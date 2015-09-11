/********************************************************************************
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
********************************************************************************
* Base class used to decorate ColdBox MVC Application Controller
*/
component extends="coldbox.system.web.context.RequestContext" accessors="true" serializable="false"{

	// The original request context
	property name="requestContext";

	/**
	* Constructor
	*/
	RequestContextDecorator function init( required oContext, required controller ){
		// Set the memento state
		setMemento( arguments.oContext.getMemento() );
		// Set Controller
		instance.controller = arguments.controller;
		// Composite the original context
		variables.requestContext = arguments.oContext;

		return this;
	}

	/**
	* Override to provide a pseudo-constructor for your decorator
	*/
	function configure(){}

	/**
	* Get original controller
	*/
	function getController(){
		return instance.controller;
	}

}