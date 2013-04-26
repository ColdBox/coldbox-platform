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
		mockController
			.$("getSetting").$args("RBundles").$results( structnew() )
			.$("getSetting").$args("DefaultLocale").$results( "en_US" )
			.$("getSetting").$args("DefaultResourceBundle").$results( "" )
			.$("getSetting").$args("UnknownTranslation").$results( "" )
			.$("settingExists", true)
			.$("getSetting").$args("RBundles").$results( {} )
			.$("getAppRootPath", expandPath("/coldbox/testharness"));

		plugin.init( mockController );
		plugin.$("getFWLocale", "en_US");
		plugin.loadBundle( rbFile=expandPath("/coldbox/testing/resources/main") );
	}

	function testResourceReplacements(){
		r = plugin.getResource(resource="testrep", values=[ "luis", "test" ]);	
		debug( r );
		assertEquals( "Hello my name is luis and test", r );
	}
</cfscript>
</cfcomponent>