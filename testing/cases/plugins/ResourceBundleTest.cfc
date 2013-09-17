<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
----------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.testing.BasePluginTest" plugin="coldbox.system.plugins.ResourceBundle">
<cfscript>

	function setup(){
		super.setup();

		// Mocks
		mocki18n =  getMockBox().createEmptyMock( "coldbox.system.plugins.i18n" );
		mockLogger.$("canDebug", false);
		mockController
			.$("getSetting").$args("RBundles").$results( structnew() )
			.$("getSetting").$args("DefaultLocale").$results( "en_US" )
			.$("getSetting").$args("DefaultResourceBundle").$results( "" )
			.$("getSetting").$args("UnknownTranslation").$results( "**TEST**" )
			.$("settingExists", true)
			.$("getAppRootPath", expandPath("/coldbox/testharness") );

		plugin.init( mockController );
		plugin.$("getFWLocale", "en_US");
		plugin.loadBundle( rbFile=expandPath("/coldbox/testing/resources/main") );
	}

	function testLoadBundle(){
		plugin.loadBundle( rbFile = expandPath("/coldbox/testing/resources/main") );
		assertTrue( structCount( plugin.getBundles() ) );	
	}

	function testgetResourceBundle(){
		bundle = plugin.getResourceBundle( rbFile = expandPath("/coldbox/testing/resources/main"), rbLocale="es_SV" );
		//debug( bundle );
		assertTrue( structCount( bundle ) );
		assertTrue( structKeyExists( bundle, "helloworld" ) );

		bundle = plugin.getResourceBundle( rbFile = expandPath("/coldbox/testing/resources/main") );
		//debug( bundle );
		assertTrue( structCount( bundle ) );
		assertTrue( structKeyExists( bundle, "helloworld" ) );
	}

	function testInvalidgetResourceBundle(){
		expectException( "ResourceBundle.InvalidBundlePath" );
		plugin.getResourceBundle( rbFile = "/coldbox/testing/main" );
	}

	function testResourceReplacements(){
		r = plugin.getResource(resource="testrep", values=[ "luis", "test" ]);	
		debug( r );
		assertEquals( "Hello my name is luis and test", r );
		
		r = plugin.getResource(resource="testrepByKey", values={name="luis majano", quote="I am amazing!"});	
		debug( r );
		assertEquals( "Hello my name is luis majano and I am amazing!", r );
	}

	function testGetResource(){
		r = plugin.getResource(resource="testrep", values=[ "luis", "test" ]);	
		assertEquals( "Hello my name is luis and test", r );
		
		r = plugin.getResource( resource = "invalid" );
		assertEquals( "**TEST** key: invalid", r );

		r = plugin.getResource( resource = "invalid", default="invalid" );
		assertEquals( "invalid", r );
		
	}

	function testInvalidGetRBString(){
		expectException( "ResourceBundle.FileNotFoundException" );
		r = plugin.getRBString(rbFile=expandPath( "/coldbox/testing/resources" ), rbKey="");
	}

	function testGetRBString(){
		r = plugin.getRBString(rbFile=expandPath( "/coldbox/testing/resources/main" ), rbKey="helloworld");
		assertTrue( len( r ) );

		r = plugin.getRBString(rbFile=expandPath( "/coldbox/testing/resources/main" ), rbKey="invaliddude", default="Found");
		assertEquals( "Found", r );
	}

	function testGetRBKeys(){
		a = plugin.getRBKeys( rbFile=expandPath( "/coldbox/testing/resources/main" ) );
		assertTrue( arrayLen( a ) );
	}

	function testGetVersion(){
		a = plugin.getVersion();
		assertEquals( a.pluginVersion, plugin.getPluginVersion() );
	}

	function testVerifyPattern(){
		r = plugin.verifyPattern( "At {1,time} on {1,date}, there was {2} on planet {0,number,integer}." );
		assertTrue( r );
	}
</cfscript>
</cfcomponent>