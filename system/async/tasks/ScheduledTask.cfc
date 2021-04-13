/**
 * This object represents a scheduled task that will be sent in to an executor for scheduling.
 * It has a fluent and human dsl for setting it up and restricting is scheduling.
 *
 * A task can be represented as either a closure or a cfc with a `run()` or custom runnable method.
 */
component accessors="true" {

	/**
	 * The delay or time to wait before we execute the task in the scheduler
	 */
	property name="delay" type="numeric";

	/**
	 * The period of execution of the tasks in this schedule
	 */
	property name="period" type="numeric";

	/**
	 * The delay to use when using scheduleWithFixedDelay(), so tasks execute after this delay once completed
	 */
	property name="spacedDelay" type="numeric";

	/**
	 * The task closure or CFC to execute
	 */
	property name="task";

	/**
	 * The method to execute if the task is a CFC
	 */
	property name="method";

	/**
	 * The human name of this task
	 */
	property name="name";

	/**
	 * A handy boolean that disables the scheduling of this task
	 */
	property name="disabled" type="boolean";

	/**
	 * A closure, that if registered, determines if this task will be sent for scheduling or not
	 */
	property name="when" type="any";

	/**
	 * The timezone this task runs under, by default we use the timezone defined in the schedulers
	 */
	property name="timezone";

	/**
	 * This task can be assigned to a task scheduler or be executed on its own at runtime
	 */
	property name="scheduler";

	/**
	 * The collection of stats for the task: { created, lastRun, nextRun, totalRuns, totalFailures, totalSuccess }
	 */
	property name="stats" type="struct";

	/**
	 * Constructor
	 *
	 * @name The name of this task
	 * @executor The executor this task will run under and be linked to
	 * @task The closure or cfc that represents the task (optional)
	 * @method The method on the cfc to call, defaults to "run" (optional)
	 */
	ScheduledTask function init(
		required name,
		required executor,
		any task = "",
		method   = "run"
	){
		// Link up the executor and name
		variables.executor    = arguments.executor;
		variables.name        = arguments.name;
		// time unit helper
		variables.chronoUnit  = new coldbox.system.async.time.ChronoUnit();
		// System Helper
		variables.System      = createObject( "java", "java.lang.System" );
		// Init Properties
		variables.task        = arguments.task;
		variables.method      = arguments.method;
		// Default Frequencies
		variables.period      = 0;
		variables.delay       = 0;
		variables.spacedDelay = 0;
		variables.timeUnit    = "milliseconds";
		// Constraints
		variables.disabled    = false;
		variables.when        = "";
		// Probable Scheduler or not
		variables.scheduler   = "";
		// Prepare execution tracking stats
		variables.stats       = {
			"created"           : now(),
			"lastRun"           : "",
			"nextRun"           : "",
			"totalRuns"         : 0,
			"totalFailures"     : 0,
			"totalSuccess"      : 0,
			"lastExecutionTime" : 0,
			"lastResults"       : "",
			"neverRun"          : true
		};
		// Life cycle methods
		variables.beforeTask    = "";
		variables.afterTask     = "";
		variables.onTaskSuccess = "";
		variables.onTaskFailure = "";

		return this;
	}

	/**
	 * --------------------------------------------------------------------------
	 * Utility and Operational
	 * --------------------------------------------------------------------------
	 */

	/**
	 * Utility to send to output to the output stream
	 *
	 * @var Variable/Message to send
	 */
	ScheduledTask function out( required var ){
		variables.System.out.println( arguments.var.toString() );
		return this;
	}

	/**
	 * Utility to send to output to the error stream
	 *
	 * @var Variable/Message to send
	 */
	ScheduledTask function err( required var ){
		variables.System.err.println( arguments.var.toString() );
		return this;
	}

	/**
	 * Set the timezone for this task using the task identifier else we default to our scheduler
	 *
	 * @see https://docs.oracle.com/en/java/javase/11/docs/api/java.base/java/time/ZoneId.html
	 *
	 * @timezone The timezone string identifier
	 */
	ScheduledTask function setTimezone( required timezone ){
		variables.timezone = variables.chronoUnit.ZoneId.of( arguments.timezone );
		return this;
	}

	/**
	 * Has this task been assigned to a scheduler or not?
	 */
	boolean function hasScheduler(){
		return isObject( variables.scheduler );
	}

	/**
	 * This method is used to register the callable closure or cfc on this scheduled task.
	 *
	 * @task The closure or cfc that represents the task
	 * @method The method on the cfc to call, defaults to "run" (optional)
	 *
	 * @return The schedule with the task/method registered on it
	 */
	ScheduledTask function call( required task, method = "run" ){
		variables.task   = arguments.task;
		variables.method = arguments.method;
		return this;
	}

	/**
	 * --------------------------------------------------------------------------
	 * Restrictions
	 * --------------------------------------------------------------------------
	 */

	/**
	 * Register a when closure that will be executed before the task is set to be registered.
	 * If the closure returns true we schedule, else we disable it.
	 */
	ScheduledTask function when( target ){
		variables.when = arguments.target;
		return this;
	}

	/**
	 * Disable the task when scheduled, meaning, don't run this sucker!
	 */
	ScheduledTask function disable(){
		variables.disabled = true;
		return this;
	}

	/**
	 * Verifies if we can schedule this task or not by looking at the following constraints:
	 *
	 * - disabled
	 * - when closure
	 */
	boolean function isDisabled(){
		// Disabled bit
		if ( variables.disabled ) {
			return true;
		}

		// When Closure that dictates if the task can be scheduled: true => yes, false => no
		if ( isClosure( variables.when ) ) {
			return !variables.when( this );
		}

		// Not disabled
		return false;
	}

	/**
	 * --------------------------------------------------------------------------
	 * Startup and Runnable Proxy
	 * --------------------------------------------------------------------------
	 */

	/**
	 * This is the runnable proxy method that executes your code by the executors
	 */
	function run(){
		var sTime = getTickCount();

		// If disabled, skip run
		if ( isDisabled() ) {
			return;
		}

		// Init now as it is running
		variables.stats.neverRun = false;

		try {
			// Life-Cycle methods
			if ( isClosure( variables.beforeTask ) ) {
				variables.beforeTask( this );
			}

			// Target task call proxy
			if ( isClosure( variables.task ) || isCustomFunction( variables.task ) ) {
				variables.stats.lastResults = variables.task() ?: "";
			} else {
				variables.stats.lastResults = invoke( variables.task, variables.method ) ?: "";
			}

			// Life-Cycle methods
			if ( isClosure( variables.afterTask ) ) {
				variables.afterTask( this, variables.stats.lastResults );
			}

			// store successes
			variables.stats.totalSuccess++;
			if ( isClosure( variables.onTaskSuccess ) ) {
				variables.onTaskSuccess( this, variables.stats.lastResults );
			}
		} catch ( any e ) {
			// store failures
			variables.stats.totalFailures++;
			// Life Cycle
			if ( isClosure( variables.onTaskFailure ) ) {
				variables.onTaskFailure( this, e );
			}
		} finally {
			// Store finalization stats
			variables.stats.lastRun           = now();
			variables.stats.totalRuns         = variables.stats.totalRuns + 1;
			variables.stats.lastExecutionTime = getTickCount() - sTime;
		}
	}

	/**
	 * This method registers the task into the executor and sends it for execution and scheduling.
	 * This will not register the task for execution if the disabled flag or the constraints allow it.
	 *
	 * @return A ScheduledFuture from where you can monitor the task, an empty ScheduledFuture if the task was not registered
	 */
	ScheduledFuture function start(){
		// Startup a spaced frequency task
		if ( variables.spacedDelay > 0 ) {
			return variables.executor.scheduleWithFixedDelay(
				task       : this,
				spacedDelay: variables.spacedDelay,
				delay      : variables.delay,
				timeUnit   : variables.timeUnit,
				method     : "run"
			);
		}

		// Startup a task with a frequency period
		if ( variables.period > 0 ) {
			return variables.executor.scheduleAtFixedRate(
				task    : this,
				every   : variables.period,
				delay   : variables.delay,
				timeUnit: variables.timeUnit,
				method  : "run"
			);
		}

		// Start off the one-off task
		return variables.executor.schedule(
			task    : this,
			delay   : variables.delay,
			timeUnit: variables.timeUnit,
			method  : "run"
		);
	}

	/**
	 * --------------------------------------------------------------------------
	 * Life - Cycle Methods
	 * --------------------------------------------------------------------------
	 */

	/**
	 * Store the closure to execute before the task is executed
	 *
	 * @target The closure to execute
	 */
	ScheduledTask function before( required target ){
		variables.beforeTask = arguments.target;
		return this;
	}

	/**
	 * Store the closure to execute after the task is executed
	 *
	 * @target The closure to execute
	 */
	ScheduledTask function after( required target ){
		variables.afterTask = arguments.target;
		return this;
	}

	/**
	 * Store the closure to execute after the task is executed successfully
	 *
	 * @target The closure to execute
	 */
	ScheduledTask function onSuccess( required target ){
		variables.onTaskSuccess = arguments.target;
		return this;
	}

	/**
	 * Store the closure to execute after the task is executed successfully
	 *
	 * @target The closure to execute
	 */
	ScheduledTask function onFailure( required target ){
		variables.onTaskFailure = arguments.target;
		return this;
	}

	/**
	 * --------------------------------------------------------------------------
	 * Frequency Methods
	 * --------------------------------------------------------------------------
	 */

	/**
	 * Set a delay in the running of the task that will be registered with this schedule
	 *
	 * @delay The delay that will be used before executing the task
	 * @timeUnit The time unit to use, available units are: days, hours, microseconds, milliseconds, minutes, nanoseconds, and seconds. The default is milliseconds
	 */
	Scheduledtask function delay( numeric delay, timeUnit = "milliseconds" ){
		variables.delay    = arguments.delay;
		variables.timeUnit = arguments.timeUnit;
		return this;
	}

	/**
	 * Set the spaced delay between the executions of this scheduled task
	 *
	 * @delay The delay that will be used before executing the task
	 * @timeUnit The time unit to use, available units are: days, hours, microseconds, milliseconds, minutes, nanoseconds, and seconds. The default is milliseconds
	 */
	Scheduledtask function spacedDelay( numeric spacedDelay, timeUnit = "milliseconds" ){
		variables.spacedDelay = arguments.spacedDelay;
		variables.timeUnit    = arguments.timeUnit;
		return this;
	}

	/**
	 * Set the period of execution for the schedule
	 *
	 * @period The period of execution
	 * @timeUnit The time unit to use, available units are: days, hours, microseconds, milliseconds, minutes, nanoseconds, and seconds. The default is milliseconds
	 */
	Scheduledtask function every( numeric period, timeUnit = "milliseconds" ){
		variables.period   = arguments.period;
		variables.timeUnit = arguments.timeUnit;
		return this;
	}

	/**
	 * Set the time unit in days
	 */
	Scheduledtask function inDays(){
		variables.timeUnit = "days";
		return this;
	}

	/**
	 * Set the time unit in hours
	 */
	Scheduledtask function inHours(){
		variables.timeUnit = "hours";
		return this;
	}

	/**
	 * Set the time unit in microseconds
	 */
	Scheduledtask function inMicroseconds(){
		variables.timeUnit = "microseconds";
		return this;
	}

	/**
	 * Set the time unit in milliseconds
	 */
	Scheduledtask function inMilliseconds(){
		variables.timeUnit = "milliseconds";
		return this;
	}

	/**
	 * Set the time unit in minutes
	 */
	Scheduledtask function inMinutes(){
		variables.timeUnit = "minutes";
		return this;
	}

	/**
	 * Set the time unit in nanoseconds
	 */
	Scheduledtask function inNanoseconds(){
		variables.timeUnit = "nanoseconds";
		return this;
	}

	/**
	 * Set the time unit in seconds
	 */
	Scheduledtask function inSeconds(){
		variables.timeUnit = "seconds";
		return this;
	}

}
