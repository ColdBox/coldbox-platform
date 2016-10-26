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
				evictCount = 1,
				maxObjects = 200,
				objectStore = "coldbox.system.cache.store.ConcurrentSoftReferenceStore"
			},
			
			// Register all event listeners here, they are created in the specified order
			listeners = [
				{ class="coldbox.tests.specs.cache.listeners.MyListener", name="MyListener", 
				  properties={
				  	name="CoolListener"
				  } },
				{ class="coldbox.tests.specs.cache.listeners.MyListener", name="FunkyListener", 
				  properties={
				  	name="FunkyListener"
				  } }				  
			]
			
		};
	}	
</cfscript>
</cfcomponent>