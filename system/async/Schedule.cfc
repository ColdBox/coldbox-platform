/**
 * This is the ColdBox Scheduler class which connects your code to the Java
 * Scheduling services to execute tasks.
 */
component accessors="true"{

	/**
	 * The Java executor class
	 */
	property name="executor";

	property name="timeUnit";
	property name="delay";
	property name="period";

	/**
	 * Constructor
	 *
	 * @executor The native executor
	 */
	Schedule function init( required executor ){
		variables.executor 		= arguments.executor;
		variables.jTimeUnit 	= new TimeUnit();

		// Schedule Properties
		variables.timeUnit 	= variables.jTimeUnit.getTimeUnit();
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
				variables.jTimeUnit
			);
		}
		// Just a simple schedule with a delay
		else {
			variables.executor.schedule(
				jRunnable,
				javaCast( "long", variables.delay ),
				variables.jTimeUnit
			);
		}
	}

	/**
	 * Set a delay in the running of this schedule
	 *
	 * @delay The delay number
	 * @timeUnit The time unit to use, available units are: days, hours, microseconds, milliseconds, minutes, nanoseconds, and seconds. The default is seconds
	 */
	function delay( numeric delay, timeUnit="seconds" ){
		variables.delay = arguments.delay;
		variables.timeUnit = variables.jTimeUnit.getTimeUnit( arguments.timeUnit );
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
		variables.timeUnit = variables.jTimeUnit.getTimeUnit( arguments.timeUnit );
		return this;
	}

	/**
	 * Set the time unit in days
	 */
	Schedule function inDays(){
		variables.timeUnit = variables.jTimeUnit.getTimeout( "days" );
		return this;
	}

	/**
	 * Set the time unit in hours
	 */
	Schedule function inHours(){
		variables.timeUnit = variables.jTimeUnit.getTimeout( "hours" );
		return this;
	}

	/**
	 * Set the time unit in microseconds
	 */
	Schedule function inMicroseconds(){
		variables.timeUnit = variables.jTimeUnit.getTimeout( "microseconds" );
		return this;
	}

	/**
	 * Set the time unit in milliseconds
	 */
	Schedule function inMilliseconds(){
		variables.timeUnit = variables.jTimeUnit.getTimeout( "milliseconds" );
		return this;
	}

	/**
	 * Set the time unit in minutes
	 */
	Schedule function inMinutes(){
		variables.timeUnit = variables.jTimeUnit.getTimeout( "minutes" );
		return this;
	}

	/**
	 * Set the time unit in nanoseconds
	 */
	Schedule function inNanoseconds(){
		variables.timeUnit = variables.jTimeUnit.getTimeout( "nanoseconds" );
		return this;
	}

	/**
	 * Set the time unit in seconds
	 */
	Schedule function inSeconds(){
		variables.timeUnit = variables.jTimeUnit.getTimeout( "seconds" );
		return this;
	}
}