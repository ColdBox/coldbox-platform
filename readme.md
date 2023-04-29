<p align="center">
	<img src="https://www.ortussolutions.com/__media/coldbox-185-logo.png">
	<br>
	<img src="https://www.ortussolutions.com/__media/wirebox-185.png" height="125">
	<img src="https://www.ortussolutions.com/__media/cachebox-185.png" height="125" >
	<img src="https://www.ortussolutions.com/__media/logbox-185.png"  height="125">
</p>

<p align="center">
<a href="https://github.com/ColdBox/coldbox-platform/actions/workflows/ci.yml">
	<img src="https://github.com/ColdBox/coldbox-platform/actions/workflows/ci.yml/badge.svg">
</a>
<a href="https://forgebox.io/view/coldbox"><img src="https://forgebox.io/api/v1/entry/coldbox/badges/downloads" alt="Total Downloads" /></a>
<a href="https://forgebox.io/view/coldbox"><img src="https://forgebox.io/api/v1/entry/coldbox/badges/version" alt="Latest Stable Version" /></a>
<a href="https://forgebox.io/view/coldbox"><img src="https://img.shields.io/badge/License-Apache2-brightgreen" alt="Apache2 License" /></a>
</p>

<p align="center">
	Copyright Since 2005 ColdBox Platform by Luis Majano and Ortus Solutions, Corp
	<br>
	<a href="https://www.coldbox.org">www.coldbox.org</a> |
	<a href="https://www.ortussolutions.com">www.ortussolutions.com</a>
</p>

----

Because of God's grace, this project exists. If you don't like this, then don't read it, it's not for you.

>"Therefore being justified by faith, we have peace with God through our Lord Jesus Christ:
By whom also we have access by faith into this grace wherein we stand, and rejoice in hope of the glory of God.
And not only so, but we glory in tribulations also: knowing that tribulation worketh patience;
And patience, experience; and experience, hope:
And hope maketh not ashamed; because the love of God is shed abroad in our hearts by the
Holy Ghost which is given unto us. ." Romans 5:5

----

# Welcome to ColdBox LTS Release (`v6.x`)

ColdBox *Hierarchical* MVC is the de-facto enterprise-level [HMVC](https://en.wikipedia.org/wiki/Hierarchical_model%E2%80%93view%E2%80%93controller) framework for ColdFusion (CFML) developers. It's professionally backed, conventions-based, modular, highly extensible, and productive. Getting started with ColdBox is quick and painless.  ColdBox takes the pain out of development by giving you a standardized methodology for modern ColdFusion (CFML) development with features such as:

* [Conventions instead of configuration](https://coldbox.ortusbooks.com/getting-started/conventions)
* [Modern URL routing](https://coldbox.ortusbooks.com/the-basics/routing)
* [RESTFul APIs](https://coldbox.ortusbooks.com/the-basics/event-handlers/rendering-data)
* [A hierarchical approach to MVC using ColdBox Modules](https://coldbox.ortusbooks.com/hmvc/modules)
* [Event-driven programming](https://coldbox.ortusbooks.com/digging-deeper/interceptors)
* [Async and Parallel programming constructs](https://coldbox.ortusbooks.com/digging-deeper/promises-async-programming)
* [Integration & Unit Testing](https://coldbox.ortusbooks.com/testing/testing-coldbox-applications)
* [Included dependency injection](https://wirebox.ortusbooks.com)
* [Caching engine and API](https://cachebox.ortusbooks.com)
* [Logging engine](https://logbox.ortusbooks.com)
* [An extensive eco-system](https://forgebox.io)
* Much More

## LTS Support

For all ColdBox releases, updates are provided for 12 months and security fixes are provided for 2 years after the next major release.

**ColdBox 6.x will receive bug fixes until 2024 and security fixes until 2025.**

| Version | Release | Updates 	| Security Fixes |
| ------- | ------- | --------- | -------------- |
| 6.x     | 2022    | 2023      | 2025           |
| 7.x     | 2023    | 2024      | 2026           |
| 8.x     | 2024    | 2025      | 2027           |
| 9.x     | 2025    | 2026      | 2028           |

## License

Apache License, Version 2.0.

>The ColdBox Websites, logo and content have a separate license and they are a separate entity.

## Versioning

ColdBox is maintained under the Semantic Versioning guidelines as much as possible.

Releases will be numbered with the following format:

```html
<major>.<minor>.<patch>
```

And constructed with the following guidelines:

* Breaking backward compatibility bumps the major (and resets the minor and patch)
* New additions without breaking backward compatibility bumps the minor (and resets the patch)
* Bug fixes and misc changes bumps the patch

## Important Links

### Source Code

* https://github.com/coldbox/coldbox-platform

### Bug Tracking/Agile Boards

* https://ortussolutions.atlassian.net/browse/COLDBOX
* https://ortussolutions.atlassian.net/browse/CACHEBOX
* https://ortussolutions.atlassian.net/browse/LOGBOX
* https://ortussolutions.atlassian.net/browse/WIREBOX

### Documentation

* https://coldbox.ortusbooks.com
* https://cachebox.ortusbooks.com
* https://logbox.ortusbooks.com
* https://wirebox.ortusbooks.com

### Official Site

* https://www.coldbox.org
* https://www.ortussolutions.com/products/coldbox

## System Requirements

* Lucee 5+
* Adobe ColdFusion 2018+ (2016 Has Been Deprecated)

## Quick Installation

Please go to our [documentation](https://coldbox.ortusbooks.com) for expanded instructions.

**CommandBox (Recommended)**

We recommend you use [CommandBox](https://www.ortussolutions.com/products/commandbox), our CFML CLI and package manager, to install ColdBox.

**Stable Release**

`box install coldbox`

**Bleeding Edge Release**

`box install coldbox@be`

Bleeding edge releases are updated automatically when code is committed.

## Collaboration

First, read our [contributing](CONTRIBUTING.md) guidelines, then you will need to download [CommandBox](https://www.ortussolutions.com/products/commandbox) so you can install dependencies, run the development server and much more.

Then you need to install some CommandBox modules in order to work with environment variables and CFML engine configuration. Once you fork/clone the repository, startup a CommandBox shell in the root of the project via `box` and then install all of the project development dependencies:

```bash
install
```

Create an `.env` file according to the `.env.template` in the root and spice it up for your local database.  Then import the SQL for the database which can be found in `/tests/resources/coolblog.sql`. You can then go ahead and start an embedded server `box server start` and start hacking around.

For running our test suites you will need 2 more steps, so please refer to the [Readme](tests/readme.md) in the tests folder.

----

### THE DAILY BREAD

 > "I am the way, and the truth, and the life; no one comes to the Father, but by me (JESUS)" Jn 14:1-12
