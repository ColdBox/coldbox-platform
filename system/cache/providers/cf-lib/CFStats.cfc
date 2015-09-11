/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************
Author: Luis Majano
Description:
	
A coldfusion statistics object that communicates with the CF ehCache stats

*/
component implements="coldbox.system.cache.util.ICacheStats" accessors="true"{
	
	property name="cacheStats" serializable="false";

	CFStats function init( stats ) output=false{
		setCacheStats( arguments.stats );
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
		return getCacheStats().getObjectCount();
	}
	
	void function clearStatistics() output=false{
		getCacheStats().clearStatistics();
	}
	
	any function getGarbageCollections() output=false{
		return 0;
	}
	
	any function getEvictionCount() output=false{
		return getCacheStats().getEvictionCount();
	}
	
	any function getHits() output=false{
		return getCacheStats().getCacheHits();
	}
	
	any function getMisses() output=false{
		return getCacheStats().getCacheMisses();
	}
	
	any function getLastReapDatetime() output=false{
		return "";
	}
	
	/*******************************************************
	ehCache specific functions
	********************************************************/
	any function getAverageGetTime(){
		return getCacheStats().getAverageGetTime();
	}
	
}
			 
