<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Author 	 :	Luis Majano
Description :
	My application's CacheBox configuration structure
----------------------------------------------------------------------->
<cfcomponent output="false">
<cfscript>
	
	/**
	* Configure CacheBox for ColdBox Application Operation
	*/
	function configure(){
		
		// The CacheBox configuration structure DSL
		cacheBox = {
			// LogBox config already in coldbox app, not needed
			// logBoxConfig = "coldbox.system.web.config.LogBox", 
			
			// Scope registration, automatically register the cachebox factory instance on any CF scope
			// By default it registeres itself on server scope
			scopeRegistration = {
				enabled = true,
				scope   = "server", // server, cluster, session
				key		= "cacheBoxTestHarness"
			},
			// The defaultCache has an implicit name "default" which is a reserved cache name
			// It also has a default provider of cachebox which cannot be changed.
			// All timeouts are in minutes
			defaultCache = {
				objectDefaultTimeout = 120, //two hours default
				objectDefaultLastAccessTimeout = 30, //30 minutes idle time
				useLastAccessTimeouts = true,
				reapFrequency = 2,
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
						freeMemoryPercentageThreshold = 0,
						useLastAccessTimeouts = true,
						reapFrequency = 2,
						evictionPolicy = "LRU",
						evictCount = 2,
						maxObjects = 300,
						objectStore = "ConcurrentSoftReferenceStore" //memory sensitive
					}
				}	
			}		
		};
		
		// Add caches per engine
		if( structKeyExists(server,"railo") ){
			caches.railoCache = {
				provider = "coldbox.system.cache.providers.RailoProvider"
			};
		}
		else{
			caches.cfCache = {
				provider = "coldbox.system.cache.providers.CFColdboxProvider"
			};
		}
	}	
</cfscript>
</cfcomponent>