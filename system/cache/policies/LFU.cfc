/**
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.coldbox.org | www.luismajano.com | www.ortussolutions.com
* ----
* @author  original: Luis Majano, cfscript: Ben Koshy
* LFU Eviction Policy Command
* Removes entities from the cache that are used the least.
* More information can be found here:
* http://en.wikipedia.org/wiki/Least_Frequently_Used
*/
component extends = "coldbox.system.cache.policies.AbstractEvictionPolicy"{

	/**
	* Constructor
	* @cacheProvider The associated cache provider of type: coldbox.system.cache.ICacheProvider" colddoc:generic="coldbox.system.cache.ICacheProvider
	*/
	public LFU function init( required any cacheProvider ){
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
				.getSortedKeys( "hits", "numeric", "asc" );
			// process evictions
			processEvictions( index );
		}
		catch( any e ){
			getLogger().error( "Error sorting via store indexer #e.message# #e.detail# #e.stackTrace#." );
		}
	}

}