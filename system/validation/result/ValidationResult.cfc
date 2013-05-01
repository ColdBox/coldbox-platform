/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
The ColdBox validation results
*/
import coldbox.system.validation.result.*;
component accessors="true" implements="IValidationResult"{

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

	/**
	* The constraints evaluated in the validation process
	*/
	property name="constraints"		type="struct";

	/**
	* The resource bundle object
	*/
	property name="resourceBundle";

	ValidationResult function init(string locale="",string targetName="", any resourceBundle="",struct constraints=structNew()){
		errors 						= [];
		resultMetadata 				= {};
		errorTemplate   			= new ValidationError();

		variables.locale			= arguments.locale;
		variables.targetName 		= arguments.targetName;
		variables.resourceBundle	= arguments.resourceBundle;
		variables.constraints		= arguments.constraints;
		return this;
	}

	/**
	* Set the validation target object name
	*/
	IValidationResult function setTargetName(required string name){
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
	* Get the validation locale
	*/
	string function getValidationLocale(){
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
	IValidationResult function setLocale(required string locale){
		variables.locale = arguments.locale;
		return this;
	}

	/**
	* Get a new error object
	*/
	IValidationError function newError(struct properties){
		return duplicate( errorTemplate ).configure(argumentCollection=arguments);
	}

	/**
	* Add errors into the result object
	* @error.hint The validation error to add into the results object
	*/
	IValidationResult function addError(required IValidationError error){
		// Verify Custom Messages via constraints, these take precedence
		if( structKeyExists( constraints, error.getField() ) AND structKeyExists( constraints[error.getField()], "#error.getValidationType()#Message" ) ){
			// override message with custom constraint
			// process global replacements
			globalReplacements( constraints[error.getField()]["#error.getValidationType()#Message"], error );
		}
		// Validate localization?
		else if( hasLocale() ){
			// get i18n message, if it exists
			var message = resourceBundle.getResource(resource="#targetName#.#error.getField()#.#error.getValidationType()#",
													 default="",
													 locale=getValidationLocale());
			// Override with localized message
			if( len( message ) ){
				// process global replacements
				globalReplacements( message, error );
			}
		}
		// append error
		arrayAppend( errors, arguments.error );
		return this;
	}

	// Replace global messages
	private void function globalReplacements(required message, required error){
		// The rejected value
		arguments.message = replacenocase( arguments.message, "{rejectedValue}", arguments.error.getRejectedValue(), "all");
		// The property or field value
		arguments.message = replacenocase( arguments.message, "{field}", arguments.error.getField(), "all");
		// Hyrule Compatibility for property
		arguments.message = replacenocase( arguments.message, "{property}", arguments.error.getField(), "all");
		// The validation type
		arguments.message = replacenocase( arguments.message, "{validationType}", arguments.error.getValidationType(), "all");
		// The validation data
		arguments.message = replacenocase( arguments.message, "{validationData}", arguments.error.getValidationData(), "all");
		// The target name of the object
		arguments.message = replacenocase( arguments.message, "{targetName}", getTargetName(), "all");

		// process result metadata replacements
		var errorData = arguments.error.getErrorMetadata();
		for( var key in errorData ){
			arguments.message = replacenocase( arguments.message, "{#key#}", errorData[key], "all" );
		}

		// override message
		arguments.error.setMessage( arguments.message );
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
	* Get all errors as flat structure that can easily be used for UI display
	*/
	struct function getAllErrorsAsStruct(string field){
		var errorTarget = errors;

		// filter by field?
		if( structKeyExists(arguments,"field") ){
			errorTarget = getFieldErrors( arguments.field );
		}

		var results = {};
		for( var thisError in errorTarget ){
			// check if field struct exists, else create it
			if( !structKeyExists( results, thisError.getField() ) ){
				results[ thisError.getField() ] = [];
			}
			// Add error Message
			arrayAppend( results[ thisError.getField() ] , thisError.getMemento() );
		}

		return results;
	}

	/**
	* Get all errors or by field as a JSON structure
	*/
	string function getAllErrorsAsJSON(string field){
		var results = getAllErrorsAsStruct(argumentcollection=arguments);
		return serializeJSON( results );
	}

	/**
	* Get an error object for a specific field that failed. Throws exception if the field does not exist
	* @field.hint The field to return error objects on
	*/
	IValidationError[] function getFieldErrors(required string field){
		var r = [];
		for( var thisError in errors ){
			if( thisError.getField() eq arguments.field ){ arrayAppend(r, thisError); }
		}
		return r;
	}

	/**
	* Clear All errors
	*/
	IValidationResult function clearErrors(){
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
	IValidationResult function setResultMetadata(required struct data){
		variables.resultMetadata = arguments.data;
		return this;
	}

}