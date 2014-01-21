/**
* This is the TestBox MXUnit compatible object. You can use this object as a direct replacement
* To MXUnit BaseTest Case.
* All assertions found in this object delegate to our core Assertion object.
*/
component extends="coldbox.system.testing.BaseSpec"{

	// ExpectedException Annotation
	this.$exceptionAnnotation	= "mxunit:expectedException";

/*********************************** LIFE-CYCLE Methods ***********************************/
	
	// Added signatures for backwards compat
	function init(){ return this; }
	function setup(){}
	function teardown(){}
	function afterTests(){}
	function beforeTests(){}

/*********************************** RUNNER Methods ***********************************/

	/**
	* Run a test remotely like MXUnit
	* @testMethod.hint A list or array of test names that are the ones that will be executed ONLY!
	* @debug.hint Show debug output on the reports or not
	* @output.hint The type of reporter to run the test with
	*/
	remote function runTestRemote(any testMethod="", boolean debug=false, output="simple") output=true{

		switch( arguments.output ){
			case "junitxml" : { arguments.output = "junit"; break; } 
			case "query" 	: case "array" : { arguments.output = "raw"; break; }
			case "html" 	: { arguments.output = "simple"; break; }
			default 		: { arguments.output = "simple"; }
		}

		var runner = new coldbox.system.testing.TestBox( bundles="#getMetadata( this ).name#", reporter=arguments.output );

		// Produce report
		writeOutput( runner.run( testSpecs=arguments.testMethod ) );
	}

/*********************************** UTILITY Methods ***********************************/

	/**
	* Utility for dynamically adding assertion behaviors at runtime
	* @decoratorName.hint The fully qualied name of the assertion component to add; e.g., org.mycompany.MyAssertionComponent
	*/
	function addAssertDecorator( required string decoratorName ){
		var oDecorator = new "#arguments.decoratorName#"();
		var aFunctions = getMetadata( oDecorator ).functions;
		
		// iterate and add
		for( var x=1; x lte arrayLen( aFunctions ); x++ ){
			var thisFunction = aFunctions[ x ];
			if( !structKeyExists( thisFunction, "access" ) or thisFunction.access eq "public" ){
				variables[ thisFunction.name ] 	= oDecorator[ thisFunction.name ];
				this[ thisFunction.name ] 		= oDecorator[ thisFunction.name ];
			}
		}

		return this;
	}

	function setMockingFramework(){ 
		// does nothing, we always use MockBox 
	}

	function getMockFactory(){
		return getMockBox();
	}

	function mock( mocked ){
		return createMock( arguments.mocked );
	}

	/**
	* MXUnit style debug
	* @var.hint The variable to debug
	*/
	function debug( required var ){
		arguments.deepCopy = true;
		super.debug( argumentCollection=arguments );
	}

	/**
	* Expect an exception from the testing spec
	* @expectedExceptionType.hint the type to expect
	* @expectedExceptionMessage.hint Optional exception message
	*/
	function expectException( expectedExceptionType, expectedExceptionMessage=".*" ){
		super.expectedException( arguments.expectedExceptionType, arguments.expectedExceptionMessage );
	}

	/**
	* Injects properties into the receiving object
	*/
	any function injectProperty( 
		required any receiver, 
		required string propertyName, 
		required any propertyValue,
		string scope="variables"
	){
		// Mock it baby
		getMockBox().prepareMock( arguments.receiver )
			.$property( propertyName=arguments.propertyName, 
						propertyScope=arguments.scope, 
						mock=arguments.propertyValue );

		return arguments.receiver;
	}

	/**
	* injects the method from giver into receiver. This is helpful for quick and dirty mocking
	*/
	any function injectMethod( 
		required any receiver, 
		required any giver, 
		required string functionName,
		string functionNameInReceiver="#arguments.functionName#"
	){
		// Mock it baby
		getMockBox().prepareMock( arguments.giver );
		
		// inject it.
		if( structkeyexists( arguments.giver, arguments.functionName ) ){
			arguments.receiver[ arguments.functionNameInReceiver ] = arguments.giver.$getProperty( name=arguments.functionName, scope="this" );
		} else {
			arguments.receiver[ arguments.functionNameInReceiver ] = arguments.giver.$getProperty( name=arguments.functionName, scope="variables" );
		}
		
		return arguments.receiver;
	}
	
/*********************************** ASSERTION METHODS ***********************************/

	/**
	* Fail assertion
	* @message.hint The message to fail with
	*/
	function fail( message="" ){
		this.$assert.fail( arguments.message );
	}

	/**
	* Assert that the passed expression is true
	*/
	function assert( required string condition, message="" ){
		this.$assert.isTrue( arguments.condition, arguments.message );
	}

	/**
	* Compares two arrays, element by element, and fails if differences exist
	*/
	function assertArrayEquals( required array expected, required array actual, message="" ){
		this.$assert.isEqual( arguments.expected, arguments.actual, arguments.message );
	}

	/**
	* Core assertion that compares the values the EXPECTED and ACTUAL parameters
	*/
	function assertEquals( required any expected, required any actual, message="" ){
		this.$assert.isEqual( arguments.expected, arguments.actual, arguments.message );
	}

	/**
	* Core assertion that compares the values the EXPECTED and ACTUAL parameters with case-sensitivity
	*/
	function assertEqualsCase( required any expected, required any actual, message="" ){
		this.$assert.isEqualWithCase( arguments.expected, arguments.actual, arguments.message );
	}

	/**
	* Assert something is false
	*/
	function assertFalse( required string condition, message="" ){
		this.$assert.isFalse( arguments.condition, arguments.message );
	}

	/**
	* Core assertion that compares the values the EXPECTED and ACTUAL parameters to NOT be equal
	*/
	function assertNotEquals( required any expected, required any actual, message="" ){
		this.$assert.isNotEqual( arguments.expected, arguments.actual, arguments.message );
	}

	/**
	* Assert that an expected and actual objec is NOT the same instance
	* This only works on objects that are passed by reference, please remember that in Railo
	* arrays pass by reference and in Adobe CF they pass by value.
	*/
	function assertNotSame( required expected, required actual, message="" ){
		this.$assert.isNotEqual( arguments.expected, arguments.actual, arguments.message );
	}

	/**
	* Compares 2 queries, cell by cell, and fails if differences exist
	*/
	function assertQueryEquals( required query expected, required query actual, message="" ){
		this.$assert.isEqual( arguments.expected, arguments.actual, arguments.message );
	}

	/**
	* Assert that an expected and actual objec is the same instance
	* This only works on objects that are passed by reference, please remember that in Railo
	* arrays pass by reference and in Adobe CF they pass by value.
	*/
	function assertSame( required expected, required actual, message="" ){
		this.$assert.isEqual( arguments.expected, arguments.actual, arguments.message );
	}

	/**
	* Compares two structures, key by key, and fails if differences exist
	*/
	function assertStructEquals( required struct expected, required struct actual, message="" ){
		this.$assert.isEqual( arguments.expected, arguments.actual, arguments.message );
	}

	/**
	* Assert something is true
	*/
	function assertTrue( required string condition, message="" ){
		this.$assert.isTrue( arguments.condition, arguments.message );
	}

	/**
	* Assert something is array
	*/
	function assertIsArray( required a, message="" ){
		this.$assert.typeOf( "array", arguments.a, arguments.message );
	}

	/**
	* Assert something is query
	*/
	function assertIsQuery( required q, message="" ){
		this.$assert.typeOf( "query", arguments.q, arguments.message );
	}

	/**
	* Assert something is struct
	*/
	function assertIsStruct( required actual, message="" ){
		this.$assert.typeOf( "struct", arguments.actual, arguments.message );
	}

	/**
	* Assert something is of a certrain object type
	*/
	function assertIsTypeOf( required actual, required typeName, message="" ){
		this.$assert.instanceOf( arguments.actual, arguments.typeName, arguments.message );
	}

	/**
	* Assert something is of a certrain object type without any inheritance lookup
	*/
	function assertIsExactTypeOf( required o, required type, message="" ){
		this.$assert.isEqual( arguments.type, getMetadata( arguments.o ).name, arguments.message );
	}

	/**
	* Assert something is defined or not
	*/
	function assertIsDefined( required o, message="" ){
		this.$assert.isTrue( isDefined( evaluate( "arguments.o" ) ) , arguments.message );
	}

	/**
	* Assert something is an XMLDoc
	*/
	function assertIsXMLDoc( required xml, message="Passed in xml is not a valid XML Object" ){
		this.$assert.isTrue( isXMLDoc( arguments.xml ), arguments.message );
	}

	/**
	* Assert array is empty
	*/
	function assertIsEmptyArray( required a, message="" ){
		this.$assert.isEqual( 0, arrayLen( arguments.a ), arguments.message );
	}

	/**
	* Assert query is empty
	*/
	function assertIsEmptyQuery( required q, message="" ){
		this.$assert.isEqual( 0, arguments.q.recordcount, arguments.message );
	}

	/**
	* Assert struct is empty
	*/
	function assertIsEmptyStruct( required struct, message="" ){
		this.$assert.isEqual( 0, structCount( arguments.struct ), arguments.message );
	}

	/**
	* Assert string is empty
	*/
	function assertIsEmpty( required o, message="" ){
		this.$assert.isEqual( 0, len( arguments.o ) , arguments.message );
	}

	/**
	* Assert that the passed in actual number or date is expected to be close to it within +/- a passed delta and optional datepart
	*/
	function assertEqualsWithTolerance( 
		required expected, 
		required actual, 
		required numeric tolerance, 
		datePart="",
		message="" 
	){
		this.$assert.closeTo( arguments.expected, arguments.actual, arguments.tolerance, arguments.datePart, arguments.message );
	}

}