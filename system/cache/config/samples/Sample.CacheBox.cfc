/********************************************************************************
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
********************************************************************************
* The default ColdBox CacheBox configuration object that is used when the cache factory is created by itself
**/
component{
	
	/**
	* Configure CacheBox, that's it!
	*/
	function configure(){
		
		// The CacheBox configuration structure DSL
		cacheBox = {
			// LogBox Configuration file
			logBoxConfig = "coldbox.system.cache.config.LogBoxConfig", 
			
			// Scope registration, automatically register the cachebox factory instance on any CF scope
			// By default it registeres itself on server scope
			scopeRegistration = {
				enabled = true,
				scope   = "server", // server, cluster, session
				key		= "cacheBox"
			},
			
			// The defaultCache has an implicit name "default" which is a reserved cache name
			// It also has a default provider of cachebox which cannot be changed.
			// All timeouts are in minutes
			defaultCache = {
				objectDefaultTimeout = 60,
				objectDefaultLastAccessTimeout = 30,
				useLastAccessTimeouts = true,
				reapFrequency = 2,
				freeMemoryPercentageThreshold = 0,
				evictionPolicy = "LRU",
				evictCount = 1,
				maxObjects = 200,
				objectStore = "ConcurrentSoftReferenceStore"
			},
			
			// Register all the custom named caches you like here
			caches = {
				sampleCache1 = {
					provider="coldbox.system.cache.providers.CacheBoxProvider",
					properties = {
						objectDefaultTimeout="20",
						useLastAccessTimeouts="false",
						reapFrequency="1",
						evictionPolicy="LFU",
						evictCount="1",
						maxObjects="100",
						objectStore="ConcurrentSoftReferenceStore"
					}
				},
				sampleCache2 = {
					provider = "coldbox.system.cache.providers.CacheBoxProvider",
					properties = {
						maxObjects = 100,
						evictionPolicy="FIFO"
					}
				}
			},
			
			// Register all event listeners here, they are created in the specified order
			listeners = [
				// { class="", name="", properties={} }
			]
			
		};
	}	

}