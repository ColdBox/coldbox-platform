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
	this.timezone 			= "UTC";
	this.enableNullSupport = shouldEnableFullNullSupport();

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
		// New ColdBox Virtual Application Starter
		request.coldBoxVirtualApp = new coldbox.system.testing.VirtualApp( appMapping = "/cbTestHarness" );

		// If hitting the runner or specs, prep our virtual app and database
		if ( getBaseTemplatePath().replace( expandPath( "/tests" ), "" ).reFindNoCase( "(runner|specs)" ) ) {
			request.coldBoxVirtualApp.startup(  );
		}

		// ORM Reload for fresh results
		if( structKeyExists( url, "fwreinit" ) ){
			if( structKeyExists( server, "lucee" ) ){
				pagePoolClear();
			}
			ormReload();
			request.coldBoxVirtualApp.restart();
		}

		return true;
	}

	public void function onRequestEnd( required targetPage ) {
		request.coldBoxVirtualApp.shutdown();
	}

	private boolean function shouldEnableFullNullSupport() {
        var system = createObject( "java", "java.lang.System" );
        var value = system.getEnv( "FULL_NULL" );
		writedump( var = "FULL NULL enabled: #yesNoFormat( isNull( value ) ? false : !!value )#", output = "console" );
        return isNull( value ) ? false : !!value;
    }

}
