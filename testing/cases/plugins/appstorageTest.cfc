<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	9/3/2007
Description :
	securityTest
----------------------------------------------------------------------->
<cfcomponent name="appstoragetest" extends="coldbox.system.testing.BaseTestCase" output="false">

	<cffunction name="setUp" returntype="void" access="public" output="false">
		<cfscript>
		//Setup ColdBox Mappings For this Test
		setAppMapping("/coldbox/testharness");
		setConfigMapping(ExpandPath(instance.AppMapping & "/config/coldbox.xml.cfm"));
		//Call the super setup method to setup the app.
		super.setup();
		</cfscript>
	</cffunction>
	
	<cffunction name="testPlugin" access="public" returntype="void" output="false">
		<!--- Now test some events --->
		<cfscript>
			var plugin = getController().getPlugin("ApplicationStorage");
			assertTrue( isStruct(plugin.getStorage()), "Application storage check");
			
		</cfscript>
	</cffunction>	
	
	<cffunction name="testMethods" access="public" returntype="void" output="false">
		<!--- Now test some events --->
		<cfscript>
			var plugin = getController().getPlugin("ApplicationStorage");
			
			plugin.setVar("tester", 1);
			
			AssertTrue( plugin.exists("tester") ,"Test set & Exists");
			AssertEquals(1, plugin.getVar("tester"), "Get & Set Test");
			
			AssertFalse( plugin.exists("nothing") ,"False Assertion on exists" );
			
			plugin.deleteVar("tester");
			AssertFalse( plugin.exists("tester") ,"Remove & Exists");
			
			plugin.setVar("tester", 1);
			plugin.setVar("tester2", now());
			
			plugin.clearAll();
			AssertTrue( structISEmpty(application.cbStorage), "Clear & Test" );
		</cfscript>
	</cffunction>
	
	<!--- tearDown --->
	<cffunction name="tearDown" output="false" access="public" returntype="void" hint="">
		<cfscript>
		structDelete(application,"cbStorage");
		</cfscript>
	</cffunction>
	
	
</cfcomponent>