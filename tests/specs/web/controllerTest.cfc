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
		expect( controller.getLoaderService() ).toBeComponent();
		expect( controller.getRequestService() ).toBeComponent();
		expect( controller.getinterceptorService() ).toBeComponent();
		expect( controller.getHandlerService() ).toBeComponent();
		expect( controller.getModuleService() ).toBeComponent();
	}

	function testSettings(){
		// Populate
		var config = {
			handlerCaching : true,
			mysetting      : "nothing",
			eventCaching   : true
		};
		var fwsettings = { Author : "Luis Majano" };

		controller.setConfigSettings( config );
		controller.setColdboxSettings( fwsettings );

		expect( controller.getConfigSettings() ).toBe( config );
		expect( controller.getColdBoxSettings() ).toBe( fwsettings );
	}

	function testSettingProcedures(){
		// Populate
		var config = {
			handlerCaching : true,
			mysetting      : "nothing",
			eventCaching   : true
		};
		var fwsettings = { Author : "Luis Majano" };

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
		mockFlash   = createMock( "coldbox.system.web.flash.MockFlash" ).init( controller ).$( "saveFlash" );
		mockContext = getMockRequestContext();

		controller
			.setConfigSettings( {
				eventName    : "event",
				defaultEvent : "main.index",
				flash        : { autoSave : true },
				SESBaseURL   : "http://localhost"
			} )
			.$( "persistVariables" )
			.$( "pushTimers" )
			.$( "sendRelocation" )
			// More Mocks
			.getRequestService()
			.$( "getContext", mockContext )
			.$( "getFlashScope", mockFlash )
			.$( "announce" );

		// Test Full URL
		controller.relocate( URL = "http://www.coldbox.org", addToken = true );
		assertEquals( "http://www.coldbox.org", controller.$callLog().sendRelocation[ 1 ].URL );
		assertEquals( true, controller.$callLog().sendRelocation[ 1 ].addToken );
		assertEquals( 302, controller.$callLog().sendRelocation[ 1 ].statusCode );

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
