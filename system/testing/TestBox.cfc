/**
********************************************************************************
Copyright 2005-2009 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
* Welcome to the next generation of BDD and xUnit testing for CFML applications
* The TestBox core class allows you to execute all kinds of test bundles, directories and more.
*/ 
component accessors="true"{
	
	// The version
	property name="version";
	// The codename
	property name="codename";
	// The main utility object
	property name="utility";
	// The CFC bundles to test
	property name="bundles";
	// The labels used for the testing
	property name="labels";
	// The reporter attached to this runner
	property name="reporter";
	// The configuration options attached to this runner
	property name="options";
			
	/**
	* Constructor
	* @bundles.hint The path, list of paths or array of paths of the spec bundle CFCs to run and test
	* @directory.hint The directory information struct to test: [ mapping = the path to the directory using dot notation (myapp.testing.specs), recurse = boolean, filter = closure that receives the path of the CFC found, it must return true to process or false to continue process ]
	* @reporter.hint The type of reporter to use for the results, by default is uses our 'simple' report. You can pass in a core reporter string type or an instance of a coldbox.system.testing.reports.IReporter
	* @labels.hint The list or array of labels that a suite or spec must have in order to execute.
	* @options.hint A structure of configuration options that are optionally used to configure a runner.
	*/
	any function init( 
		any bundles=[], 
		struct directory={}, 
		any reporter="simple", 
		any labels=[], 
		struct options={} 
	){
		
		// TestBox version
		variables.version 	= "1.0.0.@build.number@";
		variables.codename 	= "";
		// init util
		variables.utility = new coldbox.system.core.util.Util();
		
		// reporter
		variables.reporter = arguments.reporter;
		// options
		variables.options = arguments.options;

		// directory passed?
		if( !structIsEmpty( arguments.directory ) ){
			arguments.bundles = getSpecPaths( arguments.directory );
		}

		// inflate labels
		inflateLabels( arguments.labels );
		// inflate bundles to array
		inflateBundles( arguments.bundles );
		
		return this;
	}
	
	/**
	* Run me some testing goodness, this can use the constructed object variables or the ones
	* you can send right here.
	* @bundles.hint The path, list of paths or array of paths of the spec bundle CFCs to run and test
	* @directory.hint The directory information struct to test: [ mapping = the path to the directory using dot notation (myapp.testing.specs), recurse = boolean, filter = closure that receives the path of the CFC found, it must return true to process or false to continue process ]	
	* @reporter.hint The type of reporter to use for the results, by default is uses our 'simple' report. You can pass in a core reporter string type or an instance of a coldbox.system.testing.reports.IReporter. You can also pass a struct if the reporter requires options: {type="", options={}}
	* @labels.hint The list or array of labels that a suite or spec must have in order to execute.
	* @options.hint A structure of configuration options that are optionally used to configure a runner.
	* @testSuites.hint A list or array of suite names that are the ones that will be executed ONLY!
	* @testSpecs.hint A list or array of test names that are the ones that will be executed ONLY!
	*/
	any function run( 
		any bundles,
		struct directory,
		any reporter,
		any labels,
		struct options,
		any testSuites=[],
		any testSpecs=[]
	){
	
		// reporter passed?
		if( structKeyExists( arguments, "reporter" ) ){ variables.reporter = arguments.reporter; }
		// run it and get results
		var results = runRaw( argumentCollection=arguments );
		// return report
		return produceReport( results );
	}

	/**
	* Run me some testing goodness but give you back the raw TestResults object instead
	* @bundles.hint The path, list of paths or array of paths of the spec bundle CFCs to run and test
	* @directory.hint The directory information struct to test: [ mapping = the path to the directory using dot notation (myapp.testing.specs), recurse = boolean, filter = closure that receives the path of the CFC found, it must return true to process or false to continue process ]	
	* @labels.hint The list or array of labels that a suite or spec must have in order to execute.
	* @options.hint A structure of configuration options that are optionally used to configure a runner.
	* @testSuites.hint A list or array of suite names that are the ones that will be executed ONLY!
	* @testSpecs.hint A list or array of test names that are the ones that will be executed ONLY!
	*/
	coldbox.system.testing.TestResult function runRaw( 
		any bundles,
		struct directory,
		any labels,
		struct options,
		any testSuites=[],
		any testSpecs=[]
	){
		
		// inflate options if passed
		if( structKeyExists( arguments, "options" ) ){ 
			variables.options = arguments.options;
		}

		// inflate test suites and specs from incoming variables.
		arguments.testSuites = ( isSimpleValue( arguments.testSuites ) ? listToArray( arguments.testSuites ) : arguments.testSuites );
		arguments.testSpecs = ( isSimpleValue( arguments.testSpecs ) ? listToArray( arguments.testSpecs ) : arguments.testSpecs );
		
		// directory passed?
		if( structKeyExists( arguments, "directory" ) && !structIsEmpty( arguments.directory ) ){
			arguments.bundles = getSpecPaths( arguments.directory );
		}

		// inflate labels if passed
		if( structKeyExists( arguments, "labels" ) ){ inflateLabels( arguments.labels ); }
		// if bundles passed, inflate those as the target
		if( structKeyExists( arguments, "bundles" ) ){ inflateBundles( arguments.bundles ); }
		
		// create results object
		var results = new coldbox.system.testing.TestResult( bundleCount=arrayLen( variables.bundles ), 
															 labels=variables.labels,
															 testSuites=arguments.testSuites,
															 testSpecs=arguments.testSpecs );
		
		// iterate and run the test bundles
		for( var thisBundlePath in variables.bundles ){
			testBundle( thisBundlePath, results );
		}
		
		// mark end of testing bundles
		results.end();
		
		return results;
	}

	/**
	* Run me some testing goodness, remotely via SOAP, Flex, REST, URL
	* @bundles.hint The path or list of paths of the spec bundle CFCs to run and test
	* @directory.hint The directory mapping to test: directory = the path to the directory using dot notation (myapp.testing.specs)
	* @recurse.hint Recurse the directory mapping or not, by default it does
	* @reporter.hint The type of reporter to use for the results, by default is uses our 'simple' report. You can pass in a core reporter string type or a class path to the reporter to use.
	* @reporterOptions.hint A JSON struct literal of options to pass into the reporter
	* @labels.hint The list of labels that a suite or spec must have in order to execute.
	* @options.hint A JSON struct literal of configuration options that are optionally used to configure a runner.
	* @testSuites.hint A list of suite names that are the ones that will be executed ONLY!
	* @testSpecs.hint A list of test names that are the ones that will be executed ONLY!
	*/
	remote function runRemote( 
		string bundles,
		string directory,
		boolean recurse=true,
		string reporter="simple",
		string reporterOptions="{}",
		string labels="",
		string options,
		string testSuites="",
		string testSpecs=""
	) output=true {
		// local init
		init();

		// simple to complex
		arguments.labels 		= listToArray( arguments.labels );
		arguments.testSuites 	= listToArray( arguments.testSuites );
		arguments.testSpecs 	= listToArray( arguments.testSpecs );

		// options inflate from JSON
		if( structKeyExists( arguments, "options" ) and isJSON( arguments.options ) ){
			arguments.options = deserializeJSON( arguments.options );
		}
		else{
			arguments.options = {};
		}

		// Inflate directory?
		if( structKeyExists( arguments, "directory" ) and len( arguments.directory ) ){
			arguments.directory = { mapping = arguments.directory, recurse = arguments.recurse };
		}

		// reporter options inflate from JSON
		if( structKeyExists( arguments, "reporterOptions" ) and isJSON( arguments.reporterOptions ) ){
			arguments.reporterOptions = deserializeJSON( arguments.reporterOptions );
		}
		else{
			arguments.reporterOptions = {};
		}
		
		// setup reporter
		if( structKeyExists( arguments, "reporter" ) and len( arguments.reporter ) ){ 
			variables.reporter = { type = arguments.reporter, options = arguments.reporterOptions }; 
		}

		// run it and get results
		var results = runRaw( argumentCollection=arguments );

		// check if reporter is "raw" and if raw, just return it
		if( variables.reporter.type == "raw" ){
			return produceReport( results );
		}
		else{
			// return report
			writeOutput( produceReport( results ) );
		}
	}

	/************************************** REPORTING COMMON METHODS *********************************************/

	/**
	* Build a report according to this runner's setup reporter, which can be anything.
	* @results.hint The results object to use to produce a report
	*/
	private any function produceReport( required results ){
		var iData = { type="", options={} };

		// If the type is a simple value then inflate it
		if( isSimpleValue( variables.reporter ) ){
			iData = { type=buildReporter( variables.reporter ), options={} };
		}

		// If the incoming reporter is an object.
		if( isObject( variables.reporter ) ){
			iData = { type=variables.reporter, options={} };
		}

		// Do we have reporter type and options
		if( isStruct( variables.reporter ) ){
			iData.type = buildReporter( variables.reporter.type );
			if( structKeyExists( variables.reporter, "options" ) ){
				iData.options = variables.reporter.options;
			}
		}
		// build the report from the reporter
		return iData.type.runReport( arguments.results, this, iData.options );
	}

	/**
	* Build a reporter according to passed in reporter type or class path
	* @reporter.hint The reporter type to build.
	*/
	private any function buildReporter( required reporter ){

		switch( arguments.reporter ){
			case "json" : { return new "coldbox.system.testing.reports.JSONReporter"(); }
			case "xml" : { return new "coldbox.system.testing.reports.XMLReporter"(); }
			case "raw" : { return new "coldbox.system.testing.reports.RawReporter"(); }
			case "simple" : { return new "coldbox.system.testing.reports.SimpleReporter"(); }
			case "dot" : { return new "coldbox.system.testing.reports.DotReporter"(); }
			case "text" : { return new "coldbox.system.testing.reports.TextReporter"(); }
			case "junit" : { return new "coldbox.system.testing.reports.JUnitReporter"(); }
			case "console" : { return new "coldbox.system.testing.reports.ConsoleReporter"(); }
			case "min" : { return new "coldbox.system.testing.reports.MinReporter"(); }
			case "tap" : { return new "coldbox.system.testing.reports.TapReporter"(); }
			default: {
				return new "#arguments.reporter#"();
			}
		}
	}

	/***************************************** PRIVATE ************************************************************ //

	/**
	* This method tests a bundle CFC according to type
	* @bundlePath.hint The path of the Bundle CFC to test.
	* @testResults.hint The testing results object to keep track of results
	*/
	private function testBundle(
		required bundlePath, 
		required testResults
	){
		
		// create new target bundle and get its metadata
		var target = getBundle( arguments.bundlePath );
		
		// Discover type?
		if( structKeyExists( target, "run" ) ){
			// BDD Style
			new coldbox.system.testing.runners.BDDRunner( options=variables.options )
				.run( target, arguments.testResults );
		}
		else{
			// xUnit Style
			new coldbox.system.testing.runners.UnitRunner( options=variables.options )
				.run( target, arguments.testResults );
		}
		
		return this;
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
	* Get an array of spec paths from a directory
	* @directory.hint The directory information struct to test: [ mapping = the path to the directory using dot notation (myapp.testing.specs), recurse = boolean, filter = closure that receives the path of the CFC found, it must return true to process or false to continue process ]
	*/
	private function getSpecPaths( required directory ){
		var results = [];

		// recurse default
		arguments.directory.recurse = ( structKeyExists( arguments.directory, "recurse" ) ? arguments.directory.recurse : true );
		// clean up paths
		var bundleExpandedPath 	= expandPath( "/" & replace( arguments.directory.mapping, ".", "/", "all" ) );
		bundleExpandedPath 		= replace( bundleExpandedPath, "\", "/", "all" );
		// search directory with filters
		var bundlesFound 		= directoryList( bundleExpandedPath, arguments.directory.recurse, "path", "*.cfc", "asc" );

		// cleanup paths and store them for usage
		for( var x=1; x lte arrayLen( bundlesFound ); x++ ){

			// filter closure exists and the filter does not match the path
			if( structKeyExists( arguments.directory, "filter" ) && !arguments.directory.filter( bundlesFound[ x ] ) ){
				continue;
			}

			// standardize paths
			bundlesFound[ x ] = rereplace( replaceNoCase( bundlesFound[ x ], ".cfc", "" ) , "(\\|/)", "/", "all" );
			// clean base out of them
			bundlesFound[ x ] = replace( bundlesFound[ x ], bundleExpandedPath, "" );
			// Clean out slashes and append the mapping.
			bundlesFound[ x ] = arguments.directory.mapping & rereplace( bundlesFound[ x ], "(\\|/)", ".", "all" );

			arrayAppend( results, bundlesFound[ x ] );
		}

		return results;
	}

	/**
	* Inflate incoming labels from a simple string as a standard array
	*/
	private function inflateLabels(required any labels){
		variables.labels = ( isSimpleValue( arguments.labels ) ? listToArray( arguments.labels ) : arguments.labels );
	}

	/**
	* Inflate incoming bundles from a simple string as a standard array
	*/
	private function inflateBundles(required any bundles){
		variables.bundles = ( isSimpleValue( arguments.bundles ) ? listToArray( arguments.bundles ) : arguments.bundles );
	}

}