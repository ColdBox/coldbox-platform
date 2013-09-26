/**
********************************************************************************
Copyright 2005-2009 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
* The TestBox main testing runner.  You will be able to execute your tests/specs
* with this awesome runner and create simple or elegant testing reports
*/ 
component accessors="true"{
	
	// The CFC bundles to test
	property name="bundles";
	// The main utility object
	property name="utility";
	// The reporter attached to this runner
	property name="reporter";
	// The version
	property name="version";
	// The codename
	property name="codename";
			
	/**
	* Constructor
	* @bundles.hint The path, list of paths or array of paths of the spec bundle CFCs to run and test
	* @reporter.hint The type of reporter to use for the results, by default is uses our 'simple' report. You can pass in a core reporter string type or an instance of a coldbox.system.testing.reports.IReporter
	*/
	Runner function init( any bundles=[], any reporter="simple" ){
		// TestBox version
		variables.version 	= "1.0.0.@build.number@";
		variables.codename 	= ""; 
		// init util
		variables.utility = new coldbox.system.core.util.Util();
		// reporter
		variables.reporter = arguments.reporter;
		// inflate bundles to array
		inflateBundles( arguments.bundles );
		
		return this;
	}
	
	/**
	* Run the bundles setup in this Runner and produces an awesome report according to sepcified reporter
	* @bundles.hint The path, list of paths or array of paths of the spec bundle CFCs to run and test
	* @reporter.hint The type of reporter to use for the results, by default is uses our 'simple' report. You can pass in a core reporter string type or an instance of a coldbox.system.testing.reports.IReporter
	*/
	any function run( any bundles, any reporter ){
		// reporter passed?
		if( structKeyExists( arguments, "reporter" ) ){ variables.reporter = arguments.reporter; }
		// if bundles passed, inflate those as the target
		if( structKeyExists( arguments, "bundles" ) ){ inflateBundles( arguments.bundles ); }
		// create results object
		var results = new TestResult( arrayLen( variables.bundles ) );
		// iterate and run the test bundles
		for( var thisBundlePath in variables.bundles ){
			testBundle( thisBundlePath, results );
		}
		// mark end of testing bundles
		results.end();
		
		return produceReport( results );
	}
	
	
/************************************** PRIVATE *********************************************/
	

	/************************************** REPORTING *********************************************/

	/**
	* Build a report according to this runner's setup reporter, which can be anything.
	* @results.hint The results object to use to produce a report
	*/
	private any function produceReport( required results ){
		// if reporter is simple value, then its a core reporter, go get it
		if( isSimpleValue( variables.reporter ) ){
			variables.reporter = buildCoreReporter( variables.reporter );
		}
		// build the report from the reporter
		return variables.reporter.runReport( arguments.results, this );
	}

	/**
	* Build a core reporter according to passed in reporter type
	* @reporter.hint The reporter type to build.
	*/
	private any function buildCoreReporter( required reporter ){
		var reporterList = "json,raw,simple";

		switch( arguments.reporter ){
			case "json" : { return new "coldbox.system.testing.reports.JSONReporter"(); }
			case "raw" : { return new "coldbox.system.testing.reports.RawReporter"(); }
			case "simple" : { return new "coldbox.system.testing.reports.SimpleReporter"(); }
			default: {
				throw(type="TestBox.InvalidReporterType", message="The passed in reporter [#arguments.reporter#] is not a valid report. Valid reporters are #reporterList#");
			}
		}
	}

	/************************************** TESTING METHODS *********************************************/

	
	/**
	* This method tests a bundle CFC in its entirety
	* @bundlePath.hint The path of the Bundle CFC to test.
	* @testResults.hint The testing results object to keep track of results
	*/
	private Runner function testBundle(
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
	*/
	private function testSuite(
		required target,
		required suite,
		required testResults
	){

		// Get bundle stats
		var bundleStats = arguments.testResults.getBundleStats( bundleStats.id );
		// Start suite stats
		var suiteStats 	= arguments.testResults.startSuiteStats( arguments.suite.name, bundleStats );
		
		// Record bundle + suite initial stats
		bundleStats.totalSuites++;
		suiteStats.totalSpecs 	= arrayLen( arguments.suite.specs );
		bundleStats.totalSpecs += suiteStats.totalSpecs;

		// Verify we can execute the incoming suite
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

				// execute beforeEach(), setup()
				if( structKeyExists( arguments.target, "beforeEach" ) ){ arguments.target.beforeEach(); }
				if( structKeyExists( arguments.target, "setup" ) ){ arguments.target.setup(); }
				
				// Execute Spec
				evaluate( "arguments.target.#arguments.spec.name#()" );
				
				// execute afterEach(), teardown()
				if( structKeyExists( arguments.target, "afterEach" ) ){ arguments.target.afterEach(); }
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
			specStats.failOrigin 	= e.tagContext[ 1 ];
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
		// check if doing Unit Style or BDD style
		if( arrayLen( arguments.target.$suites ) eq 0 ){
			return getUnitStyleSuite( arguments.target, arguments.targetMD );
		}

		// else build and return BDD suite.
	}

	/**
	* Build a unit style suite
	*/
	private array function getUnitStyleSuite(
		required target,
		required targetMD
	){

		var suite = {
			// bundle this suite belongs to
			bundlePath = arguments.targetMD.name,
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
					name 				= specMD.name,
					hint 				= ( structKeyExists( specMD, "hint" ) ? specMD.hint : "" ),
					skip 				= ( structKeyExists( specMD, "skip" ) ?  ( len( specMD.skip ) ? specMD.skip : true ) : false ),
					labels 				= ( structKeyExists( specMD, "labels" ) ? listToArray( specMD.labels ) : [] ),
					order 				= ( structKeyExists( specMD, "order" ) ? listToArray( specMD.order ) : index++ ),
					expectedException   = ( structKeyExists( specMD, "expectedException" ) ? specMD.expectedException : "" ),
				};

				// skip constraint?
				if( !isBoolean( spec.skip ) && isCustomFunction( arguments.target[ spec.skip ] ) ){
					spec.skip = evaluate( "arguments.target.#spec.skip#()" );
				}

				arrayAppend( mResults, spec );
			}
		}
		return mResults;
	}

	/************************************** UTILITY METHODS *********************************************/

	/**
	* Creates and returns a bundle CFC with spec capabilities if not inherited.
	* @bundlePath.hint The path to the Bundle CFC
	*/ 
	private any function getBundle( required bundlePath ){
		var bundle		= new "#arguments.bundlePath#"();
		var familyPath 	= "coldbox.system.testing.BaseSpec";
		
		// check if base spec assigned
		if( isInstanceOf( bundle, familyPath ) ){
			return bundle;
		}
		
		// Else virtualize it
		var baseObject 			= new coldbox.system.testing.BaseSpec();
		var excludedProperties 	= "";
		
		// Mix it up baby
		variables.utility.getMixerUtil().start( bundle );
		
		// Mix in the virtual methods
		for( var key in baseObject ){
			// If target has overriden method, then don't override it with mixin, simulated inheritance
			if( NOT structKeyExists( bundle, key ) AND NOT listFindNoCase( excludedProperties, key ) ){
				bundle.injectMixin( key, baseObject[ key ] );
			}
		}

		// Mix in virtual super class just in case we need it
		bundle.$super = baseObject;
		
		return bundle;
	}

	/**
	* Validate the incoming method name is a valid TestBox test method name
	*/
	private boolean function isValidTestMethod( required methodName ) {
		// All test methods must start with the term, "test". 
		return( !! reFindNoCase( "^test", methodName ) );
	}
	
	/**
	* Inflate incoming bundles from a simple string as a standard array
	*/
	private function inflateBundles(required any bundles){
		variables.bundles = ( isSimpleValue( arguments.bundles ) ? listToArray( arguments.bundles ) : arguments.bundles );
	}
	
}