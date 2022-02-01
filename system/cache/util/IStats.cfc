/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 *
 * The main interface for a CacheBox cache provider statistics object
 *
 * @author Luis Majano
 */
interface {

	/**
	 * Get the cache's performance ratio
	 */
	numeric function getCachePerformanceRatio();

	/**
	 * Get the associated cache's live object count
	 */
	numeric function getObjectCount();

	/**
	 * Clear the stats
	 *
	 * @return IStats
	 */
	function clearStatistics();

	/**
	 * Get the total cache's garbage collections
	 */
	numeric function getGarbageCollections();

	/**
	 * Get the total cache's eviction count
	 */
	numeric function getEvictionCount();

	/**
	 * Get the total cache's hits
	 */
	numeric function getHits();

	/**
	 * Get the total cache's misses
	 */
	numeric function getMisses();

	/**
	 * Get the date/time of the last reap the cache did
	 *
	 * @return date/time or empty
	 */
	function getLastReapDatetime();

}
