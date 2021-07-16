component extends="tests.resources.BaseIntegrationTest" {

	this.loadColdBox = false;

	function setup(){
		flash          = createMock( "coldbox.system.web.flash.AbstractFlashScope" );
		mockController = createMock( className = "coldbox.system.web.Controller", clearMethods = true );
		mockRService   = createMock( className = "coldbox.system.web.services.RequestService", clearMethods = true );
		mockEvent      = createMock( className = "coldbox.system.web.context.RequestContext", clearMethods = true );

		mockController
			.$( "getRequestService", mockRService )
			.$(
				method             = "getUtil",
				returns            = new coldbox.system.core.util.Util(),
				preserveReturnType = false
			);
		mockRService.$( "getContext", mockEvent );

		flash.init( mockController );

		testScope = {
			name : {
				content      : "luis majano",
				keep         : true,
				inflateToRC  : true,
				inflateToPRC : false,
				autoPurge    : true
			},
			date : {
				content      : now(),
				keep         : true,
				inflateToRC  : true,
				inflateToPRC : false,
				autoPurge    : true
			}
		};
	}

	function teardown(){
	}

	function testInflateFlash(){
		testScope = {
			name : {
				content      : "luis majano",
				keep         : true,
				inflateToRC  : true,
				inflateToPRC : false,
				autoPurge    : true
			},
			date : {
				content      : now(),
				keep         : true,
				inflateToRC  : true,
				inflateToPRC : false,
				autoPurge    : true
			},
			testData : {
				keep         : true,
				inflateToRC  : true,
				inflateToPRC : false,
				autoPurge    : true
			}
		};
		mockEvent.$( "setValue" );
		flash.$( "getFlash", testScope ).$( "clearFlash" );

		flash.inflateFlash();
		assertEquals( flash.size(), 2 );
		// debug( mockEvent.$callLog().setValue );
		assertEquals( arrayLen( mockEvent.$callLog().setValue ), 2 );
	}

	function testScopeMethods(){
		flash.clear();

		assertEquals( flash.size(), 0 );
		assertEquals( flash.isEmpty(), true );

		flash.put( "name", "luis majano" );
		flash.put( "obj", this );

		assertEquals( flash.exists( "name" ), true );
		assertEquals( flash.exists( "obj2" ), false );
		assertEquals( flash.isEmpty(), false );

		flash.clear();
		assertEquals( flash.size(), 0 );

		testMap = { name : "luis majano", date : now() };

		flash.putAll( testMap );
		assertEquals( flash.size(), 2 );
		assertEquals( flash.get( "name" ), "luis majano" );
		flash.remove( "name" );
		assertEquals( flash.get( "name", "" ), "" );
	}

	function testPersistRC(){
		mockEvent.$( "getCollection", testScope );

		flash.clear();

		flash.persistRC();
		assertEquals(
			flash.size(),
			0,
			"Nothing persisted, flash shuold be empty."
		);

		flash.persistRC( include = "name" );
		assertEquals(
			flash.size(),
			1,
			"Flash should contain only 'name', thus one item."
		);

		flash.clear();

		flash.persistRC( include = "name,date" );
		assertEquals(
			flash.size(),
			2,
			"Flash should cotnain only 'name' and 'date', thus two items."
		);

		flash.clear();

		flash.persistRC( exclude = "name" );
		assertEquals(
			flash.size(),
			1,
			"After being cleared, flash should only contain 'name', thus one item."
		);
	}

	function testClearFlash(){
		flash.$( "flashExists", true );
		testScope = {
			t1 : { content : createUUID(), keep : true, autoPurge : true },
			t2 : { content : createUUID(), keep : true, autoPurge : true },
			t3 : { content : createUUID(), keep : true, autoPurge : false },
			t4 : { content : createUUID(), keep : true, autoPurge : true },
			t5 : { content : createUUID(), keep : true, autoPurge : false }
		};
		flash.$( "getFlash", testScope );

		flash.clearFlash();

		assertTrue( structKeyExists( testScope, "t3" ) );
		assertTrue( structKeyExists( testScope, "t5" ) );
	}

	function testGetKeys(){
		var testScope = {
			t1 : { content : createUUID(), keep : true, autoPurge : true },
			t2 : { content : createUUID(), keep : true, autoPurge : true },
			t3 : { content : createUUID(), keep : true, autoPurge : false },
			t4 : { content : createUUID(), keep : true, autoPurge : true },
			t5 : { content : createUUID(), keep : true, autoPurge : false }
		};
		flash.$( "getScope", testScope );

		var r = flash.getKeys();

		assertTrue( listLen( r ) == 5 );
	}

	function testGetAll(){
		var testScope = {
			t1 : { content : createUUID(), keep : true, autoPurge : true },
			t2 : { content : createUUID(), keep : true, autoPurge : true },
			t3 : { content : createUUID(), keep : true, autoPurge : false },
			t4 : { content : createUUID(), keep : true, autoPurge : true },
			t5 : { content : createUUID(), keep : true, autoPurge : false }
		};
		flash.$( "getScope", testScope );

		var r = flash.getAll();
		expect( r ).toBeStruct().toHaveLength( 5 );
	}

}
