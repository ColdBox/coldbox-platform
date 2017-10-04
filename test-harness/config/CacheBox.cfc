﻿component{

	/**
	* Configure CacheBox for ColdBox Application Operation
	*/
	function configure(){

		// The CacheBox configuration structure DSL
		cacheBox = {
			// LogBox config already in coldbox app, not needed
			// logBoxConfig = "coldbox.system.web.config.LogBox",

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
				coldboxEnabled = true
			},

			// Register all the custom named caches you like here
			caches = {
				// Named cache for all coldbox event and view template caching
				template = {
					provider = "coldbox.system.cache.providers.CacheBoxColdBoxProvider",
					properties = {
						objectDefaultTimeout = 120,
						objectDefaultLastAccessTimeout = 30,
						useLastAccessTimeouts = true,
						freeMemoryPercentageThreshold = 0,
						reapFrequency = 5,
						evictionPolicy = "LRU",
						evictCount = 2,
						maxObjects = 300,
						objectStore = "ConcurrentSoftReferenceStore" //memory sensitive
					}
				}
			}
		};

		// Add caches per engine
		if( listFindNoCase( "Lucee", server.coldfusion.productname ) ){
			cachebox.caches.luceeCache = {
				provider = "coldbox.system.cache.providers.LuceeProvider"
			};
		} else {
			cachebox.caches.cfCache = {
				provider = "coldbox.system.cache.providers.CFColdBoxProvider"
			};
		}
	}

}