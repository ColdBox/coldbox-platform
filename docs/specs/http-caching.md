# Spec: HTTP Caching Primitives in ColdBox

**Status:** Draft — no implementation yet
**Target:** ColdBox 8.3.0 (or next minor)
**Runtime:** BoxLang + CFML (Adobe, Lucee) — pure HTTP header mechanics, no BIF dependency
**Related:** ColdBox's existing Event Caching (`system/Bootstrap.cfc`, `HandlerService.cfc`);
`docs/specs/sse-streaming.md` (the annotation/interception-point conventions this spec follows)

---

## 1. Motivation

A case-insensitive grep across `system/` for `etag`, `last-modified`, `cache-control`,
`if-none-match`, `if-modified-since`, and `304` returns **zero hits** (the lone `"304"` string
anywhere in the codebase is a status-text lookup entry, unrelated to caching). ColdBox has no
concept of HTTP-level conditional requests or cache negotiation. Every response — cached
server-side or not — always sends a full `200` with a full body.

That is a real gap for anything that talks to a browser, CDN, or reverse proxy: API resources
that rarely change, static-ish content endpoints, polling clients, HTMX partials. All of them
would benefit from being able to say "you already have this" (`Cache-Control`) or "ask me, and
I'll say 304 if nothing changed" (`ETag` / `Last-Modified`).

### This is not Event Caching, and must not be confused with it

ColdBox already ships a caching system that looks adjacent but solves a different problem, and
this spec's central design move is to sit *on top of* it rather than duplicate it.

**Event Caching** (`cache="true"` on a handler action, `system/Bootstrap.cfc:243-403`) caches the
**server's own rendered output** in CacheBox so ColdBox can skip re-running the handler and
re-rendering the view on a hit. It is a *server compute* optimization. It has nothing to say to
the client — a cache hit still ships a full `200` response with the full body over the wire,
every time, forever, to every client, even one that already has last minute's identical bytes.

**HTTP Caching** (this spec) is the *client-facing* layer: it lets the browser, a CDN, or a
reverse proxy skip the round trip entirely, or lets the server skip sending the body when the
client can prove it already has the current representation. It is orthogonal to whether the
server itself re-computed that representation.

They compose. §4 is built entirely around the observation that Event Caching's existing
machinery — a pre-execution cache lookup, sitting in memory with the full rendered body, before
ColdBox has committed to sending it — is exactly the leverage point HTTP caching needs, and that
combining the two is nearly free.

### Non-goals

- **Not** a route-level cache-rules system (`cache`/`cacheTimeout`/`cacheKey` as route-struct
  keys, à la Nitro's `routeRules`). That is a separate, later recommendation that would *consume*
  the primitives this spec defines — it is not designed here.
- **Not** replacing or deprecating Event Caching. Every existing `cache="true"` handler keeps
  working exactly as it does today if it never opts into anything this spec adds.
- **Not** CDN/reverse-proxy configuration, surrogate keys, or cache purging APIs.
- **Not** content negotiation via `Vary` on representation (gzip/br, `Accept`-based format
  switching). `Vary` is mentioned only as a correctness caveat in §4.5.

---

## 2. Two independent knobs

| | Event Caching (existing) | HTTP Caching (this spec) |
|---|---|---|
| **Question it answers** | "Do I need to re-run the handler and re-render?" | "Does the *client* need to re-fetch the body?" |
| **Where it lives** | Server (CacheBox) | Client / CDN / proxy, via response headers |
| **Mechanism** | `system/Bootstrap.cfc:245-289` looks up a cache entry keyed by event + hashed RC before calling `runEvent()` | `ETag` / `Last-Modified` response headers, checked against `If-None-Match` / `If-Modified-Since` request headers |
| **On a hit today** | Skips handler execution, replays stored body — but still ships the full body | N/A (doesn't exist yet) |
| **On a hit after this spec** | Unchanged, unless `etag`/`lastModified` also opted in | Client gets `304 Not Modified`, zero-byte body |
| **Annotation** | `cache="true" cacheTimeout="30" ...` (`HandlerService.cfc:801-811`) | New sibling annotations on the *same* function, see §4.1 |

A handler can use either, both, or neither. The deep automatic behavior in §4.2 only activates
when **both** are opted into together — that combination is where the free win is.

---

## 3. Manual API surface

The baseline, engine-agnostic primitives every automatic behavior in §4 is built from. These are
useful standalone even without any annotation.

### 3.1 `RequestContext.cfc`

Built entirely from methods that already exist: `setHTTPHeader( name=, value= )`
(`RequestContext.cfc:2173`), `getHTTPHeader( header, defaultValue )` (`:2144`), `noExecution()`
(`:1192`).

```java
/**
 * Sets the ETag response header and checks it against an incoming If-None-Match.
 * On a match, short-circuits the request with a bare 304 and returns true.
 *
 * @value The entity tag value (unquoted - quoting is handled here)
 * @weak  Mark as a weak validator (W/"...") - use when the representation is
 *        semantically-but-not-byte-identical across regenerations
 *
 * @return True if the request was short-circuited with a 304
 */
boolean function etag( required string value, boolean weak = false ){
    var tag = ( arguments.weak ? "W/" : "" ) & '"#arguments.value#"';
    setHTTPHeader( name="ETag", value=tag );

    if ( getHTTPHeader( "If-None-Match", "" ) == tag ) {
        noExecution();
        setHTTPHeader( statusCode=304 );
        return true;
    }
    return false;
}

/**
 * Sets Last-Modified and checks it against an incoming If-Modified-Since.
 *
 * @value HTTP-date granularity is seconds - callers with sub-second timestamps
 *        should round down, never up, to avoid false negatives
 *
 * @return True if the request was short-circuited with a 304
 */
boolean function lastModified( required date value ){
    var httpDate = dateTimeFormat( arguments.value, "ddd, dd mmm yyyy HH:mm:ss" ) & " GMT";
    setHTTPHeader( name="Last-Modified", value=httpDate );

    var since = getHTTPHeader( "If-Modified-Since", "" );
    if ( len( since ) && isDate( since ) && parseDateTime( since ) >= arguments.value ) {
        noExecution();
        setHTTPHeader( statusCode=304 );
        return true;
    }
    return false;
}

/**
 * Sets Cache-Control from a directive struct. Boolean values become bare
 * directives ("public", "no-cache"); others become "key=value".
 *
 * @directives e.g. { "public" : true, "max-age" : 60, "stale-while-revalidate" : 30 }
 */
function cacheControl( struct directives = { "no-cache" : true } ){
    setHTTPHeader(
        name  = "Cache-Control",
        value = arguments.directives
            .reduce( ( acc, key, val ) => {
                acc.append( ( isBoolean( val ) && val ) ? key : "#key#=#val#" );
                return acc;
            }, [] )
            .toList( ", " )
    );
    return this;
}
```

Both `etag()` and `lastModified()` return `boolean` rather than throwing or rendering, so a
handler stays in control of the early-return:

```java
function show( event, rc, prc ){
    prc.product = productService.get( rc.id );
    if ( event.etag( prc.product.getHash() ) ) {
        return;
    }
    event.setView( "products/show" );
}
```

### 3.2 `Response.cfc`

`Response.cfc` has no header-specific fluent methods today — only the generic
`addHeader( name, value )` (`:217`), used internally by `RestHandler` to accumulate headers that
get flushed via `event.setHTTPHeader()` later. Two thin fluent wrappers, matching the existing
`withStatus()`/`withData()` naming (`:409`, `:383`):

```java
Response function withETag( required string value, boolean weak = false ){
    addHeader( "ETag", ( arguments.weak ? "W/" : "" ) & '"#arguments.value#"' );
    return this;
}

Response function withCacheControl( struct directives = { "no-cache" : true } ){
    // same directive-assembly logic as RequestContext.cacheControl()
    addHeader( "Cache-Control", ... );
    return this;
}
```

Note `Response.cfc` headers are buffered and only actually written by `RestHandler.aroundHandler`
at `RestHandler.cfc:157-158` — see §6 for why a 304 must happen *before* that point, not through
this buffer.

---

## 4. The automatic layer

This is the part worth building carefully, because there are two genuinely different cost
profiles hiding under one word ("automatic"), and conflating them would make a false promise
about what the framework is actually saving.

### 4.1 Annotations extend the existing cache metadata block

Event Caching's annotation defaults live in `getNewMDEntry()` (`HandlerService.cfc:764-776`) and
are read in `getEventCachingMetadata()` (`:801-811`):

```java
// Existing, unchanged
cache                  : false,
cacheTimeout           : "",
cacheLastAccessTimeout : "",
cacheProvider          : "template",
cacheInclude           : "*",
cacheExclude           : "",
cacheFilter            : "",
```

New siblings, added to the same struct and read the same way (as function-level annotations):

```java
// New
etag         : false,   // boolean, or "auto" — see tiers below
etagWeak     : false,   // boolean
lastModified : "",      // "" (off), "true" (tier-1 only), or a private-method name (tier-2, mirrors cacheFilter's closure-by-name pattern)
cacheControl : "",      // raw Cache-Control value, e.g. "public, max-age=60"
```

Declaration is unchanged CFML annotation-on-function syntax, identical in spirit to how
`cache`/`cacheTimeout` already read today:

```java
function index( event, rc, prc )
    cache="true"
    cacheTimeout="30"
    etag="true"
{
    ...
}
```

### 4.2 Tier 1 — cache-integrated automatic ETag (the free win)

This is the deep insight the rest of the section builds on: `Bootstrap.cfc:245-289` **already**
performs a pre-execution CacheBox lookup, keyed by `EventURLFacade.buildEventKey()` +
`getUniqueHash()` (`EventURLFacade.cfc:136-145`, `:44-96` — event name + module + a filtered hash
of RC params + host), *before* `runEvent()` is ever called. On a hit, the full `renderedContent`,
`statusCode`, `contentType`, and `responseHeaders` are already sitting in memory, about to be
replayed verbatim (`Bootstrap.cfc:361`).

Piggy-backing an ETag onto that entry costs almost nothing, because the hash is computed **once,
at write time**, not on every subsequent request:

**On cache write** (`Bootstrap.cfc:340-378`, alongside the existing `cacheBox...set(...)` call at
`:370-377`): if `etag="true"` is set on the action, compute `hash( renderedContent, "MD5" )` once
and store it as an `etag` field on the same cache entry struct that already holds
`renderedContent`/`contentType`/`statusCode`.

**On cache hit** (`Bootstrap.cfc:245-289`, before the existing replay at `:290+`): if the stored
entry carries an `etag`, compare it against `getHTTPHeader( "If-None-Match", "" )` *before*
writing the body.

- **Match** → skip the replay entirely. Send a bare `304` with just `ETag` (and `Cache-Control`,
  if set) — no body write at all. This is strictly *cheaper* than what happens today on every
  cache hit, for zero extra request-time cost, because the hash already existed.
- **No match / absent `If-None-Match`** → replay the full body exactly as today, but now also
  emit the stored `ETag` header, so the *client's next* request can 304.

```
Request arrives
  │
  ├─ eventCachingTest() (RequestService.cfc:145) says cacheable?
  │    │
  │    ├─ NO → run handler + render normally (untouched by this spec)
  │    │
  │    └─ YES → look up cache entry
  │         │
  │         ├─ MISS → run handler + render
  │         │          → on write: if etag="true", hash body once, store on entry
  │         │          → send 200 + body (+ ETag header if etag="true")
  │         │
  │         └─ HIT
  │              ├─ etag NOT set on entry → replay body exactly as today (unchanged)
  │              │
  │              └─ etag set on entry → compare If-None-Match
  │                   ├─ match    → 304, no body   (NEW — cheaper than today's replay)
  │                   └─ no match → replay body + ETag header (as before, now with ETag)
```

This only activates when `etag="true"` is *explicitly* opted into alongside `cache="true"` —
existing `cache="true"` handlers that never touch this new annotation see no behavior change at
all, on either the write or read path.

### 4.3 Tier 2 — standalone automatic ETag (no Event Caching involved)

Some handlers can't or shouldn't use Event Caching — output that's too per-user-specific for the
RC-hash cache key to be meaningful, or content that must always be freshly computed server-side
but still benefits from *client-side* conditional-GET. For these, `etag="true"` without
`cache="true"` computes the hash **after** rendering, on every request, and checks it against
`If-None-Match` before the body is written to the client.

This needs a hook *after* the rendered body exists but *before* it's written to the wire.
Event Caching itself is not wired through an announced interception point — it's inline in
`Bootstrap.cfc` — so Tier 2 has the same structural choice Event Caching already made: either add
a small, explicit check inline in `Bootstrap.cfc`'s render path (mirroring how the cache-write
branch works, just without CacheBox), or introduce a new interception point
(`preResponseWrite`, firing after `renderedContent` is final and before `writeOutput()`) that a
core, conditionally-registered interceptor listens on. The latter is more consistent with how the
SSE work extended the interception-point ENUM (`InterceptorService.cfc:44-92`) rather than adding
inline branches, and is the recommended approach — left as an implementation decision, not a
design gap, since either is mechanically straightforward.

**This tier's cost model is genuinely different, and must be documented as such**: the handler
and the full render *still run on every request* — Tier 2 saves the client a body download, but
saves the server nothing. Framework documentation and the annotation's own doc comment should say
this explicitly, so nobody enables `etag="true"` on a hot, expensive, uncached endpoint expecting
Event-Caching-level savings and is disappointed.

### 4.4 Automatic Last-Modified

Two sources, matching the two tiers:

- **Tier 1 (free):** when `cache="true"` and `lastModified="true"` (boolean form) are both set,
  the cache entry's write timestamp is exposed as `Last-Modified` for free. CacheBox object stores
  already record a `created` timestamp on every entry as standard metadata (used for eviction
  policies like `FIFO.cfc`, and retrievable via `getObjectMetadata()`) — this reuses that existing
  value rather than tracking a new one, the same way §4.2 reuses a hash computed once at write
  time rather than per-request.
- **Tier 2 (developer-supplied):** `lastModified="getProductModifiedDate"` names a private handler
  method, mirroring the existing `cacheFilter` closure-by-name convention
  (`HandlerService.cfc:824-851`), returning a `date`. Useful when the true "last changed" moment
  is a database column, not "whenever this happened to render":

  ```java
  function show( event, rc, prc )
      lastModified="getProductModifiedDate"
  {
      prc.product = productService.get( rc.id )
      event.setView( "products/show" )
  }

  private date function getProductModifiedDate( event, rc ){
      return productService.get( rc.id ).getModifiedDate()
  }
  ```

  This form necessarily runs before the main action body (it needs `rc.id` to know *which*
  product), so it participates in Tier 2's cost model even when combined with `cache="true"` —
  unlike the boolean form, a closure-supplied `Last-Modified` cannot be deferred to cache-write
  time because it depends on data the framework doesn't otherwise fetch.

### 4.5 Automatic Cache-Control

The simplest of the three — pure header assembly, no negotiation logic, no client round-trip
involved. If `cacheControl` is set, the framework attaches it verbatim. As a convenience default:
when `cache="true"` and `cacheTimeout` are set with no explicit `cacheControl`, default
`Cache-Control: private, max-age={cacheTimeout in seconds}` — "you already told me how long to
keep this server-side; telling the client the same number by default is a reasonable inference,
always overridable by setting `cacheControl` explicitly."

**Correctness caveat, not optional:** any response whose `Cache-Control`/`ETag` genuinely differs
per requester (auth state, locale, `Accept`-negotiated format) must either use `private` rather
than `public`, or set `Vary` accordingly. This spec does not attempt to infer that automatically —
`private` is the conservative default in the auto-derivation above precisely to avoid a framework
default ever causing a cross-user cache leak. `public` is opt-in only.

### 4.6 Annotation reference

| Annotation | Type | Default | Tier | Requires |
|---|---|---|---|---|
| `etag` | `boolean` | `false` | 1 if paired with `cache="true"`, else 2 | — |
| `etagWeak` | `boolean` | `false` | — | `etag="true"` |
| `lastModified` | `boolean` \| method name | `""` | 1 (boolean form + `cache`) or 2 (method-name form) | — |
| `cacheControl` | `string` | `""` (falls back to the §4.5 default when `cache`+`cacheTimeout` set) | — | — |

### 4.7 Settings block

**Tier 1 needs no settings block of its own.** Every one of its annotations
(`etag`/`etagWeak`/`lastModified`/`cacheControl`) is only ever read inside the
same `getEventCachingMetadata()` branch that already requires `cache="true"`
*and* the existing global `this.coldbox.eventCaching` switch
(`Settings.cfc:35`) to be `true` (`HandlerService.cfc:186-190`). A separate
`this.httpCaching.enabled` toggle was drafted and then removed during
implementation - it could never independently disable anything the existing
`eventCaching` switch didn't already disable, since Tier 1 has no code path
that runs without both. Per-handler, simply not setting the annotations is
already the finest-grained control there is.

A settings block **would** earn its place once Tier 2 (§4.3) is implemented,
since that tier runs independently of `cache="true"`/`eventCaching` entirely
and genuinely needs its own opt-in:

```java
this.httpCaching = {
    // Tier 2 only: enable an ETag automatically for every rendered GET/HEAD
    // response that doesn't otherwise set an etag annotation. Off by default -
    // this changes response bytes for every endpoint in the app.
    "autoETag"            : false,
    "defaultCacheControl" : "private, no-cache",
    "weakETagsByDefault"  : false
};
```

---

## 5. Route-level equivalent

Out of scope for this spec's implementation, but the seam is worth naming: a future route-level
cache-rules feature (route-struct `cache`/`cacheTimeout`/`cacheKey`, à la Nitro's `routeRules`)
would declare `etag`/`lastModified`/`cacheControl` as route-struct keys the same way `sse` and
`sseCallback` were added to `initRouteDefinition()` — and would need those keys declared as
`addRoute()` parameters too, per the drift class fixed in `Router.cfc` (`ai`/`mcp`/`sse` all hit
this same footgun; see the `getRouteDefinitionKeys()` guard test added specifically to catch it
happening again).

---

## 6. Interaction with `RestHandler`

The same integration hazard class the SSE spec found (`docs/specs/sse-streaming.md §6`) applies
here, for the same underlying reason: `RestHandler.aroundHandler` (`RestHandler.cfc:40`)
unconditionally calls `event.renderData(...)` at `:142-150` whenever the action set no view, no
render data, and returned nothing — which describes a 304 short-circuit just as well as it
describes a stream.

A `304` must happen **before** `aroundHandler` reaches that render step, not through the
`Response` object's buffered headers (§3.2), since those are only flushed *after* the render call.
The pattern:

```java
function show( event, rc, prc ){
    prc.product = productService.get( rc.id )
    if ( event.etag( prc.product.getHash() ) ) {
        return   // noExecution() + 304 already set — aroundHandler must not marshal a body
    }
    prc.response.setData( prc.product )
}
```

`event.etag()`/`event.lastModified()` already call `noExecution()` (§3.1), and
`RestHandler.aroundHandler` already has an `isSSE()`-style guard point (added by the SSE work,
`RestHandler.cfc` immediately after the response timer) that is the natural place to add a
parallel check. `isNoExecution` today is only a `property` (`RequestContext.cfc:38`) — the
accessor-generated getter is `getIsNoExecution()`, not a bare boolean predicate — so this spec
needs to **add** a small `isNoExecution()` method (mirroring `isSSE()`'s own existing shape)
rather than reuse something that already exists in that form:

```java
// RequestContext.cfc — new
boolean function isNoExecution(){
    return variables.isNoExecution;
}
```

```java
// RestHandler.cfc — end timer
arguments.prc.response.setResponseTime( getTickCount() - stime )

// A 304 (or an SSE stream) has already committed the response - no marshalling.
if ( arguments.event.isSSE() || arguments.event.isNoExecution() ) {
    return
}
```

---

## 7. Examples

### 7.1 Manual ETag, plain handler

```java
function show( event, rc, prc ){
    prc.product = productService.get( rc.id )
    if ( event.etag( prc.product.getHash() ) ) {
        return
    }
    event.setView( "products/show" )
}
```

### 7.2 Tier 1 — Event Caching + automatic ETag, for free

```java
function index( event, rc, prc )
    cache="true"
    cacheTimeout="300"
    etag="true"
{
    prc.products = productService.list()
    event.setView( "products/index" )
}
```

First request: cache miss, handler runs, body hashed once at write time, `ETag` sent.
Every subsequent request within the 300s window: cache hit, hash comparison only — no handler
execution, no render, and (on a match) no body write either.

### 7.3 Tier 2 — automatic Last-Modified via closure, no Event Caching

```java
function show( event, rc, prc )
    lastModified="getArticleModifiedDate"
{
    prc.article = articleService.get( rc.id )
    event.setView( "articles/show" )
}

private date function getArticleModifiedDate( event, rc ){
    return articleService.get( rc.id ).getModifiedDate()
}
```

### 7.4 REST resource with conditional GET

```java
component extends="coldbox.system.RestHandler" {

    function show( event, rc, prc ){
        prc.order = orderService.get( rc.id )
        if ( event.etag( prc.order.getVersion() ) ) {
            return
        }
        prc.response.setData( prc.order )
    }

}
```

### 7.5 App-wide Tier 2 opt-in

```java
// config/Coldbox.cfc
this.httpCaching = {
    "enabled"  : true,
    "autoETag" : true   // every rendered GET/HEAD response gets a computed ETag,
                         // no per-handler annotation required
};
```

---

## 8. Implementation notes

### Files touched (anticipated)

| File | Change |
|---|---|
| `system/web/context/RequestContext.cfc` | Add `etag()`, `lastModified()`, `cacheControl()` |
| `system/web/context/Response.cfc` | Add `withETag()`, `withCacheControl()` |
| `system/web/services/HandlerService.cfc` | Extend `getNewMDEntry()` defaults (`:764-776`) and `getEventCachingMetadata()` (`:801-811`) with the new annotations |
| `system/Bootstrap.cfc` | Extend the cache-write branch (`:340-378`) to compute+store the hash/timestamp when opted in; extend the cache-hit branch (`:245-289`) to check `If-None-Match`/`If-Modified-Since` before replay |
| `system/web/services/InterceptorService.cfc` | (If the interception-point approach is chosen for Tier 2) add `preResponseWrite` to the ENUM |
| `system/web/config/Settings.cfc` | Add `this.httpCaching` defaults block - **Tier 2 only**, see §4.7 |
| `system/web/config/ApplicationLoader.cfc` | Add `parseHTTPCaching()` to the parser chain - **Tier 2 only**, see §4.7 |
| `system/RestHandler.cfc` | Extend the existing `isSSE()` guard clause in `aroundHandler` to also check a new `isNoExecution()` predicate |
| `system/web/context/RequestContext.cfc` (guard addition) | Add `isNoExecution()` — `isNoExecution` is currently only a `property`, with no bare boolean-predicate accessor |

### Safe-methods guard

Both tiers, and the manual primitives, must refuse to apply to unsafe HTTP methods. A `304` (or
any cache-control guidance) on a `POST`/`PUT`/`PATCH`/`DELETE` is a specification violation and a
correctness hazard. `etag()`/`lastModified()` should check `event.getHTTPMethod()` (or equivalent)
internally and no-op (never short-circuit) on unsafe methods, regardless of annotation state —
this is a hard rule, not a configurable default.

---

## 9. Testing strategy

Following the pattern established for SSE (`tests/specs/web/context/RequestContextSSETest.cfc`
et al.), but with **no BoxLang gate** — this feature is pure HTTP header logic with no runtime
dependency, so specs run on every engine in the matrix.

- **`RequestContextHTTPCachingTest.cfc`** — `etag()`/`lastModified()`/`cacheControl()` against a
  mocked request context, covering: match → 304 + `noExecution()`; no-match → header set, request
  proceeds; weak vs strong tag formatting; absent conditional header behaves as no-match; unsafe
  HTTP methods never short-circuit.
- **Bootstrap-level integration test** — a `cache="true" etag="true"` handler, asserting: first
  request executes and stores a hash; second identical request (no `If-None-Match`) still replays
  the body but now carries `ETag`; third request with a matching `If-None-Match` gets a `304` with
  an empty body and the handler does not re-execute (assert via a call-count spy on the handler,
  matching the existing Event Caching test suite's approach).
- **`RestHandlerTest.cfc`** — extend to cover the `isNoExecution()` guard in `aroundHandler`,
  mirroring the existing `isSSE()` coverage.

---

## 10. Open questions

- **Interception point vs. inline `Bootstrap.cfc` check for Tier 2** (§4.3) — leaning inline, for
  consistency with how Event Caching itself is implemented, but a new `preResponseWrite` point
  would be more consistent with how *this session's* SSE work extended the ENUM. Worth deciding
  before implementation, not during it.
- **Hash algorithm for auto-ETag** — `MD5` is fast and collision-irrelevant for cache validation
  (not a security context), but should this be configurable (`this.httpCaching.hashAlgorithm`) for
  shops with a compliance policy against MD5 anywhere in the codebase, even non-cryptographic
  uses?
- **`cacheControl` as a struct vs. raw string annotation** — §4.1's table declares it as a raw
  string for simplicity of annotation syntax (CFML function annotations are string-valued). A
  friendlier `cachePublic`/`cacheMaxAge`/`cacheSWR` multi-annotation alternative was considered
  and rejected for the *annotation* surface (too many new keys) but might still be worth offering
  on the `RequestContext.cacheControl()`/`Response.withCacheControl()` *method* surface, where a
  struct argument is natural — the spec's method signatures in §3 already do this.
- **Does `autoETag=true` (global Tier 2) apply to `renderData()`/JSON responses, or only
  view-rendered HTML?** Leaning "both — anything with a final response body," but JSON responses
  from REST resources may already carry their own `Response`-level caching guidance (§7.4) that
  should take precedence over a blanket global default.
