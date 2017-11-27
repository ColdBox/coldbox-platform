/**
* Request Context Decorator
*/
component extends="coldbox.system.testing.BaseModelTest"{
	
/*********************************** LIFE CYCLE Methods ***********************************/

	// executes before all suites+specs in the run() method
	function beforeAll(){
		super.beforeAll();
		
		mockController = createMock( className="coldbox.system.web.Controller" );
		mockController.setUtil( new coldbox.system.core.util.Util() );

		mockInterceptorService 	= createMock( className="coldbox.system.web.services.InterceptorService", clearMethods=true );
		mockEngine     			= createEmptyMock( className="coldbox.system.core.util.CFMLEngine" );

		mockController.$( "getInterceptorService", mockInterceptorService )
			.$( "getCFMLEngine", mockEngine );
	}

	// executes after all suites+specs in the run() method
	function afterAll(){
		super.afterAll();
	}

/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		describe( "Handler Service", function(){
			
			beforeEach( function(){
				handlerService = createMock( classname="coldbox.system.web.services.HandlerService" ).init( mockController );
			} );

			it( "can register handlers", function(){
				// Mocks
				mockController
					.$("getSetting")
						.$args("HandlersPath")
						.$results( expandPath('/coldbox/test-harness/handlers') )
					.$("getSetting")
						.$args("HandlersExternalLocationPath")
						.$results( expandPath('/coldbox/test-harness/external/testHandlers') )
					.$( "setSetting" );
				
				var handlers = [ "ehGeneral", "blog" ];
				handlerService.$( "gethandlerListing", handlers );

				handlerService.registerHandlers();

				//debug(mockController.$callLog().setSetting[1]);
				expect( mockController.$callLog().setSetting[ 1 ].value ).toBe( arrayToList( handlers ) );
				expect( mockController.$callLog().setSetting[ 2 ].value ).toBe( arrayToList( handlers ) );
			} );

			it( "can recurse handler listings", function(){
				var path = expandPath( "/coldbox/test-harness/handlers" );
				makePublic( handlerService, "getHandlerListing" );

				var files = handlerService.getHandlerListing( path );
				expect( files ).notToBeEmpty();
			} );
		} );
	}

}