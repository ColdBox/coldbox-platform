********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Unit Testing for Event Handlers

The following test cases have been created for testing of event handlers, please
note that the controller created is the ColdBox's testcontroller.

The code speaks for itself. Just make sure you tests inherit from the base test
according to testing framework. 

Then create a setup method that follows the following pattern:

<cffunction name="setUp" returntype="void" access="private">
	<cfscript>
	//Persist Framework in application scope for test.
	THIS.PERSIST_FRAMEWORK = true or false;
	
	//Setup ColdBox Mappings For this Test
	setAppMapping("/applications/coldbox/ApplicationTemplate");
	setConfigMapping(ExpandPath(instance.AppMapping & "/config/config.xml.cfm"));
		
	//Call the super setup method to setup the app.
	super.setup();
		
	//EXECUTE THE APPLICATION START HANDLER: UNCOMMENT IF NEEDED AND FILL IT OUT.
	//getController().runEvent("ehMain.onAppInit");

	//EXECUTE THE ON REQUEST START HANDLER: UNCOMMENT IF NEEDED AND FILL IT OUT
	//getController().runEvent("ehMain.onRequestStart");
	</cfscript>
</cffunction>


Structure:
-integration
	- cfcunit - cfcunit enabled tests
	- mxunit - mxunit enabled tests
 		- GeneralTest.cfc - The test case for the General.cfc handler
 		- MaintTest.cfc - The test case for the Main.cfc handler
 -unit
 	- For all your unit test cases.
 -mocks
 	- For any mock testing or mock objects.


SPECIAL CONSIDERATIONS:
Make sure that if you are using any relative paths in your application, that they become
absolute. This is because the unit testing occurs inside of the unit testing framework
which is outside of this app root. So please remember for unit testing to use absolute
mappings on files or references. I recommend also using a test configuration file.