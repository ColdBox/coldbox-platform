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
	this.mappings[ "/test" ] = getDirectoryFromPath( getCurrentTemplatePath() )
	// setup root path
	rootPath = REReplaceNoCase( this.mappings[ "/test" ], "test(\\|/)", "" )
	// harness path
	this.mappings[ "/cbtestharness" ] 	= rootPath & "test-harness";

	this.datasource = "coolblog";
	this.ormEnabled = "true";

	this.ormSettings = {
		logSQL = true,
		dbcreate = "update",
		secondarycacheenabled = false,
		cacheProvider = "ehcache",
		flushAtRequestEnd = false,
		eventhandling = true,
		eventHandler = "testmodel.EventHandler",
		skipcfcWithError = true
	};

	function onRequestStart( required targetPage ){
	
		if( structKeyExists(URL,"reinit") ){
			ORMReload();
		}

		<!---application.wirebox = createObject("component","coldbox.system.ioc.Injector").init()>--->

		return true;
	}
}