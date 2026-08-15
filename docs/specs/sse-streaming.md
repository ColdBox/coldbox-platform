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

A new, narrower private guard is introduced:

```java
/**
 * Verifies the active runtime can stream Server-Sent Events.
 *
 * @throws SSENotSupportedException If not running on BoxLang, or on a BoxLang
 *                                  runtime older than 1.7.0, or in a non-web runtime
 */
private function ensureSSESupport(){
    if ( !server.keyExists( "boxlang" ) ) {
        throw(
            type   : "SSENotSupportedException",
            message: "Server-Sent Events require BoxLang. The active runtime is [#server.coldfusion.productname#].",
            detail : "event.sse() is a BoxLang-only feature. Guard calls with event.isSSESupported()."
        )
    }
}
```

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
 * @async             Run the callback on a background thread.
 * @timeout           Maximum execution time in ms for async mode. 0 is unlimited.
 * @headers           Additional response headers to set before the stream opens.
 *
 * @throws SSENotSupportedException If the runtime cannot stream
 */
RequestContext function sse(
    required any callback,
    numeric keepAliveInterval = getController().getSetting( "sse" ).keepAliveInterval,
    numeric retry             = getController().getSetting( "sse" ).retry,
    string  cors              = getController().getSetting( "sse" ).cors,
    boolean async             = false,
    numeric timeout           = getController().getSetting( "sse" ).timeout,
    struct  headers           = {}
)
```

**Behavior, in order:**

1. `ensureSSESupport()` — throw early and clearly on the wrong runtime.
2. Mark the request: `variables.privateContext.coldbox_sse = true` and call
   `noRender()` so `Bootstrap.cfc:296` (`if ( not event.isNoRender() )`) skips
   the whole render block.
3. Apply `arguments.headers` through the existing `setHTTPHeader()`.
4. Announce **`preSSEConnection`** with `{ event, options }`. An interceptor
   returning `true` short-circuits the chain and **aborts the stream** — this is
   the auth/rate-limit hook, and it reuses the existing short-circuit semantics
   in `InterceptorState.cfc:410-422`.
5. Invoke the BIF, wrapping the raw BoxLang emitter in a ColdBox `SSEEmitter`
   before handing it to the user callback.
6. On any exception inside the callback, announce **`onSSEError`**, log through
   LogBox, and attempt `emitter.close()`.
7. Announce **`postSSEConnection`** with `{ sentCount, duration }`.
8. Return `this` for chaining.

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
| `sendView( view, args={}, event="", id="", module="" )` | Render a ColdBox view and push the HTML as one event. Newlines are escaped into multiple `data:` lines per the SSE spec. This is the HTMX / live-fragment path. |
| `sendData( data, type="json", event="", id="" )` | Marshal through `DataMarshaller` so XML and custom `$renderdata()` objects work, not just JSON |
| `sendError( message, code="" )` | Emits a conventional `event: error` frame with `{ error, code }` |
| `sendIf( condition, data, event="", id="" )` | Send only when open and `condition` is true — removes the ubiquitous `if ( !emitter.isClosed() )` boilerplate |
| `getSentCount()` | Number of frames sent; surfaced in `postSSEConnection` |
| `heartbeat()` | Manual keep-alive comment |

**Critically, every send is a no-op once the client disconnects.** The raw BIF
forces `if ( !emitter.isClosed() )` around every call — visible three times in
the 30-line `toAi()` stream closure. The decorator absorbs that check, so a
disconnect quietly ends the stream instead of throwing.

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

New block in `system/web/config/Settings.cfc`:

```java
// Server-Sent Events defaults (BoxLang only)
this.sse = {
    "keepAliveInterval" : 30000,  // 30s — most proxies idle-timeout at 60s
    "retry"             : 0,      // no client reconnect hint by default
    "cors"              : "",     // no CORS by default — opt in explicitly
    "timeout"           : 0       // unlimited
}
```

Note the deliberate difference from `toAi()`, which hardcodes `cors: "*"`
(`Router.cfc:2116`). **A framework default of `cors: "*"` is wrong** — it makes
every stream readable cross-origin. The default here is `""`, opt-in per route.
`toAi()`'s existing behavior is left untouched for backward compatibility, but
should be flagged for review.

### 3.6 Interception points

Appended to the ENUM in `system/web/services/InterceptorService.cfc:44`:

| Point | Data | Use |
|---|---|---|
| `preSSEConnection` | `{ options }` | Auth, rate limiting, connection caps. Return `true` to reject. |
| `postSSEConnection` | `{ sentCount, duration }` | Metrics, connection accounting |
| `onSSEError` | `{ exception, sentCount }` | Logging, alerting |

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

### 4.2 Job progress, driven by the async subsystem

Uses the existing `AsyncManager` — no new async machinery.

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

Per-route CORS, overriding the safe default:

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
| `system/web/context/RequestContext.cfc` | Add `sse()`, `isSSE()`, `isSSESupported()`, private `ensureSSESupport()` |
| `system/web/context/SSEEmitter.cfc` | **New** — decorator over the BoxLang emitter |
| `system/web/routing/Router.cfc` | Add `toSSE()`; add `sse` + `sseCallback` to `initRouteDefinition()` (line 1119) |
| `system/web/services/RoutingService.cfc` | Add an `sse` branch to `processRoute()`, next to the existing `response` branch |
| `system/web/services/InterceptorService.cfc` | Append 3 interception points to the ENUM (line 44) |
| `system/web/config/Settings.cfc` | Add the `this.sse` defaults block |
| `system/RestHandler.cfc` | Guard `aroundHandler` against marshalling over a live stream (§6) |
| `system/testing/mock/web/MockSSEEmitter.cfc` | **New** — recording emitter for tests |
| `system/testing/CustomMatchers.cfc` | Add `toHaveSentSSEEvent()` |

### Why `noRender()` and not `noExecution()`

`noExecution()` skips the *handler*, which is wrong — the handler is what opens
the stream. `noRender()` skips only the render block at `Bootstrap.cfc:296`,
which is exactly the desired effect. `toSSE()` routes use both, matching how
`toResponse()` already behaves.

---

## 6. Interaction with `RestHandler`

This is the one real integration hazard. `RestHandler.aroundHandler`
(`system/RestHandler.cfc:40`) ends with: *if the action returned nothing, set no
view, and set no renderData, then call `event.renderData( ... )`.* A streaming
action satisfies all three conditions, so it would try to marshal a JSON envelope
onto a response that has already been streamed and closed.

`aroundHandler` must therefore add `!event.isSSE()` to that final condition.
Same for the `x-response-time` header write, which would be a write-after-commit.

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

1. **Should `toAi()` be refactored onto this API?** It would delete the
   hand-rolled `SSE()` call in `Router.cfc:2088-2120` and give AI streams the
   interception points for free. Behavior-compatible except that `cors: "*"`
   would become configurable — arguably a fix, technically a behavior change.
2. **`async = true` and request scope.** BoxLang's async mode runs the callback
   on a background thread. ColdBox's `RequestContext` lives in `request` scope,
   so a detached callback may lose it. Recommend documenting `async` as
   advanced-use and defaulting to `false` until the context-propagation behavior
   is verified against a real BoxLang web runtime.
3. **Should `sendView()` exist at all?** It couples streaming to the `Renderer`.
   Argued yes: HTMX SSE swaps are a major use case and the alternative is every
   app hand-rolling `getRenderer().view()` plus newline escaping.
4. **Minimum BoxLang version detection.** `server.boxlang` exists, but this spec
   does not yet pin how to read the version to enforce `>= 1.7.0`. Needs
   verification against a live runtime before implementation.
