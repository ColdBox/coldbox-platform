/**
********************************************************************************
Copyright 2005-2009 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
* This TestBox runner is used to run and report on BDD style test suites.
*/ 
component extends="coldbox.system.testing.runners.BaseRunner" implements="coldbox.system.testing.runners.IRunner" accessors="true"{

	// runner options
	property name="options";

	/**
	* Constructor
	* @options.hint The options for this runner
	*/
	function init( required struct options ){

		variables.options = arguments.options;
		
		return this;
	}

	/**
	* Execute a BDD test on the incoming target and store the results in the incoming test results
	* @target.hint The target bundle CFC to test
	* @testResults.hint The test results object to keep track of results for this test case
	*/
	any function run( 
		required any target,
		required coldbox.system.testing.TestResult testResults
	){
		// Get target metadata
		var targetMD 	= getMetadata( arguments.target );
		var bundleName 	= ( structKeyExists( targetMD, "displayName" ) ? targetMD.displayname : targetMD.name );
		
		// Execute the suite descriptors
		arguments.target.run();

		// Discover the test suite data to use for testing
		var testSuites 		= getTestSuites( arguments.target, targetMD );
		var testSuitesCount = arrayLen( testSuites );

		// Start recording stats for this bundle
		var bundleStats = arguments.testResults.startBundleStats( bundlePath=targetMD.name, name=bundleName );

		//#### NOTHING IS TRAPPED BELOW SO AS TO THROW REAL EXCEPTIONS FROM TESTS THAT ARE WRITTEN WRONG
		
		// Verify we can run this bundle
		if( canRunBundle( bundlePath=targetMD.name, testResults=arguments.testResults ) ){
		
			// execute beforeAll() for this bundle, no matter how many suites they have.
			if( structKeyExists( arguments.target, "beforeAll" ) ){ 
				arguments.target.beforeAll(); 
			}

			// Iterate over found test suites and test them, if nested suites, then this will recurse as well.
			for( var thisSuite in testSuites ){
				
				testSuite( target=arguments.target, 
						   suite=thisSuite, 
						   testResults=arguments.testResults,
						   bundleStats=bundleStats );

			}

			// execute afterAll() for this bundle, no matter how many suites they have.
			if( structKeyExists( arguments.target, "afterAll" ) ){ 
				arguments.target.afterAll(); 
			}

		} // end if we can run bundle
		
		// finalize the bundle stats
		arguments.testResults.endStats( bundleStats );
		
		return this;
	}

	/************************************** TESTING METHODS *********************************************/

	/**
	* Test the incoming suite definition
	* @target.hint The target bundle CFC
	* @method.hint The method definition to test
	* @testResults.hint The testing results object
	* @bundleStats.hint The bundle stats this suite belongs to
	* @parentStats.hint If this is a nested test suite, then it will have some parentStats goodness
	*/
	private function testSuite(
		required target,
		required suite,
		required testResults,
		required bundleStats,
		parentStats={}
	){

		// Start suite stats
		var suiteStats = arguments.testResults.startSuiteStats( arguments.suite.name, arguments.bundleStats, arguments.parentStats );
		
		// Record bundle + suite + global initial stats
		suiteStats.totalSpecs = arrayLen( arguments.suite.specs );
		arguments.bundleStats.totalSpecs += suiteStats.totalSpecs;
		arguments.bundleStats.totalSuites++;
		// increment global suites + specs
		arguments.testResults.incrementSuites().incrementSpecs( suiteStats.totalSpecs );

		// Verify we can execute the incoming suite via skipping or labels
		if( !arguments.suite.skip && 
			canRunLabel( arguments.suite.labels, arguments.testResults ) && 
			canRunSuite( arguments.suite, arguments.testResults )
		){
			
			// prepare threaded names
			var threadNames = [];
			// threaded variables just in case some suite is async and another is not.
			thread.testResults 	= arguments.testResults;
			thread.suiteStats  	= suiteStats;
			thread.target 		= arguments.target;

			// iterate over suite specs and test them
			for( var thisSpec in arguments.suite.specs ){
				
				// is this async or not?
				if( arguments.suite.asyncAll ){
					// prepare thread names
					var thisThreadName = "tb-suite-#hash( thisSpec.name )#";
					arrayAppend( threadNames, thisThreadName );
					// thread it
					thread name="#thisThreadName#" thisSpec="#thisSpec#" suite="#arguments.suite#" threadName="#thisThreadName#"{
						// execute the test within the context of the spec target due to railo closure bug, move back once it is resolved.
						thread.target.runSpec( spec=attributes.thisSpec,
								  			   suite=attributes.suite,
								  			   testResults=thread.testResults, 
								  			   suiteStats=thread.suiteStats,
								  			   runner=this );
					}

				} else {
					// execute the test within the context of the spec target due to railo closure bug, move back once it is resolved.
					thread.target.runSpec( spec=thisSpec,
								  		   suite=arguments.suite,
								  		   testResults=thread.testResults, 
								  		   suiteStats=thread.suiteStats,
								  		   runner=this );
				}
			} // end loop over specs

			// join threads if async
			if( arguments.suite.asyncAll ){ thread action="join" name="#arrayToList( threadNames )#"{}; }

			// All specs finalized, set suite status according to spec data
			if( suiteStats.totalError GT 0 ){ suiteStats.status = "Error"; }
			else if( suiteStats.totalFail GT 0 ){ suiteStats.status = "Failed"; }
			else{ suiteStats.status = "Passed"; }

			// Do we have any internal suites? If we do, test them recursively, go down the rabbit hole
			for( var thisInternalSuite in arguments.suite.suites ){
				// run parent before each
				arguments.suite.beforeEach();

				// run the suite specs recursively
				testSuite( target=arguments.target,
						   suite=thisInternalSuite,
						   testResults=arguments.testResults,
						   bundleStats=arguments.bundleStats,
						   parentStats=suiteStats );

				// run parent before each
				arguments.suite.afterEach();
			}

			// Skip Checks
			if( suiteStats.totalSpecs == suiteStats.totalSkipped ){
				suiteStats.status = "Skipped";	
			}

		}
		else{
			// Record skipped stats and status
			suiteStats.status = "Skipped";
			arguments.bundleStats.totalSkipped += suiteStats.totalSpecs;
			arguments.testResults.incrementStat( "skipped", suiteStats.totalSpecs );
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