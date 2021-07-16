component extends="tests.resources.BaseIntegrationTest" skip="isAdobe" {

	this.loadColdBox = false;

	boolean function isAdobe(){
		return server.keyExists( "lucee" );
	}

	function setup(){
		super.setup();

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
			.$( "canDebug", false );
		mockEventManager.$( "announce" );

		// Config
		config = { cacheName : "object" };

		// Create Provider
		cache = createMock( "coldbox.system.cache.providers.CFProvider" ).init();

		// Decorate it
		cache.setConfiguration( config );
		cache.setCacheFactory( mockFactory );
		cache.setEventManager( mockEventManager );

		// writeDump( var=cacheGetSession( "object" ) );abort;
		// writeDump( var=cache.getObjectStore() );abort;
		// writeDump( var=cache.getObjectStore().getStatistics() );abort;

		// Configure the provider
		cache.configure();
	}

	function teardown(){
		cache.clearAll();
	}

	function testShutdown(){
		cache.shutdown();
	}

	function testLookup(){
		cache.set( "test", now(), 20 );
		cache.clearStatistics();

		assertEquals( false, cache.lookup( "invalid" ) );
		assertEquals( true, cache.lookup( "test" ) );
	}

	function testLookupQuiet(){
		cache.set( "test", now(), 20 );
		cache.clearStatistics();

		assertEquals( false, cache.lookupQuiet( "invalid" ) );
		assertEquals( true, cache.lookupQuiet( "test" ) );
	}

	function testgetKeys(){
		s = cacheGetSession( "object" ).removeAll();
		cache.set( "test", now() );
		cache.set( "test2", now() );
		assertEquals( 2, arrayLen( cache.getKeys() ) );
	}

	function testgetCachedObjectMetadata(){
		cache.set( "test", now() );
		md = cache.getCachedObjectMetadata( "test" );
		// debug(md);
		assertEquals( false, structIsEmpty( md ) );
	}

	function testGet(){
		testVal = { name : "luis", age : 32 };

		cache.set( "test", testVal, 20 );
		cache.clearStatistics();

		results = cache.get( "test" );
		assertEquals( results, testval );

		results = cache.get( "test2" );
		assertFalse( isDefined( "results" ) );
	}

	function testGetOrSet(){
		cache.clearStatistics();

		results = cache.getOrSet( objectKey = "test", produce = cacheProducer );
		assertTrue( structKeyExists( results, "name" ) );

		results = cache.getOrSet( objectKey = "test", produce = cacheProducer );
		assertTrue( structKeyExists( results, "name" ) );
	}

	private function cacheProducer(){
		return { date : now(), name : "luis majano", id : createUUID() };
	}

	function testGetQuiet(){
		testVal = { name : "luis", age : 32 };

		cache.clearStatistics();
		cache.set( "test", testVal, 20 );

		results = cache.getQuiet( "test" );
		// debug(results);
		assertEquals( testVal, results );
	}

	function testSet(){
		testVal = { name : "luis", age : 32 };
		cache.clearAll();

		cache.set(
			"test",
			testVal,
			createTimespan( 0, 0, 2, 0 ),
			createTimespan( 0, 0, 1, 0 )
		);
		assertEquals( testVal, cache.get( "test" ) );
		md = cache.getCachedObjectMetadata( "test" );
		assertEquals( 60, md.idleTime );
		assertEquals( 120, md.timespan );
		// debug(md);
	}

	function testSetQuiet(){
		testVal = { name : "luis", age : 32 };
		cache.clearAll();

		cache.setQuiet(
			"test",
			testVal,
			createTimespan( 0, 0, 2, 0 ),
			createTimespan( 0, 0, 1, 0 )
		);
		assertEquals( testVal, cache.get( "test" ) );
		md = cache.getCachedObjectMetadata( "test" );
		assertEquals( 60, md.idleTime );
		assertEquals( 120, md.timespan );
		// debug(md);
	}

	function testGetSize(){
		testVal = { name : "luis", age : 32 };
		cache.clearAll();

		cache.setQuiet(
			"test",
			testVal,
			createTimespan( 0, 0, 2, 0 ),
			createTimespan( 0, 0, 1, 0 )
		);

		assertEquals( 1, cache.getSize() );
	}

	function testClear(){
		testVal = { name : "luis", age : 32 };
		cache.clearAll();

		cache.set(
			"test",
			testVal,
			createTimespan( 0, 0, 2, 0 ),
			createTimespan( 0, 0, 1, 0 )
		);

		assertEquals( 1, cache.getSize() );
		cache.clear( "test" );
		assertEquals( 0, cache.getSize() );
	}

	function testClearQuiet(){
		testVal = { name : "luis", age : 32 };
		cache.clearAll();

		cache.set(
			"test",
			testVal,
			createTimespan( 0, 0, 2, 0 ),
			createTimespan( 0, 0, 1, 0 )
		);

		assertEquals( 1, cache.getSize() );
		cache.clearQuiet( "test" );
		assertEquals( 0, cache.getSize() );
	}

}
