component extends="tests.resources.BaseIntegrationTest" {

	this.loadColdBox = false;

	function setup(){
		flash          = createMock( "coldbox.system.web.flash.MockFlash" );
		mockController = createMock( className = "coldbox.system.web.Controller" );
		flash.init( mockController );

		// test scope
		testscope = {
			test : { content : "luis", autoPurge : true, keep : true },
			date : { content : now(), autoPurge : true, keep : true }
		};
	}

	function teardown(){
		flash.removeFlash();
	}

	function testClearFlash(){
		flash.clearFlash();
		assertTrue( structIsEmpty( flash.getMockFlash() ) );
	}

	function testSaveFlash(){
		flash.$( "getScope", testscope );
		flash.saveFlash();

		assertEquals( flash.getMockFlash(), testscope );
	}

	function testFlashExists(){
		flash.$( "getScope", testscope );
		flash.saveFlash();
		assertTrue( flash.flashExists() );
	}

	function testgetFlash(){
		flash.removeFlash();
		assertEquals( flash.getMockFlash(), structNew() );

		flash.$( "getScope", testscope );
		flash.saveFlash();
		assertEquals( flash.getMockFlash(), testScope );
	}

}
