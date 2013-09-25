/**
* This object represents our Assertion style DSL for Unit style testing
*/
component{
	
	/**
	* Fail assertion
	* @message.hint The message to send in the failure
	*/
	function fail(message=""){
		arguments.message = ( len( arguments.message ) ? arguments.message : "A test failure occurred" );
		throw(type="TestBox.AssertionFailed", message=arguments.message);
	}
	
	/**
	* Assert that the passed expression is true
	* @expression.hint The expression to test
	* @message.hint The message to send in the failure
	*/
	function assert( required boolean actual, message="" ){
		return isTrue( arguments.expression, arguments.message );
	}
	
	/**
	* Assert something is true
	* @actual.hint The actual data to test
	* @message.hint The message to send in the failure
	*/
	function isTrue( required boolean actual, message="" ){
		arguments.message = ( len( arguments.message ) ? arguments.message : "Expected [#arguments.actual#] to be true" );
		if( NOT arguments.actual ){
			fail( arguments.message );
		}
		return this;
	}

	/**
	* Assert something is false
	* @actual.hint The actual data to test
	* @message.hint The message to send in the failure
	*/
	function isFalse( required boolean actual, message="" ){
		arguments.message = ( len( arguments.message ) ? arguments.message : "Expected [#arguments.actual#] to be false" );
		if( arguments.actual ){
			fail( arguments.message );
		}
		return this;
	}
	
	/**
	* Assert something is equal to each other, no case is required
	* @actual.hint The actual data to test
	* @expected.hint The expected data
	* @message.hint The message to send in the failure
	*/
	function equal( required any actual, required any expected, message="" ){
		arguments.message = ( len( arguments.message ) ? arguments.message : "Expected [#arguments.expected.toString()#] but received [#arguments.actual.toString()#]" );
		// validate equality
		if( equalize( arguments.actual, arguments.expected ) ){ return this; }
		// if we reach here, nothing is equal man!
		fail( arguments.message );
	}

	/**
	* Assert something is not equal to each other, no case is required
	* @actual.hint The actual data to test
	* @expected.hint The expected data
	* @message.hint The message to send in the failure
	*/
	function notEqual( required any actual, required any expected, message="" ){
		arguments.message = ( len( arguments.message ) ? arguments.message : "Expected [#arguments.expected.toString()#] to not be [#arguments.actual.toString()#]" );
		// validate equality
		if( !equalize( arguments.actual, arguments.expected ) ){ return this; }
		// if we reach here, they are equal!
		fail( arguments.message );
	}

	/**
	* Assert strings are equal to each other with case. 
	* @actual.hint The actual data to test
	* @expected.hint The expected data
	* @message.hint The message to send in the failure
	*/
	function equalWithCase( required string actual, required string expected, message="" ){
		arguments.message = ( len( arguments.message ) ? arguments.message : "Expected [#arguments.expected.toString()#] but received [#arguments.actual.toString()#]" );
		// equalize with case
		if( compare( arguments.actual, arguments.expected ) eq 0 ){ return this; }
		// if we reach here, nothing is equal man!
		fail( arguments.message );
	}

	/**
	* Assert something is null
	* @actual.hint The actual data to test
	* @message.hint The message to send in the failure
	*/
	function null( required any actual, message="" ){
		arguments.message = ( len( arguments.message ) ? arguments.message : "Expected a null value but got #arguments.actual.toString()#" );
		// equalize with case
		if( isNull( arguments.actual ) ){ return this; }
		// if we reach here, nothing is equal man!
		fail( arguments.message );
	}


	/**
	* Assert something is not null
	* @actual.hint The actual data to test
	* @message.hint The message to send in the failure
	*/
	function notNull( required any actual, message="" ){
		arguments.message = ( len( arguments.message ) ? arguments.message : "Expected the actual value to be NOT null but it was null" );
		// equalize with case
		if( !isNull( arguments.actual ) ){ return this; }
		// if we reach here, nothing is equal man!
		fail( arguments.message );
	}

	/**
	* Assert the type of the incoming actual data, it uses the internal ColdFusion isValid() function behind the scenes
	* @type.hint The type to check, valid types are: array, binary, boolean, component, date, time, float, numeric, integer, query, string, struct, url, uuid
	* @actual.hint The actual data to check
	* @message.hint The message to send in the failure
	*/
	function typeOf( required string type, required any actual, message=""){
		arguments.message = ( len( arguments.message ) ? arguments.message : "Actual data is not of this type: [#arguments.type#]" );
		if( isValid( arguments.type, arguments.actual ) ){ return this; }
		fail( arguments.message );
	}

	/**
	* Assert that is NOT a type of the incoming actual data, it uses the internal ColdFusion isValid() function behind the scenes
	* @type.hint The type to check, valid types are: array, binary, boolean, component, date, time, float, numeric, integer, query, string, struct, url, uuid
	* @actual.hint The actual data to check
	* @message.hint The message to send in the failure
	*/
	function notTypeOf( required string type, required any actual, message=""){
		arguments.message = ( len( arguments.message ) ? arguments.message : "Actual data is actually of this type: [#arguments.type#]" );
		if( !isValid( arguments.type, arguments.actual ) ){ return this; }
		fail( arguments.message );
	}

	/**
	* Assert that the actual object is of the expected instance type
	* @actual.hint The actual data to check
	* @typeName.hint The typename to check
	* @message.hint The message to send in the failure
	*/
	function instanceOf( required any actual, required string typeName, message=""){
		arguments.message = ( len( arguments.message ) ? arguments.message : "The actual data is not of type [#arguments.typeName#]" );
		if( isInstanceOf( arguments.actual, arguments.typeName ) ){ return this; }
		fail( arguments.message );
	}

	/**
	* Assert that the actual object is NOT of the expected instance type
	* @actual.hint The actual data to check
	* @typeName.hint The typename to check
	* @message.hint The message to send in the failure
	*/
	function notInstanceOf( required any actual, required string typeName, message=""){
		arguments.message = ( len( arguments.message ) ? arguments.message : "The actual data is actually of type [#arguments.typeName#]" );
		if( !isInstanceOf( arguments.actual, arguments.typeName ) ){ return this; }
		fail( arguments.message );
	}

	/**
	* Assert that the actual data matches the incoming regular expression with no case sensitivity
	* @actual.hint The actual data to check
	* @regex.hint The regex to check with
	* @message.hint The message to send in the failure
	*/
	function match( required string actual, required string regex, message=""){
		arguments.message = ( len( arguments.message ) ? arguments.message : "The actual [#arguments.actual.toString()#] does not match [#arguments.regex#]" );
		if( arrayLen( reMatchNoCase( arguments.regex, arguments.actual ) ) gt 0 ){ return this; }
		fail( arguments.message );
	}

	/**
	* Assert that the actual data matches the incoming regular expression with case sensitivity
	* @actual.hint The actual data to check
	* @regex.hint The regex to check with
	* @message.hint The message to send in the failure
	*/
	function matchWithCase( required string actual, required string regex, message=""){
		arguments.message = ( len( arguments.message ) ? arguments.message : "The actual [#arguments.actual.toString()#] does not match [#arguments.regex#]" );
		if( arrayLen( reMatch( arguments.regex, arguments.actual ) ) gt 0 ){ return this; }
		fail( arguments.message );
	}

	/**
	* Assert that the actual data does NOT match the incoming regular expression with no case sensitivity
	* @actual.hint The actual data to check
	* @regex.hint The regex to check with
	* @message.hint The message to send in the failure
	*/
	function notMatch( required string actual, required string regex, message=""){
		arguments.message = ( len( arguments.message ) ? arguments.message : "The actual [#arguments.actual.toString()#] matches [#arguments.regex#]" );
		if( arrayLen( reMatchNoCase( arguments.regex, arguments.actual ) ) eq 0 ){ return this; }
		fail( arguments.message );
	}


/*********************************** PRIVATE Methods ***********************************/	

	private function equalize( required actual, required expected ){
		// Numerics
		if( isNumeric( arguments.actual ) && isNumeric( arguments.expected ) && arguments.actual eq arguments.expected ){
			return true;
		}

		// Simple values
		if( isSimpleValue( arguments.actual ) && isSimpleValue( arguments.expected ) && arguments.actual eq arguments.expected ){
			return true;
		}
		
		// Arrays
		if( isArray( arguments.actual ) && isArray( arguments.expected ) && 
			if( createObject("java", "java.util.Arrays").deepEquals( arguments.actual, arguments.expected ) ){
				return true;
			}
		}

		// Queries
		if( isQuery( arguments.actual ) && isQuery( arguments.expected ) && 
			if( serializeJSON( arguments.actual ) eq serializeJSON( arguments.expected ) ){
				return true;
			}
		}

		// Objects
		if( isObject( arguments.actual ) && isObject( arguments.expected ) ){
			var system = createObject("java", "java.lang.System");
			var aHash = system.identityHashCode( arguments.actual );
			var eHash = system.identityHashCode( arguments.expected );
			if( aHash eq eHash ){ return true; }
		}

		// Structs
		if( isStruct( arguments.actual ) && isStruct( arguments.expected ) ){
			// use ordered trees for not caring about position or case
			var eTree = createObject("java","java.util.TreeMap").init( arguments.expected );
			var aTree = createObject("java","java.util.TreeMap").init( arguments.actual );
			// evaluate them
			if( eTree.toString() eq aTree.toString() ){ return true; }
		}

		return false;
	}
	
	
}