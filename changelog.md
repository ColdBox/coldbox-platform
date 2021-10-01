# Changelog

All notable changes to this project will be documented here: https://coldbox.ortusbooks.com/intro/release-history and summarized in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

----

## [6.5.1] => 2021-JUL-12

### ColdBox HMVC Core

#### Bug

- [COLDBOX-1024](https://ortussolutions.atlassian.net/browse/COLDBOX-1024) Module helpers no longer injected/mixed into interceptors

#### Improvement

- [COLDBOX-1026](https://ortussolutions.atlassian.net/browse/COLDBOX-1026) Update BeanPopulator for Hibernate 5 detection in Lucee new extension
- [COLDBOX-1025](https://ortussolutions.atlassian.net/browse/COLDBOX-1025) Added back the finally block, just to make sure cleanup are done in bootstrap reinits

----

## [6.5.0] => 2021-JUL-09

### ColdBox HMVC Core

#### Bugs

- COLDBOX-1021 fix lastBusinessDay tests to reflect if the now is the actual last business day of the month
- COLDBOX-1020 ColdBox does not allow for non-existent client cookies when using Flash RAM
- COLDBOX-1019 ACF 2021 introduced getTimezone() so we need to be specific when getting timezones in the scheduler or else it fails
- COLDBOX-1016 CF-2018 stats.lastResult is null when task->call have runEvent("xxxx")
- COLDBOX-1015 Element cleaner not matching on query strings due to misordering of map keys. Use a TreepMap to normalize ordering so event caching and view caching cleanups can ocur.
- COLDBOX-1014 response object cached response was never used, rely on the master bootstrap ColdBox cache response header
- COLDBOX-1013 RendererEncapsulator overwrites view()-Method from FrameworkSupertype
- COLDBOX-1010 this.nullSupport = true breaks coldbox
- COLDBOX-1008 ScheduleTask listeners are only testing for isClosure() and lambdas return false, so do an or check for isCustomFunction() to support lambdas
- COLDBOX-1007 scheduled task doesn't listen to when() in Scheduler.cfc
- COLDBOX-1004 Custom matchers debug() function not found since it's injected in isolation
- COLDBOX-1003 Scheduler service DI constructor argument was using the string literal instead of the string value for the scheduler name
- COLDBOX-1002 added this scope to getTimezone() to address issue with ACF-2021 bif
- COLDBOX-1001 category not logged correctly in async loggers

#### Improvements

- COLDBOX-1023 Readjustments to fail fast and reloading procedures when there are exceptions and reiniting becomes impossible.
- COLDBOX-1018 Enable proxy to use the ColdBox app key defined in the bootstrap instead of hard coding it
- COLDBOX-1017 Delay loadApplicationHelpers() in interceptors so modules can contribute udf helpers and even core interceptors can load them.
- COLDBOX-1012 Move coldbox inited flag to after after aspects load, so we can make sure all modules are loaded before serving requests
- COLDBOX-1009 RESTHandler capture JWT TokenException to authentication failures

### CacheBox

#### Bugs

- CACHEBOX-68 BlackHoleStore never finishes reap() method

### LogBox

#### Improvements

- LOGBOX-63 Allow for dbappender to have default column maps instead of strict maps and allow for all methods to use the maps

#### New Features

- LOGBOX-64 Ability to add new appenders after config has been registered already