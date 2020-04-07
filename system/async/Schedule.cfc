/**
 * This is the ColdBox Scheduler class which connects your code to the Java
 * Scheduling services to execute tasks.
 */
component accessors="true" {

	/**
	 * The human name of this scheduler
	 */
	property name="name";

	/**
	 * The Java executor class
	 */
	property name="executor";

	/**
	 * The time unit used in the schedule
	 */
	property name="timeUnit";

	/**
	 * The delay to use in the schedule
	 */
	property name="delay";

	/**
	 * The period of execution of the tasks in this schedule
	 */
	property name="period";

	/**
	 * Constructor
	 *
	 * @name The name of the scheduler
	 * @executor The native executor
	 * @debug Add output debugging
	 * @loadAppContext Load the CFML App contexts or not, disable if not used
	 */
	Schedule function init( required name, required executor, boolean debug=false, boolean loadAppContext=true ){
		variables.name      = arguments.name;
		variables.executor  = arguments.executor;
		variables.jTimeUnit = new TimeUnit();

		// Schedule Properties
		variables.timeUnit = variables.jTimeUnit.get();
		variables.delay    = 0;
		variables.period   = 0;

		// Debugging + Contexzt
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
	Future function submit( required callable, method = "run", any result ){
		var jCallable = createDynamicProxy(
			new proxies.Callable(
				arguments.callable,
				arguments.method,
				variables.debug,
				variables.loadAppContext
			),
			[ "java.util.function.Callable" ]
		);

		// Do we have a seeded result?
		if( !isNull( arguments.result ) ){
			return new Future().setNative(
				variables.executor.submit( jCallable ),
				arguments.result
			);
		}

		// Basic future
		return new Future().setNative(
			variables.executor.submit( jCallable )
		);
	}

	/**
	 * Seed a runnable closure into this scheduler via the Java
	 * `scheduleAtFixedRate()` or `schedule()` methods
	 *
	 * @runnable THe runnable closure/lambda/cfc
	 * @method The default method to execute if the runnable is a CFC, defaults to `run()`
	 */
	function schedule( required runnable, method = "run" ){
		// build out the java runnable
		var jRunnable = createDynamicProxy(
			new proxies.Runnable(
				arguments.runnable,
				arguments.method,
				variables.debug,
				variables.loadAppContext
			),
			[ "java.util.function.Runnable" ]
		);

		// Build out a periodical schedule?
		if ( variables.period > 0 ) {
			variables.executor.scheduleAtFixedRate(
				jRunnable,
				javacast( "long", variables.delay ),
				javacast( "long", variables.period ),
				variables.timeUnit
			);
		}
		// Just a simple schedule with a delay
		else {
			variables.executor.schedule(
				jRunnable,
				javacast( "long", variables.delay ),
				variables.timeUnit
			);
		}
	}

	/**
	 * Set a delay in the running of the task that will be registered with this schedule
	 *
	 * @delay The delay that will be used before executing the task
	 * @timeUnit The time unit to use, available units are: days, hours, microseconds, milliseconds, minutes, nanoseconds, and seconds. The default is seconds
	 */
	function delay( numeric delay, timeUnit = "seconds" ){
		variables.delay    = arguments.delay;
		variables.timeUnit = variables.jTimeUnit.get( arguments.timeUnit );
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
		variables.timeUnit = variables.jTimeUnit.get( arguments.timeUnit );
		return this;
	}

	/**
	 * Set the time unit in days
	 */
	Schedule function inDays(){
		variables.timeUnit = variables.jTimeUnit.get( "days" );
		return this;
	}

	/**
	 * Set the time unit in hours
	 */
	Schedule function inHours(){
		variables.timeUnit = variables.jTimeUnit.get( "hours" );
		return this;
	}

	/**
	 * Set the time unit in microseconds
	 */
	Schedule function inMicroseconds(){
		variables.timeUnit = variables.jTimeUnit.get( "microseconds" );
		return this;
	}

	/**
	 * Set the time unit in milliseconds
	 */
	Schedule function inMilliseconds(){
		variables.timeUnit = variables.jTimeUnit.get( "milliseconds" );
		return this;
	}

	/**
	 * Set the time unit in minutes
	 */
	Schedule function inMinutes(){
		variables.timeUnit = variables.jTimeUnit.get( "minutes" );
		return this;
	}

	/**
	 * Set the time unit in nanoseconds
	 */
	Schedule function inNanoseconds(){
		variables.timeUnit = variables.jTimeUnit.get( "nanoseconds" );
		return this;
	}

	/**
	 * Set the time unit in seconds
	 */
	Schedule function inSeconds(){
		variables.timeUnit = variables.jTimeUnit.get( "seconds" );
		return this;
	}

	/****************************************************************
	 * Executor Utility Methods *
	 ****************************************************************/

	/**
	 * Returns true if all tasks have completed following shut down.
	 */
	boolean function isTerminated(){
		return variables.executor.isTerminated();
	}

	/**
	 * Returns true if this executor is in the process of terminating after shutdown() or shutdownNow() but has
	 * not completely terminated.
	 */
	boolean function isTerminating(){
		return variables.executor.isTerminating();
	}

	/**
	 * Returns true if this executor has been shut down.
	 */
	boolean function isShutdown(){
		return variables.executor.isShutdown();
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
		return variables.executor.awaitTermination(
			javacast( "long", arguments.timeout ),
			variables.jTimeUnit.get( arguments.timeUnit )
		);
	}

	/**
	 * Initiates an orderly shutdown in which previously submitted tasks are executed, but no new tasks will be accepted.
	 * Invocation has no additional effect if already shut down.
	 *
	 * This method does not wait for previously submitted tasks to complete execution. Use awaitTermination to do that.
	 *
	 */
	Schedule function shutdown(){
		variables.executor.shutdown();
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
		return variables.executor.shutdownNow();
	}

	/**
	 * Returns the task queue used by this executor.
	 */
	any function getQueue(){
		return variables.executor.getQueue();
	}

	/**
	 * Returns the approximate number of threads that are actively executing tasks.
	 */
	numeric function getActiveCount(){
		return variables.executor.getActiveCount();
	}

	/**
	 * Returns the approximate total number of tasks that have ever been scheduled for execution.
	 */
	numeric function getTaskCount(){
		return variables.executor.getTaskCount();
	}

	/**
	 * Returns the approximate total number of tasks that have completed execution.
	 */
	numeric function getCompletedTaskCount(){
		return variables.executor.getCompletedTaskCount();
	}

	/**
	 * Returns the core number of threads.
	 */
	numeric function getCorePoolSize(){
		return variables.executor.getCorePoolSize();
	}

	/**
	 * Returns the largest number of threads that have ever simultaneously been in the pool.
	 */
	numeric function getLargestPoolSize(){
		return variables.executor.getLargestPoolSize();
	}

	/**
	 * Returns the maximum allowed number of threads.
	 */
	numeric function getMaximumPoolSize(){
		return variables.executor.getMaximumPoolSize();
	}

	/**
	 * Returns the current number of threads in the pool.
	 */
	numeric function getPoolSize(){
		return variables.executor.getPoolSize();
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

}
