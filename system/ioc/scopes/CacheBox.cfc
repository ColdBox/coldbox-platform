/**
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
* ---
* A scope that interfaces with CacheBox
**/
component implements="coldbox.system.ioc.scopes.IScope" accessors="true"{

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
	 *
	 * @injector The linked WireBox injector
	 * @injector.doc_generic coldbox.system.ioc.Injector
	 *
	 * @return coldbox.system.ioc.scopes.IScope
	 */
	function init( required injector ){
		variables.injector 	= arguments.injector;
		variables.cacheBox 	= arguments.injector.getCacheBox();
		variables.log		= arguments.injector.getLogBox().getLogger( this );
		return this;
	}

	/**
	 * Retrieve an object from scope or create it if not found in scope
	 *
	 *
	 * @mapping The linked WireBox injector
	 * @mapping.doc_generic coldbox.system.ioc.config.Mapping
	 * @initArguments The constructor struct of arguments to passthrough to initialization
	 */
	function getFromScope( required mapping, struct initArguments ){
		var cacheProperties = arguments.mapping.getCacheProperties();
		var refLocal		= {};
		var cacheProvider	= variables.cacheBox.getCache( cacheProperties.provider );
		var cacheKey		= "#cacheProperties.key#";

		// Get From Cache
		refLocal.target = cacheProvider.get( cacheKey );

		// Verify it
		if( isNull( refLocal.target ) ){
			// Lock it
			lock	name="WireBox.#variables.injector.getInjectorID()#.CacheBoxScope.#arguments.mapping.getName()#"
					type="exclusive"
					timeout="30"
					throwontimeout="true"{

				// Double get just in case of race conditions
				refLocal.target = cacheProvider.get( cacheKey );
				if( !isNull( refLocal.target ) ){
					return refLocal.target;
				}

				// some nice debug info.
				if( variables.log.canDebug() ){
					variables.log.debug("Object: (#cacheProperties.toString()#) not found in cacheBox, beginning construction.");
				}

				// construct it
				refLocal.target = variables.injector.buildInstance( arguments.mapping, arguments.initArguments );

				// If not in wiring thread safety, store in singleton cache to satisfy circular dependencies
				if( NOT arguments.mapping.getThreadSafe() ){
					cacheProvider.set(
						cacheKey,
						refLocal.target,
						cacheProperties.timeout,
						cacheProperties.lastAccessTimeout
					);
				}

				// wire up dependencies on the object
				variables.injector.autowire( target=refLocal.target, mapping=arguments.mapping );

				// If thread safe, then now store it in the cache, as all dependencies are now safely wired
				if( arguments.mapping.getThreadSafe() ){
					cacheProvider.set(
						cacheKey,
						refLocal.target,
						cacheProperties.timeout,
						cacheProperties.lastAccessTimeout
					);
				}

				// log it
				if( variables.log.canDebug() ){
					variables.log.debug( "Object: (#cacheProperties.toString()#) constructed and stored in cacheBox. ThreadSafe=#arguments.mapping.getThreadSafe()#" );
				}

				// return it
				return refLocal.target;

			}// end lock
		} else {
			return refLocal.target;
		}
	}


	/**
	 * Indicates whether an object exists in scope
	 *
	 * @mapping The linked WireBox injector
	 * @mapping.doc_generic coldbox.system.ioc.config.Mapping
	 *
	 * @return coldbox.system.ioc.scopes.IScope
	 */
	boolean function exists( required mapping ){
		return variables.cacheProvider.lookupQuiet( arguments.mapping.getCacheProperties().key );
	}

}