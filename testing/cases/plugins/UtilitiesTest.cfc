<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author      :	Sana Ullah
Date        :	April 04, 2008
Description :
	UtilitiesTest
----------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.testing.BaseTestCase" appMapping="/coldbox/testharness">

	<cffunction name="setUp" returntype="void" access="public" output="false">
		<cfscript>
		//Call the super setup method to setup the app.
		super.setup();
		</cfscript>
	</cffunction>

	<cffunction name="testPlugin" access="public" returntype="void" output="false">
		<!--- Now test test plugin as a object --->
		<cfscript>
			var plugin = getController().getPlugin("Utilities");

			AssertTrue( isObject(plugin) );
		</cfscript>
	</cffunction>

	<cffunction name="testMethods" access="public" returntype="void" output="false">
		<!--- Now test test plugin as a object --->
		<cfscript>
			var plugin = getController().getPlugin("Utilities");
			var direactoryPath = ExpandPath('/coldbox/testing/resources');
			var sStruct	= structNew() ;
			var sString = "";
			var sObject = CreateObject("component","coldbox.testing.resources.test1");
			
			sStruct["1"] = "ColdBox";
			sStruct["2"] = "Great Toolkit";

			assertTrue(plugin.isCFUUID(CreateUUID()), 'The value is not CF UUID');
			
			assertTrue(plugin.IsEmail('test.sana@test1.yahoo.co.uk'), 'The value is not valid email');
			
			assertTrue(plugin.IsURL('http://test1.yahoo.co.uk'), 'The value is not valid URL');
			
			plugin.sleeper(500);
			
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
			
			plugin.getAbsolutePath(direactoryPath);
			
			//AssertEquals(plugin.readFile(direactoryPath & '\unittest.txt'), 'unitest-#chr(10)##chr(13)#unitest','Returned values are not equal');
			
			assertTrue(IsValid("date",plugin.FileLastModified(direactoryPath & '\unittest.txt')));
			
			assertTrue(IsValid("numeric",plugin.FileSize(direactoryPath & '\unittest.txt')));
			
			assertTrue(plugin.FileCanWrite(direactoryPath & '\unittest.txt'));
			
			assertTrue(plugin.FileCanRead(direactoryPath & '\unittest.txt'));
			
			assertTrue(plugin.isFile(direactoryPath & '\unittest.txt'));
			
			assertTrue(plugin.isDirectory(direactoryPath));
			
			AssertEquals(plugin.checkCharSet('iso-8859-1'),'iso-8859-1', 'checkCharSet() something gone wrong');
			
			AssertEquals(plugin.ripExtension('unittest.txt'),'unittest', 'ripExtension() something gone wrong');
			
			assertTrue(plugin.removeFile(direactoryPath & '\unittest.txt'));
			
			sString = plugin._serialize(sStruct);
		
			assertTrue(IsStruct(plugin._deserialize(sString)));
			
			plugin._serializeToFile( sStruct , direactoryPath & '\serialized.txt');
			
			assertTrue(IsStruct(plugin._deserializeFromFile(direactoryPath & '\serialized.txt')));
			
			assertTrue(plugin.removeFile(direactoryPath & '\serialized.txt'));
			// serialise component, its CF8
			if(not structKeyExists(server,"railo") ){
				plugin._serializeToFile( sObject , direactoryPath & '\serializedCFC.txt');
			
				assertTrue(IsObject(plugin._deserializeFromFile(direactoryPath & '\serializedCFC.txt')));
				assertTrue(plugin.removeFile(direactoryPath & '\serializedCFC.txt'));
			}
		</cfscript>
		
	</cffunction>

</cfcomponent>
