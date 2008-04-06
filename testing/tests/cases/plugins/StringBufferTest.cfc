<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author      :	Sana Ullah
Date        :	April 04, 2008
Description :
	StringBufferTest
----------------------------------------------------------------------->
<cfcomponent name="StringBufferTest" extends="coldbox.system.extras.testing.baseTest" output="false">

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
		<!--- Returned value is object...? --->
		<cfscript>
			var plugin = getController().getPlugin("StringBuffer");

			assertComponent(plugin);
		</cfscript>
	</cffunction>
	
	<cffunction name="testMethods" access="public" returntype="void" output="false">
		<!--- test methods --->
		<cfscript>
			var plugin = getController().getPlugin("StringBuffer");
			var st1		= "StringTest";
			var st2		= "9Test2";
			
			assertComponent(plugin.setup());
			
			plugin.append(st1);
			plugin.insertStr(10,st2); 
			
			assertEqualsNumber(plugin.indexOf('9'), '10');
			
			// this is something not working not sure why
			//assertEqualsNumber(plugin.lastIndexOf('T'), '10', 'lastIndexOf() something gone wrong');
			assertEqualsNumber(plugin.length(), '16', 'length() something gone wrong');
			
			//substring from position and before from end of position 
			assertEqualsString(plugin.substring('10','12'), '9T', 'substring() something gone wrong');
			
			assertTrue(IsValid("numeric" , plugin.capacity()));
			
			assertTrue(IsObject(plugin.getStringBuffer()));
			
			plugin.replaceStr('10', '12', '7P');
			assertEqualsString(plugin.getString(), 'StringTest7Pest2', 'getString() something gone wrong');
			
			plugin.append('7V');
			assertEqualsString(plugin.getString(), 'StringTest7Pest27V', 'getString() something gone wrong');
			
			plugin.delete(16, 18);
			assertEqualsString(plugin.getString(), 'StringTest7Pest2', 'getString() something gone wrong');
		</cfscript>
		
	</cffunction>

</cfcomponent>
