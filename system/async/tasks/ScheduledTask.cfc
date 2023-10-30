/**
 * This object represents a scheduled task that will be sent in to a scheduled executor for scheduling.
 * It has a fluent and human dsl for setting it up and restricting is scheduling and frequency of scheduling.
 *
 * A task can be represented as either a closure or a cfc with a `run()` or custom runnable method.
 */
component accessors="true" {

	/**
	 * The human name of this task
	 */
	property name="name" type="string";

	/**
	 * The group this task belongs to. You can use this for organizational purposes.
	 */
	property name="group" type="string";

	/**
	 * The task closure or CFC to execute in the task
	 */
	property name="task" type="any";

	/**
	 * The method to execute if the task is a CFC
	 */
	property name="method" type="string";

	/**
	 * The delay or time to wait before we execute the task in the scheduler
	 */
	property name="delay" type="numeric";

	/**
	 * The time unit string used when there is a delay requested for the task
	 */
	property name="delayTimeUnit" type="string";

	/**
	 * A fixed time period of execution of the tasks in this schedule. It does not wait for tasks to finish,
	 * tasks are fired exactly at that time period.
	 */
	property name="period" type="numeric";

	/**
	 * The delay to use when using scheduleWithFixedDelay(), so tasks execute after this delay once completed
	 */
	property name="spacedDelay" type="numeric";

	/**
	 * The time unit string used to schedule the task
	 */
	property name="timeUnit" type="string";

	/**
	 * A handy boolean that is set when the task is annually scheduled
	 */
	property name="annually" type="boolean";

	/**
	 * The boolean value is used for debugging
	 */
	property name="debug" type="boolean";

	/**
	 * A handy boolean that disables the scheduling of this task
	 */
	property name="disabled" type="boolean";

	/**
	 * A closure, that if registered, determines if this task will be sent for scheduling or not.
	 * It is both evaluated at scheduling and at runtime.
	 */
	property name="whenClosure" type="any";

	/**
	 * Constraint of what day of the month we need to run on: 1-31
	 */
	property name="dayOfTheMonth" type="numeric";

	/**
	 * Constraint of what day of the week this runs on: 1-7
	 */
	property name="dayOfTheWeek" type="numeric";

	/**
	 * Constraint to run only on weekends
	 */
	property name="weekends" type="boolean";

	/**
	 * Constraint to run only on weekdays
	 */
	property name="weekdays" type="boolean";

	/**
	 * Constraint to run only on the first business day of the month
	 */
	property name="firstBusinessDay" type="boolean";

	/**
	 * Constraint to run only on the last business day of the month
	 */
	property name="lastBusinessDay" type="boolean";

	/**
	 * By default tasks execute in an interval frequency which can cause tasks to
	 * stack if they take longer than their periods ( fire immediately after completion ).
	 * With this boolean flag turned on, the schedulers don't kick off the
	 * intervals until the tasks finish executing. Meaning no stacking.
	 */
	property name="noOverlaps" type="boolean";

	/**
	 * Used by first and last business day constraints to
	 * log the time of day for use in setNextRunTime()
	 */
	property name="taskTime" type="string";

	/**
	 * Constraint of when the task can start execution.
	 */
	property name="startOnDateTime" type="date";

	/**
	 * Constraint of when the task must not continue to execute
	 */
	property name="endOnDateTime" type="date";

	/**
	 * Constraint to limit the task to run after a specified time of day.
	 */
	property name="startTime" type="string";

	/**
	 * Constraint to limit the task to run before a specified time of day.
	 */
	property name="endTime" type="string";

	/**
	 * The boolean value that lets us know if this task has been scheduled
	 */
	property name="scheduled" type="boolean";

	/**
	 * This task can be assigned to a task scheduler or be executed on its own at runtime
	 */
	property name="scheduler" type="any";

	/**
	 * A struct for the task that can be used to store any metadata
	 */
	property name="meta" type="struct";

	/**
	 * The collection of stats for the task: { name, created, lastRun, nextRun, totalRuns, totalFailures, totalSuccess, lastResult, neverRun, lastExecutionTime }
	 */
	property name="stats" type="struct";

	/**
	 * The timezone this task runs under, by default we use the timezone defined in the schedulers
	 */
	property name="timezone" type="string";

	/**
	 * The before task closure
	 */
	property name="beforeTask" type="any";

	/**
	 * The after task closure
	 */
	property name="afterTask" type="any";

	/**
	 * The task success closure
	 */
	property name="onTaskSuccess" type="any";

	/**
	 * The task failure closure
	 */
	property name="onTaskFailure" type="any";

	/**
	 * Constructor
	 *
	 * @name     The name of this task
	 * @executor The executor this task will run under and be linked to
	 * @task     The closure or cfc that represents the task (optional)
	 * @method   The method on the cfc to call, defaults to "run" (optional)
	 * @debug    Add debugging logs to System out, disabled by default
	 */
	ScheduledTask function init(
		required name,
		required executor,
		any task = "",
		method   = "run",
		debug    = false,
		group    = ""
	){
		// Utility class
		variables.util             = new coldbox.system.core.util.Util();
		// Link up the executor and name
		variables.executor         = arguments.executor;
		variables.name             = arguments.name;
		variables.group            = arguments.group;
		// time unit helper
		variables.dateTimeHelper   = new coldbox.system.async.time.DateTimeHelper();
		variables.timeUnitHelper   = new coldbox.system.async.time.TimeUnit();
		// Init Properties
		variables.task             = arguments.task;
		variables.method           = arguments.method;
		// Default Frequencies
		variables.delay            = 0;
		variables.delayTimeUnit    = "";
		variables.period           = 0;
		variables.spacedDelay      = 0;
		variables.timeUnit         = "milliseconds";
		variables.noOverlaps       = false;
		// Constraints
		variables.annually         = false;
		variables.debug            = arguments.debug;
		variables.disabled         = false;
		variables.whenClosure      = "";
		variables.dayOfTheMonth    = 0;
		variables.dayOfTheWeek     = 0;
		variables.weekends         = false;
		variables.weekdays         = false;
		variables.firstBusinessDay = false;
		variables.lastBusinessDay  = false;
		variables.taskTime         = "";
		variables.startOnDateTime  = "";
		variables.endOnDateTime    = "";
		variables.startTime        = "";
		variables.endTime          = "";
		variables.scheduled        = false;
		// Probable Scheduler or not
		variables.scheduler        = "";
		// Prepare execution tracking stats
		variables.stats            = {
			// Save name just in case
			"name"              : arguments.name,
			// When task got created
			"created"           : getJavaNow().toString(),
			// The last execution run timestamp
			"lastRun"           : "",
			// The next execution run timestamp
			"nextRun"           : "",
			// Total runs
			"totalRuns"         : 0,
			// Total faiulres
			"totalFailures"     : 0,
			// Total successful task executions
			"totalSuccess"      : 0,
			// How long the last execution took
			"lastExecutionTime" : 0,
			// The latest result if any
			"lastResult"        : new coldbox.system.async.cbproxies.models.Optional(),
			// If the task has never ran or not
			"neverRun"          : true,
			// Server Host
			"inetHost"          : variables.util.discoverInetHost(),
			// Server IP
			"localIp"           : variables.util.getServerIp()
		};
		// Prepare for the user to store metadata
		variables.meta          = {};
		// Life cycle methods
		variables.beforeTask    = "";
		variables.afterTask     = "";
		variables.onTaskSuccess = "";
		variables.onTaskFailure = "";

		debugLog(
			"init",
			{
				name   : variables.name,
				group  : variables.group,
				method : variables.method,
				debug  : variables.debug
			}
		);

		return this;
	}

	/**
	 * --------------------------------------------------------------------------
	 * Utility and Operational
	 * --------------------------------------------------------------------------
	 */

	/**
	 * Call this method periodically in a long-running task to check to see if the thread has been interrupted.
	 *
	 * @throws UserInterruptException - When the thread has been interrupted
	 */
	function checkInterrupted(){
		debugLog( "checkInterrupted" );

		var thisThread = createObject( "java", "java.lang.Thread" ).currentThread();
		// Has the user/system tried to interrupt this thread?
		if ( thisThread.isInterrupted() ) {
			// This clears the interrupted status. i.e., "yeah, yeah, I'm on it!"
			thisThread.interrupted();
			throw(
				"UserInterruptException",
				"UserInterruptException",
				""
			);
		}
	}

	/**
	 * Utility to send to output to the output stream
	 *
	 * @var Variable/Message to send
	 */
	ScheduledTask function out( required var ){
		variables.executor.out( arguments.var.toString() );
		return this;
	}

	/**
	 * Utility to send to output to the error stream
	 *
	 * @var Variable/Message to send
	 */
	ScheduledTask function err( required var ){
		variables.executor.err( arguments.var.toString() );
		return this;
	}

	/**
	 * Set the timezone for this task using the task identifier else we default to our scheduler
	 *
	 * @see      https://docs.oracle.com/en/java/javase/11/docs/api/java.base/java/time/ZoneId.html
	 * @timezone The timezone string identifier
	 */
	ScheduledTask function setTimezone( required timezone ){
		debugLog( "setTimezone", arguments );
		variables.timezone = createObject( "java", "java.time.ZoneId" ).of( arguments.timezone );
		return this;
	}

	/**
	 * Has this task been assigned to a scheduler or not?
	 */
	boolean function hasScheduler(){
		debugLog( "hasScheduler" );
		return isObject( variables.scheduler );
	}

	/**
	 * This method is used to register the callable closure or cfc on this scheduled task.
	 *
	 * @task   The closure or cfc that represents the task
	 * @method The method on the cfc to call, defaults to "run" (optional)
	 *
	 * @return The schedule with the task/method registered on it
	 */
	ScheduledTask function call( required task, method = "run" ){
		debugLog( "call" );
		variables.task   = arguments.task;
		variables.method = arguments.method;
		return this;
	}

	/**
	 * Update the debug setting for this task!
	 */
	ScheduledTask function debug( required boolean value ){
		debugLog( "debug" );
		variables.debug = arguments.value;
		return this;
	}

	/**
	 * Disable the task when scheduled, meaning, don't run this sucker!
	 */
	ScheduledTask function disable(){
		debugLog( "disable" );
		variables.disabled = true;
		return this;
	}

	/**
	 * Enable the task when disabled so we can run again
	 */
	ScheduledTask function enable(){
		debugLog( "enable" );
		variables.disabled = false;
		return this;
	}

	/**
	 * Is the task disabled
	 */
	boolean function isDisabled(){
		debugLog( "isDisabled" );
		return variables.disabled;
	}

	/**
	 * Is the task enabled
	 */
	boolean function isEnabled(){
		debugLog( "isEnabled" );
		return !isDisabled();
	}

	/**
	 * Set the meta data for this task!
	 *
	 * @meta The meta data struct
	 */
	ScheduledTask function setMeta( required struct meta ){
		debugLog( "setMeta" );
		variables.meta = arguments.meta;
		return this;
	}

	/**
	 * Set a specific meta data key for this task!
	 *
	 * @key   The key to set
	 * @value The value to set
	 */
	ScheduledTask function setMetaKey( required string key, required any value ){
		debugLog( "setMetaKey" );
		variables.meta[ arguments.key ] = arguments.value;
		return this;
	}

	/**
	 * Delete a specific meta data key from this task!
	 *
	 * @key The key to delete
	 */
	ScheduledTask function deleteMetaKey( required string key ){
		debugLog( "deleteMetaKey" );
		variables.meta.delete( arguments.key );
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
		debugLog( "when" );

		variables.whenClosure = arguments.target;
		return this;
	}

	/**
	 * Set when this task should start execution on. By default it starts automatically.
	 *
	 * @date The date when this task should start execution on => yyyy-mm-dd format is preferred.
	 * @time The specific time using 24 hour format => HH:mm, defaults to 00:00
	 */
	ScheduledTask function startOn( required date, string time = "00:00" ){
		debugLog( "startOn", arguments );

		variables.startOnDateTime = variables.dateTimeHelper.parse(
			"#dateFormat( arguments.date, "yyyy-mm-dd" )#T#arguments.time#"
		);
		return this;
	}

	/**
	 * Set when this task should stop execution on. By default it never ends
	 *
	 * @date The date when this task should stop execution on => yyyy-mm-dd format is preferred.
	 * @time The specific time using 24 hour format => HH:mm, defaults to 00:00
	 */
	ScheduledTask function endOn( required date, string time = "00:00" ){
		debugLog( "endOn", arguments );

		variables.endOnDateTime = variables.dateTimeHelper.parse(
			"#dateFormat( arguments.date, "yyyy-mm-dd" )#T#arguments.time#"
		);
		return this;
	}

	/**
	 * Sets a daily time range restriction where this task can run on.
	 *
	 * @startTime The specific time using 24 hour format => HH:mm
	 * @endTime   The specific time using 24 hour format => HH:mm
	 */
	ScheduledTask function between( required string startTime, required string endTime ){
		debugLog( "between" );

		startOnTime( arguments.startTime );
		endOnTime( arguments.endTime );
		return this;
	}

	/**
	 * Sets a daily start time restriction for this task.
	 *
	 * @time The specific time using 24 hour format => HH:mm
	 */
	ScheduledTask function startOnTime( required string time ){
		debugLog( "startOnTime" );

		// Validate time format
		arguments.time = variables.dateTimeHelper.validateTime( arguments.time );

		variables.startTime = arguments.time;
		return this;
	}

	/**
	 * Sets a daily end time restriction for this task.
	 *
	 * @time The specific time using 24 hour format => HH:mm
	 */
	ScheduledTask function endOnTime( required string time ){
		debugLog( "endOnTime" );

		// Validate time format
		arguments.time = variables.dateTimeHelper.validateTime( arguments.time );

		variables.endTime = arguments.time;
		return this;
	}

	/**
	 * --------------------------------------------------------------------------
	 * Startup and Runnable Proxy
	 * --------------------------------------------------------------------------
	 */

	/**
	 * This method verifies if the running task is constrained to run on specific valid constraints:
	 *
	 * - when
	 * - dayOfTheMonth
	 * - dayOfTheWeek
	 * - firstBusinessDay
	 * - lastBusinessDay
	 * - weekdays
	 * - weekends
	 * - startOnDateTime
	 * - endOnDateTime
	 * - startTime and/or endTime
	 *
	 * This method is called by the `run()` method at runtime to determine if the task can be ran at that point in time
	 */
	boolean function isConstrained(){
		debugLog( "isConstrained" );

		var now = getJavaNow();

		// When Closure that dictates if the task can be scheduled/ran: true => yes, false => no
		if (
			( isClosure( variables.whenClosure ) || isCustomFunction( variables.whenClosure ) )
			&&
			!variables.whenClosure( this )
		) {
			return true;
		}

		// Do we have a day of the month constraint? and the same as the running date/time? Else skip it
		// If the day assigned is greater than the days in the month, then we let it thru
		// as the user intended to run it at the end of the month
		if (
			variables.dayOfTheMonth > 0 &&
			now.getDayOfMonth() != variables.dayOfTheMonth &&
			variables.dayOfTheMonth <= daysInMonth( now.toString() )
		) {
			return true;
		}

		// Do we have day of the week?
		if (
			variables.dayOfTheWeek > 0 &&
			now.getDayOfWeek().getValue() != variables.dayOfTheWeek
		) {
			return true;
		}

		// Do we have a first business day constraint
		if (
			variables.firstBusinessDay &&
			now.getDayOfMonth() != variables.dateTimeHelper
				.getFirstBusinessDayOfTheMonth( timezone: this.getTimeZone() )
				.getDayOfMonth()
		) {
			return true;
		}

		// Do we have a last business day constraint
		if (
			variables.lastBusinessDay &&
			now.getDayOfMonth() != variables.dateTimeHelper
				.getLastBusinessDayOfTheMonth( timezone: this.getTimezone() )
				.getDayOfMonth()
		) {
			return true;
		}

		// Do we have weekdays?
		if (
			variables.weekdays &&
			now.getDayOfWeek().getValue() > 5
		) {
			return true;
		}

		// Do we have weekends?
		if (
			variables.weekends &&
			now.getDayOfWeek().getValue() <= 5
		) {
			return true;
		}

		// Do we have a start on constraint
		if (
			len( variables.startOnDateTime ) &&
			now.isBefore( variables.startOnDateTime )
		) {
			return true;
		}

		// Do we have an end on constraint
		if (
			len( variables.endOnDateTime ) &&
			now.isAfter( variables.endOnDateTime )
		) {
			return true;
		}

		// Do we have we have a start time and / or end time constraint
		if (
			len( variables.startTime ) ||
			len( variables.endTime )
		) {
			var _startTime = variables.dateTimeHelper.parse(
				dateFormat( getJavaNow().toString(), "yyyy-mm-dd" ) & "T" & (
					len( variables.startTime ) ? variables.startTime : "00:00:00"
				)
			);
			var _endTime = variables.dateTimeHelper.parse(
				dateFormat( getJavaNow().toString(), "yyyy-mm-dd" ) & "T" & (
					len( variables.endTime ) ? variables.endTime : "23:59:59"
				)
			);
			if ( now.isBefore( _startTime ) || now.isAfter( _endTime ) ) {
				return true;
			}
		}

		return false;
	}

	/**
	 * This is the runnable proxy method that executes your code by the executors
	 */
	function run( boolean force = false ){
		debugLog( "run( #arguments.force# )" );

		var sTime = getTickCount();

		// If disabled or paused
		if ( !arguments.force && isDisabled() ) {
			setNextRunTime();
			return;
		}

		// Check for constraints of execution
		if ( !arguments.force && isConstrained() ) {
			setNextRunTime();
			return;
		}

		// Mark the task as it will run now for the first time
		variables.stats.neverRun = false;

		try {
			// Before Interceptors
			if ( hasScheduler() ) {
				getScheduler().beforeAnyTask( this );
			}
			if ( isClosure( variables.beforeTask ) || isCustomFunction( variables.beforeTask ) ) {
				variables.beforeTask( this );
			}

			// Target task call callable
			if ( isClosure( variables.task ) || isCustomFunction( variables.task ) ) {
				variables.stats.lastResult = variables.stats.lastResult.ofNullable( variables.task() );
			} else {
				variables.stats.lastResult = variables.stats.lastResult.ofNullable(
					invoke( variables.task, variables.method )
				);
			}

			// After Interceptor
			if ( isClosure( variables.afterTask ) || isCustomFunction( variables.afterTask ) ) {
				variables.afterTask( this, variables.stats.lastResult );
			}
			if ( hasScheduler() ) {
				getScheduler().afterAnyTask( this, variables.stats.lastResult );
			}

			// store successes and call success interceptor
			variables.stats.totalSuccess = variables.stats.totalSuccess + 1;
			if ( isClosure( variables.onTaskSuccess ) || isCustomFunction( variables.onTaskSuccess ) ) {
				variables.onTaskSuccess( this, variables.stats.lastResult );
			}
			if ( hasScheduler() ) {
				getScheduler().onAnyTaskSuccess( this, variables.stats.lastResult );
			}
		} catch ( any e ) {
			// store failures
			variables.stats.totalFailures = variables.stats.totalFailures + 1;
			// Log it, so it doesn't go to ether
			err( "Error running task (#getName()#) : #e.message & e.detail#" );
			err( "Stacktrace for task (#getName()#) : #e.stackTrace#" );

			// Try to execute the error handlers. Try try try just in case.
			try {
				// Life Cycle onTaskFailure call
				if ( isClosure( variables.onTaskFailure ) || isCustomFunction( variables.onTaskFailure ) ) {
					variables.onTaskFailure( this, e );
				}
				// If we have a scheduler attached, called the schedulers life-cycle
				if ( hasScheduler() ) {
					getScheduler().onAnyTaskError( this, e );
				}
				// After Tasks Interceptor with the exception as the last result
				if ( isClosure( variables.afterTask ) || isCustomFunction( variables.afterTask ) ) {
					variables.afterTask( this, e );
				}
				if ( hasScheduler() ) {
					getScheduler().afterAnyTask( this, e );
				}
			} catch ( any afterException ) {
				// Log it, so it doesn't go to ether and executor doesn't die.
				err(
					"Error running task (#getName()#) after/error handlers : #afterException.message & afterException.detail#"
				);
				err( "Stacktrace for task (#getName()#) after/error handlers : #afterException.stackTrace#" );
			}
		} finally {
			// Store finalization stats
			variables.stats.lastRun           = getJavaNow().toString();
			variables.stats.totalRuns         = variables.stats.totalRuns + 1;
			variables.stats.lastExecutionTime = getTickCount() - sTime;
			// Call internal cleanups event
			cleanupTaskRun();
			// set next run time based on timeUnit and period
			setNextRunTime();
		}
	}

	/**
	 * Get the last result of the task
	 *
	 * @return The last result of the task as an Optional
	 */
	function getLastResult(){
		return variables.stats.lastResult;
	}

	/**
	 * This method is called ALWAYS after a task runs, wether in failure or success but used internally for
	 * any type of cleanups
	 */
	function cleanupTaskRun(){
		debugLog( "cleanupTaskRun" );
		// no cleanups for now
	}

	/**
	 * This method registers the task into the executor and sends it for execution and scheduling.
	 * This will not register the task for execution if the disabled flag or the constraints allow it.
	 *
	 * @return A ScheduledFuture from where you can monitor the task, an empty ScheduledFuture if the task was not registered
	 */
	ScheduledFuture function start(){
		// If we have overlaps and the spaced delay is 0 then grab it from the period
		if ( variables.noOverlaps && variables.spacedDelay == 0 ) {
			variables.spacedDelay = variables.period;
		}

		// If we have a delay and a delayTimeUnit, then we need to compare to our
		// current timeUnit and convert to support the delay
		// ( only if our time unit is seconds , if not we disable the delay )
		//
		// TODO: We need to support other time units - this is a temporary fix
		// for the previous issue where the delay and/or setting would replace
		// the time setting of the task based on the order presented
		if (
			variables.delay > 0 &&
			len( variables.delayTimeUnit ) &&
			compare( variables.delayTimeUnit, variables.timeUnit ) neq 0 // not the same
		) {
			if ( variables.timeUnit != "seconds" ) {
				variables.delay         = 0;
				// reset the initial nextRunTime
				variables.stats.nextRun = "";
			} else {
				variables.delay = variables.dateTimeHelper.timeUnitToSeconds(
					variables.delay,
					variables.delayTimeUnit
				);
			}
		}

		debugLog(
			"start",
			{
				delay         : variables.delay,
				delayTimeUnit : variables.delayTimeUnit,
				period        : variables.period,
				spacedDelay   : variables.spacedDelay,
				timeUnit      : variables.timeUnit,
				type          : variables.spacedDelay > 0 ? "scheduleWithFixedDelay" : variables.period > 0 ? "scheduleAtFixedRate" : "runOnce"
			}
		);

		try {
			// Startup a spaced frequency task: no overlaps
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

			// Start off a one-off task
			return variables.executor.schedule(
				task    : this,
				delay   : variables.delay,
				timeUnit: variables.timeUnit,
				method  : "run"
			);
		} finally {
			variables.scheduled = true;
		}
	}

	/**
	 * --------------------------------------------------------------------------
	 * Life - Cycle Methods
	 * -------------------------------------------------------------------------------------------------
	 */

	/**
	 * Store the closure to execute before the task is executed
	 *
	 * @target The closure to execute
	 */
	ScheduledTask function before( required target ){
		debugLog( "before" );
		variables.beforeTask = arguments.target;
		return this;
	}

	/**
	 * Store the closure to execute after the task is executed
	 *
	 * @target The closure to execute
	 */
	ScheduledTask function after( required target ){
		debugLog( "after" );
		variables.afterTask = arguments.target;
		return this;
	}

	/**
	 * Store the closure to execute after the task is executed successfully
	 *
	 * @target The closure to execute
	 */
	ScheduledTask function onSuccess( required target ){
		debugLog( "onSuccess" );
		variables.onTaskSuccess = arguments.target;
		return this;
	}

	/**
	 * Store the closure to execute after the task is executed successfully
	 *
	 * @target The closure to execute
	 */
	ScheduledTask function onFailure( required target ){
		debugLog( "onFailure" );
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
	 * @delay      The delay that will be used before executing the task
	 * @timeUnit   The time unit to use, available units are: days, hours, microseconds, milliseconds, minutes, nanoseconds, and seconds. The default is milliseconds
	 * @overwrites Boolean to overwrite delay and delayTimeUnit even if value is already set, this is helpful if the delay is set later in the chain when creating the task - defaults to false
	 */
	ScheduledTask function delay(
		numeric delay,
		timeUnit           = "milliseconds",
		boolean overwrites = false
	){
		debugLog( "delay", arguments );

		if ( arguments.overwrites || !variables.delay ) {
			variables.delay         = arguments.delay;
			variables.delayTimeUnit = arguments.timeUnit;
		}

		if ( variables.delay > 0 ) {
			setNextRunTime();
		}

		return this;
	}

	/**
	 * Run the task every custom spaced delay of execution, meaning no overlaps
	 *
	 * @spacedDelay The delay that will be used before executing the task with no overlaps
	 * @timeUnit    The time unit to use, available units are: days, hours, microseconds, milliseconds, minutes, nanoseconds, and seconds. The default is milliseconds
	 */
	ScheduledTask function spacedDelay( numeric spacedDelay, timeUnit = "milliseconds" ){
		debugLog( "spacedDelay", arguments );

		variables.spacedDelay = arguments.spacedDelay;
		variables.timeUnit    = arguments.timeUnit;
		return this;
	}

	/**
	 * Calling this method prevents task frequencies to overlap.  By default all tasks are executed with an
	 * interval but could potentially overlap if they take longer to execute than the period.
	 */
	ScheduledTask function withNoOverlaps(){
		debugLog( "withNoOverlaps" );
		variables.noOverlaps = true;
		return this;
	}

	/**
	 * Run the task every custom period of execution
	 *
	 * @period   The period of execution
	 * @timeUnit The time unit to use, available units are: days, hours, microseconds, milliseconds, minutes, nanoseconds, and seconds. The default is milliseconds
	 */
	ScheduledTask function every( numeric period, timeUnit = "milliseconds" ){
		debugLog( "every", arguments );

		variables.period   = arguments.period;
		variables.timeUnit = arguments.timeUnit;

		setNextRunTime();

		return this;
	}

	/**
	 * Run the task every second from the time it get's scheduled
	 */
	ScheduledTask function everySecond(){
		debugLog( "everysecond" );
		return this.every( 1, "seconds" );
	}

	/**
	 * Run the task every minute from the time it get's scheduled
	 */
	ScheduledTask function everyMinute(){
		debugLog( "everyMinute" );
		return this.every( 1, "minutes" );
	}

	/**
	 * Run the task every hour from the time it get's scheduled
	 */
	ScheduledTask function everyHour(){
		debugLog( "everyHour" );
		return this.every( 1, "hours" );
	}

	/**
	 * Set the period to be hourly at a specific minute mark and 00 seconds
	 *
	 * @minutes The minutes past the hour mark
	 */
	ScheduledTask function everyHourAt( required numeric minutes ){
		debugLog( "everyHourAt", arguments );
		// Get times
		var now     = getJavaNow();
		var nextRun = now.withMinute( javacast( "int", arguments.minutes ) ).withSecond( javacast( "int", 0 ) );
		// If we passed it, then move to the next hour
		if ( now.compareTo( nextRun ) > 0 ) {
			nextRun = nextRun.plusHours( javacast( "long", 1 ) );
		}
		// Set the initial delay, period, and time unit
		setInitialDelayPeriodAndTimeUnit( now, nextRun, "hours" );

		return this;
	}

	/**
	 * Run the task every day at midnight
	 */
	ScheduledTask function everyDay(){
		debugLog( "everyDay" );
		return this.everyDayAt( "00:00" );
	}

	/**
	 * Run the task daily with a specific time in 24 hour format: HH:mm
	 * We will always add 0 seconds for you.
	 *
	 * @time The specific time using 24 hour format => HH:mm
	 */
	ScheduledTask function everyDayAt( required string time ){
		debugLog( "everyDayAt", arguments );

		// Validate time format
		arguments.time = variables.dateTimeHelper.validateTime( arguments.time );

		// Get times
		var now     = getJavaNow();
		var nextRun = now
			.withHour( javacast( "int", getToken( arguments.time, 1, ":" ) ) )
			.withMinute( javacast( "int", getToken( arguments.time, 2, ":" ) ) )
			.withSecond( javacast( "int", 0 ) );
		// If we passed it, then move to the next day
		if ( now.compareTo( nextRun ) > 0 ) {
			nextRun = nextRun.plusDays( javacast( "long", 1 ) );
		}
		// Set the initial delay, period, and time unit
		setInitialDelayPeriodAndTimeUnit( now, nextRun );

		return this;
	}

	/**
	 * Run the task every Sunday at midnight
	 */
	ScheduledTask function everyWeek(){
		debugLog( "everyWeek" );
		return this.everyWeekOn( 7 );
	}

	/**
	 * Run the task weekly on the given day of the week and time
	 *
	 * @dayOfWeek The day of the week from 1 (Monday) -> 7 (Sunday)
	 * @time      The specific time using 24 hour format => HH:mm, defaults to midnight
	 */
	ScheduledTask function everyWeekOn( required numeric dayOfWeek, string time = "00:00" ){
		debugLog( "everyWeekOn", arguments );

		// Validate time format
		arguments.time = variables.dateTimeHelper.validateTime( arguments.time );

		// Get times
		var now     = getJavaNow();
		var nextRun = now
			// Given day
			.with( variables.dateTimeHelper.ChronoField.DAY_OF_WEEK, javacast( "int", arguments.dayOfWeek ) )
			// Given time
			.withHour( javacast( "int", getToken( arguments.time, 1, ":" ) ) )
			.withMinute( javacast( "int", getToken( arguments.time, 2, ":" ) ) )
			.withSecond( javacast( "int", 0 ) );
		// If we passed it, then move to the next week
		if ( now.compareTo( nextRun ) > 0 ) {
			nextRun = nextRun.plusWeeks( javacast( "long", 1 ) );
		}
		// Set the initial delay, period, and time unit
		setInitialDelayPeriodAndTimeUnit( now, nextRun, "days", 7 );
		// set constraints
		variables.dayOfTheWeek = arguments.dayOfWeek;

		return this;
	}

	/**
	 * Run the task on the first day of every month at midnight
	 */
	ScheduledTask function everyMonth(){
		debugLog( "everyMonth" );
		return this.everyMonthOn( 1 );
	}

	/**
	 * Run the task every month on a specific day and time
	 *
	 * @day  Which day of the month
	 * @time The specific time using 24 hour format => HH:mm, defaults to midnight
	 */
	ScheduledTask function everyMonthOn( required numeric day, string time = "00:00" ){
		debugLog( "everyMonthOn", arguments );

		// Validate time format
		arguments.time = variables.dateTimeHelper.validateTime( arguments.time );

		// Get times
		var now     = getJavaNow();
		var nextRun = now
			// First day of the month
			.with( variables.dateTimeHelper.ChronoField.DAY_OF_MONTH, javacast( "int", arguments.day ) )
			// Specific Time
			.withHour( javacast( "int", getToken( arguments.time, 1, ":" ) ) )
			.withMinute( javacast( "int", getToken( arguments.time, 2, ":" ) ) )
			.withSecond( javacast( "int", 0 ) );
		// If we passed it, then move to the next month
		if ( now.compareTo( nextRun ) > 0 ) {
			nextRun = nextRun.plusMonths( javacast( "long", 1 ) );
		}
		// Set the initial delay, period, and time unit
		setInitialDelayPeriodAndTimeUnit( now, nextRun );
		// Set constraints
		variables.dayOfTheMonth = arguments.day;

		return this;
	}

	/**
	 * Run the task on the first Monday of every month
	 *
	 * @time The specific time using 24 hour format => HH:mm, defaults to midnight
	 */
	ScheduledTask function onFirstBusinessDayOfTheMonth( string time = "00:00" ){
		debugLog( "onFirstBusinessDayOfTheMonth", arguments );

		// Validate time format
		arguments.time = variables.dateTimeHelper.validateTime( arguments.time );

		// Get times
		var now     = getJavaNow();
		var nextRun = variables.dateTimeHelper.getFirstBusinessDayOfTheMonth(
			time    : arguments.time,
			timezone: this.getTimezone()
		);
		// If we passed it, then move to the first business day of next month
		if ( now.compareTo( nextRun ) > 0 ) {
			nextRun = variables.dateTimeHelper.getFirstBusinessDayOfTheMonth(
				time    : arguments.time,
				addMonth: true,
				timezone: this.getTimezone()
			);
		}
		// Set the initial delay, period, and time unit
		setInitialDelayPeriodAndTimeUnit( now, nextRun );
		// Set constraints
		variables.firstBusinessDay = true;
		variables.taskTime         = arguments.time;

		return this;
	}

	/**
	 * Run the task on the last business day of the month
	 *
	 * @time The specific time using 24 hour format => HH:mm, defaults to midnight
	 */
	ScheduledTask function onLastBusinessDayOfTheMonth( string time = "00:00" ){
		debugLog( "onLastBusinessDayOfTheMonth", arguments );

		// Validate time format
		arguments.time = variables.dateTimeHelper.validateTime( arguments.time );

		// Get times
		var now     = getJavaNow();
		var nextRun = variables.dateTimeHelper.getLastBusinessDayOfTheMonth(
			time    : arguments.time,
			timezone: this.getTimezone()
		);
		// If we passed it, then move to the last business day of next month
		if ( now.compareTo( nextRun ) > 0 ) {
			nextRun = variables.dateTimeHelper.getLastBusinessDayOfTheMonth(
				time    : arguments.time,
				addMonth: true,
				timezone: this.getTimezone()
			);
		}
		// Set the initial delay, period, and time unit
		setInitialDelayPeriodAndTimeUnit( now, nextRun );
		// Set constraints
		variables.lastBusinessDay = true;
		variables.taskTime        = arguments.time;

		return this;
	}

	/**
	 * Run the task on the first day of the year at midnight
	 */
	ScheduledTask function everyYear(){
		debugLog( "everyYear" );
		return this.everyYearOn( 1, 1 );
	}

	/**
	 * Set the period to be weekly at a specific time at a specific day of the week
	 *
	 * @month The month in numeric format 1-12
	 * @day   Which day of the month
	 * @time  The specific time using 24 hour format => HH:mm, defaults to 00:00
	 */
	ScheduledTask function everyYearOn(
		required numeric month,
		required numeric day,
		required string time = "00:00"
	){
		debugLog( "everyYearOn", arguments );

		// Validate time format
		arguments.time = variables.dateTimeHelper.validateTime( arguments.time );

		// Get times
		var now     = getJavaNow();
		var nextRun = now
			// Specific month
			.with( variables.dateTimeHelper.ChronoField.MONTH_OF_YEAR, javacast( "int", arguments.month ) )
			// Specific day of the month
			.with( variables.dateTimeHelper.ChronoField.DAY_OF_MONTH, javacast( "int", arguments.day ) )
			// Midnight
			.withHour( javacast( "int", getToken( arguments.time, 1, ":" ) ) )
			.withMinute( javacast( "int", getToken( arguments.time, 2, ":" ) ) )
			.withSecond( javacast( "int", 0 ) );
		// If we passed it, then move to the next year
		if ( now.compareTo( nextRun ) > 0 ) {
			nextRun = nextRun.plusYears( javacast( "long", 1 ) );
		}
		// Set the initial delay, period, and time unit
		setInitialDelayPeriodAndTimeUnit( now, nextRun, "days", 365 );
		// Set constraints
		variables.annually = true;

		return this;
	}

	/**
	 * Run the task on saturday and sundays
	 *
	 * @time The specific time using 24 hour format => HH:mm, defaults to 00:00
	 */
	ScheduledTask function onWeekends( string time = "00:00" ){
		debugLog( "onWeekends", arguments );

		// Validate time format
		arguments.time = variables.dateTimeHelper.validateTime( arguments.time );

		// Get times
		var now     = getJavaNow();
		var nextRun = now
			.withHour( javacast( "int", getToken( arguments.time, 1, ":" ) ) )
			.withMinute( javacast( "int", getToken( arguments.time, 2, ":" ) ) )
			.withSecond( javacast( "int", 0 ) );
		// If we passed it, then move to the next day
		if ( now.compareTo( nextRun ) > 0 ) {
			nextRun = nextRun.plusDays( javacast( "long", 1 ) );
		}
		// Set the initial delay, period, and time unit
		setInitialDelayPeriodAndTimeUnit( now, nextRun );
		// Set constraints
		variables.weekends = true;
		variables.weekdays = false;

		return this;
	}

	/**
	 * Set the period to be from Monday - Friday
	 *
	 * @time The specific time using 24 hour format => HH:mm, defaults to 00:00
	 */
	ScheduledTask function onWeekdays( string time = "00:00" ){
		debugLog( "onWeekdays", arguments );

		// Validate time format
		arguments.time = variables.dateTimeHelper.validateTime( arguments.time );

		// Get times
		var now     = getJavaNow();
		var nextRun = now
			.withHour( javacast( "int", getToken( arguments.time, 1, ":" ) ) )
			.withMinute( javacast( "int", getToken( arguments.time, 2, ":" ) ) )
			.withSecond( javacast( "int", 0 ) );
		// If we passed it, then move to the next day
		if ( now.compareTo( nextRun ) > 0 ) {
			nextRun = nextRun.plusDays( javacast( "long", 1 ) );
		}
		// Set the initial delay, period, and time unit
		setInitialDelayPeriodAndTimeUnit( now, nextRun );
		// Set constraints
		variables.weekdays = true;
		variables.weekends = false;

		return this;
	}

	/**
	 * Set the period to be on Mondays
	 *
	 * @time The specific time using 24 hour format => HH:mm, defaults to 00:00
	 */
	ScheduledTask function onMondays( string time = "00:00" ){
		debugLog( "onMondays", arguments );
		return this.everyWeekOn( 1, arguments.time );
	}

	/**
	 * Set the period to be on Tuesdays
	 *
	 * @time The specific time using 24 hour format => HH:mm, defaults to 00:00
	 */
	ScheduledTask function onTuesdays( string time = "00:00" ){
		debugLog( "onTuesdays", arguments );
		return this.everyWeekOn( 2, arguments.time );
	}

	/**
	 * Set the period to be on Wednesdays
	 *
	 * @time The specific time using 24 hour format => HH:mm, defaults to 00:00
	 */
	ScheduledTask function onWednesdays( string time = "00:00" ){
		debugLog( "onWednesdays", arguments );
		return this.everyWeekOn( 3, arguments.time );
	}

	/**
	 * Set the period to be on Thursdays
	 *
	 * @time The specific time using 24 hour format => HH:mm, defaults to 00:00
	 */
	ScheduledTask function onThursdays( string time = "00:00" ){
		debugLog( "onThursdays", arguments );
		return this.everyWeekOn( 4, arguments.time );
	}

	/**
	 * Set the period to be on Fridays
	 *
	 * @time The specific time using 24 hour format => HH:mm, defaults to 00:00
	 */
	ScheduledTask function onFridays( string time = "00:00" ){
		debugLog( "onFridays", arguments );
		return this.everyWeekOn( 5, arguments.time );
	}

	/**
	 * Set the period to be on Saturdays
	 *
	 * @time The specific time using 24 hour format => HH:mm, defaults to 00:00
	 */
	ScheduledTask function onSaturdays( string time = "00:00" ){
		debugLog( "onSaturdays", arguments );
		return this.everyWeekOn( 6, arguments.time );
	}

	/**
	 * Set the period to be on Sundays
	 *
	 * @time The specific time using 24 hour format => HH:mm, defaults to 00:00
	 */
	ScheduledTask function onSundays( string time = "00:00" ){
		debugLog( "onSundays", arguments );
		return this.everyWeekOn( 7, arguments.time );
	}

	/**
	 * --------------------------------------------------------------------------
	 * TimeUnit Methods
	 * --------------------------------------------------------------------------
	 * These methods are used to set the time unit of the interval or periods.
	 * Last one called wins!
	 */

	/**
	 * Set the time unit in days
	 */
	ScheduledTask function inDays(){
		debugLog( "inDays" );
		variables.timeUnit = "days";
		return this;
	}

	/**
	 * Set the time unit in hours
	 */
	ScheduledTask function inHours(){
		debugLog( "inHours" );
		variables.timeUnit = "hours";
		return this;
	}

	/**
	 * Set the time unit in microseconds
	 */
	ScheduledTask function inMicroseconds(){
		debugLog( "inMicroseconds" );
		variables.timeUnit = "microseconds";
		return this;
	}

	/**
	 * Set the time unit in milliseconds
	 */
	ScheduledTask function inMilliseconds(){
		debugLog( "inMilliseconds" );
		variables.timeUnit = "milliseconds";
		return this;
	}

	/**
	 * Set the time unit in minutes
	 */
	ScheduledTask function inMinutes(){
		debugLog( "inMinutes" );
		variables.timeUnit = "minutes";
		return this;
	}

	/**
	 * Set the time unit in nanoseconds
	 */
	ScheduledTask function inNanoseconds(){
		debugLog( "inNanoseconds" );
		variables.timeUnit = "nanoseconds";
		return this;
	}

	/**
	 * Set the time unit in seconds
	 */
	ScheduledTask function inSeconds(){
		debugLog( "inSeconds" );
		variables.timeUnit = "seconds";
		return this;
	}

	/**
	 * Get a Java localDateTime object using the current date/time and timezone
	 *
	 * @now The date to use as the starting point, defaults to now() - modifications are helpful for testing
	 */
	function getJavaNow( date now = now() ){
		return variables.dateTimeHelper.toLocalDateTime( arguments.now, this.getTimezone() );
	}

	/**
	 * Get the state representation of the scheduler task
	 */
	function getMemento(){
		return variables.filter( function( key, value ){
			return isCustomFunction( value ) || listFindNoCase( "this", key ) ? false : true;
		} );
	}

	/**
	 * --------------------------------------------------------------------------
	 * Private Methods
	 * --------------------------------------------------------------------------
	 */

	/**
	 * This method is called to set the initial delay period which
	 * calls setInitialNextRunTime, then sets the timeUnit to seconds
	 * and the period based on a value to convert to seconds.
	 *
	 * @now              The current time to use for calculating the initial delay
	 * @nextRun          The first run time to use for calculating the initial delay
	 * @periodValue      The value to use when calculating the period to seconds
	 * @periodMultiplier The multiplier to use when calculating the period to seconds
	 */
	private function setInitialDelayPeriodAndTimeUnit(
		required now,
		required nextRun,
		string periodValue       = "days",
		numeric periodMultiplier = 1
	){
		debugLog(
			"setInitialDelayPeriodAndTimeUnit",
			{
				now              : arguments.now.toString(),
				nextRun          : arguments.nextRun.toString(),
				periodValue      : arguments.periodValue,
				periodMultiplier : arguments.periodMultiplier
			}
		);

		// Get the duration time for the next run and delay accordingly
		this.delay(
			variables.dateTimeHelper
				.duration()
				.getNative()
				.between( arguments.now, arguments.nextRun )
				.getSeconds(),
			"seconds",
			true
		);
		// Set the period to be every hour in seconds
		variables.period = variables.timeUnitHelper
			.get( arguments.periodValue )
			.toSeconds( arguments.periodMultiplier );
		variables.timeUnit = "seconds";
	}

	/**
	 * This method is called to set the next run time of the task based on the timeUnit and period.
	 */
	private function setNextRunTime(){
		var initialNextRun = "";
		var nextRun        = getJavaNow();

		if ( len( variables.stats.nextRun ) ) {
			initialNextRun = variables.stats.nextRun;
		}

		debugLog(
			"setNextRunTime-start",
			{
				"delay"            : variables.delay,
				"delayTimeUnit"    : variables.delayTimeUnit,
				"period"           : variables.period,
				"spacedDelay"      : variables.spacedDelay,
				"timeUnit"         : variables.timeUnit,
				"startTime"        : variables.startTime,
				"endTime"          : variables.endTime,
				"firstBusinessDay" : variables.firstBusinessDay,
				"lastBusinessDay"  : variables.lastBusinessDay,
				"taskTime"         : variables.taskTime,
				"initialNextRun"   : initialNextRun.toString()
			}
		);

		// check if we are a first or last business day of month entry
		if ( variables.firstBusinessDay ) {
			nextRun = variables.dateTimeHelper.getFirstBusinessDayOfTheMonth(
				time    : variables.taskTime,
				addMonth: true,
				timezone: this.getTimezone()
			);
		} else if ( variables.lastBusinessDay ) {
			nextRun = variables.dateTimeHelper.getLastBusinessDayOfTheMonth(
				time    : variables.taskTime,
				addMonth: true,
				timezone: this.getTimezone()
			);
		}
		// If we have start/end times, we need to modify this
		else if ( len( variables.startTime ) || len( variables.endTime ) ) {
			nextRun = startEndTimeNextRun( nextRun );
		}

		// Add in the delay ONLY if it's the initial next run
		if ( variables.delay > 0 && !len( variables.stats.nextRun ) ) {
			nextRun = DateTimeHelper.dateTimeAdd(
				target  : nextRun,
				amount  : variables.delay,
				timeUnit: variables.delayTimeUnit
			);
		}
		// If we have run this task already and have already a task run
		// then calculate it via the period and timeUnit
		else if ( len( initialNextRun ) ) {
			// Calculate the amount of time to add to the next run time based on period or the spaced delay
			// Which is what the task operates on, either one.
			var amount = variables.spacedDelay != 0 ? variables.spacedDelay : variables.period;
			// if overlaps are allowed task is immediately scheduled
			if ( variables.spacedDelay == 0 && variables.stats.lastExecutionTime / 1000 > variables.period ) {
				amount = 0;
			}
			nextRun = variables.dateTimeHelper.dateTimeAdd( nextRun, amount, variables.timeUnit );
		}

		debugLog( "setNextRunTime-end", { nextRun : nextRun.toString() } );
		variables.stats.nextRun = nextRun.toString();
	}

	/**
	 * This method is called to set the next run time of the task
	 * so it can process start/end times to calculate the next run on the passed initial date-time
	 *
	 * @now The initial next run date time
	 *
	 * @return The calculated next run date time accouting start/end times
	 */
	private function startEndTimeNextRun( required now ){
		var	sTime = len( variables.startTime )
		 ? arguments.now
			.withHour( javacast( "int", variables.startTime.getToken( 1, ":" ) ) )
			.withMinute( javacast( "int", variables.startTime.getToken( 2, ":" ) ) )
			.withSecond( 0 )
		 : arguments.now
			.withHour( 0 )
			.withMinute( 0 )
			.withSecond( 0 );

		var	eTime = variables.endTime.length() > 0
		 ? arguments.now
			.withHour( javacast( "int", variables.endTime.getToken( 1, ":" ) ) )
			.withMinute( javacast( "int", variables.endTime.getToken( 2, ":" ) ) )
			.withSecond( 0 )
		 : arguments.now
			.withHour( 23 )
			.withMinute( 59 )
			.withSecond( 59 );

		if ( arguments.now.compareTo( sTime ) < 0 ) {
			return sTime;
		} else if ( arguments.now.compareTo( eTime ) > 0 ) {
			return sTime.plusDays( 1 );
		} else {
			return arguments.now;
		}
	}

	/**
	 * Debug output to the executor out console
	 *
	 * @caller The name of the method calling this method
	 * @args   The arguments to attach to the logging output
	 */
	function debugLog( required string caller, struct args = {} ){
		if ( variables.debug ) {
			var message = [
				dateTimeFormat( now(), "yyyy-mm-dd hh:nn:ss" ),
				"ScheduledTask",
				"group: #getGroup()#",
				"name: #getName()#",
				"caller: #arguments.caller#"
			];

			if ( !arguments.args.isEmpty() ) {
				message.append( "args: #serializeJSON( arguments.args )#" );
			}

			variables.executor.out( message.toList( " " ) );
		}
	}

}
