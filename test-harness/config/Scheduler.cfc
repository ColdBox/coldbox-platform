component {

	function configure(){

		task( "testharness-Heartbeat" )
			.call( function() {
				if ( randRange(1, 5) eq 1 ){
					throw( message = "I am throwing up randomly!", type="RandomThrowup" );
				}
				writeDump( var='====> I am in a test harness test schedule!', output="console" );
			}  )
				.every( 15, "seconds" )
				.delay( 60, "seconds" )
				.before( function( task ) {
					writeDump( var='====> Running before the task!', output="console" );
				} )
				.after( function( task, results ){
					writeDump( var='====> Running after the task!', output="console" );
				} )
				.onFailure( function( task, exception ){
					writeDump( var='====> test schedule just failed!! #exception.message#', output="console" );
				} )
				.onSuccess( function( task, results ){
					writeDump( var="====> Test scheduler success : Stats: #task.getStats().toString()#", output="console" );
				} );

	}

	/**
	 * Called before the scheduler is going to be shutdown
	 */
	function onShutdown(){
		writeDump( var="Bye bye from the Global App Scheduler!", output="console" );
	}

	/**
	 * Called after the scheduler has registered all schedules
	 */
	function onStartup(){
		writeDump( var="The App Scheduler is in da house!!!!!", output="console" );
	}

	/**
	 * Called whenever ANY task fails
	 *
	 * @task The task that got executed
	 * @exception The ColdFusion exception object
	 */
	function onAnyTaskError( required task, required exception ){
		writeDump( var="the #arguments.task.getname()# task just went kabooooooom!", output="console" );
	}

	/**
	 * Called whenever ANY task succeeds
	 *
	 * @task The task that got executed
	 * @result The result (if any) that the task produced
	 */
	function onAnyTaskSuccess( required task, result ){
		writeDump( var="the #arguments.task.getname()# task completed!", output="console" );
	}

	/**
	 * Called before ANY task runs
	 *
	 * @task The task about to be executed
	 */
	function beforeAnyTask( required task ){
		writeDump( var="I am running before the task: #arguments.task.getName()#", output="console" );
	}

	/**
	 * Called after ANY task runs
	 *
	 * @task The task that got executed
	 * @result The result (if any) that the task produced
	 */
	function afterAnyTask( required task, result ){
		writeDump( var="I am running after the task: #arguments.task.getName()#", output="console" );
	}

}