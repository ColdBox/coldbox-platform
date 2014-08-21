   ____     ____     _____       ______     ______      ____     __     __  
  / ___)   / __ \   (_   _)     (_  __ \   (_   _ \    / __ \   (_ \   / _) 
 / /      / /  \ \    | |         ) ) \ \    ) (_) )  / /  \ \    \ \_/ /   
( (      ( ()  () )   | |        ( (   ) )   \   _/  ( ()  () )    \   /    
( (      ( ()  () )   | |   __    ) )  ) )   /  _ \  ( ()  () )    / _ \    
 \ \___   \ \__/ /  __| |___) )  / /__/ /   _) (_) )  \ \__/ /   _/ / \ \_  
  \____)   \____/   \________/  (______/   (______/    \____/   (__/   \__) 
     
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
HONOR GOES TO GOD ABOVE ALL
********************************************************************************
Because of His grace, this project exists. If you don't like this, then don't read it, its not for you.

"Therefore being justified by faith, we have peace with God through our Lord Jesus Christ:
By whom also we have access by faith into this grace wherein we stand, and rejoice in hope of the glory of God.
And not only so, but we glory in tribulations also: knowing that tribulation worketh patience;
And patience, experience; and experience, hope:
And hope maketh not ashamed; because the love of God is shed abroad in our hearts by the 
Holy Ghost which is given unto us. ." Romans 5:5

********************************************************************************
WELCOME TO THE COLDBOX TEST SUITES
********************************************************************************
This folder contains a full suite of BDD specs, load tests and much more.  Here are some
instructions on how to get the test suites to run in your development environment.

1) Datasource
You will require to create a datasource called: coolblog in any Database you like.
Then you can inflate our script to populate such database. This script can be found here:

/coldbox/tests/resources/coolblog.sql

This SQL script will populate the database with everything you need for some tests
that require database connectivity.

2) Test Harness
We also deliver a ColdBox application that is used for integration testing and so much more.
This is found under /coldbox/test-harness which also needs access to the "coolblog" datasource.

3) Webroot
The tests and integration links expect that the /coldbox folder be inside of a webroot, so you
can access it like so: http://localhost/coldbox/test-harness.
