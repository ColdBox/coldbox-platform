component extends="coldbox.system.testing.BaseModelTest" model="coldbox.system.web.services.InterceptorService" {

	function setup(){
		super.setup();

		// Create Mock Objects
		variables.mockbox            = getMockBox();
		variables.mockController     = mockBox.createMock( "coldbox.system.testing.mock.web.MockController" );
		variables.mockRequestContext = getMockRequestContext();
		variables.mockRequestService = mockBox
			.createEmptyMock( "coldbox.system.web.services.RequestService" )
			.$( "getContext", mockRequestContext );
		variables.mockLogBox   = mockBox.createEmptyMock( "coldbox.system.logging.LogBox" );
		variables.mockLogger   = mockBox.createEmptyMock( "coldbox.system.logging.Logger" ).$( "canDebug", false );
		variables.mockFlash    = mockBox.createMock( "coldbox.system.web.flash.MockFlash" ).init( mockController );
		variables.mockCacheBox = mockBox.createEmptyMock( "coldbox.system.cache.CacheFactory" );
		variables.mockCache    = mockBox.createEmptyMock( "coldbox.system.cache.providers.CacheBoxColdBoxProvider" );
		variables.mockWireBox  = mockBox.createEmptyMock( "coldbox.system.ioc.Injector" );

		// Mock model Dependencies
		mockController.$( "getRequestService", mockRequestService );

		mockController.setLogBox( mockLogBox );
		mockController.setWireBox( mockWireBox );
		mockController.setCacheBox( mockCacheBox );

		mockRequestService.$( "getFlashScope", mockFlash );
		mockLogBox.$( "getLogger", mockLogger );

		variables.iService = model
			.init( mockController )
			.$( "getCache", mockCache )
			.$property( "wirebox", "variables", mockWireBox );
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
		iService.$property( "interceptionPointsChanged", "variables", true );

		iService.onConfigurationLoad();

		assertTrue( iService.$once( "registerInterceptors" ) );
		expect( iService.getInterceptionPointsChanged() ).toBeFalse();
	}

	function testregisterInterceptors(){
		var states     = "";
		var mockConfig = {
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
		expect( iService.getInterceptionPointIndex() ).toHaveKey( "myCustom" );
		expect( iService.getInterceptionPointIndex().myCustom.core ).toBeFalse();
		expect( iService.getInterceptionPointIndex().myCustom.module ).toBe( "" );
	}

	function testListen(){
		var called = false;
		iService.listen( function(){
			called = true;
		}, "onCall" );
		iService.announce( "onCall" );
		assertTrue( called );
	}

	function testUnlisten(){
		var called   = false;
		var listener = function(){
			called = true;
		};
		iService.listen( listener, "onCall" );
		iService.unlisten( listener, "onCall" );

		iService.announce( "onCall" );
		assertFalse( called );
	}

	function testListenReverseArgumentOrder(){
		var called = false;
		iService.listen( "onCall", function(){
			called = true;
		} );
		iService.announce( "onCall" );
		assertTrue( called );
	}

	function testUnlistenReverseArgumentOrder(){
		var called   = false;
		var listener = function(){
			called = true;
		};
		iService.listen( "onCall", listener );
		iService.unlisten( "onCall", listener );

		iService.announce( "onCall" );
		assertFalse( called );
	}

	function testAnnounceFlushesBufferedInterceptorOutput(){
		iService.listen( function( event, data, buffer ){
			arguments.buffer.append( "buffered output" )
		}, "onBufferedOutput" )

		savecontent variable="local.output" {
			iService.announce( "onBufferedOutput" )
		}

		expect( local.output ).toBe( "buffered output" )
	}

	function testInterceptionPoints(){
		// test registration again
		assertTrue( arrayLen( iService.getInterceptionPoints() ) gt 0 );
		expect( iService.getInterceptionPointIndex() ).toHaveKey( "preProcess" );
		expect( iService.getInterceptionPointIndex().preProcess.name ).toBe( "preProcess" );
		expect( iService.getInterceptionPointIndex().preProcess.core ).toBeTrue();
		expect( iService.getInterceptionPointIndex().preProcess.module ).toBe( "" );
		expect( iService.getInterceptionPointIndex().preProcess.order ).toBeGT( 0 );
	}

	function testgetStateContainer(){
		var state = iService.getStateContainer( "nothing" );

		assertFalse( isObject( state ) );

		var mockState = createStub().$( "process" );
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
		var mockState                         = mockBox.createStub().$( "unregister" );
		iService.$property(
			"preProcess",
			"variables.interceptionStates",
			mockState
		);
		var mockState2 = mockBox.createStub().$( "unregister" );
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
		expect( iService.getInterceptionPointsChanged() ).toBeFalse();

		// test 1: nothing
		iService.appendInterceptionPoints( "" );
		assertEquals( aLen, arrayLen( iService.getInterceptionPoints() ) );
		expect( iService.getInterceptionPointsChanged() ).toBeFalse();

		// test 2: add points
		aLen = arrayLen( iService.getInterceptionPoints() );
		iService.appendInterceptionPoints( "onTest,onLuis" );
		assertEquals( aLen + 2, arrayLen( iService.getInterceptionPoints() ) );
		expect( iService.getInterceptionPointIndex().onTest.name ).toBe( "onTest" );
		expect( iService.getInterceptionPointIndex().onTest.core ).toBeFalse();
		expect( iService.getInterceptionPointIndex().onTest.module ).toBe( "" );
		expect( iService.getInterceptionPointsChanged() ).toBeTrue();

		iService.$property(
			"interceptionPointsChanged",
			"variables",
			false
		);

		// test 3: add points with duplicates
		aLen = arrayLen( iService.getInterceptionPoints() );
		iService.appendInterceptionPoints( [ "on1", "on2", "on1" ] );
		assertEquals( ( aLen + 2 ), arrayLen( iService.getInterceptionPoints() ) );
		expect( iService.getInterceptionPointsChanged() ).toBeTrue();

		iService.$property(
			"interceptionPointsChanged",
			"variables",
			false
		);

		// test 4: add module points
		aLen = arrayLen( iService.getInterceptionPoints() );
		iService.appendInterceptionPoints( customPoints = "onModulePoint", module = "testModule" );
		assertEquals( ( aLen + 1 ), arrayLen( iService.getInterceptionPoints() ) );
		expect( iService.getInterceptionPointIndex().onModulePoint.name ).toBe( "onModulePoint" );
		expect( iService.getInterceptionPointIndex().onModulePoint.core ).toBeFalse();
		expect( iService.getInterceptionPointIndex().onModulePoint.module ).toBe( "testModule" );
		expect( iService.getInterceptionPointsChanged() ).toBeTrue();

		iService.$property(
			"interceptionPointsChanged",
			"variables",
			false
		);

		// test 5: case-insensitive duplicate checks use the index
		aLen = arrayLen( iService.getInterceptionPoints() );
		iService.appendInterceptionPoints( "ONMODULEPOINT" );
		assertEquals( aLen, arrayLen( iService.getInterceptionPoints() ) );
		expect( iService.getInterceptionPointIndex().onModulePoint.module ).toBe( "testModule" );
		expect( iService.getInterceptionPointsChanged() ).toBeFalse();
	}

	function testRescanInterceptorsOnlyWhenInterceptionPointsChanged(){
		mockLogger.$( "info" );
		iService.$( "registerInterceptors", iService );

		iService.rescanInterceptors();
		assertTrue( iService.$never( "registerInterceptors" ) );

		iService.appendInterceptionPoints( "onStartupAddedPoint" );
		iService.rescanInterceptors();

		assertTrue( iService.$once( "registerInterceptors" ) );
	}

	function testSimpleProcessInterception(){
		// 1: inited with throw enabled but not throw
		mockController.$( "getColdboxInitiated", true );
		iService.announce( "preProcess" );

		// 3: process a mock state
		mockController.$( "getColdboxInitiated", true );
		var mockState = createStub().$( "process" );
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

	function testRegisterInterceptorParsesInheritedAndAnnotatedMetadata(){
		var obj                               = createObject( "component", "coldbox.tests.resources.ChildMetadataInterceptor" )
		mockCache.INTERCEPTOR_CACHEKEY_PREFIX = "sample"
		mockLogger.$( "canDebug", false )
		mockController.$( "getAspectsInitiated", false )

		iService.registerInterceptor( interceptorObject = obj, interceptorName = "childMetadataInterceptor" )

		assertTrue( isObject( iService.getStateContainer( "preProcess" ) ) )
		assertTrue( isObject( iService.getStateContainer( "postProcess" ) ) )
		assertTrue( isObject( iService.getStateContainer( "onCustomMetadata" ) ) )
		expect( iService.getInterceptionPointIndex() ).toHaveKey( "onCustomMetadata" )
	}

}
