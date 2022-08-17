/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * A scope that leverages the request scope
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
		variables.log      = arguments.injector.getLogBox().getLogger( this );
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
		var cacheKey = "wirebox:#arguments.mapping.getName()#";

		// Check if already in request scope
		if ( NOT structKeyExists( request, cacheKey ) ) {
			// some nice debug info.
			if ( variables.log.canDebug() ) {
				variables.log.debug(
					"Object: (#arguments.mapping.getName()#) not found in request scope, beginning construction."
				);
			}

			// construct it and store it, to satisfy circular dependencies
			var target          = variables.injector.buildInstance( arguments.mapping, arguments.initArguments );
			request[ cacheKey ] = target;

			try {
				// wire it
				variables.injector.autowire( target = target, mapping = arguments.mapping );
			} catch ( any e ) {
				structDelete( request, cacheKey );
				rethrow;
			}

			// log it
			if ( variables.log.canDebug() ) {
				variables.log.debug(
					"Object: (#arguments.mapping.getName()#) constructed and stored in Request scope."
				);
			}

			return target;
		}

		return request[ cacheKey ];
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
		var cacheKey = "wirebox:#arguments.mapping.getName()#";
		return structKeyExists( request, cacheKey );
	}

}
