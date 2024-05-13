# Changelog

All notable changes to this project will be documented here: <https://coldbox.ortusbooks.com/intro/release-history> and summarized in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

* * *

## [Unreleased]

### New Feature

- Prettier SQL printing in `StringUtil.prettySQL()`
- [COLDBOX-1270](https://ortussolutions.atlassian.net/browse/COLDBOX-1270) Abililty to restart schedulers with a \`restart\(\)\` method

### Improvement

- [COLDBOX-1268](https://ortussolutions.atlassian.net/browse/COLDBOX-1268) WireBox Singleton auto reload now only affects app singletons and not core singletons
- [COLDBOX-1269](https://ortussolutions.atlassian.net/browse/COLDBOX-1269) Do not add double headers if \`event.setHTTPHeader\(\)\` is called more than once
- [COLDBOX-1273](https://ortussolutions.atlassian.net/browse/COLDBOX-1273) Removal of deprecated CFML functions in core
- [COLDBOX-1275](https://ortussolutions.atlassian.net/browse/COLDBOX-1275) Improved engine detection by the CFMLEngine feature class
- [COLDBOX-1278](https://ortussolutions.atlassian.net/browse/COLDBOX-1278) Remove unsafe evaluate function usage

### Bug

- [COLDBOX-1266](https://ortussolutions.atlassian.net/browse/COLDBOX-1266) Logger for MS SQL using date not datetime.
- [COLDBOX-1267](https://ortussolutions.atlassian.net/browse/COLDBOX-1267) Lucee only isEmpty function call
- [COLDBOX-1279](https://ortussolutions.atlassian.net/browse/COLDBOX-1279) Render encapsulator bleed of this scope by engines

## [7.2.1] - 2023-12-11

### ColdBox HMVC

#### Bug Fixes

- COLDBOX-1264 - standalone libs issue with agressive excludes on build process and wirebox standalone not building correctly

### CacheBox

#### Bug Fixes

- CACHEBOX-85 - Improve Lock and Double `get` from getOrSet

## [7.2.0] - 2023-11-18

### ColdBox HMVC

#### New Feature

- [COLDBOX-1248](https://ortussolutions.atlassian.net/browse/COLDBOX-1248) Scheduled tasks now get a \`group\` property so you can use it for grouping purposes
- [COLDBOX-1252](https://ortussolutions.atlassian.net/browse/COLDBOX-1252) New \`now()\` method in the DateTmeHelper with optional TimeZone
- [COLDBOX-1253](https://ortussolutions.atlassian.net/browse/COLDBOX-1253) New datetimehelper method: getSystemTimezoneAsString()
- [COLDBOX-1256](https://ortussolutions.atlassian.net/browse/COLDBOX-1256) New ScheduledTask helper: getLastResult() to get the latest result
- [COLDBOX-1257](https://ortussolutions.atlassian.net/browse/COLDBOX-1257) LastResult is now a cbproxies Optional to denote a value or not (COMPAT)
- [COLDBOX-1258](https://ortussolutions.atlassian.net/browse/COLDBOX-1258) new scheduledTask method: isEnabled() to verify if the task is enabled
- [COLDBOX-1259](https://ortussolutions.atlassian.net/browse/COLDBOX-1259) Complete rewrite of Scheduled Task setNextRuntime() calculations to account for start end running scenarios
- [COLDBOX-1260](https://ortussolutions.atlassian.net/browse/COLDBOX-1260) new ScheduledTask period : everySecond()
- [COLDBOX-1262](https://ortussolutions.atlassian.net/browse/COLDBOX-1262) New SchemaInfo helper to help interrogate databases for metadata
- [COLDBOX-1263](https://ortussolutions.atlassian.net/browse/COLDBOX-1263) Add an errorHandler to the allApply method so you can attach your own error handler to each future computation

#### Improvement

- [COLDBOX-1246](https://ortussolutions.atlassian.net/browse/COLDBOX-1246) casting to long instead of int when using LocalDateTime and plus methods to avoid casting issues.
- [COLDBOX-1247](https://ortussolutions.atlassian.net/browse/COLDBOX-1247) Do not expose restful handler exception data unless you are in debug mode
- [COLDBOX-1250](https://ortussolutions.atlassian.net/browse/COLDBOX-1250) RestHandler.cfc should catch NotAuthorized exception
- [COLDBOX-1254](https://ortussolutions.atlassian.net/browse/COLDBOX-1254) getFirstBusinessDayOfTheMonth(), getLastBusinessDayOfTheMonth() now refactored to the dateTimeHelper
- [COLDBOX-1255](https://ortussolutions.atlassian.net/browse/COLDBOX-1255) validateTime() is now a helper method in the DateTimeHelper
- [COLDBOX-1261](https://ortussolutions.atlassian.net/browse/COLDBOX-1261) Migration of old tasks to new task syntax of task()

#### Bug

- [COLDBOX-1241](https://ortussolutions.atlassian.net/browse/COLDBOX-1241) Scheduled Task Stats "NextRun", "Created", "LastRun" Using Wrong Timezones
- [COLDBOX-1244](https://ortussolutions.atlassian.net/browse/COLDBOX-1244) onSessionEnd Error when using Coldbox_App_Key
- [COLDBOX-1245](https://ortussolutions.atlassian.net/browse/COLDBOX-1245) Scheduled task isConstrainted() on day of the month was calculating the days in month backwards
- [COLDBOX-1251](https://ortussolutions.atlassian.net/browse/COLDBOX-1251) set next run time when using first or last business day was not accounting times

### CacheBox

#### Improvement

- [CACHEBOX-70](https://ortussolutions.atlassian.net/browse/CACHEBOX-70) Support ad-hoc struct literal of CacheBox DSL to configure CacheBox

### LogBox

#### New Feature

- [LOGBOX-75](https://ortussolutions.atlassian.net/browse/LOGBOX-75) New listeners for all appenders: preProcessQueue() postProcessQueue()
- [LOGBOX-76](https://ortussolutions.atlassian.net/browse/LOGBOX-76) Add the queue as an argument to the processQueueElement() method
- [LOGBOX-79](https://ortussolutions.atlassian.net/browse/LOGBOX-79) new rolling appender property archiveLayout which is a closure that returns the pattern of the archive layout

#### Bug

- [LOGBOX-73](https://ortussolutions.atlassian.net/browse/LOGBOX-73) Unhandled race conditions in FileRotator lead to errors and potential log data loss
- [LOGBOX-77](https://ortussolutions.atlassian.net/browse/LOGBOX-77) log rotator was not checking for file existence and 1000s of errors could be produced

#### Improvement

- [LOGBOX-62](https://ortussolutions.atlassian.net/browse/LOGBOX-62) Support ad-hoc struct literal of LogBox DSL to configure LogBox
- [LOGBOX-70](https://ortussolutions.atlassian.net/browse/LOGBOX-70) Add \`Exclude\` key to Logbox Categories to Easily Exclude Appenders
- [LOGBOX-74](https://ortussolutions.atlassian.net/browse/LOGBOX-74) shutdown the appenders first instead of the executors to avoid chicken and egg issues
- [LOGBOX-78](https://ortussolutions.atlassian.net/browse/LOGBOX-78) Change fileMaxArchives default from 2 to 10

#### Task

- [LOGBOX-72](https://ortussolutions.atlassian.net/browse/LOGBOX-72) Removal of instance approach in preferences to accessors for the LogBoxConfig

### WireBox

#### New Features

- [WIREBOX-61](https://ortussolutions.atlassian.net/browse/WIREBOX-61) Make wirebox.system.aop.Mixer listener load automatically if any aspects are defined/mapped

* * *

## [7.1.0] - 2023-08-03

### ColdBox HMVC

#### Bug

- [COLDBOX-1233](https://ortussolutions.atlassian.net/browse/COLDBOX-1233) Exception bean can't cast \`"i"\` to a number value

#### New Feature

- [COLDBOX-1229](https://ortussolutions.atlassian.net/browse/COLDBOX-1229) Added debug argument to ScheduleExecutor and Scheduler when creating tasks for consistency
- [COLDBOX-1230](https://ortussolutions.atlassian.net/browse/COLDBOX-1230) Reorganized ScheduledTasks functions within the CFC into code groups and comments
- [COLDBOX-1235](https://ortussolutions.atlassian.net/browse/COLDBOX-1235) New StringUtil.prettySQL method for usage in debugging and whoops reports
- [COLDBOX-1238](https://ortussolutions.atlassian.net/browse/COLDBOX-1238) New testing matcher: toRedirectTo for easier testing against relocations
- [COLDBOX-1239](https://ortussolutions.atlassian.net/browse/COLDBOX-1239) New REST convention for custom error handlers: \`on{errorType}Exception()\`

#### Improvements

- [COLDBOX-1041](https://ortussolutions.atlassian.net/browse/COLDBOX-1041) Logging category in ColdBox scheduler is generic
- [COLDBOX-1231](https://ortussolutions.atlassian.net/browse/COLDBOX-1231) Improve RestHandler Exception handler with on#ExceptionType#Exception() convention
- [COLDBOX-1234](https://ortussolutions.atlassian.net/browse/COLDBOX-1234) Account for null or empty incoming json to prettyjson output
- [COLDBOX-1236](https://ortussolutions.atlassian.net/browse/COLDBOX-1236) Incorporate appName into the appHash to give more uniqueness to locks internally

#### Tasks

- [COLDBOX-1237](https://ortussolutions.atlassian.net/browse/COLDBOX-1237) Removal of Lucee RC tests - no longer needed

### WireBox

#### Bug

- [WIREBOX-148](https://ortussolutions.atlassian.net/browse/WIREBOX-148) Several AOP and Internal WireBox methods not excluded from delegations
- [WIREBOX-150](https://ortussolutions.atlassian.net/browse/WIREBOX-150) Wirebox standalone is missing delegates
- [WIREBOX-151](https://ortussolutions.atlassian.net/browse/WIREBOX-151) Injections are null, sometimes
- [WIREBOX-152](https://ortussolutions.atlassian.net/browse/WIREBOX-152) getEnv errors in Binder context
- [WIREBOX-154](https://ortussolutions.atlassian.net/browse/WIREBOX-154) populateFromQuery delegate defaulting composeRelationships to true

#### Improvement

- [WIREBOX-147](https://ortussolutions.atlassian.net/browse/WIREBOX-147) Improve debug logging to not send the full memento on several debug operations

#### Task

- [WIREBOX-149](https://ortussolutions.atlassian.net/browse/WIREBOX-149) \`toWebservice()\` is now deprecated

* * *

## [7.0.0] - 2023-05-15

### ColdBox HMVC

#### Bugs

- [COLDBOX-1133](https://ortussolutions.atlassian.net/browse/COLDBOX-1133) \`getFullURL\` encodes the query string when it should not.
- [COLDBOX-1136](https://ortussolutions.atlassian.net/browse/COLDBOX-1136) Scoping lookup bug in Lucee affects route()
- [COLDBOX-1138](https://ortussolutions.atlassian.net/browse/COLDBOX-1138) Event Cache Response Has Status Code of 0 (or Null)
- [COLDBOX-1139](https://ortussolutions.atlassian.net/browse/COLDBOX-1139) make event caching cache keys lower cased to avoid case issues when clearing keys
- [COLDBOX-1143](https://ortussolutions.atlassian.net/browse/COLDBOX-1143) render inline PDF (CB 6.8.1) throws a 500 error
- [COLDBOX-1145](https://ortussolutions.atlassian.net/browse/COLDBOX-1145) RestHandler OnError() Exception not checking for empty \`exception\` blocks which would cause another exception on development ONLY
- [COLDBOX-1146](https://ortussolutions.atlassian.net/browse/COLDBOX-1146) BiConsumer proxy was making both arguments required, when they can be null so execution fails
- [COLDBOX-1149](https://ortussolutions.atlassian.net/browse/COLDBOX-1149) Woops and Adobe CF needs a double check if session/client is defined even if sessionManagement/clientManagement is defined
- [COLDBOX-1150](https://ortussolutions.atlassian.net/browse/COLDBOX-1150) virtual app controller scoping is missing on ocassion due to this.load|unload flags
- [COLDBOX-1151](https://ortussolutions.atlassian.net/browse/COLDBOX-1151) Integration Tests do not support NoRender()
- [COLDBOX-1153](https://ortussolutions.atlassian.net/browse/COLDBOX-1153)   RestHandler.cfc missing exception information on InvalidCredentials & TokenInvalidException
- [COLDBOX-1154](https://ortussolutions.atlassian.net/browse/COLDBOX-1154) Invalid DateFormat Mask in Whoops.cfm
- [COLDBOX-1173](https://ortussolutions.atlassian.net/browse/COLDBOX-1173) Update the Router.cfc to look at not only the cgi host but the forwarded hosts
- [COLDBOX-1175](https://ortussolutions.atlassian.net/browse/COLDBOX-1175) calling function "view" from within function which has an argument named "view" causes error.
- [COLDBOX-1176](https://ortussolutions.atlassian.net/browse/COLDBOX-1176) viewLocations struct does not exist in function renderer.layout() on line 684 if nolayout = true
- [COLDBOX-1191](https://ortussolutions.atlassian.net/browse/COLDBOX-1191) Attempts to use \`getHTMLBaseURL()\` inside of Async Task Fail on ACF
- [COLDBOX-1193](https://ortussolutions.atlassian.net/browse/COLDBOX-1193) Missing java casting on arrayRange() method ont the asyncmanager
- [COLDBOX-1194](https://ortussolutions.atlassian.net/browse/COLDBOX-1194)  Ensure modules are applied to routing action structs when necessary #243
- [COLDBOX-1196](https://ortussolutions.atlassian.net/browse/COLDBOX-1196) Render collections items and counter variables are not thread safe since we migrated to a singleton renderer
- [COLDBOX-1202](https://ortussolutions.atlassian.net/browse/COLDBOX-1202) urlMatches in the request context does not account for the path to be larger than the requested uri
- [COLDBOX-1204](https://ortussolutions.atlassian.net/browse/COLDBOX-1204) Overridden events in preProcess interceptions assume event cache configuration of original request
- [COLDBOX-1211](https://ortussolutions.atlassian.net/browse/COLDBOX-1211) Base Model and Interceptor Tests where overriding application.wirebox in integration tests
- [COLDBOX-1213](https://ortussolutions.atlassian.net/browse/COLDBOX-1213) Var scoping issue on \`includeUDF\` in the super type

#### Improvements

- [COLDBOX-1029](https://ortussolutions.atlassian.net/browse/COLDBOX-1029) ModuleAwareness : Wirebox Injector Lookup Should Check Current Module First
- [COLDBOX-1155](https://ortussolutions.atlassian.net/browse/COLDBOX-1155) Implement abort logic onAuthenticationFailure on RESTHandler
- [COLDBOX-1157](https://ortussolutions.atlassian.net/browse/COLDBOX-1157) Reuse existing controller in getMockRequestContext()
- [COLDBOX-1159](https://ortussolutions.atlassian.net/browse/COLDBOX-1159) JSON Serialization in \`forAttribute\` Does Not Support ACF Prefixing
- [COLDBOX-1171](https://ortussolutions.atlassian.net/browse/COLDBOX-1171) Do not allow injection of the same applicatio helper on the same target
- [COLDBOX-1177](https://ortussolutions.atlassian.net/browse/COLDBOX-1177) Please add more debugging info to REST handler
- [COLDBOX-1184](https://ortussolutions.atlassian.net/browse/COLDBOX-1184) When whoops error template defaults to public for non-dev, the messaging is very confusing
- [COLDBOX-1185](https://ortussolutions.atlassian.net/browse/COLDBOX-1185) ColdBox DebugMode with inDebugMode() helper
- [COLDBOX-1190](https://ortussolutions.atlassian.net/browse/COLDBOX-1190) Reworking of several rest handler exception methods so they log the issues instead of announcing \`onException\` events and announce their appropriate events , onAuthenticationFailure, onAuthorizationFailure, onValidationException, onEntityNotFoundException
- [COLDBOX-1195](https://ortussolutions.atlassian.net/browse/COLDBOX-1195) ColdBox Proxy should ignore the routing service captures to avoid redirects or returns
- [COLDBOX-1210](https://ortussolutions.atlassian.net/browse/COLDBOX-1210) encapsulate route finding by name to the actual router itself
- [COLDBOX-1214](https://ortussolutions.atlassian.net/browse/COLDBOX-1214) Compatibility layer for env methods in the Util object: getSystemSetting(), getSystemProperty(), getEnv()

#### New Features

- [COLDBOX-1022](https://ortussolutions.atlassian.net/browse/COLDBOX-1022) Allow for Flash RAM to use a third party provided tracking variable via the new setting identifierProvider
- [COLDBOX-1039](https://ortussolutions.atlassian.net/browse/COLDBOX-1039) Allow unregistering closure listeners
- [COLDBOX-1077](https://ortussolutions.atlassian.net/browse/COLDBOX-1077) Provide ability for handlers/interceptors/etc. to have inherent self-knowledge of the module they live in for modulesettings/moduleConfig injections
- [COLDBOX-1137](https://ortussolutions.atlassian.net/browse/COLDBOX-1137) Allow passing interception point first in interceptor listen() method
- [COLDBOX-1140](https://ortussolutions.atlassian.net/browse/COLDBOX-1140) Whoops updates galore! SQL Syntax highlighting, json formatting and highlighting, and more
- [COLDBOX-1141](https://ortussolutions.atlassian.net/browse/COLDBOX-1141) New Flow delegate helpers for functional usage everywhere in ColdBox land
- [COLDBOX-1142](https://ortussolutions.atlassian.net/browse/COLDBOX-1142) New convention for module setting overrides: config/{moduleName}.cfc
- [COLDBOX-1147](https://ortussolutions.atlassian.net/browse/COLDBOX-1147) PostLayoutRender and PostViewRender now pass which view/layout path was used to render
- [COLDBOX-1148](https://ortussolutions.atlassian.net/browse/COLDBOX-1148) postEvent now get's new interceptData: ehBean, handler and data results
- [COLDBOX-1152](https://ortussolutions.atlassian.net/browse/COLDBOX-1152) this.unloadColdBox is false now as the default thanks to the virtual test app
- [COLDBOX-1158](https://ortussolutions.atlassian.net/browse/COLDBOX-1158) New \`back()\` function in super type that you can use to redirect back to your referer or a fallback
- [COLDBOX-1161](https://ortussolutions.atlassian.net/browse/COLDBOX-1161) new toJson() helper in the Util class which is delegated in many locations around the framework to add struct based query serialization and no dubm security prefixes
- [COLDBOX-1162](https://ortussolutions.atlassian.net/browse/COLDBOX-1162) Add in functionality to exclude patterns via router's findRoute()
- [COLDBOX-1165](https://ortussolutions.atlassian.net/browse/COLDBOX-1165) New convention for modules for storing and using coldfusion tags: \`/tags\`
- [COLDBOX-1166](https://ortussolutions.atlassian.net/browse/COLDBOX-1166) Lazy loading and persistence of engine helper to assist in continued performance and initial load speed
- [COLDBOX-1167](https://ortussolutions.atlassian.net/browse/COLDBOX-1167) New core delegates for smaller building blocks, which leverages the \`@coreDelegates\` namespace
- [COLDBOX-1168](https://ortussolutions.atlassian.net/browse/COLDBOX-1168) New coldbox based delegates mapped with \`@cbDelegates\`
- [COLDBOX-1172](https://ortussolutions.atlassian.net/browse/COLDBOX-1172) core json utils now include a prettyJson() and a toPrettyJson() utilities
- [COLDBOX-1174](https://ortussolutions.atlassian.net/browse/COLDBOX-1174) New getEnv() method on the base test class to get access to the env delegate for inquiring for env and java properties
- [COLDBOX-1178](https://ortussolutions.atlassian.net/browse/COLDBOX-1178) ChronoUnit becomes the official cb Date Time Helper to assist with date/time conversions and formatting
- [COLDBOX-1179](https://ortussolutions.atlassian.net/browse/COLDBOX-1179) New super type methods: getDateTimeHelper() getIsoTime() to assist with recurrent iso time conversions in modern APIs and responses
- [COLDBOX-1186](https://ortussolutions.atlassian.net/browse/COLDBOX-1186) Add three environment location helpers in the controller and supertype: isProduction(), isDevelopment(), isTesting()
- [COLDBOX-1188](https://ortussolutions.atlassian.net/browse/COLDBOX-1188) Request Context setRequestTimeout() method encapsulation, so you can control the time limit of a request
- [COLDBOX-1189](https://ortussolutions.atlassian.net/browse/COLDBOX-1189) setRequestTimeout() mock in testing Request Context so handlers cannot override testing timeouts
- [COLDBOX-1192](https://ortussolutions.atlassian.net/browse/COLDBOX-1192) Module Inception Isolation - every module has it's own injector that matches the module hierarchy
- [COLDBOX-1197](https://ortussolutions.atlassian.net/browse/COLDBOX-1197) All rendering methods now accept a \`viewVariables\` argument that allows you to add variables into the view's \`variables\` scope
- [COLDBOX-1199](https://ortussolutions.atlassian.net/browse/COLDBOX-1199) New request context method: \`routeIs( name ):boolean\` that evaluates if the passed name is the same as the current route
- [COLDBOX-1200](https://ortussolutions.atlassian.net/browse/COLDBOX-1200) request context \`getFullUrl()\` renamed to \`getUrl()\`
- [COLDBOX-1201](https://ortussolutions.atlassian.net/browse/COLDBOX-1201) request context \`getFullPath()\` renamed to \`getPath()\`
- [COLDBOX-1205](https://ortussolutions.atlassian.net/browse/COLDBOX-1205) request context \`event.getUrl( withQuery:true )\` new argument \`withQuery\` to allow adding the query string or not
- [COLDBOX-1206](https://ortussolutions.atlassian.net/browse/COLDBOX-1206) request context \`event.getPath( withQuery:true )\` new argument \`withQuery\` to allow adding the query string or not
- [COLDBOX-1207](https://ortussolutions.atlassian.net/browse/COLDBOX-1207) New request context methods: \`getPathSegments():array, getPathSegment( index, defaultValue ):string\` so you can segment the incoming url path
- [COLDBOX-1208](https://ortussolutions.atlassian.net/browse/COLDBOX-1208) Add \`persist\` and \`persistStruct\` to the \`back()\` method in the supertype
- [COLDBOX-1209](https://ortussolutions.atlassian.net/browse/COLDBOX-1209) Add route names to resourceful routes according to conventions
- [COLDBOX-1215](https://ortussolutions.atlassian.net/browse/COLDBOX-1215) this.moduleInjector enables modular injector hiearchy. By default it is false until ColdBox 8
- [COLDBOX-1216](https://ortussolutions.atlassian.net/browse/COLDBOX-1216) New super type method: \`getRootWireBox()\` to get an instance of the root wirebox in the application
- [COLDBOX-1217](https://ortussolutions.atlassian.net/browse/COLDBOX-1217) New `AppModes` delegate that helps objects know in which modes the application is on: debugMode, testing, production, etc.
- [COLDBOX-1226](https://ortussolutions.atlassian.net/browse/COLDBOX-1226) Many Many Many Scheduled Tasks Updates

#### Task

- [COLDBOX-1160](https://ortussolutions.atlassian.net/browse/COLDBOX-1160) COMPAT: jsonQueryFormat has been removed in preference to "struct".
- [COLDBOX-1169](https://ortussolutions.atlassian.net/browse/COLDBOX-1169) routes.cfm Support Removal
- [COLDBOX-1170](https://ortussolutions.atlassian.net/browse/COLDBOX-1170) populateModel deprecated - refactored to just populate() in the supertype methods
- [COLDBOX-1187](https://ortussolutions.atlassian.net/browse/COLDBOX-1187) Removal of uniqueUrls boolean indicator for URL routing, since Pretty URLs are now the standard. This rerouting feature needs to be removed.

### LogBox

#### Improvements

- [LOGBOX-67](https://ortussolutions.atlassian.net/browse/LOGBOX-67) Come up with better default serialization for exception objects on LogEvents

#### New Features

- [LOGBOX-61](https://ortussolutions.atlassian.net/browse/LOGBOX-61) Allow for closure for all logging messages in the logger, this way, we can verify the logging level automatically.
- [LOGBOX-69](https://ortussolutions.atlassian.net/browse/LOGBOX-69) LogEvents in JSON are now prettified

### CacheBox

#### Bugs

- [CACHEBOX-83](https://ortussolutions.atlassian.net/browse/CACHEBOX-83) Intermittent Exception from MetadataIndexer

### WireBox

#### Improvements

- [WIREBOX-133](https://ortussolutions.atlassian.net/browse/WIREBOX-133) BeanPopulator renamed to ObjectPopulator to be consistent with naming

#### Bugs

- [WIREBOX-132](https://ortussolutions.atlassian.net/browse/WIREBOX-132) WireBox caches Singletons even if their autowired dependencies throw exceptions.

#### New Features

- [WIREBOX-89](https://ortussolutions.atlassian.net/browse/WIREBOX-89) Wirebox - add onInjectorMissingDependency event
- [WIREBOX-130](https://ortussolutions.atlassian.net/browse/WIREBOX-130) Ability to remove specific objects from wirebox injector singleton's and request scopes via a \`clear( key )\` method
- [WIREBOX-131](https://ortussolutions.atlassian.net/browse/WIREBOX-131) Object Delegators
- [WIREBOX-134](https://ortussolutions.atlassian.net/browse/WIREBOX-134) Object Populator is now created by the Injector and it is now a singleton
- [WIREBOX-135](https://ortussolutions.atlassian.net/browse/WIREBOX-135) Object populator now caches orm entity maps, so they are ONLy loaded once and population with orm objects accelerates tremendously
- [WIREBOX-136](https://ortussolutions.atlassian.net/browse/WIREBOX-136) object populator cache relational metadata for faster population of the same objects
- [WIREBOX-137](https://ortussolutions.atlassian.net/browse/WIREBOX-137) New \`this.population\` marker for controlling mas population of objects. It can include an \`include\` and and \`exclude\` list.
- [WIREBOX-138](https://ortussolutions.atlassian.net/browse/WIREBOX-138) Lazy Properties
- [WIREBOX-139](https://ortussolutions.atlassian.net/browse/WIREBOX-139) Property Observers
- [WIREBOX-140](https://ortussolutions.atlassian.net/browse/WIREBOX-140) Transient request cache for injections and delegations
- [WIREBOX-141](https://ortussolutions.atlassian.net/browse/WIREBOX-141) New config setting transientInjectionCache to enable or disable globally, default is true
- [WIREBOX-142](https://ortussolutions.atlassian.net/browse/WIREBOX-142) You can now instantiate an Injector with the \`binder\` argument being the config structure instead of creating a binder
- [WIREBOX-143](https://ortussolutions.atlassian.net/browse/WIREBOX-143) New injection DSL for ColdBox Root Injector \`coldbox:rootWireBox\`
- [WIREBOX-144](https://ortussolutions.atlassian.net/browse/WIREBOX-144) Injectors can now track the root injector by having a root reference via \`getRoot(), hasRoot()\` methods
- [WIREBOX-145](https://ortussolutions.atlassian.net/browse/WIREBOX-145) New DSL for wirebox only root injectors: \`wirebox:root\`

* * *

[Unreleased]: https://github.com/ColdBox/coldbox-platform/compare/v7.2.1...HEAD

[7.2.1]: https://github.com/ColdBox/coldbox-platform/compare/v7.2.0...v7.2.1

[7.2.0]: https://github.com/ColdBox/coldbox-platform/compare/v7.1.0...v7.2.0

[7.1.0]: https://github.com/ColdBox/coldbox-platform/compare/v7.0.0...v7.1.0

[7.0.0]: https://github.com/ColdBox/coldbox-platform/compare/af03e4a577fa627e94619a451e56d36292815b06...v7.0.0
