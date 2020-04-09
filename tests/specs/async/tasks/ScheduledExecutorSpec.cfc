/**
 * My BDD Test
 */
component extends="tests.specs.async.BaseAsyncSpec"{

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "ColdBox Executor Spec", function(){

			beforeEach( function( currentSpec ){
				asyncManager = new coldbox.system.async.AsyncManager();
			} );

			story( "Ability to submit one-off tasks into the executor", function(){
				it( "can execute one-off tasks", function(){
					var myExecutor = asyncManager.newScheduledExecutor( "schedulerTest" );
					var future = myExecutor.submit( function(){
						toConsole( "running submit() task in the scheduler from:#getThreadName()#" );
						return "scheduler";
					} );

					expect( future.get() ).toBe( "scheduler" );
					expect( future.isCancelled() ).toBeFalse();
					expect( future.isDone() ).toBeTrue();
				});
			});

			story( "Ability to submit scheduled tasks", function(){

				it( "can submit a task with no period and no delay", function(){
					var myExecutor = asyncManager.newScheduledExecutor( "schedulerTest" );

					var sFuture = myExecutor.schedule( function(){
						toConsole( "running schedule() in the scheduler from:#getThreadName()#" );
						return "scheduler";
					} );

					expect( sFuture.get() ).toBe( "scheduler" );
					expect( sFuture.isPeriodic() ).toBeFalse();
					expect( sFuture.getDelay( "seconds" ) ).toBe( 0 );
					expect( sFuture.isCancelled() ).toBeFalse();
					expect( sFuture.isDone() ).toBeTrue();
				});
				it( "can submit a task with no period and a delay", function(){
					var myExecutor = asyncManager.newScheduledExecutor( "schedulerTest" );

					var sFuture = myExecutor.schedule( function(){
						toConsole( "running hello task with delay from:#getThreadName()#" );
						return "hello";
					}, 300, "milliseconds" );

					expect( sFuture.isDone() ).toBeFalse();

					sleep( 300 );

					expect( sFuture.get() ).toBe( "hello" );
					expect( sFuture.isPeriodic() ).toBeFalse();
				});

				it( "can execute with a time period and be able to shutdown", function(){
					var atomicLong = createObject( "java", "java.util.concurrent.atomic.AtomicLong" ).init( 0 );
					var myExecutor = asyncManager.newScheduledExecutor( "schedulerTest" );

					var sFuture = myExecutor.scheduleAtFixedRate( function(){
						var results = atomicLong.incrementAndGet();
						toConsole( "running periodic task (#results#) from:#getThreadName()#" );
					}, 250, 0, "milliseconds" );

					try{
						expect( sFuture.isPeriodic() ).toBeTrue();
						for( var x=0; x lte 3; x++ ){
							sleep( 750 );
							toConsole( "atomic is " & atomicLong.get() );
							expect( sFuture.isDone() ).toBeFalse();
							expect( sFuture.isCancelled() ).toBeFalse();
							toConsole( asyncManager.getExecutor( "schedulerTest" ).getStats() );
						}
					} finally {
						toConsole( "xxxxx => shutting down task..." );
						sFuture.cancel();

						expect( sFuture.isDone() ).toBeTrue();
						expect( sFuture.isCancelled() ).toBeTrue();

						asyncManager.deleteExecutor( "schedulerTest" );

						toConsole( "xxxxx => task done" );
					}
				});

				it( "can execute with a spaced delay and be able to shutdown", function(){
					var atomicLong = createObject( "java", "java.util.concurrent.atomic.AtomicLong" ).init( 0 );
					var myExecutor = asyncManager.newScheduledExecutor( "schedulerTest" );

					var sFuture = myExecutor.scheduleWithFixedDelay( function(){
						sleep( 100 );
						var results = atomicLong.incrementAndGet();
						toConsole( "running periodic task (#results#) from:#getThreadName()#" );
					}, 50, 0, "milliseconds" );

					try{
						expect( sFuture.isPeriodic() ).toBeTrue();
						for( var x=0; x lte 3; x++ ){
							sleep( 750 );
							toConsole( "atomic is " & atomicLong.get() );
							expect( sFuture.isDone() ).toBeFalse();
							expect( sFuture.isCancelled() ).toBeFalse();
							toConsole( asyncManager.getExecutor( "schedulerTest" ).getStats() );
						}
					} finally {
						toConsole( "xxxxx => shutting down task..." );
						sFuture.cancel();

						expect( sFuture.isDone() ).toBeTrue();
						expect( sFuture.isCancelled() ).toBeTrue();

						asyncManager.deleteExecutor( "schedulerTest" );

						toConsole( "xxxxx => task done" );
					}
				});


			});


			story( "Ability to use a builder to schedule tasks", function(){

				it( "can use the builder to schedule a one-time task", function(){
					var scheduler = asyncManager.newScheduledExecutor( "myExecutor" );
					var atomicLong = createObject( "java", "java.util.concurrent.atomic.AtomicLong" ).init( 0 );

					var sFuture = scheduler
						.newSchedule( function(){
							var results = atomicLong.incrementAndGet();
							toConsole( "running periodic task (#results#) from:#getThreadName()#" );
						} )
						.delay( 500 )
						.start();

					try{
						while( !sFuture.isDone() ){
							toConsole( "Waiting for task to finish..." );
							sleep( 100 );
						}
						expect( atomicLong.get() ).toBe( 1 );
						toConsole( "task finalized" );
					} finally {
						asyncManager.deleteExecutor( "myExecutor" );
						expect( sFuture.isDone() ).toBeTrue();
						expect( sFuture.isCancelled() ).toBeFalse();
					}
				});
				it( "can use the builder to schedule a periodic task", function(){
					var scheduler = asyncManager.newScheduledExecutor( "myExecutor" );
					var atomicLong = createObject( "java", "java.util.concurrent.atomic.AtomicLong" ).init( 0 );

					var sFuture = scheduler
						.newSchedule( function(){
							var results = atomicLong.incrementAndGet();
							toConsole( "running periodic task (#results#) from:#getThreadName()#" );
						} )
						.every( 50 ) // every 50 ms
						.start();

					try{

						expect( sFuture.isPeriodic() ).toBeTrue();
						for( var x=0; x lte 3; x++ ){
							sleep( 750 );
							toConsole( "atomic is " & atomicLong.get() );
							expect( sFuture.isDone() ).toBeFalse();
							expect( sFuture.isCancelled() ).toBeFalse();
							toConsole( asyncManager.getExecutor( "myExecutor" ).getStats() );
						}
					} finally {
						toConsole( "xxxxx => shutting down task..." );
						sFuture.cancel();
						asyncManager.deleteExecutor( "schedulerTest" );

						expect( sFuture.isDone() ).toBeTrue();
						expect( sFuture.isCancelled() ).toBeTrue();

						toConsole( "xxxxx => task done" );
					}
				});
				it( "can use the builder to schedule a periodic task", function(){
					var scheduler = asyncManager.newScheduledExecutor( "myExecutor" );
					var atomicLong = createObject( "java", "java.util.concurrent.atomic.AtomicLong" ).init( 0 );

					var sFuture = scheduler
						.newSchedule( function(){
							sleep( randRange( 25, 100 ) );
							var results = atomicLong.incrementAndGet();
							toConsole( "running spaced delayed task (#results#) from:#getThreadName()#" );
						} )
						.spacedDelay( 50 ) // every 50 ms after each task completes
						.start();
					try{

						expect( sFuture.isPeriodic() ).toBeTrue();
						for( var x=0; x lte 3; x++ ){
							sleep( 750 );
							toConsole( "atomic is " & atomicLong.get() );
							expect( sFuture.isDone() ).toBeFalse();
							expect( sFuture.isCancelled() ).toBeFalse();
							toConsole( asyncManager.getExecutor( "myExecutor" ).getStats() );
						}
					} finally {
						toConsole( "xxxxx => shutting down spaced delay task..." );
						sFuture.cancel();
						asyncManager.deleteExecutor( "schedulerTest" );

						expect( sFuture.isDone() ).toBeTrue();
						expect( sFuture.isCancelled() ).toBeTrue();

						toConsole( "xxxxx => spaced delay task done" );
					}
				});

			});

		} );
	}

}
