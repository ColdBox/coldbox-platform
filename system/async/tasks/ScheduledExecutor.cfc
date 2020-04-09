component extends="Executor" accessors="true" singleton{

	/**
	 * This method is used to register a runnable CFC, closure or lambda so it can
	 * execute as a scheduled task according to the delay and period you have set
	 * in the Schedule.
	 *
	 * The method will register the runnable and send it for execution, the result
	 * is a ScheduledFuture.  Periodic tasks do NOT return a result, while normal delayed
	 * tasks can.
	 *
	 * @task The closure/lambda/cfc that will be used as the executable task
	 * @method The default method to execute if the task is a CFC, defaults to `run()`
	 *
	 * @return The scheduled future for the task so you can monitor it
	 */
	ScheduledFuture function schedule( required task, method = "run" ){

		var jScheduledFuture = ( variables.period > 0 ?
			schedulePeriodicTask( argumentCollection=arguments ) :
			scheduleTask( argumentCollection=arguments )
		);

		return new ScheduledFuture( jScheduledFuture );
	}

	/****************************************************************
	 * Private Methods *
	 ****************************************************************/

	/**
	 * Build out a ScheduledFuture from the incoming function and/or method.
	 *
	 * @runnable THe runnable closure/lambda/cfc
	 * @method The default method to execute if the runnable is a CFC, defaults to `run()`
	 *
	 * @return Java ScheduledFuture
	 */
	private function scheduleTask( required runnable, required method ){
		// build out the java callable
		var jCallable = createDynamicProxy(
			new proxies.Callable(
				arguments.runnable,
				arguments.method,
				variables.debug,
				variables.loadAppContext
			),
			[ "java.util.concurrent.Callable" ]
		);

		return variables.native.schedule(
			jCallable,
			javacast( "long", variables.delay ),
			variables.timeUnit
		);
	}

	/**
	 * Build out a ScheduledFuture from the incoming function and/or method using
	 * the Java period fixed rate function: scheduleAtFixedRate
	 *
	 * @runnable THe runnable closure/lambda/cfc
	 * @method The default method to execute if the runnable is a CFC, defaults to `run()`
	 *
	 * @return Java ScheduledFuture
	 */
	private function schedulePeriodicTask( required runnable, required method ){
		// build out the java callable
		var jRunnable = createDynamicProxy(
			new proxies.Runnable(
				arguments.runnable,
				arguments.method,
				variables.debug,
				variables.loadAppContext
			),
			[ "java.lang.Runnable" ]
		);

		return variables.native.scheduleAtFixedRate(
			jRunnable,
			javacast( "long", variables.delay ),
			javacast( "long", variables.period ),
			variables.timeUnit
		);
	}

}