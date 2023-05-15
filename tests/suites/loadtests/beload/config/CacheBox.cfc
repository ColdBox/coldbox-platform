component {

	/**
	 * Configure CacheBox for ColdBox Application Operation
	 */
	function configure() {
		/**
		 * --------------------------------------------------------------------------
		 * CacheBox Configuration (https://cachebox.ortusbooks.com)
		 * --------------------------------------------------------------------------
		 */
		cacheBox = {
			/**
			 * --------------------------------------------------------------------------
			 * Default Cache Configuration
			 * --------------------------------------------------------------------------
			 * The defaultCache has an implicit name "default" which is a reserved cache name
			 * It also has a default provider of cachebox which cannot be changed.
			 * All timeouts are in minutes
			 */
			defaultCache : {
				objectDefaultTimeout           : 120, // two hours default
				objectDefaultLastAccessTimeout : 30, // 30 minutes idle time
				useLastAccessTimeouts          : true,
				reapFrequency                  : 5,
				freeMemoryPercentageThreshold  : 0,
				evictionPolicy                 : "LRU",
				evictCount                     : 1,
				maxObjects                     : 300,
				objectStore                    : "ConcurrentStore", // guaranteed objects
				coldboxEnabled                 : true
			},
			/**
			 * --------------------------------------------------------------------------
			 * Custom Cache Regions
			 * --------------------------------------------------------------------------
			 * You can use this section to register different cache regions and map them
			 * to different cache providers
			 */
			caches : {
				/**
				 * --------------------------------------------------------------------------
				 * ColdBox Template Cache
				 * --------------------------------------------------------------------------
				 * The ColdBox Template cache region is used for event/view caching and
				 * other internal facilities that might require a more elastic cache.
				 */
				template : {
					provider   : "coldbox.system.cache.providers.CacheBoxColdBoxProvider",
					properties : {
						objectDefaultTimeout           : 120,
						objectDefaultLastAccessTimeout : 30,
						useLastAccessTimeouts          : true,
						freeMemoryPercentageThreshold  : 0,
						reapFrequency                  : 5,
						evictionPolicy                 : "LRU",
						evictCount                     : 2,
						maxObjects                     : 300,
						objectStore                    : "ConcurrentSoftReferenceStore" // memory sensitive
					}
				}
			}
		};
	}

}
