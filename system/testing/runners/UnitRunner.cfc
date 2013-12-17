/**
********************************************************************************
Copyright 2005-2009 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
* This TestBox runner is used to run and report on xUnit style test suites.
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

		// Get target information
		var targetMD 	= getMetadata( arguments.target );
		var bundleName 	= ( structKeyExists( targetMD, "displayName" ) ? targetMD.displayname : targetMD.name );
		
		// Discover the test suite data to use for testing
		var testSuites 		= getTestSuites( arguments.target, targetMD, arguments.testResults );
		var testSuitesCount = arrayLen( testSuites );

		// Start recording stats for this bundle
		var bundleStats = arguments.testResults.startBundleStats( bundlePath=targetMD.name, name=bundleName );

		//#### NOTHING IS TRAPPED BELOW SO AS TO THROW REAL EXCEPTIONS FROM TESTS THAT ARE WRITTEN WRONG

		// Verify we can run this bundle
		if( canRunBundle( bundlePath=targetMD.name, testResults=arguments.testResults ) ){

			// execute beforeAll(), beforeTests() for this bundle, no matter how many suites they have.
			if( structKeyExists( arguments.target, "beforeAll" ) ){ arguments.target.beforeAll(); }
			if( structKeyExists( arguments.target, "beforeTests" ) ){ arguments.target.beforeTests(); }
			
			// Iterate over found test suites and test them, if nested suites, then this will recurse as well.
			for( var thisSuite in testSuites ){
				testSuite( target=arguments.target, 
						   suite=thisSuite, 
						   testResults=arguments.testResults,
						   bundleStats=bundleStats );
			}

			// execute afterAll(), afterTests() for this bundle, no matter how many suites they have.
			if( structKeyExists( arguments.target, "afterAll" ) ){ arguments.target.afterAll(); }
			if( structKeyExists( arguments.target, "afterTests" ) ){ arguments.target.afterTests(); }
		
		}

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
						thread.target.runTestMethod( spec=attributes.thisSpec, 
										  	   		 testResults=thread.testResults, 
						  				  	   		 suiteStats=thread.suiteStats,
						  				  	   		 runner=this );
				
					}

				} else {
					// execute the test within the context of the spec target due to railo closure bug, move back once it is resolved.
					thread.target.runTestMethod( spec=thisSpec,
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

	/**
	* Get all the test suites in the passed in bundle
	* @target.hint The target to get the suites from
	* @targetMD.hint The metdata of the target
	* @testResults.hint The test results object
	*/
	private array function getTestSuites( 
		required target,
		required targetMD,
		required testResults
	){
		var suite = {
			// suite name
			name 		= ( structKeyExists( arguments.targetMD, "displayName" ) ? arguments.targetMD.displayname : arguments.targetMD.name ),
			// async flag
			asyncAll 	= ( structKeyExists( arguments.targetMD, "asyncAll" ) ? arguments.targetMD.asyncAll : false ),
			// skip suite testing flag
			skip 		= ( structKeyExists( arguments.targetMD, "skip" ) ?  ( len( arguments.targetMD.skip ) ? arguments.targetMD.skip : true ) : false ),
			// labels attached to the suite for execution
			labels 		= ( structKeyExists( arguments.targetMD, "labels" ) ? listToArray( arguments.targetMD.labels ) : [] ),
			// the specs attached to this suite.
			specs 		= getTestMethods( arguments.target, arguments.testResults ),
			// the recursive suites
			suites 		= []
		};

		// skip constraint for suite?
		if( !isBoolean( suite.skip ) && isCustomFunction( arguments.target[ suite.skip ] ) ){
			suite.skip = evaluate( "arguments.target.#suite.skip#()" );
		}

		// check them.
		if( arrayLen( arguments.testResults.getLabels() ) )
			suite.skip = ( ! canRunLabel( suite.labels, arguments.testResults ) );

		return [ suite ];
	}

	/**
	* Retrieve the testing methods/specs from a given target.
	* @target.hint The target to get the methods from
	*/
	private array function getTestMethods( 
		required any target,
		required any testResults
	){
	
		var mResults = [];
		var methodArray = structKeyArray( arguments.target );
		var index = 1;

		for( var thisMethod in methodArray ) {
			// only valid functions and test functions allowed
			if( isCustomFunction( arguments.target[ thisMethod ] ) &&
				isValidTestMethod( thisMethod ) ) {
				// Build the spec data packet
				var specMD = getMetadata( arguments.target[ thisMethod ] );
				var spec = {
					name 		= specMD.name,
					hint 		= ( structKeyExists( specMD, "hint" ) ? specMD.hint : "" ),
					skip 		= ( structKeyExists( specMD, "skip" ) ?  ( len( specMD.skip ) ? specMD.skip : true ) : false ),
					labels 		= ( structKeyExists( specMD, "labels" ) ? listToArray( specMD.labels ) : [] ),
					order 		= ( structKeyExists( specMD, "order" ) ? listToArray( specMD.order ) : index++ ),
					expectedException  = ( structKeyExists( specMD, "expectedException" ) ? specMD.expectedException : "" )
				};
				
				// skip constraint?
				if( !isBoolean( spec.skip ) && isCustomFunction( arguments.target[ spec.skip ] ) ){
					spec.skip = evaluate( "arguments.target.#spec.skip#()" );
				}

				// do we have labels applied?
				if( arrayLen( arguments.testResults.getLabels() ) )
					spec.skip = ( ! canRunLabel( spec.labels, arguments.testResults ) );

				// register spec
				arrayAppend( mResults, spec );
			}
		}
		return mResults;
	}

}