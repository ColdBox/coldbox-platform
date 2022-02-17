# Changelog

All notable changes to this project will be documented here: https://coldbox.ortusbooks.com/intro/release-history and summarized in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

----

## [6.6.1] => 2022-FEB-17

### Coldbox HMVC Core

#### Bug

* [COLDBOX-1093](https://ortussolutions.atlassian.net/browse/COLDBOX-1093) Remove debug writedumps left over from previous testing
* [COLDBOX-1085](https://ortussolutions.atlassian.net/browse/COLDBOX-1085) Fix instance of bad route merging the routes but loosing the handler

#### Improvement

* [COLDBOX-1095](https://ortussolutions.atlassian.net/browse/COLDBOX-1095) Update Response Pagination Properties for Case-Sensitive Engines
* [COLDBOX-1091](https://ortussolutions.atlassian.net/browse/COLDBOX-1091) default status code to 302 in the internal relocate\(\) just like CFML does instead of 0 and eliminate source
* [COLDBOX-1089](https://ortussolutions.atlassian.net/browse/COLDBOX-1089) Update the internal cfml engine checker to have more engine based feature checkers
* [COLDBOX-1088](https://ortussolutions.atlassian.net/browse/COLDBOX-1088) Switch isInstance check on renderdata in controller to secondary of $renderdata check to optimize speed


----

## [6.6.0] => 2022-JAN-31

### ColdBox HMVC Core

#### Bug

* [COLDBOX-1072](https://ortussolutions.atlassian.net/browse/COLDBOX-1072) Non config apps fails since the core Settings.cfc had the configure() method removed
* [COLDBOX-1069](https://ortussolutions.atlassian.net/browse/COLDBOX-1069) Framework Initialization Fails in @be on AutoWire of App Scheduler
* [COLDBOX-1066](https://ortussolutions.atlassian.net/browse/COLDBOX-1066) Scheduled tasks not accessing application scope on Adobe Engines
* [COLDBOX-1063](https://ortussolutions.atlassian.net/browse/COLDBOX-1063) ColdBox schedulers starting before the application is ready to serve requests
* [COLDBOX-1062](https://ortussolutions.atlassian.net/browse/COLDBOX-1062) Scheduler service not registering schedulers with the appropriate name
* [COLDBOX-1051](https://ortussolutions.atlassian.net/browse/COLDBOX-1051) scheduler names can only be used once - executor needs to be removed
* [COLDBOX-1036](https://ortussolutions.atlassian.net/browse/COLDBOX-1036) Scheduled tasks fail after upgrading to coldbox 6.5. Downgrading to 6.4.0 works.
* [COLDBOX-1027](https://ortussolutions.atlassian.net/browse/COLDBOX-1027) actions for a specific pattern cannot point to different handlers

#### Improvement

* [COLDBOX-1074](https://ortussolutions.atlassian.net/browse/COLDBOX-1074) Improvements to module loading/activation log messages
* [COLDBOX-1071](https://ortussolutions.atlassian.net/browse/COLDBOX-1071) Make unloadAll() in ModuleService more resilient by verifying loaded modules exist
* [COLDBOX-1061](https://ortussolutions.atlassian.net/browse/COLDBOX-1061) Change default template cache from concurrentSoftReference to ConcurrentReference to avoid auto cleanups
* [COLDBOX-1056](https://ortussolutions.atlassian.net/browse/COLDBOX-1056) Default route names to pattern when using route()
* [COLDBOX-1050](https://ortussolutions.atlassian.net/browse/COLDBOX-1050) New router method: `apiResources()` to allow you to define resources without the new and edit actions
* [COLDBOX-1049](https://ortussolutions.atlassian.net/browse/COLDBOX-1049) Update elixirPath to allow for many permutations of filenames and arguments to avoid cache collisions
* [COLDBOX-1048](https://ortussolutions.atlassian.net/browse/COLDBOX-1048) Ability for the response `setPagination()` to use any incoming argument for storage
* [COLDBOX-1037](https://ortussolutions.atlassian.net/browse/COLDBOX-1037) Move `onRequestCapture` after default event capture to allow for consistency on the capture
* [COLDBOX-980](https://ortussolutions.atlassian.net/browse/COLDBOX-980) Deprecate declaration of multiple resources on a single `resources()` call
* [COLDBOX-676](https://ortussolutions.atlassian.net/browse/COLDBOX-676) Improve routing DSL to allow for different HTTP verbs on the the same route to point to different events or actions

#### New Feature

* [COLDBOX-1082](https://ortussolutions.atlassian.net/browse/COLDBOX-1082) Announce `onException` interception points for async interceptors
* [COLDBOX-1080](https://ortussolutions.atlassian.net/browse/COLDBOX-1080) experimental web mapping support to allow for modern app templates with assets outside of the webroot
* [COLDBOX-1076](https://ortussolutions.atlassian.net/browse/COLDBOX-1076) Ability to pass in the domain to test executions in via integration testing
* [COLDBOX-1073](https://ortussolutions.atlassian.net/browse/COLDBOX-1073) Enable automated full null support via github actions
* [COLDBOX-1065](https://ortussolutions.atlassian.net/browse/COLDBOX-1065) ScheduledTask new `getMemento`() to get the state of the task
* [COLDBOX-1064](https://ortussolutions.atlassian.net/browse/COLDBOX-1064) Schedulers can now get the current thread and thread name: `getCurrentThread(), getThreadName()` as private helpers
* [COLDBOX-1033](https://ortussolutions.atlassian.net/browse/COLDBOX-1033) New controller method: `getUserSessionIdentifier`() which gives you the unique request tracking identifier according to our algorithms
* [COLDBOX-1032](https://ortussolutions.atlassian.net/browse/COLDBOX-1032) New coldbox setting `identifierProvider` which can be a closure/udf/lambda that provides a unique tracking identifier for user requests

----

### CacheBox

#### Bug

* [CACHEBOX-76](https://ortussolutions.atlassian.net/browse/CACHEBOX-76) Fixed method return value + SQL compatibility on jdbc metadata indexer thanks to @homestar9
* [CACHEBOX-75](https://ortussolutions.atlassian.net/browse/CACHEBOX-75) reap operation was not ignoring 0 values for last access timeouts
* [CACHEBOX-74](https://ortussolutions.atlassian.net/browse/CACHEBOX-74) Typo in queryExecute Attribute "datasource" in the JDBCStore.cfc

#### Improvement

* [CACHEBOX-73](https://ortussolutions.atlassian.net/browse/CACHEBOX-73) Replace IIF and urlEncodedFormat on cache content reports
* [CACHEBOX-79](https://ortussolutions.atlassian.net/browse/CACHEBOX-79) Lower logging verbosity of cache reaping from info to debug messages

----

### WireBox

#### Bug

* [WIREBOX-124](https://ortussolutions.atlassian.net/browse/WIREBOX-124) Killing `IInjector` interface usages due to many issues across cfml engines, leaving them for docs only
* [WIREBOX-118](https://ortussolutions.atlassian.net/browse/WIREBOX-118) Never override an existing variables key with virtual inheritance

#### Improvement

* [WIREBOX-120](https://ortussolutions.atlassian.net/browse/WIREBOX-120) DSLs process method now receives the caller `targetID` alongside the `targetObject` and the `target` definition

#### New Feature

* [WIREBOX-122](https://ortussolutions.atlassian.net/browse/WIREBOX-122) New wirebox DSL to inject the target's metadata that's cached in the target's binder: `wirebox:objectMetadata`
* [WIREBOX-121](https://ortussolutions.atlassian.net/browse/WIREBOX-121) New WireBoxDSL: `wirebox:targetID` to give you back the target ID used when injecting the object
* [WIREBOX-119](https://ortussolutions.atlassian.net/browse/WIREBOX-119) Missing `coldbox:schedulerService` DSL
* [WIREBOX-117](https://ortussolutions.atlassian.net/browse/WIREBOX-117) HDI - Ability for injectors to have a collection of child injectors to delegate lookups to, basically Hierarchical DI

#### Task

* [WIREBOX-123](https://ortussolutions.atlassian.net/browse/WIREBOX-123) Removal of usage of Injector dsl interface due to so many issues with multiple engines
