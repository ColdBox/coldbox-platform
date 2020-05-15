# Changelog

All notable changes to this project will be documented here: https://coldbox.ortusbooks.com/intro/release-history and summarized in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

----

## [6.0.0-RC] => 2020-MAY-15

### Tasks

* COLDBOX-870 - `compatiblity` setnextEvent removed as it was deprecated in 5
* COLDBOX-867 - `compatiblity` Removed interceptors.SES as it was deprecated in 5
* COLDBOX-866 - `compatiblity` onInvalidEvent is now removed in favor of invalidEventHandler, this was deprecated in 5.x
* COLDBOX-872 - `compatiblity` `getModel()` is now fully deprecated and removed in favor of `getInstance()`

### Added

* COLDBOX-877 - New dsl `coldbox:asyncManager` to get the async manager
* COLDBOX-876 - New dsl  `coldbox:coldboxSettings` alias to `coldbox:fwSettings`
* COLDBOX-874 - `BaseTestCase` new method `getHandlerResults()` to easy get the handler results, also injected into test request contexts
* COLDBOX-860 - Convert proxy to script and optimize it
* COLDBOX-871 - `compatiblity` Removed `fwsetting` argument from `getSetting()` in favor of a new function: `getColdBoxSetting()`
* COLDBOX-848 - Improve the bug reporting template for development based on whoops
* COLDBOX-869 - Response, SuperType => New functional if construct `when( boolean, success, failure )`
* COLDBOX-868 - RequestContext Add `urlMatches` to match current urls
* COLDBOX-865 - `compatiblity` `autoMapModels` defaults to true now
* COLDBOX-864 - `compatiblity` `jsonPayloadToRC` now defaults to true
* COLDBOX-863 - Add setting to define reinit key vs. hard-coded fwreinit: `reinitKey`
* COLDBOX-859 - ability to do async scheduled tasks with new async cbpromises
* COLDBOX-841 - `compatiblity` Change announceInterception() and processState() to a single method name like: announce()
* COLDBOX-882 - `compatiblity` Deprecate interceptData in favor of just data
* LOGBOX-46 - Update ConsoleAppender to use TaskScheduler 
* LOGBOX-47 - AbstractAppender log listener and queueing facilities are now available for all appenders
* LOGBOX-48 - DB Appender now uses a queueing approach to sending log messages

### Fixed

* COLDBOX-861 - Self-autowire fails for applications with context root configured in ColdBox Proxy
* COLDBOX-873 - `NullPointerException` in ScheduledExecutor (Lucee 5.3.4.80)
* COLDBOX-878 - ColdBox 6 blows up if `models` directory doesn't exist
* COLDBOX-875 - Gracefully handle out of index row number in populateFromQuery #450 	
* COLDBOX-862 - when passing custom cfml executors to futures it blows up as the native executor is not set
* COLDBOX-879 - Reinit-Password-Check does not use the new "reinitKey"-Setting
* COLDBOX-880 - ViewHelpers not working in CB-6 RC

### Info

* What's New: https://coldbox.ortusbooks.com/intro/release-history/whats-new-with-6.0.0
* Upgrade Guide: https://coldbox.ortusbooks.com/intro/release-history/upgrading-to-coldbox-5

----

## [6.0.0-BETA] => 2020-APR-20

* Beta release of ColdBox 6. Check out the What's new guide for all issues: https://coldbox.ortusbooks.com/intro/release-history/whats-new-with-6.0.0