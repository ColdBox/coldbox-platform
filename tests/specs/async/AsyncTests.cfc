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

			story( "Ability to create schedulers", function(){
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

					var statusMap = asyncManager.getScheduleStatusMap()

					expect( statusMap )
						.toHaveKey( "unitTest1" )
						.toHaveKey( "unitTest2" );
				});

			});
		} );
	}

}
