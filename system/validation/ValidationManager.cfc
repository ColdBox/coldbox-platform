/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

The ColdBox Validation Manager, all inspired by awesome Hyrule Validation Framework by Dan Vega.

When using constraints you can use {} values for replacements:
- {now} = today
- {property:name} = A property value
- {udf:name} = Call a UDF provider

Constraint Definition Sample:
constraints = {
	propertyName = {
		// required or not
		required : boolean [false],
		// type constraint
		type  : (ssn,email,url,alpha,boolean,date,usdate,eurodate,numeric,GUID,UUID,integer,[string],telephone,zipcode,ipaddress,creditcard,binary,component,query,struct,json,xml),
		// size or length of the value (struct,string,array,query)
		size  : numeric or range, eg: 10 or 6..8
		// range is a range of values the property value should exist in
		range : eg: 1..10 or 5..-5
		// regex validation
		regex : valid no case regex
		// same as another property
		sameAs : propertyName
		// same as but with no case
		sameAsNoCase : propertyName
		// value in list
		inList : list
		// discrete math modifiers
		discrete : (gt,gte,lt,lte,eq,neq):value
		// UDF to use for validation, must return boolean accept the incoming value and target object, validate(value,target):boolean
		udf : function,
		// Validation method to use in the targt object must return boolean accept the incoming value and target object, validate(value,target):boolean
		method : methodName
		// Custom validator, must implement 
		validator : path or wirebox id: 'mypath.MyValidator' or 'id:MyValidator'
	}
};

vResults = validateModel(target=model);

*/
component accessors="true" serialize="false" singleton{

	/**
	* DI
	*/
	property name="wirebox" inject="wirebox";
	
	/**
	* Shared constraints
	*/
	property name="sharedConstraints" type="struct";
	
	/**
	* Lazy loaded object constraints
	*/
	property name="objectConstraints" type="struct";
	

	// constructor
	ValidationManager function init(){
		
		// shared constraints
		sharedConstraints = {};
		// loaded object constraints
		objectConstraints = {};
		// valid validators
		validValidators = "required,type,size,range,regex,sameAs,sameAsNoCase,inList,discrete,udf,method,validator";
		
		return this;
	}
	
	/**
	* Validate an object
	* @target.hint The target object to validate
	* @fields.hint One or more fields to validate on, by default it validates all fields in the constraints. This can be a simple list or an array.
	* @constraints.hint An optional shared constraints name or an actual structure of constraints to validate on.
	*/
	coldbox.system.validation.result.IValidationResult function validate(required any target, string fields="*", any constraints){
		// discover and determine constraints definition for an incoming target.
		var allConstraints = determineConstraintsDefinition(arguments.target, arguments.constraints);
		// create new result object
		var results = new coldbox.system.validation.result.ValidationResult();
		// iterate over constraints defined
		for(var thisField in allConstraints ){
			// verify we can validate the field described in the constraint
			if( arguments.fields == "*" || listFindNoCase(arguments.fields, thisField) ) {
				// process the validation rules on the target field using the constraint validation data
				processRules(results=results,rules=allConstraints[thisField],target=arguments.target,field=thisField);
			}
		}
		
		return results;
	}
	
	/**
	* Process validation rules on a target object and field
	*/
	ValidationManager function processRules(required coldbox.system.validation.result.IValidationResult result, required struct rules, required any target, required any field){
		// process the incoming rules
		for( var key in arguments.rules ){
			// had to use nasty evaluate until adobe cf get's their act together on invoke.
			getValidator(validatorType=key, validationData=arguments.rules[key])
				.validate(result=result,
						  target=arguments.target,
						  field=arguments.field,
						  targetValue=evaluate("arguments.target.get#arguments.field#()"),
						  validationData=arguments.rules[key]);
		}
		return this;
	}
	
	/**
	* Create validators according to types and validation data
	*/
	coldbox.system.validation.validators.IValidator function getValidator(required string validatorType, required string validationData){
	
		switch( arguments.validatorType ){
			case "required" 	: { return wirebox.getInstance("coldbox.system.validation.validators.RequiredValidator"); }
			case "type" 		: { return wirebox.getInstance("coldbox.system.validation.validators.TypeValidator"); }
			case "size" 		: { return wirebox.getInstance("coldbox.system.validation.validators.SizeValidator"); }
			case "range" 		: { return wirebox.getInstance("coldbox.system.validation.validators.RangeValidator"); }
			case "regex" 		: { return wirebox.getInstance("coldbox.system.validation.validators.RegexValidator"); }
			case "sameAs" 		: { return wirebox.getInstance("coldbox.system.validation.validators.SameAsValidator"); }
			case "sameAsNoCase" : { return wirebox.getInstance("coldbox.system.validation.validators.SameAsNoCaseValidator"); }
			case "inList" 		: { return wirebox.getInstance("coldbox.system.validation.validators.InListValidator"); }
			case "discrete" 	: { return wirebox.getInstance("coldbox.system.validation.validators.DiscreteValidator"); }
			case "udf" 			: { return wirebox.getInstance("coldbox.system.validation.validators.UDFValidator"); }
			case "method" 		: { return wirebox.getInstance("coldbox.system.validation.validators.MethodValidator"); }
			case "validator"	: { 
				if( find(":", arguments.validationData) ){ return wirebox.getInstance( getToken( arguments.validationData, 2, ":" ) ); }
				return wirebox.getInstance( arguments.validationData );
			}
			default : {
				throw(message="The validator you requested #arguments.validatorType# is not a valid validator",type="ValidationManager.InvalidValidatorType");
			}
		}
	}
	
	/**
	* Retrieve the shared constraints
	* @name.hint Filter by name or not
	*/
	struct function getSharedConstraints(string name){
		return ( structKeyExists(arguments,"name") ? sharedConstraints[arguments.name] : sharedConstraints );
	}
	
	/**
	* Check if a shared constraint exists by name
	* @name.hint The shared constraint to check
	*/
	boolean function sharedConstraintsExists(required string name){
		return structKeyExists( sharedConstraints, arguments.name );
	}
	
	
	/**
	* Retrieve the shared constraints
	* @constraints.hint Filter by name or not
	*/
	coldbox.system.validation.ValidationManager function setSharedConstraints(struct constraints){
		variables.sharedConstraints = arguments.constraints;
		return this;
	}
	
	/**
	* This method is called by ColdBox when the application loads so you can load or process shared constraints
	* @constraints.hint A structure of validation constraints { key (shared name) = { constraints} }
	*/
	coldbox.system.validation.ValidationManager function loadSharedConstraints(required struct constraints){
		
	}
	
	/************************************** private *********************************************/
	
	private struct function determineConstraintsDefinition(required any target, required any constraints){
		var thisConstraints = {};
		
		// Discover contraints, check passed constraints first
		if( structKeyExists(arguments,"constraints") ){ 
			// simple value means shared lookup
			if( isSimpleValue(arguments.constraints) ){ 
				if( !sharedConstraintsExists(arguments.constraints) ){
					throw(message="The shared constraint you requested (#arguments.constraints#) does not exist",
						  detail="Valid constraints are: #structKeyList(sharedConstraints)#",
						  type="ValidationManager.InvalidSharedConstraint");
				}
				// retrieve the shared constraint
				thisConstraints = getSharedConstraints( arguments.constraints ); 
			}
			// else it is a struct just assign it
			else{ thisConstraints = arguments.constraints; }
		}
		// discover constraints from target object
		else{ thisConstraints = discoverConstraints( arguments.target ); }
		
		// now back to the fun stuff.
		return thisConstraints;
	}
	
	private struct function discoverConstraints(required any target){
		if( structKeyExists(arguments.target,"constraints") ){
			var c = arguments.target.constraints;
			return processConstraints( c );
		}
		return {};
	}
	
}