/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************
Author: Luis Majano
Description:
	
A coldfusion statistics object that communicates with the Railo cache stats

*/
component implements="coldbox.system.cache.util.ICacheStats" accessors="true"{
	
	property name="cacheProvider" serializable="false";

	RailoStats function init( cacheProvider ) output=false{
		setCacheProvider( arguments.cacheProvider );
		return this;
	}
	
	any function getCachePerformanceRatio() output=false{
		var hits 		= getHits();
		var requests 	= hits + getMisses();
		
	 	if ( requests eq 0){
	 		return 0;
		}
		
		return (hits/requests) * 100;
	}
	
	any function getObjectCount() output=false{
		return cacheCount( getCacheProvider().getConfiguration().cacheName );
	}
	
	void function clearStatistics() output=false{
		// not yet implemented by railo
	}
	
	any function getGarbageCollections() output=false{
		return 0;
	}
	
	any function getEvictionCount() output=false{
		return 0;
	}
	
	any function getHits() output=false{
		var props = cacheGetProperties( getCacheProvider().getConfiguration().cacheName );
		if( arrayLen( props ) and structKeyExists( props[ 1 ], "hit_count" ) ){
			return props[ 1 ].hit_count;
		}
		return 0;
	}
	
	any function getMisses() output=false{
		var props = cacheGetProperties( getCacheProvider().getConfiguration().cacheName );
		if( arrayLen( props ) and structKeyExists( props[ 1 ], "miss_count" ) ){
			return props[ 1 ].miss_count;
		}
		return 0;
	}
	
	any function getLastReapDatetime() output=false{
		return "";
	}
}
			 
