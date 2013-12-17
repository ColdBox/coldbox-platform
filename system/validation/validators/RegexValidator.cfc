/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
This validator validates against a user defined regular expression
*/
component accessors="true" implements="coldbox.system.validation.validators.IValidator" singleton{

	property name="name";

	RegexValidator function init(){
		name = "Regex";
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
	boolean function validate(required coldbox.system.validation.result.IValidationResult validationResult, required any target, required string field, any targetValue, any validationData){


		if( !isNull(arguments.targetValue) AND isValid("regex", arguments.targetValue, arguments.validationData) ){
			return true;
		}

		var args = {message="The '#arguments.field#' value does not match the regular expression: #arguments.validationData#",field=arguments.field,validationType=getName(),validationData=arguments.validationData};
		var error = validationResult.newError(argumentCollection=args).setErrorMetadata({regex=arguments.validationData});
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