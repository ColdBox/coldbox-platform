/**
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Description :
	This is the bootstrapper Application.cfc for ColdBox Applications.
	It uses inheritance on the CFC, so if you do not want inheritance
	then use the Application_noinheritance.cfc instead.
**/	
component extends="coldbox.system.mvc.Bootstrap"{

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

	boolean function onRequestStart(required targetPage){
		// Process A ColdBox Request Only
		if( findNoCase('index.cfm', listLast(arguments.targetPage, '/')) ){
			// Reload Checks
			reloadChecks();
			// Process Request
			processColdBoxRequest();
		}
		
		// WHATEVER YOU WANT BELOW
		return true;
	}
	
}