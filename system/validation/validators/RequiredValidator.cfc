/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
This validator checks if a field has value and not null
*/
component accessors="true" implements="coldbox.system.validation.validators.IValidator" singleton{

	property name="name";

	RequiredValidator function init(){
		name = "Required";
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
		// check
		if( !isBoolean(arguments.validationData) ){
			throw(message="The Required validator data needs to be boolean and you sent in: #arguments.validationData#",type="RequiredValidator.InvalidValidationData");
		}
		// return true if not required, nothing needed to check
		if( !arguments.validationData ){ return true; }

		// null checks
		if( isNull(arguments.targetValue) ){
			var args = {message="The '#arguments.field#' value is null",field=arguments.field,validationType=getName(),validationData=arguments.validationData};
			validationResult.addError( validationResult.newError(argumentCollection=args) );
			return false;
		}

		// Simple Tests
		if( isSimpleValue(arguments.targetValue) AND len(trim( arguments.targetValue )) ){
			return true;
		}
		// Array Tests
		if( isArray( arguments.targetValue ) and arrayLen( arguments.targetValue ) ){
			return true;
		}
		// Query Tests
		if( isQuery( arguments.targetValue ) and arguments.targetValue.recordcount ){
			return true;
		}
		// Struct Tests
		if( isStruct( arguments.targetValue ) and structCount( arguments.targetValue ) ){
			return true;
		}
		// Object
		if( isObject( arguments.targetValue ) ){
			return true;
		}

		var args = {message="The '#arguments.field#' value is required",field=arguments.field,validationType=getName(),validationData=arguments.validationData};
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