/**
********************************************************************************
Copyright 2005-2009 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
* This object manages the results of testing with TestBox
*/ 
component accessors="true"{

	// Durations
	property name="startTime"		type="numeric" ;
	property name="endTime"			type="numeric";
	property name="totalDuration"	type="numeric";
	// Global Stats
	property name="bundleCount"		type="numeric";
	property name="specCount" 		type="numeric";
	property name="totalPass" 		type="numeric";
	property name="totalFail" 		type="numeric";
	property name="totalError" 		type="numeric";
	property name="totalSkipped"	type="numeric";

	// specific stats
	property name="bundleStats"		type="struct";
	
	/**
	* Constructor
	*/
	TestResult function init( numeric bundleCount=0) {
		// Global test durations
		variables.startTime 	= getTickCount();	
		variables.endTime 		= 0;
		variables.totalDuration = 0;

		// Global Stats
		variables.bundleCount 	= arguments.bundleCount;
		variables.specCount 	= 0;
		variables.totalPass		= 0;
		variables.totalFail		= 0;
		variables.totalError	= 0;
		variables.totalSkipped 	= 0;
		
		// Init bundle stats structure
		// its a concurrent map so it can support async updates
		//variables.bundleStats = createObject("java", "java.util.concurrent.ConcurrentHashMap").init();
		variables.bundleStats = {};
		
		return this;
	}
	
	TestResult function incrementSpecs(required count=1){
		variables.specCount += arguments.count;
		return this;
	}
	
	TestResult function incrementGlobalStat(required type="pass"){
		switch( arguments.type ){
			case "fail" 	: { variables.totalFail++; return this; }
			case "pass" 	: { variables.totalPass++; return this; }
			case "error" 	: { variables.totalError++; return this; }
			case "skipped" 	: { variables.totalSkipped++; return this; }
		}
		return this;
	}

	TestResult function end() {
		if ( isComplete() ) {
			throw( type = "InvalidState", message = "Testing is already complete." );
		}
		variables.endTime = getTickCount();
		variables.totalDuration = variables.endTime - variables.startTime;
		return this;
	}

	TestResult function endWithError( required TestError error ) {
		if ( isComplete() ) {
			throw( type = "InvalidState", message = "Testing is already complete." );
		}
		endTime = getTickCount();
		variables.error = arguments.error;
		
		return this;
	}

	numeric function getTotalDuration() {
		if ( isComplete() ) {
			return variables.totalDuration;
		}
		return( getTickCount() - variables.startTime );
	}

	boolean function isComplete() {
		return( variables.endTime != 0 );
	}

	boolean function isFailed() {
		if ( !isComplete() ) {
			throw( type = "InvalidState", message = "Testing is not complete." );
		}
		return( isObject( error ) );
	}

	boolean function isPassed() {
		if ( !isComplete() ) {
			throw( type = "InvalidState", message = "Testing is not complete." );
		}
		return( isSimpleValue( error ) );
	}
	
	
	
	struct function startBundleStats(
		required string bundlePath,
		required string name, 
		required numeric specCount){
			
		// setup stats data for bundle
		var results = variables.bundleStats[ arguments.bundlePath ] = {
			// The bundle name
			name		= arguments.name,
			// Total specs found to test
			totalSpecs 	= arguments.specCount,
			// Total passed specs
			totalPass	= 0,
			// Total failed specs
			totalFail	= 0,
			// Total error in specs
			totalError	= 0,
			// Total skipped specs/suites
			totalSkipped = 0,
			// Durations
			startTime 	= getTickCount(),
			endTime		= 0,
			totalDuration = 0,
			// The specs stats
			specs 		= []
		};
		
		return results;
	}
	
	struct function startSpecStats(
		required string name, 
		required struct bundleStats){
			
		// setup stats data for bundle
		var stats = {
			// name of the spec
			name		= arguments.name,
			// test status
			status		= "not executed",
			// timers
			startTime 		= getTickCount(),
			endTime			= 0, 
			totalDuration 	= 0,
			// exception structure
			error		= {},
			// the failure message
			failMessage	= "",
			// the failure origin
			failOrigin = {}
		};
		
		arrayAppend( arguments.bundleStats.specs, stats );
		
		return stats;
	}
	
	/**
	* Get a flat representation of this result
	*/
	struct function getMemento(){
		var pList = listToArray( "startTime,endTime,totalDuration,specCount,bundleCount,bundleStats,totalPass,totalFail,totalError" );
		var result = {};
		
		// Do simple properties only
		for(var x=1; x lte arrayLen( pList ); x++ ){
			if( structKeyExists( variables, pList[ x ] ) ){
				result[ pList[ x ] ] = variables[ pList[ x ] ];
			}
			else{
				result[ pList[ x ] ] = "";
			}
		}
		
		return result;		
	}
}