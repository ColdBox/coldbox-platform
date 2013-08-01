﻿<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	9/3/2007
Description :
	securityTest
----------------------------------------------------------------------->
<cfcomponent plugin="coldbox.system.plugins.CookieStorage" extends="coldbox.system.testing.BasePluginTest">

	<cffunction name="setUp" returntype="void" access="public" output="false">
		<cfscript>
		super.setup();
		
		//mocks
		mockController.$("getCFMLEngine", getMockBox().createEmptyMock("coldbox.system.core.cf.CFMLEngine").$("getEngine","ADOBE"));
		plugin.$("settingExists",false).init( mockController );
		</cfscript>
	</cffunction>
	
	<cffunction name="testMethods" access="public" returntype="void" output="false">
		<!--- Now test some events --->
		<cfscript>
			var complex = structnew();
			
			complex.date = now();
			complex.id = createUUID();
			
			plugin.setVar("tester", 1);
			
			AssertTrue( plugin.exists("tester") ,"Test set & Exists");
			AssertEquals(1, plugin.getVar("tester"), "Get & Set Test");
			
			AssertFalse( plugin.exists("nothing") ,"False Assertion on exists" );
			plugin.deleteVar("tester");
			debug(cookie);
			
			AssertFalse( plugin.getVar("tester").length() ,"Remove & Exists for tester simple");
			plugin.setVar("tester", complex );
			AssertTrue( plugin.exists("tester") ,"Test Complex set & Exists");
			debug(cookie);
			r = plugin.getVar("tester");
			assertTrue( isStruct( r ) );
			assertEquals( complex.id, r.id );
			
			plugin.deleteVar("tester");
			AssertFalse( plugin.getVar("tester").length() ,"Remove & Exists for complex");
			
		</cfscript>
	</cffunction>
	
	<cffunction name="testWithEncryption" access="public" returntype="void" output="false">
		<!--- Now test some events --->
		<cfscript>
			var complex = structnew();
			
			complex.date = now();
			complex.id = createUUID();
			
			/* set Encryption */
			plugin.setEncryption(true);
			plugin.setEncryptionKey('My#createUUID()#-Unit Test Key');
			
			/* Set */
			plugin.setVar("tester", 1);
			AssertTrue( plugin.exists("tester") ,"Test set & Exists");
			AssertEquals(1, plugin.getVar("tester"), "Get & Set Test");
			
			AssertFalse( plugin.exists("nothing") ,"False Assertion on exists" );
			plugin.deleteVar("tester");
			AssertFalse( plugin.getVar("tester").length() ,"Remove & Exists for tester simple");
			
			plugin.setVar("tester", complex );
			AssertTrue( plugin.exists("tester") ,"Test Complex set & Exists");
			
			plugin.deleteVar("tester");
			AssertFalse( plugin.getVar("tester").length() ,"Remove & Exists for complex");
		
		</cfscript>
	</cffunction>
	
</cfcomponent>