/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 *
 * This is a cache statistics object.  We do not use internal method calls but leverage the properties directly so it is faster.
 *
 * @author Luis Majano
 */
component implements="coldbox.system.cache.util.IStats" accessors="true" {

	/**
	 * The associated cache manager/provider of type: coldbox.system.cache.providers.ICacheProvider
	 */
	property name="cacheProvider" doc_generic="coldbox.system.cache.providers.ICacheProvider";

	/**
	 * Recording of last reap
	 */
	property name="lastReapDateTime";
	/**
	 * Cache hits
	 */
	property name="hits" default="0";
	/**
	 * Cache misses
	 */
	property name="misses" default="0";
	/**
	 * Eviction counts
	 */
	property name="evictionCount" default="0";
	/**
	 * Garbage collection counts
	 */
	property name="garbageCollections" default="0";

	/**
	 * Constructor
	 *
	 * @cacheProvider             The associated cache manager/provider of type: coldbox.system.cache.providers.ICacheProvider
	 * @cacheProvider.doc_generic coldbox.system.cache.providers.ICacheProvider
	 */
	function init( required cacheProvider ){
		variables.cacheProvider = arguments.cacheProvider;
		// Clear the stats to start fresh.
		clearStatistics();

		return this;
	}

	/**
	 * Get the associated cache provider/manager of type: coldbox.system.cache.providers.ICacheProvider
	 *
	 * @return coldbox.system.cache.providers.ICacheProvider
	 */
	function getAssociatedCache(){
		return variables.cacheProvider;
	}

	/**
	 * Get the cache's performance ratio
	 */
	numeric function getCachePerformanceRatio(){
		var requests = variables.hits + variables.misses;

		if ( requests eq 0 ) {
			return 0;
		}

		return ( variables.hits / requests ) * 100;
	}

	/**
	 * Get the associated cache's live object count
	 */
	numeric function getObjectCount(){
		return getAssociatedCache().getSize();
	}

	/**
	 * Clear the stats
	 *
	 * @return IStats
	 */
	function clearStatistics(){
		variables.lastReapDatetime   = now();
		variables.hits               = 0;
		variables.misses             = 0;
		variables.evictionCount      = 0;
		variables.garbageCollections = 0;

		return this;
	}

	/**
	 * Get the total cache's garbage collections
	 */
	numeric function getGarbageCollections(){
		return variables.garbageCollections;
	}

	/**
	 * Get the total cache's eviction count
	 */
	numeric function getEvictionCount(){
		return variables.evictionCount;
	}

	/**
	 * Get the total cache's hits
	 */
	numeric function getHits(){
		return variables.hits;
	}

	/**
	 * Get the total cache's misses
	 */
	numeric function getMisses(){
		return variables.misses;
	}

	/**
	 * Get the date/time of the last reap the cache did
	 *
	 * @return date/time or empty
	 */
	function getLastReapDatetime(){
		return variables.lastReapDatetime;
	}

	/**
	 * Record an eviction hit
	 */
	CacheStats function evictionHit(){
		variables.evictionCount++;
		return this;
	}

	/**
	 * Record an garbage collection hit
	 */
	CacheStats function GCHit(){
		variables.garbageCollections++;
		return this;
	}

	/**
	 * Record an cache hit
	 */
	CacheStats function hit(){
		variables.hits++;
		return this;
	}

	/**
	 * Record an cache miss
	 */
	CacheStats function miss(){
		variables.misses++;
		return this;
	}

	/**
	 * A quick snapshot of the stats state
	 */
	struct function getMemento(){
		return variables.filter( function( k, v ){
			return ( !isCustomFunction( v ) && !isObject( v ) );
		} );
	}

}
