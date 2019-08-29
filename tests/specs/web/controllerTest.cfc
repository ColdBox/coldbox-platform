component extends="coldbox.system.testing.BaseModelTest" {

    function setUp(){
        controller = createMock( "coldbox.system.web.Controller" ).init(
            expandPath( "/coldbox/test-harness" ),
            "cbController"
        );
        prepareMock( controller.getRequestService() );
        prepareMock( controller.getInterceptorService() ).$( "processState" );
    }

    function testAppRoots(){
        AssertTrue( controller.getAppRootPath() eq expandPath( "/coldbox/test-harness" ) & "/" );
        controller.setAppRootPath( "nothing" );
        AssertTrue( controller.getAppRootPath() eq "nothing" );
    }

    function testDependencies(){
        AssertTrue( isObject( controller.getLoaderService() ) );
        AssertTrue( isObject( controller.getRequestService() ) );
        AssertTrue( isObject( controller.getinterceptorService() ) );
        AssertTrue( isObject( controller.getHandlerService() ) );
        AssertTrue( isObject( controller.getModuleService() ) );
    }

    function testSettings(){
        // Populate
        config = { handlerCaching: true, mysetting: "nothing", eventCaching: true };
        fwsettings = { Author: "Luis Majano" };

        controller.setConfigSettings( config );
        controller.setColdboxSettings( fwsettings );

        obj = controller.getConfigSettings();
        AssertFalse( structIsEmpty( obj ), "Structure populated" );

        obj = controller.getsettingStructure();
        AssertFalse( structIsEmpty( obj ), "Config Structure populated" );

        obj = controller.getsettingStructure( false, true );
        AssertFalse( structIsEmpty( obj ), "Config Structure populated, deep copy" );

        obj = controller.getsettingStructure( true );
        AssertFalse( structIsEmpty( obj ), "FW Structure populated" );

        obj = controller.getsettingStructure( true, false );
        AssertFalse( structIsEmpty( obj ), "FW Structure populated, deep copy" );
    }

    function testSettingProcedures(){
        // Populate
        config = { handlerCaching: true, mysetting: "nothing", eventCaching: true };
        fwsettings = { Author: "Luis Majano" };

        controller.setConfigSettings( config );
        controller.setColdboxSettings( fwsettings );

        obj = controller.getSetting( "HandlerCaching" );
        AssertTrue( isBoolean( obj ), "get test" );

        obj = controller.settingExists( "nada" );
        AssertFalse( obj, "config exists check" );

        obj = controller.settingExists( "HandlerCaching" );
        AssertTrue( obj, "config exists check" );

        obj = controller.settingExists( "nada", true );
        AssertFalse( obj, "fw exists check" );

        obj = "test_#createUUID()#";
        controller.setSetting( obj, obj );
        AssertEquals( obj, controller.getSetting( obj ) );
    }

    function testColdboxInit(){
        AssertFalse( controller.getColdboxInitiated() );
        controller.setColdboxInitiated( true );
        AssertTrue( controller.getColdboxInitiated() );
    }





    function appstarthandlerFired(){
        AssertFalse( controller.getAppStartHandlerFired() );
        controller.setAppStartHandlerFired( true );
        AssertTrue( controller.getAppStartHandlerFired() );
    }

    function testPersistVariables(){
        mockFlash = createMock( "coldbox.system.web.flash.MockFlash" ).init( controller );
        controller.getRequestService().$( "getFlashScope", mockFlash );
        mockFlash.$( "persistRC" ).$( "putAll" );

        makePublic( target = controller, method = "persistVariables" );

        controller.persistVariables( "hello,test" );
        assertEquals( "hello,test", mockFlash.$callLog().persistRC[ 1 ].include );

        persistStruct = { hello: "test", name: "luis" };
        controller.persistVariables( persistStruct = persistStruct );
        assertEquals( persistStruct, mockFlash.$callLog().putAll[ 2 ].map );
    }

    function testRelocate(){
        // mock data
        mockFlash = createMock( "coldbox.system.web.flash.MockFlash" ).init( controller );
        mockContext = getMockRequestContext();

        mockFlash.$( "saveFlash" );

        controller.setConfigSettings( { eventName: "event", defaultEvent: "main.index", flash: { autoSave: true } } );
        controller
            .$( "persistVariables" )
            .$( "pushTimers" )
            .$( "sendRelocation" );
        controller.getRequestService().$( "getContext", mockContext );
        controller.getRequestService().$( "getFlashScope", mockFlash );
        controller.getRequestService().$( "processState" );

        // Test Full URL
        controller.relocate( URL = "http://www.coldbox.org", addToken = true );
        assertEquals( "http://www.coldbox.org", controller.$callLog().sendRelocation[ 1 ].URL );
        assertEquals( true, controller.$callLog().sendRelocation[ 1 ].addToken );
        assertEquals( 0, controller.$callLog().sendRelocation[ 1 ].statusCode );

        // Full URL with more stuff
        controller.relocate( URL = "http://www.coldbox.org", statusCode = 301, queryString = "page=2&test=1" );
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
