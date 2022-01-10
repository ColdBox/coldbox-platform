/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * Process DSL functions via CacheBox
 **/
component accessors="true" {

	/**
	 * Injector Reference
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
	 * Configure the DSL Builder for operation and returns itself
	 *
	 * @injector             The linked WireBox Injector
	 * @injector.doc_generic coldbox.system.ioc.Injector
	 *
	 * @return coldbox.system.ioc.dsl.IDSLBuilder
	 */
	function init( required injector ){
		variables.injector = arguments.injector;
		variables.cacheBox = variables.injector.getCacheBox();
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
			// CacheBox
			case 1: {
				return variables.cacheBox;
			}

			// CacheBox:CacheName
			case 2: {
				var cacheName = getToken( thisType, 2, ":" );
				// Verify that cache exists
				if ( variables.cacheBox.cacheExists( cacheName ) ) {
					return variables.cacheBox.getCache( cacheName );
				} else if ( variables.log.canDebug() ) {
					variables.log.debug(
						"getCacheBoxDSL() cannot find named cache #cacheName# using definition: #arguments.definition.toString()#. Existing cache names are #variables.cacheBox.getCacheNames().toString()#"
					);
				}
				break;
			}

			// CacheBox:CacheName:Element
			case 3: {
				var cacheName    = getToken( thisType, 2, ":" );
				var cacheElement = getToken( thisType, 3, ":" );
				// Verify that dependency exists in the Cache container
				if ( variables.cacheBox.getCache( cacheName ).lookup( cacheElement ) ) {
					return variables.cacheBox.getCache( cacheName ).get( cacheElement );
				} else if ( variables.log.canDebug() ) {
					variables.log.debug(
						"getCacheBoxDSL() cannot find cache Key: #cacheElement# in the #cacheName# cache using definition: #arguments.definition.toString()#"
					);
				}
				break;
			}
			// end level 3 main DSL
		}
	}

}
