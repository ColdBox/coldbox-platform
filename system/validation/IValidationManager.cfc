/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
The ColdBox validation manager interface, all inspired by awesome Hyrule Validation Framework by Dan Vega
*/
import coldbox.system.validation.*;
import coldbox.system.validation.result.*;
interface{

	/**
	* Validate an object
	* @target.hint The target object to validate
	* @fields.hint One or more fields to validate on, by default it validates all fields in the constraints. This can be a simple list or an array.
	* @constraints.hint An optional shared constraints name or an actual structure of constraints to validate on.
	* @locale.hint An optional locale to use for i18n messages
	* @excludeFields.hint An optional list of fields to exclude from the validation.
	*/
	IValidationResult function validate(required any target, string fields, any constraints, string locale="", string excludeFields="");

	/**
	* Retrieve the shared constraints
	* @name.hint Filter by name or not
	*/
	struct function getSharedConstraints(string name);

	/**
	* Check if a shared constraint exists by name
	* @name.hint The shared constraint to check
	*/
	boolean function sharedConstraintsExists(required string name);

	/**
	* Set the shared constraints into the validation manager, usually these are described in the ColdBox configuraiton file
	* @constraints.hint Filter by name or not
	*/
	IValidationManager function setSharedConstraints(struct constraints);

	/**
	* Store a shared constraint
	* @name.hint Filter by name or not
	* @constraint.hint The constraint to store.
	*/
	IValidationManager function addSharedConstraint(required string name, required struct constraint);
}