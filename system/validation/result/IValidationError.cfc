/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
The ColdBox validation error interface, all inspired by awesome Hyrule Validation Framework by Dan Vega
*/
import coldbox.system.validation.result.*;
interface{

	/**
	* Set the error message
	* @message.hint The error message
	*/
	IValidationError function setMessage(required string message);
	 
	/**
	* Set the field
	* @message.hint The error message
	*/
	IValidationError function setField(required string field);
	
	/**
	* Set the rejected value
	* @value.hint The rejected value
	*/
	IValidationError function setRejectedValue(required any value);
	
	/**
	* Set the validator type name that rejected
	* @validationType.hint The name of the rejected validator
	*/
	IValidationError function setValidationType(required any validationType);
	
	/**
	* Get the error validation type
	*/
	string function getValidationType();
	
	/**
	* Set the validator data
	* @data.hint The data of the validator
	*/
	IValidationError function setValidationData(required any data);
	
	/**
	* Get the error validation data
	*/
	string function getValidationData();
	
	/**
	* Get the error message
	*/
	string function getMessage();
	
	/**
	* Get the error field
	*/
	string function getField();
	
	/**
	* Get the rejected value
	*/
	any function getRejectedValue();
	
}