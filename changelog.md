# Changelog

All notable changes to this project will be documented here: <https://coldbox.ortusbooks.com/intro/release-history> and summarized in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

* * *

## [Unreleased]

### Fixed

- `COLDBOX-1456` `Bootstrap.onSessionStart()` ran the session start handler on a controller that was still loading during a reinit. It now skips the event until the controller is initiated.
- WireBox released a circular partner to other threads before the outer object finished wiring. A singleton, engine scope or CacheBox object built inside another build left the wiring set as soon as its own wiring ended, while holding a reference to the outer object. Keys now stay marked until the outermost build completes, tracked on the injector across all scopes.
- `COLDBOX-1455` WireBox singleton, engine (application, session, server) and CacheBox scopes handed objects to other threads before their dependencies were wired. A single wiring lock now makes other threads wait, while the wiring thread still resolves circular dependencies.

### Changed

- WireBox `CFScopes` scope renamed to `EngineScopes`

### Added

- `group()` now accepts a `meta` struct option that every route inside the group inherits. Nested groups merge outer-first and a route's own `meta()` values win on conflict. This lets a single group declare route metadata, for example the permissions consumed by security middleware.

### Fixed

- `BaseTestCase.execute()` (and the `get()`, `post()`, etc. helpers built on it) now runs route-scoped middleware registered with `Router.middleware()`, in the same order as the Bootstrap, so integration tests exercise the same request lifecycle as a real request.

## [8.2.0] - 2026-09-23

- <https://coldbox.ortusbooks.com/readme/release-history/whats-new-with-8.2.0>

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

[unreleased]: https://github.com/ColdBox/coldbox-platform/compare/v8.2.0...HEAD
[8.2.0]: https://github.com/ColdBox/coldbox-platform/compare/v8.1.0...v8.2.0
[8.1.0]: https://github.com/ColdBox/coldbox-platform/compare/v8.0.5...v8.1.0
[8.0.5]: https://github.com/ColdBox/coldbox-platform/compare/v8.0.4...v8.0.5
[8.0.4]: https://github.com/ColdBox/coldbox-platform/compare/v8.0.3...v8.0.4
[8.0.3]: https://github.com/ColdBox/coldbox-platform/compare/v8.0.2...v8.0.3
[8.0.2]: https://github.com/ColdBox/coldbox-platform/compare/v8.0.1...v8.0.2
[8.0.1]: https://github.com/ColdBox/coldbox-platform/compare/v8.0.0...v8.0.1
[8.0.0]: https://github.com/ColdBox/coldbox-platform/compare/2782f650918c6a2399f48a8ceb8b749177f47beb...v8.0.0
