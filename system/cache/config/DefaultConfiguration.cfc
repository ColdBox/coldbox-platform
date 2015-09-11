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
			logBoxConfig = "coldbox.system.cache.config.LogBox",

			// Scope registration, automatically register the cachebox factory instance on any CF scope
			// By default it registeres itself on server scope
			scopeRegistration = {
				enabled = true,
				scope   = "application", // the cf scope you want
				key		= "cacheBox"
			},

			// The defaultCache has an implicit name of "default" which is a reserved cache name
			// It also has a default provider of cachebox which cannot be changed.
			// All timeouts are in minutes
			// Please note that each object store could have more configuration properties
			defaultCache = {
				objectDefaultTimeout = 120,
				objectDefaultLastAccessTimeout = 30,
				useLastAccessTimeouts = true,
				reapFrequency = 2,
				freeMemoryPercentageThreshold = 0,
				evictionPolicy = "LRU",
				evictCount = 1,
				maxObjects = 300,
				objectStore = "ConcurrentSoftReferenceStore",
				// This switches the internal provider from normal cacheBox to coldbox enabled cachebox
				coldboxEnabled = false
			},

			// Register all the custom named caches you like here
			caches = {
			},

			// Register all event listeners here, they are created in the specified order
			listeners = [
				// { class="", name="", properties={} }
			]

		};
	}

}