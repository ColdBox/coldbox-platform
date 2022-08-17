/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * Tracking of single instance objects: Singletons
 *
 * @see coldbox.system.ioc.scopes.IScope
 **/
component accessors="true" {

	/**
	 * Injector linkage
	 */
	property name="injector";

	/**
	 * Track singletons as a concurrent hash map
	 */
	property name="singletons";

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
		variables.injector   = arguments.injector;
		variables.singletons = createObject( "java", "java.util.concurrent.ConcurrentHashMap" ).init();
		variables.log        = arguments.injector.getLogBox().getLogger( this );
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
		var cacheKey = lCase( arguments.mapping.getName() );

		// Verify in Singleton Cache
		if ( NOT variables.singletons.containsKey( cacheKey ) ) {
			// Lock it
			lock
				name          ="WireBox.#variables.injector.getInjectorID()#.Singleton.#cacheKey#"
				type          ="exclusive"
				timeout       ="30"
				throwontimeout="true" {
				// double lock it
				if ( NOT variables.singletons.containsKey( cacheKey ) ) {
					// some nice debug info.
					if ( variables.log.canDebug() ) {
						variables.log.debug(
							"Object: (#cacheKey#) not found in singleton cache, beginning construction."
						);
					}

					// construct the singleton object
					var tmpSingleton = variables.injector.buildInstance(
						arguments.mapping,
						arguments.initArguments
					);

					// If not in wiring thread safety, store in singleton cache to satisfy circular dependencies
					if ( NOT arguments.mapping.getThreadSafe() ) {
						variables.singletons.put( cacheKey, tmpSingleton );
					}

					try {
						// wire up dependencies on the singleton object
						variables.injector.autowire( target = tmpSingleton, mapping = arguments.mapping );
					} catch ( any e ) {
						variables.singletons.remove( cacheKey );
						rethrow;
					}

					// If thread safe, then now store it in the singleton cache, as all dependencies are now safely wired
					if ( arguments.mapping.getThreadSafe() ) {
						variables.singletons.put( cacheKey, tmpSingleton );
					}

					// log it
					if ( variables.log.canDebug() ) {
						variables.log.debug(
							"Object: (#cacheKey#) constructed and stored in singleton cache. ThreadSafe=#arguments.mapping.getThreadSafe()#"
						);
					}

					// return it
					return variables.singletons.get( cacheKey );
				}
			}
			// end lock
		}

		// return singleton
		return variables.singletons.get( cacheKey );
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
		return variables.singletons.containsKey( lCase( arguments.mapping.getName() ) );
	}

	/**
	 * Clear the singletons scopes
	 */
	function clear(){
		variables.singletons = createObject( "java", "java.util.concurrent.ConcurrentHashMap" ).init();
		return this;
	}

}
