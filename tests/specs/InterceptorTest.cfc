component extends="coldbox.system.testing.BaseModelTest" {

	function setup(){
		interceptor    = createMock( "coldbox.system.Interceptor" );
		mockIService   = createEmptyMock( "coldbox.system.web.services.InterceptorService" );
		mockController = createMock( "coldbox.system.web.Controller" );
		mockRS         = createMock( "coldbox.system.web.services.RequestService" );
		flashScope     = createMock( "coldbox.system.web.flash.MockFlash" );
		mockLogBox     = createMock( "coldbox.system.logging.LogBox" );
		mockLogger     = createMock( "coldbox.system.logging.Logger" );
		mockCacheBox   = createEmptyMock( "coldbox.system.cache.CacheFactory" );
		mockWireBox    = createEmptyMock( "coldbox.system.ioc.Injector" );

		mockController
			.$( "getRequestService", mockRS )
			.$( "getInterceptorService", mockIService )
			.$( "getSetting" )
			.$args( "applicationHelper" )
			.$results( [] );

		mockController.setLogBox( mockLogBox );
		mockController.setWireBox( mockWireBox );
		mockController.setCacheBox( mockCacheBox );

		mockRS.$( "getFlashScope", flashScope );
		mockLogBox.$( "getLogger", mockLogger );

		properties = { debugmode : true, configFile : "config/routes.cfm" };
		interceptor.init( mockController, properties ).$( "getInterceptorService", mockIService );
	}

	function testProperties(){
		assertEquals( interceptor.getProperty( "debugMode" ), true );
		interceptor.setProperty( "luis", "majano" );
		assertEquals( interceptor.getProperty( "luis" ), "majano" );

		assertTrue( interceptor.propertyExists( "luis" ) );
	}

	function testUnregister(){
		mockController.$( "getInterceptorService", mockIService );
		mockIService.$( "unregister", true );

		interceptor.unregister( "preProcess" );
		assertEquals( mockIService.$count( "unregister" ), 1 );
	}

}
