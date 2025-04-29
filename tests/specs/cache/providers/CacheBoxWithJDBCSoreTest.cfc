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
		objectStore                    : "JDBCStore",
		dsn                            : "coolblog",
		table                          : "cacheBox",
		// This switches the internal provider from normal cacheBox to coldbox enabled cachebox
		coldboxEnabled                 : false
	};

}
