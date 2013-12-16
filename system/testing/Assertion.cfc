/**
********************************************************************************
Copyright 2005-2009 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
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
	function assert( required boolean expression, message="" ){
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
	* @expected.hint The expected data
	* @actual.hint The actual data to test
	* @message.hint The message to send in the failure
	*/
	function isEqual( required any expected, required any actual, message="" ){
		// validate equality
		if( equalize( arguments.expected, arguments.actual ) ){ return this; }
		arguments.message = ( len( arguments.message ) ? arguments.message : "Expected [#getStringName( arguments.expected )#] but received [#getStringName( arguments.actual )#]" );
		// if we reach here, nothing is equal man!
		fail( arguments.message );
	}

	/**
	* Assert something is not equal to each other, no case is required
	* @expected.hint The expected data
	* @actual.hint The actual data to test
	* @message.hint The message to send in the failure
	*/
	function isNotEqual( required any expected, required any actual, message="" ){
		arguments.message = ( len( arguments.message ) ? arguments.message : "Expected [#getStringName( arguments.expected )#] to not be [#getStringName( arguments.actual )#]" );
		// validate equality
		if( !equalize( arguments.expected, arguments.actual ) ){ return this; }
		// if we reach here, they are equal!
		fail( arguments.message );
	}

	/**
	* Assert strings are equal to each other with case. 
	* @expected.hint The expected data
	* @actual.hint The actual data to test
	* @message.hint The message to send in the failure
	*/
	function isEqualWithCase( required string expected, required string actual, message="" ){
		arguments.message = ( len( arguments.message ) ? arguments.message : "Expected [#getStringName( arguments.expected )#] but received [#getStringName( arguments.actual )#]" );
		// equalize with case
		if( compare( arguments.expected, arguments.actual ) eq 0 ){ return this; }
		// if we reach here, nothing is equal man!
		fail( arguments.message );
	}

	/**
	* Assert something is null
	* @actual.hint The actual data to test
	* @message.hint The message to send in the failure
	*/
	function null( any actual, message="" ){
		// equalize with case
		if( isNull( arguments.actual ) ){ return this; }
		arguments.message = ( len( arguments.message ) ? 
			arguments.message : "Expected a null value but got #getStringName( arguments.actual )#" );
		// if we reach here, nothing is equal man!
		fail( arguments.message );
	}


	/**
	* Assert something is not null
	* @actual.hint The actual data to test
	* @message.hint The message to send in the failure
	*/
	function notNull( any actual, message="" ){
		// equalize with case
		if( !isNull( arguments.actual ) ){ return this; }
		arguments.message = ( len( arguments.message ) ? arguments.message : "Expected the actual value to be NOT null but it was null" );
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
		arguments.message = ( len( arguments.message ) ? arguments.message : "Actual data [#getStringName( arguments.actual )#] is not of this type: [#arguments.type#]" );
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
		arguments.message = ( len( arguments.message ) ? arguments.message : "Actual data [#getStringName( arguments.actual )#] is actually of this type: [#arguments.type#]" );
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
		arguments.message = ( len( arguments.message ) ? arguments.message : "The actual [#arguments.actual.toString()#] actually matches [#arguments.regex#]" );
		if( arrayLen( reMatchNoCase( arguments.regex, arguments.actual ) ) eq 0 ){ return this; }
		fail( arguments.message );
	}

	/**
	* Assert that a given key exists in the passed in struct/object
	* @target.hint The target object/struct
	* @key.hint The key to check for existence
	* @message.hint The message to send in the failure
	*/
	function key( required any target, required string key, message=""){
		arguments.message = ( len( arguments.message ) ? arguments.message : "The key [#arguments.key#] does not exist in the target object. Found keys are [#structKeyArray( arguments.target ).toString()#]" );
		if( structKeyExists( arguments.target, arguments.key ) ){ return this; }
		fail( arguments.message );
	}

	/**
	* Assert that a given key DOES NOT exist in the passed in struct/object
	* @target.hint The target object/struct
	* @key.hint The key to check for existence
	* @message.hint The message to send in the failure
	*/
	function notKey( required any target, required string key, message=""){
		arguments.message = ( len( arguments.message ) ? arguments.message : "The key [#arguments.key#] exists in the target object. Found keys are [#structKeyArray( arguments.target ).toString()#]" );
		if( !structKeyExists( arguments.target, arguments.key ) ){ return this; }
		fail( arguments.message );
	}

	/**
	* Assert that a given key exists in the passed in struct by searching the entire nested structure
	* @target.hint The target object/struct
	* @key.hint The key to check for existence anywhere in the nested structure
	* @message.hint The message to send in the failure
	*/
	function deepKey( required struct target, required string key, message=""){
		arguments.message = ( len( arguments.message ) ? arguments.message : "The key [#arguments.key#] does not exist anywhere in the target object." );
		if( arrayLen( structFindKey( arguments.target, arguments.key ) ) GT 0 ){ return this; }
		fail( arguments.message );
	}

	/**
	* Assert that a given key DOES NOT exists in the passed in struct by searching the entire nested structure
	* @target.hint The target object/struct
	* @key.hint The key to check for existence anywhere in the nested structure
	* @message.hint The message to send in the failure
	*/
	function notDeepKey( required struct target, required string key, message=""){
		var results = structFindKey( arguments.target, arguments.key );
		// check if not found?
		if( arrayLen( results ) EQ 0 ){ return this; }
		// found, so throw it
		arguments.message = ( len( arguments.message ) ? arguments.message : "The key [#arguments.key#] actually exists in the target object: #results.toString()#" );
		fail( arguments.message );
	}

	/**
	* Assert the size of a given string, array, structure or query
	* @target.hint The target object to check the length for, this can be a string, array, structure or query
	* @length.hint The length to check
	* @message.hint The message to send in the failure
	*/
	function lengthOf( required any target, required string length, message=""){
		var aLength = getTargetLength( arguments.target );
		// validate it
		if( aLength eq arguments.length ){ return this; }

		// found, so throw it
		arguments.message = ( len( arguments.message ) ? arguments.message : "The expected length [#arguments.length#] is different than the actual length [#aLength#]" );
		fail( arguments.message );
	}

	/**
	* Assert the size of a given string, array, structure or query
	* @target.hint The target object to check the length for, this can be a string, array, structure or query
	* @length.hint The length to check
	* @message.hint The message to send in the failure
	*/
	function notLengthOf( required any target, required string length, message=""){
		var aLength = getTargetLength( arguments.target );
		// validate it
		if( aLength neq arguments.length ){ return this; }

		// found, so throw it
		arguments.message = ( len( arguments.message ) ? arguments.message : "The expected length [#arguments.length#] is equal than the actual length [#aLength#]" );
		fail( arguments.message );
	}

	/**
	* Assert that a a given string, array, structure or query is empty
	* @target.hint The target object to check the length for, this can be a string, array, structure or query
	* @message.hint The message to send in the failure
	*/
	function isEmpty( required any target, message=""){
		var aLength = getTargetLength( arguments.target );
		// validate it
		if( aLength eq 0 ){ return this; }

		// found, so throw it
		arguments.message = ( len( arguments.message ) ? arguments.message : "The expected value is not empty, actual size [#aLength#]" );
		fail( arguments.message );
	}

	/**
	* Assert that a a given string, array, structure or query is not empty
	* @target.hint The target object to check the length for, this can be a string, array, structure or query
	* @message.hint The message to send in the failure
	*/
	function isNotEmpty( required any target, message=""){
		var aLength = getTargetLength( arguments.target );
		// validate it
		if( aLength GT 0 ){ return this; }

		// found, so throw it
		arguments.message = ( len( arguments.message ) ? arguments.message : "The expected target to be empty but has a size of [#aLength#]" );
		fail( arguments.message );
	}

	/**
	* Assert that the passed in function will throw an exception
	* @target.hint The target function to execute and check for exceptions
	* @type.hint Match this type with the exception thrown
	* @regex.hint Match this regex against the message of the exception
	* @message.hint The message to send in the failure
	*/
	function throws( required any target, type="", regex=".*", message="" ){
		
		try{
			arguments.target();
			arguments.message = ( len( arguments.message ) ? arguments.message : "The incoming function did not throw an expected exception. Type=[#arguments.type#], Regex=[#arguments.regex#]" );
		}
		catch(Any e){
			// If no type, message expectations
			if( !len( arguments.type ) && arguments.regex eq ".*" ){ return this; }
			// Type expectation then
			if( len( arguments.type ) && e.type eq arguments.type && reFindNoCase( arguments.regex, e.message ) ){
				return this;
			}
			// Message regex then only
			if( arguments.regex neq ".*" && reFindNoCase( arguments.regex, e.message ) ){
				return this;
			}
			// diff messsage types
			arguments.message = ( len( arguments.message ) ? arguments.message : "The incoming function threw exception [#e.type#] [#e.message#] different than expected type=[#arguments.type#], Regex=[#arguments.regex#]" );
		}

		// found, so throw it
		fail( arguments.message );
	}

	/**
	* Assert that the passed in function will NOT throw an exception, an exception of a specified type or exception message regex
	* @target.hint The target function to execute and check for exceptions
	* @type.hint Match this type with the exception thrown
	* @regex.hint Match this regex against the message of the exception
	* @message.hint The message to send in the failure
	*/
	function notThrows( required any target, type="", regex="", message="" ){
		try{
			arguments.target();
		}
		catch(Any e){
			arguments.message = ( len( arguments.message ) ? arguments.message : "The incoming function DID throw an exception of type [#e.type#] with message [#e.message#]" );
		
			// If type passed and matches, then its ok
			if( len( arguments.type ) && e.type neq arguments.type ){
				return this;
			}
			// Message regex must not match
			if( len( arguments.message) && !reFindNoCase( arguments.regex, e.message ) ){
				return this;
			}

			fail( arguments.message );
		}

		return this;
	}

	/**
	* Assert that the passed in actual number or date is expected to be close to it within +/- a passed delta and optional datepart
	* @actual.hint The actual number or date
	* @expected.hint The expected number or date
	* @delta.hint The +/- delta to range it
	* @datepart.hint If passed in values are dates, then you can use the datepart to evaluate it
	* @message.hint The message to send in the failure
	*/
	function closeTo( required any actual, required any expected, required any delta, datePart="", message=""){
		arguments.message = ( len( arguments.message ) ? arguments.message : "The actual [#arguments.actual#] is not in range of [#arguments.expected#] by +/- [#arguments.delta#]" );
		
		if( isNumeric( arguments.actual ) ){
			if( isValid( "range", arguments.actual, (arguments.expected-arguments.delta), (arguments.expected+arguments.delta) ) ){ return this; }
		}
		else if( isDate( arguments.actual ) ){ 

			if( !listFindNoCase( "yyyy,q,m,ww,w,y,d,h,n,s,l", arguments.datePart ) ){
				fail( "The passed in datepart [#arguments.datepart#] is not valid." );
			}

			if( abs( dateDiff( arguments.datePart, arguments.actual, arguments.expected) ) lt arguments.delta ){ return this; }
		}

		fail( arguments.message );
	}

	/**
	* Assert that the passed in actual number or date is between the passed in min and max values
	* @actual.hint The actual number or date to evaluate
	* @min.hint The expected min number or date
	* @max.hint The expected max number or date
	* @message.hint The message to send in the failure
	*/
	function between( required any actual, required any min, required any max, message=""){
		arguments.message = ( len( arguments.message ) ? arguments.message : "The actual [#arguments.actual#] is not between [#arguments.min#] and [#arguments.max#]" );
		
		// numeric between
		if( isNumeric( arguments.actual ) ){
			if( isValid( "range", arguments.actual, arguments.min, arguments.max ) ){
				return this;
			}
		}
		else if( isDate( arguments.actual ) ){
			// check min/max dates first
			if( dateCompare( arguments.min, arguments.max ) NEQ -1 ){
				fail( "The passed in min [#arguments.min#] is either equal or later than max [#arguments.max#]" );
			}

			// To pass, ( actual > min && actual < max )
			if( ( dateCompare( arguments.actual, arguments.min ) EQ 1 ) AND 
				( dateCompare( arguments.actual, arguments.max ) EQ -1 ) 
			){
				return this;
			}
		}

		fail( arguments.message );
	}

	/**
	* Assert that the given "needle" argument exists in the incoming string or array with no case-sensitivity
	* @target.hint The target object to check if the incoming needle exists in. This can be a string or array
	* @needle.hint The substring to find in a string or the value to find in an array
	* @message.hint The message to send in the failure
	*/
	function includes( required any target, required any needle, message="" ){
		arguments.message = ( len( arguments.message ) ? arguments.message : "The needle [#arguments.needle#] was not found in [#arguments.target.toString()#]" );
		
		// string
		if( isSimpleValue( arguments.target ) AND findNoCase( arguments.needle, arguments.target ) ){
			return this;
		}
		// array
		if( isArray( arguments.target ) AND ArrayFindNoCase( arguments.target, arguments.needle ) ){
			return this;
		}

		fail( arguments.message );
	}

	/**
	* Assert that the given "needle" argument exists in the incoming string or array with case-sensitivity
	* @target.hint The target object to check if the incoming needle exists in. This can be a string or array
	* @needle.hint The substring to find in a string or the value to find in an array
	* @message.hint The message to send in the failure
	*/
	function includesWithCase( required any target, required any needle, message="" ){
		arguments.message = ( len( arguments.message ) ? arguments.message : "The needle [#arguments.needle#] was not found in [#arguments.target.toString()#]" );
		
		// string
		if( isSimpleValue( arguments.target ) AND find( arguments.needle, arguments.target ) ){
			return this;
		}
		// array
		if( isArray( arguments.target ) AND arrayContains( arguments.target, arguments.needle ) ){
			return this;
		}

		fail( arguments.message );
	}

	/**
	* Assert that the given "needle" argument does not exist in the incoming string or array with case-sensitivity
	* @target.hint The target object to check if the incoming needle exists in. This can be a string or array
	* @needle.hint The substring to find in a string or the value to find in an array
	* @message.hint The message to send in the failure
	*/
	function notIncludesWithCase( required any target, required any needle, message="" ){
		arguments.message = ( len( arguments.message ) ? arguments.message : "The needle [#arguments.needle#] was found in [#arguments.target.toString()#]" );
		
		// string
		if( isSimpleValue( arguments.target ) AND !find( arguments.needle, arguments.target ) ){
			return this;
		}
		// array
		if( isArray( arguments.target ) AND !arrayContains( arguments.target, arguments.needle ) ){
			return this;
		}

		fail( arguments.message );
	}

	/**
	* Assert that the given "needle" argument exists in the incoming string or array with no case-sensitivity
	* @target.hint The target object to check if the incoming needle exists in. This can be a string or array
	* @needle.hint The substring to find in a string or the value to find in an array
	* @message.hint The message to send in the failure
	*/
	function notIncludes( required any target, required any needle, message="" ){
		arguments.message = ( len( arguments.message ) ? arguments.message : "The needle [#arguments.needle#] was found in [#arguments.target.toString()#]" );
		
		// string
		if( isSimpleValue( arguments.target ) AND !findNoCase( arguments.needle, arguments.target ) ){
			return this;
		}
		// array
		if( isArray( arguments.target ) AND !ArrayFindNoCase( arguments.target, arguments.needle ) ){
			return this;
		}

		fail( arguments.message );
	}

	/**
	* Assert that the actual value is greater than the target value
	* @actual.hint The actual value
	* @target.hint The target value
	* @message.hint The message to send in the failure
	*/
	function isGT( required any actual, required any target, message="" ){
		arguments.message = ( len( arguments.message ) ? arguments.message : "The actual [#arguments.actual#] is not greater than [#arguments.target#]" );
		
		if( arguments.actual gt arguments.target ){
			return this;
		}

		fail( arguments.message );
	}

	/**
	* Assert that the actual value is greater than or equal the target value
	* @actual.hint The actual value
	* @target.hint The target value
	* @message.hint The message to send in the failure
	*/
	function isGTE( required any actual, required any target, message="" ){
		arguments.message = ( len( arguments.message ) ? arguments.message : "The actual [#arguments.actual#] is not greater than or equal to [#arguments.target#]" );
		
		if( arguments.actual gte arguments.target ){
			return this;
		}

		fail( arguments.message );
	}

	/**
	* Assert that the actual value is less than the target value
	* @actual.hint The actual value
	* @target.hint The target value
	* @message.hint The message to send in the failure
	*/
	function isLT( required any actual, required any target, message="" ){
		arguments.message = ( len( arguments.message ) ? arguments.message : "The actual [#arguments.actual#] is not less than [#arguments.target#]" );
		
		if( arguments.actual lt arguments.target ){
			return this;
		}

		fail( arguments.message );
	}

	/**
	* Assert that the actual value is less than or equal the target value
	* @actual.hint The actual value
	* @target.hint The target value
	* @message.hint The message to send in the failure
	*/
	function isLTE( required any actual, required any target, message="" ){
		arguments.message = ( len( arguments.message ) ? arguments.message : "The actual [#arguments.actual#] is not less than or equal to [#arguments.target#]" );
		
		if( arguments.actual lte arguments.target ){
			return this;
		}

		fail( arguments.message );
	}

	
	/**
	* Get a string name representation of an incoming object.
	*/
	function getStringName( required obj ){
		if( isSimpleValue( arguments.obj) ){ return arguments.obj; }
		if( isObject( arguments.obj) ){ return getMetadata( arguments.obj ).name; }
		return arguments.obj.toString();		
	}

/*********************************** PRIVATE Methods ***********************************/	

	private function equalize( required expected, required actual ){
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
			createObject("java", "java.util.Arrays").deepEquals( arguments.actual, arguments.expected ) ){
			return true;
		}

		// Queries
		if( isQuery( arguments.actual ) && isQuery( arguments.expected ) &&
			serializeJSON( arguments.actual ) eq serializeJSON( arguments.expected ) ){
			return true;
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
	
	private function getTargetLength( required any target ){
		var aLength = 0;

		if( isSimpleValue( arguments.target ) ){ aLength = len( arguments.target ); }
		if( isArray( arguments.target ) ){ aLength = arrayLen( arguments.target); }
		if( isStruct( arguments.target ) ){ aLength = structCount( arguments.target); }
		if( isQuery( arguments.target ) ){ aLength = arguments.target.recordcount; }

		return aLength;
	}

}