/**
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
* ----
*
* CacheBox Eviction polify interface
*/ 
interface{
	
	/**
	* Execute the eviction policy on the associated cache
	*/
	public void function execute();

	/**
	* Get the Associated Cache Provider of type: coldbox.system.cache.ICacheProvider
	* 
	* @return coldbox.system.cache.ICacheProvider
	*/
	public any function getAssociatedCache();	

}