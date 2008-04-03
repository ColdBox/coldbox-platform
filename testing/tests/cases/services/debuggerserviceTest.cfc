<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date        :	September 3, 2007
Description :
	debugger service tests

Modification History:
01/18/2007 - Created
----------------------------------------------------------------------->
<cfcomponent name="debuggerserviceTest" extends="coldbox.system.extras.testing.baseTest" output="false">

	<cffunction name="setUp" returntype="void" access="private" output="false">
		<cfscript>
		//Setup ColdBox Mappings For this Test
		setAppMapping("/coldbox");
		setConfigMapping(ExpandPath(instance.AppMapping & "/config/coldbox.xml.cfm"));
		//Call the super setup method to setup the app.
		super.setup();
		</cfscript>
	</cffunction>
	
	<cffunction name="testDebugModes" access="public" returntype="void" output="false">
		<cfscript>
		var service = getController().getDebuggerService();
		var cookieName = "coldbox_debugmode_#getController().getApphash()#";
		
		//set test
		service.setDebugMode(true);
		AssertTrue( cookie[cookieName] , "Set Tests");
		//get test for true
		AssertTrue( service.getDebugMode(), "Get Test to true" );
		
		//set to false
		service.setDebugMode(false);
		AssertFalse( service.getDebugMode(), "Test after set to false");
		
		</cfscript>
	</cffunction>
	
	<cffunction name="testRenderDebugLog" access="public" returntype="void" output="false">
		<cfscript>
		var service = getController().getDebuggerService();
		var debugLog = service.renderDebugLog();
		
		assertSimpleValue(debugLog);		
		</cfscript>
	</cffunction>
	
	<cffunction name="testRenderCachePanel" access="public" returntype="void" output="false">
		<cfscript>
		var service = getController().getDebuggerService();
		var cachePanel = service.renderCachePanel();
		
		assertSimpleValue(cachePanel);		
		</cfscript>
	</cffunction>
	
	
</cfcomponent>