/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
The ColdBox validation results interface, all inspired by awesome Hyrule Validation Framework by Dan Vega
*/
interface{

	/**
	* Add errors into the result object
	* @error.hint The validation error to add into the results object
	*/
	coldbox.system.validation.result.IValidationResult function addError(required coldbox.system.validation.result.IValidationError error);
	
	/**
	* Determine if the results had error or not
	* @field.hint The field to count on (optional)
	*/
	boolean function hasErrors(string field);
	
	/**
	* Clear All errors
	*/
	coldbox.system.validation.result.IValidationResult function clearErrors();
	
	
	/**
	* Get how many errors you have
	* @field.hint The field to count on (optional)
	*/
	numeric function getErrorCount(string field);
	
	/**
	* Get the Errors Array, which is an array of error messages (strings)
	* @field.hint The field to use to filter the error messages on (optional)
	*/
	array function getAllErrors(string field);
	
	/**
	* Get an error object for a specific field that failed. Throws exception if the field does not exist
	* @field.hint The field to return error objects on
	*/
	coldbox.system.validation.result.IValidationError[] function getFieldErrors(required string field);
	
	/**
	* Get a collection of metadata about the validation results
	*/
	struct function getResultMetadata();
	
	/**
	* Set a collection of metadata into the results object
	*/
	coldbox.system.validation.result.IValidationResult function setResultMetadata(required struct data);
	
}