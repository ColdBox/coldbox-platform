component name="cacheTest" extends="CacheBoxProviderTest" {

	function setup(){
		super.setup();

		// Config
		config = {
			objectDefaultTimeout           : 60,
			objectDefaultLastAccessTimeout : 30,
			useLastAccessTimeouts          : true,
			reapFrequency                  : 2,
			freeMemoryPercentageThreshold  : 0,
			evictionPolicy                 : "LRU",
			evictCount                     : 1,
			maxObjects                     : 200,
			objectStore                    : "DiskStore",
			directoryPath                  : "/coldbox/tests/tmp/cacheDepot",
			// This switches the internal provider from normal cacheBox to coldbox enabled cachebox
			coldboxEnabled                 : false
		};

		// Create Provider
		cache = createMock( "coldbox.system.cache.providers.CacheBoxProvider" ).init();

		// Decorate it
		cache.setConfiguration( config );
		cache.setCacheFactory( mockFactory );
		cache.setEventManager( mockEventManager );

		// Configure the provider
		cache.configure();
	}

}
