/**
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.coldbox.org | www.luismajano.com | www.ortussolutions.com
* ----
* @author  original: Luis Majano, cfscript: Craig Lonsbury
* This is the LRU or least recently used algorithm for cachebox.
* It discards the least recently used items first according to the last accessed date.
* It is the default algorithm for CacheBox.
* More information can be found here: http://en.wikipedia.org/wiki/Least_Recently_Used
*/
component extends = "coldbox.system.cache.policies.AbstractEvictionPolicy"{

	/**
	* Constructor
	* @cacheProvider The associated cache provider of type: coldbox.system.cache.ICacheProvider colddoc:generic="coldbox.system.cache.ICacheProvider"
	*/
	public LRU function init( required any cacheProvider ){
		super.init( arguments.cacheProvider );

		return this;
	}
	
	/**
	* Execute the policy
	*/
	public void function execute(){
		var index = "";

		// Get searchable index
		try {
			index = getAssociatedCache()
				.getObjectStore()
				.getIndexer()
				.getSortedKeys( "LastAccessed", "numeric", "asc" );
				
			// process evictions
			processEvictions( index );
		}
		catch( any e ){
			getLogger().error( "Error sorting via store indexer #e.message# #e.detail# #e.stackTrace#." );
		}
	}

}
