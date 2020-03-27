component extends="coldbox.system.testing.BaseModelTest"{

	function setup(){
		handler        = createMock( "coldbox.system.EventHandler" );
		mockController = createMock( "coldbox.system.web.Controller" );
		flashScope     = createEmptyMock( "coldbox.system.web.flash.MockFlash" );
		mockRS         = createEmptyMock( "coldbox.system.web.services.RequestService" ).$( "getFlashScope", flashScope );
		mockLogger     = createEmptyMock( "coldbox.system.logging.Logger" );
		mockLogBox     = createEmptyMock( "coldbox.system.logging.LogBox" ).$( "getLogger", mockLogger );
		mockCacheBox   = createEmptyMock( "coldbox.system.cache.CacheFactory" );
		mockWireBox    = createEmptyMock( "coldbox.system.ioc.Injector" );

		mockController.$( "getRequestService", mockRS );

		mockController.setLogBox( mockLogBox );
		mockController.setWireBox( mockWireBox );
		mockController.setCacheBox( mockCacheBox );

		mockController
			.$( "getSetting" )
			.$args( "applicationHelper" )
			.$results( [
				"/tests/resources/mixins.cfm",
				"/tests/resources/mixins2"
			] )
			.$( "getSetting" )
			.$args( "AppMapping" )
			.$results( "/coldbox/testing" );

		handler.init( mockController );
	}

	function testMixins(){
		assertTrue( structKeyExists( handler, "mixinTest" ) );
		assertTrue( structKeyExists( handler, "repeatThis" ) );
		assertTrue( structKeyExists( handler, "add" ) );
	}

}