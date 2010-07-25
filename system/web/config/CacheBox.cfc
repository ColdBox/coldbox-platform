<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Author 	 :	Luis Majano
Description :
	The default ColdBox CacheBox configuration object for ColdBox Applications
----------------------------------------------------------------------->
<cfcomponent output="false" hint="The default ColdBox CacheBox configuration object for ColdBox Applications">
<cfscript>
	
	/**
	* Configure CacheBox for ColdBox Application Operation
	*/
	function configure(){
		
		// The CacheBox configuration structure DSL
		cacheBox = {
			// LogBox Configuration file - uses the coldbox application default
			logBoxConfig = "coldbox.system.web.config.LogBox", 
			
			// The defaultCache has an implicit name "default" which is a reserved cache name
			// It also has a default provider of cachebox which cannot be changed.
			// All timeouts are in minutes
			defaultCache = {
				objectDefaultTimeout = 120,
				objectDefaultLastAccessTimeout = 30,
				useLastAccessTimeouts = true,
				reapFrequency = 2,
				freeMemoryPercentageThreshold = 0,
				evictionPolicy = "LRU",
				evictCount = 1,
				maxObjects = 200,
				objectStore = "coldbox.system.cache.store.ConcurrentSoftReferenceStore",
				coldboxEnabled = true
			},
			
			// Register all the custom named caches you like here
			caches = {
				// Named cache for all coldbox event and view caching
				cboxEventsViews = {
					provider = "coldbox.system.cache.providers.ColdBoxAppProvider",
					properties = {
						objectDefaultTimeout = 120,
						objectDefaultLastAccessTimeout = 30,
						useLastAccessTimeouts = true,
						reapFrequency = 2,
						evictionPolicy = "LRU",
						evictCount = 1,
						maxObjects = 200,
						objectStore = "coldbox.system.cache.store.ConcurrentSoftReferenceStore"
					}
				}		
			},
			
			// Register all event listeners here, they are created in the specified order
			listeners = [
				// { class="", name="", properties={} }
			]
			
		};
	}	
</cfscript>
</cfcomponent>