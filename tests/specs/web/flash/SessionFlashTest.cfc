component extends="tests.resources.BaseIntegrationTest" {

	this.loadColdBox = false;

	function setup(){
		flash          = createMock( "coldbox.system.web.flash.SessionFlash" );
		mockController = createMock( className = "coldbox.system.web.Controller" );
		flash.init( mockController );

		// test scope
		testscope = {
			test : { content : "luis", autoPurge : true, keep : true },
			date : { content : now(), autoPurge : true, keep : true }
		};
	}
	function teardown(){
		lock scope="session" timeout="10" throwOnTimeout="true" {
			structClear( session );
		}
	}
	function testClearFlash(){
		session[ flash.getFlashKey() ] = testscope;
		flash.clearFlash();
		assertFalse( structKeyExists( session, flash.getFlashKey() ) );
	}
	function testSaveFlash(){
		flash.$( "getScope", testscope );
		flash.saveFlash();
		assertEquals( session[ flash.getFlashKey() ], testscope );
	}
	function testFlashExists(){
		assertFalse( flash.flashExists() );
		session[ flash.getFlashKey() ] = testscope;
		assertTrue( flash.flashExists() );
	}
	function testgetFlash(){
		assertEquals( flash.getFlash(), structNew() );

		session[ flash.getFlashKey() ] = testscope;
		assertEquals( flash.getFlash(), testScope );
	}

}
