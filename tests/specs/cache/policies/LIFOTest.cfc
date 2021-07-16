component extends="AbstractPolicyTest" {

	function setup(){
		super.setup();

		config = { evictCount : 2 };

		pool = {
			obj1 : {
				created      : now(),
				lastAccessed : now(),
				timeout      : 5,
				isExpired    : false,
				hits         : 999
			},
			obj2 : {
				created      : dateAdd( "n", -7, now() ),
				lastAccessed : dateAdd( "n", -14, now() ),
				timeout      : 10,
				isExpired    : false,
				hits         : 555
			},
			obj3 : {
				created      : dateAdd( "n", -6, now() ),
				lastAccessed : dateAdd( "n", -7, now() ),
				timeout      : 10,
				isExpired    : false,
				hits         : 111
			}
		};

		mockCM.$( "getConfiguration", config );
		mockIndexer.$( "getPoolMetadata", pool ).$( "objectExists", true );
		keys = structSort( pool, "numeric", "desc", "created" );
		mockIndexer.$( "getSortedKeys", keys );
		mockIndexer.$( "getObjectMetadata" ).$results( pool.obj2, pool.obj3, pool.obj1 );

		lifo = createMock( "coldbox.system.cache.policies.LIFO" ).init( mockCM );
	}

	function testPolicy(){
		lifo.execute();
		assertEquals( 2, arrayLen( mockCM.$callLog().clear ) );
		assertEquals( "obj1", mockCM.$callLog().clear[ 1 ][ 1 ] );
	}

}
