﻿/**
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************
*/
component{
	// Application properties
	this.name = "Test Harness" & hash( getCurrentTemplatePath() );
	this.sessionManagement = true;
	this.sessionTimeout = createTimeSpan(0,0,30,0);
	this.setClientCookies = true;

	// COLDBOX STATIC PROPERTY, DO NOT CHANGE UNLESS THIS IS NOT THE ROOT OF YOUR COLDBOX APP
	COLDBOX_APP_ROOT_PATH = getDirectoryFromPath( getCurrentTemplatePath() );
	// The web server mapping to this application. Used for remote purposes or static purposes
	COLDBOX_APP_MAPPING   = "";
	// COLDBOX PROPERTIES
	COLDBOX_CONFIG_FILE 	 = "";
	// COLDBOX APPLICATION KEY OVERRIDE
	COLDBOX_APP_KEY 		 = "";
	// JAVA INTEGRATION: JUST DROP JARS IN THE LIB FOLDER
	// You can add more paths or change the reload flag as well.
	this.javaSettings = { loadPaths = [ "lib" ], reloadOnChange = false };

	// Mappings
	rootPath = REReplaceNoCase( COLDBOX_APP_ROOT_PATH, "test-harness(\\|/)", "" );
	// ColdBox Root path
	this.mappings[ "/coldbox" ] 		= rootPath;
	// Test Harness Path
	this.mappings[ "/cbtestharness" ] 	= COLDBOX_APP_ROOT_PATH;

	// Core Application.cfc mixins - ORM Settings, etc
	include "config/ApplicationMixins.cfm";

	// application start
	public boolean function onApplicationStart(){
		var start = getTickCount();

		application.cbBootstrap = new coldbox.system.Bootstrap( COLDBOX_CONFIG_FILE, COLDBOX_APP_ROOT_PATH, COLDBOX_APP_KEY, COLDBOX_APP_MAPPING );
		application.cbBootstrap.loadColdbox();

		request.fwloadTime = getTickCount() - start;
		writeDump( var="FWLoadTime: #request.fwLoadTime# ms", output="console" );

		return true;
	}

	// request start
	public boolean function onRequestStart(String targetPage){

		if( structKeyExists( url, "appstop" ) ){
			applicationStop();abort;
		}

		// Bootstrap Reinit
		if( not structKeyExists(application,"cbBootstrap") or application.cbBootStrap.isfwReinit() ){
			lock name="coldbox.bootstrap_#this.name#" type="exclusive" timeout="5" throwonTimeout=true{
				structDelete( application, "cbBootStrap" );
				onApplicationStart();
			}
		}

		// Process ColdBox Request
		application.cbBootstrap.onRequestStart( arguments.targetPage );

		return true;
	}

	public void function onSessionStart(){
		application.cbBootStrap.onSessionStart();
	}

	public void function onSessionEnd( struct sessionScope, struct appScope ){
		arguments.appScope.cbBootStrap.onSessionEnd( argumentCollection=arguments );
	}

	public boolean function onMissingTemplate( template ){
		return application.cbBootstrap.onMissingTemplate( argumentCollection=arguments );
	}

}