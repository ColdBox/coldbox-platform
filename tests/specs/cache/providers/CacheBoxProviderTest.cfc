component extends="tests.resources.BaseIntegrationTest" {

	this.loadColdBox = false;

	function setup(){
		super.setup();

		// Mocks
		mockFactory      = createMock( "coldbox.system.cache.CacheFactory" );
		mockEventManager = createMock( "coldbox.system.core.events.EventPoolManager" );
		mockLogBox       = createMock( "coldbox.system.logging.LogBox" );
		mockLogger       = createMock( "coldbox.system.logging.Logger" );
		mockAsyncManager = createMock( "coldbox.system.async.AsyncManager" ).init();
		mockExecutor     = prepareMock( mockAsyncManager.newScheduledExecutor( name: "cachebox-tasks", threads: 1 ) );

		// Mock Methods
		mockFactory
			.setLogBox( mockLogBox )
			.setAsyncManager( mockAsyncManager )
			.setTaskScheduler( mockExecutor );

		mockLogBox.$( "getLogger", mockLogger );
		mockLogger
			.$( "error", mockLogger )
			.$( "debug", mockLogger )
			.$( "info", mockLogger )
			.$( "canDebug", true )
			.$( "canInfo", true )
			.$( "canError", true );
		mockEventManager.$( "announce" );

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
			objectStore                    : "ConcurrentSoftReferenceStore",
			// This switches the internal provider from normal cacheBox to coldbox enabled cachebox
			coldboxEnabled                 : false
		};

		// Create Provider
		cache = createMock( "coldbox.system.cache.providers.CacheBoxProvider" ).init();
		// Decorate it
		cache.setConfiguration( config );
		cache.setCacheFactory( mockFactory );
		cache.setEventManager( mockEventManager );

		// Mock The Scheduler, we don't need any reaping async
		var mockSchedule = prepareMock(
			mockExecutor.newSchedule( function(){
				debug( "In Mock Executor" );
			} )
		);
		mockExecutor.$( "newSchedule", mockSchedule );

		// Configure the provider
		cache.configure();

		// Clear everything first
		cache.clearAll();
	}

	function teardown(){
		cache.clearAll();
	}

	function testShutdown(){
		cache.shutdown();
	}

	function testLookupMulti(){
		cache.clearAll();
		cache.getObjectStore().set( "test", now(), 20 );
		cache.getObjectStore().set( "test2", now(), 20 );
		cache.clearStatistics();

		// list
		results = cache.lookupMulti( keys = "test,test2,test3" );

		// debug( results );

		assertEquals( true, results.test );
		assertEquals( true, results.test2 );
		assertEquals( false, results.test3 );
	}

	function testLookup(){
		cache.getObjectStore().set( "test", now(), 20 );
		cache.clearStatistics();

		assertEquals( false, cache.lookup( "invalid" ) );
		assertEquals( true, cache.lookup( "test" ) );

		assertEquals( 1, cache.getStats().getMisses() );
		assertEquals( 1, cache.getStats().getHits() );
	}

	function testLookupQuiet(){
		cache.getObjectStore().set( "test", now(), 20 );
		cache.clearStatistics();

		assertEquals( false, cache.lookupQuiet( "invalid" ) );
		assertEquals( true, cache.lookupQuiet( "test" ) );

		assertEquals( 0, cache.getStats().getMisses() );
		assertEquals( 0, cache.getStats().getHits() );
	}

	function testGet(){
		var testVal = { name : "luis", age : 32 };
		cache.getObjectStore().set( "test", testVal, 20 );
		cache.clearStatistics();

		var results = cache.get( "test" );

		assertEquals( results, testval );
		assertEquals(
			0,
			cache.getStats().getMisses(),
			"Actual: #cache.getStats().getMisses()#"
		);
		assertEquals(
			1,
			cache.getStats().getHits(),
			"Actual: #cache.getStats().getHits()#"
		);
	}

	function testGetOrSet(){
		cache.clearStatistics();

		var cacheKey = "test-#createUUID()#";
		var results  = cache.getOrSet( objectKey = cacheKey, produce = cacheProducer );
		assertTrue( structKeyExists( results, "name" ) );
		assertEquals( 2, cache.getStats().getMisses() );
		assertEquals( 0, cache.getStats().getHits() );

		var results = cache.getOrSet( objectKey = cacheKey, produce = cacheProducer );
		assertTrue( structKeyExists( results, "name" ) );
		assertEquals( 2, cache.getStats().getMisses() );
		assertEquals( 1, cache.getStats().getHits() );
	}

	// this is not a closure, so as to work on cf8.
	private function cacheProducer(){
		return { date : now(), name : "luis majano", id : createUUID() };
	}

	function testGetQuiet(){
		testVal = { name : "luis", age : 32 };
		cache.getObjectStore().set( "test", testVal, 20 );
		cache.clearStatistics();

		results = cache.getQuiet( "test" );
		assertEquals( results, testval );
		assertEquals( 0, cache.getStats().getMisses() );
		assertEquals( 0, cache.getStats().getHits() );
	}

	function testGetMulti(){
		var testVal = { name : "luis", age : 32 };
		cache.clearAll();
		cache.clearStatistics();
		cache.getObjectStore().set( "test", testVal, 20 );

		var results = cache.getMulti( "test,test2" );
		// debug(results);

		expect(	isNull( results.test ) ).toBeFalse();
		expect(	isNull( results.test2 ) ).toBeTrue();
	}

	function testgetCachedObjectMetadata(){
		testVal = { name : "luis", age : 32 };
		cache.getObjectStore().set( "test", testVal, 20 );
		cache.clearStatistics();

		results = cache.getCachedObjectMetadata( "test" );
		// debug(results);

		assertEquals( 1, results.hits );
	}

	function testset(){
		testVal = { name : "luis", age : 32 };
		cache.clearAll();

		cache.set( "test", testVal, 20 );
		md = cache.getCachedObjectMetadata( "test" );
		assertEquals( testVal, cache.get( "test" ) );
		assertEquals( 20, md.timeout );
		assertEquals( config.objectDefaultLastAccessTimeout, md.lastAccesstimeout );

		cache.set( "test", testVal, 20, 20 );
		md = cache.getCachedObjectMetadata( "test" );
		assertEquals( testVal, cache.get( "test" ) );
		assertEquals( 20, md.timeout );
		assertEquals( 20, md.lastAccesstimeout );

		cache.set( "test", testVal );
		md = cache.getCachedObjectMetadata( "test" );
		assertEquals( testVal, cache.get( "test" ) );
		assertEquals( config.objectDefaultTimeout, md.timeout );
		assertEquals( config.objectDefaultLastAccessTimeout, md.lastAccesstimeout );
	}

	function testsetQuiet(){
		testVal = { name : "luis", age : 32 };
		cache.setQuiet( "test", testVal, 20 );

		assertEquals( testVal, cache.get( "test" ) );
	}

	function testSetMulti(){
		test = { key1 : { name : "luis", age : 2 }, key2 : "hello" };
		cache.setMulti( test );

		assertEquals( test.key1, cache.get( "key1" ) );
		assertEquals( test.key2, cache.get( "key2" ) );
	}

	function testClearMulti(){
		test = { key1 : { name : "luis", age : 2 }, key2 : "hello" };
		cache.setMulti( test );

		cache.clearMulti( "key1,key2" );

		assertFalse( cache.lookup( "key1" ) );
		assertFalse( cache.lookup( "key2" ) );
	}

	function testClearQuiet(){
		test = {
			key1 : now(),
			key2 : { name : "Pio", age : "32", cool : "beyond belief" }
		};
		cache.setQuiet( "key1", test.key1 );

		cache.clearQuiet( "key1" );

		assertFalse( cache.lookup( "key1" ) );
	}

	function testClear(){
		test = {
			key1 : now(),
			key2 : { name : "Pio", age : "32", cool : "beyond belief" }
		};
		cache.setQuiet( "key1", test.key1 );

		cache.clear( "key1" );

		assertFalse( cache.lookup( "key1" ) );
	}

	function testClearAll(){
		test = {
			key1 : now(),
			key2 : { name : "Pio", age : "32", cool : "beyond belief" }
		};
		cache.setMulti( test );

		cache.clearAll();

		assertFalse( cache.lookup( "key1" ) );
		assertFalse( cache.lookup( "key2" ) );
	}

	function testGetSize(){
		test = {
			key1 : now(),
			key2 : { age : "32", name : "Lui Mahoney" }
		};
		cache.clearAll();
		cache.setMulti( test );

		assertEquals( 2, cache.getSize() );
	}

	function testExpireObjectAndIsExpired(){
		test = {
			key1 : now(),
			key2 : { name : "Pio", age : "32", cool : "beyond belief" }
		};
		cache.set( "test", test );
		cache.expireObject( "test" );

		assertTrue( cache.isExpired( "test" ) );

		cache.set( "test3", test );
		assertFalse( cache.isExpired( "test3" ) );
	}

	function testExpireByKeySnippet(){
		test = {
			key1 : now(),
			key2 : { name : "Pio", age : "32", cool : "beyond belief" }
		};
		cache.set( "test1", test.key1 );
		cache.set( "test2", test.key2 );

		cache.expireByKeySnippet( "tes", true );

		assertTrue( cache.isExpired( "test1" ) );
		assertTrue( cache.isExpired( "test2" ) );
	}

	function testExpireAll(){
		test = {
			key1 : now(),
			key2 : { name : "Pio", age : "32", cool : "beyond belief" }
		};
		cache.set( "test1", test.key1 );
		cache.set( "test2", test.key2 );

		cache.expireAll();

		assertTrue( cache.isExpired( "test1" ) );
		assertTrue( cache.isExpired( "test2" ) );
	}

	function testGetKeys(){
		test = {
			key1 : now(),
			key2 : { name : "Luis Mahoney", cool : "You betcha!" }
		};
		cache.set( "test1", test.key1 );
		cache.set( "test2", test.key2 );

		keys = cache.getKeys();

		assertTrue( keys.contains( "test1" ) );
		assertTrue( keys.contains( "test2" ) );
	}

	function testReap(){
		test = { key1 : now(), key2 : { name : "luis", age : 2 } };
		cache.clearAll();
		cache.set( "test1", test.key1 );
		cache.set( "test2", test.key2 );

		cache.expireAll();

		cache.reap();

		assertEquals( 0, cache.getSize() );
	}

}
