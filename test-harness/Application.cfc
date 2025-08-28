/**
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************
*/
component {

	// Application properties
	this.name               = "ColdBox Test Harness";
	this.sessionManagement  = true;
	this.sessionTimeout     = createTimespan( 0, 0, 30, 0 );
	this.setClientCookies   = true;
	this.timezone 			= "UTC";
	this.enableNullSupport = shouldEnableFullNullSupport();

	// Turn on/off remote cfc content whitespace
	this.suppressRemoteComponentContent = false;

	// COLDBOX STATIC PROPERTY, DO NOT CHANGE UNLESS THIS IS NOT THE ROOT OF YOUR COLDBOX APP
	COLDBOX_APP_ROOT_PATH = getDirectoryFromPath( getCurrentTemplatePath() );
	// The web server mapping to this application. Used for remote purposes or static purposes
	COLDBOX_APP_MAPPING   = "";
	// COLDBOX PROPERTIES
	COLDBOX_CONFIG_FILE   = "";
	// COLDBOX APPLICATION KEY OVERRIDE
	COLDBOX_APP_KEY       = "";
	COLDBOX_FAIL_FAST = true;
	COLDBOX_WEB_MAPPING = "test-harness";

	// JAVA INTEGRATION: JUST DROP JARS IN THE LIB FOLDER
	// You can add more paths or change the reload flag as well.
	this.javaSettings     = {
		loadPaths      : [ "lib" ],
		reloadOnChange : false
	};

	// Mappings
	rootPath = reReplaceNoCase(
		COLDBOX_APP_ROOT_PATH,
		"test-harness(\\|/)",
		""
	);

	// ColdBox Root path
	this.mappings[ "/coldbox" ]       = rootPath;
	// Test Harness Path
	this.mappings[ "/cbtestharness" ] = COLDBOX_APP_ROOT_PATH;
	// Core Application.cfc mixins - ORM Settings, etc
	include "config/ApplicationMixins.cfm";

	// application start
	public boolean function onApplicationStart(){
		writeDump( var="**** Started App Start ****", output="console" );

		var start = getTickCount();

		application.cbBootstrap = new coldbox.system.Bootstrap(
			COLDBOX_CONFIG_FILE,
			COLDBOX_APP_ROOT_PATH,
			COLDBOX_APP_KEY,
			COLDBOX_APP_MAPPING,
			COLDBOX_FAIL_FAST,
			COLDBOX_WEB_MAPPING
		);
		application.cbBootstrap.loadColdbox();

		request.fwloadTime = getTickCount() - start;

		writeDump( var = "> ColdBox On AppStart Loaded in #request.fwLoadTime# ms", output = "console" );

		return true;
	}

	// request start
	public boolean function onRequestStart( String targetPage ){
		request.fwRequestStart = getTickCount();

		if ( structKeyExists( url, "appstop" ) ) {
			applicationStop();
			abort;
		}

		// Bootstrap Reinit
		if ( not structKeyExists( application, "cbBootstrap" ) or structKeyExists( url, "bsReinit" ) ) {
			lock name="coldbox.bootstrap_#this.name#" type="exclusive" timeout="5" throwonTimeout=true {
				structDelete( application, "cbBootStrap" );
				onApplicationStart();
			}
		}

		if( url.keyExists( "fwreinit" ) && getFunctionList().keyExists( "ormReload" ) ){
			ormReload();
		}

		// Process ColdBox Request
		application.cbBootstrap.onRequestStart( arguments.targetPage );

		return true;
	}

	public void function onSessionStart(){
		application.cbBootStrap.onSessionStart();
	}

	public void function onSessionEnd( struct sessionScope, struct appScope ){
		arguments.appScope.cbBootStrap.onSessionEnd( argumentCollection = arguments );
	}

	public boolean function onMissingTemplate( template ){
		return application.cbBootstrap.onMissingTemplate( argumentCollection = arguments );
	}

	private boolean function shouldEnableFullNullSupport() {
        var system = createObject( "java", "java.lang.System" );
        var value = system.getEnv( "FULL_NULL" );
        return isNull( local.value ) ? false : !!value;
    }
}
