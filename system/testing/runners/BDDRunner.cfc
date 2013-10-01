/**
********************************************************************************
Copyright 2005-2009 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
* This TestBox runner is used to run and report on BDD style test suites.
*/ 
component extends="coldbox.system.testing.runners.BaseRunner" implements="coldbox.system.testing.runners.IRunner"{

	/**
	* Run the bundles setup in this Runner and produces an awesome report according to sepcified passed reporter
	* @bundles.hint The path, list of paths or array of paths of the spec bundle CFCs to run and test
	* @directory.hint The directory information struct to test: [ mapping = the path to the directory using dot notation (myapp.testing.specs), recurse = boolean, filter = closure that receives the path of the CFC found, it must return true to process or false to continue process ]	
	* @reporter.hint The type of reporter to use for the results, by default is uses our 'simple' report. You can pass in a core reporter string type or an instance of a coldbox.system.testing.reports.IReporter. You can also pass a struct if the reporter requires options: {type="", options={}}
	* @labels.hint The list or array of labels that a suite or spec must have in order to execute.
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
		var results = new coldbox.system.testing.TestResult( arrayLen( variables.bundles ), variables.labels );
		// iterate and run the test bundles
		for( var thisBundlePath in variables.bundles ){
			testBundle( thisBundlePath, results );
		}
		// mark end of testing bundles
		results.end();
		
		return produceReport( results );
	}

	/************************************** TESTING METHODS *********************************************/

	/**
	* This method tests a bundle CFC in its entirety
	* @bundlePath.hint The path of the Bundle CFC to test.
	* @testResults.hint The testing results object to keep track of results
	*/
	private function testBundle(
		required bundlePath, 
		required testResults
	){
		
		// create new target bundle and get its metadata
		var target 		= getBundle( arguments.bundlePath );
		var targetMD 	= getMetadata( target );
		var bundleName 	= ( structKeyExists( targetMD, "displayName" ) ? targetMD.displayname : arguments.bundlePath );
		
		// Execute the suite descriptors
		target.run();

		// Discover the test suite data to use for testing
		var testSuites 		= getTestSuites( target, targetMD );
		var testSuitesCount = arrayLen( testSuites );

		// Start recording stats for this bundle
		var bundleStats = arguments.testResults.startBundleStats( bundlePath=arguments.bundlePath, name=bundleName );

		//#### NOTHING IS TRAPPED BELOW SO AS TO THROW REAL EXCEPTIONS FROM TESTS THAT ARE WRITTEN WRONG

		// execute beforeAll() for this bundle, no matter how many suites they have.
		if( structKeyExists( target, "beforeAll" ) ){ target.beforeAll(); }

		// Iterate over found test suites and test them, if nested suites, then this will recurse as well.
		for( var thisSuite in testSuites ){
			testSuite( target=target, 
					   suite=thisSuite, 
					   testResults=arguments.testResults,
					   bundleStats=bundleStats );
		}

		// execute afterAll() for this bundle, no matter how many suites they have.
		if( structKeyExists( target, "afterAll" ) ){ target.afterAll(); }
		
		// finalize the bundle stats
		arguments.testResults.endStats( bundleStats );
		
		return this;
	}

	/**
	* Test the incoming suite definition
	* @target.hint The target bundle CFC
	* @method.hint The method definition to test
	* @testResults.hint The testing results object
	* @bundleStats.hint The bundle stats this suite belongs to
	*/
	private function testSuite(
		required target,
		required suite,
		required testResults,
		required bundleStats
	){

		// Start suite stats
		var suiteStats 	= arguments.testResults.startSuiteStats( arguments.suite.name, arguments.bundleStats );
		
		// Record bundle + suite + global initial stats
		suiteStats.totalSpecs 	= arrayLen( arguments.suite.specs );
		arguments.bundleStats.totalSpecs += suiteStats.totalSpecs;
		arguments.bundleStats.totalSuites++;
		// increment global suites + specs
		arguments.testResults.incrementSuites()
			.incrementSpecs( suiteStats.totalSpecs );

		// Verify we can execute the incoming suite via skipping or labels
		if( !arguments.suite.skip && canRunLabel( arguments.suite.labels ) ){
			
			// iterate over suite specs and test them
			for( var thisSpec in arguments.suite.specs ){
				// execute the test within the context of the spec target
				arguments.target.runSpecInContext( spec=thisSpec,
								  				   suite=arguments.suite,
								  				   testResults=arguments.testResults, 
								  				   suiteStats=suiteStats,
								  				   runner=this );

			}

			// All specs finalized, set suite status according to spec data
			if( suiteStats.totalError GT 0 ){ suiteStats.status = "Error"; }
			else if( suiteStats.totalFail GT 0 ){ suiteStats.status = "Failed"; }
			else{ suiteStats.status = "Passed"; }

			// Do we have any internal suites? If we do, test them recursively.

		}
		else{
			// Record skipped stats and status
			suiteStats.status = "Skipped";
			arguments.bundleStats.totalSkipped += suiteStats.totalSpecs;
		}

		// Finalize the suite stats
		arguments.testResults.endStats( suiteStats );
	}

	/************************************** DISCOVERY METHODS *********************************************/

	/**
	* Get all the test suites in the passed in bundle
	* @target.hint The target to get the suites from
	* @targetMD.hint The metdata of the target
	*/
	private array function getTestSuites( 
		required target,
		required targetMD
	){
		// get the spec suites
		return arguments.target.$suites;
	}



}