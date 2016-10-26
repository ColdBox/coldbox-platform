/**
* Standalone Config
*/
component{

	function configure(){
		// The CacheBox configuration structure DSL
		cacheBox = {
			// LogBox config already in coldbox app, not needed
			logBoxConfig = "tests.resources.StandaloneLogBoxConfig", 
			
			// The defaultCache has an implicit name "default" which is a reserved cache name
			// It also has a default provider of cachebox which cannot be changed.
			// All timeouts are in minutes
			defaultCache = {
				objectDefaultTimeout = 120, //two hours default
				objectDefaultLastAccessTimeout = 30, //30 minutes idle time
				useLastAccessTimeouts = true,
				reapFrequency = 5,
				freeMemoryPercentageThreshold = 0,
				evictionPolicy = "LRU",
				evictCount = 1,
				maxObjects = 300,
				objectStore = "ConcurrentStore", //guaranteed objects
				coldboxEnabled = false
			},
			
			// Register all the custom named caches you like here
			caches = {
				// Named cache for all coldbox event and view template caching
				standalone = {
					provider = "coldbox.system.cache.providers.CacheBoxProvider",
					properties = {
						objectDefaultTimeout = 5,
						reapFrequency = 5,
						evictionPolicy = "LRU",
						maxObjects = 5,
						objectStore = "ConcurrentStore"
					}
				}		
			}		
		};
	}

}