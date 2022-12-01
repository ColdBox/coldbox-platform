/**
 * Baser Interceptor Test
 */
component extends="coldbox.system.testing.BaseInterceptorTest" interceptor="cbtestharness.interceptors.Test1"{

/*********************************** LIFE CYCLE Methods ***********************************/

	/**
	 * executes before all suites+specs in the run() method
	 */
	function beforeAll(){

	}

	/**
	 * executes after all suites+specs in the run() method
	 */
	function afterAll(){

	}

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "Test 1 Interceptor Test", function(){

			beforeEach(function( currentSpec ){
				setup();
			});

			it( "It can be created", function(){
				expect( interceptor ).toBeComponent();
			} );

		} );
	}

}
