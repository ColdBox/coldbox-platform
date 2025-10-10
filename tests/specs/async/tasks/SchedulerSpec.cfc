/**
 * Duration Specs
 */
component extends="tests.specs.async.BaseAsyncSpec" {

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "Scheduler Spec", function(){
			beforeEach( function( currentSpec ){
				asyncManager = new coldbox.system.async.AsyncManager();
				scheduler    = asyncManager.newScheduler( "bdd-test" );
			} );

			it( "can be created", function(){
				expect( scheduler ).toBeComponent();
				expect( scheduler.getName() ).toBe( "bdd-test" );
				expect( scheduler.getExecutor() ).toBeComponent();
				expect( scheduler.getExecutor().getName() ).toBe( "bdd-test-scheduler" );
			} );

			it( "can set a new timezone", function(){
				scheduler.setTimezone( "America/New_York" );
				expect( scheduler.getTimezone().toString() ).toBe( "America/New_York" );
			} );

			it( "can register a new task and get it's record", function(){
				var task = scheduler.task( "bddTest" );
				expect( scheduler.hasTask( "bddTest" ) ).toBeTrue();
				expect( scheduler.getRegisteredTasks() ).toInclude( "bddTest" );
				expect( scheduler.getTaskRecord( "bddTest" ).task.getName() ).toBe( "bddTest" );
			} );

			it( "can throw an exception on getting a bogus task record", function(){
				expect( function(){
					scheduler.getTaskRecord( "bogus" );
				} ).toThrow();
			} );

			it( "can remove a task", function(){
				var task = scheduler.task( "bddTest" );
				expect( scheduler.hasTask( "bddTest" ) ).toBeTrue();
				scheduler.removeTask( "bddTest" );
				expect( scheduler.hasTask( "bddTest" ) ).toBeFalse();
			} );

			it( "can throw an exception on removing a non-existent task", function(){
				expect( function(){
					scheduler.removeTask( "bogus" );
				} ).toThrow();
			} );

			it( "can register and run the tasks with life cycle methods", function(){
				var atomicLong = createObject( "java", "java.util.concurrent.atomic.AtomicLong" ).init( 0 );

				// Register two one-time tasks
				scheduler
					.task( "test1" )
					.call( function(){
						var results = atomicLong.incrementAndGet();
						toConsole( "Running test1 (#results#) from:#getThreadName()#" );
						return results;
					} )
					.before( function( task ){
						toConsole( "I am about to run baby!" );
					} )
					.after( function( task, results ){
						toConsole( "this task is done baby!" );
					} )
					.onFailure( function( task, exception ){
						toConsole( "we blew up: #exception.message#" );
					} )
					.onSuccess( function( task, results ){
						toConsole( "Task has completed with success baby! #results.toString()#" );
					} );

				scheduler
					.task( "test2" )
					.call( function(){
						var results = atomicLong.incrementAndGet();
						toConsole( "Running test2 (#results#) from:#getThreadName()#" );
					} );

				scheduler
					.task( "test3" )
					.call( function(){
						var results = atomicLong.incrementAndGet();
						toConsole( "Running test3 (#results#) from:#getThreadName()#" );
					} )
					.disable();

				// Startup the scheduler
				try {
					expect( scheduler.hasStarted() ).toBeFalse();
					scheduler.startup();
					expect( scheduler.hasStarted() ).toBeTrue();

					var record = scheduler.getTaskRecord( "test1" );
					expect( record.future ).toBeComponent();
					expect( record.scheduledAt ).notToBeEmpty();

					var record = scheduler.getTaskRecord( "test2" );
					expect( record.future ).toBeComponent();
					expect( record.scheduledAt ).notToBeEmpty();

					var record = scheduler.getTaskRecord( "test3" );
					expect( record.disabled ).toBeTrue();
					expect( record.future ).toBeEmpty();
					expect( record.scheduledAt ).toBeEmpty();

					// Wait for them to execute
					sleep( 1000 );
					var stats = scheduler.getTaskStats();

					// debug( scheduler.getTasks() );
					// debug( stats );

					expect( stats.test1.neverRun ).toBeFalse( "test 1 neverRun" );
					expect( stats.test2.neverRun ).toBeFalse( "test 2 neverRun" );
					expect( stats.test3.neverRun ).toBeTrue( "test 3 neverRun" );

					expect( stats.test1.totalRuns ).toBe( 1, "test1 totalRuns" );
					expect( stats.test2.totalRuns ).toBe( 1, "test2 totalRuns" );
					expect( stats.test3.totalRuns ).toBe( 0, "test3 totalRuns" );
				} finally {
					sleep( 1000 );
					scheduler.shutdown();
					expect( scheduler.hasStarted() ).toBeFalse( "Final scheduler stopped" );
				}
			} );
		} );
	}

}
