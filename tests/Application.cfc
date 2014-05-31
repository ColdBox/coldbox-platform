/**
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************
*/
component{

	this.name = "ColdBox Testing Harness" & hash(getCurrentTemplatePath());
	this.sessionManagement = true;
	this.setClientCookies = true;
	this.clientManagement = true;
	this.sessionTimeout = createTimeSpan(0,0,5,0);

	// setup test path
	this.mappings[ "/tests" ] = getDirectoryFromPath( getCurrentTemplatePath() );
	// setup root path
	rootPath = REReplaceNoCase( this.mappings[ "/tests" ], "tests(\\|/)", "" );
	// harness path
	this.mappings[ "/cbtestharness" ] 	= rootPath & "test-harness";

	function onRequestStart( required targetPage ){

		if( structKeyExists(URL,"reinit") ){
			ORMReload();
		}

		return true;
	}
}