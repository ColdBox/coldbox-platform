# Changelog

All notable changes to this project will be documented here: https://coldbox.ortusbooks.com/intro/release-history and summarized in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

----

## [6.4.0] => 2021-APR-09

### ColdBox HMVC Core

#### Bugs

- [COLDBOX-991](https://ortussolutions.atlassian.net/browse/COLDBOX-991) Fixes issues with Adobe losing App Context in Scheduled Tasks
- [COLDBOX-988](https://ortussolutions.atlassian.net/browse/COLDBOX-988) When running scheduled tasks in ACF loading of contexts produce a null pointer exception
- [COLDBOX-981](https://ortussolutions.atlassian.net/browse/COLDBOX-981) DataMarshaller no longer accepts 'row', 'column' or 'struct' as a valid argument.

#### Improvements

- [COLDBOX-989](https://ortussolutions.atlassian.net/browse/COLDBOX-989) Add more debugging when exceptions occur when loading/unloading thread contexts
- [COLDBOX-971](https://ortussolutions.atlassian.net/browse/COLDBOX-971) Implement caching strategy for application helper lookups into the `default` cache

#### New Features

- [COLDBOX-990](https://ortussolutions.atlassian.net/browse/COLDBOX-990) Allow structs for query strings when doing relocations
- [COLDBOX-987](https://ortussolutions.atlassian.net/browse/COLDBOX-987) Encapsulate any type of exception in the REST Handler in a onAnyOtherException\(\) action
- [COLDBOX-986](https://ortussolutions.atlassian.net/browse/COLDBOX-986) Add registration and activation timestamps to the a module configuration object
- [COLDBOX-985](https://ortussolutions.atlassian.net/browse/COLDBOX-985) Rename renderLayout\(\) to just layout\(\) and deprecate it for v7
- [COLDBOX-984](https://ortussolutions.atlassian.net/browse/COLDBOX-984) Rename renderView\(\) to just view\(\) and deprecate it for v7