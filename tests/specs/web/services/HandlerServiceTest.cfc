/**
 * Request Context Decorator
 */
component extends="tests.resources.BaseIntegrationTest" {

	function run( testResults, testBox ){
		describe( "Handler Service", function(){
			beforeEach( function(){
				setup();
				handlerService = controller.getHandlerService();
			} );

			it( "can register handlers", function(){
				handlerService.registerHandlers();

				expect( getController().getSetting( "registeredHandlers" ) ).notToBeEmpty();
				expect( getController().getSetting( "registeredExternalHandlers" ) ).notToBeEmpty();
			} );

			it( "can recurse handler listings", function(){
				var path = expandPath( "/coldbox/test-harness/handlers" );
				makePublic( handlerService, "getHandlerListing" );

				var files = handlerService.getHandlerListing( path );
				expect( files ).notToBeEmpty();
				expect( files.len() ).toBeGT( 10 );
			} );

			describe( "Retrieve handler beans", function(){
				beforeEach( function(){
					handlerService.setHandlerCaching( true );
				} );

				it( "with an invalid event", function(){
					var results = handlerService.getHandlerBean( "invalid" );
					expect( results.getMethod() ).toBe( "onInvalidEvent" );
					expect( handlerService.getHandlerBeanCacheDictionary() ).notToHaveKey( "invalid" );
				} );

				it( "with a valid handler event", function(){
					var results = handlerService.getHandlerBean( "main.index" );
					expect( results.getMethod() ).toBe( "index" );
					expect( results.getHandler() ).toBe( "main" );
					expect( handlerService.getHandlerBeanCacheDictionary() ).toHaveKey( "main.index" );
				} );

				it( "with a valid external handler event", function(){
					var results = handlerService.getHandlerBean( "ehTest.dspExternal" );
					expect( results.getMethod() ).toBe( "dspExternal" );
					expect( results.getHandler() ).toBe( "ehTest" );
					expect( handlerService.getHandlerBeanCacheDictionary() ).toHaveKey( "ehTest.dspExternal" );
				} );

				it( "with a valid module Event", function(){
					var results = handlerService.getHandlerBean( "resourcesTest:Home.index" );
					expect( results.getMethod() ).toBe( "index" );
					expect( results.getHandler() ).toBe( "Home" );
					expect( results.getModule() ).toBe( "resourcesTest" );
					expect( handlerService.getHandlerBeanCacheDictionary() ).toHaveKey(
						"resourcesTest:Home.index"
					);
				} );

				it( "with a valid view dispatch", function(){
					var results = handlerService.getHandlerBean( "simpleview" );
					expect( results.getViewDispatch() ).toBe( true );
					expect( handlerService.getHandlerBeanCacheDictionary() ).toHaveKey( "simpleview" );
				} );
			} );
		} );
	}

}
