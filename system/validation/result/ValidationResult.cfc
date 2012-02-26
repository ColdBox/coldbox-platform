/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
The ColdBox validation results 
*/
component accessors="true" implements="coldbox.system.validation.result.IValidationResult"{

	// errors property
	property name="errors"			type="array";
	property name="resultMetadata"	type="struct";

	ValidationResult function init(){
		errors 			= [];
		resultMetadata 	= {};
		errorTemplate   = new coldbox.system.validation.result.ValidationError();
		return this;
	}

	/**
	* Get a new error object
	*/
	coldbox.system.validation.result.IValidationError function newError(struct properties){
		return duplicate( errorTemplate ).configure(argumentCollection=arguments);
	}

	/**
	* Add errors into the result object
	* @error.hint The validation error to add into the results object
	*/
	coldbox.system.validation.result.IValidationResult function addError(required coldbox.system.validation.result.IValidationError error){
		arrayAppend( errors, arguments.error );
		return this;
	}
	
	/**
	* Determine if the results had error or not
	* @field.hint The field to count on (optional)
	*/
	boolean function hasErrors(string field){
		return (arrayLen( getAllErrors(argumentCollection=arguments) ) gt 0);
	}
	
	/**
	* Get how many errors you have
	* @field.hint The field to count on (optional)
	*/
	numeric function getErrorCount(string field){
		return arrayLen( getAllErrors(argumentCollection=arguments)  );
	}
	
	/**
	* Get the Errors Array, which is an array of error messages (strings)
	* @field.hint The field to use to filter the error messages on (optional)
	*/
	array function getAllErrors(string field){
		var errorTarget = errors;
		
		if( structKeyExists(arguments,"field") ){
			errorTarget = getFieldErrors( arguments.field );
		}
		
		var e = [];
		for( var thisKey in errorTarget ){
			arrayAppend( e, thisKey.getMessage() );
		}
		
		return e;
	}
	
	/**
	* Get an error object for a specific field that failed. Throws exception if the field does not exist
	* @field.hint The field to return error objects on
	*/
	coldbox.system.validation.result.IValidationError[] function getFieldErrors(required string field){
		var r = [];
		for( var thisError in errors ){
			if( thisError.getField() eq arguments.field ){ arrayAppend(r, thisError); }
		}
		return r;
	}
	
	/**
	* Clear All errors
	*/
	coldbox.system.validation.result.IValidationResult function clearErrors(){
		arrayClear( errors );
		return this;
	}
	
	/**
	* Get a collection of metadata about the validation results
	*/
	struct function getResultMetadata(){
		return resultMetadata;
	}
	
	/**
	* Set a collection of metadata into the results object
	*/
	coldbox.system.validation.result.IValidationResult function setResultMetadata(required struct data){
		variables.resultMetadata = arguments.data;
		return this;	
	}
	
}