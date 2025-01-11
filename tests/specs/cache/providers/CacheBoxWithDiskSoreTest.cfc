component extends="CacheBoxProviderTest" {

	// Config
	variables.config = {
		objectDefaultTimeout           : 60,
		objectDefaultLastAccessTimeout : 30,
		useLastAccessTimeouts          : true,
		reapFrequency                  : 2,
		freeMemoryPercentageThreshold  : 0,
		evictionPolicy                 : "LRU",
		evictCount                     : 1,
		maxObjects                     : 200,
		objectStore                    : "DiskStore",
		directoryPath                  : "/coldbox/tests/tmp/cacheDepot",
		// This switches the internal provider from normal cacheBox to coldbox enabled cachebox
		coldboxEnabled                 : false
	};

}
