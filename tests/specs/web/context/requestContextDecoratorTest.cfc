/**
 * Request Context Decorator
 */
component extends="tests.resources.BaseIntegrationTest" {

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
		describe( "Request context decorator", function(){
			beforeEach( function( currentSpec ){
				mockContext    = getMockRequestContext();
				mockController = getMockController();

				mockDecorator = new coldbox.system.web.context.RequestContextDecorator(
					mockContext,
					mockController
				);
			} );

			it( "can be created", function(){
				expect( mockContext ).toBe( mockDecorator.getRequestContext() );
			} );

			it( "can have a reference to its controller", function(){
				makePublic( mockDecorator, "getController" );
				expect( mockController ).toBe( mockDecorator.getController() );
			} );
		} );
	}

}
