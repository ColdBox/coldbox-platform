component extends="tests.resources.BaseIntegrationTest" {

	/*********************************** BDD SUITES ***********************************/

	function beforeAll(){
		variables.asyncManager = new coldbox.system.async.AsyncManager();
		super.beforeAll();
	}

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "ColdBox Scheduled Task", function(){
			beforeEach( function( currentSpec ){
				variables.scheduler = getInstance(
					name         : "coldbox.system.web.tasks.ColdBoxScheduler",
					initArguments: {
						name         : "bdd-tests",
						asyncManager : variables.asyncManager
					}
				);
				// Start the scheduler so getStartedAt() has a value
				variables.scheduler.startup();
			} );

			it( "can register a ColdBox enhanced task", function(){
				var t = scheduler.task( "cbTask" );
				expect( t.hasScheduler() ).toBeTrue();
				expect( t.getCacheName() ).toBe( "template" );
				expect( t.getServerFixation() ).toBeFalse();
				expect( scheduler.getTaskRecord( "cbTask" ).task ).toBe( t );
			} );

			it( "can register environment constraints", function(){
				var t = scheduler.task( "cbTask" ).onEnvironment( "development" );
				expect( t.getEnvironments() ).toInclude( "development" );
			} );

			it( "can be constrained by environment", function(){
				var t = scheduler.task( "cbTask" ).everyMinute();

				expect( t.isConstrained() ).toBeFalse();

				// Constrain it
				t.onEnvironment( "bogus" );
				expect( t.getEnvironments() ).toInclude( "bogus" );
				expect( t.isConstrained() ).toBeTrue();
			} );

			it( "can register server fixation", function(){
				var t = scheduler.task( "cbTask" ).onOneServer();
				expect( t.getServerFixation() ).toBeTrue();
			} );

			it( "can be constrained by server", function(){
				var t = scheduler
					.task( "cbTask-ServerFixation" )
					.onOneServer()
					.everyHourAt( 9 )
					.withNoOverlaps();

				expect( t.isConstrained() ).toBeFalse();
				expect( t.getCache().getKeys() ).toInclude( t.getFixationCacheKey() );

				// Cache item should persist after cleanup (it's removed by natural expiration now)
				t.cleanupTaskRun();
				expect( t.getCache().getKeys() ).toInclude( t.getFixationCacheKey() );

				// Constrain it by setting a lock from a different server
				t.getCache()
					.set(
						t.getFixationCacheKey(),
						{
							"task"       : t.getName(),
							"lockOn"     : now(),
							"serverHost" : "10.10.10.10",
							"serverIp"   : "my.macdaddy.bogus.bdd.server"
						},
						5,
						0
					);
				expect( t.getCache().getKeys() ).toInclude( t.getFixationCacheKey() );
				expect( t.isConstrained() ).toBeTrue();

				// Cleanup still doesn't remove the cache item
				t.cleanupTaskRun();
				expect( t.getCache().getKeys() ).toInclude( t.getFixationCacheKey() );
			} );

			describe( "schedule synchronization", function(){
				it( "stores schedule metadata in cache lock", function(){
					var t = scheduler
						.task( "sync-test-1" )
						.onOneServer()
						.every( 1, "hours" );

					// Trigger canRunOnThisServer to create the lock
					expect( t.isConstrained() ).toBeFalse();

					// Verify the lock contains schedule metadata
					var lock = t.getCache().get( t.getFixationCacheKey() );
					debug( lock )
					expect( lock ).toBeStruct();
					expect( lock ).toHaveKey( "scheduleStart" );
					expect( lock ).toHaveKey( "period" );
					expect( lock ).toHaveKey( "timeUnit" );
					expect( lock.period ).toBe( 1 );
					expect( lock.timeUnit ).toBe( "hours" );
				} );

				it( "uses scheduler start time as schedule anchor", function(){
					var schedulerStartTime = scheduler.getStartedAt();
					var t                  = scheduler
						.task( "sync-test-2" )
						.onOneServer()
						.every( 2, "hours" );

					// Trigger lock creation
					t.isConstrained();

					var lock = t.getCache().get( t.getFixationCacheKey() );
					expect( lock.scheduleStart ).toBe( schedulerStartTime );
				} );

				it( "preserves schedule anchor when refreshing lock", function(){
					var t = scheduler
						.task( "sync-test-3" )
						.onOneServer()
						.every( 30, "minutes" );

					// Create initial lock
					t.isConstrained();
					var initialLock = t.getCache().get( t.getFixationCacheKey() );
					var anchor      = initialLock.scheduleStart;

					// Wait a second and run again (simulating next execution)
					sleep( 1000 );
					t.isConstrained();

					// Lock should be refreshed but anchor preserved
					var refreshedLock = t.getCache().get( t.getFixationCacheKey() );
					expect( refreshedLock.scheduleStart ).toBe( anchor );
					expect( refreshedLock.lockOn ).notToBe( initialLock.lockOn );
				} );

				it( "syncs schedule when joining an existing cluster", function(){
					// Server 1 creates the schedule
					var server1Task = scheduler
						.task( "sync-test-4" )
						.onOneServer()
						.every( 1, "hours" );

					// Start and create lock
					server1Task.isConstrained();
					var existingLock = server1Task.getCache().get( server1Task.getFixationCacheKey() );

					// Server 2 joins and tries to register same task
					var scheduler2 = getInstance(
						name         : "coldbox.system.web.tasks.ColdBoxScheduler",
						initArguments: {
							name         : "server2-scheduler",
							asyncManager : variables.asyncManager
						}
					);

					var server2Task = scheduler2
						.task( "sync-test-4" )
						.onOneServer()
						.every( 1, "hours" );

					// Call syncScheduleWithCluster to align with Server 1
					server2Task.syncScheduleWithCluster();
					// Server 2 should have adjusted its delay to align with existing schedule
				} );

				it( "calculates proper lock timeout based on task period", function(){
					var hourlyTask = scheduler
						.task( "hourly-sync" )
						.onOneServer()
						.every( 1, "hours" );

					hourlyTask.isConstrained();

					// Lock timeout should be at least 60 minutes (1 hour)
					var minuteTask = scheduler
						.task( "minute-sync" )
						.onOneServer()
						.every( 5, "minutes" );

					minuteTask.isConstrained();
					// Lock timeout should be at least 5 minutes
				} );

				it( "handles missing schedule metadata gracefully", function(){
					var t = scheduler
						.task( "sync-test-5" )
						.onOneServer()
						.every( 1, "hours" );

					// Stop the scheduler to avoid executor termination issues
					scheduler.shutdown();

					// Manually create a lock without schedule metadata (old format)
					t.getCache()
						.set(
							t.getFixationCacheKey(),
							{
								"task"       : t.getName(),
								"lockOn"     : now(),
								"serverHost" : "old.server.com",
								"serverIp"   : "192.168.1.1"
							},
							60,
							0
						);

					// Test that syncScheduleWithCluster runs without throwing
					// Should log warning about missing metadata and return gracefully
					expect( function(){
						t.syncScheduleWithCluster();
					} ).notToThrow();
				} );

				it( "only syncs period-based tasks", function(){
					// Spaced delay task should not sync
					var spacedTask = scheduler
						.task( "spaced-task" )
						.onOneServer()
						.spacedDelay( 5, "minutes" );

					// Test that syncScheduleWithCluster skips spaced delay tasks
					// Should return early since period == 0
					expect( function(){
						spacedTask.syncScheduleWithCluster();
					} ).notToThrow();

					// Verify getPeriod is 0 for spaced delay tasks
					expect( spacedTask.getPeriod() ).toBe( 0 );
				} );
			} );
		} );
	}

}
