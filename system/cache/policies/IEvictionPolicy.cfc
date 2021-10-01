/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ----
 *
 * CacheBox Eviction policy interface
 */
interface {

	/**
	 * Execute the eviction policy on the associated cache
	 */
	void function execute();

	/**
	 * Get the Associated Cache Provider of type: coldbox.system.cache.providers.ICacheProvider
	 *
	 * @return coldbox.system.cache.providers.ICacheProvider
	 */
	any function getAssociatedCache();

}
