/**
 * Hyrule Validator
 * @accessors true
 */
component {

	property ValidationMessageProvider;

	public Validator function init(String rb="DefaultValidatorMessages"){
		setValidationMessageProvider(new ValidatorMessage(arguments.rb));
		return this;
	}

	public ValidationResult function validate(required any dto,Struct dtoMD,ValidationResult vr,Array properties){
		var validationResult = (isNUll(arguments.vr)) ?  new validationResult() : arguments.vr;	
		var dtoMetaData = (isNUll(arguments.dtoMD)) ?  getMetaData(arguments.dto) : arguments.dtoMD;
		
		//recurse down through the inheritence chain
		if( !isNull(dtoMetaData.extends) ) {	
			validate(arguments.dto, dtoMetaData.extends, validationResult);
		}

		var props = (isNULL(dtoMetaData.properties)) ? [] : dtoMetaData.properties;

		// for each property in the array
		for(var i=1; i <= arrayLen(props); ++i) {
			
			// the current property struct
			var prop = props[i];

			// we are only validating columns
			if( !structKeyExists(prop,"fieldtype") || prop.fieldtype == "column"){

				// the name of the current property
				var name = prop["name"];

				// the value of the property
				var val =  isNull(evaluate("arguments.dto." & "get#name#()")) ? "" : evaluate("arguments.dto." & "get#name#()");

				// add the value to the property map
				prop.value = val;

				// once we have checked null and empty we can do any other validations
				for(key in prop){
								
					var message = structKeyExists(prop,"message") ? prop.message : getValidationMessageProvider().getMessageByType(key,prop);	
					var validator = '';
										
					switch(key){

						// we will deal with notnull later

						case "NOTEMPTY" : {
							validator = new rules.NotEmptyValidator();
							break;
						}
	
						case "MIN" : {
							validator  = new rules.MinValidator();
							break;
						}

						case "MAX" : {
							validator = new rules.MaxValidator();
							break;
						}

						case "RANGE" : {
							validator = new rules.rangeValidator();
							break;
						}

						case "SIZE" : {
							validator = new rules.sizeValidator();
							break;
						}

						case "INLIST" : {
							var validator = new rules.InListValidator();
							break;
						}

						case "NOTINLIST" : {
							var validator = new rules.NotInListValidator();
							break;
						}
						
						case "PAST" : {
							validator = new rules.PastValidator();
							break;
						}

						case "FUTURE" : {
							validator = new rules.FutureValidator();
							break;
						}

						case "ASSERTTRUE" : {
							var validator = new rules.AssertTrueValidator();
							break;
						}
						case "ASSERTFALSE" : {
							var validator = new rules.AssertFalseValidator();
							break;
						}

						case "UPPERCASE" : {
							validator = new rules.UpperCaseValidator();
							break;
						}

						case "LOWERCASE" : {
							validator = new rules.LowerCaseValidator();
							break;
						}

						case "PASSWORD" : {
							validator = new rules.passwordValidator();
							break;
						}
						
						case "EMAIL" : {
							validator = new rules.emailValidator();
							break;
						}

						case "CREDITCARD" : {
							validator = new rules.CreditCardNumberValidator();
							break;
						}

						case "SSN" : {
							var validator = new rules.SSNValidator();
							break;
						}

						case "PHONE" : {
							validator = new rules.PhoneValidator();
							break;
						}

						case "ZIPCODE" : {
							validator = new rules.ZipCodeValidator();
							break;
						}

						case "DATE" : {
							validator = new rules.DateValidator();
							break;
						}

						case "ARRAY" : {
							validator = new rules.ArrayValidator();
							break;
						}

						case "STRUCT" : {
							validator = new rules.StructValidator();
							break;
						}

						case "BOOLEAN" : {
							validator = new rules.BooleanValidator();
							break;
						}

						case "QUERY" : {
							validator = new rules.QueryValidator();
							break;
						}

						case "URL" : {
							validator = new rules.URLValidator();
							break;
						}

						case "UUID" : {
							validator = new rules.UUIDValidator();
							break;
						}

						case "GUID" : {
							validator = new rules.GUIDValidator();
							break;
						}

						case "BINARY" : {
							validator = new rules.binaryValidator();
							break;
						}

						case "NUMERIC" : {
							validator = new rules.numericValidator();
							break;
						}

						case "STRING" : {
							validator = new rules.stringValidator();
							break;
						}

						case "VARIABLENAME" : {
							validator = new rules.VariableNameValidator();
							break;
						}

						case "ISMATCH" : {
							var validator = new rules.IsMatchValidator();
							
							// if we find a {} in the is match property we are looking to match a value and not a string
							var propertyMatch = reMatchNoCase("({)([\w])+?(})",prop.isMatch);
							
							if( arrayLen(propertyMatch) ) {
								var property = reReplaceNoCase(propertyMatch[1],"({)([\w]+)(})","\2");
																
								for(var i=1; i<=arrayLen(props); i++){
									if(props[i].name == property){
										prop.compareto = props[i].value;
									}
								}
							} else {
								prop.compareto = prop.ismatch;
							}
							
							break;
						}

						case "CUSTOM" : {
							// TODO: We should throw a custom error here if the component was not found
							var validator = createObject("component","#prop.custom#");
							break;
						}
						
					}//end switch(key)
										
					if( !isSimpleValue(validator) && !validator.isValid(prop) ) {					
						validationResult.addError(dtoMetaData.name,'property',prop.name,key,message);
					}
				}

			}

		}
		
		return validationResult;
	}
	
}
