/**
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
* ----
* This is an AbstractEviction Policy object for usage in a CacheBox provider
*
* @doc_abstract true
*/
component serializable=false implements="coldbox.system.cache.policies.IEvictionPolicy" accessors="true"{

	/**
	* A logbox logger
	*/
	property name="logger";

	/**
	* Associated cache provider
	*/
	property name="cacheProvider";

	/**
	* Constructor
	* @cacheProvider The associated cache provider
	* @cacheProvider.doc_generic coldbox.system.cache.providers.ICacheProvider
	*/
	function init( required cacheProvider ){
		// link associated cache
		variables.cacheProvider = arguments.cacheProvider;
		// setup logger
		variables.logger = arguments.cacheProvider.getCacheFactory().getLogBox().getLogger( this );

		// Debug logging
		if( variables.logger.canDebug() ){
			variables.logger.debug( "Policy #getMetadata( this ).name# constructed for cache: #arguments.cacheProvider.getname()#" );
		}

		return this;
	}


	/**
	* Execute the eviction policy on the associated cache
	*/
	void function execute(){
		throw( "Abstract method!" );
	}

	/**
	* Get the Associated Cache Provider of type: coldbox.system.cache.providers.ICacheProvider
	*
	* @return coldbox.system.cache.providers.ICacheProvider
	*/
	any function getAssociatedCache(){
		return variables.cacheProvider;
	}

	/****************************************** PRIVATE ************************************************/

	/**
	 * Abstract processing of evictions
	 *
	 * @index The array of metadata keys used for processing evictions
	 */
	private function processEvictions( required array index ){
		var indexer			= variables.cacheProvider.getObjectStore().getIndexer();
		var evictCount 		= variables.cacheProvider.getConfiguration().evictCount;
		var evictedCounter 	= 0;

		// TODO: Move to streams : Loop Through Metadata
		for ( var item in arguments.index ){

			// verify object in indexer
			if( NOT indexer.objectExists( item ) ){
				continue;
			}
			var md = indexer.getObjectMetadata( item );

			// Evict if not already marked for eviction or an eternal object.
			if( md.timeout GT 0 AND NOT md.isExpired ){

				// Evict The Object
				variables.cacheProvider.clear( item );

				// Record Eviction
				variables.cacheProvider.getStats().evictionHit();
				evictedCounter++;

				// Can we break or keep on evicting
				if( evictedCounter GTE evictCount ){
					break;
				}
			}
		}//end for loop
	}

	/**
	* Get utility object
	* @return coldbox.system.core.util.Util
	*/
	private function getUtil(){
		return new coldbox.system.core.util.Util();
	}

}