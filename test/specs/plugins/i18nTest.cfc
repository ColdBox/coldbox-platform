<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
----------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.testing.BasePluginTest" plugin="coldbox.system.plugins.i18n">
<cfscript>

	function setup(){
		super.setup();

		// Mocks
		mockRB =  getMockBox().createEmptyMock( "coldbox.system.plugins.ResourceBundle" )
			.$("loadBundle");
		mockController.$("getPlugin", mockRB )
			.$("getSetting").$args("LocaleStorage").$results( "session" )
			.$("getSetting").$args("DefaultLocale").$results( "en_US" )
			.$("getSetting").$args("DefaultResourceBundle").$results( "" )
			.$("settingExists", true)
			.$("getSetting").$args("RBundles").$results( {} );

		plugin.init( mockController );
		plugin.init_i18N( rblocale = "en_US", rbFile = "" );
	}

	function testgetSetfwLocale(){
		assertEquals( "en_US", plugin.getFWLocale() );
		plugin.setFWLocale( "es_SV" );
		assertEquals( "es_SV", plugin.getFWLocale() );
	}

	function testisValidLocale(){
		assertTrue( plugin.isValidLocale( "en_US" ) );
		assertFalse( plugin.isValidLocale( "ee" ) );
	}

	function testLocaleMethods(){
		assertEquals( "en_US", plugin.getFWLocale() );
		assertEquals( "English (United States)", plugin.getFWLocaleDisplay() );
		assertEquals( "united states", plugin.getFWCountry() );
		assertEquals( "US", plugin.getFWCountryCode() );
		assertEquals( "USA", plugin.getFWISO3CountryCode() );
		assertEquals( "English", plugin.getFWLanguage() );
		assertEquals( "en", plugin.getFWLanguageCode() );
		assertEquals( "eng", plugin.getFWISO3LanguageCode() );
	}
</cfscript>
</cfcomponent>