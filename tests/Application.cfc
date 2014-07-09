﻿/**
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
	this.sessionTimeout = createTimeSpan(0,0,10,0);
	this.applicationTimeout = createTimeSpan(0,0,10,0);

	// setup test path
	this.mappings[ "/tests" ] = getDirectoryFromPath( getCurrentTemplatePath() );
	// setup root path
	rootPath = REReplaceNoCase( this.mappings[ "/tests" ], "tests(\\|/)", "" );
	// harness path
	this.mappings[ "/cbtestharness" ] 	= rootPath & "test-harness";

    // ORM Settings
    this.ormEnabled 	  = true;
    this.datasource		  = "coolblog";
    this.ormSettings	  = {
    	cfclocation = "/cbtestharness/model/entities",
    	logSQL 		= false,
    	flushAtRequestEnd = false,
    	autoManageSession = false,
    	eventHandling 	  =  false
    };

	function onRequestStart( required targetPage ){

		ORMReload();

		return true;
	}
}