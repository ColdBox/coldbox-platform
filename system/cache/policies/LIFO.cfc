/**
* LIFO Eviction Policy Command
* 
* This is a LIFO eviction Policy meaning that the first object placed on cache will be the last one to come out.
* This is usually a structure that represents a stack.
* 
* More information can be found here:
* http://en.wikipedia.org/wiki/FIFO
* 
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
* 
* @author Luis Majano
*/
component extends="coldbox.system.cache.policies.AbstractEvictionPolicy" {

	/**
	* Constructor
	* 
	* @cacheProvider The associated cache provider of type: coldbox.system.cache.ICacheProvider colddoc:generic="coldbox.system.cache.ICacheProvider"
	*/
	public LIFO function init(required any cacheProvider){
		super.init(arguments.cacheProvider);
		return this;
	}

	/**
	* Execute the policy
	*/
	public void function execute() {
		var index = "";
		
		// Get searchable index
		try{
			index = getAssociatedCache().getObjectStore().getIndexer().getSortedKeys("Created", "numeric", "desc");
			// process evictions
			processEvictions(index);
		}
		catch(any e){
			getLogger().error("Error sorting via store indexer #e.message# #e.detail# #e.stackTrace#.");
		}	
	}
}