/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
The ColdBox validator interface, all inspired by awesome Hyrule Validation Framework by Dan Vega
*/
component accessors="true" implements="coldbox.system.validation.validators.IValidator"{

	property name="name";
	
	MockValidator function init(){
		name = "Mock";	
		return this;
	}

	/**
	* Will check if an incoming value validates
	* @validationResult.hint The result object of the validation
	* @target.hint The target object to validate on
	* @field.hint The field on the target object to validate on
	* @targetValue.hint The target value to validate
	* @validationData.hint The validation data the validator was created with
	*/
	boolean function validate(required coldbox.system.validation.result.IValidationResult validationResult, required any target, required string field, any targetValue, string validationData){
		return true;
	}
	
	/**
	* Get the name of the validator
	*/
	string function getName(){
		return name;
	}
	
}