component extends="coldbox.system.testing.BaseModelTest" {

	function setup(){
		mockProvider = createMock( "coldbox.system.cache.providers.MockProvider" ).init().configure();
		store        = createMock( "coldbox.system.cache.store.ConcurrentStore" ).init( mockProvider );
	}

	function testClearAll(){
		store.set( "test", now(), 20 );
		assertEquals( 1, store.getSize() );
		store.clearAll();
		assertEquals( 0, store.getSize() );
	}

	function testGetPool(){
		assertTrue( isStruct( store.getpool() ) );
	}

	function testGetKeys(){
		assertEquals( [], store.getKeys() );
		store.set( "test", now() );
		store.set( "test1", now() );
		store.set( "test2", now() );
		assertEquals( 3, arrayLen( store.getKeys() ) );
	}

	function testLookup(){
		assertFalse( store.lookup( "nada" ) );

		store.set( "myKey", "hello" );
		assertTrue( store.lookup( "myKey" ) );

		// Expire it
		store.getPool().get( "myKey" ).isExpired = true;
		assertFalse( store.lookup( "myKey" ) );
	}

	function testGet(){
		store.set( "myKey", "123" );
		assertEquals( store.get( "myKey" ), "123" );
	}

	function testGetQuiet(){
		store.set( "myKey", "123" );
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

	function testSetEternals(){
		var obj = { name : "luis", date : now() };
		var key = "myObj";

		store.set( key, obj, 0 );
		assertSame( store.get( key ), obj );

		assertTrue( store.lookup( key ) );
		assertFalse( store.lookup( "nothing" ) );

		metadata = store.getCachedObjectMetadata( key );

		assertEquals( 0, metadata.timeout );
		assertEquals( 2, metadata.hits );
		assertEquals( false, metadata.isExpired );
		assertEquals( "", metadata.LastAccessTimeout );
		assertTrue( isDate( metadata.Created ) );
		assertTrue( isDate( metadata.lastAccessed ) );

		store.clear( key );
		assertFalse( store.lookup( key ) );
	}

	function testClear(){
		map  = { test : "test" };
		map2 = duplicate( map );
		// debug(map2);

		store.$property( "pool", "variables", map );

		map = { test : "123" };
		store.$property( "pool", "variables", map );

		results = store.clear( "test" );

		// debug( store.$callLog() );
		assertEquals( results, true );
		assertTrue( structIsEmpty( map ) );
	}

	function testGetSize(){
		assertTrue( store.getSize() eq 0 );
		store.set( "test", now(), 0 );
		assertTrue( store.getSize() eq 1 );
	}

}
