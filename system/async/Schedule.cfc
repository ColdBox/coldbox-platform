/**
 * This is the ColdBox Scheduler class which connects your code to the Java
 * Scheduling services to execute tasks.
 */
component accessors="true"{

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
	 */
	Schedule function init( required name, required executor ){
		variables.name 			= arguments.name;
		variables.executor 		= arguments.executor;
		variables.jTimeUnit 	= new TimeUnit();

		// Schedule Properties
		variables.timeUnit 	= variables.jTimeUnit.get();
		variables.delay 	= 0;
		variables.period 	= 0;

		return this;
	}

	/**
	 * Run the scheduler with the given closure/lambda or CFC
	 *
	 * @runnable THe runnable closure/lambda/cfc
	 * @method The default method to execute if the runnable is a CFC, defaults to `run()`
	 */
	function run( required runnable, method="run" ){
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
		if( variables.period > 0 ){
			variables.executor.scheduleAtFixedRate(
				jRunnable,
				javaCast( "long", variables.delay ),
				javaCast( "long", variables.period ),
				variables.timeUnit
			);
		}
		// Just a simple schedule with a delay
		else {
			variables.executor.schedule(
				jRunnable,
				javaCast( "long", variables.delay ),
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
	function delay( numeric delay, timeUnit="seconds" ){
		variables.delay = arguments.delay;
		variables.timeUnit = variables.jTimeUnit.get( arguments.timeUnit );
		return this;
	}

	/**
	 * Set the period of execution for the schedule
	 *
	 * @period The period of execution
	 * @timeUnit The time unit to use, available units are: days, hours, microseconds, milliseconds, minutes, nanoseconds, and seconds. The default is seconds
	 */
	function every( numeric period, timeUnit="seconds" ){
		variables.period = arguments.period;
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

	boolean function isTerminated(){
		return variables.executor.isTerminated();
	}

	boolean function isTerminating(){
		return variables.executor.isTerminating();
	}

	boolean function isShutdown(){
		return variables.executor.isShutdown();
	}

	/**
	 * Undocumented function
	 *
	 * @timeout
	 * @timeUnit
	 *
	 * @return true if all tasks have completed following shut down
	 */
	boolean function awaitTermination( required numeric timeout, timeUnit="seconds" ){
		return variables.executor.awaitTermination(
			javaCast( "long", arguments.timeout ),
			variables.jTimeUnit.get( arguments.timeUnit )
		);
	}

	Schedule function shutdown(){
		variables.executor.shutdown();
		return this;
	}

	Schedule function shutdownNow(){
		variables.executor.shutdownNow();
		return this;
	}

	any function getQueue(){
		return variables.executor.getQueue();
	}

	numeric function getActiveCount(){
		return variables.executor.getActiveCount();
	}

	numeric function getTaskCount(){
		return variables.executor.getTaskCount();
	}

	numeric function getCompletedTaskCount(){
		return variables.executor.getCompletedTaskCount();
	}

	numeric function getCorePoolSize(){
		return variables.executor.getCorePoolSize();
	}

	numeric function getLargestPoolSize(){
		return variables.executor.getLargestPoolSize();
	}

	numeric function getMaximumPoolSize(){
		return variables.executor.getMaximumPoolSize();
	}

	numeric function getPoolSize(){
		return variables.executor.getPoolSize();
	}

	/**
	 * Our very own stats struct map to give you a holistic view of the schedule
	 * and it's executor
	 */
	struct function getStats(){
		return {
			"name" : getName(),
			"delay" : getDelay(),
			"every" : getPeriod(),
			"timeUnit" : getTimeUnit().toString(),
			"poolSize" : getPoolSize(),
			"maximumPoolSize" : getMaximumPoolSize(),
			"largestPoolSize" : getLargestPoolSize(),
			"corePoolSize" : getCorePoolSize(),
			"completedTaskCount" : getCompletedTaskCount(),
			"taskCount" : getTaskCount(),
			"activeCount" : getActiveCount(),
			"isTerminated" : isTerminated(),
			"isTerminating" : isTerminating(),
			"isShutdown" : isShutdown()
		};
	}



}