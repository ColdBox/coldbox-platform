<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author      :	Sana Ullah
Date        :	Jan 13, 2009
Description :   Logger Plugin Test
----------------------------------------------------------------------->
<cfcomponent name="loggertest" extends="coldbox.system.extras.testing.baseMXUnitTest" output="false">

	<cffunction name="setUp" returntype="void" access="public" output="false">
		<cfscript>
		//Setup ColdBox Mappings For this Test
		setAppMapping("/coldbox/testharness");
		setConfigMapping(ExpandPath(instance.AppMapping & "/config/coldbox.xml.cfm"));
		//Call the super setup method to setup the app.
		super.setup();
		</cfscript>
	</cffunction>
	
	<cffunction name="testAPlugin" access="public" returntype="void" output="false">
		<!--- Now test some events --->
		<cfscript>
			var plugin = getController().getPlugin("logger");
			
			AssertTrue( isObject(plugin) );
			
		</cfscript>
	</cffunction>	
	
	<cffunction name="testMethods" access="public" returntype="void" output="false">
		<!--- Now test some events --->
		<cfscript>
			var plugin = getController().getPlugin("logger");
			
			AssertEquals(2, plugin.getlogLevel("tester"), "Log level --- Test");
			plugin.setlogLevel(4);
			AssertEquals(4, plugin.getlogLevel("tester"), "Log level --- Test");
			
			plugin.debug('The debug message to log');
			
			plugin.info('The message to log.');
			
			plugin.warn('The warning message to log');
			
			plugin.error('The error message to log');
			
			plugin.fatal('The fatal message to log');
			
			plugin.tracer('The tracer message to log');
			
			AssertEquals(4, plugin.getlogLevel("tester"), "Log level --- Test");
		</cfscript>
	</cffunction>
	
</cfcomponent>
