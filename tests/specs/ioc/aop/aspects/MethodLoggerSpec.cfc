/**
 * My BDD Test
 */
component extends="coldbox.system.testing.BaseModelTest" model="coldbox.system.aop.aspects.MethodLogger" {

	/*********************************** LIFE CYCLE Methods ***********************************/

	// executes before all suites+specs in the run() method
	function beforeAll(){
		super.setup();
		model.init();
		// mockings
		mockLogger = createEmptyMock( "coldbox.system.logging.Logger" )
			.$( "canDebug", true )
			.$( "error" )
			.$( "debug" );

		model.$property( "log", "variables", mockLogger );
	}

	// executes after all suites+specs in the run() method
	function afterAll(){
		super.afterAll();
	}

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "Method Logger aspect", function(){
			it( "can log execution calls", function(){
				var mockInvocation = createMock( "coldbox.system.aop.MethodInvocation" )
					.init(
						method         = "execute",
						args           = { name : "luis majano" },
						methodMetadata = "{}",
						target         = this,
						targetname     = "mymock",
						targetMapping  = "mymock",
						interceptors   = []
					)
					.$( "proceed", "called" );

				var results = model.invokeMethod( mockInvocation );
				expect( results ).toBe( "called" );
				expect( mockLogger.$times( 2, "debug" ) ).toBeTrue();
			} );
		} );
	}

}
