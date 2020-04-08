/**
 * My BDD Test
 */
component extends="BaseAsyncSpec"{

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "ColdBox Async Schedulers", function(){
			beforeEach( function( currentSpec ){
				asyncManager = new coldbox.system.async.AsyncManager();
			} );

			story( "Ability to create and execute different schedules", function(){

				it( "can schedule with no options", function(){
					var sFuture = asyncManager
						.newSchedule( "unitTest" )
							.schedule( function(){
								toConsole( "running hello task from:#getThreadName()#" );
								return "hello";
							} );
					expect( sFuture.get() ).toBe( "hello" );
				});

				it( "can schedule with a delay", function(){
					var sFuture = asyncManager
						.newSchedule( "unitTest" )
							.delay( 500 )
							.inMilliseconds()
							.schedule( function(){
								toConsole( "running hello task with delay from:#getThreadName()#" );
								return "hello";
							} );
					expect( sFuture.get() ).toBe( "hello" );
				});

				it( "can schedule with a time period and be able to shutdown", function(){
					var atomicLong = createObject( "java", "java.util.concurrent.atomic.AtomicLong" ).init( 0 );
					var sFuture = asyncManager
						.newSchedule( "unitTest" )
							.every( 250, "milliseconds" )
							.schedule( function(){
								var results = atomicLong.incrementAndGet();
								toConsole( "running periodic task (#results#) from:#getThreadName()#" );
							} );
					try{
						expect( sFuture.isPeriodic() ).toBeTrue();
						for( var x=0; x lte 3; x++ ){
							sleep( 750 );
							toConsole( "atomic is " & atomicLong.get() );
							expect( sFuture.isDone() ).toBeFalse();
							expect( sFuture.isCancelled() ).toBeFalse();
							toConsole( asyncManager.getSchedule( "unitTest" ).getStats() );
						}
					} finally {
						toConsole( "xxxxx => shutting down task..." );
						sFuture.cancel();

						expect( sFuture.isDone() ).toBeTrue();
						expect( sFuture.isCancelled() ).toBeTrue();

						asyncManager.deleteSchedule( "unitTest" );

						toConsole( "xxxxx => task done" );
					}
				});


				fit( "can create a task scheduling queue", function(){
					var queue = asyncManager.newSchedule( "unitQueue", 20 );
					var atomicLong = createObject( "java", "java.util.concurrent.atomic.AtomicLong" ).init( 0 );
					var results = [];
					try{
						// Submit 50 tasks
						for( var x=0; x < 50; x++ ){
							results.append(
									queue.submit( function(){
									var results = atomicLong.incrementAndGet();
									toConsole( "running queue task (#results#) from:#getThreadName()#..." );
									sleep( randRange( 300, 1000 ) );
									//toConsole( "finished queue task (#results#) from:#getThreadName()#..." );
									// process some data
									return results;
								} )
							);
						}

						while( queue.getActiveCount() ){
							toConsole( "===> Waiting for tasks to complete..." );
							sleep( 500 );
							toConsole( queue.getStats() );
						}

					} finally {
						queue.shutdownNow();
						toConsole( queue.getStats() );
						toConsole(
							results.map( function( item ){
								return item.get();
							} )
						);
					}
				});

			} );

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

}
