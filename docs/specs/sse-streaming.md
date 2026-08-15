# Spec: First-Class Server-Sent Events (SSE) in ColdBox

**Status:** Draft / RFC
**Target:** ColdBox 8.3.0
**Runtime:** **BoxLang only** — requires BoxLang 1.7.0+ on a web runtime
**Related:** COLDBOX-1411 (`toAi()` streaming), BoxLang `SSE()` BIF

---

## 1. Motivation

ColdBox 8.1 shipped real SSE streaming, but it is **locked inside one routing
terminator**. `Router.toAi()` registers a `POST {pattern}/stream` sub-route whose
response closure calls the BoxLang `SSE()` BIF directly
(`system/web/routing/Router.cfc:2088-2120`):

```java
SSE(
    callback: ( emitter ) => {
        runnableInstance.stream(
            ( chunk ) => {
                if ( !emitter.isClosed() ) {
                    emitter.send( chunk, "chunk" )
                }
            },
            body.input ?: {}, body.params ?: {}, body.options ?: {}
        )
        if ( !emitter.isClosed() ) {
            emitter.send( "[DONE]", "done" )
            emitter.close()
        }
    },
    keepAliveInterval: 30000,
    cors             : "*"
)
```

That plumbing works. The problem is that it is only reachable if your endpoint
happens to be an `IAiRunnable`. A developer who wants to stream **job progress,
log tails, live dashboard metrics, notifications, or HTMX fragments** has to
bypass ColdBox entirely and call the BIF from inside a handler — losing
interception points, losing the rendering pipeline, and having to remember to
suppress ColdBox's own rendering by hand.

This spec promotes streaming to a first-class ColdBox concern:
**any handler action or route can stream.**

### Non-goals

- **Not** making the `Renderer` streaming. `Renderer.cfc` stays buffered
  (`savecontent` + `StringBuilder`); `Bootstrap` still `writeOutput()`s one
  string for normal requests. SSE is a *parallel* response mode, not a rewrite
  of the rendering pipeline.
- **Not** WebSockets. That is SocketBox territory.
- **Not** CFML. Adobe and Lucee have no equivalent primitive; this spec defines
  clean detection and failure instead of a shim.

---

## 2. Runtime guard

`SSE()` is a **core BoxLang BIF** introduced in **1.7.0**. It is *not* part of
the `bxai` module.

This matters: the existing `Router.ensureBoxLang()` (`Router.cfc:1961`) throws
`ModuleNotFoundException` unless `bxai` is installed, because `toAi()` genuinely
needs it. The generalized SSE API **must not** inherit that requirement.

A new, narrower private guard is introduced. It is a **server-scope check only** —
no version detection:

```java
/**
 * Verifies the active runtime can stream Server-Sent Events.
 *
 * @throws SSENotSupportedException If not running on BoxLang
 */
private function ensureSSESupport(){
    if ( !server.keyExists( "boxlang" ) ) {
        throw(
            type   : "SSENotSupportedException",
            message: "Server-Sent Events require BoxLang.",
            detail : "event.sse() is a BoxLang-only feature. Guard calls with event.isSSESupported()."
        )
    }
}
```

`isSSESupported()` is the same check, returned as a boolean.

Deliberately **not** doing version detection. ColdBox 8.x already requires a
BoxLang release well past 1.7.0, so a runtime new enough to run the framework is
new enough to have the BIF. Parsing `server.boxlang.version` to re-verify that
would add a brittle string comparison guarding against a configuration that
cannot occur in practice. If someone does manage it, they get a clean
`Unknown function [SSE]` error from the runtime, which is adequate.

Applications that must run on both BoxLang and CFML use the public predicate to
degrade gracefully:

```java
boolean function isSSESupported()
```

---

## 3. API surface

### 3.1 `event.sse()` — the primary entry point

Added to `system/web/context/RequestContext.cfc`.

```java
/**
 * Stream a Server-Sent Events response. BoxLang only.
 *
 * Takes over the response: ColdBox rendering is suppressed and the layout/view
 * pipeline is skipped. The callback receives a ColdBox SSEEmitter.
 *
 * @callback          A closure/lambda receiving ( emitter ). Required.
 * @keepAliveInterval Milliseconds between automatic keep-alive comments. 0 disables.
 * @retry             Client reconnect hint in milliseconds. 0 omits the field.
 * @cors              CORS origin. "*" for all, "" for none.
 * @headers           Additional response headers to set before the stream opens.
 *
 * @throws SSENotSupportedException If the runtime cannot stream
 */
RequestContext function sse(
    required any callback,
    numeric keepAliveInterval = getSSESetting( "keepAliveInterval" ),
    numeric retry             = getSSESetting( "retry" ),
    string  cors              = getSSESetting( "cors" ),
    struct  headers           = {}
)
```

### No async mode

The BIF's `async` and `timeout` arguments are deliberately **not exposed**.

BoxLang's async mode runs the callback on a background thread, but ColdBox's
`RequestContext` is request-scoped — a detached callback would lose `rc`, `prc`,
and everything `SSEEmitter.sendView()` depends on. Rather than ship an argument
that quietly breaks half the emitter API, ColdBox always streams synchronously.
`timeout` goes with it, since it only governs async execution.

Applications that need to do background work *while* streaming should use the
existing `AsyncManager` inside the callback and emit from the streaming thread.

**Behavior, in order:**

1. `ensureSSESupport()` — throw early and clearly on the wrong runtime.
2. Mark the request: `variables.privateContext.coldbox_sse = true` and call
   `noRender()` so `Bootstrap.cfc:296` (`if ( not event.isNoRender() )`) skips
   the whole render block.
3. **Clear any event-cache entry** — see §5.1.
4. **Disable flash autosave for this request** — see §5.2.
5. Apply `arguments.headers` through the existing `setHTTPHeader()`.
6. Announce **`preSSEConnection`** with `{ event, options }`. An interceptor
   returning `true` short-circuits the chain and **aborts the stream** — this is
   the auth/rate-limit hook, and it reuses the existing short-circuit semantics
   in `InterceptorState.cfc:410-422`. See §3.6 for how a rejection is rendered.
7. Invoke the BIF, wrapping the raw BoxLang emitter in a ColdBox `SSEEmitter`
   before handing it to the user callback.
8. On any exception inside the callback, announce **`onSSEError`**, log through
   LogBox, and attempt `emitter.close()`.
9. Announce **`postSSEConnection`** with `{ sentCount, duration }`.
10. Return `this` for chaining.

### 3.2 `event.isSSE()`

```java
boolean function isSSE()
```

Returns true once `sse()` has taken over the response. **Required** so the REST
pipeline does not try to marshal a response on top of a live stream — see §6.

### 3.3 `SSEEmitter` — `system/web/context/SSEEmitter.cfc`

A thin ColdBox decorator over the BoxLang emitter. It delegates the native four
methods and adds ColdBox-aware ones. The decorator exists so streaming can reach
the `Renderer` and `DataMarshaller`, which the raw BIF knows nothing about.

**Delegated (pass-through to the BoxLang emitter):**

| Method | Notes |
|---|---|
| `send( data, event="", id="" )` | Complex `data` is auto-serialized to JSON by BoxLang |
| `comment( text )` | SSE comment line, useful for manual keep-alives |
| `close()` | Graceful close |
| `isClosed()` | True once the client disconnects |

**Added by ColdBox:**

| Method | Purpose |
|---|---|
| `isOpen()` | `!isClosed()` — reads better in `while` loops |
| `sendView( view, args={}, layout="", module="", event="", id="" )` | Render a ColdBox view via `view()` and push the HTML as one event. Newlines are escaped into multiple `data:` lines per the SSE spec. This is the HTMX / live-fragment path. |
| `sendLayout( layout, view="", args={}, module="", event="", id="" )` | Render through `layout()` when a frame needs a full wrapped document, not a bare fragment |
| `sendData( data, type="json", event="", id="" )` | Marshal through `DataMarshaller` so XML and custom `$renderdata()` objects work, not just JSON |
| `sendError( message, code="" )` | Emits a conventional `event: error` frame with `{ error, code }` |
| `sendIf( condition, data, event="", id="" )` | Send only when open and `condition` is true — removes the ubiquitous `if ( !emitter.isClosed() )` boilerplate |
| `getSentCount()` | Number of frames sent; surfaced in `postSSEConnection` |
| `heartbeat()` | Manual keep-alive comment |

**Critically, every send is a no-op once the client disconnects.** The raw BIF
forces `if ( !emitter.isClosed() )` around every call — visible three times in
the 30-line `toAi()` stream closure. The decorator absorbs that check, so a
disconnect quietly ends the stream instead of throwing.

`sendView()` and `sendLayout()` delegate to the same `view()` and `layout()`
methods every handler already uses (`FrameworkSupertype.cfc:173` and `:234`), so
module lookup, view caching, and the `preViewRender`/`postViewRender` points all
behave exactly as they do in a normal render. `sendView()` defaults to
layout-less because SSE frames are usually fragments; pass `layout` when a frame
needs wrapping.

### 3.4 `Router.toSSE()` — routing terminator

Mirrors the existing `toResponse()` terminator, for streams with no handler.

```java
/**
 * Terminates the route by streaming a Server-Sent Events response.
 *
 * @callback A closure/lambda receiving ( event, rc, prc, emitter )
 */
function toSSE( required callback )
```

Adds two keys to the route definition in `initRouteDefinition()`
(`Router.cfc:1119`):

```java
"sse"         : false,  // Flag indicating this route streams SSE
"sseCallback" : ""      // The streaming closure
```

`RoutingService.processRoute()` gains an `sse` branch alongside the existing
`response` branch, calling `event.sse()` and then `noExecution()`.

Unlike `toAi()`, `toSSE()` calls `ensureSSESupport()` — **not** `ensureBoxLang()` —
so it does not demand `bxai`.

### 3.5 Configuration

#### Global defaults

New block in `system/web/config/Settings.cfc`, a sibling of `this.flash`:

```java
// Server-Sent Events defaults (BoxLang only)
this.sse = {
    "keepAliveInterval" : 30000,  // 30s — most proxies idle-timeout at 60s
    "retry"             : 0,      // no client reconnect hint by default
    "cors"              : "*"     // preserves toAi()'s existing behavior
}
```

Parsed by a new `parseSSE()` in `system/web/config/ApplicationLoader.cfc`,
following the existing `parseFlashScope()` pattern and registered as the `sse`
setting, so applications configure it in `config/Coldbox.cfc`:

```java
function configure(){
    sse = {
        cors              : "https://app.example.com",
        keepAliveInterval : 15000
    }
}
```

#### CORS is configuration, never a hardcoded literal

`toAi()` currently hardcodes `cors: "*"` in its stream sub-route
(`Router.cfc:2116`), so there is no way to change it. **This spec removes that
hardcode** — `toAi()`'s stream route reads the `sse` setting like every other
stream, and per-route overrides go through the `cors` argument.

The default stays `"*"`, which keeps every existing `toAi()` deployment working
unchanged. This is a deliberate trade: a permissive default is not what you would
choose on a blank sheet, but silently dropping `Access-Control-Allow-Origin` from
live AI endpoints on a minor upgrade is worse. Applications that want it tighter
set `sse = { cors : "" }`. **This is worth revisiting for 9.0**, where flipping
the default to `""` would be an appropriate major-version change.

#### Module-level overrides

A `ModuleConfig` may declare its own block in `configure()`, stored in that
module's settings alongside everything else modules already configure:

```java
// modules_app/notifications/ModuleConfig.cfc
function configure(){
    settings = {
        sse : {
            cors              : "https://notify.example.com",
            keepAliveInterval : 10000
        }
    }
}
```

`ModuleService.activateModule()` already merges `variables.settings` into
`moduleSettings.<module>` (`ModuleService.cfc:1337-1355`), so no new storage
mechanism is needed — SSE settings ride the existing three-tier override chain
(ModuleConfig → app config → `config/modules/<name>.cfc`).

Resolution is handled by a private `getSSESetting( key )` on `RequestContext`:

1. If `event.getCurrentModule()` is non-empty and that module's settings declare
   an `sse` struct containing `key`, use it.
2. Otherwise fall back to the global `sse` setting.

So a stream served from a module's handler inherits that module's SSE
configuration automatically, and an explicit argument to `event.sse()` still
wins over both.

### 3.6 Interception points

Appended to the ENUM in `system/web/services/InterceptorService.cfc:44`:

| Point | Data | Use |
|---|---|---|
| `preSSEConnection` | `{ options }` | Auth, rate limiting, connection caps. Return `true` to reject. |
| `postSSEConnection` | `{ sentCount, duration }` | Metrics, connection accounting |
| `onSSEError` | `{ exception, sentCount }` | Logging, alerting |

#### Rejecting a connection

When `preSSEConnection` returns `true`, the stream never opens. The interceptor
may shape that rejection three ways:

- **Do nothing** — ColdBox responds **403 Forbidden** with an empty body. A bare
  socket close is hostile to debug, so there is always a default status.
- **Set a status** — `event.setHTTPHeader( statusCode = 429 )` and that wins.
- **Render a response** — call `event.setView()` or `event.setLayout()` and
  ColdBox renders it normally. Because `sse()` bails before calling the BIF, the
  response was never committed, so the standard render pipeline is still
  available. This is what makes a rejected stream able to return a real error
  page or an HTMX error fragment rather than an empty 403.

Rejection therefore clears the `coldbox_sse` marker and the `noRender()` flag
that `sse()` set, so `Bootstrap` renders as it would for any normal request.

---

## 4. Examples

### 4.1 Minimal — a countdown

```java
component extends="coldbox.system.EventHandler" {

    function countdown( event, rc, prc ){
        event.sse( ( emitter ) => {
            for ( var i = 10; i > 0; i-- ) {
                if ( emitter.isClosed() ) {
                    break
                }
                emitter.send( { "count" : i }, "tick" )
                sleep( 1000 )
            }
            emitter.send( "liftoff", "done" )
            emitter.close()
        } )
    }

}
```

Client:

```javascript
const source = new EventSource( "/main/countdown" );

source.addEventListener( "tick", e => {
    document.querySelector( "#counter" ).textContent = JSON.parse( e.data ).count;
} );

source.addEventListener( "done", () => source.close() );
```

### 4.2 Job progress

Polls a job's status from the streaming thread. Since ColdBox never detaches the
callback (§3.1), `rc`, `prc` and injected models are all available throughout.

```java
component extends="coldbox.system.EventHandler" {

    property name="jobService" inject="JobService";

    function progress( event, rc, prc ){
        var jobId = event.getValue( "jobId", "" )

        event.sse( ( emitter ) => {
            while ( emitter.isOpen() ) {
                var status = jobService.getStatus( jobId )

                emitter.send(
                    { "percent" : status.percent, "message" : status.message },
                    "progress"
                )

                if ( status.complete ) {
                    emitter.send( status.result, "complete" )
                    break
                }

                sleep( 500 )
            }
            emitter.close()
        }, keepAliveInterval = 15000 )
    }

}
```

### 4.3 Streaming rendered views (HTMX / live fragments)

`sendView()` is why the emitter is decorated rather than passed through raw.

```java
function feed( event, rc, prc ){
    event.sse( ( emitter ) => {
        var lastId = event.getValue( "lastId", 0 )

        while ( emitter.isOpen() ) {
            var posts = postService.since( lastId )

            posts.each( ( post ) => {
                emitter.sendView(
                    view  = "posts/_card",
                    args  = { post : post },
                    event = "newPost"
                )
                lastId = post.getId()
            } )

            sleep( 2000 )
        }
    } )
}
```

```html
<div hx-ext="sse" sse-connect="/posts/feed" sse-swap="newPost" hx-swap="afterbegin"></div>
```

### 4.4 Inline route, no handler

```java
// config/Router.cfc
function configure(){
    route( "/events/heartbeat" )
        .toSSE( ( event, rc, prc, emitter ) => {
            while ( emitter.isOpen() ) {
                emitter.send( { "ts" : now() }, "heartbeat" )
                sleep( 5000 )
            }
        } )
}
```

### 4.5 Secured stream with CORS, via a route group

Route modifiers compose exactly as they do for every other terminator.

```java
group( { pattern : "/api/v1/streams", condition : ( route, params, event ) => event.isAuthenticated() }, () => {

    route( "/notifications" )
        .toSSE( ( event, rc, prc, emitter ) => {
            notificationService.subscribe( event.getUserId(), ( notification ) => {
                emitter.sendIf( emitter.isOpen(), notification, "notification" )
            } )
        } )

} )
```

Per-route CORS, tightening the permissive default:

```java
function notifications( event, rc, prc ){
    event.sse(
        callback = ( emitter ) => { ... },
        cors     = "https://app.example.com",
        retry    = 3000
    )
}
```

### 4.6 Connection limits via an interceptor

Reuses the short-circuit semantics the interceptor chain already has.

```java
component extends="coldbox.system.Interceptor" {

    property name="cache" inject="cachebox:default";

    /**
     * Cap concurrent streams per user. Returning true aborts the connection.
     */
    boolean function preSSEConnection( event, data, rc, prc ){
        var userId = event.getUserId()
        var active = cache.get( "sse-count-#userId#", 0 )

        if ( active >= 3 ) {
            event.setHTTPHeader( statusCode = 429 )
            return true
        }

        cache.set( "sse-count-#userId#", active + 1, 60 )
        return false
    }

    function postSSEConnection( event, data, rc, prc ){
        log.info( "SSE closed: #data.sentCount# frames in #data.duration#ms" )
    }

}
```

### 4.7 Graceful degradation on CFML

```java
function updates( event, rc, prc ){
    if ( !event.isSSESupported() ) {
        // Fall back to polling on Adobe/Lucee
        return event.renderData( type = "json", data = updateService.latest() )
    }

    event.sse( ( emitter ) => { ... } )
}
```

---

## 5. Implementation notes

### Files touched

| File | Change |
|---|---|
| `system/web/context/RequestContext.cfc` | Add `sse()`, `isSSE()`, `isSSESupported()`, private `ensureSSESupport()` and `getSSESetting()` |
| `system/web/context/SSEEmitter.cfc` | **New** — decorator over the BoxLang emitter |
| `system/web/routing/Router.cfc` | Add `toSSE()`; add `sse` + `sseCallback` to `initRouteDefinition()` (line 1119); replace the hardcoded `cors: "*"` in `toAi()` (line 2116) with the setting |
| `system/web/services/RoutingService.cfc` | Add an `sse` branch to `processRoute()`, next to the existing `response` branch |
| `system/web/services/InterceptorService.cfc` | Append 3 interception points to the ENUM (line 44) |
| `system/web/config/Settings.cfc` | Add the `this.sse` defaults block |
| `system/web/config/ApplicationLoader.cfc` | Add `parseSSE()` to the parser chain, following `parseFlashScope()` |
| `system/RestHandler.cfc` | Early exit in `aroundHandler` for SSE — skips both marshalling and header flush (§6) |
| `system/testing/mock/web/MockSSEEmitter.cfc` | **New** — recording emitter for tests |
| `system/testing/CustomMatchers.cfc` | Add `toHaveSentSSEEvent()` |

### Why `noRender()` and not `noExecution()`

`noExecution()` skips the *handler*, which is wrong — the handler is what opens
the stream. `noRender()` skips only the render block at `Bootstrap.cfc:296`,
which is exactly the desired effect. `toSSE()` routes use both, matching how
`toResponse()` already behaves.

### 5.1 Event caching must be cleared, not merely ignored

If a streaming action carries a `cache=true` annotation, `Bootstrap.cfc:243-290`
looks up an event-cache entry on the way in and writes one on the way out. For a
stream there is no `renderedContent` to store, so the framework would cache an
empty response — and then serve that empty response to every subsequent request
until it expires, silently breaking the endpoint in a way that looks like a
client bug.

`event.sse()` therefore **clears the cacheable entry outright**, so the write-back
path at `Bootstrap.cfc:378-390` has nothing to store. Streaming and event caching
are fundamentally incompatible; making that explicit at the point of no return is
better than trusting every developer to never combine the two annotations.

### 5.2 Flash scope is disabled for streams

Flash is a page-transition concept — values survive exactly one redirect. A
stream is not a page transition, and it may hold the request open for minutes
before `Bootstrap.cfc:415-420` runs the autosave. Persisting flash values at that
point would attach them to whatever unrelated request the user makes next.

`event.sse()` disables flash autosave for the request. Handlers can still read
inflated flash values; they just will not be re-persisted on stream close.

---

## 6. Interaction with `RestHandler`

This is the one real integration hazard, and it is **in scope for this spec**.

`RestHandler.aroundHandler` (`system/RestHandler.cfc:40`) does two things after
the action returns that are both invalid once a stream has been committed:

1. **Lines 118-142** — *if the action returned nothing, set no view, and set no
   render data, then call `event.renderData( ... )`.* A streaming action
   satisfies all three conditions, so it marshals a JSON envelope onto a response
   that has already been streamed and closed.
2. **Lines 145-150** — adds `x-response-time` and flushes
   `prc.response.getHeaders()` through `event.setHTTPHeader()`. Every one of
   those is a write-after-commit against a response whose headers went out the
   moment the stream opened.

Guarding only the render condition, as originally drafted, would have left the
header writes broken. The correct fix is a single early exit covering both,
inserted after the response timer is set (line 115) and before the render block:

```java
// end timer
arguments.prc.response.setResponseTime( getTickCount() - stime )

// SSE streams have already committed the response — no marshalling, no header
// writes. Both would be write-after-commit against an open or closed stream.
if ( arguments.event.isSSE() ) {
    if ( !isNull( local.actionResults ) ) {
        return local.actionResults
    }
    return
}

// Did the controllers set a view to be rendered? ...
```

The debug-mode block at lines 106-112 needs no guard: it only mutates the
in-memory `Response` object and never touches the wire.

A REST handler streaming is then well-defined:

```java
component extends="coldbox.system.RestHandler" {

    function events( event, rc, prc ){
        event.sse( ( emitter ) => {
            emitter.send( { "hello" : "world" }, "greeting" )
            emitter.close()
        } )
        // aroundHandler sees isSSE() and leaves the response alone
    }

}
```

---

## 7. Testing

SSE cannot be exercised through the normal `BaseTestCase.execute()` path — there
is no real response to stream into. Instead, when `event.sse()` runs under a
`MockController`, it substitutes a `MockSSEEmitter` that records frames in memory
and runs the callback synchronously.

```java
component extends="tests.resources.BaseIntegrationTest" {

    function run(){
        describe( "SSE streaming", function(){

            it( "streams a countdown and closes", function(){
                var event   = this.get( "main.countdown" )
                var emitter = event.getValue( "_sseEmitter", {}, true )

                expect( emitter.getSentEvents() ).toHaveLength( 11 )
                expect( emitter.getSentEvents()[ 1 ].event ).toBe( "tick" )
                expect( emitter ).toHaveSentSSEEvent( "done" )
                expect( emitter.isClosed() ).toBeTrue()
            } )

            it( "throws a clear exception on CFML engines", function(){
                if ( isBoxLang() ) {
                    return
                }
                expect( () => this.get( "main.countdown" ) )
                    .toThrow( "SSENotSupportedException" )
            } )

        } )
    }

}
```

`MockSSEEmitter` exposes `getSentEvents()` (array of `{ data, event, id }`),
`getComments()`, `isClosed()`, and `simulateDisconnect()` so tests can assert
that loops terminate when a client drops.

---

## 8. Open questions

### Resolved

| # | Question | Decision |
|---|---|---|
| 1 | `toAi()` CORS break | **`cors` defaults to `"*"`.** No break; existing deployments keep working. Revisit for 9.0. (§3.5) |
| 2 | Where the setting lives | **Top-level `this.sse`**, sibling of `this.flash`, parsed by `ApplicationLoader` into the `sse` setting. (§3.5) |
| 3 | Module overrides | **Per-module**, stored in that module's settings via the existing three-tier merge; resolved by `getSSESetting()`. (§3.5) |
| 4 | `async` + request scope | **Not exposed.** `async` and `timeout` are dropped from the ColdBox API; streams are always synchronous. (§3.1) |
| 5 | Flash on long streams | **Disabled** for SSE requests. (§5.2) |
| 6 | Event caching collision | **Cacheable entry cleared** outright by `sse()`. (§5.1) |
| 7 | Aborted `preSSEConnection` | **Defaults to 403**, overridable by status, or renderable via `setView()` / `setLayout()`. (§3.6) |
| — | `sendView()` and layouts | Layout-less by default; `layout` argument plus a `sendLayout()` method. (§3.3) |
| — | Runtime check | `server.keyExists( "boxlang" )`, no version detection. (§2) |
| — | `RestHandler` | Early exit covering both marshalling and header flush. (§6) |

### Still open

1. **Should `sse` join the format-negotiation path?** Every real-world SSE REST
   API — OpenAI, Anthropic, MCP's Streamable HTTP transport, Spring, ASP.NET
   Core — streams from the **same** URL as the JSON response, with `Accept:
   text/event-stream` or a `stream: true` body flag selecting the shape. MCP
   explicitly deprecated its two-endpoint HTTP+SSE design in favor of one
   endpoint for exactly this reason.

   `toAi()` currently does the opposite, registering a separate
   `POST {base}/stream` sub-route. ColdBox already has the machinery to do it the
   industry-standard way: `RoutingService.detectExtension()` reduces the `Accept`
   header into `rc.format` against `Router.VALID_EXTENSIONS`, and
   `RestHandler.aroundHandler:54-56` already calls
   `prc.response.setFormat( rc.format )`. Adding `sse` to `VALID_EXTENSIONS` and
   the negotiation path would enable:

   ```java
   function index( event, rc, prc ){
       if ( event.getValue( "format", "" ) == "sse" ) {
           return event.sse( ( emitter ) => { ... } )
       }
       return messageService.list()
   }
   ```

   One URL, `Accept` decides. Recommend yes. This does not block the rest of the
   spec — it is additive — but it affects whether `toAi()`'s `/stream` sub-route
   should eventually be deprecated.

2. **Naming.** `sse()` / `toSSE()` is explicit but locks the name to one
   transport. If BoxLang later adds other streaming primitives, `stream()` /
   `toStream()` would age better. Recommend keeping `sse()` — it matches the BIF
   and the client-side `EventSource` contract.

3. **`postProcess` on long-lived streams.** Flash is handled (§5.2), but
   `postProcess` still fires only when the stream finally closes, which may be
   minutes after the request began. Probably correct, but interceptors doing
   per-request timing will see wildly skewed numbers and should be aware.
