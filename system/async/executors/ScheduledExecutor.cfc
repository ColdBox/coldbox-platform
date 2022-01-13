/**
 * This is a specialized executor that deals with scheduled tasks using
 * the Java ScheduledExecutorService.  With it, you will be able to create
 * different types of tasks:
 *
 * - `submit()` : Submit tasks just like a normal executors (can return results)
 * - `schedule()` : Schedule one-time executing tasks with or without delays (can return results)
 * - `scheduleAtFixedRate()` : Schedule tasks that will execute on a specific frequency (do not return results)
 * - `scheduleWithFixedDelay()` : Schedule tasks that will execute on a specific delayed schedule after each of them completes (do not return results)
 *
 * All of the scheduling methods will return a ScheduledFuture object that you can
 * use to monitor and get results from the tasks at hand, if any.
 *
 */
component extends="Executor" accessors="true" singleton {

	/****************************************************************
	 * Scheduling Methods *
	 ****************************************************************/

	/**
	 * This method is used to register a runnable CFC, closure or lambda so it can
	 * execute as a scheduled task according to the delay and period you have set
	 * in the Schedule.
	 *
	 * The method will register the runnable and send it for execution, the result
	 * is a ScheduledFuture.  Periodic tasks do NOT return a result, while normal delayed
	 * tasks can.
	 *
	 * @task     The runnable task closure/lambda/cfc
	 * @delay    The time to delay the first execution
	 * @timeUnit The time unit to use, available units are: days, hours, microseconds, milliseconds, minutes, nanoseconds, and seconds. The default is milliseconds
	 * @method   The default method to execute if the runnable is a CFC, defaults to `run()`
	 *
	 * @return ScheduledFuture representing pending completion of the task and whose get() method will return null upon completion
	 *
	 * @throws RejectedExecutionException - if the task cannot be scheduled for execution
	 */
	ScheduledFuture function schedule(
		required task,
		numeric delay = 0,
		timeUnit      = "milliseconds",
		method        = "run"
	){
		// build out the java callable
		var jCallable = createDynamicProxy(
			new coldbox.system.async.proxies.Callable(
				supplier       = arguments.task,
				method         = arguments.method,
				debug          = variables.debug,
				loadAppContext = variables.loadAppContext
			),
			[ "java.util.concurrent.Callable" ]
		);

		// Schedule it in the executor
		var jScheduledFuture = variables.native.schedule(
			jCallable,
			javacast( "long", arguments.delay ),
			this.$timeUnit.get( arguments.timeUnit )
		);

		// Return the results
		return new coldbox.system.async.tasks.ScheduledFuture( jScheduledFuture );
	}

	/**
	 * Creates and executes a periodic action that becomes enabled first after
	 * the given initial delay, and subsequently with the given period;
	 * that is executions will commence after delay then delay+every, then delay + 2 * every,
	 * and so on.
	 *
	 * If any execution of the task encounters an exception, subsequent executions are
	 * suppressed. Otherwise, the task will only terminate via cancellation or termination
	 * of the executor. If any execution of this task takes longer than its period,
	 * then subsequent executions may start late, but will not concurrently execute.
	 *
	 * @task     The runnable task closure/lambda/cfc
	 * @every    The period between successive executions
	 * @delay    The time to delay the first execution
	 * @timeUnit The time unit to use, available units are: days, hours, microseconds, milliseconds, minutes, nanoseconds, and seconds. The default is milliseconds
	 * @method   The default method to execute if the runnable is a CFC, defaults to `run()`
	 *
	 * @return a ScheduledFuture representing pending completion of the task, and whose get() method will throw an exception upon cancellation
	 *
	 * @throws RejectedExecutionException - if the task cannot be scheduled for execution
	 * @throws IllegalArgumentException   - if period less than or equal to zero
	 */
	ScheduledFuture function scheduleAtFixedRate(
		required task,
		required numeric every,
		numeric delay = 0,
		timeUnit      = "milliseconds",
		method        = "run"
	){
		// Schedule it
		var jScheduledFuture = variables.native.scheduleAtFixedRate(
			buildJavaRunnable( argumentCollection = arguments ),
			javacast( "long", arguments.delay ),
			javacast( "long", arguments.every ),
			this.$timeUnit.get( arguments.timeUnit )
		);

		// Return the results
		return new coldbox.system.async.tasks.ScheduledFuture( jScheduledFuture );
	}

	/**
	 * Creates and executes a periodic action that becomes enabled first after the given
	 * delay, and subsequently with the given spacedDelay between the termination of one
	 * execution and the commencement of the next.
	 *
	 * If any execution of the task encounters an exception, subsequent executions are
	 * suppressed. Otherwise, the task will only terminate via cancellation or
	 * termination of the executor.
	 *
	 * @task        The runnable task closure/lambda/cfc
	 * @spacedDelay The delay between the termination of one execution and the commencement of the next
	 * @delay       The time to delay the first execution
	 * @timeUnit    The time unit to use, available units are: days, hours, microseconds, milliseconds, minutes, nanoseconds, and seconds. The default is milliseconds
	 * @method      The default method to execute if the runnable is a CFC, defaults to `run()`
	 *
	 * @return a ScheduledFuture representing pending completion of the task, and whose get() method will throw an exception upon cancellation
	 *
	 * @throws RejectedExecutionException - if the task cannot be scheduled for execution
	 * @throws IllegalArgumentException   - if spacedDelay less than or equal to zero
	 */
	ScheduledFuture function scheduleWithFixedDelay(
		required task,
		required numeric spacedDelay,
		numeric delay = 0,
		timeUnit      = "milliseconds",
		method        = "run"
	){
		// Schedule it
		var jScheduledFuture = variables.native.scheduleWithFixedDelay(
			buildJavaRunnable( argumentCollection = arguments ),
			javacast( "long", arguments.delay ),
			javacast( "long", arguments.spacedDelay ),
			this.$timeUnit.get( arguments.timeUnit )
		);

		// Return the results
		return new coldbox.system.async.tasks.ScheduledFuture( jScheduledFuture );
	}

	/****************************************************************
	 * Builder Methods *
	 ****************************************************************/

	/**
	 * Build out a new scheduled task
	 *
	 * @deprecated DO NOT USE, use newTask() instead
	 * @task       The closure or cfc that represents the task
	 * @method     The method on the cfc to call, defaults to "run" (optional)
	 */
	ScheduledTask function newSchedule( required task, method = "run" ){
		return this.newTask( argumentCollection = arguments );
	}

	/**
	 * Build out a new scheduled task representation. Calling this method does not mean that the task is executed.
	 *
	 * @name   The name of the task
	 * @task   The closure or cfc that represents the task (optional)
	 * @method The method on the cfc to call, defaults to "run" (optional)
	 */
	ScheduledTask function newTask(
		name = "task-#getName()#-#createUUID()#",
		task,
		method = "run"
	){
		arguments.executor = this;
		return new coldbox.system.async.tasks.ScheduledTask( argumentCollection = arguments );
	}

	/****************************************************************
	 * Private Methods *
	 ****************************************************************/

	/**
	 * Build out a Java Runnable from the incoming cfc/closure/lambda/udf that will be sent to the schedulers.
	 *
	 * @task   The runnable task closure/lambda/cfc
	 * @method The default method to execute if the runnable is a CFC, defaults to `run()`
	 *
	 * @return A java.lang.Runnable
	 */
	function buildJavaRunnable( required task, required method ){
		return createDynamicProxy(
			new coldbox.system.async.proxies.Runnable(
				target         = arguments.task,
				method         = arguments.method,
				debug          = variables.debug,
				loadAppContext = variables.loadAppContext
			),
			[ "java.lang.Runnable" ]
		);
	}

}
