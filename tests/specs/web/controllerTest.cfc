component extends="coldbox.system.testing.BaseModelTest" {

	function setUp(){
		controller = createMock( "coldbox.system.web.Controller" ).init(
			expandPath( "/coldbox/test-harness" ),
			"cbController"
		);
		prepareMock( controller.getRequestService() );
		prepareMock( controller.getInterceptorService() ).$( "announce" );
	}

	function testAppRoots(){
		assertTrue( controller.getAppRootPath() eq expandPath( "/coldbox/test-harness" ) & "/" );
		controller.setAppRootPath( "nothing" );
		assertTrue( controller.getAppRootPath() eq "nothing" );
	}

	function testDependencies(){
		assertTrue( isObject( controller.getLoaderService() ) );
		assertTrue( isObject( controller.getRequestService() ) );
		assertTrue( isObject( controller.getinterceptorService() ) );
		assertTrue( isObject( controller.getHandlerService() ) );
		assertTrue( isObject( controller.getModuleService() ) );
	}

	function testSettings(){
		// Populate
		config = {
			handlerCaching : true,
			mysetting      : "nothing",
			eventCaching   : true
		};
		fwsettings = { Author : "Luis Majano" };

		controller.setConfigSettings( config );
		controller.setColdboxSettings( fwsettings );

		obj = controller.getConfigSettings();
		assertFalse( structIsEmpty( obj ), "Structure populated" );
	}

	function testSettingProcedures(){
		// Populate
		config = {
			handlerCaching : true,
			mysetting      : "nothing",
			eventCaching   : true
		};
		fwsettings = { Author : "Luis Majano" };

		controller.setConfigSettings( config );
		controller.setColdboxSettings( fwsettings );

		obj = controller.getSetting( "HandlerCaching" );
		assertTrue( isBoolean( obj ), "get test" );

		obj = controller.settingExists( "nada" );
		assertFalse( obj, "config exists check" );

		obj = controller.settingExists( "HandlerCaching" );
		assertTrue( obj, "config exists check" );

		obj = "test_#createUUID()#";
		controller.setSetting( obj, obj );
		assertEquals( obj, controller.getSetting( obj ) );
	}

	function testColdboxInit(){
		assertFalse( controller.getColdboxInitiated() );
		controller.setColdboxInitiated( true );
		assertTrue( controller.getColdboxInitiated() );
	}

	function appstarthandlerFired(){
		assertFalse( controller.getAppStartHandlerFired() );
		controller.setAppStartHandlerFired( true );
		assertTrue( controller.getAppStartHandlerFired() );
	}

	function testPersistVariables(){
		mockFlash = createMock( "coldbox.system.web.flash.MockFlash" ).init( controller );
		controller.getRequestService().$( "getFlashScope", mockFlash );
		mockFlash.$( "persistRC" ).$( "putAll" );

		makePublic( target = controller, method = "persistVariables" );

		controller.persistVariables( "hello,test" );
		assertEquals( "hello,test", mockFlash.$callLog().persistRC[ 1 ].include );

		persistStruct = { hello : "test", name : "luis" };
		controller.persistVariables( persistStruct = persistStruct );
		assertEquals( persistStruct, mockFlash.$callLog().putAll[ 2 ].map );
	}

	function testRelocate(){
		// mock data
		mockFlash   = createMock( "coldbox.system.web.flash.MockFlash" ).init( controller );
		mockContext = getMockRequestContext();

		mockFlash.$( "saveFlash" );

		controller.setConfigSettings( {
			eventName    : "event",
			defaultEvent : "main.index",
			flash        : { autoSave : true }
		} );
		controller
			.$( "persistVariables" )
			.$( "pushTimers" )
			.$( "sendRelocation" );
		controller.getRequestService().$( "getContext", mockContext );
		controller.getRequestService().$( "getFlashScope", mockFlash );
		controller.getRequestService().$( "announce" );

		// Test Full URL
		controller.relocate( URL = "http://www.coldbox.org", addToken = true );
		assertEquals( "http://www.coldbox.org", controller.$callLog().sendRelocation[ 1 ].URL );
		assertEquals( true, controller.$callLog().sendRelocation[ 1 ].addToken );
		assertEquals( 0, controller.$callLog().sendRelocation[ 1 ].statusCode );

		// Full URL with more stuff
		controller.relocate(
			URL         = "http://www.coldbox.org",
			statusCode  = 301,
			queryString = "page=2&test=1"
		);
		assertEquals( "http://www.coldbox.org?page=2&test=1", controller.$callLog().sendRelocation[ 2 ].URL );
		assertEquals( false, controller.$callLog().sendRelocation[ 2 ].addToken );
		assertEquals( 301, controller.$callLog().sendRelocation[ 2 ].statusCode );

		// Test relative URI with query strings
		controller.relocate( URI = "/route/path/two", queryString = "page=2&test=1" );
		assertEquals( "/route/path/two?page=2&test=1", controller.$callLog().sendRelocation[ 3 ].URL );

		// Test normal event
		controller.relocate( event = "general.page", querystring = "page=2&test=1" );
		// assertEquals( "", controller.$callLog().sendRelocation[4].URL );

		// debug( controller.$calllog() );
	}

}
