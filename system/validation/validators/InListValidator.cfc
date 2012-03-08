/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
The ColdBox validator interface, all inspired by awesome Hyrule Validation Framework by Dan Vega
*/
component accessors="true" singleton{

	property name="name";
	
	InListValidator function init(){
		name = "InList";	
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
		
		if( !isNull(arguments.targetValue) AND listFindNoCase(arguments.validationData, arguments.targetValue)){
			return true;
		}
		
		var args = {message="The '#arguments.field#' value is not in the constraint list: #arguments.validationData#",field=arguments.field,validationType=getName(),validationData=arguments.validationData};
		var error = validationResult.newError(argumentCollection=args).setErrorMetadata({inlist=arguments.validationData});
		validationResult.addError( error );
		return false;
	}
	
	/**
	* Get the name of the validator
	*/
	string function getName(){
		return name;
	}
	
}