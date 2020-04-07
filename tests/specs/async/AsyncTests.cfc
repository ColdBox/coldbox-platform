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

			it( "can run a cf closure with a then/get pipeline and custom executors", function(){
				var singlePool = asyncManager.executors.newSingleThreadPool();
				var f = asyncManager
					.newFuture()
					.runAsync( function(){
						debug( "runAsync: " & getThreadName() );
						var message = "hello from in closure land";
						createObject( "java", "java.lang.System" ).out.println( message );
						debug( "Hello debugger" );

						sleep( randRange( 1, 1000 ) );

						return "Luis";
					} )
					.then( function( result ){
						debug( "then: " & getThreadName() );
						return arguments.result & " majano";
					} )
					// Run this in a separate thread
					.thenAsync( function( result ){
						debug( "thenAsync: " & getThreadName() );
						return arguments.result & " loves threads, NOT!";
					}, singlePool );

				expect( f.get(), "Luis majano loves threads, NOT!" );
				expect( f.isDone() ).toBeTrue();
			} );

			it( "can cancel a long-running future", function(){
				var future = asyncManager.newFuture();
				var results = future.run( function(){
					sleep( 5000 );
				}).cancel();
				expect( results ).toBeTrue();
				expect( future.isCancelled() ).toBeTrue();
			});

			it( "can complete a future explicitly", function(){
				var f = asyncManager.newFuture();
				f.complete( 100 );
				expect(
					f.get()
				).toBe( 100 );

				expect(
					asyncManager.newCompletedFuture( 200 ).get()
				).toBe( 200 );

				expect(
					asyncManager.newFuture().completedFuture( 400 ).get()
				).toBe( 400 );
			});

			it( "can complete with a custom exception", function(){
				var f = asyncManager.newFuture().completeExceptionally();
				expect( function(){
					f.get();
				} ).toThrow();
				expect( f.isCompletedExceptionally() ).toBeTrue();
			});

			it( "can get the results now", function(){
				var future = asyncManager.newFuture().run( function(){
					return 1;
				});
				sleep( 500 );
				expect( future.getNow( 2 ) ).toBe( 1 );

				var future = asyncManager.newFuture().run( function(){
					sleep( 2000 );
					return 1;
				});
				expect( future.getNow( 2 ) ).toBe( 2 );
			});

			it( "can register an exception handler ", function(){
				var future = asyncManager.newFuture()
					.supplyAsync( function(){
						if( age < 0 ){
							throw( type="IllegalArgumentException" );
						}
						if(age > 18) {
							return "Adult";
						} else {
							return "Child";
						}
					} ).exceptionally( function( ex ){
						//debug( ex);
						debug( "Oops we have an exception: #ex.toString()#" );
						return "Who Knows!";
					} );
					expect( future.get() ).toBe( "Who Knows!" );
			});

			it( "can combine two futures together into a single result", function(){
				if( !server.keyExists( "lucee" ) ){
					// ACF is inconsistent, I have no clue why.
					// Combining futures for some reason fails on ACF
					return;
				}

				var getCreditRating = function( user ){
					return asyncManager.newFuture().run( function(){
						// I would use the user here :!
						return 800;
					} );
				};
				var creditFuture = asyncManager.newFuture()
					.run( function(){
						// lookup user
						return {
							id : now(),
							name : "luis majano"
						};
					} ).thenCompose( function( user ){
						return getCreditRating( arguments.user );
					} );

				expect( creditFuture.get() ).toBe( 800 );
			});

			story( "Ability to create and manage schedulers", function(){
				it( "can create a vanilla schedule", function(){
					var schedule = asyncManager.newSchedule( "unitTest" );
					expect( schedule.getName() ).toBe( "unitTest" );
				});
				it( "can create a schedule with a custom name", function(){
					var schedule = asyncManager.newSchedule( "unitTest", 10 );
					expect( schedule.getName() ).toBe( "unitTest" );
					expect( schedule.getExecutor().getCorePoolSize() ).toBe( 10 );
				});
				it( "can retrieve a created schedule", function(){
					var schedule = asyncManager.newSchedule( "unitTest" );
					expect( asyncManager.getSchedule( "unitTest" ) ).toBeComponent();
				});
				it( "will throw an exception when getting an invalid schedule", function(){
					expect( function(){
						asyncManager.getSchedule( "bogus" );
					} ).toThrow( type="ScheduleNotFoundException" );
				});
				it( "can retrieve the schedule key names", function(){
					expect( asyncManager.getScheduleNames() ).toBeEmpty();
					var schedule = asyncManager.newSchedule( "unitTest" );
					expect( asyncManager.getScheduleNames() ).toInclude( "unitTest" );
				});
				it( "can verify if a scheduler exists", function(){
					expect( asyncManager.hasSchedule( "bogus" ) ).toBeFalse();
					var schedule = asyncManager.newSchedule( "unitTest" );
					expect( asyncManager.hasSchedule( "unitTest" ) ).toBeTrue();
				});
				it( "can delete an existing schedule", function(){
					var schedule = asyncManager.newSchedule( "unitTest" );
					asyncManager.deleteSchedule( "unitTest" );
					expect( asyncManager.hasSchedule( "unitTest" ) ).toBeFalse();
				});
				it( "can delete a non-existing schedule", function(){
					asyncManager.deleteSchedule( "bogusTest" );
				});
				it( "can shutdown all schedules", function(){
					var schedule1 = asyncManager.newSchedule( "unitTest1" );
					var schedule2 = asyncManager.newSchedule( "unitTest2" );

					asyncManager.shutdownAllSchedules();

					expect( schedule1.isShutdown() ).toBeTrue();
					expect( schedule2.isShutdown() ).toBeTrue();
				});
				it( "can retrieve the schedule status map", function(){
					var schedule1 = asyncManager.newSchedule( "unitTest1" );
					var schedule2 = asyncManager.newSchedule( "unitTest2" );

					var statusMap = asyncManager.getScheduleStatusMap();

					expect( statusMap )
						.toHaveKey( "unitTest1" )
						.toHaveKey( "unitTest2" );
				});

			});

		} );
	}

	/**
	 * Get the current thread name
	 */
	private function getThreadName(){
		return getCurrentThread().getName();
	}

	/**
	 * Get the current thread java object
	 */
	private function getCurrentThread(){
		return createObject( "java", "java.lang.Thread" ).currentThread();
	}

}