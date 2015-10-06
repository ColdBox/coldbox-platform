# Welcome to the ColdBox Test Suite

```
   ____     ____     _____       ______     ______      ____     __     __  
  / ___)   / __ \   (_   _)     (_  __ \   (_   _ \    / __ \   (_ \   / _) 
 / /      / /  \ \    | |         ) ) \ \    ) (_) )  / /  \ \    \ \_/ /   
( (      ( ()  () )   | |        ( (   ) )   \   _/  ( ()  () )    \   /    
( (      ( ()  () )   | |   __    ) )  ) )   /  _ \  ( ()  () )    / _ \    
 \ \___   \ \__/ /  __| |___) )  / /__/ /   _) (_) )  \ \__/ /   _/ / \ \_  
  \____)   \____/   \________/  (______/   (______/    \____/   (__/   \__) 
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
We leverage **CommandBox** to build ColdBox and its libraries.  You can download it from our main website here: http://www.ortussolutions.com/products/commandbox.

### Install Dependencies
Once CommandBox is install go into the root of the project and type: `box install`. This will download all required dependencies and test dependencies for you.

### Startup Test Server
Startup the test server via the following command: `box server start`. This will startup a server that you can use for development, hacking and testing. 

> **Note:** The server will start in a specific port, make sure you take note of it.

### Create Testing Datasource

ColdBox requires a datasource connection in order to be able to provide testing capabilities for integration.  Please open the CFML administrator and create a datsource called **coolblog** and populate it with our SQL script that can be found here: `/coldbox/tests/resources/coolblog.sql`.

### Lucee Optional: `Default` Cache
If you are in the Lucee CFML engine, then you will need to register a `default` cache in the administrator so CacheBox can be tested.  

## Test Harness
We also deliver a ColdBox application that is used for integration testing and so much more.
This is found under `/coldbox/test-harness` which also needs access to the `coolblog` datasource.

#Happy Coding and Contributing!
