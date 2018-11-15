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
					.$( "getSetting" )
						.$args( "HandlersPath" )
						.$results( expandPath('/coldbox/test-harness/handlers') )
					.$( "getSetting" )
						.$args( "HandlersInvocationPath" )
						.$results( "coldbox.test-harness.handlers" )
					.$( "getSetting" )
						.$args( "HandlersExternalLocationPath" )
						.$results( [ expandPath('/coldbox/test-harness/external/testHandlers') ] )
					.$( "getSetting" )
						.$args( "HandlersExternalLocation" )
						.$results( [ "coldbox.test-harness.external.testHandlers'" ] )
					.$( "setSetting" );

				var handlers = [ {name="ehGeneral",actions=[ "index" ]}, {name="blog",actions=[ "index" ]} ];
				var expected = [ "blog", "ehGeneral" ];
				handlerService.$( "gethandlerListing", handlers );

				handlerService.registerHandlers();

				var actual = listToArray( mockController.$callLog().setSetting[ 1 ].value );
				arraySort( actual, "textnocase" );
				expect( actual ).toBe( expected );
			} );

			it( "can recurse handler listings", function(){
				var path = expandPath( "/coldbox/test-harness/handlers" );
				makePublic( handlerService, "getHandlerListing" );

				var files = handlerService.getHandlerListing( path, "coldbox.test-harness.handlers" );
				expect( files ).notToBeEmpty();
			} );
		} );
	}

}