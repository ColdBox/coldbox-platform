component extends="AbstractPolicyTest" {

	function setup(){
		super.setup();

		config = { evictCount : 2 };

		pool = {
			obj1 : { created : now(), timeout : 5, isExpired : false },
			obj2 : {
				created   : dateAdd( "n", -7, now() ),
				timeout   : 10,
				isExpired : false
			},
			obj3 : {
				created   : dateAdd( "n", -6, now() ),
				timeout   : 10,
				isExpired : false
			}
		};

		mockStore = createStub();
		mockCM.$( "getConfiguration", config );
		mockCM.$( "getObjectStore", mockStore );
		mockCM.$( "lookupQuiet", true );
		mockCM.$( "getCachedObjectMetadata" ).$results( pool.obj2, pool.obj3, pool.obj1 );

		keys = structSort( pool, "numeric", "asc", "created" );
		mockStore.$( "getSortedKeys", keys );

		fifo = createMock( "coldbox.system.cache.policies.FIFO" ).init( mockCM );
	}

	function testPolicy(){
		fifo.execute();
		assertEquals( 2, arrayLen( mockCM.$callLog().clear ) );
		assertEquals( "obj2", mockCM.$callLog().clear[ 1 ][ 1 ] );
	}

}
