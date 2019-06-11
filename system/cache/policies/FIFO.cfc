/**
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
* ----
* This is a FIFO eviction Policy meaning that the first object placed on cache
* will be the first one to come out.
*
* More information can be found here:
* http://en.wikipedia.org/wiki/FIFO
*/
component extends="coldbox.system.cache.policies.AbstractEvictionPolicy"{

	/**
	 * Constructor
	 *
	 * @cacheProvider The associated cache provider of type: coldbox.system.cache.providers.ICacheProvider" doc_generic="coldbox.system.cache.providers.ICacheProvider
 	 */
	FIFO function init ( required any cacheProvider  ){
		super.init( arguments.cacheProvider );

		return this;
	}

	/**
	 * Execute the policy
	 */
	void function execute (){
		// Get searchable index
		try{
			var index = getAssociatedCache()
				.getObjectStore()
				.getIndexer()
				.getSortedKeys( "created", "numeric", "asc" );
			// process evictions
			processEvictions( index );
		} catch( Any e ) {
			getLogger().error( "Error sorting via store indexer #e.message# #e.detail# #e.stackTrace#." );
		}
	}

}