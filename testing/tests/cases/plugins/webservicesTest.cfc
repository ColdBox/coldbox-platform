<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author      :	Sana Ullah
Date        :	April 03, 2008
Description :
	webservicesTest
----------------------------------------------------------------------->
<cfcomponent name="webservicesTest" extends="coldbox.system.extras.testing.baseTest" output="false">

	<cffunction name="setUp" returntype="void" access="private" output="false">
		<cfscript>
		//Setup ColdBox Mappings For this Test
		setAppMapping("/coldbox");
		setConfigMapping(ExpandPath(instance.AppMapping & "/config/coldbox.xml.cfm"));
		//Call the super setup method to setup the app.
		super.setup();
		</cfscript>
	</cffunction>
	
	<cffunction name="testPlugin" access="public" returntype="void" output="false">
		<!--- Now test some events --->
		<cfscript>
			var plugin = getController().getPlugin("webservices");

			assertComponent(plugin);
		</cfscript>
	</cffunction>
	
	<cffunction name="testgetWS" access="public" returntype="void" output="false">
		<!--- Now test getWS method --->
		<cfscript>
			var plugin = getController().getPlugin("webservices");
			
			assertEqualsString(plugin.getWS('AnotherTestWS'),'http://www.coldboxframework.com/distribution/updatews.cfc?wsdl','Returned url is different');			
		</cfscript>
	</cffunction>

	<cffunction name="testgetWSobj" access="public" returntype="void" output="false">
		<!--- Now test getWSobj method --->
		<cfscript>
			var plugin = getController().getPlugin("webservices");
			
			assertTrue(IsObject(plugin.getWSobj('AnotherTestWS')),'Returned values is not a object');			
		</cfscript>
	</cffunction>
	
	<cffunction name="testgetrefreshWS" access="public" returntype="void" output="false">
		<!--- Now test refreshWS method --->
		<cfscript>
			var plugin = getController().getPlugin("webservices");
			
			plugin.refreshWS('AnotherTestWS');			
		</cfscript>
	</cffunction>
	
</cfcomponent>
