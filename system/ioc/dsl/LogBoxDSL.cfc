/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * Process DSL functions via LogBox
 **/
component accessors="true" {

	/**
	 * Injector Reference
	 */
	property name="injector";

	/**
	 * LogBox Reference
	 */
	property name="logBox";

	/**
	 * Log Reference
	 */
	property name="log";

	/**
	 * Configure the DSL Builder for operation and returns itself
	 *
	 * @injector             The linked WireBox Injector
	 * @injector.doc_generic coldbox.system.ioc.Injector
	 *
	 * @return coldbox.system.ioc.dsl.IDSLBuilder
	 */
	function init( required injector ){
		variables.injector = arguments.injector;
		variables.logBox   = variables.injector.getLogBox();
		variables.log      = variables.injector.getLogBox().getLogger( this );

		return this;
	}

	/**
	 * Process an incoming DSL definition and produce an object with it
	 *
	 * @definition   The injection dsl definition structure to process. Keys: name, dsl
	 * @targetObject The target object we are building the DSL dependency for. If empty, means we are just requesting building
	 * @targetID     The target ID we are building this dependency for
	 *
	 * @return coldbox.system.ioc.dsl.IDSLBuilder
	 */
	function process( required definition, targetObject, targetID ){
		var thisType    = arguments.definition.dsl;
		var thisTypeLen = listLen( thisType, ":" );

		// DSL stages
		switch ( thisTypeLen ) {
			// logbox
			case 1: {
				return variables.logBox;
			}

			// logbox:root and logbox:logger
			case 2: {
				var thisLocationKey = getToken( thisType, 2, ":" );
				switch ( thisLocationKey ) {
					case "root": {
						return variables.logbox.getRootLogger();
					}
					case "logger": {
						return variables.logbox.getLogger( arguments.definition.name );
					}
				}
				break;
			}

			// Named Loggers
			case 3: {
				var thisLocationType = getToken( thisType, 2, ":" );
				var thisLocationKey  = getToken( thisType, 3, ":" );
				// DSL Level 2 Stage Types
				switch ( thisLocationType ) {
					// Get a named Logger
					case "logger": {
						// Check for {this} and targetobject exists
						if ( thisLocationKey eq "{this}" AND structKeyExists( arguments, "targetObject" ) ) {
							return variables.logBox.getLogger( arguments.targetObject );
						}
						// Normal Logger injection
						return variables.logBox.getLogger( thisLocationKey );
						break;
					}
				}
				break;
			}
			// end level 3 main DSL
		}
	}

}
