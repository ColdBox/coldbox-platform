<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author      :	Sana Ullah
Date        :	April 04, 2008
Description :
	timerTest
----------------------------------------------------------------------->
<cfcomponent name="timerTest" extends="coldbox.system.testing.BaseTestCase" output="false">

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
		<!--- Now test is returned value is object --->
		<cfscript>
			var plugin = getController().getPlugin("Timer");

			AssertTrue( isObject(plugin) );
		</cfscript>
	</cffunction>
	
	<cffunction name="testMethods" access="public" returntype="void" output="false">
		<!--- test methods --->
		<cfscript>
			var plugin    = getController().getPlugin("Timer");
			var Utilities = getController().getPlugin("Utilities");
			plugin.start('t1'); 
			
			Utilities.sleeper(1000);
			
			plugin.logTime('t2', '3000');
			
			Utilities.sleeper(1000);
			
			plugin.stop('t1'); 
			
			assertTrue(IsQuery(plugin.getTimerScope()));
		</cfscript>
	</cffunction>

</cfcomponent>
