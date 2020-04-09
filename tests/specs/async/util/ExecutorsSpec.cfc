/**
 * My BDD Test
 */
component extends="tests.specs.async.BaseAsyncSpec"{

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "Executors", function(){
			beforeEach( function( currentSpec ){
				executors = new coldbox.system.async.util.Executors();
			} );

			it( "can be created", function(){
				expect( executors ).toBeComponent();
			});

			story( "Ability to create different supported executors", function(){
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
