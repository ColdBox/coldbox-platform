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
		// setup bundle name
		var bundleName = ( structKeyExists( targetMD, "displayName" ) ? targetMD.displayname : arguments.bundlePath );
		
		// get test target specs to test for this bundle
		var testSpecs = getTestMethods( target );
		var testSpecsCount = arrayLen( testSpecs );
		
		// record global stats
		arguments.testResults.incrementSpecs( count=testSpecsCount );
		
		// Start stats for this spec bundle
		var bundleStats = arguments.testResults.startBundleStats( bundlePath=arguments.bundlePath, 
																  name=bundleName, 
																  specCount=testSpecsCount );

		// NOTHING IS TRAPPED BELOW AS THAT MEANS THERE IS AN ACTUAL EXCEPTION IN THE TEST ITSELF
		// execute beforeAll(), beforeTests()
		if( structKeyExists( target, "beforeAll" ) ){ target.beforeAll(); }
		if( structKeyExists( target, "beforeTests" ) ){ target.beforeTests(); }
		
		// iterate and test specs in this bundle
		for( var thisMethod in testSpecs ){
			testSpec( target, thisMethod, arguments.testResults, bundleStats );
		}
		
		// execute afterAll(), afterTests()
		if( structKeyExists( target, "afterAll" ) ){ target.afterAll(); }
		if( structKeyExists( target, "afterTests" ) ){ target.afterTests(); }
		
		// end the bundle stats time count
		bundleStats.endTime 		= getTickCount();
		bundleStats.totalDuration 	= bundleStats.endTime - bundleStats.startTime;
		
		return this;
	}
	
	/**
	* Test the incoming spec definition
	* @target.hint The target bundle CFC
	* @method.hint The method definition to test
	* @testResults.hint The testing results object
	* @bundleStats
	*/
	private function testSpec(
		required target,
		required method,
		required testResults, 
		required bundleStats
	){
			
		try{
			// init spec tests
			var specStats = arguments.testResults.startSpecStats( arguments.method.name, arguments.bundleStats );
			
			// Verify we can execute
			if( !arguments.method.skip ){

				// execute beforeEach(), setup()
				if( structKeyExists( arguments.target, "beforeEach" ) ){ arguments.target.beforeEach(); }
				if( structKeyExists( arguments.target, "setup" ) ){ arguments.target.setup(); }
				
				// Execute Test Method
				evaluate( "arguments.target.#arguments.method.name#()" );
				
				// execute afterEach(), teardown()
				if( structKeyExists( arguments.target, "afterEach" ) ){ arguments.target.afterEach(); }
				if( structKeyExists( arguments.target, "teardown" ) ){ arguments.target.teardown(); }
				
				// store end time and stats
				specStats.status 	= "Passed";
				arguments.testResults.incrementGlobalStat(type="pass");
				arguments.bundleStats.totalPass++;
			}
			else{
				// Record skipped stats
				specStats.status = "Skipped";
				arguments.testResults.incrementGlobalStat(type="skipped");
				arguments.bundleStats.totalSkipped++;
			}
		}
		// Catch assertion failures
		catch("TestBox.AssertionFailed" e){
			// increment failures and stats
			specStats.status 		= "Failed";
			specStats.failMessage 	= e.message;
			specStats.failOrigin 	= e.tagContext[ 1 ];
			arguments.bundleStats.totalFail++;
			arguments.testResults.incrementGlobalStat(type="fail");
		}
		// Catch errors
		catch(any e){
			// increment errors
			specStats.error 		= e;
			specStats.status 		= "Error";
			arguments.bundleStats.totalError++;
			arguments.testResults.incrementGlobalStat(type="error");
		}
		finally{
			// Complete timing of the spec test
			specStats.endTime 	= getTickCount();
			specStats.totalDuration = specStats.endTime - specStats.startTime;			
		}
		
		return this;
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