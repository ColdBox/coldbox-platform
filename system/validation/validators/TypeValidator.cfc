/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
This validator verifies field type
*/
component accessors="true" implements="coldbox.system.validation.validators.IValidator" singleton{

	property name="name";

	TypeValidator function init(){
		name = "Type";
		validTypes = "ssn,email,url,alpha,boolean,date,usdate,eurodate,numeric,GUID,UUID,integer,string,telephone,zipcode,ipaddress,creditcard,binary,component,query,struct,json,xml";
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
		// check incoming type
		if( !reFindNoCase( "^(#replace(validTypes,",","|","all")#)$", arguments.validationData ) ){
			throw(message="The Required validator data is invalid: #arguments.validationData#",type="TypeValidator.InvalidValidationData");
		}

		// return true if not data to check, type needs a data element to be checked.
		if( isNull(arguments.targetValue) OR ( isSimpleValue(arguments.targetValue) AND NOT len(arguments.targetValue) ) ){ return true; }

		var r = false;

		switch( arguments.validationData ){
			case "ssn" 			: { r = isValid("ssn",arguments.targetValue); break; }
			case "email"		: { r = isValid("email",arguments.targetValue); break; }
			case "url"			: { r = isValid("url",arguments.targetValue); break; }
			case "alpha"		: { r = (reFindNoCase("^[a-zA-Z\s]*$",arguments.targetValue) gt 0); break; }
			case "boolean"		: { r = isValid("boolean",arguments.targetValue); break; }
			case "date"			: { r = isValid("date",arguments.targetValue); break; }
			case "usdate"		: { r = isValid("usdate",arguments.targetValue); break; }
			case "eurodate"		: { r = isValid("eurodate",arguments.targetValue); break; }
			case "numeric"		: { r = isValid("numeric",arguments.targetValue); break; }
			case "guid"			: { r = isValid("guid",arguments.targetValue); break; }
			case "uuid"			: { r = isValid("uuid",arguments.targetValue); break; }
			case "integer"		: { r = isValid("integer",arguments.targetValue); break; }
			case "string"		: { r = isValid("string",arguments.targetValue); break; }
			case "telephone"	: { r = isValid("telephone",arguments.targetValue); break; }
			case "zipcode"		: { r = isValid("zipcode",arguments.targetValue); break; }
			case "ipaddress"	: { r = (refindnocase("\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b",arguments.targetvalue) gt 0); break; }
			case "creditcard"	: { r = isValid("creditcard",arguments.targetValue); break; }
			case "component"	: { r = isValid("component",arguments.targetValue); break; }
			case "query"		: { r = isValid("query",arguments.targetValue); break; }
			case "struct"		: { r = isValid("struct",arguments.targetValue); break; }
			case "json"			: { r = isJSON(arguments.targetValue); break; }
			case "xml"			: { r = isXML(arguments.targetValue); break; }
		}

		if( !r ){
			var args = {message="The '#arguments.field#' has an invalid type, expected type is #arguments.validationData#",field=arguments.field,validationType=getName(),validationData=arguments.validationData};
			var error = validationResult.newError(argumentCollection=args).setErrorMetadata({type=arguments.validationData});
			validationResult.addError( error );
		}

		return r;
	}

	/**
	* Get the name of the validator
	*/
	string function getName(){
		return name;
	}

}