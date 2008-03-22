<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	9/3/2007
Description :
	securityTest
----------------------------------------------------------------------->
<cfcomponent name="sessionstoragetest" extends="coldbox.system.extras.baseTest" output="false">

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
			var plugin = getController().getPlugin("cookiestorage");
			
			assertComponent(plugin);
			
		</cfscript>
	</cffunction>	
	
	<cffunction name="testMethods" access="public" returntype="void" output="false">
		<!--- Now test some events --->
		<cfscript>
			var plugin = getController().getPlugin("cookiestorage");
			var complex = structnew();
			
			complex.date = now();
			complex.id = createUUID();
			
			plugin.setVar("tester", 1);
			
			AssertTrue( plugin.exists("tester") ,"Test set & Exists");
			AssertEqualsNumber(1, plugin.getVar("tester"), "Get & Set Test");
			
			AssertFalse( plugin.exists("nothing") ,"False Assertion on exists" );
			plugin.deleteVar("tester");
			AssertFalse( plugin.getVar("tester").length() ,"Remove & Exists for tester simple");
			
			plugin.setVar("tester", complex );
			AssertTrue( plugin.exists("tester") ,"Test Complex set & Exists");
			
			plugin.deleteVar("tester");
			AssertFalse( plugin.getVar("tester").length() ,"Remove & Exists for complex");
			
		</cfscript>
	</cffunction>
		
	
</cfcomponent>