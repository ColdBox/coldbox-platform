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
<cfcomponent name="sessionstoragetest" extends="coldbox.system.extras.testing.baseMXUnitTest" output="false">

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
			var plugin = getController().getPlugin("JavaLoader");
			
			AssertTrue( isObject(plugin) );
			
		</cfscript>
	</cffunction>	
	
	<cffunction name="testMethods" access="public" returntype="void" output="false">
		<!--- Now test some events --->
		<cfscript>
			var plugin = getController().getPlugin("JavaLoader");
			var testJar = expandPath('/coldbox/testing/tests/resources/helloworld.jar');
			var myClass = "";
			
			//Load it
			plugin.setup( listToArray(testjar) );
			AssertTrue( structKeyExists(server, plugin.GETSTATICIDKEY()) , "Javaloader in scope");
			
			/* Create */
			try{
				myClass = plugin.create("HelloWorld").init();
			}
			catch(Any e){
				Fail(e.toString());
			}
			
			AssertEquals( myClass.hello(), "Hello World", "Saying Hello");
			
		</cfscript>
	</cffunction>
	
</cfcomponent>