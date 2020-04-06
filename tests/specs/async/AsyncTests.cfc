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
		describe( "ColdBox Async Programming", function(){
			beforeEach( function( currentSpec ){
				asyncManager = new coldbox.system.async.AsyncManager( debug=true );
			} );

			it( "can run a closure with a ColdBox Future", function(){
				var f = asyncManager
					.newFuture()
					.run( function(){
						var message = "hello from in closure land";
						createObject( "java", "java.lang.System" ).out.println( message );
						debug( "Hello debugger" );

						sleep( 1000 );

						return "Luis";
					} )
					.then( function( result ){
						return result & " majano";
					} )
					.then( function( result ){
						return result & " loves threads, NOT!";
					} );

				expect( f.get(), "Luis majano loves threads, NOT!" );
			} );


			story( "Ability to create executors", function(){
				it( "can create a single thread executor", function(){
					var executor = asyncManager.newSingleThreadPool();
					expect( executor.isTerminated() ).toBeFalse();
				});
				it( "can create a fixed pool executor", function(){
					var executor = asyncManager.newFixedThreadPool( 10 );
					expect( executor.isTerminated() ).toBeFalse();
				});

			});

			xstory( "Ability to create schedulers", function(){

				it( "can create a vanilla schedule", function(){

				});

				it( "can retrieve a created schedule", function(){
				});

				it( "will throw an exception when getting an invalid schedule", function(){
				});

				it( "can retrieve the schedule key names", function(){
				});

				it( "can verify if a scheduler exists", function(){
					expect( asyncManager.hasSchedule( "bogus" ) ).toBeFalse();
				});

				it( "can delete an existing schedule", function(){

				});
				it( "can delete a non-existing schedule", function(){

				});

				it( "can shutdown all schedules", function(){

				});

				it( "can retrieve the schedule status map", function(){
				});

			});
		} );
	}

}
