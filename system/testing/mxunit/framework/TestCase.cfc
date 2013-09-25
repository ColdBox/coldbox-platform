/**
* This is the TestBox MXUnit compatible object. You can use this object as a direct replacement
* To MXUnit BaseTest Case.
* All assertions found in this object delegate to our core Assertion object.
*/
component extends="coldbox.system.testing.BaseSpec"{

	this.$expectException = {};

/*********************************** RUNNER Methods ***********************************/

	remote function run(any testResult){
		// TODO: implement
	}

	remote function runTestRemote(any testMethod, boolean debug=false, output="html"){
		// TODO: implement
	}

/*********************************** UTILITY Methods ***********************************/

	/**
	*  MXUnit style debug
	*/ 
	function debug(required var){
		arguments.deepCopy = true;
		super.debug( argumentCollection=arguments );
	}

	/**
	* Expect an exception from the testing spec
	*/
	function expectException(type, message=""){
		// TODO: implement
	}
/*********************************** ASSERTION METHODS ***********************************/

	/**
	* Fail assertion
	*/
	function fail(message=""){
		variables.$assert.fail( arguments.message );
	}
	
	/**
	* Assert that the passed expression is true
	*/
	function assert( required string condition, message="" ){
		variables.$assert.isTrue( arguments.condition, arguments.message );
	}

	/**
	* Compares two arrays, element by element, and fails if differences exist
	*/
	function assertArrayEquals( required array expected, required array actual, message="" ){
		variables.$assert.isEqual( arguments.expected, arguments.actual, arguments.message );
	}

	/**
	* Core assertion that compares the values the EXPECTED and ACTUAL parameters
	*/
	function assertEquals( required any expected, required any actual, message="" ){
		variables.$assert.isEqual( arguments.expected, arguments.actual, arguments.message );
	}

	/**
	* Core assertion that compares the values the EXPECTED and ACTUAL parameters with case-sensitivity
	*/
	function assertEqualsCase( required any expected, required any actual, message="" ){
		variables.$assert.isEqualWithCase( arguments.expected, arguments.actual, arguments.message );
	}
	
	/**
	* Assert something is false
	*/
	function assertFalse( required string condition, message="" ){
		variables.$assert.isFalse( arguments.condition, arguments.message );
	}

	/**
	* Core assertion that compares the values the EXPECTED and ACTUAL parameters to NOT be equal
	*/
	function assertNotEquals( required any expected, required any actual, message="" ){
		variables.$assert.isNotEqual( arguments.expected, arguments.actual, arguments.message );
	}
	
	/**
	* Assert that an expected and actual objec is NOT the same instance
	* This only works on objects that are passed by reference, please remember that in Railo
	* arrays pass by reference and in Adobe CF they pass by value.
	*/
	function assertNotSame( required expected, required actual, message="" ){
		variables.$assert.isNotEqual( arguments.expected, arguments.actual, arguments.message );
	}

	/**
	* Compares 2 queries, cell by cell, and fails if differences exist
	*/
	function assertQueryEquals( required query expected, required query actual, message="" ){
		variables.$assert.isEqual( arguments.expected, arguments.actual, arguments.message );
	}

	/**
	* Assert that an expected and actual objec is the same instance
	* This only works on objects that are passed by reference, please remember that in Railo
	* arrays pass by reference and in Adobe CF they pass by value.
	*/
	function assertSame( required expected, required actual, message="" ){
		variables.$assert.isEqual( arguments.expected, arguments.actual, arguments.message );
	}

	/**
	* Compares two structures, key by key, and fails if differences exist
	*/
	function assertStructEquals( required struct expected, required struct actual, message="" ){
		variables.$assert.isEqual( arguments.expected, arguments.actual, arguments.message );
	}

	/**
	* Assert something is true
	*/
	function assertTrue( required string condition, message="" ){
		variables.$assert.isTrue( arguments.condition, arguments.message );
	}

}