/**
********************************************************************************
Copyright 2005-2009 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
* This TestBox runner is used to run and report on BDD style test suites.
*/ 
component extends="coldbox.system.testing.runners.BaseRunner" implements="coldbox.system.testing.runners.IRunner"{

	/**
	* Run the bundles setup in this Runner and produces an awesome report according to sepcified reporter
	* @bundles.hint The path, list of paths or array of paths of the spec bundle CFCs to run and test
	* @reporter.hint The type of reporter to use for the results, by default is uses our 'simple' report. You can pass in a core reporter string type or an instance of a coldbox.system.testing.reports.IReporter
	*/
	any function run( any bundles, struct directory, any reporter, any labels ){
		// inflate labels if passed
		if( structKeyExists( arguments, "labels" ) ){ 
			variables.labels = ( isSimpleValue( arguments.labels ) ? listToArray( arguments.labels ) : arguments.labels ); 
		}
		// reporter passed?
		if( structKeyExists( arguments, "reporter" ) ){ variables.reporter = arguments.reporter; }
		// if bundles passed, inflate those as the target
		if( structKeyExists( arguments, "bundles" ) ){ inflateBundles( arguments.bundles ); }
		// create results object
		var results = new TestResult( arrayLen( variables.bundles ), variables.labels );
		// iterate and run the test bundles
		for( var thisBundlePath in variables.bundles ){
			testBundle( thisBundlePath, results );
		}
		// mark end of testing bundles
		results.end();
		
		return produceReport( results );
	}

	/************************************** TESTING METHODS *********************************************/

}