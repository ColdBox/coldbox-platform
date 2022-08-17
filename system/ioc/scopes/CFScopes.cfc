/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * A scope that stores in valid CF scopes
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
		var CFScope  = arguments.mapping.getScope();
		var cacheKey = "wirebox:#arguments.mapping.getName()#";

		// Verify it
		if ( !variables.injector.getScopeStorage().exists( cacheKey, CFScope ) ) {
			// Lock it
			lock
				name          ="WireBox.#variables.injector.getInjectorID()#.#CFScope#.#cacheKey#"
				type          ="exclusive"
				timeout       ="30"
				throwontimeout="true" {
				if ( !variables.injector.getScopeStorage().exists( cacheKey, CFScope ) ) {
					// some nice debug info.
					if ( variables.log.canDebug() ) {
						variables.log.debug(
							"Object: (#arguments.mapping.getName()#) not found in CFScope (#CFScope#), beginning construction."
						);
					}

					// construct the variables
					var target = variables.injector.buildInstance( arguments.mapping, arguments.initArguments );

					// If not in wiring thread safety, store in scope to satisfy circular dependencies
					if ( NOT arguments.mapping.getThreadSafe() ) {
						variables.injector.getScopeStorage().put( cacheKey, target, CFScope );
					}

					try {
						// wire it
						variables.injector.autowire( target = target, mapping = arguments.mapping );
					} catch ( any e ) {
						variables.injector.getScopeStorage().delete( cacheKey, CFScope );
						rethrow;
					}

					// If thread safe, then now store it in the scope, as all dependencies are now safely wired
					if ( arguments.mapping.getThreadSafe() ) {
						variables.injector.getScopeStorage().put( cacheKey, target, CFScope );
					}

					// log it
					if ( variables.log.canDebug() ) {
						variables.log.debug(
							"Object: (#arguments.mapping.getName()#) constructed and stored in CFScope (#CFScope#), threadSafe=#arguments.mapping.getThreadSafe()#."
						);
					}

					return target;
				}
			}
			// end lock
		}

		return variables.injector.getScopeStorage().get( cacheKey, CFScope );
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
		var CFScope  = arguments.mapping.getScope();

		return variables.injector.getScopeStorage().exists( cacheKey, CFScope );
	}

}
