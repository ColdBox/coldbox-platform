/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * A scope that stores in valid engine scopes (application, session, server)
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
		// scope:key of objects currently being built and wired
		variables.wiring   = createObject( "java", "java.util.concurrent.ConcurrentHashMap" ).init();
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
		var CFScope   = arguments.mapping.getScope();
		var cacheKey  = "wirebox:#arguments.mapping.getName()#";
		var wiringKey = "#CFScope#:#cacheKey#";
		var storage   = variables.injector.getScopeStorage();

		// Verify it. An object stored before wiring (circular dependency support) is not ready for other threads,
		// so they queue on the lock. The wiring thread re-enters its own lock and gets the stored instance.
		if ( !storage.exists( cacheKey, CFScope ) OR variables.wiring.containsKey( wiringKey ) ) {
			// One lock for all scopes, so threads building circular dependencies from opposite ends cannot deadlock
			lock
				name          ="WireBox.#variables.injector.getInjectorID()#.ScopeWiring"
				type          ="exclusive"
				timeout       ="30"
				throwontimeout="true" {
				if ( !storage.exists( cacheKey, CFScope ) ) {
					variables.wiring.put( wiringKey, true )
					try {
						// some nice debug info.
						if ( variables.log.canDebug() ) {
							variables.log.debug(
								"Object: (#arguments.mapping.getName()#) not found in CFScope (#CFScope#), beginning construction by (#variables.injector.getName()#) injector"
							);
						}

						// construct the variables
						var target = variables.injector.buildInstance( arguments.mapping, arguments.initArguments );

						// If not in wiring thread safety, store in scope to satisfy circular dependencies
						if ( NOT arguments.mapping.getThreadSafe() ) {
							storage.put( cacheKey, target, CFScope );
						}

						try {
							// wire it
							variables.injector.autowire( target = target, mapping = arguments.mapping );
						} catch ( any e ) {
							storage.delete( cacheKey, CFScope );
							rethrow;
						}

						// If thread safe, then now store it in the scope, as all dependencies are now safely wired
						if ( arguments.mapping.getThreadSafe() ) {
							storage.put( cacheKey, target, CFScope );
						}

						// log it
						if ( variables.log.canDebug() ) {
							variables.log.debug(
								"Object: (#arguments.mapping.getName()#) constructed and stored in CFScope (#CFScope#), threadSafe=#arguments.mapping.getThreadSafe()# by (#variables.injector.getName()#) injector"
							);
						}

						return target;
					} finally {
						variables.wiring.remove( wiringKey )
					}
				}
			}
			// end lock
		}

		return storage.get( cacheKey, CFScope );
	}


	/**
	 * Indicates whether an object exists in scope
	 *
	 * @mapping             The linked WireBox injector
	 * @mapping.doc_generic coldbox.system.ioc.config.Mapping
	 *
	 * @return True if the mapping exists in the singleton cache
	 */
	boolean function exists( required mapping ){
		var cacheKey = "wirebox:#arguments.mapping.getName()#";
		var CFScope  = arguments.mapping.getScope();

		return storage.exists( cacheKey, CFScope );
	}

}
