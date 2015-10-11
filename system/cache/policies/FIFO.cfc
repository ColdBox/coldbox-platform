/**
*
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.coldbox.org | www.luismajano.com | www.ortussolutions.com
*
* @file  /coldbox-platform/system/cache/policies/FIFO.cfc
* @author  original: Luis Majano, cfscript: Ben Koshy
* @date original: 11/14/2007 cfscript: 10/11/2015
* @description
* 	This is a FIFO eviction Policy meaning that the first object placed on cache will be the first one to come out.
* 	More information can be found here: http://en.wikipedia.org/wiki/FIFO
*/
component
	output 	= false
	hint 	= "FIFO Eviction Policy Command"
	extends = "coldbox.system.cache.policies.AbstractEvictionPolicy"
{

	public function init( required any cacheProvider hint="The associated cache provider of type: coldbox.system.cache.ICacheProvider" colddoc:generic="coldbox.system.cache.ICacheProvider")
		output = false
		hint = "Constructor"
	{
		super.init( arguments.cacheProvider );

		return this;
	} // init()

	public void function execute()
		output = false
		hint = "Execute the Policy"
	{
		var index = "";			
		// Get searchable index
		try {
			index = getAssociatedCache().getObjectStore().getIndexer().getSortedKeys( "created", "numeric", "asc" );
			// process evictions
			processEvictions( index );
		}
		catch( any e ){
			getLogger().error( "Error sorting via store indexer #e.message# #e.detail# #e.stackTrace#." );
		}	

	} // execute()
}