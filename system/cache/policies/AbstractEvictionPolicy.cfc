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
	* @cacheProvider.doc_generic coldbox.system.cache.ICacheProvider
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
	public void function execute(){
		throw( "Abstract method!" );	
	}

	/**
	* Get the Associated Cache Provider of type: coldbox.system.cache.ICacheProvider
	* 
	* @return coldbox.system.cache.ICacheProvider
	*/
	public any function getAssociatedCache(){
		return variables.cacheProvider;
	}

	/****************************************** PRIVATE ************************************************/

	/**
	* Abstract processing of evictions
	* @index The array of metadata keys used for processing evictions
	*/
	private function processEvictions( required any index ){
		var oCacheManager 	= variables.cacheProvider;
		var indexer			= oCacheManager.getObjectStore().getIndexer();
		var indexLength 	= arrayLen(arguments.index);
		var x 				= 1;
		var md 				= "";
		var evictCount 		= oCacheManager.getConfiguration().evictCount;
		var evictedCounter 	= 0;
		
		//Loop Through Metadata
		for (x=1; x lte indexLength; x=x+1){
			
			// verify object in indexer
			if( NOT indexer.objectExists( arguments.index[x] ) ){
				continue;
			}
			md = indexer.getObjectMetadata( arguments.index[x] );
			
			// Evict if not already marked for eviction or an eternal object.
			if( md.timeout gt 0 AND NOT md.isExpired ){
				
				// Evict The Object
				oCacheManager.clear( arguments.index[x] );
				
				// Record Eviction 
				oCacheManager.getStats().evictionHit();
				evictedCounter++;
				
				// Can we break or keep on evicting
				if( evictedCounter GTE evictCount ){
					break;
				}			
			}
		}//end for loop
	}
	
	/**
	* Get utiliy object
	* @return coldbox.system.core.util.Util
	*/
	private function getUtil(){
		return new coldbox.system.core.util.Util();		
	}

}