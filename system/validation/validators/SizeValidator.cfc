/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
This validator validates the size or length of the value of a field
*/
component accessors="true" implements="coldbox.system.validation.validators.IValidator" singleton{

	property name="name";

	SizeValidator function init(){
		name = "Size";
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
		if( !isValid("string",arguments.validationData) || !isValid("regex",arguments.validationData,"(\-?\d)+(?:\.\.\-?\d+)?")){
			throw(message="The Required validator data needs to be boolean and you sent in: #arguments.validationData#",type="RequiredValidator.InvalidValidationData");
		}

		var min = listFirst( arguments.validationData,'..');
		var max = min;
		if( find("..",arguments.validationData) ){
			max = listLast( arguments.validationData,'..');
		}

		// simple size evaluations?
		if( !isNull(arguments.targetValue) AND isSimpleValue(targetValue)){
			if( len(trim(targetValue)) >= min AND ( !len(max) OR len(trim(targetValue)) <= max ) ) {
				return true;
			}
		}
		// complex objects
		else if( !isNull(arguments.targetValue) ){
			// Arrays
			if( isArray(targetValue) AND ( arrayLen(targetValue) >= min AND ( !len(max) OR arrayLen(targetvalue) <= max ) ) ){
				return true;
			}
			// query
			else if( isQuery(targetValue) AND ( targetValue.recordcount >= min AND ( !len(max) OR targetvalue.recordcount <= max ) ) ){
				return true;
			}
			// structure
			else if( isStruct(targetValue) AND ( structCount(targetValue) >= min AND ( !len(max) OR structCount(targetvalue) <= max ) ) ){
				return true;
			}
		}

		var args = {message="The '#arguments.field#' values is not in the required size range (#arguments.validationData#)",field=arguments.field,validationType=getName(),validationData=arguments.validationData};
		var error = validationResult.newError(argumentCollection=args).setErrorMetadata({size=arguments.validationData, min=min, max=max});
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