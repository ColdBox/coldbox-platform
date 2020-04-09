/**
 * This is the ColdBox Executor class which connects your code to the Java
 * Scheduling services to execute tasks.
 */
component accessors="true" {

	/**
	 * The human name of this executor
	 */
	property name="name";

	/**
	 * The native Java executor class modeled in this executor
	 */
	property name="native";

	/**
	 * The Java time unit class used in the schedule
	 */
	property name="timeUnit";

	/**
	 * The delay to use in the schedule execution
	 */
	property name="delay" type="numeric";

	/**
	 * The period of execution of the tasks in this schedule
	 */
	property name="period" type="numeric";

	// Prepare the static time unit class
	this.jTimeUnit = new coldbox.system.async.util.TimeUnit();

	/**
	 * Constructor
	 *
	 * @name The name of the scheduler
	 * @executor The native executor attached to this schedule
	 * @debug Add output debugging
	 * @loadAppContext Load the CFML App contexts or not, disable if not used
	 */
	Executor function init(
		required name,
		required executor,
		boolean debug=false,
		boolean loadAppContext=true
	){
		// Seed name and executor
		variables.name      = arguments.name;
		variables.native  	= arguments.executor;

		// Scheduling Property defaults, no delays and no periods
		variables.timeUnit = this.jTimeUnit.get();
		variables.delay    = 0;
		variables.period   = 0;

		// Debugging + Context
		variables.debug = arguments.debug;
		variables.loadAppContext = arguments.loadAppContext;

		return this;
	}

	/**
	 * Submit a task into the scheduler which can return a result if any.  The result of this call
	 * is a ColdBox Future.
	 *
	 * @callable THe callable closure/lambda/cfc
	 * @method The default method to execute if the runnable is a CFC, defaults to `run()`
	 * @result the result to return once the future completes
	 *
	 * @return A ColdBox Future
	 */
	ScheduledFuture function submit( required callable, method = "run", any result ){
		var jCallable = createDynamicProxy(
			new proxies.Callable(
				arguments.callable,
				arguments.method,
				variables.debug,
				variables.loadAppContext
			),
			[ "java.util.concurrent.Callable" ]
		);

		// Do we have a seeded result?
		if( !isNull( arguments.result ) ){
			return new Future().setNative(
				variables.native.submit( jCallable ),
				arguments.result
			);
		}

		// Send for execution
		return new ScheduledFuture(
			variables.native.submit( jCallable )
		);
	}

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

	/**
	 * Set a delay in the running of the task that will be registered with this schedule
	 *
	 * @delay The delay that will be used before executing the task
	 * @timeUnit The time unit to use, available units are: days, hours, microseconds, milliseconds, minutes, nanoseconds, and seconds. The default is seconds
	 */
	function delay( numeric delay, timeUnit = "seconds" ){
		variables.delay    = arguments.delay;
		variables.timeUnit = this.jTimeUnit.get( arguments.timeUnit );
		return this;
	}

	/**
	 * Set the period of execution for the schedule
	 *
	 * @period The period of execution
	 * @timeUnit The time unit to use, available units are: days, hours, microseconds, milliseconds, minutes, nanoseconds, and seconds. The default is seconds
	 */
	function every( numeric period, timeUnit = "seconds" ){
		variables.period   = arguments.period;
		variables.timeUnit = this.jTimeUnit.get( arguments.timeUnit );
		return this;
	}

	/**
	 * Set the time unit in days
	 */
	Executor function inDays(){
		variables.timeUnit = this.jTimeUnit.get( "days" );
		return this;
	}

	/**
	 * Set the time unit in hours
	 */
	Executor function inHours(){
		variables.timeUnit = this.jTimeUnit.get( "hours" );
		return this;
	}

	/**
	 * Set the time unit in microseconds
	 */
	Executor function inMicroseconds(){
		variables.timeUnit = this.jTimeUnit.get( "microseconds" );
		return this;
	}

	/**
	 * Set the time unit in milliseconds
	 */
	Executor function inMilliseconds(){
		variables.timeUnit = this.jTimeUnit.get( "milliseconds" );
		return this;
	}

	/**
	 * Set the time unit in minutes
	 */
	Executor function inMinutes(){
		variables.timeUnit = this.jTimeUnit.get( "minutes" );
		return this;
	}

	/**
	 * Set the time unit in nanoseconds
	 */
	Executor function inNanoseconds(){
		variables.timeUnit = this.jTimeUnit.get( "nanoseconds" );
		return this;
	}

	/**
	 * Set the time unit in seconds
	 */
	Executor function inSeconds(){
		variables.timeUnit = this.jTimeUnit.get( "seconds" );
		return this;
	}

	/****************************************************************
	 * Executor Utility Methods *
	 ****************************************************************/

	/**
	 * Returns true if all tasks have completed following shut down.
	 */
	boolean function isTerminated(){
		return variables.native.isTerminated();
	}

	/**
	 * Returns true if this executor is in the process of terminating after shutdown() or shutdownNow() but has
	 * not completely terminated.
	 */
	boolean function isTerminating(){
		return variables.native.isTerminating();
	}

	/**
	 * Returns true if this executor has been shut down.
	 */
	boolean function isShutdown(){
		return variables.native.isShutdown();
	}

	/**
	 * Blocks until all tasks have completed execution after a shutdown request, or the timeout occurs, or
	 * the current thread is interrupted, whichever happens first.
	 *
	 * @timeout The maximum time to wait
	 * @timeUnit The time unit to use, available units are: days, hours, microseconds, milliseconds, minutes, nanoseconds, and seconds. The default is seconds
	 *
	 * @throws InterruptedException - if interrupted while waiting
	 *
	 * @return true if all tasks have completed following shut down
	 */
	boolean function awaitTermination( required numeric timeout, timeUnit = "seconds" ){
		return variables.native.awaitTermination(
			javacast( "long", arguments.timeout ),
			this.jTimeUnit.get( arguments.timeUnit )
		);
	}

	/**
	 * Initiates an orderly shutdown in which previously submitted tasks are executed, but no new tasks will be accepted.
	 * Invocation has no additional effect if already shut down.
	 *
	 * This method does not wait for previously submitted tasks to complete execution. Use awaitTermination to do that.
	 *
	 */
	Executor function shutdown(){
		variables.native.shutdown();
		return this;
	}

	/**
	 * Attempts to stop all actively executing tasks, halts the processing of
	 * waiting tasks, and returns a list of the tasks that were awaiting execution.
	 *
	 * This method does not wait for actively executing tasks to terminate. Use awaitTermination to do that.
	 *
	 * There are no guarantees beyond best-effort attempts to stop processing actively executing tasks.
	 * This implementation cancels tasks via Thread.interrupt(), so any task that fails to respond to interrupts may never
	 * terminate.
	 *
	 * @return list of tasks that never commenced execution
	 */
	any function shutdownNow(){
		return variables.native.shutdownNow();
	}

	/**
	 * Returns the task queue used by this executor.
	 */
	any function getQueue(){
		return variables.native.getQueue();
	}

	/**
	 * Returns the approximate number of threads that are actively executing tasks.
	 */
	numeric function getActiveCount(){
		return variables.native.getActiveCount();
	}

	/**
	 * Returns the approximate total number of tasks that have ever been scheduled for execution.
	 */
	numeric function getTaskCount(){
		return variables.native.getTaskCount();
	}

	/**
	 * Returns the approximate total number of tasks that have completed execution.
	 */
	numeric function getCompletedTaskCount(){
		return variables.native.getCompletedTaskCount();
	}

	/**
	 * Returns the core number of threads.
	 */
	numeric function getCorePoolSize(){
		return variables.native.getCorePoolSize();
	}

	/**
	 * Returns the largest number of threads that have ever simultaneously been in the pool.
	 */
	numeric function getLargestPoolSize(){
		return variables.native.getLargestPoolSize();
	}

	/**
	 * Returns the maximum allowed number of threads.
	 */
	numeric function getMaximumPoolSize(){
		return variables.native.getMaximumPoolSize();
	}

	/**
	 * Returns the current number of threads in the pool.
	 */
	numeric function getPoolSize(){
		return variables.native.getPoolSize();
	}

	/**
	 * Our very own stats struct map to give you a holistic view of the schedule
	 * and it's executor
	 *
	 * @return struct of data about the executor and the schedule
	 */
	struct function getStats(){
		return {
			"name"               : getName(),
			"delay"              : getDelay(),
			"every"              : getPeriod(),
			"timeUnit"           : getTimeUnit().toString(),
			"poolSize"           : getPoolSize(),
			"maximumPoolSize"    : getMaximumPoolSize(),
			"largestPoolSize"    : getLargestPoolSize(),
			"corePoolSize"       : getCorePoolSize(),
			"completedTaskCount" : getCompletedTaskCount(),
			"taskCount"          : getTaskCount(),
			"activeCount"        : getActiveCount(),
			"isTerminated"       : isTerminated(),
			"isTerminating"      : isTerminating(),
			"isShutdown"         : isShutdown()
		};
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
