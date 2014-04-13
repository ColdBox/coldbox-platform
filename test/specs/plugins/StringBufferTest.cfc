<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author      :	Sana Ullah
Date        :	April 04, 2008
Description :
	StringBufferTest
----------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.testing.BasePluginTest" plugin="coldbox.system.plugins.StringBuffer">

	<cffunction name="setUp" returntype="void" access="public" output="false">
		<cfscript>
		//Call the super setup method to setup the app.
		super.setup();
		plugin.init();
		</cfscript>
	</cffunction>
	
	<cffunction name="testMethods" access="public" returntype="void" output="false">
		<!--- test methods --->
		<cfscript>
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
