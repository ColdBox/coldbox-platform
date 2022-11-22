/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * Population Delegation with ColdBox integration
 */
component singleton {

	// DI
	property name="controller" inject="coldbox";
	property name="populator"  inject="wirebox:populator";
	property name="wirebox"    inject="wirebox";

	/**
	 * Populate an object from the incoming request collection
	 *
	 * @model                The name of the model to get and populate or the acutal model object. If you already have an instance of a model, then use the populateBean() method
	 * @scope                Use scope injection instead of setters population. Ex: scope=variables.instance.
	 * @trustedSetter        If set to true, the setter method will be called even if it does not exist in the object
	 * @include              A list of keys to include in the population
	 * @exclude              A list of keys to exclude in the population
	 * @ignoreEmpty          Ignore empty values on populations, great for ORM population
	 * @nullEmptyInclude     A list of keys to NULL when empty
	 * @nullEmptyExclude     A list of keys to NOT NULL when empty
	 * @composeRelationships Automatically attempt to compose relationships from memento
	 * @memento              A structure to populate the model, if not passed it defaults to the request collection
	 * @jsonstring           If you pass a json string, we will populate your model with it
	 * @xml                  If you pass an xml string, we will populate your model with it
	 * @qry                  If you pass a query, we will populate your model with it
	 * @rowNumber            The row of the qry parameter to populate your model with
	 * @ignoreTargetLists    If this is true, then the populator will ignore the target's population include/exclude metadata lists. By default this is false.
	 *
	 * @return The instance populated
	 */
	function populate(
		required model,
		scope                        = "",
		boolean trustedSetter        = false,
		include                      = "",
		exclude                      = "",
		boolean ignoreEmpty          = false,
		nullEmptyInclude             = "",
		nullEmptyExclude             = "",
		boolean composeRelationships = false,
		struct memento,
		string jsonstring,
		string xml,
		query qry,
		boolean ignoreTargetLists = false
	) cbMethod{
		// Do we have a model or name
		if ( isSimpleValue( arguments.model ) ) {
			arguments.target = variables.wirebox.getInstance( model );
		} else {
			arguments.target = arguments.model;
		}

		// json?
		if ( !isNull( arguments.jsonString ) ) {
			return variables.populator.populateFromJSON( argumentCollection = arguments );
		}
		// XML
		else if ( !isNull( arguments.xml ) ) {
			return variables.populator.populateFromXML( argumentCollection = arguments );
		}
		// Query
		else if ( !isNull( arguments.qry ) ) {
			return variables.populator.populateFromQuery( argumentCollection = arguments );
		}
		// Mementos
		else {
			// Param the memento to the request collection
			param arguments.memento = variables.controller
				.getRequestService()
				.getContext()
				.getCollection();
			// populate
			return variables.populator.populateFromStruct( argumentCollection = arguments );
		}
	}

}
