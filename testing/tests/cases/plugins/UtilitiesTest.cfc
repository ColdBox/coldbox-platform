<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author      :	Sana Ullah
Date        :	April 04, 2008
Description :
	UtilitiesTest
----------------------------------------------------------------------->
<cfcomponent name="UtilitiesTest" extends="coldbox.system.extras.testing.baseTest" output="false">

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
		<!--- Now test test plugin as a object --->
		<cfscript>
			var plugin = getController().getPlugin("Utilities");

			assertComponent(plugin);
		</cfscript>
	</cffunction>

	<cffunction name="testMethods" access="public" returntype="void" output="false">
		<!--- Now test test plugin as a object --->
		<cfscript>
			var plugin = getController().getPlugin("Utilities");
			var direactoryPath = ExpandPath('/applications/coldbox/testing/tests/resources');

			assertTrue(plugin.isCFUUID(CreateUUID()), 'The value is not CF UUID');
			
			assertTrue(plugin.IsEmail('test.sana@test1.yahoo.co.uk'), 'The value is not valid email');
			
			assertTrue(plugin.IsURL('http://test1.yahoo.co.uk'), 'The value is not valid URL');
			
			plugin.sleeper(500);
			
			assertTrue(IsArray(plugin.createArray('[a,b,c,d,e]')),'The value is not valid Array');
			
			assertTrue(IsStruct(plugin.createArray('{"key": "value" , "key2": "value"}')),'The value is not valid Structure');
			
			plugin.getOSFileSeparator();
			
			plugin.getOSName();
			
			plugin.getInetHost();
			
			plugin.getIPAddress();
			
			plugin.getJavaRuntime();
			
			plugin.getJavaVersion();
			
			plugin.getJVMfreeMemory();
			
			plugin.getJVMTotalMemory();
			
			plugin.createFile(direactoryPath & '\unittest.txt');

			plugin.saveFile(direactoryPath & '\unittest.txt', 'unitest-');
			
			plugin.appendFile(direactoryPath & '\unittest.txt', 'unitest');
			
			assertEqualsString(plugin.readFile(direactoryPath & '\unittest.txt'), 'unitest-#chr(10)##chr(13)#unitest','Returned values are not equal');
			
			plugin.FileLastModified(direactoryPath & '\unittest.txt');
			
			plugin.FileSize(direactoryPath & '\unittest.txt');
			
			assertTrue(plugin.FileCanWrite(direactoryPath & '\unittest.txt'));
			
			assertTrue(plugin.FileCanRead(direactoryPath & '\unittest.txt'));
			
			assertTrue(plugin.isFile(direactoryPath & '\unittest.txt'));
			
			assertTrue(plugin.isDirectory(direactoryPath));
			
			plugin.getAbsolutePath(direactoryPath);
			
			plugin.checkCharSet('UTF-8');
			
			assertEqualsString(plugin.ripExtension('unittest.txt'),'.txt');
			
			plugin.removeFile(direactoryPath & '\unittest.txt');
		</cfscript>
	</cffunction>

</cfcomponent>
