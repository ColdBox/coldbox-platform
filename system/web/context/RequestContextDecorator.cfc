/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * Base class used to decorate ColdBox MVC Application Controller
 */
component accessors="true" serializable="false" {

	// The original request context
	property name="requestContext";

	/**
	 * Constructor
	 */
	RequestContextDecorator function init( required oContext, required controller ){
		// Composite the original context
		variables.requestContext = arguments.oContext;
		variables.requestContext.setController( arguments.controller );

		return this;
	}

	/**
	 * Override to provide a pseudo-constructor for your decorator
	 */
	function configure(){
	}

	function getController(){
		return variables.requestContext.getController();
	}

	/**
	 * Get original controller
	 */
	function onMissingMethod( required string missingMethodName, required struct missingMethodArguments ){
		return invoke(
			variables.requestContext,
			arguments.missingMethodName,
			arguments.missingMethodArguments
		);
	}

}
