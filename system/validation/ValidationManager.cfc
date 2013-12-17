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
		required : boolean [false]
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
		// min value
		min : value
		// max value
		max : value
	}
};

vResults = validateModel(target=model);

*/
import coldbox.system.validation.*;
import coldbox.system.validation.result.*;
component accessors="true" serialize="false" implements="IValidationManager"{

	/**
	* WireBox Object Factory
	*/
	property name="wirebox" inject="wirebox";

	/**
	* A resource bundle plugin for i18n capabilities
	*/
	property name="resourceBundle" inject="coldbox:plugin:ResourceBundle";

	/**
	* Shared constraints that can be loaded into the validation manager
	*/
	property name="sharedConstraints" type="struct";

	/**
	* Constructor
	* @sharedConstraints.hint A structure of shared constraints
	*/
	ValidationManager function init(struct sharedConstraints=structNew()){

		// valid validator registrations
		validValidators = "required,type,size,range,regex,sameAs,sameAsNoCase,inList,discrete,udf,method,validator,min,max,unique";
		// store shared constraints if passed
		variables.sharedConstraints = arguments.sharedConstraints;
		return this;
	}

	/**
	* Validate an object
	* @target.hint The target object to validate or a structure like a form or collection. If it is a collection, we will build a generic object for you so we can validate the structure of name-value pairs.
	* @fields.hint One or more fields to validate on, by default it validates all fields in the constraints. This can be a simple list or an array.
	* @constraints.hint An optional shared constraints name or an actual structure of constraints to validate on.
	* @locale.hint An optional locale to use for i18n messages
	* @excludeFields.hint An optional list of fields to exclude from the validation.
	*/
	IValidationResult function validate(required any target, string fields="*", any constraints="", string locale="", string excludeFields=""){
		var targetName = "";

		// Do we have a real object or a structure?
		if( !isObject( arguments.target ) ){
			arguments.target = new coldbox.system.validation.GenericObject( arguments.target );
			if( isSimpleValue( arguments.constraints ) and len( arguments.constraints ) )
				targetName = arguments.constraints;
			else
				targetName = "GenericForm";
		}
		else{
			targetName = listLast( getMetadata( arguments.target ).name, ".");
		}

		// discover and determine constraints definition for an incoming target.
		var allConstraints = determineConstraintsDefinition( arguments.target, arguments.constraints );

		// create new result object
		var initArgs = {
			locale			= arguments.locale,
			targetName 		= targetName,
			resourceBundle 	= resourceBundle,
			constraints 	= allConstraints
		};
		var results = wirebox.getInstance(name="coldbox.system.validation.result.ValidationResult", initArguments=initArgs);

		// iterate over constraints defined
		var thisField = "";
		for( thisField in allConstraints ){
			// exclusions passed and field is in the excluded list just continue
			if( len( arguments.excludeFields ) and listFindNoCase( arguments.excludeFields, thisField ) ){
				continue;
			}
			// verify we can validate the field described in the constraint
			if( arguments.fields == "*" || listFindNoCase(arguments.fields, thisField) ) {
				// process the validation rules on the target field using the constraint validation data
				processRules(results=results, rules=allConstraints[thisField], target=arguments.target, field=thisField, locale=arguments.locale);
			}
		}

		return results;
	}

	/**
	* Process validation rules on a target object and field
	*/
	ValidationManager function processRules(required coldbox.system.validation.result.IValidationResult results, required struct rules, required any target, required any field){
		// process the incoming rules
		var key = "";
		for( key in arguments.rules ){
			// if message validators, just ignore
			if( reFindNoCase("^(#replace(validValidators,",","|","all")#)Message$", key) ){ continue; }

			// had to use nasty evaluate until adobe cf get's their act together on invoke.
			getValidator(validatorType=key, validationData=arguments.rules[key])
				.validate(validationResult=results,
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
	coldbox.system.validation.validators.IValidator function getValidator(required string validatorType, required any validationData){

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
			case "min" 			: { return wirebox.getInstance("coldbox.system.validation.validators.MinValidator"); }
			case "max" 			: { return wirebox.getInstance("coldbox.system.validation.validators.MaxValidator"); }
			case "udf" 			: { return wirebox.getInstance("coldbox.system.validation.validators.UDFValidator"); }
			case "method" 		: { return wirebox.getInstance("coldbox.system.validation.validators.MethodValidator"); }
			case "unique" 		: { return wirebox.getInstance("coldbox.system.validation.validators.UniqueValidator"); }
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
	* Retrieve the shared constraints, all of them or by name
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
	* Set the entire shared constraints structure
	* @constraints.hint Filter by name or not
	*/
	IValidationManager function setSharedConstraints(struct constraints){
		variables.sharedConstraints = arguments.constraints;
		return this;
	}

	/**
	* Store a shared constraint
	* @name.hint Filter by name or not
	* @constraint.hint The constraint to store.
	*/
	IValidationManager function addSharedConstraint(required string name, required struct constraint){
		sharedConstraints[ arguments.name ] = arguments.constraints;
	}

	/************************************** private *********************************************/

	/**
	* Determine from where to take the constraints from
	*/
	private struct function determineConstraintsDefinition(required any target, any constraints=""){
		var thisConstraints = {};

		// if structure, just return it back
		if( isStruct( arguments.constraints ) ){ return arguments.constraints; }

		// simple value means shared lookup
		if( isSimpleValue(arguments.constraints) AND len( arguments.constraints ) ){
			if( !sharedConstraintsExists(arguments.constraints) ){
				throw(message="The shared constraint you requested (#arguments.constraints#) does not exist",
					  detail="Valid constraints are: #structKeyList(sharedConstraints)#",
					  type="ValidationManager.InvalidSharedConstraint");
			}
			// retrieve the shared constraint and return, they are already processed.
			return getSharedConstraints( arguments.constraints );
		}

		// discover constraints from target object
		return discoverConstraints( arguments.target );
	}

	/**
	* Get the constraints structure from target objects, if none, it returns an empty structure
	*/
	private struct function discoverConstraints(required any target){
		if( structKeyExists(arguments.target,"constraints") ){
			return arguments.target.constraints;
		}
		return {};
	}

}