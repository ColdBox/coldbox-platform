component extends="coldbox.system.testing.BaseModelTest" skip="isLucee" {

	boolean function isLucee(){
		return listFindNoCase( "Lucee", server.coldfusion.productname ) ? false : true;
	}

	function setup(){
		// Mocks
		mockFactory      = createMock( "coldbox.system.cache.CacheFactory" );
		mockEventManager = createMock( "coldbox.system.core.events.EventPoolManager" );
		mockLogBox       = createMock( "coldbox.system.logging.LogBox" );
		mockLogger       = createMock( "coldbox.system.logging.Logger" );

		// Mock Methods
		mockFactory.setLogBox( mockLogBox );
		mockLogBox.$( "getLogger", mockLogger );
		mockLogger
			.$( "error" )
			.$( "debug" )
			.$( "info" )
			.$( "canDebug", "false" );
		mockEventManager.$( "announce" );

		// Config
		config = { cacheName : "default" };

		// Create Provider
		cache = createMock( "coldbox.system.cache.providers.LuceeProvider" ).init();

		// Decorate it
		cache.setConfiguration( config );
		cache.setCacheFactory( mockFactory );
		cache.setEventManager( mockEventManager );

		// Configure the provider
		cache.configure();
	}

	function teardown(){
		cache.clearAll();
	}

	function testTimeouts(){
		testVal = { name : "luis", age : 32 };
		cache.clearAll();

		cache.set(
			"test",
			testVal,
			10,
			createTimespan( 0, 0, 1, 0 )
		);
		assertEquals( testVal, cache.get( "test" ) );
		md = cache.getCachedObjectMetadata( "test" );
		// debug( md );
		assertEquals( 600 * 1000, md.timespan );
		assertEquals( 60 * 1000, md.idleTime );
		cache.clearAll();

		cache.set( "test", testVal );
		assertEquals( testVal, cache.get( "test" ) );
		cache.clearAll();

		cache.set( "test", testVal, "" );
		assertEquals( testVal, cache.get( "test" ) );
		cache.clearAll();
	}

}
