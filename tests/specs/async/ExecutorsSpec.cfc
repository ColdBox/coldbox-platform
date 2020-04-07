/**
 * My BDD Test
 */
component extends="testbox.system.BaseSpec" {

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
		describe( "Executors", function(){
			beforeEach( function( currentSpec ){
				executors = new coldbox.system.async.Executors();
			} );

			it( "can be created", function(){
				expect( executors ).toBeComponent();
			});

			story( "Ability to create different supported executors", function(){
				it( "can create a single thread executor", function(){
					var executor = executors.newSingleThreadPool();
					expect( executor.isTerminated() ).toBeFalse();
				});
				it( "can create a fixed pool executor", function(){
					var executor = executors.newFixedThreadPool( 10 );
					expect( executor.isTerminated() ).toBeFalse();
				});
				it( "can create a cached pool executor", function(){
					var executor = executors.newCachedThreadPool();
					expect( executor.isTerminated() ).toBeFalse();
				});
				it( "can create a scheduled pool executor", function(){
					var executor = executors.newScheduledThreadPool( 5 );
					expect( executor.isTerminated() ).toBeFalse();
				});
			});

		} );
	}

}
