/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 *
 * Boxlang stats implementation
 *
 * @author Luis Majano
 */
component implements="coldbox.system.cache.util.IStats" accessors="true" {

	property name="cacheProvider" serializable="false";

	/**
	 * Constructor
	 *
	 * @cacheProvider             The associated cache manager/provider of type: coldbox.system.cache.providers.ICacheProvider
	 * @cacheProvider.doc_generic coldbox.system.cache.providers.ICacheProvider
	 */
	function init( required cacheProvider ){
		setCacheProvider( arguments.cacheProvider );
		return this;
	}

	/**
	 * Get the cache's performance ratio
	 */
	numeric function getCachePerformanceRatio(){
		return getCacheProvider()
			.getCache()
			.getStats()
			.hitRate();
	}

	/**
	 * Get the associated cache's live object count
	 */
	numeric function getObjectCount(){
		return getCacheProvider().getSize();
	}

	/**
	 * Clear the stats
	 *
	 * @return IStats
	 */
	function clearStatistics(){
		return getCacheProvider().clearStatistics();
		return this;
	}

	/**
	 * Get the total cache's garbage collections
	 */
	numeric function getGarbageCollections(){
		return getCacheProvider()
			.getCache()
			.getStats()
			.garbageCollections();
	}

	/**
	 * Get the total cache's eviction count
	 */
	numeric function getEvictionCount(){
		return getCacheProvider()
			.getCache()
			.getStats()
			.evictionCount();
	}

	/**
	 * Get the total cache's hits
	 */
	numeric function getHits(){
		return getCacheProvider()
			.getCache()
			.getStats()
			.hits();
	}

	/**
	 * Get the total cache's misses
	 */
	numeric function getMisses(){
		return getCacheProvider()
			.getCache()
			.getStats()
			.misses();
	}

	/**
	 * Get the date/time of the last reap the cache did
	 *
	 * @return date/time or empty
	 */
	function getLastReapDatetime(){
		return getCacheProvider()
			.getCache()
			.getStats()
			.lastReapDatetime();
	}

	/**
	 * Get the total cache's reap count
	 */
	numeric function getReapCount(){
		return getCacheProvider()
			.getCache()
			.getStats()
			.reapCount();
	}

	/**
	 * When the cache was started
	 */
	function getStarted(){
		return getCacheProvider()
			.getCache()
			.getStats()
			.started();
	}

}
