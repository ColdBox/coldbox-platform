component {

	variables.delay = 15;

	function configure(){

		xtask( "Disabled Task" )
			.call ( function(){
				writeDump( var="Disabled", output="console" );
			})
			.every( 1, "second" );

		task( name: "Scope Test", debug: true )
			.call( function(){
				writeDump( var="****************************************************************************", output="console" );
				writeDump( var="Scope Test (application) -> #getThreadName()# #application.keyList()#", output="console" );
				writeDump( var="Scope Test (server) -> #getThreadName()# #server.keyList()#", output="console" );
				writeDump( var="Scope Test (cgi) -> #getThreadName()# #cgi.keyList()#", output="console" );
				writeDump( var="Scope Test (url) -> #getThreadName()# #url.keyList()#", output="console" );
				writeDump( var="Scope Test (form) -> #getThreadName()# #form.keyList()#", output="console" );
				writeDump( var="Scope Test (request) -> #getThreadName()# #request.keyList()#", output="console" );
				writeDump( var="Scope Test (variables) -> #getThreadName()# #variables.keyList()#", output="console" );
				writeDump( var="****************************************************************************", output="console" );
			} )
			.every( 60, "seconds" )
			.onFailure( function( task, exception ){
				writeDump( var='====> Scope test failed (#getThreadName()#)!! #exception.message# #exception.stacktrace.left( 500 )#', output="console" );
			} );

		task( name: "ProcessJobs", debug: true )
			.call( function(){
				runEvent( "main.process" );
			})
			.every( 20, 'seconds' )
			.delay( variables.delay, "seconds" )
			.withNoOverlaps()
			.onFailure( function( task, exception ){
				writeDump( var='====> process jobs just failed!! #exception.message#', output="console" );
			} )
			.onSuccess( function( task, results ){
				writeDump( var="====> process jobs success : Stats: #task.getStats().toString()#", output="console" );
			} );

		task( name: "testharness-Heartbeat", debug: true )
			.call( function() {
				if ( randRange(1, 5) eq 1 ){
					throw( message = "I am throwing up randomly!", type="RandomThrowup" );
				}
				writeDump( var='====> I am in a test harness test schedule!', output="console" );
			}  )
				.every( 15, "seconds" )
				.delay( variables.delay, "seconds" )
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
		writeDump( var="[onShutdown] ==> Bye bye from the Global App Scheduler!", output="console" );
	}

	/**
	 * Called after the scheduler has registered all schedules
	 */
	function onStartup(){
		writeDump( var="[onStartup] ==> The App Scheduler is in da house!!!!!", output="console" );
	}

	/**
	 * Called whenever ANY task fails
	 *
	 * @task The task that got executed
	 * @exception The ColdFusion exception object
	 */
	function onAnyTaskError( required task, required exception ){
		writeDump( var="[onAnyTaskError] ==> #arguments.task.getname()# task just went kabooooooom!", output="console" );
	}

	/**
	 * Called whenever ANY task succeeds
	 *
	 * @task The task that got executed
	 * @result The result (if any) that the task produced
	 */
	function onAnyTaskSuccess( required task, result ){
		writeDump( var="[onAnyTaskSuccess] ==>  #arguments.task.getname()# task completed!", output="console" );
	}

	/**
	 * Called before ANY task runs
	 *
	 * @task The task about to be executed
	 */
	function beforeAnyTask( required task ){
		writeDump( var="[beforeAnyTask] ==> I am running before the task: #arguments.task.getName()#", output="console" );
	}

	/**
	 * Called after ANY task runs
	 *
	 * @task The task that got executed
	 * @result The result (if any) that the task produced
	 */
	function afterAnyTask( required task, result ){
		writeDump( var="[afterAnyTask] ==> I am running after the task: #arguments.task.getName()#", output="console" );
	}

}
