/**
* Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
* ---
*/
component{

	this.name               = "ColdBox Testing Harness" & hash( getCurrentTemplatePath() );
	this.sessionManagement  = true;
	this.setClientCookies   = true;
	this.clientManagement   = true;
	this.sessionTimeout     = createTimeSpan( 0, 0, 10, 0 );
	this.applicationTimeout = createTimeSpan( 0, 0, 10, 0 );

	// Turn on/off white space management
	this.whiteSpaceManagement = "smart";

	// setup test path
	this.mappings[ "/tests" ] = getDirectoryFromPath( getCurrentTemplatePath() );
	// setup root path
	rootPath = REReplaceNoCase( this.mappings[ "/tests" ], "tests(\\|/)", "" );
	// ColdBox Root path
	this.mappings[ "/coldbox" ] 		= rootPath;
	// TestBox
	this.mappings[ "/testbox" ] 		= rootPath & "testbox";
	// harness path
	this.mappings[ "/cbtestharness" ] 	= rootPath & "test-harness";

	// COLDBOX STATIC PROPERTY, DO NOT CHANGE UNLESS THIS IS NOT THE ROOT OF YOUR COLDBOX APP
	COLDBOX_APP_ROOT_PATH = this.mappings[ "/cbtestharness" ];

	// Core Application.cfc mixins - ORM Settings, etc
	include "../test-harness/config/ApplicationMixins.cfm";

	public boolean function onRequestStart( targetPage ){
		// Set a high timeout for long running tests
		setting requestTimeout="9999";

		// ORM Reload for fresh results
		if( structKeyExists( url, "fwreinit" ) ){
			if( structKeyExists( server, "lucee" ) ){
				pagePoolClear();
			}
			ormReload();
		}

		return true;
	}

	public void function onRequestEnd( required targetPage ) {

		thread name="testbox-shutdown" {
			if( !isNull( application.cbController ) ){
				application.cbController.getLoaderService().processShutdown();
			}

			structDelete( application, "cbController" );
			structDelete( application, "wirebox" );
		}

	}

}