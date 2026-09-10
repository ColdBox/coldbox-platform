# Changelog

All notable changes to this project will be documented here: <https://coldbox.ortusbooks.com/intro/release-history> and summarized in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

* * *

## [Unreleased]

### Added

- `route( "/gateways" ).toAiGateway()`: a routing DSL terminator exposing a BoxLang AI Gateway over
  HTTP, alongside `toAi()` and `toMCP()`. Registers the sub-route family a gateway surface needs:
  `GET/POST {pattern}[/:gateway]/events` (the platform's URL-verification handshake and its inbound
  events, on one URL because that is what a platform is given),
  `GET {pattern}/interactions/:requestID` and `POST {pattern}/interactions/:requestID/decisions` for
  human-in-the-loop approvals, and `GET {pattern}/info`. Pin a mount to one gateway with
  `toAiGateway( "slack" )`, or leave the name out and one mount serves every gateway registered in
  `aiGatewayRegistry()`. Pass a `session` (a WireBox ID or a live `GatewaySession`) and every inbound
  message is dispatched as an agent turn and acked `202` immediately, without waiting on the turn:
  a platform webhook times out in seconds while an agent turn does not. Without one, inbound events
  are verified and parsed only. BoxLang only, and requires the `bxai` module. ([bx-ai#286](https://github.com/ortus-boxlang/bx-ai/pull/286))

### Fixed

- A route `response` closure that rendered the response itself (`event.renderData(...)`) had its
  status code and content type flattened back onto the route's static `statusCode` by the router's
  own `renderData()` call. Render data set during the closure is now left alone, so a closure can
  answer with a per-request status. Render data an interceptor set before the route ran is
  unaffected.

- `BoxLangProvider` did not convert CacheBox's minute-based timeouts before handing them to BoxLang's
  cache, which reads a bare number as seconds, so every timeout expired sixty times too soon. A region
  moved from `CacheBoxProvider` to `BoxLangProvider` kept a 10 minute object for 10 seconds.
  `LuceeProvider` and `CFProvider` already convert.
- [COLDBOX-1434](https://ortussolutions.atlassian.net/browse/COLDBOX-1434): `ScheduledTask` combining
  `withNoOverlaps()` with a daily start time (`between()`/`startOnTime()`) snapshotted `spacedDelay`
  from `period` before the start-time alignment converted `period`/`timeUnit` to seconds, so the
  original unit's value (e.g. `1` for "1 minute") was scheduled using the converted `timeUnit`
  ("seconds") instead. A `1` minute task with `withNoOverlaps()` and an aligned start time re-fired
  every second instead of every 60 seconds.

## [8.1.0] - 2026-04-14

- <https://coldbox.ortusbooks.com/readme/release-history/whats-new-with-8.1.0>

## [8.0.5] - 2025-11-07

### Fixed

- ColdBoxProxy typo on getting page context length

## [8.0.4] - 2025-11-06

### Fixed

- add dependency install so dependencies can be built correctly

## [8.0.3] - 2025-11-05

### Fixed

- Left extra debugging info in the router.

## [8.0.2] - 2025-11-05

### Fixed

- Router not being detected in `boxlang` and `modern` layouts

## [8.0.1] - 2025-10-28

### Fixed

- Update bx-coldbox location as it was pointing to the wrong place.

## [8.0.0] - 2025-10-10

- <https://coldbox.ortusbooks.com/readme/release-history/whats-new-with-8.0.0>
- <https://coldbox.ortusbooks.com/readme/upgrading-to-coldbox-8>

[unreleased]: https://github.com/ColdBox/coldbox-platform/compare/v8.1.0...HEAD
[8.1.0]: https://github.com/ColdBox/coldbox-platform/compare/v8.0.5...v8.1.0
[8.0.5]: https://github.com/ColdBox/coldbox-platform/compare/v8.0.4...v8.0.5
[8.0.4]: https://github.com/ColdBox/coldbox-platform/compare/v8.0.3...v8.0.4
[8.0.3]: https://github.com/ColdBox/coldbox-platform/compare/v8.0.2...v8.0.3
[8.0.2]: https://github.com/ColdBox/coldbox-platform/compare/v8.0.1...v8.0.2
[8.0.1]: https://github.com/ColdBox/coldbox-platform/compare/v8.0.0...v8.0.1
[8.0.0]: https://github.com/ColdBox/coldbox-platform/compare/2782f650918c6a2399f48a8ceb8b749177f47beb...v8.0.0
