/**
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Description :
	This Application.cfc uses composition to ColdBox so you can use
	per application mappings.
*/
import coldbox.system.mvc.*;
component{

	// Application Properties
	this.name = hash( getCurrentTemplatePath() );
	this.sessionManagement = true;
	this.sessionTimeout = createTimeSpan(0,0,30,0);
	this.setClientCookies = true;
	
	// COLDBOX STATIC PROPERTY, DO NOT CHANGE UNLESS THIS IS NOT THE ROOT OF YOUR COLDBOX APP
	COLDBOX_APP_ROOT_PATH = getDirectoryFromPath( getCurrentTemplatePath() );
	// The web server mapping to this application. Used for remote purposes or static purposes
	COLDBOX_APP_MAPPING = "";
	// COLDBOX PROPERTIES
	COLDBOX_CONFIG_FILE = "";	
	// COLDBOX APPLICATION KEY OVERRIDE
	COLDBOX_APP_KEY = "";
	
	boolean function onApplicationStart(){
		//Load ColdBox
		application.cbBootstrap = new BootStrap( COLDBOX_CONFIG_FILE, COLDBOX_APP_ROOT_PATH, COLDBOX_APP_KEY, COLDBOX_APP_MAPPING );
		application.cbBootstrap.loadColdbox();
		return true;
	}
	
	boolean function onRequestStart(required targetPage){
		// Bootrap reinit check
		if( NOT structKeyExists( application, "cbBootstrap" ) OR application.cbBootStrap.isFWReinit() ){
			lock name="coldbox.bootstrap_#hash( getCurrentTemplatePath() )#" type="exclusive" timeout="5" throwOnTimeout="true"{
				structDelete( application, "cbBootStrap" );
				application.cbBootstrap = new BootStrap( COLDBOX_CONFIG_FILE, COLDBOX_APP_ROOT_PATH, COLDBOX_APP_KEY, COLDBOX_APP_MAPPING );
			}
		}
		// Do Request
		application.cbBootStrap.onRequestStart( arguments.targetPage );
		
		return true;
	}
	
	function onApplicationEnd(required appScope){
		arguments.appScope.cbBootstrap.onApplicationEnd(argumentCollection=arguments);	
	}
	
	function onSessionStart(){
		arguments.appScope.cbBootstrap.onSessionStart();	
	}
	
	function onSessionEnd(required sessionScope){
		appScope.cbBootstrap.onSessionEnd(argumentCollection=arguments);	
	}
	
	function onMissingTemplate(required template){
		application.cbBootstrap.onMissingTemplate(argumentCollection=arguments);	
	}
	
}