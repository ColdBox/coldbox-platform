# Changelog

All notable changes to this project will be documented here: https://coldbox.ortusbooks.com/intro/release-history and summarized in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

----

## [6.2.2] => 2021-JAN-12

### ColdBox HMVC Core

#### Bugs

* [COLDBOX-963] - Use Java URI for more resiliant getFullURL to avoid double slashes

----

### WireBox

### Bug

* [WIREBOX-107] - wirebox metadata caching broken
* [WIREBOX-109] - Standalone event pool interceptData -> data not backwards compat

### Improvement

* [WIREBOX-108] - WireBox not handling cachebox, logbox, and asynmanager instances properly


----

### CacheBox

#### Improvement

* [CACHEBOX-65] - CacheBox not handling wirebox, logbox, and asynmanager instances properly

----

### LogBox

#### Improvement

* [LOGBOX-60] - Ignore interrupted exceptions from appenders' scheduler pool
