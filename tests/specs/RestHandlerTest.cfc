component extends="coldbox.system.testing.BaseModelTest" {

	/*********************************** LIFE CYCLE Methods ***********************************/

	// executes before all suites+specs in the run() method
	function beforeAll(){
	}

	// executes after all suites+specs in the run() method
	function afterAll(){
	}

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "Response Object", function(){
			beforeEach( function( currentSpec ){
				handler            = createMock( "coldbox.system.RestHandler" ).$( "announce" ).$( "announceInterception" );
				mockController     = createMock( "coldbox.system.web.Controller" );
				flashScope         = createEmptyMock( "coldbox.system.web.flash.MockFlash" );
				mockRequestContext = createMock( "coldbox.system.web.context.RequestContext" ).init(
					{
						eventName    : "event",
						modules      : {},
						defaultLayout: "",
						defaultView  : ""
					},
					mockController
				);
				mockRS = createEmptyMock( "coldbox.system.web.services.RequestService" )
					.$( "getFlashScope", flashScope )
					.$( "getContext", mockRequestContext );
				mockLogger = createEmptyMock( "coldbox.system.logging.Logger" )
					.$( "warn" )
					.$( "canDebug", false )
					.$( "debug" )
					.$( "error" );
				mockLogBox   = createEmptyMock( "coldbox.system.logging.LogBox" ).$( "getLogger", mockLogger );
				mockCacheBox = createEmptyMock( "coldbox.system.cache.CacheFactory" );
				mockWireBox  = createEmptyMock( "coldbox.system.ioc.Injector" );

				mockController
					.$( "getRequestService", mockRS )
					.setLogBox( mockLogBox )
					.setWireBox( mockWireBox )
					.setCacheBox( mockCacheBox )
					.$( "getSetting" )
					.$args( "applicationHelper" )
					.$results( [] )
					.$( "getSetting" )
					.$args( "AppMapping" )
					.$results( "/coldbox/testing" )
					.$( "getSetting" )
					.$args( "debugMode", false )
					.$results( false );

				handler
					.init()
					.setCacheBox( mockCacheBox )
					.setController( mockController )
					.setFlash( flashScope )
					.setLogBox( mockLogBox )
					.setLog( mockLogger )
					.setWireBox( mockWirebox );
				handler.onHandlerDIComplete();
			} );

			it( "can be created", function(){
				expect( handler ).toBeComponent();
			} );

			it( "can handle onExpectationFailed", function(){
				makePublic( handler, "onExpectationFailed" );
				handler.onExpectationFailed();
				var response = handler.getRequestContext().getResponse();
				expect( response.getError() ).toBeTrue();
				expect( response.getStatusCode() ).toBe( 417 );
			} );

			it( "can handle onInvalidRoute", function(){
				handler.onInvalidRoute(
					mockRequestContext,
					mockRequestContext.getCollection(),
					mockRequestContext.getPrivateCollection()
				);
				var response = mockRequestContext.getResponse();
				expect( response.getError() ).toBeTrue();
				expect( response.getStatusCode() ).toBe( 404 );
			} );

			it( "can handle onAuthorizationFailure with no aborts", function(){
				handler.onAuthorizationFailure(
					mockRequestContext,
					mockRequestContext.getCollection(),
					mockRequestContext.getPrivateCollection()
				);
				var response = mockRequestContext.getResponse();
				expect( response.getError() ).toBeTrue();
				expect( response.getStatusCode() ).toBe( 403 );
			} );

			it( "can handle onAuthorizationFailure with cbsecurity results", function(){
				mockrequestContext.setPrivateValue(
					"cbSecurity_validatorResults",
					{ messages : "Invalid Access!" }
				);
				handler.onAuthorizationFailure(
					mockRequestContext,
					mockRequestContext.getCollection(),
					mockRequestContext.getPrivateCollection()
				);
				var response = mockRequestContext.getResponse();
				expect( response.getError() ).toBeTrue();
				expect( response.getStatusCode() ).toBe( 403 );
				expect( response.getMessagesString() ).toInclude( "Invalid Access!" );
			} );

			it( "can handle onAuthenticationFailure with no aborts", function(){
				handler.onAuthenticationFailure(
					mockRequestContext,
					mockRequestContext.getCollection(),
					mockRequestContext.getPrivateCollection()
				);
				var response = mockRequestContext.getResponse();
				expect( response.getError() ).toBeTrue();
				expect( response.getStatusCode() ).toBe( 401 );
			} );

			it( "can handle onAuthenticationFailure with cbsecurity expiration results", function(){
				mockrequestContext.setPrivateValue(
					"cbSecurity_validatorResults",
					{ messages : "Expired Token!" }
				);
				handler.onAuthenticationFailure(
					mockRequestContext,
					mockRequestContext.getCollection(),
					mockRequestContext.getPrivateCollection()
				);
				var response = mockRequestContext.getResponse();
				expect( response.getError() ).toBeTrue();
				expect( response.getStatusCode() ).toBe( 401 );
				expect( response.getMessagesString() ).toInclude( "Expired Authentication Credentials" );
			} );

			it( "can handle onMissingActions", function(){
				handler.onMissingAction(
					mockRequestContext,
					mockRequestContext.getCollection(),
					mockRequestContext.getPrivateCollection(),
					"bogus",
					{}
				);
				var response = mockRequestContext.getResponse();
				expect( response.getError() ).toBeTrue();
				expect( response.getStatusCode() ).toBe( 404 );
			} );

			it( "can handle onInvalidHTTPMethod", function(){
				handler.onInvalidHTTPMethod(
					mockRequestContext,
					mockRequestContext.getCollection(),
					mockRequestContext.getPrivateCollection(),
					"badAction",
					{}
				);
				var response = mockRequestContext.getResponse();
				expect( response.getError() ).toBeTrue();
				expect( response.getStatusCode() ).toBe( 405 );
			} );

			it( "can handle onEntityNotFoundException", function(){
				handler.onEntityNotFoundException(
					mockRequestContext,
					mockRequestContext.getCollection(),
					mockRequestContext.getPrivateCollection(),
					{}
				);
				var response = mockRequestContext.getResponse();
				expect( response.getError() ).toBeTrue();
				expect( response.getStatusCode() ).toBe( 404 );
			} );

			it( "can handle onValidationException", function(){
				handler.onValidationException(
					mockRequestContext,
					mockRequestContext.getCollection(),
					mockRequestContext.getPrivateCollection(),
					{},
					{ extendedInfo : serializeJSON( [ "Title is missing" ] ) }
				);
				var response = mockRequestContext.getResponse();
				expect( response.getError() ).toBeTrue();
				expect( response.getStatusCode() ).toBe( 400 );
			} );

			it( "can handle onError", function(){
				handler
					.$( "getSetting" )
					.$args( "environment" )
					.$results( "production" );
				handler.onError(
					mockRequestContext,
					mockRequestContext.getCollection(),
					mockRequestContext.getPrivateCollection(),
					"badAction",
					{
						message   : "Invalid syntax",
						detail    : "oooops!",
						stackTrace: callStackGet().toString()
					},
					{}
				);
				var response = mockRequestContext.getResponse();
				expect( response.getError() ).toBeTrue();
				expect( response.getStatusCode() ).toBe( 500 );
			} );
		} );
	}

}
