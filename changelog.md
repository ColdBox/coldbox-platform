# Changelog

All notable changes to this project will be documented here: <https://coldbox.ortusbooks.com/intro/release-history> and summarized in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

* * *

## [Unreleased]

### Bug

- [COLDBOX-1274](https://ortussolutions.atlassian.net/browse/COLDBOX-1274) javacasting to long for new Java LocalDateTime instead of int, Adobe not doing type promotion
- [COLDBOX-1279](https://ortussolutions.atlassian.net/browse/COLDBOX-1279) Render encapsulator bleed of this scope by engines

### Improvement

- [COLDBOX-1273](https://ortussolutions.atlassian.net/browse/COLDBOX-1273) Removal of deprecated CFML functions in core
- [COLDBOX-1275](https://ortussolutions.atlassian.net/browse/COLDBOX-1275) Improved engine detection by the CFMLEngine feature class
- [COLDBOX-1278](https://ortussolutions.atlassian.net/browse/COLDBOX-1278) Remove unsafe evaluate function usage

## [6.9.0] - 2023-06-09

### Added

- [COLDBOX-1229](https://ortussolutions.atlassian.net/browse/COLDBOX-1229) Added debug argument to ScheduleExecutor and Scheduler when creating tasks for consistency
- [COLDBOX-1230](https://ortussolutions.atlassian.net/browse/COLDBOX-1230) Reorganized ScheduledTasks functions within the CFC into code groups and comments

### Improvements

- [COLDBOX-1226](https://ortussolutions.atlassian.net/browse/COLDBOX-1226) Scheduled Tasks Updates

### Fixed

- [COLDBOX-1145](https://ortussolutions.atlassian.net/browse/COLDBOX-1145) RestHandler OnError() Exception not checking for empty \`exception\` blocks which would cause another exception on development ONLY

## [6.8.2] - 2023-05-01

### Added

- Github actions for LTS Releases
- LTS Updates

### Bugs

- [COLDBOX-1219](https://ortussolutions.atlassian.net/browse/COLDBOX-1219) CFProvider ACF versions are Hard-Coded
- [WIREBOX-132](https://ortussolutions.atlassian.net/browse/WIREBOX-132) WireBox caches Singletons even if their autowired dependencies throw exceptions.

## [6.8.1] => 2022-AUG-11

### ColdBox HMVC Core

#### Bug

- [COLDBOX-1139](https://ortussolutions.atlassian.net/browse/COLDBOX-1139) make event caching cache keys lower cased to avoid case issues when clearing keys
- [COLDBOX-1138](https://ortussolutions.atlassian.net/browse/COLDBOX-1138) Event Cache Response Has Status Code of 0 or `null`

* * *

## [6.8.0] => 2022-JUL-23

### ColdBox HMVC Core

#### Bug

- [COLDBOX-1134](https://ortussolutions.atlassian.net/browse/COLDBOX-1134) Router closure responses not marshalling complex content to json
- [COLDBOX-1132](https://ortussolutions.atlassian.net/browse/COLDBOX-1132) New virtual app was always starting up the virtual coldbox app instead of checking if it was running already

#### Improvement

- [COLDBOX-1131](https://ortussolutions.atlassian.net/browse/COLDBOX-1131) Updated Missing Action Response Code to 404 instead of 405
- [COLDBOX-1127](https://ortussolutions.atlassian.net/browse/COLDBOX-1127) All core async proxies should send exceptions to the error log

#### New Feature

- [COLDBOX-1130](https://ortussolutions.atlassian.net/browse/COLDBOX-1130) New config/ColdBox.cfc global injections: webMapping, coldboxVersion
- [COLDBOX-1126](https://ortussolutions.atlassian.net/browse/COLDBOX-1126) Funnel all out and err logging on a ColdBox Scheduled Task to LogBox

#### Task

- [COLDBOX-1135](https://ortussolutions.atlassian.net/browse/COLDBOX-1135) Remove HandlerTestCase as it is no longer in usage.

* * *

## [6.7.0] => 2022-JUN-22

### ColdBox HMVC Core

#### Bug

- [COLDBOX-1114](https://ortussolutions.atlassian.net/browse/COLDBOX-1114) Persistance of variables failing due to null support
- [COLDBOX-1110](https://ortussolutions.atlassian.net/browse/COLDBOX-1110) Renderer is causing coldbox RestHandler to render convention view
- [COLDBOX-1109](https://ortussolutions.atlassian.net/browse/COLDBOX-1109) Exceptions in async interceptors are missing onException announcement
- [COLDBOX-1105](https://ortussolutions.atlassian.net/browse/COLDBOX-1105) Interception with `async` annotation causes InterceptorState Exception on Reinit
- [COLDBOX-1104](https://ortussolutions.atlassian.net/browse/COLDBOX-1104) A view not set exception is thrown when trying to execution handler ColdBox methods that are not concrete actions when they should be invalid events.
- [COLDBOX-1103](https://ortussolutions.atlassian.net/browse/COLDBOX-1103) Update getServerIP() so it avoids looking at the cgi scope as it can cause issues on ACF
- [COLDBOX-1100](https://ortussolutions.atlassian.net/browse/COLDBOX-1100) Event Caching Does Not Preserve HTTP Response Codes
- [COLDBOX-1099](https://ortussolutions.atlassian.net/browse/COLDBOX-1099) Regression on ColdBox v6.6.1 around usage of statusCode = 0 on relocates
- [COLDBOX-1098](https://ortussolutions.atlassian.net/browse/COLDBOX-1098) RequestService context creation not thread safe
- [COLDBOX-1097](https://ortussolutions.atlassian.net/browse/COLDBOX-1097) Missing scopes on isNull() checks
- [COLDBOX-1092](https://ortussolutions.atlassian.net/browse/COLDBOX-1092) RestHandler Try/Catches Break In Testbox When RunEvent() is Called
- [COLDBOX-1045](https://ortussolutions.atlassian.net/browse/COLDBOX-1045) Scheduled tasks have no default error handling
- [COLDBOX-1043](https://ortussolutions.atlassian.net/browse/COLDBOX-1043) Creating scheduled task with unrecognized timeUnit throws null pointer
- [COLDBOX-1042](https://ortussolutions.atlassian.net/browse/COLDBOX-1042) afterAnyTask() and task.after() don't run after failing task
- [COLDBOX-1040](https://ortussolutions.atlassian.net/browse/COLDBOX-1040) Error in onAnyTaskError() or after() tasks not handled and executor dies.
- [COLDBOX-966](https://ortussolutions.atlassian.net/browse/COLDBOX-966) Coldbox Renderer.RenderLayout() Overwrites Event's Current View

#### Improvement

- [COLDBOX-1124](https://ortussolutions.atlassian.net/browse/COLDBOX-1124) Convert mixer util to script and utilize only the necessary mixins by deprecating older mixins
- [COLDBOX-1116](https://ortussolutions.atlassian.net/browse/COLDBOX-1116) Enhance EntityNotFound Exception Messages for rest handlers
- [COLDBOX-1096](https://ortussolutions.atlassian.net/browse/COLDBOX-1096) SES is always disabled on RequestContext until RoutingService request capture : SES is the new default for ColdBox Apps
- [COLDBOX-1094](https://ortussolutions.atlassian.net/browse/COLDBOX-1094) coldbox 6.5 and 6.6 break ORM event handling in cborm
- [COLDBOX-1067](https://ortussolutions.atlassian.net/browse/COLDBOX-1067) Scheduled Tasks: Inject module context variables to module schedulers and inject global context into global scheduler
- [COLDBOX-1044](https://ortussolutions.atlassian.net/browse/COLDBOX-1044) Create singular aliases for timeunits

#### New Feature

- [COLDBOX-1123](https://ortussolutions.atlassian.net/browse/COLDBOX-1123) New xTask() method in the schedulers that will automatically disable the task but still register it. Great for debugging!
- [COLDBOX-1121](https://ortussolutions.atlassian.net/browse/COLDBOX-1121) Log schedule task failures to console so errors are not ignored
- [COLDBOX-1120](https://ortussolutions.atlassian.net/browse/COLDBOX-1120) Scheduler's onShutdown() callback now receives the boolean force and numeric timeout arguments
- [COLDBOX-1119](https://ortussolutions.atlassian.net/browse/COLDBOX-1119) The Scheduler's shutdown method now has two arguments: boolean force, numeric timeout
- [COLDBOX-1118](https://ortussolutions.atlassian.net/browse/COLDBOX-1118) All schedulers have a new property: shutdownTimeout which defaults to 30 that can be used to control how long to wait for tasks to gracefully complete when shutting down.
- [COLDBOX-1113](https://ortussolutions.atlassian.net/browse/COLDBOX-1113) New coldobx.system.testing.VirtualApp object that can startup,restart and shutdown Virtual Testing Applications
- [COLDBOX-1108](https://ortussolutions.atlassian.net/browse/COLDBOX-1108) Async interceptos can now discover their announced data without duplicating it via cfthread
- [COLDBOX-1107](https://ortussolutions.atlassian.net/browse/COLDBOX-1107) Interception Event pools are now using synchronized linked maps to provide concurrency
- [COLDBOX-1106](https://ortussolutions.atlassian.net/browse/COLDBOX-1106) New super type function "forAttribute" to help us serialize simple/complex data and encoded for usage in html attributes
- [COLDBOX-1101](https://ortussolutions.atlassian.net/browse/COLDBOX-1101) announce `onException` interception from RESTHandler, when exceptions are detected
- [COLDBOX-1053](https://ortussolutions.atlassian.net/browse/COLDBOX-1053) Async schedulers and executors can now have a graceful shutdown and await for task termination with a configurable timeout.
- [COLDBOX-1052](https://ortussolutions.atlassian.net/browse/COLDBOX-1052) Scheduled tasks add start and end date/times

#### Task

- [COLDBOX-1122](https://ortussolutions.atlassian.net/browse/COLDBOX-1122) lucee async tests where being skipped due to missing engine check
- [COLDBOX-1117](https://ortussolutions.atlassian.net/browse/COLDBOX-1117) Remove nextRun stat from scheduled task, it was never implemented

### CacheBox

#### Bug

- [CACHEBOX-66](https://ortussolutions.atlassian.net/browse/CACHEBOX-66) Cachebox concurrent store meta index not thread safe during reaping

#### Improvement

- [CACHEBOX-82](https://ortussolutions.atlassian.net/browse/CACHEBOX-82) Remove the usage of identity hash codes, they are no longer relevant and can cause contention under load

### LogBox

#### Improvement

- [LOGBOX-68](https://ortussolutions.atlassian.net/browse/LOGBOX-68) Remove the usage of identity hash codes, they are no longer relevant and can cause contention under load
- [LOGBOX-65](https://ortussolutions.atlassian.net/browse/LOGBOX-65) File Appender missing text "ExtraInfo: "

### WireBox

#### Bug

- [WIREBOX-126](https://ortussolutions.atlassian.net/browse/WIREBOX-126) Inherited Metadata Usage - Singleton attribute evaluated before Scopes

#### Improvement

- [WIREBOX-129](https://ortussolutions.atlassian.net/browse/WIREBOX-129) Massive refactor to improve object creation and injection wiring
- [WIREBOX-128](https://ortussolutions.atlassian.net/browse/WIREBOX-128) Injector now caches all object contains lookups to increase performance across hierarchy lookups
- [WIREBOX-127](https://ortussolutions.atlassian.net/browse/WIREBOX-127) Lazy load all constructs on the Injector to improve performance
- [WIREBOX-125](https://ortussolutions.atlassian.net/browse/WIREBOX-125) Remove the usage of identity hash codes, they are no longer relevant and can cause contention under load

* * *

## [6.6.1] => 2022-FEB-17

### Coldbox HMVC Core

#### Bug

- [COLDBOX-1093](https://ortussolutions.atlassian.net/browse/COLDBOX-1093) Remove debug writedumps left over from previous testing
- [COLDBOX-1085](https://ortussolutions.atlassian.net/browse/COLDBOX-1085) Fix instance of bad route merging the routes but loosing the handler

#### Improvement

- [COLDBOX-1095](https://ortussolutions.atlassian.net/browse/COLDBOX-1095) Update Response Pagination Properties for Case-Sensitive Engines
- [COLDBOX-1091](https://ortussolutions.atlassian.net/browse/COLDBOX-1091) default status code to 302 in the internal relocate() just like CFML does instead of 0 and eliminate source
- [COLDBOX-1089](https://ortussolutions.atlassian.net/browse/COLDBOX-1089) Update the internal cfml engine checker to have more engine based feature checkers
- [COLDBOX-1088](https://ortussolutions.atlassian.net/browse/COLDBOX-1088) Switch isInstance check on renderdata in controller to secondary of $renderdata check to optimize speed

### CacheBox

#### Bug

- [CACHEBOX-80](https://ortussolutions.atlassian.net/browse/CACHEBOX-80) Bug in JDBCMetadataIndexer sortedKeys() using non-existent variable `arguments.objectKey`

#### Improvement

- [CACHEBOX-81](https://ortussolutions.atlassian.net/browse/CACHEBOX-81) JDBCStore Dynamically generate queryExecute options + new config to always include DSN due to ACF issues

* * *

## [6.6.0] => 2022-JAN-31

### ColdBox HMVC Core

#### Bug

- [COLDBOX-1072](https://ortussolutions.atlassian.net/browse/COLDBOX-1072) Non config apps fails since the core Settings.cfc had the configure() method removed
- [COLDBOX-1069](https://ortussolutions.atlassian.net/browse/COLDBOX-1069) Framework Initialization Fails in @be on AutoWire of App Scheduler
- [COLDBOX-1066](https://ortussolutions.atlassian.net/browse/COLDBOX-1066) Scheduled tasks not accessing application scope on Adobe Engines
- [COLDBOX-1063](https://ortussolutions.atlassian.net/browse/COLDBOX-1063) ColdBox schedulers starting before the application is ready to serve requests
- [COLDBOX-1062](https://ortussolutions.atlassian.net/browse/COLDBOX-1062) Scheduler service not registering schedulers with the appropriate name
- [COLDBOX-1051](https://ortussolutions.atlassian.net/browse/COLDBOX-1051) scheduler names can only be used once - executor needs to be removed
- [COLDBOX-1036](https://ortussolutions.atlassian.net/browse/COLDBOX-1036) Scheduled tasks fail after upgrading to coldbox 6.5. Downgrading to 6.4.0 works.
- [COLDBOX-1027](https://ortussolutions.atlassian.net/browse/COLDBOX-1027) actions for a specific pattern cannot point to different handlers

#### Improvement

- [COLDBOX-1074](https://ortussolutions.atlassian.net/browse/COLDBOX-1074) Improvements to module loading/activation log messages
- [COLDBOX-1071](https://ortussolutions.atlassian.net/browse/COLDBOX-1071) Make unloadAll() in ModuleService more resilient by verifying loaded modules exist
- [COLDBOX-1061](https://ortussolutions.atlassian.net/browse/COLDBOX-1061) Change default template cache from concurrentSoftReference to ConcurrentReference to avoid auto cleanups
- [COLDBOX-1056](https://ortussolutions.atlassian.net/browse/COLDBOX-1056) Default route names to pattern when using route()
- [COLDBOX-1050](https://ortussolutions.atlassian.net/browse/COLDBOX-1050) New router method: `apiResources()` to allow you to define resources without the new and edit actions
- [COLDBOX-1049](https://ortussolutions.atlassian.net/browse/COLDBOX-1049) Update elixirPath to allow for many permutations of filenames and arguments to avoid cache collisions
- [COLDBOX-1048](https://ortussolutions.atlassian.net/browse/COLDBOX-1048) Ability for the response `setPagination()` to use any incoming argument for storage
- [COLDBOX-1037](https://ortussolutions.atlassian.net/browse/COLDBOX-1037) Move `onRequestCapture` after default event capture to allow for consistency on the capture
- [COLDBOX-980](https://ortussolutions.atlassian.net/browse/COLDBOX-980) Deprecate declaration of multiple resources on a single `resources()` call
- [COLDBOX-676](https://ortussolutions.atlassian.net/browse/COLDBOX-676) Improve routing DSL to allow for different HTTP verbs on the the same route to point to different events or actions

#### New Feature

- [COLDBOX-1082](https://ortussolutions.atlassian.net/browse/COLDBOX-1082) Announce `onException` interception points for async interceptors
- [COLDBOX-1080](https://ortussolutions.atlassian.net/browse/COLDBOX-1080) experimental web mapping support to allow for modern app templates with assets outside of the webroot
- [COLDBOX-1076](https://ortussolutions.atlassian.net/browse/COLDBOX-1076) Ability to pass in the domain to test executions in via integration testing
- [COLDBOX-1073](https://ortussolutions.atlassian.net/browse/COLDBOX-1073) Enable automated full null support via github actions
- [COLDBOX-1065](https://ortussolutions.atlassian.net/browse/COLDBOX-1065) ScheduledTask new `getMemento`() to get the state of the task
- [COLDBOX-1064](https://ortussolutions.atlassian.net/browse/COLDBOX-1064) Schedulers can now get the current thread and thread name: `getCurrentThread(), getThreadName()` as private helpers
- [COLDBOX-1033](https://ortussolutions.atlassian.net/browse/COLDBOX-1033) New controller method: `getUserSessionIdentifier`() which gives you the unique request tracking identifier according to our algorithms
- [COLDBOX-1032](https://ortussolutions.atlassian.net/browse/COLDBOX-1032) New coldbox setting `identifierProvider` which can be a closure/udf/lambda that provides a unique tracking identifier for user requests

* * *

### CacheBox

#### Bug

- [CACHEBOX-76](https://ortussolutions.atlassian.net/browse/CACHEBOX-76) Fixed method return value + SQL compatibility on jdbc metadata indexer thanks to @homestar9
- [CACHEBOX-75](https://ortussolutions.atlassian.net/browse/CACHEBOX-75) reap operation was not ignoring 0 values for last access timeouts
- [CACHEBOX-74](https://ortussolutions.atlassian.net/browse/CACHEBOX-74) Typo in queryExecute Attribute "datasource" in the JDBCStore.cfc

#### Improvement

- [CACHEBOX-73](https://ortussolutions.atlassian.net/browse/CACHEBOX-73) Replace IIF and urlEncodedFormat on cache content reports
- [CACHEBOX-79](https://ortussolutions.atlassian.net/browse/CACHEBOX-79) Lower logging verbosity of cache reaping from info to debug messages

* * *

### WireBox

#### Bug

- [WIREBOX-124](https://ortussolutions.atlassian.net/browse/WIREBOX-124) Killing `IInjector` interface usages due to many issues across cfml engines, leaving them for docs only
- [WIREBOX-118](https://ortussolutions.atlassian.net/browse/WIREBOX-118) Never override an existing variables key with virtual inheritance

#### Improvement

- [WIREBOX-120](https://ortussolutions.atlassian.net/browse/WIREBOX-120) DSLs process method now receives the caller `targetID` alongside the `targetObject` and the `target` definition

#### New Feature

- [WIREBOX-122](https://ortussolutions.atlassian.net/browse/WIREBOX-122) New wirebox DSL to inject the target's metadata that's cached in the target's binder: `wirebox:objectMetadata`
- [WIREBOX-121](https://ortussolutions.atlassian.net/browse/WIREBOX-121) New WireBoxDSL: `wirebox:targetID` to give you back the target ID used when injecting the object
- [WIREBOX-119](https://ortussolutions.atlassian.net/browse/WIREBOX-119) Missing `coldbox:schedulerService` DSL
- [WIREBOX-117](https://ortussolutions.atlassian.net/browse/WIREBOX-117) HDI - Ability for injectors to have a collection of child injectors to delegate lookups to, basically Hierarchical DI

#### Task

- [WIREBOX-123](https://ortussolutions.atlassian.net/browse/WIREBOX-123) Removal of usage of Injector dsl interface due to so many issues with multiple engines

[Unreleased]: https://github.com/ColdBox/coldbox-platform/compare/v6.9.0...HEAD

[6.9.0]: https://github.com/ColdBox/coldbox-platform/compare/v6.8.2...v6.9.0

[6.8.2]: https://github.com/ColdBox/coldbox-platform/compare/e0aa96ff743adb860834194715729198ecb051bd...v6.8.2
