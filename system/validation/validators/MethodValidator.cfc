/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
This validator validates against a unique method
*/
component accessors="true" implements="coldbox.system.validation.validators.IValidator" singleton{

	property name="name";

	MethodValidator function init(){
		name = "Method";
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
	
		// null checks
		if( isNull(arguments.targetValue) ){
			var args = {message="The '#arguments.field#' value is null",field=arguments.field,validationType=getName(),validationData=arguments.validationData};
			validationResult.addError( validationResult.newError(argumentCollection=args) );
			return false;
		}
		
		// Validate via method
		if( evaluate("arguments.target.#arguments.validationData#( arguments.targetValue )")  ){
			return true;
		}

		var args = {message="The '#arguments.field#' value does validate",field=arguments.field,validationType=getName(),validationData=arguments.validationData};
		validationResult.addError( validationResult.newError(argumentCollection=args) );
		return false;
	}

	/**
	* Get the name of the validator
	*/
	string function getName(){
		return name;
	}

}