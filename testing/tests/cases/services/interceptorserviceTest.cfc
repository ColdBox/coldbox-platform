<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date        :	September 3, 2007
Description :
	plugin service test cases.

Modification History:
01/18/2007 - Created
----------------------------------------------------------------------->
<cfcomponent name="interceptorserviceTest" extends="coldbox.system.extras.testing.baseTest" output="false">

	<cffunction name="setUp" returntype="void" access="private" output="false">
		<cfscript>
		//Setup ColdBox Mappings For this Test
		setAppMapping("/coldbox");
		setConfigMapping(ExpandPath(instance.AppMapping & "/config/coldbox.xml.cfm"));
		//Call the super setup method to setup the app.
		super.setup();
		</cfscript>
	</cffunction>
	
	<cffunction name="testInterceptionPoints" access="public" returntype="void" output="false">
		<cfscript>
		var service = getController().getInterceptorService();
		
		//test registration again
		AssertTrue( listLen(service.getInterceptionPoints()) gt 0 );
		
		</cfscript>
	</cffunction>
	
	<cffunction name="testregisterInterceptors" access="public" returntype="void" output="false">
		<cfscript>
		var service = getController().getInterceptorService();
		var states = "";
		
		//test registration again
		service.registerInterceptors();
		states = service.getinterceptionStates();
		AssertFalse( structisEmpty(states), "registration failed");
		
		</cfscript>
	</cffunction>
	
	<cffunction name="testSimpleProcessInterception" access="public" returntype="void" output="false">
		<cfscript>
		var service = getController().getInterceptorService();
		
		service.processState("preProcess");
		
		</cfscript>
	</cffunction>
	
	<cffunction name="testProcessInterception" access="public" returntype="void" output="false">
		<cfscript>
		var service = getController().getInterceptorService();
		var md = structnew();
		
		md.test = "UNIT TESTING";
		md.today = now();
		
		service.processState("preProcess",md);
		
		</cfscript>
	</cffunction>
	
	<cffunction name="testProcessInvalidInterception" access="public" returntype="void" output="false">
		<cfscript>
		var service = getController().getInterceptorService();
		var md = structnew();
		
		try{
			service.processState("nada loco",md);
		}
		catch("Framework.InterceptorService.InvalidInterceptionState" e){
			AssertTrue(true);
		}
		catch(Any e){
			fail(e.message & e.detail);
		}
		</cfscript>
	</cffunction>
	
	
	
</cfcomponent>