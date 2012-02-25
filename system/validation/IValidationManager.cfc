/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
The ColdBox validation manager interface, all inspired by awesome Hyrule Validation Framework by Dan Vega
*/
interface{

	/**
	* Validate an object
	* @target.hint The target object to validate
	* @fields.hint One or more fields to validate on, by default it validates all fields in the constraints. This can be a simple list or an array.
	* @constraints.hint An optional shared constraints name or an actual structure of constraints to validate on.
	*/
	IValidationResult function validate(required any target, string fields, any constraints);
	
	/**
	* This method is called by ColdBox when the application loads so you can load or process shared constraints
	* @constraints.hint A structure of validation constraints { key (shared name) = { constraints} }
	*/
	IValidationManager function loadSharedConstraints(required struct constraints);
	
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
	* Retrieve the shared constraints
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