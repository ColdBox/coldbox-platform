/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************
Author: Luis Majano
Description:

A coldfusion statistics object that communicates with the CF ehCache stats

*/
component implements="coldbox.system.cache.util.IStats" accessors="true"{

	property name="cacheStats" serializable="false";

	/**
	 * Constructor
	 *
	 * @stats Cache session stats
	 */
	CFStats function init( stats ) output=false{
		setCacheStats( arguments.stats );
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
		if( server.coldfusion.productVersion.listFirst() == 11 ){
			return getCacheStats().getObjectCount();
		} else {
			return getCacheStats().getSize();
		}
	}

	/**
	 * Clear the stats
	 *
	 * @return IStats
	 */
	function clearStatistics(){
		if( server.coldfusion.productVersion.listFirst() == 11 ){
			getCacheStats().clearStatistics();
		}
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
		if( server.coldfusion.productVersion.listFirst() == 11 ){
			return getCacheStats().getEvictionCount();
		} else {
			return getCacheStats().cacheEvictionCount();
		}
	}

	/**
	 * Get the total cache's hits
	 */
	numeric function getHits(){
		if( server.coldfusion.productVersion.listFirst() == 11 ){
			return getCacheStats().getCacheHits();
		} else {
			return getCacheStats().cacheHitCount();
		}
	}

	/**
	 * Get the total cache's misses
	 */
	numeric function getMisses(){
		if( server.coldfusion.productVersion.listFirst() == 11 ){
			return getCacheStats().getCacheMisses();
		} else {
			return getCacheStats().cacheMissCount();
		}
	}

	/**
	 * Get the date/time of the last reap the cache did
	 *
	 * @return date/time or empty
	 */
	function getLastReapDatetime(){
		return "";
	}

	/*******************************************************
	ehCache specific functions
	********************************************************/

	any function getAverageGetTime(){
		if( server.coldfusion.productVersion.listFirst() == 11 ){
			return getCacheStats().getAverageGetTime();
		} else {
			return "";
		}
	}

}