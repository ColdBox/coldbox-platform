# Welcome to the ColdBox Test Suite

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

Because of God's grace, this project exists. If you don't like this, then don't read it, its not for you.

>"Therefore being justified by faith, we have peace with God through our Lord Jesus Christ:
By whom also we have access by faith into this grace wherein we stand, and rejoice in hope of the glory of God.
And not only so, but we glory in tribulations also: knowing that tribulation worketh patience;
And patience, experience; and experience, hope:
And hope maketh not ashamed; because the love of God is shed abroad in our hearts by the
Holy Ghost which is given unto us. ." Romans 5:5

----

## Instructions

This folder contains a full suite of BDD specs, load tests and much more.  Here are some
instructions on how to get the test suites to run in your development environment.

### Get CommandBox

We leverage **CommandBox** to build ColdBox and its libraries.  You can download it from our main website here: https://www.ortussolutions.com/products/commandbox.

### Install Dependencies

Install the CommandBox modules first by typing the following command:

```
install commandbox-cfconfig
```

Then go into the root of the project and type: `box install`. This will download all required dependencies and test dependencies for you.

### Startup Test Server

Startup the test server via the following command: `box server start` in the root of the repository. This will startup a server that you can use for development, hacking and testing.

> **Note:** The server will start in a specific port, make sure you take note of it.

We deliver the capabilities for you to test the following engines:

* Lucee 5
* ACF 2018
* ACF 2021

Just look at the appropriate `server-engine.json` file in the root of the repository so you can test a specific engine like this:

```
box server start serverConfigFile=server-adobe@2021.json
```

> **Note:** Run the above command from the root of the repo.

### Testing Datasource

The testing datasource is pre-configured with the following properties that can be found in the file `/.cfconfig.json`, which leverages a MySQL database.

* Database: `coolblog`
* Username: `root`
* Password: `mysql`

Modify those values as you need to change the connection details or remove the datasource from the JSON file and create it manually in the admin.  Create a database called `coolblog` and populateit with our SQL script that can be found here: `/tests/resources/coolblog.sql`.  There is a version of the SQL script for MS SQL Server as well in the same folder.

Here's a Docker command that you can run in the root of this project to create and seed the database:

```sh
docker container run -d --name coolblog -p 3306:3306 -e MYSQL_ROOT_PASSWORD=mysql -e MYSQL_DATABASE=coolblog -v $(pwd)/tests/resources/coolblog.sql:/docker-entrypoint-initdb.d/coolblog.sql mysql:5
```

### Lucee Optional: `Default` Cache

If you are in the Lucee CFML engine, then you will need to register a `default` cache in the administrator so CacheBox can be tested.

## Test Harness

We also deliver a ColdBox application that is used for integration testing and so much more.  This is found under `/coldbox/test-harness` which also needs access to the `coolblog` datasource.

# Happy Coding and Contributing!
