component extends="coldbox.system.testing.BaseModelTest"{

	function setup(){
		mockCM 		 = createEmptyMock( 'coldbox.system.cache.providers.MockProvider' );
		mockFactory  = createEmptyMock( 'coldbox.system.cache.CacheFactory' );
		mockLogBox	 = createEmptyMock( "coldbox.system.logging.LogBox" );
		mockLogger	 = createEmptyMock( "coldbox.system.logging.Logger" );
		mockPool 	 = createEmptyMock( 'coldbox.system.cache.store.ConcurrentStore' );
		mockStats 	 = createEmptyMock( 'coldbox.system.cache.util.CacheStats' );
		mockIndexer  = createEmptyMock( 'coldbox.system.cache.store.indexers.MetadataIndexer' );

		// Mocks
		mockCM.$( "getCacheFactory", mockFactory )
			.$('getStats', mockStats )
			.$( "getName", "MockCache" )
			.$( "getObjectStore", mockPool )
			.$( "clear" );
		mockPool.$( "getIndexer", mockIndexer );
 		mockFactory.$( "getLogBox", mockLogBox );
		mockLogBox.$( "getLogger", mockLogger );
		mockLogger.$( "error" ).$( "debug" ).$( "info" ).$( "canDebug", true ).$( "canInfo", true );
		mockStats.$( method='evictionHit', returns=mockStats, preserveReturnType=false );
	}

}