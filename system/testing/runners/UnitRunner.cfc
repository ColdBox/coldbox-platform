/**
********************************************************************************
Copyright 2005-2009 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
* This TestBox runner is used to run and report on xUnit style test suites.
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
		
		// Discover the test suite data to use for testing
		var testSuites 		= getTestSuites( target, targetMD );
		var testSuitesCount = arrayLen( testSuites );

		// Start recording stats for this bundle
		var bundleStats = arguments.testResults.startBundleStats( bundlePath=arguments.bundlePath, name=bundleName );

		//#### NOTHING IS TRAPPED BELOW SO AS TO THROW REAL EXCEPTIONS FROM TESTS THAT ARE WRITTEN WRONG

		// execute beforeAll(), beforeTests() for this bundle, no matter how many suites they have.
		if( structKeyExists( target, "beforeAll" ) ){ target.beforeAll(); }
		if( structKeyExists( target, "beforeTests" ) ){ target.beforeTests(); }
		
		// Iterate over found test suites and test them, if nested suites, then this will recurse as well.
		for( var thisSuite in testSuites ){
			testSuite( target=target, 
					   suite=thisSuite, 
					   testResults=arguments.testResults,
					   bundleStats=bundleStats );
		}

		// execute afterAll(), afterTests() for this bundle, no matter how many suites they have.
		if( structKeyExists( target, "afterAll" ) ){ target.afterAll(); }
		if( structKeyExists( target, "afterTests" ) ){ target.afterTests(); }
		
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
		if( !arguments.suite.skip ){

			// iterate over suite specs and test them
			for( var thisSpec in arguments.suite.specs ){
				
				testSpec( target=arguments.target, 
						  spec=thisSpec, 
						  testResults=arguments.testResults, 
						  suiteStats=suiteStats );

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

	/**
	* Test the incoming spec definition
	* @target.hint The target bundle CFC
	* @spec.hint The spec definition to test
	* @testResults.hint The testing results object
	* @suiteStats.hint The suite stats that the incoming spec definition belongs to
	*/
	private function testSpec(
		required target,
		required spec,
		required testResults,
		required suiteStats
	){
			
		try{
			
			// init spec tests
			var specStats = arguments.testResults.startSpecStats( arguments.spec.name, arguments.suiteStats );
			
			// Verify we can execute
			if( !arguments.spec.skip ){

				// execute setup()
				if( structKeyExists( arguments.target, "setup" ) ){ arguments.target.setup(); }
				
				// Execute Spec
				evaluate( "arguments.target.#arguments.spec.name#()" );
				
				// execute teardown()
				if( structKeyExists( arguments.target, "teardown" ) ){ arguments.target.teardown(); }
				
				// store spec status
				specStats.status 	= "Passed";
				// Increment recursive pass stats
				arguments.testResults.incrementSpecStat( type="pass", stats=specStats );
			}
			else{
				// store spec status
				specStats.status = "Skipped";
				// Increment recursive pass stats
				arguments.testResults.incrementSpecStat( type="skipped", stats=specStats );
			}
		}
		// Catch assertion failures
		catch("TestBox.AssertionFailed" e){
			// store spec status and debug data
			specStats.status 		= "Failed";
			specStats.failMessage 	= e.message;
			specStats.failOrigin 	= e.tagContext;
			// Increment recursive pass stats
			arguments.testResults.incrementSpecStat( type="fail", stats=specStats );
		}
		// Catch errors
		catch(any e){
			// store spec status and debug data
			specStats.status 		= "Error";
			specStats.error 		= e;
			// Increment recursive pass stats
			arguments.testResults.incrementSpecStat( type="error", stats=specStats );
		}
		finally{
			// Complete spec testing
			arguments.testResults.endStats( specStats );
		}
		
		return this;
	}

	/**
	* Get all the test suites in the passed in bundle
	* @target.hint The target to get the suites from
	* @targetMD.hint The metdata of the target
	*/
	private array function getTestSuites( 
		required target,
		required targetMD
	){
		var suite = {
			// suite name
			name 		= ( structKeyExists( arguments.targetMD, "displayName" ) ? arguments.targetMD.displayname : arguments.targetMD.name ),
			// async flag
			asyncAll 	= false,
			// skip suite testing flag
			skip 		= ( structKeyExists( arguments.targetMD, "skip" ) ?  ( len( arguments.targetMD.skip ) ? arguments.targetMD.skip : true ) : false ),
			// labels attached to the suite for execution
			labels 		= ( structKeyExists( arguments.targetMD, "labels" ) ? listToArray( arguments.targetMD.labels ) : [] ),
			// the specs attached to this suite.
			specs 		= getTestMethods( arguments.target ),
			// the recursive suites
			suites 		= []
		};

		// skip constraint for suite?
		if( !isBoolean( suite.skip ) && isCustomFunction( arguments.target[ suite.skip ] ) ){
			suite.skip = evaluate( "arguments.target.#suite.skip#()" );
		}

		// do we have labels applied?
		if( arrayLen( variables.labels ) ){
			// check them.
			suite.skip = ( ! canRunLabel( suite.labels ) );
		}

		return [ suite ];
	}

	/**
	* Retrieve the testing methods/specs from a given target.
	* @target.hint The target to get the methods from
	*/
	private array function getTestMethods( required any target ){
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
				if( arrayLen( variables.labels ) ){
					for( var thisLabel in variables.labels ){
						// verify that a label exists, if it does, break, it matches the criteria, if no matches, then skip it.
						if( arrayFindNoCase( spec.labels, thisLabel ) ){
							spec.skip = false;
							break;
						}
						spec.skip = true;
					}
				}

				arrayAppend( mResults, spec );
			}
		}
		return mResults;
	}

}