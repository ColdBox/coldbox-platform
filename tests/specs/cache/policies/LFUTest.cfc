component extends="AbstractPolicyTest" {

	function setup(){
		super.setup();

		config = { evictCount : 2 };

		pool = {
			obj1 : {
				created   : now(),
				timeout   : 5,
				isExpired : false,
				hits      : 1
			},
			obj2 : {
				created   : dateAdd( "n", -7, now() ),
				timeout   : 10,
				isExpired : false,
				hits      : 555
			},
			obj3 : {
				created   : dateAdd( "n", -6, now() ),
				timeout   : 10,
				isExpired : false,
				hits      : 2
			}
		};

		mockCM.$( "getConfiguration", config );
		mockIndexer.$( "getPoolMetadata", pool ).$( "objectExists", true );
		keys = structSort( pool, "numeric", "asc", "hits" );
		mockIndexer.$( "getSortedKeys", keys );
		mockIndexer.$( "getObjectMetadata" ).$results( pool.obj2, pool.obj3, pool.obj1 );

		lfu = createMock( "coldbox.system.cache.policies.LFU" ).init( mockCM );
	}

	function testPolicy(){
		lfu.execute();
		assertEquals( 2, arrayLen( mockCM.$callLog().clear ) );
		assertEquals( "obj1", mockCM.$callLog().clear[ 1 ][ 1 ] );
	}

}
