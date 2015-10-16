/** 
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
********************************************************************************
* Date        :	11/14/2007
* Description :
* 	This is a FIFO eviction Policy meaning that the first object placed on cache
*	will be the first one to come out.
*
* More information can be found here:
* http://en.wikipedia.org/wiki/FIFO
* 
* @author Luis Majano <lmajano@ortussolutions.com>
*/

component output="false" extends="coldbox.system.cache.policies.AbstractEvictionPolicy" {

	/** 
	* Constructor
	* @controller.hint FIFO Eviction Policy Command
	* @cacheProvider.hint The associated cache provider of type: coldbox.system.cache.ICacheProvider" colddoc:generic="coldbox.system.cache.ICacheProvider
	*/

	public FIFO function init ( required any cacheProvider  ) output="false" {

		super.init(arguments.cacheProvider);

		return this;
	}

//------------------------------------------- PUBLIC -------------------------------------------

	/**
	* Execute the policy
	*/

	public void function execute () output="false" {
			var index 		= "";
			
			// Get searchable index
			try{
				index 	= getAssociatedCache().getObjectStore().getIndexer().getSortedKeys("created","numeric","asc");
				// process evictions
				processEvictions( index );
			}
			catch(Any e){
				getLogger().error("Error sorting via store indexer #e.message# #e.detail# #e.stackTrace#.");
			}	
	}

//------------------------------------------- PRIVATE --------------------------------------------

}
	
