component accessors="true" {

	property name="name";

	function init( required injector ){
		variables.injector = arguments.injector;
		return this;
	}

	function process( required definition, targetObject, targetID ){
		variables.name = getToken( arguments.definition.dsl, 2, ":" );
		return this;
	}

}
