/**
* This is the TestBox MXUnit compatible object. You can use this object as a direct replacement
* To MXUnit BaseTest Case.
* All assertions found in this object delegate to our core Assertion object.
*/
component extends="coldbox.system.testing.BaseSpec"{

	// ExpectedException Annotation
	this.$exceptionAnnotation	= "mxunit:expectedException";

/*********************************** RUNNER Methods ***********************************/

	/**
	* Run a test remotely like MXUnit
	* @testMethod.hint A list or array of test names that are the ones that will be executed ONLY!
	* @debug.hint Show debug output on the reports or not
	* @output.hint The type of reporter to run the test with
	*/
	remote function runTestRemote(any testMethod="", boolean debug=false, output="simple") output=true{
		var runner = new coldbox.system.testing.TestBox( bundles="#getMetadata(this).name#", reporter=arguments.output );

		// Produce report
		writeOutput( runner.run( testSpecs=arguments.testMethod ) );
	}

/*********************************** UTILITY Methods ***********************************/

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
	function assertIsArray( required actual, message="" ){
		this.$assert.typeOf( "array", arguments.actual, arguments.message );
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

}