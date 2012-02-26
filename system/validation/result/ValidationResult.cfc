/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
The ColdBox validation results 
*/
component accessors="true" implements="coldbox.system.validation.result.IValidationResult"{

	/**
	* A collection of error objects represented in this result object
	*/
	property name="errors"			type="array";
	
	/**
	* Extra metadata you can store in the results object
	*/
	property name="resultMetadata"	type="struct";
	
	/**
	* The locale this result validation is using
	*/
	property name="locale"			type="string";
	
	/**
	* The name of the target object
	*/
	property name="targetName"		type="string";
	
	// DI
	property name="rb"	inject="coldbox:plugin:ResourceBundle";

	ValidationResult function init(string locale="",string targetName=""){
		errors 					= [];
		resultMetadata 			= {};
		variables.locale		= arguments.locale;
		variables.targetName 	= arguments.targetName;
		errorTemplate   		= new coldbox.system.validation.result.ValidationError();
		return this;
	}
	
	/**
	* Set the validation target object name
	*/
	coldbox.system.validation.result.ValidationResult function setTargetName(required string name){
		targetName = arguments.name;
		return this;
	}
	
	/**
	* Get the name of the target object that got validated
	*/
	string function getTargetName(){
		return targetName;
	}
	
	/**
	* Set the validation locale
	*/
	coldbox.system.validation.result.ValidationResult function setLocale(required string locale){
		variables.locale = arguments.locale;
		return this;
	}
	
	/**
	* Get the locale
	*/
	string function getLocale(){
		return locale;
	}
	
	/**
	* has locale information
	*/
	boolean function hasLocale(){
		return ( len(locale) GT 0 );
	}

	/**
	* Set the validation locale
	*/
	coldbox.system.validation.result.ValidationResult function setLocale(required string locale){
		variables.locale = arguments.locale;
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