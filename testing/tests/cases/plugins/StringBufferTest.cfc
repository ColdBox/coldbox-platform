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
		<!--- Now test is returned value is object --->
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
			
			//assertEqualsNumber(plugin.indexOf('9T'), '10');
			
			//assertEqualsNumber(plugin.lastIndexOf('9T'), '10');
			assertEqualsNumber(plugin.length(), '16');
			assertEqualsString(plugin.substring('9','10'), '9T');
			
			asssertTrue(IsValid("numeric" , plugin.capacity()));
		</cfscript>
		
	</cffunction>

</cfcomponent>
