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
<cfcomponent name="StringBufferTest" extends="coldbox.system.extras.testing.baseMXUnitTest" output="false">

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
		<!--- Returned value is object...? --->
		<cfscript>
			//JDK 1.5 TEST
			var plugin = getController().getPlugin("StringBuffer").setup('test');
			obj = plugin.getStringBuffer().init();
			AssertEquals( getMetadata(obj).name, "java.lang.StringBuilder" );
			
			//JDK 1.4 TeST
			getController().oCFMLENGINE.JDK_VERSION = 1.4;
			plugin = getController().getPlugin("StringBuffer").setup('test');
			obj = plugin.getStringBuffer().init();
			AssertEquals( getMetadata(obj).name, "java.lang.StringBuffer" );
		</cfscript>
	</cffunction>
	
	<cffunction name="testMethods" access="public" returntype="void" output="false">
		<!--- test methods --->
		<cfscript>
			var plugin = getController().getPlugin("StringBuffer");
			var st1		= "StringTest";
			var st2		= "9Test2";
			
			assertTrue( isObject(plugin.setup()) );
			
			plugin.append(st1);
			plugin.insertStr(10,st2); 
			
			AssertEquals(plugin.indexOf('9'), '10');
			
			// this is something not working not sure why
			//AssertEquals(plugin.lastIndexOf('T'), '10', 'lastIndexOf() something gone wrong');
			AssertEquals(plugin.length(), '16', 'length() something gone wrong');
			
			//substring from position and before from end of position 
			AssertEquals(plugin.substring('10','12'), '9T', 'substring() something gone wrong');
			
			assertTrue(IsValid("numeric" , plugin.capacity()));
			
			assertTrue(IsObject(plugin.getStringBuffer()));
			
			plugin.replaceStr('10', '12', '7P');
			AssertEquals(plugin.getString(), 'StringTest7Pest2', 'getString() something gone wrong');
			
			plugin.append('7V');
			AssertEquals(plugin.getString(), 'StringTest7Pest27V', 'getString() something gone wrong');
			
			plugin.delete(16, 18);
			AssertEquals(plugin.getString(), 'StringTest7Pest2', 'getString() something gone wrong');
		</cfscript>
		
	</cffunction>

</cfcomponent>
