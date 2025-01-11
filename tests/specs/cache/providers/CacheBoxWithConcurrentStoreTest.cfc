component extends="CacheBoxProviderTest" {

	// Config
	variables.config = {
		objectDefaultTimeout           : 60,
		objectDefaultLastAccessTimeout : 30,
		useLastAccessTimeouts          : true,
		reapFrequency                  : 10,
		freeMemoryPercentageThreshold  : 0,
		evictionPolicy                 : "LRU",
		evictCount                     : 1,
		maxObjects                     : 200,
		objectStore                    : "ConcurrentStore",
		// This switches the internal provider from normal cacheBox to coldbox enabled cachebox
		coldboxEnabled                 : false,
		resetTimeoutOnAccess           : true
	};

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
