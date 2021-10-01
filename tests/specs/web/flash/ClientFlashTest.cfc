component extends="tests.resources.BaseIntegrationTest" {

	this.loadColdBox = false;

	function setup(){
		flash          = createMock( "coldbox.system.web.flash.ClientFlash" );
		mockController = createMock( className = "coldbox.system.web.Controller" );
		converter      = createMock( className = "coldbox.system.core.conversion.ObjectMarshaller" ).init();

		flash.init( mockController );

		system = createObject( "java", "java.lang.System" );
		obj    = createObject( "component", "coldbox.system.core.util.CFMLEngine" ).init();
		test   = converter.deserializeObject( converter.serializeObject( obj ) );

		// test scope
		testscope = {
			test : { content : "luis", autoPurge : true, keep : true },
			date : { content : now(), autoPurge : true, keep : true },
			obj  : { content : obj, autoPurge : true, keep : true }
		};
	}
	function teardown(){
		structClear( client );
	}
	function testClearFlash(){
		client[ flash.getFlashKey() ] = converter.serializeObject( testscope );
		flash.clearFlash();
		assertFalse( structKeyExists( client, flash.getFlashKey() ) );
	}
	function testSaveFlash(){
		flash.$( "getScope", testscope );
		flash.saveFlash();
		assertTrue( len( client[ flash.getFlashKey() ] ) );
	}
	function testFlashExists(){
		assertFalse( flash.flashExists() );
		client[ flash.getFlashKey() ] = "NADA";
		assertTrue( flash.flashExists() );
	}
	function testgetFlash(){
		// assertEquals( flash.getFlash(), structNew() );

		client[ flash.getFlashKey() ] = converter.serializeObject( testscope );

		assertTrue( structKeyExists( flash.getFlash(), "obj" ) );
		assertTrue( structKeyExists( flash.getFlash(), "date" ) );
		assertTrue( structKeyExists( flash.getFlash(), "test" ) );
	}

}
