/**
********************************************************************************
Copyright 2005-2009 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
* This is a base spec object that is used to test XUnit and BDD style specification methods
*/ 
component{
			
	// MockBox mocking framework
	variables.$mockBox = this.$mockBox 	= new coldbox.system.testing.MockBox();
	// Assertions object
	variables.$assert = this.$assert = new coldbox.system.testing.Assertion();
	// Custom Matchers
	this.$customMatchers 		= {};
	// Utility object
	this.$utility 				= new coldbox.system.core.util.Util();
	// BDD Test Suites are stored here as an array so they are executed in order of definition
	this.$suites 				= [];
	// A reverse lookup for the suite definitions
	this.$suiteReverseLookup	= {};
	// The suite context
	this.$suiteContext			= "";
	// ExpectedException Annotation
	this.$exceptionAnnotation	= "expectedException";
	// Expected Exception holder, only use on synchronous testing.
	this.$expectedException		= {};
	// Internal testing ID
	this.$testID 				= createUUID();
	// Debug buffer
	this.$debugBuffer			= [];

	/************************************** BDD & EXPECTATIONS METHODS *********************************************/
	
	/**
	* Expect an exception from the testing spec
	* @type.hint The type to expect
	* @regex.hint Optional exception message regular expression to match, by default it matches .*
	*/
	function expectedException( type="", regex=".*" ){
		this.$expectedException = arguments;
		return this;
	}

	/**
	* Assert that the passed expression is true
	* @facade
	*/
	function assert( required expression, message="" ){
		return this.$assert.assert(argumentCollection=arguments);
	}

	/**
	* Fail an assertion
	* @facade
	*/
	function fail( message="" ){
		this.$assert.fail(argumentCollection=arguments);
	}

	/**
	* This function is used for BDD test suites to store the beforeEach() function to execute for a test suite group
	* @body.hint The closure function
	*/
	function beforeEach( required any body ){
		this.$suitesReverseLookup[ this.$suiteContext ].beforeEach = arguments.body;
	}

	/**
	* This function is used for BDD test suites to store the afterEach() function to execute for a test suite group
	* @body.hint The closure function
	*/
	function afterEach( required any body ){
		this.$suitesReverseLookup[ this.$suiteContext ].afterEach = arguments.body;
	}

	/**
	* The way to describe BDD test suites in TestBox. The title is usually what you are testing or grouping of tests.
	* The body is the function that implements the suite.
	* @title.hint The name of this test suite
	* @body.hint The closure that represents the test suite
	* @labels The list or array of labels this suite group belongs to
	* @asyncAll If you want to parallelize the execution of the defined specs in this suite group.
	* @skip A flag or a closure that tells TestBox to skip this suite group from testing if true. If this is a closure it must return boolean.
	*/
	any function describe(
		required string title,
		required any body,
		any labels=[],
		boolean asyncAll=false,
		any skip=false
	){

		// closure checks
		if( !isClosure( arguments.body ) ){
			throw( type="TestBox.InvalidBody", message="The body of this test suite must be a closure and you did not give me one, what's up with that!" );
		}

		var suite = {
			// suite name
			name 		= arguments.title,
			// async flag
			asyncAll 	= arguments.asyncAll,
			// skip suite testing
			skip 		= arguments.skip,
			// labels attached to the suite for execution
			labels 		= ( isSimpleValue( arguments.labels ) ? listToArray( arguments.labels ) : arguments.labels ),
			// the test specs for this suite
			specs 		= [],
			// the recursive suites
			suites 		= [],
			// the beforeEach closure
			beforeEach 	= variables.closureStub,
			// the afterEach closure
			afterEach 	= variables.closureStub,
			// the parent suite
			parent 		= "",
			// hiearachy slug
			slug 		= ""
		};

		// skip constraint for suite as a closure
		if( isClosure( arguments.skip ) || isCustomFunction( arguments.skip ) ){
			suite.skip = arguments.skip();
		}

		// Are we in a nested describe() block
		if( len( this.$suiteContext ) and this.$suiteContext neq arguments.title ){
			// Append this suite to the nested suite.
			arrayAppend( this.$suitesReverseLookup[ this.$suiteContext ].suites, suite );
			this.$suitesReverseLookup[ arguments.title ] = suite;
			
			// Setup parent reference
			suite.parent = this.$suiteContext;

			// Build hiearachy slug separated by /
			suite.slug = this.$suitesReverseLookup[ this.$suiteContext ].slug & "/" & this.$suiteContext;
			if( left( suite.slug, 1) != "/" ){ suite.slug = "/" & suite.slug; }
				
			// Store parent context
			var parentContext 	= this.$suiteContext;
			var parentSpecIndex = this.$specOrderIndex;
			// Switch contexts and go deep
			this.$suiteContext 		= arguments.title;
			this.$specOrderIndex 	= 1;
			// execute the test suite definition with this context now.
			arguments.body();
			// switch back the context to parent
			this.$suiteContext 		= parentContext;
			this.$specOrderIndex 	= parentSpecIndex;
		}
		else{
			// Append this spec definition to the master root
			arrayAppend( this.$suites, suite );
			// setup pivot context now and reverse lookups
			this.$suiteContext 		= arguments.title;
			this.$specOrderIndex 	= 1;
			this.$suitesReverseLookup[ arguments.title ] = suite;
			// execute the test suite definition with this context now.
			arguments.body();
			// reset context, finalized it already.
			this.$suiteContext = "";
		}

		// Restart spec index
		this.$specOrderIndex 	= 1;

		return this;
	}

	/**
	* The it() function describes a spec or a test in TestBox.  The body argument is the closure that implements
	* the test which usually contains one or more expectations that test the state of the code under test.
	* @title.hint The title of this spec
	* @body.hint The closure that represents the test
	* @labels The list or array of labels this spec belongs to
	* @skip A flag or a closure that tells TestBox to skip this spec test from testing if true. If this is a closure it must return boolean.
	*/
	any function it(
		required string title,
		required any body,
		any labels=[],
		any skip=false
	){
		// closure checks
		if( !isClosure( arguments.body ) ){
			throw( type="TestBox.InvalidBody", message="The body of this test suite must be a closure and you did not give me one, what's up with that!" );
		}

		// Context checks
		if( !len( this.$suiteContext ) ){
			throw( type="TestBox.InvalidContext", message="You cannot define a spec without a test suite! This it() must exist within a describe() body! Go fix it :)" );
		}

		// define the spec
		var spec = {
			// spec title
			name 		= arguments.title,
			// skip spec testing
			skip 		= arguments.skip,
			// labels attached to the spec for execution
			labels 		= ( isSimpleValue( arguments.labels ) ? listToArray( arguments.labels ) : arguments.labels ),
			// the spec body
			body 		= arguments.body,
			// The order of execution
			order 		= this.$specOrderIndex++
		};

		// skip constraint for suite as a closure
		if( isClosure( arguments.skip ) || isCustomFunction( arguments.skip ) ){
			spec.skip = arguments.skip();
		}

		// Attach this spec to the incoming context array of specs
		arrayAppend( this.$suitesReverseLookup[ this.$suiteContext ].specs, spec );
		
		return this;
	}

	/**
	* This is a convenience method that makes sure the test suite is skipped from execution
	* @title.hint The name of this test suite
	* @body.hint The closure that represents the test suite
	* @labels The list or array of labels this suite group belongs to
	* @asyncAll If you want to parallelize the execution of the defined specs in this suite group.
	*/
	any function xdescribe(
		required string title,
		required any body,
		any labels=[],
		boolean asyncAll=false
	){
		arguments.skip = true;
		return describe( argumentCollection=arguments );
	}

	/**
	* This is a convenience method that makes sure the test spec is skipped from execution
	* @title.hint The title of this spec
	* @body.hint The closure that represents the test
	* @labels The list or array of labels this spec belongs to
	*/
	any function xit(
		required string title,
		required any body,
		any labels=[]
	){
		arguments.skip = true;
		return it( argumentCollection=arguments );
	}

	/**
	* Start an expectation expression. This returns an instance of Expectation so you can work with its matchers.
	* @actual.hint The actual value, it is not required as it can be null.
	*/
	Expectation function expect( any actual ){
		// build an expectation
		var oExpectation = new Expectation( spec=this, assertions=this.$assert, mockbox=this.$mockbox );

		// Store the actual data
		if( !isNull( arguments.actual ) ){
			oExpectation.actual = arguments.actual;
		}
		else{
			oExpectation.actual = javacast( "null", "" );
		}

		// Do we have any custom matchers to add to this expectation?
		if( !structIsEmpty( this.$customMatchers ) ){
			for( var thisMatcher in this.$customMatchers ){
				oExpectation.registerMatcher( thisMatcher, this.$customMatchers[ thisMatcher ] );
			}
		}

		return oExpectation;
	}
	
	/**
	* Add custom matchers to your expectations
	* @matchers.hint The structure of custom matcher functions to register or a path or instance of a CFC containing all the matcher functions to register
	*/
	function addMatchers( required any matchers ){
		// register structure
		if( isStruct( arguments.matchers ) ){
			// register the custom matchers with override
			structAppend( this.$customMatchers, arguments.matchers, true );
			return this;
		}

		// Build the Matcher CFC
		var oMatchers = "";
		if( isSimpleValue( arguments.matchers ) ){
			oMatchers = new "#arguments.matchers#"();
		}
		else if( isObject( arguments.matchers ) ){
			oMatchers = arguments.matchers;
		}
		else{
			throw(type="TestBox.InvalidCustomMatchers", message="The matchers argument you sent is not valid, it must be a struct, string or object");
		}

		// Register the methods into our custom matchers struct
		var matcherArray = structKeyArray( oMatchers );
		for( var thisMatcher in matcherArray ){
			this.$customMatchers[ thisMatcher ] = oMatchers[ thisMatcher ];
		}

		return this;
	}

	/**
	* Add custom assertions to the $assert object 
	* @assertions.hint The structure of custom assertion functions to register or a path or instance of a CFC containing all the assertion functions to register
	*/
	function addAssertions( required any assertions ){
		// register structure
		if( isStruct( arguments.assertions ) ){
			// register the custom matchers with override
			structAppend( this.$assert, arguments.assertions, true );
			return this;
		}

		// Build the Custom Assertion CFC
		var oAssertions = "";
		if( isSimpleValue( arguments.assertions ) ){
			oAssertions = new "#arguments.assertions#"();
		}
		else if( isObject( arguments.assertions ) ){
			oAssertions = arguments.assertions;
		}
		else{
			throw(type="TestBox.InvalidCustomAssertions", message="The assertions argument you sent is not valid, it must be a struct, string or object");
		}

		// Register the methods into our custom assertions struct
		var methodArray = structKeyArray( oAssertions );
		for( var thisMethod in methodArray ){
			this.$assert[ thisMethod ] = oAssertions[ methodArray ];
		}

		return this;
	}

	/************************************** RUN BDD METHODS *********************************************/
	
	/**
	* Run a test remotely, only useful if the spec inherits from this class. Useful for remote executions.
	* @testSuites.hint A list or array of suite names that are the ones that will be executed ONLY!
	* @testSpecs.hint A list or array of test names that are the ones that will be executed ONLY!
	* @debug.hint Show debug output on the reports or not
	* @reporter.hint The type of reporter to run the test with
	*/
	remote function runRemote( string testSpecs="", string testSuites="", boolean debug=false, string reporter="simple" ) output=true{
		var runner = new coldbox.system.testing.TestBox( bundles="#getMetadata(this).name#", reporter=arguments.reporter );

		// Produce report
		writeOutput( runner.run( testSuites=arguments.testSuites, testSpecs=arguments.testSpecs ) );
	}
	
	/**
	* Run a BDD test in this target CFC
	* @spec.hint The spec definition to test
	* @suite.hint The suite definition this spec belongs to
	* @testResults.hint The testing results object
	* @suiteStats.hint The suite stats that the incoming spec definition belongs to
	* @runner.hint The runner calling this BDD test
	*/
	function runSpec(
		required spec,
		required suite,
		required testResults,
		required suiteStats,
		required runner
	){
			
		try{
			
			// init spec tests
			var specStats = arguments.testResults.startSpecStats( arguments.spec.name, arguments.suiteStats );
			
			// Verify we can execute
			if( !arguments.spec.skip && 
				arguments.runner.canRunLabel( arguments.spec.labels, arguments.testResults ) &&
				arguments.runner.canRunSpec( arguments.spec.name, arguments.testResults )
			){

				// execute beforeEach()
				arguments.suite.beforeEach( currentSpec=arguments.spec.name );
				
				// Execute the Spec body
				arguments.spec.body();
				
				// execute afterEach()
				arguments.suite.afterEach( currentSpec=arguments.spec.name );
				
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
		catch( "TestBox.AssertionFailed" e ){
			// store spec status and debug data
			specStats.status 		= "Failed";
			specStats.failMessage 	= e.message;
			specStats.failOrigin 	= e.tagContext;
			// Increment recursive pass stats
			arguments.testResults.incrementSpecStat( type="fail", stats=specStats );
		}
		// Catch errors
		catch( any e ){
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
	* Runs a xUnit style test method in this target CFC
	* @spec.hint The spec definition to test
	* @testResults.hint The testing results object
	* @suiteStats.hint The suite stats that the incoming spec definition belongs to
	* @runner.hint The runner calling this BDD test
	*/
	function runTestMethod(
		required spec,
		required testResults,
		required suiteStats,
		required runner
	){
			
		try{
			
			// init spec tests
			var specStats = arguments.testResults.startSpecStats( arguments.spec.name, arguments.suiteStats );
			
			// Verify we can execute
			if( !arguments.spec.skip &&
				arguments.runner.canRunLabel( arguments.spec.labels, arguments.testResults ) &&
				arguments.runner.canRunSpec( arguments.spec.name, arguments.testResults )
			){

				// Reset expected exceptions: Only works on synchronous testing.
				this.$expectedException = {};

				// execute setup()
				if( structKeyExists( this, "setup" ) ){ this.setup( currentMethod=arguments.spec.name ); }
				
				// Execute Spec
				try{
					evaluate( "this.#arguments.spec.name#()" );
				}
				catch( Any e ){
					if( !isExpectedException( e, arguments.spec.name, arguments.runner ) ){ rethrow; }
				}

				// execute teardown()
				if( structKeyExists( this, "teardown" ) ){ this.teardown( currentMethod=arguments.spec.name ); }
				
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
		catch( "TestBox.AssertionFailed" e ){
			// store spec status and debug data
			specStats.status 		= "Failed";
			specStats.failMessage 	= e.message;
			specStats.failOrigin 	= e.tagContext;
			// Increment recursive pass stats
			arguments.testResults.incrementSpecStat( type="fail", stats=specStats );
		}
		// Catch errors
		catch( any e ){
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

	/************************************** UTILITY METHODS *********************************************/
	
	/**
	* Send some information to the console via writedump( output="console" )
	* @var.hint The data to send
	* @top.hint Apply a top to the dump, by default it does 9999 levels
	*/
	any function console( required var, top=9999 ){
		writedump( var=arguments.var, output="console", top=arguments.top );
		return this;
	}
	
	/**
	* Debug some information into the TestBox debugger array buffer
	* @var.hint The data to send
	* @deepCopy.hint By default we do not duplicate the incoming information, but you can :)
	*/
	any function debug( var, boolean deepCopy=false ){
		if( isNull( arguments.var ) ){ arrayAppend( this.$debugBuffer, "null" ); return; }
		lock name="tb-debug-#this.$testID#" type="exclusive" timeout="10"{
			var newVar = ( arguments.deepCopy ? duplicate( arguments.var ) : arguments.var );
			arrayAppend( this.$debugBuffer, newVar );
		}
		return this;
	}

	/**
	*  Clear the debug array buffer
	*/
	any function clearDebugBuffer(){
		lock name="tb-debug-#this.$testID#" type="exclusive" timeout="10"{
			arrayClear( this.$debugBuffer );
		}
		return this;
	}

	/**
	*  Get the debug array buffer from scope
	*/
	array function getDebugBuffer(){
		lock name="tb-debug-#this.$testID#" type="readonly" timeout="10"{
			return this.$debugBuffer;
		}
	}

	/**
	* Write some output to the ColdFusion output buffer
	*/
	any function print(required message) output=true{
		writeOutput( arguments.message );
		return this;
	}
	
	/**
	* Write some output to the ColdFusion output buffer using a <br> attached
	*/
	any function println(required message) output=true{
		return print( arguments.message & "<br>" );
	}
	
	/************************************** MOCKING METHODS *********************************************/
	
	/**
	* Make a private method on a CFC public with or without a new name and returns the target object
	* @target.hint The target object to expose the method
	* @method.hint The private method to expose
	* @newName.hint If passed, it will expose the method with this name, else just uses the same name
	*/
	any function makePublic( required any target, required string method, string newName="" ){
		
		// mix it
		arguments.target.$exposeMixin = this.$utility.getMixerUtil().exposeMixin;
		// expose it
		arguments.target.$exposeMixin( arguments.method, arguments.newName );

		return arguments.target;
	}

	/**
	* First line are the query columns separated by commas. Then do a consecuent rows separated by line breaks separated by | to denote columns.
	*/
	function querySim(required queryData){
		return this.$mockBox.querySim( arguments.queryData );
	}
	
	/**
	* Get a reference to the MockBox engine 
	* @generationPath.hint The path to generate the mocks if passed, else uses default location.
	*/
	function getMockBox( string generationPath ){
		if( structKeyExists( arguments, "generationPath" ) ){
			this.$mockBox.setGenerationPath( arguments.generationPath );
		}
		return this.$mockBox;
	}

	/**
	* Create an empty mock
	* @className.hint The class name of the object to mock. The mock factory will instantiate it for you
	* @object.hint The object to mock, already instantiated
	* @callLogging.hint Add method call logging for all mocked methods. Defaults to true
	*/
	function createEmptyMock(
		string className,
		any object,
		boolean callLogging=true
	){
		return this.$mockBox.createEmptyMock( argumentCollection=arguments );
	}

	/**
	* Create a mock with or without clearing implementations, usually not clearing means you want to build object spies
	* @className.hint The class name of the object to mock. The mock factory will instantiate it for you
	* @object.hint The object to mock, already instantiated
	* @clearMethods.hint If true, all methods in the target mock object will be removed. You can then mock only the methods that you want to mock. Defaults to false
	* @callLogging.hint Add method call logging for all mocked methods. Defaults to true
	*/
	function createMock(
		string className,
		any object,
		boolean clearMethods=false
		boolean callLogging=true
	){
		return this.$mockBox.createMock( argumentCollection=arguments );
	}

	/**
	* Prepares an already instantiated object to act as a mock for spying and much more
	* @object.hint The object to mock, already instantiated
	* @callLogging.hint Add method call logging for all mocked methods. Defaults to true
	*/
	function prepareMock(
		any object,
		boolean callLogging=true
	){
		return this.$mockBox.prepareMock( argumentCollection=arguments );
	}

	/**
	* Create an empty stub object that you can use for mocking
	* @callLogging.hint Add method call logging for all mocked methods. Defaults to true
	* @extends.hint Make the stub extend from certain CFC
	* @implements.hint Make the stub adhere to an interface
	*/
	function createStub(
		boolean callLogging=true,
		string extends="",
		string implements=""
	){
		return this.$mockBox.createStub( argumentCollection=arguments );
	}	
	
	// Closure Stub
	function closureStub(){}

	/************************************** PRIVATE METHODS *********************************************/

	/**
	* Check if the incoming exception is expected or not.
	*/
	private boolean function isExpectedException( required exception, required specName, required runner ){
		var results = false;
		// do we have an expected annotation?
		var eAnnotation = arguments.runner.getMethodAnnotation( this[ arguments.specName ], this.$exceptionAnnotation, "false" );
		if( eAnnotation != false ){
			// incorporate it.
			this.$expectedException = {
				type =  ( eAnnotation == "true" ? "" : listFirst( eAnnotation, ":" ) ),
				regex = ( find( ":", eAnnotation ) ? listLast( eAnnotation, ":" ) : ".*" )
			};
		}
		
		// Verify expected exceptions
		if( !structIsEmpty( this.$expectedException ) ){
			// If no type, message expectations
			if( !len( this.$expectedException.type ) && this.$expectedException.regex eq ".*" ){
				results = true;
			}
			// Type expectation then
			else if( len( this.$expectedException.type ) && 
					 arguments.exception.type eq this.$expectedException.type && 
					 reFindNoCase( this.$expectedException.regex, arguments.exception.message ) ){
				results = true;
			}
			// Message regex then only
			else if( this.$expectedException.regex neq ".*" && reFindNoCase( this.$expectedException.regex, arguments.exception.message ) ){
				results = true;
			}
		}

		return results;
	}
}