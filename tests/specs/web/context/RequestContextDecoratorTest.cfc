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

			it( "does not take the this scope of the original context", function(){
				expect( mockContext.getMemento() ).notToHaveKey( "this" );
			} );

			it( "runs its inherited methods against its own mocks", function(){
				var context = new coldbox.system.web.context.RequestContext(
					properties = {
						defaultLayout     : "Main.cfm",
						defaultView       : "",
						folderLayouts     : {},
						viewLayouts       : {},
						eventName         : "event",
						sesBaseURL        : "http://localhost/index.cfm",
						registeredLayouts : {},
						modules           : {}
					},
					controller = mockController
				);
				var decorator = prepareMock(
					new coldbox.system.web.context.RequestContextDecorator( context, mockController )
				);
				decorator
					.$( "getHTTPHeader" )
					.$args( "x-forwarded-proto", "http" )
					.$results( "https" );
				// isSSL() calls getHTTPHeader() unscoped, which must reach the mock of the decorator
				expect( decorator.isSSL() ).toBeTrue();
			} );
		} );
	}

}
