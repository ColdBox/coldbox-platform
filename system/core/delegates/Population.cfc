/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * A delegate that can be used to gain population techniques on the injected $parent delegator
 */
component {

	// DI
	property name="populator" inject="wirebox:populator";

	/**
	 * Populate/bind an entity's properties and relationships from an incoming structure or map of flat data.
	 *
	 * @memento              The map/struct to populate the entity with
	 * @scope                Use scope injection instead of setter injection, no need of setters, just tell us what scope to inject to
	 * @trustedSetter        Do not check if the setter exists, just call it, great for usage with onMissingMethod() and virtual properties
	 * @include              A list of keys to include in the population ONLY
	 * @exclude              A list of keys to exclude from the population
	 * @ignoreEmpty          Ignore empty values on populations, great for ORM population
	 * @nullEmptyInclude     A list of keys to NULL when empty
	 * @nullEmptyExclude     A list of keys to NOT NULL when empty
	 * @composeRelationships Automatically attempt to compose relationships from the incoming properties memento
	 * @target               The entity to populate, yourself
	 * @ignoreTargetLists    If this is true, then the populator will ignore the target's population include/exclude metadata lists. By default this is false.
	 */
	any function populate(
		required struct memento,
		string scope                 = "",
		boolean trustedSetter        = false,
		string include               = "",
		string exclude               = "",
		boolean ignoreEmpty          = false,
		string nullEmptyInclude      = "",
		string nullEmptyExclude      = "",
		boolean composeRelationships = false,
		any target                   = $parent,
		boolean ignoreTargetLists    = false
	){
		return variables.populator.populateFromStruct( argumentCollection = arguments );
	}

	/**
	 * Simple map to property population for entities with structure key prefixes
	 *
	 * @memento              The map/struct to populate the entity with
	 * @scope                Use scope injection instead of setter injection, no need of setters, just tell us what scope to inject to
	 * @trustedSetter        Do not check if the setter exists, just call it, great for usage with onMissingMethod() and virtual properties
	 * @include              A list of keys to include in the population ONLY
	 * @exclude              A list of keys to exclude from the population
	 * @ignoreEmpty          Ignore empty values on populations, great for ORM population
	 * @nullEmptyInclude     A list of keys to NULL when empty
	 * @nullEmptyExclude     A list of keys to NOT NULL when empty
	 * @composeRelationships Automatically attempt to compose relationships from the incoming properties memento
	 * @prefix               The prefix used to filter, Example: 'user' would apply to the following formfield: 'user_id' and 'user_name' but not 'address_id'
	 * @target               The entity to populate
	 * @ignoreTargetLists    If this is true, then the populator will ignore the target's population include/exclude metadata lists. By default this is false.
	 */
	any function populateWithPrefix(
		required struct memento,
		string scope                 = "",
		boolean trustedSetter        = false,
		string include               = "",
		string exclude               = "",
		boolean ignoreEmpty          = false,
		string nullEmptyInclude      = "",
		string nullEmptyExclude      = "",
		boolean composeRelationships = false,
		required string prefix,
		any target                = $parent,
		boolean ignoreTargetLists = false
	){
		return variables.populator.populateFromStructWithPrefix( argumentCollection = arguments );
	}

	/**
	 * Populate from JSON, for argument definitions look at the populate method
	 *
	 * @jsonString           The Json string to use for population
	 * @scope                Use scope injection instead of setter injection, no need of setters, just tell us what scope to inject to
	 * @trustedSetter        Do not check if the setter exists, just call it, great for usage with onMissingMethod() and virtual properties
	 * @include              A list of keys to include in the population ONLY
	 * @exclude              A list of keys to exclude from the population
	 * @ignoreEmpty          Ignore empty values on populations, great for ORM population
	 * @nullEmptyInclude     A list of keys to NULL when empty
	 * @nullEmptyExclude     A list of keys to NOT NULL when empty
	 * @composeRelationships Automatically attempt to compose relationships from the incoming properties memento
	 * @target               The entity to populate
	 * @ignoreTargetLists    If this is true, then the populator will ignore the target's population include/exclude metadata lists. By default this is false.
	 */
	any function populateFromJSON(
		required string JSONString,
		string scope                 = "",
		boolean trustedSetter        = false,
		string include               = "",
		string exclude               = "",
		boolean ignoreEmpty          = false,
		string nullEmptyInclude      = "",
		string nullEmptyExclude      = "",
		boolean composeRelationships = false,
		any target                   = $parent,
		boolean ignoreTargetLists    = false
	){
		return variables.populator.populateFromJSON( argumentCollection = arguments );
	}

	/**
	 * Populate from XML, for argument definitions look at the populate method
	 *
	 * @xml                  The XML string or packet or XML object to populate from
	 * @root                 The XML root element to start from
	 * @scope                Use scope injection instead of setter injection, no need of setters, just tell us what scope to inject to
	 * @trustedSetter        Do not check if the setter exists, just call it, great for usage with onMissingMethod() and virtual properties
	 * @include              A list of keys to include in the population ONLY
	 * @exclude              A list of keys to exclude from the population
	 * @ignoreEmpty          Ignore empty values on populations, great for ORM population
	 * @nullEmptyInclude     A list of keys to NULL when empty
	 * @nullEmptyExclude     A list of keys to NOT NULL when empty
	 * @composeRelationships Automatically attempt to compose relationships from the incoming properties memento
	 * @target               The entity to populate
	 * @ignoreTargetLists    If this is true, then the populator will ignore the target's population include/exclude metadata lists. By default this is false.
	 */
	any function populateFromXML(
		required string xml,
		string root                  = "",
		string scope                 = "",
		boolean trustedSetter        = false,
		string include               = "",
		string exclude               = "",
		boolean ignoreEmpty          = false,
		string nullEmptyInclude      = "",
		string nullEmptyExclude      = "",
		boolean composeRelationships = false,
		any target                   = $parent,
		boolean ignoreTargetLists    = false
	){
		return variables.populator.populateFromXML( argumentCollection = arguments );
	}

	/**
	 * Populate from Query, for argument definitions look at the populate method
	 *
	 * @qry                  The query to use for population
	 * @rowNumber            The row number to use for population
	 * @scope                Use scope injection instead of setter injection, no need of setters, just tell us what scope to inject to
	 * @trustedSetter        Do not check if the setter exists, just call it, great for usage with onMissingMethod() and virtual properties
	 * @include              A list of keys to include in the population ONLY
	 * @exclude              A list of keys to exclude from the population
	 * @ignoreEmpty          Ignore empty values on populations, great for ORM population
	 * @nullEmptyInclude     A list of keys to NULL when empty
	 * @nullEmptyExclude     A list of keys to NOT NULL when empty
	 * @composeRelationships Automatically attempt to compose relationships from the incoming properties memento
	 * @target               The entity to populate
	 * @ignoreTargetLists    If this is true, then the populator will ignore the target's population include/exclude metadata lists. By default this is false.
	 */
	any function populateFromQuery(
		required any qry,
		numeric rowNumber            = 1,
		string scope                 = "",
		boolean trustedSetter        = false,
		string include               = "",
		string exclude               = "",
		boolean ignoreEmpty          = false,
		string nullEmptyInclude      = "",
		string nullEmptyExclude      = "",
		boolean composeRelationships = false,
		any target                   = $parent,
		boolean ignoreTargetLists    = false
	){
		return variables.populator.populateFromQuery( argumentCollection = arguments );
	}

}
