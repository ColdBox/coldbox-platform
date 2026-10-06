/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * A scope that interfaces with CacheBox
 *
 * @see coldbox.system.ioc.scopes.IScope
 **/
component accessors="true" {

	/**
	 * Injector linkage
	 */
	property name="injector";

	/**
	 * CacheBox Reference
	 */
	property name="cacheBox";

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
		variables.cacheBox = arguments.injector.getCacheBox();
		// keys of objects currently being built and wired
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
		var cacheProperties = arguments.mapping.getCacheProperties();
		var refLocal        = {};
		var cacheProvider   = variables.cacheBox.getCache( cacheProperties.provider );
		var cacheKey        = "#cacheProperties.key#";

		// Get From Cache
		refLocal.target = cacheProvider.get( cacheKey );

		// Verify it. An object stored before wiring (circular dependency support) is not ready for other threads,
		// so they queue on the lock. The wiring thread re-enters its own lock and gets the stored instance.
		if ( isNull( local.refLocal.target ) OR variables.wiring.containsKey( cacheKey ) ) {
			// One lock for all scopes, so threads building circular dependencies from opposite ends cannot deadlock
			lock
				name                 ="WireBox.#variables.injector.getInjectorID()#.ScopeWiring"
				type                 ="exclusive"
				timeout              ="30"
				throwontimeout       ="true" {
				// Double get just in case of race conditions
				local.refLocal.target= cacheProvider.get( cacheKey );
				if ( !isNull( local.refLocal.target ) ) {
					return local.refLocal.target;
				}

				variables.wiring.put( cacheKey, true )
				try {
					// some nice debug info.
					if ( variables.log.canDebug() ) {
						variables.log.debug(
							"Object: (#cacheProperties.toString()#) not found in cacheBox, beginning construction by (#variables.injector.getName()#) injector"
						);
					}

					// construct it
					local.refLocal.target = variables.injector.buildInstance(
						arguments.mapping,
						arguments.initArguments
					);

					// If not in wiring thread safety, store in singleton cache to satisfy circular dependencies
					if ( NOT arguments.mapping.getThreadSafe() ) {
						cacheProvider.set(
							cacheKey,
							local.refLocal.target,
							cacheProperties.timeout,
							cacheProperties.lastAccessTimeout
						);
					}

					try {
						// wire up dependencies on the object
						variables.injector.autowire( target = local.refLocal.target, mapping = arguments.mapping );
					} catch ( any e ) {
						cacheProvider.clear( cacheKey );
						rethrow;
					}

					// If thread safe, then now store it in the cache, as all dependencies are now safely wired
					if ( arguments.mapping.getThreadSafe() ) {
						cacheProvider.set(
							cacheKey,
							local.refLocal.target,
							cacheProperties.timeout,
							cacheProperties.lastAccessTimeout
						);
					}

					// log it
					if ( variables.log.canDebug() ) {
						variables.log.debug(
							"Object: (#cacheProperties.toString()#) constructed and stored in cacheBox. ThreadSafe=#arguments.mapping.getThreadSafe()# by (#variables.injector.getName()#) injector"
						);
					}

					// return it
					return local.refLocal.target;
				} finally {
					variables.wiring.remove( cacheKey )
				}
			}
			// end lock
		} else {
			return local.refLocal.target;
		}
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
		return variables.cacheProvider.lookupQuiet( arguments.mapping.getCacheProperties().key );
	}

}
