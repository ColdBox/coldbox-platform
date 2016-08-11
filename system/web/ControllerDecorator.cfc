/**
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
* ---
* Base class used to decorate ColdBox MVC Application Controller
*/
component extends="coldbox.system.web.Controller" accessors="true" serializable="false"{

	// Original Controller
	property name="originalController";

	/**
	* Constructor
	*/
	ControllerDecorator function init( required controller ){
		// Store Original Controller
		variables.originalController = arguments.controller;

		// Store Original Controller Memento of instance data and services
		var memento = arguments.controller.getMemento();
		for( var thisKey in memento.variables ){
			// Only load non-udfs
			if( !isCustomFunction( memento.variables[ thisKey ] ) ){
				variables[ thisKey ] = memento.variables[ thisKey ];
			}
		}

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
		return variables.originalController;
	}

}