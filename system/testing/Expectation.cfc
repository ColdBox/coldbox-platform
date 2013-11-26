/**
********************************************************************************
Copyright 2005-2009 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
* The Expectation CFC holds a current expectation with all the required matcher methods to provide you
* with awesome BDD expressions and testing.
*/
component accessors="true"{

	// The reference to the spec this matcher belongs to.
	property name="spec";
	// The assertions reference
	property name="assert";
	// The MockBox reference
	property name="mockbox";

	// Public properties for this Expectation to use with the BDD DSL
	// The actual value
	this.actual 	= "";
	// The negation bit
	this.isNot 		= false;
	// Custom messages
	this.message 	= "";

	/**
	* Constructor
	* @spec.hint The spec that this matcher belongs to.
	* @assertions.hint The TestBox assertions object: coldbox.system.testing.Assertion
	* @mockbox.hint A reference to MockBox
	*/
	function init( 
		required any spec,
		required any assertions,
		required any mockBox

	){

		variables.spec 		= arguments.spec;
		variables.mockBox 	= arguments.mockbox;
		variables.assert 	= arguments.assertions;

		return this;
	}

	/**
	* Registers a custom matcher on this Expectation object
	* @name.hint The name of the custom matcher
	* @body.hint The body closure/udf representing this matcher.
	*/
	function registerMatcher( required name, required body ){
		// store new custom matcher function according to specs
		this[ arguments.name ] = variables[ arguments.name ] = function(){
			// execute custom matcher
			var results = body( this, arguments );
			// if not passed, then fail the custom matcher, else you can concatenate
			return( !results ? variables.assert.fail( this.message ) : this );
		};
	}
	
	/**
	* Fail an assertion
	* @message The message to fail with.
	*/
	function fail( message="" ){
		variables.assert.fail( argumentCollection=arguments );
	}

	/**
	* Process dynamic expectations like any matcher starting with the word "not" is negated
	*/
	function onMissingMethod( required missingMethodName, required missingMethodArguments ){
		
		// detect negation
		if( left( arguments.missingMethodName, 3 ) eq "not" ){
			// remove NOT
			arguments.missingMethodName = right( arguments.missingMethodName, len( arguments.missingMethodName ) - 3 );
			// set isNot pivot on this matcher
			this.isNot = true;
		}

		// detect toBeTypeOf dynamic shortcuts
		if( reFindNoCase( "^toBe(array|binary|boolean|component|creditcard|date|time|email|eurodate|float|numeric|guid|integer|query|ssn|social_security_number|string|struct|telephone|url|UUID|usdate|zipcode)$", arguments.missingMethodName ) ){
			// remove the toBe to get the type.
			var type 	= right( arguments.missingMethodName, len( arguments.missingMethodName ) - 4 );
			// detect incoming message
			var message = ( structKeyExists( arguments.missingMethodArguments, "message" ) ? arguments.missingMethodArguments.message : "" );
			message = ( structKeyExists( arguments.missingMethodArguments, "1" ) ? arguments.missingMethodArguments[ 1 ] : message );
			// execute the method
			return toBeTypeOf( type=type, message=message );
		}

		// execute the dynamic method
		var results = evaluate( "#arguments.missingMethodName#( argumentCollection=arguments.missingMethodArguments )" );
		if( !isNull( results ) ){ return results; }

		// throw exception
		//throw(type="InvalidMethod", message="The dynamic/static method: #arguments.missingMethodName# does not exist in this CFC", detail="Available methods are #structKeyArray( this ).toString()#");
	}

	/**
	* Set the not bit to TRUE for this expectation.
	*/
	function _not(){
		this.isNot = true;
		return this;
	}
	
	/**
	* Assert something is true
	* @actual.hint The actual data to test
	* @message.hint The message to send in the failure
	*/
	function toBeTrue( message="" ){
		arguments.actual = this.actual;
		if( this.isNot )
			return variables.assert.isFalse( argumentCollection=arguments );
		else
			return variables.assert.isTrue( argumentCollection=arguments );
	}

	/**
	* Assert something is false
	* @actual.hint The actual data to test
	* @message.hint The message to send in the failure
	*/
	function toBeFalse( message="" ){
		arguments.actual = this.actual;
		if( this.isNot )
			return variables.assert.isTrue( argumentCollection=arguments );
		else
			return variables.assert.isFalse( argumentCollection=arguments );
	}
	
	/**
	* Assert something is equal to each other, no case is required
	* @expected.hint The expected data
	* @message.hint The message to send in the failure
	*/
	function toBe( required any expected, message="" ){
		arguments.actual = this.actual;
		if( this.isNot )
			return variables.assert.isNotEqual( argumentCollection=arguments );
		else
			return variables.assert.isEqual( argumentCollection=arguments );
	}

	
	/**
	* Assert strings are equal to each other with case. 
	* @expected.hint The expected data
	* @message.hint The message to send in the failure
	*/
	function toBeWithCase( required string expected, message="" ){
		arguments.actual = this.actual;
		if( this.isNot )
			return variables.assert.isNotEqual( argumentCollection=arguments );
		else
			return variables.assert.isEqualWithCase( argumentCollection=arguments );
	}

	/**
	* Assert something is null
	* @message.hint The message to send in the failure
	*/
	function toBeNull( message="" ){
		if( this.isNot ){
			if( !isNull( this.actual ) ){ return this; }
			arguments.message = ( len( arguments.message ) ? arguments.message : "Expected the actual value to be NOT null but it was null" );
		}
		else{
			if( isNull( this.actual ) ){ return this; }
			arguments.message = ( len( arguments.message ) ? 
				arguments.message : "Expected a null value but got [#variables.assert.getStringName( this.actual )#] instead" );
			
		}

		variables.assert.fail( arguments.message );		
	}


	/**
	* Assert that the actual object is of the expected instance type
	* @typeName.hint The typename to check
	* @message.hint The message to send in the failure
	*/
	function toBeInstanceOf( required string typeName, message=""){
		arguments.actual = this.actual;
		if( this.isNot )
			return variables.assert.notInstanceOf( argumentCollection=arguments );
		else
			return variables.assert.instanceOf( argumentCollection=arguments );
	}

	/**
	* Assert that the actual data matches the incoming regular expression with no case sensitivity
	* @regex.hint The regex to check with
	* @message.hint The message to send in the failure
	*/
	function toMatch( required string regex, message=""){
		arguments.actual = this.actual;
		if( this.isNot )
			return variables.assert.notMatch( argumentCollection=arguments );
		else
			return variables.assert.match( argumentCollection=arguments );
	}

	/**
	* Assert that the actual data matches the incoming regular expression with case sensitivity
	* @actual.hint The actual data to check
	* @regex.hint The regex to check with
	* @message.hint The message to send in the failure
	*/
	function toMatchWithCase( required string actual, required string regex, message=""){
		arguments.actual = this.actual;
		if( this.isNot )
			return variables.assert.notMatch( argumentCollection=arguments );
		else
			return variables.assert.matchWithCase( argumentCollection=arguments );
	}

	/**
	* Assert the type of the incoming actual data, it uses the internal ColdFusion isValid() function behind the scenes
	* @type.hint The type to check, valid types are: array, binary, boolean, component, date, time, float, numeric, integer, query, string, struct, url, uuid
	* @message.hint The message to send in the failure
	*/
	function toBeTypeOf( required string type, message=""){
		arguments.actual = this.actual;
		if( this.isNot )
			return variables.assert.notTypeOf( argumentCollection=arguments );
		else
			return variables.assert.typeOf( argumentCollection=arguments );
	}

	/**
	* Assert that a a given string, array, structure or query is empty
	* @message.hint The message to send in the failure
	*/
	function toBeEmpty( message=""){
		arguments.target = this.actual;
		if( this.isNot )
			return variables.assert.isNotEmpty( argumentCollection=arguments );
		else
			return variables.assert.isEmpty( argumentCollection=arguments );
	}

	/**
	* Assert that a given key exists in the passed in struct/object
	* @key.hint The key to check for existence
	* @message.hint The message to send in the failure
	*/
	function toHaveKey( required string key, message=""){
		arguments.target = this.actual;
		if( this.isNot )
			return variables.assert.notKey( argumentCollection=arguments );
		else
			return variables.assert.key( argumentCollection=arguments );
	}

	/**
	* Assert that a given key exists in the passed in struct by searching the entire nested structure
	* @key.hint The key to check for existence anywhere in the nested structure
	* @message.hint The message to send in the failure
	*/
	function toHaveDeepKey( required string key, message=""){
		arguments.target = this.actual;
		if( this.isNot )
			return variables.assert.notDeepKey( argumentCollection=arguments );
		else
			return variables.assert.deepKey( argumentCollection=arguments );
	}

	/**
	* Assert the size of a given string, array, structure or query
	* @length.hint The length to check
	* @message.hint The message to send in the failure
	*/
	function toHaveLength( required string length, message=""){
		arguments.target = this.actual;
		if( this.isNot )
			return variables.assert.notLengthOf( argumentCollection=arguments );
		else
			return variables.assert.lengthOf( argumentCollection=arguments );
	}

	/**
	* Assert that the passed in function will throw an exception
	* @type.hint Match this type with the exception thrown
	* @regex.hint Match this regex against the message of the exception
	* @message.hint The message to send in the failure
	*/
	function toThrow( type="", regex=".*", message="" ){
		arguments.target = this.actual;
		if( this.isNot )
			return variables.assert.notThrows( argumentCollection=arguments );
		else
			return variables.assert.throws( argumentCollection=arguments );
	}

	/**
	* Assert that the passed in actual number or date is expected to be close to it within +/- a passed delta and optional datepart
	* @expected.hint The expected number or date
	* @delta.hint The +/- delta to range it
	* @datepart.hint If passed in values are dates, then you can use the datepart to evaluate it
	* @message.hint The message to send in the failure
	*/
	function toBeCloseTo( required any expected, required any delta, datePart="", message=""){
		arguments.actual = this.actual;
		if( this.isNot ){
			try{
				variables.assert.closeTo( argumentCollection=arguments );
				arguments.message = ( len( arguments.message ) ? arguments.message : "The actual [#this.actual#] is actually in range of [#arguments.expected#] by +/- [#arguments.delta#]" );
				variables.assert.fail( arguments.message );
			}
			catch(Any e){
				return this;
			}
		}
		else
			return variables.assert.closeTo( argumentCollection=arguments );
	}

	/**
	* Assert that the passed in actual number or date is between the passed in min and max values
	* @min.hint The expected min number or date
	* @max.hint The expected max number or date
	* @message.hint The message to send in the failure
	*/
	function toBeBetween( required any min, required any max, message=""){
		arguments.actual = this.actual;
		if( this.isNot ){
			try{
				variables.assert.between( argumentCollection=arguments );
				arguments.message = ( len( arguments.message ) ? arguments.message : "The actual [#this.actual#] is actually between [#arguments.min#] and [#arguments.max#]" );
				variables.assert.fail( arguments.message );
			}
			catch(Any e){
				return this;
			}
		}
		else
			return variables.assert.between( argumentCollection=arguments );
	}

	/**
	* Assert that the given "needle" argument exists in the incoming string or array with no case-sensitivity
	* @target.hint The target object to check if the incoming needle exists in. This can be a string or array
	* @needle.hint The substring to find in a string or the value to find in an array
	* @message.hint The message to send in the failure
	*/
	function toInclude( required any needle, message="" ){
		arguments.target = this.actual;
		if( this.isNot )
			return variables.assert.notIncludes( argumentCollection=arguments );
		else
			return variables.assert.includes( argumentCollection=arguments );
	}

	/**
	* Assert that the given "needle" argument exists in the incoming string or array with case-sensitivity
	* @needle.hint The substring to find in a string or the value to find in an array
	* @message.hint The message to send in the failure
	*/
	function toIncludeWithCase( required any target, required any needle, message="" ){
		arguments.target = this.actual;
		if( this.isNot )
			return variables.assert.notIncludesWithCase( argumentCollection=arguments );
		else
			return variables.assert.includesWithCase( argumentCollection=arguments );
	}

	/**
	* Assert that the actual value is greater than the target value
	* @target.hint The target value
	* @message.hint The message to send in the failure
	*/
	function toBeGT( required any target, message="" ){
		arguments.message = ( len( arguments.message ) ? arguments.message : "The actual [#this.actual#] is not greater than [#arguments.target#]" );

		if( this.isNot )
			variables.assert.isLTE( this.actual, arguments.target, arguments.message );
		else	
			variables.assert.isGT( this.actual, arguments.target, arguments.message );
		
	}

	/**
	* Assert that the actual value is greater than or equal the target value
	* @target.hint The target value
	* @message.hint The message to send in the failure
	*/
	function toBeGTE( required any target, message="" ){
		arguments.message = ( len( arguments.message ) ? arguments.message : "The actual [#this.actual#] is not greater than or equal to [#arguments.target#]" );
		
		if( this.isNot )
			variables.assert.isLT( this.actual, arguments.target, arguments.message );
		else	
			variables.assert.isGTE( this.actual, arguments.target, arguments.message );
	}

	/**
	* Assert that the actual value is less than the target value
	* @target.hint The target value
	* @message.hint The message to send in the failure
	*/
	function toBeLT( required any target, message="" ){
		arguments.message = ( len( arguments.message ) ? arguments.message : "The actual [#this.actual#] is not less than [#arguments.target#]" );
		
		if( this.isNot )
			variables.assert.isGTE( this.actual, arguments.target, arguments.message );
		else	
			variables.assert.isLT( this.actual, arguments.target, arguments.message );
	}

	/**
	* Assert that the actual value is less than or equal the target value
	* @target.hint The target value
	* @message.hint The message to send in the failure
	*/
	function toBeLTE( required any target, message="" ){
		arguments.message = ( len( arguments.message ) ? arguments.message : "The actual [#this.actual#] is not less than or equal to [#arguments.target#]" );
		
		if( this.isNot )
			variables.assert.isGT( this.actual, arguments.target, arguments.message );
		else	
			variables.assert.isLTE( this.actual, arguments.target, arguments.message );
	}

}