/**
*
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.coldbox.org | www.luismajano.com | www.ortussolutions.com
*
* @file  /coldbox-platform/system/cache/policies/LFU.cfc
* @author  original: Luis Majano, cfscript: Ben Koshy
* @date original: 11/14/2007 cfscript: 10/11/2015
* @description
	Removes entities from the cache that are used the least.
	
	More information can be found here:
	http://en.wikipedia.org/wiki/Least_Frequently_Used
*/
component
	name = "LFU"
	output = false
	hint = "LFU Eviction Policy Command"
	extends = "coldbox.system.cache.policies.AbstractEvictionPolicy"
{
	/**
	* Constructor
	* @cacheprovider The associated cache provider of type: coldbox.system.cache.ICacheProvider" colddoc:generic="coldbox.system.cache.ICacheProvider
	*/
	public LFU function init( required any cacheProvider ){
		super.init( arguments.cacheProvider );
			
		return this;
	} // init()

/*------------------------------------------- PUBLIC -------------------------------------------*/
	/**
	* Execute the policy
	*/
	public void function execute(){
		var index = "";
		
		// Get searchable index
		try {
			index 	= getAssociatedCache().getObjectStore().getIndexer().getSortedKeys( "hits", "numeric", "asc" );
			// process evictions
			processEvictions( index );
		}
		catch( any e ){
			getLogger().error("Error sorting via store indexer #e.message# #e.detail# #e.stackTrace#.");
		}		
	} // execute()

/*------------------------------------------- PRIVATE ------------------------------------------- */
}