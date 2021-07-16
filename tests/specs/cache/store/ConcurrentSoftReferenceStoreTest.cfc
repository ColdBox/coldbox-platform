component extends="coldbox.system.testing.BaseModelTest" {

	function setup(){
		mockProvider = createMock( "coldbox.system.cache.providers.MockProvider" ).init().configure();
		store        = createMock( "coldbox.system.cache.store.ConcurrentSoftReferenceStore" ).init( mockProvider );
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
		// don't exist
		assertFalse( store.lookup( "nada" ) );

		// non sr
		store.set( "test", now(), 0 );
		assertEquals( true, store.lookup( "test" ) );

		// store SR
		store.set( "test", now(), 10 );
		assertEquals( true, store.lookup( "test" ) );

		// expired one
		store.set( "test", now(), 10 );
		store.expireObject( "test" );
		assertEquals( false, store.lookup( "test" ) );

		// expire SR
		store.set( "test", now(), 10 );
		pool = store.getPool();
		pool[ "test" ].clear();
		assertEquals( false, store.lookup( "test" ) );
	}

	function testGet(){
		test = { name : "luis", created : now() };
		// non-sr
		store.set( "test", test, 0 );
		assertEquals( test, store.get( "test" ) );
		assertEquals( 2, store.getIndexer().getObjectMetadataProperty( "test", "hits" ) );

		// sr
		store.set( "test", test, 10 );
		assertEquals( test, store.get( "test" ) );
		assertEquals( true, store.getIndexer().getObjectMetadataProperty( "test", "isSoftReference" ) );
		assertEquals( 2, store.getIndexer().getObjectMetadataProperty( "test", "hits" ) );
	}

	function testGetQuiet(){
		test = { name : "luis", created : now() };
		// non-sr
		store.set( "test", test, 0 );
		assertEquals( test, store.getQuiet( "test" ) );
		assertEquals( 1, store.getIndexer().getObjectMetadataProperty( "test", "hits" ) );

		// sr
		store.set( "test", test, 10 );
		assertEquals( test, store.getQuiet( "test" ) );
		assertEquals( true, store.getIndexer().getObjectMetadataProperty( "test", "isSoftReference" ) );
		assertEquals( 1, store.getIndexer().getObjectMetadataProperty( "test", "hits" ) );
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
		data = store.getPool();
		assertEquals( data[ "test" ], "123" );

		// 2:Timeout = X
		store.$( "createSoftReference", "MySoftReference" );
		store.set( "test", "123", 20, 20 );
		data = store.getPool();
		assertEquals( data[ "test" ], "MySoftReference" );
	}

	function testClear(){
		// non sr
		store.set( "test", now(), 0 );
		results = store.clear( "test" );
		assertEquals( results, true );

		// sr
		store.set( "test", now(), 10 );
		results = store.clear( "test" );
		assertEquals( results, true );
	}

	function testGetSize(){
		assertTrue( store.getSize() eq 0 );
		store.set( "test", now(), 0 );
		assertTrue( store.getSize() eq 1 );
	}


	function testgetReferenceQueue(){
		assertEquals( getMetadata( store.getReferenceQueue() ).name, "java.lang.ref.ReferenceQueue" );
	}

	function testgetSoftRefKeyMap(){
		assertTrue( isStruct( store.getSoftRefKeyMap() ) );
	}

	function testCreateSoftReference(){
		var key = "myObj";
		var obj = { name : "luis", date : now() };

		makePublic( store, "createSoftReference" );

		var sr = store.createSoftReference( key, obj );

		// Test Reverse Mapping
		expect( store.softRefLookup( sr ) ).ToBeTrue();
		expect( store.getSoftRefKey( sr ) ).toBe( key );
	}

}
