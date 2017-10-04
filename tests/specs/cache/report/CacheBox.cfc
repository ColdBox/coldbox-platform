﻿<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Author 	 :	Luis Majano
Description :
	The default ColdBox CacheBox configuration object that is used when the
	cache factory is created
----------------------------------------------------------------------->
<cfcomponent output="false" hint="The default ColdBox CacheBox configuration">
<cfscript>
	
	/**
	* Configure CacheBox, that's it!
	*/
	function configure(){
		
		// The CacheBox configuration structure DSL
		cacheBox = {
			// LogBox Configuration file
			logBoxConfig = "coldbox.system.cache.config.LogBox", 
			
			// Scope Registration
			scopeRegistration = {
				enabled = false
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
				//evictCount = 1,
				//maxObjects = 200,
				objectStore = "coldbox.system.cache.store.ConcurrentSoftReferenceStore"
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
						objectStore="coldbox.system.cache.store.ConcurrentSoftReferenceStore"
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
				//{ class="path.to.listener", name="Syncrhonizer", properties={} }
			]
		};
		
		// cool thing about programmatic configuration
		if( listFindNoCase( "Lucee", server.coldfusion.productname ) ){
			cachebox.caches.luceeCache = {
				provider = "coldbox.system.cache.providers.LuceeProvider"
			};
		}
		
	}	
</cfscript>
</cfcomponent>