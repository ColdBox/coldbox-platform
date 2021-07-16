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
				handler            = createMock( "coldbox.system.RestHandler" );
				mockController     = createMock( "coldbox.system.web.Controller" );
				flashScope         = createEmptyMock( "coldbox.system.web.flash.MockFlash" );
				mockRequestContext = createMock( "coldbox.system.web.context.RequestContext" ).init(
					{
						eventName     : "event",
						modules       : {},
						defaultLayout : "",
						defaultView   : ""
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

				mockController.$( "getRequestService", mockRS );

				mockController.setLogBox( mockLogBox );
				mockController.setWireBox( mockWireBox );
				mockController.setCacheBox( mockCacheBox );

				mockController
					.$( "getSetting" )
					.$args( "applicationHelper" )
					.$results( [] )
					.$( "getSetting" )
					.$args( "AppMapping" )
					.$results( "/coldbox/testing" );

				handler.init( mockController );
			} );

			it( "can be created", function(){
				expect( handler ).toBeComponent();
			} );

			it( "can handle onExpectationFailed", function(){
				makePublic( handler, "onExpectationFailed" );
				handler.onExpectationFailed();
				var response = handler.getRequestContext().getResponse();
				expect( response.getError() ).toBeTrue();
				expect( response.getStatusText() ).toBe( "Expectation Failed" );
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
				expect( response.getStatusText() ).toBe( "Not Found" );
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
				expect( response.getStatusText() ).toBe( "Unauthorized Resource" );
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
				expect( response.getStatusText() ).toBe( "Unauthorized Resource" );
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
				expect( response.getStatusText() ).toBe( "Invalid or Missing Credentials" );
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
				expect( response.getStatusText() ).toBe( "Expired Authentication Credentials" );
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
				expect( response.getStatusText() ).toBe( "Invalid Action" );
				expect( response.getStatusCode() ).toBe( 405 );
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
				expect( response.getStatusText() ).toBe( "Invalid HTTP Method" );
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
				expect( response.getStatusText() ).toBe( "Not Found" );
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
				expect( response.getStatusText() ).toBe( "Invalid Request" );
				expect( response.getStatusCode() ).toBe( 400 );
			} );

			it( "can handle onError", function(){
				handler.onError(
					mockRequestContext,
					mockRequestContext.getCollection(),
					mockRequestContext.getPrivateCollection(),
					"badAction",
					{
						message    : "Invalid syntax",
						detail     : "oooops!",
						stackTrace : callStackGet().toString()
					},
					{}
				);
				var response = mockRequestContext.getResponse();
				expect( response.getError() ).toBeTrue();
				expect( response.getStatusText() ).toBe( "General application error" );
				expect( response.getStatusCode() ).toBe( 500 );
			} );
		} );
	}

}
