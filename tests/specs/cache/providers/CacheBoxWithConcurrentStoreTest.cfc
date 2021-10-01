component extends="CacheBoxProviderTest" {

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
			objectStore                    : "ConcurrentStore",
			// This switches the internal provider from normal cacheBox to coldbox enabled cachebox
			coldboxEnabled                 : false,
			resetTimeoutOnAccess           : true
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

	function testResetAccess(){
		var testVal = { name : "luis", age : 32 };
		cache.getObjectStore().set( "test", testVal, 20 );
		// We duplicate, since it is by reference, we need a snapshot
		var originalMD = duplicate( cache.getCachedObjectMetadata( "test" ) );

		sleep( 1000 );
		cache.get( "test" );
		var newMD = cache.getCachedObjectMetadata( "test" );

		expect( newMD.created ).toBeGT( originalMD.created );
	}

}
