********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Welcome to the ColdBox Application Template

This is a skeleton for you to start a new ColdBox application or you can use the 
Application Generator included in the ColdBox Dashboard. Below is a sample
ColdBox application directory structure.  You need to follow this structure in order
for ColdBox to work via its conventions. You can also change the conventions using
the ColdBox Dashboard or the settings.xml

******************************************************************************
Sample Directory Structure For Your Application
******************************************************************************
-ApplicationFolder
	- config (Your config folder)
	- handlers (Your event handlers)
	- includes (Your include files if used)
	- interceptors (Where you can put your interceptors) 
	- layouts  (Your layouts) 
	- logs (Where your log files go, you can change this)
	- model (Where your model objects go) 
	- plugins (Your custom plugins by convention)
	- remote (Where your remote proxies go) 
	- test (Where your unit testing goes)
	- views (Your views)
	
******************************************************************************
QUICK START
******************************************************************************
How to start? 

1) Start off by copying the ApplicationTemplate folder to your web root and
   naming it to something you want. Remember that you need to have installed
   ColdBox first. Copy the coldbox distribution directory to the
   web root. /WEBROOT/coldbox

2) Open the config/coldbox.xml.cfm file and change the AppName setting to whatever you want.
    
   You can read the coldbox.xml guide in order to understand all the variables in this file
   and adjust if needed.  

3) Optional step, skip to step 4.
   If you need to change the name property of your Application.cfc or
   Application.cfm template.
   Open the file Application.cfc or Application.cfm and change the name
   property to whatever you want it to be. Remember that every application will need
   its own name property. Also, please note that ColdBox uses the application
   scope as a requirement. 
   
   - The client scope needs to be enabled if using the clientstorage plugin.
   - The messagebox plugin can use the session or client scope. By default it uses session.

4) Now that you have completed editing your config and Application.cfc, you are ready to see 
   results. Point your web browser to your application folder and you will see a message display:

OPTIONAL: Skip all the steps, just fire up the ColdBox Dashboard and run the Application Generator.

UNIT TESTS: You will also find the unit tests ready for the event handlers inside the handlers
            directory under the name tests. You will find a test suite and two test cases.

Welcome to Coldbox!!

Now get your mind out of procedural code, dive into OO Programming. Please make sure
to fasten your seat belts, it WILL GET BUMPY!!

******************************************************************************
PRETTY URLS/SES SUPPORT
******************************************************************************
ColdBox provides you with pretty URL support or SES.  The configuration file already has
the ses interceptor declared and a sample routing configuration file has been created for 
you with the three most common routes to get you started.  However, out of the box,
the interceptor will use 'index.cfm/handler/action' to route requests. If you would
like to eliminate the 'index.cfm' then please use the provided .htaccess or IsapiRewrite.ini
files (If your web server supports it).

******************************************************************************
COLDBOX PROXY
******************************************************************************
The ColdBox proxy is used as a means to adapt the ColdBox event driven framework
to a Flex/AIR application. You basically forward requests to the proxy with an
associative array of parameters: The event to execute and any other parameters.
The framework will then process the event as a ColdBox event. You can then treat
your ColdBox application as a model application. You can use the debugger panel, etc
to monitor your flex application.

REQUIREMENTS:
1) You will not to create the setting: AppMapping
   You need to do this in order for the framework to correctly create the instantiation
   paths.
2) Your Imagination!!