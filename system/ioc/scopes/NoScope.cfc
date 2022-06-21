/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * A no scope scope scope :)
 *
 * @see coldbox.system.ioc.scopes.IScope
 **/
component accessors="true" {

	/**
	 * Injector linkage
	 */
	property name="injector";

	/**
	 * Log Reference
	 */
	property name="log";

	/**
	 * Configure the scope for operation and returns itself
	 *
	 * @injector             The linked WireBox injector
	 * @injector.doc_generic coldbox.system.ioc.Injector
	 *
	 * @return coldbox.system.ioc.scopes.IScope
	 */
	function init( required injector ){
		variables.injector = arguments.injector;
		return this;
	}

	/**
	 * Retrieve an object from scope or create it if not found in scope
	 *
	 * @mapping             The linked WireBox injector
	 * @mapping.doc_generic coldbox.system.ioc.config.Mapping
	 * @initArguments       The constructor struct of arguments to passthrough to initialization
	 */
	function getFromScope( required mapping, struct initArguments ){
		// create and return the no scope instance, no locking needed.
		var object = variables.injector.buildInstance( arguments.mapping, arguments.initArguments );
		// wire it
		variables.injector.autowire(
			target   = object,
			mapping  = arguments.mapping,
			targetId = arguments.mapping.getName()
		);
		// send it back
		return object;
	}


	/**
	 * Indicates whether an object exists in scope
	 *
	 * @mapping             The linked WireBox injector
	 * @mapping.doc_generic coldbox.system.ioc.config.Mapping
	 *
	 * @return coldbox.system.ioc.scopes.IScope
	 */
	boolean function exists( required mapping ){
		return false;
	}

}
