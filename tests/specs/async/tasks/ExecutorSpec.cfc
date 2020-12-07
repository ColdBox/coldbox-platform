/**
 * My BDD Test
 */
component extends="tests.specs.async.BaseAsyncSpec" {

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "ColdBox Executor Spec", function(){
			beforeEach( function( currentSpec ){
				asyncManager = new coldbox.system.async.AsyncManager();
			} );

			story( "Ability to process stats for different executors", function(){
				it( "can get stats for a fixed executor", function(){
					var executor = asyncManager.newExecutor( "unitTest" );
					expect( executor.getStats() ).toBeStruct();
				} );
				it( "can get stats for a single executor", function(){
					var executor = asyncManager.newExecutor( name: "unitTest", type: "single" );
					expect( executor.getStats() ).toBeStruct();
				} );
				it( "can get stats for a cached executor", function(){
					var executor = asyncManager.newExecutor( name: "unitTest", type: "cached" );
					expect( executor.getStats() ).toBeStruct();
				} );
				it( "can get stats for a scheduled executor", function(){
					var executor = asyncManager.newExecutor( name: "unitTest", type: "scheduled" );
					expect( executor.getStats() ).toBeStruct();
				} );
			} );

			story( "Ability to submit tasks into the executor", function(){
				it( "can execute a submitted closure task", function(){
					var myExecutor = asyncManager.newExecutor( "unitTest" );
					var future     = myExecutor.submit( function(){
						toConsole( "running hello task from:#getThreadName()#" );
						return "hello";
					} );

					expect( future.get() ).toBe( "hello" );
					expect( future.isCancelled() ).toBeFalse();
					expect( future.isDone() ).toBeTrue();
				} );
				it( "can execute a submitted CFC task", function(){
					var myExecutor = asyncManager.newExecutor( "unitTest" );
					var task       = createStub()
						.$( "run" )
						.$callback( function(){
							toConsole( "running from a CFC in:#getThreadName()#" );
							return "cfc";
						} );

					var future = myExecutor.submit( task );

					expect( future.get() ).toBe( "cfc" );
					expect( future.isCancelled() ).toBeFalse();
					expect( future.isDone() ).toBeTrue();
				} );
				it( "can execute a submitted CFC task with a different method name", function(){
					var myExecutor = asyncManager.newExecutor( "unitTest" );
					var task       = createStub()
						.$( "reapCache" )
						.$callback( function(){
							toConsole( "running from the cache reaper in:#getThreadName()#" );
							return "cache";
						} );

					var future = myExecutor.submit( task, "reapCache" );

					expect( future.get() ).toBe( "cache" );
					expect( future.isCancelled() ).toBeFalse();
					expect( future.isDone() ).toBeTrue();
				} );

				it( "can execute and cancel a submitted task", function(){
					var myExecutor = asyncManager.newExecutor( "unitTest" );
					var future     = myExecutor.submit( function(){
						toConsole( "running hello task from:#getThreadName()#" );
						sleep( 5000 );
						return "hello";
					} );

					future.cancel();

					expect( future.isCancelled() ).toBeTrue();
					expect( future.isDone() ).toBeTrue();
					expect( function(){
						future.get();
					} ).toThrow();
				} );

				it( "can execute and get with a timeout", function(){
					var myExecutor = asyncManager.newExecutor( "unitTest" );
					var future     = myExecutor.submit( function(){
						toConsole( "running hello task from:#getThreadName()#" );
						sleep( 2000 );
						return "hello";
					} );

					var results = future.get( 100, "milliseconds", "timeout" );

					expect( future.isCancelled() ).toBeFalse( "cancelled" );
					expect( future.isDone() ).toBeFalse( "done" );
					expect( results ).toBe( "timeout" );
				} );
			} );
		} );
	}

}
