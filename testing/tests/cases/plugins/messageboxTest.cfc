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
			var plugin = getController().getPlugin("messagebox");
			
			AssertTrue( isObject(plugin) );
					
		</cfscript>
	</cffunction>	
	
	<cffunction name="testMethods" access="public" returntype="void" output="false">
		<!--- Now test some events --->
		<cfscript>
			var plugin = "";
			var messages = "";
			
			/* setting */
			getController().setSetting("messagebox_storage_scope","session");
			/* get Plugin */
			plugin = getController().getPlugin("messagebox");
			AssertEquals( plugin.getStorageScope(), "session", "Custom Storage");
			
			/* Set Message */
			plugin.setMessage("info","TestMessage");
			AssertEquals( plugin.getMessage().message, "TestMessage", "Set and Get.");
			AssertFalse( plugin.isEmpty(), "Empty Test");
			
			/* Append */
			plugin.append("pio");
			AssertEquals( plugin.getMessage().message, "TestMessagepio", "Append Test");
			
			/* Append an array */
			messages = "unit test";
			plugin.appendArray(listToArray(messages));
						
			/* Clear */
			plugin.clearMessage();
			AssertEquals( plugin.getMessage().message, "", "Clear first, then get test.");
			AssertTrue( plugin.isEmpty(), "Empty Test");
			
			/* Append on empty */
			plugin.append("pio");
			AssertEquals( plugin.getMessage().message, "pio", "Append on empty Test");
			plugin.clearMessage();
			
			/* Append on empty Array */
			messages = "unit test";
			plugin.appendArray(listToArray(messages));
			AssertEquals( plugin.getMessage().message, "unit test", "Append on Empty");
						
			
			/* Set Array Message */
			messages = "Hello, This is a test, Hello World";
			
			plugin.setMessage("info","",listToArray(messages) );
			AssertTrue( plugin.getMessage().message.length() neq 0," Array of messages set.");
			AssertFalse( plugin.isEmpty(), "Empty Test");
			
			/* Final Render */
			AssertTrue( plugin.renderit().length() neq 0, " Render message");
			
			/* Clear */
			plugin.clearMessage();
		</cfscript>
	</cffunction>
		
</cfcomponent>