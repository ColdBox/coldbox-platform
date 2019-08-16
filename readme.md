﻿[![Build Status](https://travis-ci.org/ColdBox/coldbox-platform.svg?branch=development)](https://travis-ci.org/ColdBox/coldbox-platform)

```
   ____      _     _ ____            
  / ___|___ | | __| | __ )  _____  __
 | |   / _ \| |/ _` |  _ \ / _ \ \/ /
 | |__| (_) | | (_| | |_) | (_) >  < 
  \____\___/|_|\__,_|____/ \___/_/\_\
                                     
```

Copyright Since 2005 ColdBox Platform by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.ortussolutions.com

----

Because of God's grace, this project exists. If you don't like this, then don't read it, it's not for you.

>"Therefore being justified by faith, we have peace with God through our Lord Jesus Christ:
By whom also we have access by faith into this grace wherein we stand, and rejoice in hope of the glory of God.
And not only so, but we glory in tribulations also: knowing that tribulation worketh patience;
And patience, experience; and experience, hope:
And hope maketh not ashamed; because the love of God is shed abroad in our hearts by the 
Holy Ghost which is given unto us. ." Romans 5:5

----

# Welcome to ColdBox

ColdBox is a conventions modular MVC development platform for ColdFusion (CFML).

## License

Apache License, Version 2.0.

>The ColdBox Websites, logo and content have a separate license and they are a separate entity.

## Versioning

ColdBox is maintained under the Semantic Versioning guidelines as much as possible.

Releases will be numbered with the following format:

```
<major>.<minor>.<patch>
```

And constructed with the following guidelines:

* Breaking backward compatibility bumps the major (and resets the minor and patch)
* New additions without breaking backward compatibility bumps the minor (and resets the patch)
* Bug fixes and misc changes bumps the patch

## Important Links

Source Code

- https://github.com/coldbox/coldbox-platform

Bug Tracking/Agile Boards

- https://ortussolutions.atlassian.net/browse/COLDBOX
- https://ortussolutions.atlassian.net/browse/WIREBOX
- https://ortussolutions.atlassian.net/browse/LOGBOX
- https://ortussolutions.atlassian.net/browse/CACHEBOX

Documentation

- https://coldbox.ortusbooks.com
- https://wiki.coldbox.org (Legacy)

Official Site

- https://www.ortussolutions.com/products/coldbox
- https://www.coldbox.org

## System Requirements

- Lucee 4.5+
- ColdFusion 11+

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

If you want to develop and hack at the source, you will need to download [CommandBox](https://www.ortussolutions.com/products/commandbox) first.

Then you need to install some CommandBox modules in order to work with environment variables and cfml engine configuration. Just type the following command:

```
install commandbox-cfconfig,commandbox-dotenv
```

Then in the root of this project, type `box install` to install the development dependencies.  Create a `.env` file according to the `.env.template` in the root and spice it up for your local database.  The import SQL for the database can be found in `/tests/resources/coolblog.sql`. You can then go ahead and start an embedded server `box server start` and start hacking around.

For running our test suites you will need 2 more steps, so please refer to the [Readme](tests/readme.md) in the tests folder.

---
 
### THE DAILY BREAD
 > "I am the way, and the truth, and the life; no one comes to the Father, but by me (JESUS)" Jn 14:1-12
