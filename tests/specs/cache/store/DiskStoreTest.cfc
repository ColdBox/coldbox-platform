component extends="coldbox.system.testing.BaseModelTest" {

	function setup(){
		config = {
			autoExpandPath       : true,
			resetTimeoutOnAccess : false
			// directoryPath  = "/coldbox/tests/tmp/cacheDepot"
		};
		mockProvider = createMock( "coldbox.system.cache.providers.MockProvider" ).init().configure();
		mockProvider.$( "getConfiguration", config );

		try {
			store = createMock( className = "coldbox.system.cache.store.DiskStore" ).init( mockProvider );
			fail( "this should have failed" );
		} catch ( "DiskStore.InvalidConfigurationException" e ) {
		} catch ( any e ) {
			fail( e );
		}

		// good directory
		config.directoryPath = "/coldbox/tests/tmp/cacheDepot";
		store                = createMock( className = "coldbox.system.cache.store.DiskStore" ).init( mockProvider );
	}

	function tearDown(){
		if ( !isNull( store ) ) {
			store.clearAll();
		}
	}

	function testClearAll(){
		store.set( "test", now(), 20 );
		assertEquals( 1, store.getSize() );
		store.clearAll();
		assertEquals( 0, store.getSize() );
	}

	function testGetKeys(){
		assertEquals( arrayNew( 1 ), store.getKeys() );
		store.set( "test", now() );
		store.set( "test1", now() );
		store.set( "test2", now() );
		assertEquals( 3, arrayLen( store.getKeys() ) );
	}

	function testLookup(){
		assertFalse( store.lookup( "nada" ) );

		store.set( "myKey", "hello" );
		assertTrue( store.lookup( "myKey" ) );

		store.expireObject( "myKey" );
		assertFalse( store.lookup( "myKey" ) );
	}

	function testGet(){
		store.set( "myKey", "123" );
		assertEquals( store.get( "myKey" ), "123" );
	}

	function testGetQuiet(){
		store.set( "myKey", "123", 0 );
		assertEquals( store.getQuiet( "myKey" ), "123" );
	}

	function testExpirations(){
		store.set( "test", now() );
		assertFalse( store.isExpired( "test" ) );
		store.expireObject( "test" );
		assertTrue( store.isExpired( "test" ) );
	}

	function testSet(){
		// 1:Timeout = 0 (Eternal)
		store.set( "test", "123", 0, 0 );
		assertEquals( store.getQuiet( "test" ), "123" );
		assertEquals( 0, store.getCachedObjectMetadata( "test" ).timeout );

		// 2:Timeout = X
		store.set( "test", "123", 20, 20 );
		assertEquals( store.getQuiet( "test" ), "123" );
		assertEquals( 20, store.getCachedObjectMetadata( "test" ).timeout );
	}

	function testClear(){
		assertFalse( store.clear( "invalid" ) );
		store.set( "test", now(), 20 );
		results = store.clear( "test" );
		assertTrue( results );
	}

	function testGetSize(){
		assertTrue( store.getSize() eq 0 );
		store.set( "test", now(), 0 );
		assertTrue( store.getSize() eq 1 );
	}

}
