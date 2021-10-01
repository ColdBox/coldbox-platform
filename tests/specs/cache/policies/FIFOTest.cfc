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

		mockCM.$( "getConfiguration", config );
		mockIndexer.$( "getPoolMetadata", pool ).$( "objectExists", true );
		keys = structSort( pool, "numeric", "asc", "created" );

		mockIndexer.$( "getSortedKeys", keys );
		mockIndexer.$( "getObjectMetadata" ).$results( pool.obj2, pool.obj3, pool.obj1 );

		fifo = createMock( "coldbox.system.cache.policies.FIFO" ).init( mockCM );
	}

	function testPolicy(){
		fifo.execute();
		assertEquals( 2, arrayLen( mockCM.$callLog().clear ) );
		assertEquals( "obj2", mockCM.$callLog().clear[ 1 ][ 1 ] );
	}

}
