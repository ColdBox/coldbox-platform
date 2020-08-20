# Changelog

All notable changes to this project will be documented here: https://coldbox.ortusbooks.com/intro/release-history and summarized in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

----

## [6.0.0] => 2020-AUG-20

### ColdBox HMVC Core

#### Bugs

[COLDBOX-48] - CacheBox creates multiple reap threads if the initial one take longer to complete than the reap frequency
[COLDBOX-339] - Error in AbstractFlashScope: key does't exists due to race conditions
[COLDBOX-822] - InvalidEvent is not working when set to a module event
[COLDBOX-829] - Stopgap for Lucee bug losing sessionCluster application setting
[COLDBOX-832] - toResponse() silently fails on incorrect data types
[COLDBOX-837] - Unable to manually call invalid event method without producing error
[COLDBOX-839] - Router method and argument name discrepancy
[COLDBOX-845] - Capture request before announcing onRequestCapture
[COLDBOX-850] - XML Converter Updated invoke() to correctly call method by name
[COLDBOX-857] - ElixirPath does not take in account of module root
[COLDBOX-861] - Self-autowire fails for applications with context root configured in ColdBox Proxy
[COLDBOX-862] - when passing custom cfml executors to futures it blows up as the native executor is not set
[COLDBOX-873] - NullPointerException in ScheduledExecutor (Lucee 5.3.4.80)
[COLDBOX-875] - PopulateFromQuery : Gracefully handle out of index rownumber in populateFromQuery #450
[COLDBOX-878] - ColdBox 6 blows up if models directory doesn't exist
[COLDBOX-879] - Reinit-Password-Check does not use the new "reinitKey"-Setting
[COLDBOX-880] - ViewHelpers not working in CB-6 RC
[COLDBOX-885] - Pagination not showing from rest response
[COLDBOX-889] - RendererEncapsulator passes view-variables to "next" rendered view
[COLDBOX-891] - Whoops breaking on some exceptions
[COLDBOX-897] - Template cache eventSnippets don't match module events or event suffixes
[COLDBOX-899] - queryString argument ignored when using event in `BaseTestCase#execute`
[COLDBOX-903] - Renderer.ViewNotSetException when renderLayout used in request
[COLDBOX-911] - Garbled text in Whoops error screen - utf8 encoding

#### New Features

[COLDBOX-268] - Async Workers
[COLDBOX-749] - Performance: make renderer a singleton
[COLDBOX-848] - Improve the bug reporting template for development based on whoops
[COLDBOX-849] - Incorporate Response and RestHandler into core
[COLDBOX-851] - All ColdBox apps get a `coldbox-tasks` scheduler executor for internal ColdBox services and scheduled tasks
[COLDBOX-852] - Updated the default ColdBox config appender to be to console instead of the dummy one
[COLDBOX-853] - ColdBox controller gets a reference to the AsyncManager and registers a new `AsyncManager@coldbox` wirebox mapping
[COLDBOX-855] - Allow for the application to declare it's executors via the new `executors` configuration element
[COLDBOX-856] - Allow for a module to declare it's executors via the new `executors` configuration element
[COLDBOX-858] - Introduction of async/parallel programming via cbPromises
[COLDBOX-859] - ability to do async scheduled tasks with new async cbpromises
[COLDBOX-860] - Convert proxy to script and optimize it
[COLDBOX-863] - Add setting to define reinit key vs. hard-coded fwreinit: reinitKey
[COLDBOX-864] - jsonPayloadToRC now defaults to true
[COLDBOX-865] - autoMapModels defaults to true now
[COLDBOX-868] - RequestContext Add urlMatches to match current urls
[COLDBOX-869] - Response, SuperType => New functional if construct when( boolean, success, failure )
[COLDBOX-871] - Removed fwsetting argument from getSetting() in favor of a new function: getColdBoxSetting()
[COLDBOX-874] - BaseTestCase new method getHandlerResults() to easy get the handler results, also injected into test request contexts
[COLDBOX-876] - New dsl coldbox:coldboxSettings alias to coldbox:fwSettings
[COLDBOX-877] - New dsl coldbox:asyncManager to get the async manager
[COLDBOX-887] - Elixir manifest support for module and app roots via discovery
[COLDBOX-894] - New listen() super type and interceptor service method to register one-off closures on specific interception points
[COLDBOX-905] - The buildLink( to ) argument can now be a struct to support named routes : { name, params }
[COLDBOX-906] - Move queryString as the second argument for buildLink() so you can use it with psoitional params
[COLDBOX-907] - New context method: getCurrentRouteRecord() which gives you the full routed route record
[COLDBOX-908] - New context method: getCurrentRouteMeta() which gives you the routed route metadata if any
[COLDBOX-909] - New router method: meta() that you can use to store metadata for a specific route
[COLDBOX-910] - Every route record can now store a struct of metadata alongside of it using the `meta` key
[COLDBOX-912] - Allow toRedirect() to accept a closure which receives the matched route, you can process and then return the redirect location
[COLDBOX-915] - New onColdBoxShutdown interception point fired when the entire framework app is going down

#### Tasks

[COLDBOX-866] - onInvalidEvent is now removed in favor of invalidEventHandler, this was deprecated in 5.x
[COLDBOX-867] - Removed interceptors.SES as it was deprecated in 5
[COLDBOX-870] - setnextEvent removed as it was deprecated in 5
[COLDBOX-872] - getModel() is now fully deprecated and removed in fvor of getInstance()
[COLDBOX-886] - elixir version 2 support removed
[COLDBOX-900] - `request` and associated integration test methods are not in the official docs

#### Improvements

[COLDBOX-830] - Update cachebox flash ram to standardize on unique key discovery
[COLDBOX-833] - Improvements to threading for interceptors and logging to avoid dumb Adobe duplicates
[COLDBOX-841] - Change announceInterception() and processState() to a single method name like: announce()
[COLDBOX-846] - Use relocate and setNextEvent status codes in getStatusCode for testing integration
[COLDBOX-882] - Deprecate interceptData in favor of just data
[COLDBOX-892] - Please add an easily accessible "fwreinit" button to whoops...
[COLDBOX-895] - migrating usage of cgi.http_host to cgi.server_name due to inconsistencies with proxy requests that affects caching and many other features
[COLDBOX-904] - Interceptor Buffer Methods Removed
[COLDBOX-916] - Better module registration/activation logging to identify location and version

----

### WireBox

#### Bugs

[WIREBOX-90] - Fix constructor injection with virtual inheritance

#### New Features

[WIREBOX-91] - Injector's get a reference to an asyncManager and a task scheduler whether they are in ColdBox or non-ColdBox mode
[WIREBOX-92] - New `executors` dsl so you can easily inject executors ANYWEHRE
[WIREBOX-97] - New dsl coldbox:coldboxSetting:{setting} alias to coldbox:fwSetting:{setting}

#### Improvements

[WIREBOX-88] - Improve WireBox error on Adobe CF
[WIREBOX-93] - Rename WireBox provider get() to $get() to avoid conflicts with provided classes
[WIREBOX-94] - getInstance() now accepts either dsl or name via the first argument and initArguments as second argument

----

### CacheBox

#### Bugs

[CACHEBOX-59] - Announced Events in the set() of the cacheBoxProvider
[CACHEBOX-63] - cfthread-20506;variable [ATTRIBUES] doesn't exist;lucee.runtime.exp.ExpressionException: variable [ATTRIBUES] doesn't exist

#### New Features

[CACHEBOX-24] - CacheBox reaper : migrate to a scheduled task via cbPromises
[CACHEBOX-60] - CacheFactory gets a reference to an asyncManager and a task scheduler whether they are in ColdBox or non-ColdBox mode

#### Improvements

[CACHEBOX-64] - Migrations to script and more fluent programming

----

### LogBox

#### Bugs

[LOGBOX-35] - FileAppender: if logging happens in a thread, queue never gets processed and, potentially, you run out of heap space
[LOGBOX-38] - Rotate property is defined but never used
[LOGBOX-45] - Work around for adobe bug CF-4204874 where closures are holding on to tak contexts
[LOGBOX-50] - Rolling file appender inserting tabs on first line

#### New Features

[LOGBOX-5] - Allow config path as string in LogBox init (standalone)
[LOGBOX-11] - Allow standard appenders to be configured by name (instead of full path)
[LOGBOX-36] - Added an `err()` to abstract appenders for reporting to the error streams
[LOGBOX-42] - All appenders get a reference to the running LogBox instance
[LOGBOX-43] - LogBox has a scheduler executor and the asyncmanager attached to it for standalone and ColdBox mode.
[LOGBOX-44] - Rolling appender now uses the new async schedulers to stream data to files
[LOGBOX-46] - Update ConsoleAppender to use TaskScheduler
[LOGBOX-47] - AbstractAppender log listener and queueing facilities are now available for all appenders
[LOGBOX-48] - DB Appender now uses a queueing approach to sending log messages
[LOGBOX-49] - Rolling File Appender now uses the async scheduler for log rotation checks

#### Improvements

[LOGBOX-37] - Improvements to threading for logging to avoid dumb Adobe duplicates
[LOGBOX-41] - refactoring of internal utility closures to udfs to avoid ACF memory leaks: CF-4204874
[LOGBOX-51] - Migrations to script and more fluent programming