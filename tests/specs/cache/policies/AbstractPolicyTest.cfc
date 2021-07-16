component extends="coldbox.system.testing.BaseModelTest" {

	function setup(){
		mockCM      = createMock( "coldbox.system.cache.providers.MockProvider" );
		mockFactory = createMock( "coldbox.system.cache.CacheFactory" );
		mockLogBox  = createMock( "coldbox.system.logging.LogBox" );
		mockLogger  = createMock( "coldbox.system.logging.Logger" );
		mockPool    = createMock( "coldbox.system.cache.store.ConcurrentStore" );
		mockStats   = createMock( "coldbox.system.cache.util.CacheStats" );
		mockIndexer = createMock( "coldbox.system.cache.store.indexers.MetadataIndexer" );

		// Mocks
		mockCM
			.$( "getCacheFactory", mockFactory )
			.$( "getStats", mockStats )
			.$( "getName", "MockCache" )
			.$( "getObjectStore", mockPool )
			.$( "clear", true );
		mockPool.$( "getIndexer", mockIndexer );
		mockFactory.setLogBox( mockLogBox );
		mockLogBox.$( "getLogger", mockLogger );
		mockLogger
			.$( "error" )
			.$( "debug" )
			.$( "info" )
			.$( "canDebug", true )
			.$( "canInfo", true );

		mockStats.$(
			method             = "evictionHit",
			returns            = mockStats,
			preserveReturnType = false
		);
	}

}
