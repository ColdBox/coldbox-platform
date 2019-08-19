/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************
Author: Luis Majano
Description:

A coldfusion statistics object that communicates with the lucee cache stats

*/
component implements="coldbox.system.cache.util.IStats" accessors="true"{

	property name="cacheProvider" serializable="false";

	/**
	 * Constructor
	 *
	 * @cacheProvider The associated cache manager/provider of type: coldbox.system.cache.providers.ICacheProvider
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
		var hits 		= getHits();
		var requests 	= hits + getMisses();

	 	if ( requests eq 0){
	 		return 0;
		}

		return (hits/requests) * 100;
	}

	/**
	 * Get the associated cache's live object count
	 */
	numeric function getObjectCount(){
		return cacheCount( getCacheProvider().getConfiguration().cacheName );
	}

	/**
	 * Clear the stats
	 *
	 * @return IStats
	 */
	function clearStatistics(){
		return this;
	}

	/**
	 * Get the total cache's garbage collections
	 */
	numeric function getGarbageCollections(){
		return 0;
	}

	/**
	 * Get the total cache's eviction count
	 */
	numeric function getEvictionCount(){
		return 0;
	}

	/**
	 * Get the total cache's hits
	 */
	numeric function getHits() {
		var props = cacheGetProperties( getCacheProvider().getConfiguration().cacheName );
		if( arrayLen( props ) and structKeyExists( props[ 1 ], "hit_count" ) ){
			return props[ 1 ].hit_count;
		}
		return 0;
	}

	/**
	 * Get the total cache's misses
	 */
	numeric function getMisses(){
		var props = cacheGetProperties( getCacheProvider().getConfiguration().cacheName );
		if( arrayLen( props ) and structKeyExists( props[ 1 ], "miss_count" ) ){
			return props[ 1 ].miss_count;
		}
		return 0;
	}

	/**
	 * Get the date/time of the last reap the cache did
	 *
	 * @return date/time or empty
	 */
	function getLastReapDatetime(){
		return "";
	}

}