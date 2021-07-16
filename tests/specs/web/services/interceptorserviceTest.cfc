component extends="coldbox.system.testing.BaseModelTest" model="coldbox.system.web.services.InterceptorService" {

	function setup(){
		super.setup();

		// Create Mock Objects
		mockbox            = getMockBox();
		mockController     = mockBox.createMock( "coldbox.system.testing.mock.web.MockController" );
		mockRequestContext = getMockRequestContext();
		mockRequestService = mockBox
			.createEmptyMock( "coldbox.system.web.services.RequestService" )
			.$( "getContext", mockRequestContext );
		mockLogBox   = mockBox.createEmptyMock( "coldbox.system.logging.LogBox" );
		mockLogger   = mockBox.createEmptyMock( "coldbox.system.logging.Logger" );
		mockFlash    = mockBox.createMock( "coldbox.system.web.flash.MockFlash" ).init( mockController );
		mockCacheBox = mockBox.createEmptyMock( "coldbox.system.cache.CacheFactory" );
		mockCache    = mockBox.createEmptyMock( "coldbox.system.cache.providers.CacheBoxColdBoxProvider" );
		mockWireBox  = mockBox.createEmptyMock( "coldbox.system.ioc.Injector" );

		// Mock model Dependencies
		mockController.$( "getRequestService", mockRequestService );

		mockController.setLogBox( mockLogBox );
		mockController.setWireBox( mockWireBox );
		mockController.setCacheBox( mockCacheBox );

		mockRequestService.$( "getFlashScope", mockFlash );
		mockLogBox.$( "getLogger", mockLogger );

		iService = model.init( mockController ).$( "getCache", mockCache );
	}

	function testonConfigurationLoad(){
		mockController
			.$( "getSetting" )
			.$args( "InterceptorConfig" )
			.$results( {} )
			.$( "getSetting" )
			.$args( "coldboxConfig" )
			.$results( mockBox.createStub() );
		iService.$( "registerInterceptor", iService ).$( "registerInterceptors", iService );

		iService.onConfigurationLoad();

		assertTrue( iService.$once( "registerInterceptors" ) );
	}

	function testregisterInterceptors(){
		var states = "";
		mockConfig = {
			customInterceptionPoints : [ "myCustom" ],
			interceptors             : [
				{
					class      : "coldbox.system.interceptors.Custom",
					properties : { n : 1 },
					name       : "Custom"
				}
			]
		};
		iService.$property( "interceptorConfig", "variables", mockConfig ).$( "registerInterceptor", iService );
		mockLogger.$( "info" );

		iService.registerInterceptors();

		assertTrue( iService.$count( 1, "registerInterceptor" ) );
	}

	function testInterceptionPoints(){
		// test registration again
		assertTrue( arrayLen( iService.getInterceptionPoints() ) gt 0 );
	}

	function testgetStateContainer(){
		state = iService.getStateContainer( "nothing" );

		assertFalse( isObject( state ) );

		mockState = createStub().$( "process" );
		iService.$property(
			"preProcess",
			"variables.interceptionStates",
			mockState
		);
		state = iService.getStateContainer( "preProcess" );

		assertTrue( isObject( state ) );
	}

	function testUnregister(){
		// mocks
		mockCache.INTERCEPTOR_CACHEKEY_PREFIX = "sample";
		mockState                             = mockBox.createStub().$( "unregister" );
		iService.$property(
			"preProcess",
			"variables.interceptionStates",
			mockState
		);
		mockState2 = mockBox.createStub().$( "unregister" );
		iService.$property(
			"preProcess2",
			"variables.interceptionStates",
			mockState2
		);

		// 1: From All States
		iService.unregister( "Luis" );
		assertTrue( mockState.$once( "unregister" ) );
		assertTrue( mockState2.$once( "unregister" ) );

		// 2: From Specific State
		iService.unregister( "Luis", "preProcess2" );
		assertTrue( mockState.$once( "unregister" ) );
		assertTrue( mockState2.$count( 2, "unregister" ) );
	}

	function testAppendInterceptionPoints(){
		var aLen = arrayLen( iService.getInterceptionPoints() );

		// test 1: nothing
		iService.appendInterceptionPoints( "" );
		assertEquals( aLen, arrayLen( iService.getInterceptionPoints() ) );

		// test 2: add points
		aLen = arrayLen( iService.getInterceptionPoints() );
		iService.appendInterceptionPoints( "onTest,onLuis" );
		assertEquals( aLen + 2, arrayLen( iService.getInterceptionPoints() ) );

		// test 3: add points with duplicates
		aLen = arrayLen( iService.getInterceptionPoints() );
		iService.appendInterceptionPoints( [ "on1", "on2", "on1" ] );
		assertEquals( ( aLen + 2 ), arrayLen( iService.getInterceptionPoints() ) );
	}

	function testSimpleProcessInterception(){
		// 1: inited with throw enabled but not throw
		mockController.$( "getColdboxInitiated", true );
		iService.announce( "preProcess" );

		// 3: process a mock state
		mockController.$( "getColdboxInitiated", true );
		mockState = createStub().$( "process" );
		iService.$property(
			"preProcess",
			"variables.interceptionStates",
			mockState
		);
		// debug( iService.getInterceptionStates() );
		iService.announce( "badState" );
		assertTrue( mockState.$never( "process" ) );

		// 4: real mock state
		mockController.$( "getColdboxInitiated", true );
		mockState = createStub().$( "process" );
		iService.$property(
			"preProcess",
			"variables.interceptionStates",
			mockState
		);
		// debug( iService.getInterceptionStates() );
		iService.announce( "preProcess" );
		assertTrue( mockState.$once( "process" ) );
	}

	function testManualRegistration(){
		// mocks
		mockCache.INTERCEPTOR_CACHEKEY_PREFIX = "sample";
		mockCache.$( "set", true );
		mockLogger.$( "canDebug", false ).$( "error" );
		mockController.$( "getAspectsInitiated", false );

		iService.appendInterceptionPoints( "unitTest" );
		iService.$( "createInterceptor", createObject( "component", "coldbox.tests.resources.MockInterceptor" ) );
		iService.registerInterceptor( interceptorClass = "coldbox.tests.resources.MockInterceptor" );

		assertTrue( isObject( iService.getStateContainer( "unittest" ) ) );
	}

	function testManualObjectRegistration(){
		// mocks
		var obj                               = createObject( "component", "coldbox.tests.resources.MockInterceptor" );
		mockCache.INTERCEPTOR_CACHEKEY_PREFIX = "sample";
		mockLogger.$( "canDebug", false );
		mockController.$( "getAspectsInitiated", false );

		iService.appendInterceptionPoints( "unitTest" );
		iService.registerInterceptor( interceptorObject = obj );

		assertTrue( isObject( iService.getStateContainer( "unittest" ) ) );
	}

	function testManualObjectRegistration2(){
		// mocks
		var obj                               = createObject( "component", "coldbox.tests.resources.MockInterceptor" );
		mockCache.INTERCEPTOR_CACHEKEY_PREFIX = "sample";
		mockLogger.$( "canDebug", false );
		mockController.$( "getAspectsInitiated", false );

		iService.registerInterceptor( interceptorObject = obj, customPoints = "unitTest" );

		assertTrue( isObject( iService.getStateContainer( "unittest" ) ) );
	}

}
