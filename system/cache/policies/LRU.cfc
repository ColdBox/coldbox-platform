/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ----
 *
 * This is the LRU or least recently used algorithm for cachebox.
 * It basically discards the least recently used items first according to the last accessed date.
 * This is also the default algorithm for CacheBox.
 *
 * For more information visit: http://en.wikipedia.org/wiki/Least_Recently_Used
 */
component extends="coldbox.system.cache.policies.AbstractEvictionPolicy" {

	/**
	 * This is the constructor
	 *
	 * @cacheProvider The associated cache provider of type: coldbox.system.cache.providers.ICacheProvider" doc_generic="coldbox.system.cache.providers.ICacheProvider
	 */
	LRU function init( required any cacheProvider ){
		super.init( arguments.cacheProvider );

		return this;
	}

	/**
	 * Execute the policy
	 */
	void function execute(){
		// Get searchable index
		try {
			var index = getAssociatedCache()
				.getObjectStore()
				.getIndexer()
				.getSortedKeys( "LastAccessed", "numeric", "asc" );
			// process evictions
			processEvictions( index );
		} catch ( Any e ) {
			getLogger().error( "Error sorting via store indexer #e.message# #e.detail# #e.stackTrace#." );
		}
	}

}
