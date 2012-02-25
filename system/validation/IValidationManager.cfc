/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
The ColdBox validation manager interface, all inspired by awesome Hyrule Validation Framework by Dan Vega
*/
interface{

	/**
	* Validate an object
	* @error.hint The validation error to add into the results object
	* @target.hint The target object to validate
	* @fields.hint One or more fields to validate on, by default it validates all fields in the constraints. This can be a simple list or an array.
	*/
	IValidationResult function validate(required any target, string fields);
	
}