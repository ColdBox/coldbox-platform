/**
* Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
* ---
*/
component{

	this.name = "ColdBox Testing Harness" & hash( getCurrentTemplatePath() );
	this.sessionManagement = true;
	this.setClientCookies = true;
	this.clientManagement = true;
	this.sessionTimeout = createTimeSpan(0,0,10,0);
	this.applicationTimeout = createTimeSpan(0,0,10,0);

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

	// Datasource definitions For Standalone mode/travis mode.
	if( directoryExists( "/home/travis" ) ){
		this.datasources[ "coolblog" ] = {
			  class 			: 'org.gjt.mm.mysql.Driver',
			  connectionString	: 'jdbc:mysql://localhost:3306/coolblog?useUnicode=true&characterEncoding=UTF-8&useLegacyDatetimeCode=true',
			  username 			: 'root'
		};
	
	}

    // ORM Settings
    this.ormEnabled 	  = true;
    this.datasource		  = "coolblog";
    this.ormSettings	  = {
    	cfclocation 		= "/cbtestharness/models/entities",
    	logSQL 				= false,
    	flushAtRequestEnd 	= false,
    	autoManageSession 	= false,
    	eventHandling 	  	=  false
    };

	function onRequestStart( required targetPage ){

		//ORMReload();

		return true;
	}

}