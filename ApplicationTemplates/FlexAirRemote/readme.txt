********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Welcome to the ColdBox Application Template For Remote Applications

This is a skeleton for what we think can be a great template for building
enhanced remote monitor applications.  This template gives you a separate folder for the 
actual coldbox monitor so you can monitor your remote calls and application.

If you are building a hybrid of MVC with remote GUI's, we recommend using the 
normal Application Template.

******************************************************************************
Sample Directory Structure For Your Application
******************************************************************************
-ApplicationFolder
	- config (Your config folder, where your config.xml.cfm resides) REQUIRED
	- interceptors (Where you can put your interceptors) OPTIONAL
	- model (Your domain model objects)
	- monitor (Your Remote Monitor)
	- plugins (Your custom plugins by convention, can be organized into folders) OPTIONAL
	- remote (Where all your remote proxies go)
	- test (Your unit testing folder)
	
******************************************************************************
QUICK START
******************************************************************************
How to start? 

1) Start off by copying the ApplicationTemplateRemote folder to your web root and
   naming it to something you want. Remember that you need to have installed
   ColdBox first. Copy the coldbox distribution directory to the
   web root. /WEBROOT/coldbox

2) Open the config/coldbox.xml.cfm file and change the AppName setting to whatever you want.
    
   You can read the coldbox.xml guide in order to understand all the variables in this file
   and adjust if needed.  
   
   Also YOU HAVE TO SET the AppMapping setting.  THis is the location of your application
   from the webroot.  So if your application is reachable via the webroot as 
   Ex:
   http://mytest.com/apps/myApp
   AppMapping = apps/MyApp or /apps/MyApp
   
   So if your app is in the root, the AppMapping is blank. 

3) Optional step, skip to step 4.
   If you need to change the name property of your Application.cfc
   Open the file Application.cfc and change the name
   property to whatever you want it to be. Remember that every application will need
   its own name property. Also, please note that ColdBox uses the application
   scope as a requirement. 
   
   - The client scope needs to be enabled if using the clientstorage plugin.
   - The messagebox plugin can use the session or client scope. By default it uses session.

4) Now that you have completed editing your config and Application.cfc, you are ready to see 
   results. Point your web browser to your app's monitor folder.

Now get your mind out of procedural code, dive into OO Programming. Please make sure
to fasten your seat belts, it WILL GET BUMPY!!
