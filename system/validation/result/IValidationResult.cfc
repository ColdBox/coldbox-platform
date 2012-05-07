/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
The ColdBox validation results interface, all inspired by awesome Hyrule Validation Framework by Dan Vega
*/
import coldbox.system.validation.result.*;
interface{

	/**
	* Add errors into the result object
	* @error.hint The validation error to add into the results object
	*/
	IValidationResult function addError(required IValidationError error);

	/**
	* Set the validation target object name
	*/
	IValidationResult function setTargetName(required string name);

	/**
	* Get the name of the target object that got validated
	*/
	string function getTargetName();

	/**
	* Get the validation locale
	*/
	string function getValidationLocale();

	/**
	* has locale information
	*/
	boolean function hasLocale();

	/**
	* Set the validation locale
	*/
	IValidationResult function setLocale(required string locale);


	/**
	* Determine if the results had error or not
	* @field.hint The field to count on (optional)
	*/
	boolean function hasErrors(string field);

	/**
	* Clear All errors
	*/
	IValidationResult function clearErrors();


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
	IValidationError[] function getFieldErrors(required string field);

	/**
	* Get a collection of metadata about the validation results
	*/
	struct function getResultMetadata();

	/**
	* Set a collection of metadata into the results object
	*/
	IValidationResult function setResultMetadata(required struct data);

}