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
	property name="name";

	/**
	 * The task closure or CFC to execute in the task
	 */
	property name="task";

	/**
	 * The method to execute if the task is a CFC
	 */
	property name="method";

	/**
	 * The delay or time to wait before we execute the task in the scheduler
	 */
	property name="delay" type="numeric";

	/**
	 * The time unit string used when there is a delay requested for the task
	 */
	property name="delayTimeUnit";

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
	property name="timeUnit";

	/**
	 * A handy boolean that is set when the task is annually scheduled
	 */
	property name="annually" type="boolean";

	/**
	 * The boolean value is used for debugging
	 */
	property name="debugEnabled";

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
	property name="startOnDateTime";

	/**
	 * Constraint of when the task must not continue to execute
	 */
	property name="endOnDateTime";

	/**
	 * Constraint to limit the task to run after a specified time of day.
	 */
	property name="startTime";

	/**
	 * Constraint to limit the task to run before a specified time of day.
	 */
	property name="endTime";

	/**
	 * The boolean value that lets us know if this task has been scheduled
	 */
	property name="scheduled";

	/**
	 * This task can be assigned to a task scheduler or be executed on its own at runtime
	 */
	property name="scheduler";

	/**
	 * The collection of stats for the task: { name, created, lastRun, nextRun, totalRuns, totalFailures, totalSuccess, lastResult, neverRun, lastExecutionTime }
	 */
	property name="stats" type="struct";

	/**
	 * The timezone this task runs under, by default we use the timezone defined in the schedulers
	 */
	property name="timezone";

	/**
	 * The before task closure
	 */
	property name="beforeTask";

	/**
	 * The after task closure
	 */
	property name="afterTask";

	/**
	 * The task success closure
	 */
	property name="onTaskSuccess";

	/**
	 * The task failure closure
	 */
	property name="onTaskFailure";


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
		debug    = false
	){
		// used for debugging output
		variables.System           = createObject( "java", "java.lang.System" );
		// Utility class
		variables.util             = new coldbox.system.core.util.Util();
		// Link up the executor and name
		variables.executor         = arguments.executor;
		variables.name             = arguments.name;
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
		variables.debugEnabled     = arguments.debug;
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
			"created"           : now(),
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
			"lastResult"        : "",
			// If the task has never ran or not
			"neverRun"          : true,
			// Server Host
			"inetHost"          : variables.util.discoverInetHost(),
			// Server IP
			"localIp"           : variables.util.getServerIp()
		};
		// Life cycle methods
		variables.beforeTask    = "";
		variables.afterTask     = "";
		variables.onTaskSuccess = "";
		variables.onTaskFailure = "";

		doLog( "init" );

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
		doLog( "checkInterrupted" );

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
		doLog( "setTimezone", arguments );

		variables.timezone = createObject( "java", "java.time.ZoneId" ).of( arguments.timezone );
		return this;
	}

	/**
	 * Has this task been assigned to a scheduler or not?
	 */
	boolean function hasScheduler(){
		doLog( "hasScheduler" );

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
		doLog( "call" );

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
		doLog( "when" );

		variables.whenClosure = arguments.target;
		return this;
	}

	/**
	 * Disable the task when scheduled, meaning, don't run this sucker!
	 */
	ScheduledTask function disable(){
		doLog( "disable" );

		variables.disabled = true;
		return this;
	}

	/**
	 * Update the debug setting for this task!
	 */
	ScheduledTask function debug( required boolean value ){
		doLog( "debug" );

		variables.debugEnabled = arguments.value;
		return this;
	}

	/**
	 * Enable the task when disabled so we can run again
	 */
	ScheduledTask function enable(){
		doLog( "enable" );

		variables.disabled = false;
		return this;
	}

	/**
	 * Verifies if we can schedule this task or not by looking at the following constraints:
	 *
	 * - disabled
	 * - when closure
	 */
	boolean function isDisabled(){
		doLog( "isDisabled" );

		return variables.disabled;
	}

	/**
	 *
	 * @startTime The specific time using 24 hour format => HH:mm
	 * @endTime   The specific time using 24 hour format => HH:mm
	 */
	ScheduledTask function between( required string startTime, required string endTime ){
		doLog( "between" );
		startOnTime( arguments.startTime );
		endOnTime( arguments.endTime );
		return this;
	}

	/**
	 *
	 * @time The specific time using 24 hour format => HH:mm
	 */
	ScheduledTask function startOnTime( required string time ){
		doLog( "startOnTime" );

		// Check for minutes else add them
		if ( !find( ":", arguments.time ) ) {
			arguments.time &= ":00";
		}
		// Validate time format
		validateTime( arguments.time );

		variables.startTime = arguments.time;
		return this;
	}

	/**
	 *
	 * @time The specific time using 24 hour format => HH:mm
	 */
	ScheduledTask function endOnTime( required string time ){
		doLog( "endOnTime" );

		// Check for minutes else add them
		if ( !find( ":", arguments.time ) ) {
			arguments.time &= ":00";
		}
		// Validate time format
		validateTime( arguments.time );

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
	 * - lastBusinessDay
	 * - weekends
	 * - weekdays
	 *
	 * This method is called by the `run()` method at runtime to determine if the task can be ran at that point in time
	 */
	boolean function isConstrained(){
		doLog( "isConstrained" );

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
		// If the day day assigned is greater than the days in the month, then we let it thru
		// as the user intended to run it at the end of the month
		if (
			variables.dayOfTheMonth > 0 &&
			now.getDayOfMonth() != variables.dayOfTheMonth &&
			daysInMonth( now.toString() ) > variables.dayOfTheMonth
		) {
			return true;
		}

		// Do we have a first business day constraint
		if (
			variables.firstBusinessDay &&
			now.getDayOfMonth() != getFirstBusinessDayOfTheMonth().getDayOfMonth()
		) {
			return true;
		}

		// Do we have a last business day constraint
		if (
			variables.lastBusinessDay &&
			now.getDayOfMonth() != getLastBusinessDayOfTheMonth().getDayOfMonth()
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

		// Do we have weekdays?
		if (
			variables.weekdays &&
			now.getDayOfWeek().getValue() > 5
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

		// Do we have a start on constraint
		if (
			len( variables.startOnDateTime ) &&
			now.isBefore( variables.startOnDateTime )
		) {
			return true;
		}

		// Do we have a end on constraint
		if (
			len( variables.endOnDateTime ) &&
			now.isAfter( variables.endOnDateTime )
		) {
			return true;
		}

		// if we have a start time constraint
		if (
			len( variables.startTime ) ||
			len( variables.endTime )
		) {
			var _startTime = variables.dateTimeHelper.parse(
				dateFormat( now(), "yyyy-mm-dd" ) & "T" & (
					len( variables.startTime ) ? variables.startTime : "00:00:00"
				)
			);
			var _endTime = variables.dateTimeHelper.parse(
				dateFormat( now(), "yyyy-mm-dd" ) & "T" & ( len( variables.endTime ) ? variables.endTime : "23:59:59" )
			);
			if ( now.isBefore( _startTime ) || now.isAfter( _endTime ) ) return true;
		}

		return false;
	}

	/**
	 * This is the runnable proxy method that executes your code by the executors
	 */
	function run( boolean force = false ){
		doLog( "run - " & arguments.force );

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
				variables.stats.lastResult = variables.task() ?: "";
			} else {
				variables.stats.lastResult = invoke( variables.task, variables.method ) ?: "";
			}

			// After Interceptor
			if ( isClosure( variables.afterTask ) || isCustomFunction( variables.afterTask ) ) {
				variables.afterTask( this, variables.stats?.lastResult );
			}
			if ( hasScheduler() ) {
				getScheduler().afterAnyTask( this, variables.stats?.lastResult );
			}

			// store successes and call success interceptor
			variables.stats.totalSuccess = variables.stats.totalSuccess + 1;
			if ( isClosure( variables.onTaskSuccess ) || isCustomFunction( variables.onTaskSuccess ) ) {
				variables.onTaskSuccess( this, variables.stats?.lastResult );
			}
			if ( hasScheduler() ) {
				getScheduler().onAnyTaskSuccess( this, variables.stats?.lastResult );
			}
		} catch ( any e ) {
			// store failures
			variables.stats.totalFailures = variables.stats.totalFailures + 1;
			// Log it, so it doesn't go to ether
			err( "Error running task (#getname()#) : #e.message & e.detail#" );
			err( "Stacktrace for task (#getname()#) : #e.stackTrace#" );

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
				err( "Error running task (#getname()#) after/error handlers : #afterException.message & afterException.detail#" );
				err( "Stacktrace for task (#getname()#) after/error handlers : #afterException.stackTrace#" );
			}
		} finally {
			// Store finalization stats
			variables.stats.lastRun           = now();
			variables.stats.totalRuns         = variables.stats.totalRuns + 1;
			variables.stats.lastExecutionTime = getTickCount() - sTime;
			// Call internal cleanups event
			cleanupTaskRun();
			// set next run time based on timeUnit and period
			setNextRunTime();
		}
	}

	/**
	 * This method is called ALWAYS after a task runs, wether in failure or success but used internally for
	 * any type of cleanups
	 */
	function cleanupTaskRun(){
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
			compare( variables.delayTimeUnit, variables.timeUnit )
		) {
			if ( variables.timeUnit != "seconds" ) {
				variables.delay         = 0;
				// reset the initial nextRunTime
				variables.stats.nextRun = "";
			} else {
				// transform all to seconds
				switch ( variables.delayTimeUnit ) {
					case "days":
						variables.delay = javacast( "int", variables.delay * 60 * 60 * 24 );
						break;
					case "hours":
						variables.delay = javacast( "int", variables.delay * 60 * 60 );
						break;
					case "minutes":
						variables.delay = javacast( "int", variables.delay * 60 );
						break;
					case "milliseconds":
						variables.delay = javacast( "int", variables.delay / 1000 );
						break;
					case "microseconds":
						variables.delay = javacast( "int", variables.delay / 1000000 );
						break;
					case "nanoseconds":
						variables.delay = javacast( "int", variables.delay / 1000000000 );
						break;
				}
			}
		}

		variables.scheduled = true;

		doLog(
			"start - " & variables.name & " - should execute initial next run call " &
			serializeJSON( {
				"spacedDelay" : variables.spacedDelay,
				"period"      : variables.period,
				"delay"       : variables.delay
			} )
		);

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
		doLog( "before" );

		variables.beforeTask = arguments.target;
		return this;
	}

	/**
	 * Store the closure to execute after the task is executed
	 *
	 * @target The closure to execute
	 */
	ScheduledTask function after( required target ){
		doLog( "after" );

		variables.afterTask = arguments.target;
		return this;
	}

	/**
	 * Store the closure to execute after the task is executed successfully
	 *
	 * @target The closure to execute
	 */
	ScheduledTask function onSuccess( required target ){
		doLog( "onSuccess" );

		variables.onTaskSuccess = arguments.target;
		return this;
	}

	/**
	 * Store the closure to execute after the task is executed successfully
	 *
	 * @target The closure to execute
	 */
	ScheduledTask function onFailure( required target ){
		doLog( "onFailure" );

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
	 * @delay          The delay that will be used before executing the task
	 * @timeUnit       The time unit to use, available units are: days, hours, microseconds, milliseconds, minutes, nanoseconds, and seconds. The default is milliseconds
	 * @overwrites     Boolean to overwrite delay and timeUnit even if value is already set, this is helpful if the delay is set later in the chain when creating the task - defaults to false
	 * @setNextRunTime Boolean to execute setInitialNextRunTime() - defaults to true
	 */
	ScheduledTask function delay(
		numeric delay,
		timeUnit               = "milliseconds",
		boolean overwrites     = false,
		boolean setNextRunTime = true
	){
		doLog( "delay", arguments );

		if ( arguments.overwrites || !variables.delay ) {
			variables.delay         = arguments.delay;
			variables.delayTimeUnit = arguments.timeUnit;
		}

		if ( arguments.setNextRunTime )
			setInitialNextRunTime( delay: arguments.delay, timeUnit: arguments.timeUnit );

		return this;
	}

	/**
	 * Run the task every custom spaced delay of execution, meaning no overlaps
	 *
	 * @spacedDelay The delay that will be used before executing the task with no overlaps
	 * @timeUnit    The time unit to use, available units are: days, hours, microseconds, milliseconds, minutes, nanoseconds, and seconds. The default is milliseconds
	 */
	ScheduledTask function spacedDelay( numeric spacedDelay, timeUnit = "milliseconds" ){
		doLog( "spacedDelay", arguments );

		variables.spacedDelay = arguments.spacedDelay;
		variables.timeUnit    = arguments.timeUnit;
		return this;
	}

	/**
	 * Calling this method prevents task frequencies to overlap.  By default all tasks are executed with an
	 * interval but could potentially overlap if they take longer to execute than the period.
	 */
	ScheduledTask function withNoOverlaps(){
		doLog( "withNoOverlaps" );

		variables.noOverlaps = true;
		return this;
	}

	/**	 * Run the task every custom period of execution
	 *
	 * @period   The period of execution
	 * @timeUnit The time unit to use, available units are: days, hours, microseconds, milliseconds, minutes, nanoseconds, and seconds. The default is milliseconds
	 */
	ScheduledTask function every( numeric period, timeUnit = "milliseconds" ){
		doLog( "every", arguments );

		variables.period   = arguments.period;
		variables.timeUnit = arguments.timeUnit;

		setInitialNextRunTime();

		return this;
	}

	/**
	 * Run the task every minute from the time it get's scheduled
	 */
	ScheduledTask function everyMinute(){
		doLog( "everyMinute", arguments );

		return this.every( 1, "minutes" );
	}

	/**
	 * Run the task every hour from the time it get's scheduled
	 */
	ScheduledTask function everyHour(){
		doLog( "everyHour", arguments );

		return this.every( 1, "hours" );
	}

	/**
	 * Set the period to be hourly at a specific minute mark and 00 seconds
	 *
	 * @minutes The minutes past the hour mark
	 */
	ScheduledTask function everyHourAt( required numeric minutes ){
		doLog( "everyHourAt", arguments );

		var now     = getJavaNow();
		var nextRun = now.withMinute( javacast( "int", arguments.minutes ) ).withSecond( javacast( "int", 0 ) );
		// If we passed it, then move the hour by 1
		if ( now.compareTo( nextRun ) > 0 ) {
			nextRun = nextRun.plusHours( javacast( "int", 1 ) );
		}
		// Get the duration time for the next run and delay accordingly
		this.delay(
			variables.dateTimeHelper
				.duration()
				.getNative()
				.between( now, nextRun )
				.getSeconds(),
			"seconds",
			true
		);
		// Set the period to be every hour
		variables.period   = variables.timeUnitHelper.get( "hours" ).toSeconds( 1 );
		variables.timeUnit = "seconds";

		return this;
	}

	/**
	 * Run the task every day at midnight
	 */
	ScheduledTask function everyDay(){
		doLog( "everyDay", arguments );

		var now     = getJavaNow();
		// Set at midnight
		var nextRun = now
			.withHour( javacast( "int", 0 ) )
			.withMinute( javacast( "int", 0 ) )
			.withSecond( javacast( "int", 0 ) );
		// If we passed it, then move to the next day
		if ( now.compareTo( nextRun ) > 0 ) {
			nextRun = nextRun.plusDays( javacast( "int", 1 ) );
		}
		// Get the duration time for the next run and delay accordingly
		this.delay(
			variables.dateTimeHelper
				.duration()
				.getNative()
				.between( now, nextRun )
				.getSeconds(),
			"seconds",
			true
		);
		// Set the period to every day in seconds
		variables.period   = variables.timeUnitHelper.get( "days" ).toSeconds( 1 );
		variables.timeUnit = "seconds";

		return this;
	}

	/**
	 * Run the task daily with a specific time in 24 hour format: HH:mm
	 * We will always add 0 seconds for you.
	 *
	 * @time The specific time using 24 hour format => HH:mm
	 */
	ScheduledTask function everyDayAt( required string time ){
		doLog( "everyDayAt", arguments );

		// Check for minutes else add them
		if ( !find( ":", arguments.time ) ) {
			arguments.time &= ":00";
		}
		// Validate time format
		validateTime( arguments.time );
		// Get times
		var now     = getJavaNow();
		var nextRun = now
			.withHour( javacast( "int", getToken( arguments.time, 1, ":" ) ) )
			.withMinute( javacast( "int", getToken( arguments.time, 2, ":" ) ) )
			.withSecond( javacast( "int", 0 ) );
		// If we passed it, then move to the next day
		if ( now.compareTo( nextRun ) > 0 ) {
			nextRun = nextRun.plusDays( javacast( "int", 1 ) );
		}
		// Get the duration time for the next run and delay accordingly
		this.delay(
			variables.dateTimeHelper
				.duration()
				.getNative()
				.between( now, nextRun )
				.getSeconds(),
			"seconds",
			true
		);
		// Set the period to every day in seconds
		variables.period   = variables.timeUnitHelper.get( "DAYS" ).toSeconds( 1 );
		variables.timeUnit = "seconds";

		return this;
	}

	/**
	 * Run the task every Sunday at midnight
	 */
	ScheduledTask function everyWeek(){
		doLog( "everyWeek", arguments );

		return this.everyWeekOn( 7 );
	}

	/**
	 * Run the task weekly on the given day of the week and time
	 *
	 * @dayOfWeek The day of the week from 1 (Monday) -> 7 (Sunday)
	 * @time      The specific time using 24 hour format => HH:mm, defaults to midnight
	 */
	ScheduledTask function everyWeekOn( required numeric dayOfWeek, string time = "00:00" ){
		doLog( "everyWeekOn", arguments );

		var now = getJavaNow();
		// Check for minutes else add them
		if ( !find( ":", arguments.time ) ) {
			arguments.time &= ":00";
		}
		// Validate time format
		validateTime( arguments.time );
		var nextRun = now
			// Given day
			.with( variables.dateTimeHelper.ChronoField.DAY_OF_WEEK, javacast( "int", arguments.dayOfWeek ) )
			// Given time
			.withHour( javacast( "int", getToken( arguments.time, 1, ":" ) ) )
			.withMinute( javacast( "int", getToken( arguments.time, 2, ":" ) ) )
			.withSecond( javacast( "int", 0 ) );
		// If we passed it, then move to the next week
		if ( now.compareTo( nextRun ) > 0 ) {
			nextRun = nextRun.plusWeeks( javacast( "int", 1 ) );
		}
		// Get the duration time for the next run and delay accordingly
		this.delay(
			variables.dateTimeHelper
				.duration()
				.getNative()
				.between( now, nextRun )
				.getSeconds(),
			"seconds",
			true
		);
		// Set the period to every week in seconds
		variables.period       = variables.timeUnitHelper.get( "days" ).toSeconds( 7 );
		variables.timeUnit     = "seconds";
		variables.dayOfTheWeek = arguments.dayOfWeek;

		return this;
	}

	/**
	 * Run the task on the first day of every month at midnight
	 */
	ScheduledTask function everyMonth(){
		doLog( "everyMonth", arguments );

		return this.everyMonthOn( 1 );
	}

	/**
	 * Run the task every month on a specific day and time
	 *
	 * @day  Which day of the month
	 * @time The specific time using 24 hour format => HH:mm, defaults to midnight
	 */
	ScheduledTask function everyMonthOn( required numeric day, string time = "00:00" ){
		doLog( "everyMonthOn", arguments );

		var now = getJavaNow();
		// Check for minutes else add them
		if ( !find( ":", arguments.time ) ) {
			arguments.time &= ":00";
		}
		// Validate time format
		validateTime( arguments.time );
		// Get new time
		var nextRun = now
			// First day of the month
			.with( variables.dateTimeHelper.ChronoField.DAY_OF_MONTH, javacast( "int", arguments.day ) )
			// Specific Time
			.withHour( javacast( "int", getToken( arguments.time, 1, ":" ) ) )
			.withMinute( javacast( "int", getToken( arguments.time, 2, ":" ) ) )
			.withSecond( javacast( "int", 0 ) );
		// Have we passed it
		if ( now.compareTo( nextRun ) > 0 ) {
			nextRun = nextRun.plusMonths( javacast( "int", 1 ) );
		}
		// Get the duration time for the next run and delay accordingly
		this.delay(
			variables.dateTimeHelper
				.duration()
				.getNative()
				.between( now, nextRun )
				.getSeconds(),
			"seconds",
			true
		);
		// Set the period to one day. And make sure we add a constraint for it
		// Mostly because every month is different
		variables.period        = variables.timeUnitHelper.get( "days" ).toSeconds( 1 );
		variables.timeUnit      = "seconds";
		variables.dayOfTheMonth = arguments.day;

		return this;
	}

	/**
	 * Run the task on the first Monday of every month
	 *
	 * @time The specific time using 24 hour format => HH:mm, defaults to midnight
	 */
	ScheduledTask function onFirstBusinessDayOfTheMonth( string time = "00:00" ){
		doLog( "onFirstBusinessDayOfTheMonth", arguments );

		var now = getJavaNow();
		// Check for minutes else add them
		if ( !find( ":", arguments.time ) ) {
			arguments.time &= ":00";
		}
		// Validate time format
		validateTime( arguments.time );
		// Get new time
		var nextRun = getFirstBusinessDayOfTheMonth( arguments.time );
		// Have we passed it
		if ( now.compareTo( nextRun ) > 0 ) {
			nextRun = getFirstBusinessDayOfTheMonth( arguments.time, true );
		}
		// Get the duration time for the next run and delay accordingly
		this.delay(
			variables.dateTimeHelper
				.duration()
				.getNative()
				.between( now, nextRun )
				.getSeconds(),
			"seconds",
			true
		);
		// Set the period to one day. And make sure we add a constraint for it
		// Mostly because every month is different
		variables.period           = variables.timeUnitHelper.get( "days" ).toSeconds( 1 );
		variables.timeUnit         = "seconds";
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
		doLog( "onLastBusinessDayOfTheMonth", arguments );

		var now = getJavaNow();
		// Check for minutes else add them
		if ( !find( ":", arguments.time ) ) {
			arguments.time &= ":00";
		}
		// Validate time format
		validateTime( arguments.time );
		// Get the last day of the month
		var nextRun = getLastBusinessDayOfTheMonth( arguments.time );
		// Have we passed it
		if ( now.compareTo( nextRun ) > 0 ) {
			nextRun = getLastBusinessDayOfTheMonth( arguments.time, true );
		}
		// Get the duration time for the next run and delay accordingly
		this.delay(
			variables.dateTimeHelper
				.duration()
				.getNative()
				.between( now, nextRun )
				.getSeconds(),
			"seconds",
			true
		);
		// Set the period to one day. And make sure we add a constraint for it
		// Mostly because every month is different
		variables.period          = variables.timeUnitHelper.get( "days" ).toSeconds( 1 );
		variables.timeUnit        = "seconds";
		variables.lastBusinessDay = true;
		variables.taskTime        = arguments.time;

		return this;
	}

	/**
	 * Run the task on the first day of the year at midnight
	 */
	ScheduledTask function everyYear(){
		doLog( "everyYear" );
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
		doLog( "everyYearOn", arguments );

		var now = getJavaNow();
		// Check for minutes else add them
		if ( !find( ":", arguments.time ) ) {
			arguments.time &= ":00";
		}
		// Validate time format
		validateTime( arguments.time );
		var nextRun = now
			// Specific month
			.with( variables.dateTimeHelper.ChronoField.MONTH_OF_YEAR, javacast( "int", arguments.month ) )
			// Specific day of the month
			.with( variables.dateTimeHelper.ChronoField.DAY_OF_MONTH, javacast( "int", arguments.day ) )
			// Midnight
			.withHour( javacast( "int", getToken( arguments.time, 1, ":" ) ) )
			.withMinute( javacast( "int", getToken( arguments.time, 2, ":" ) ) )
			.withSecond( javacast( "int", 0 ) );
		// Have we passed it?
		if ( now.compareTo( nextRun ) > 0 ) {
			nextRun = nextRun.plusYears( javacast( "int", 1 ) );
		}
		// Get the duration time for the next run and delay accordingly
		this.delay(
			variables.dateTimeHelper
				.duration()
				.getNative()
				.between( now, nextRun )
				.getSeconds(),
			"seconds",
			true
		);
		// Set the period to
		variables.period   = variables.timeUnitHelper.get( "days" ).toSeconds( 365 );
		variables.timeUnit = "seconds";
		variables.annually = true;

		return this;
	}

	/**
	 * Run the task on saturday and sundays
	 *
	 * @time The specific time using 24 hour format => HH:mm, defaults to 00:00
	 */
	ScheduledTask function onWeekends( string time = "00:00" ){
		doLog( "onWeekends", arguments );

		// Check for minutes else add them
		if ( !find( ":", arguments.time ) ) {
			arguments.time &= ":00";
		}
		// Validate time format
		validateTime( arguments.time );
		// Get times
		var now     = getJavaNow();
		var nextRun = now
			.withHour( javacast( "int", getToken( arguments.time, 1, ":" ) ) )
			.withMinute( javacast( "int", getToken( arguments.time, 2, ":" ) ) )
			.withSecond( javacast( "int", 0 ) );
		// If we passed it, then move to the next day
		if ( now.compareTo( nextRun ) > 0 ) {
			nextRun = nextRun.plusDays( javacast( "int", 1 ) );
		}
		// Get the duration time for the next run and delay accordingly
		this.delay(
			variables.dateTimeHelper
				.duration()
				.getNative()
				.between( now, nextRun )
				.getSeconds(),
			"seconds",
			true
		);
		// Set the period to every day in seconds
		variables.period   = variables.timeUnitHelper.get( "DAYS" ).toSeconds( 1 );
		variables.timeUnit = "seconds";
		// Constraint to only run on weekends
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
		doLog( "onWeekdays", arguments );

		// Check for minutes else add them
		if ( !find( ":", arguments.time ) ) {
			arguments.time &= ":00";
		}
		// Validate time format
		validateTime( arguments.time );
		// Get times
		var now     = getJavaNow();
		var nextRun = now
			.withHour( javacast( "int", getToken( arguments.time, 1, ":" ) ) )
			.withMinute( javacast( "int", getToken( arguments.time, 2, ":" ) ) )
			.withSecond( javacast( "int", 0 ) );
		// If we passed it, then move to the next day
		if ( now.compareTo( nextRun ) > 0 ) {
			nextRun = nextRun.plusDays( javacast( "int", 1 ) );
		}
		// Get the duration time for the next run and delay accordingly
		this.delay(
			variables.dateTimeHelper
				.duration()
				.getNative()
				.between( now, nextRun )
				.getSeconds(),
			"seconds",
			true
		);
		// Set the period to every day in seconds
		variables.period   = variables.timeUnitHelper.get( "DAYS" ).toSeconds( 1 );
		variables.timeUnit = "seconds";
		// Constraint to only run on weekdays
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
		doLog( "onMondays", arguments );

		return this.everyWeekOn( 1, arguments.time );
	}

	/**
	 * Set the period to be on Tuesdays
	 *
	 * @time The specific time using 24 hour format => HH:mm, defaults to 00:00
	 */
	ScheduledTask function onTuesdays( string time = "00:00" ){
		doLog( "onTuesdays", arguments );

		return this.everyWeekOn( 2, arguments.time );
	}

	/**
	 * Set the period to be on Wednesdays
	 *
	 * @time The specific time using 24 hour format => HH:mm, defaults to 00:00
	 */
	ScheduledTask function onWednesdays( string time = "00:00" ){
		doLog( "onWednesdays", arguments );

		return this.everyWeekOn( 3, arguments.time );
	}

	/**
	 * Set the period to be on Thursdays
	 *
	 * @time The specific time using 24 hour format => HH:mm, defaults to 00:00
	 */
	ScheduledTask function onThursdays( string time = "00:00" ){
		doLog( "onThursdays", arguments );

		return this.everyWeekOn( 4, arguments.time );
	}

	/**
	 * Set the period to be on Fridays
	 *
	 * @time The specific time using 24 hour format => HH:mm, defaults to 00:00
	 */
	ScheduledTask function onFridays( string time = "00:00" ){
		doLog( "onFridays", arguments );

		return this.everyWeekOn( 5, arguments.time );
	}

	/**
	 * Set the period to be on Saturdays
	 *
	 * @time The specific time using 24 hour format => HH:mm, defaults to 00:00
	 */
	ScheduledTask function onSaturdays( string time = "00:00" ){
		doLog( "onSaturdays", arguments );

		return this.everyWeekOn( 6, arguments.time );
	}

	/**
	 * Set the period to be on Sundays
	 *
	 * @time The specific time using 24 hour format => HH:mm, defaults to 00:00
	 */
	ScheduledTask function onSundays( string time = "00:00" ){
		doLog( "onSundays", arguments );

		return this.everyWeekOn( 7, arguments.time );
	}

	/**
	 * Set when this task should start execution on. By default it starts automatically.
	 *
	 * @date The date when this task should start execution on => yyyy-mm-dd format is preferred.
	 * @time The specific time using 24 hour format => HH:mm, defaults to 00:00
	 */
	ScheduledTask function startOn( required date, string time = "00:00" ){
		doLog( "startOn", arguments );

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
		doLog( "endOn", arguments );

		variables.endOnDateTime = variables.dateTimeHelper.parse(
			"#dateFormat( arguments.date, "yyyy-mm-dd" )#T#arguments.time#"
		);
		return this;
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
		doLog( "inDays" );

		variables.timeUnit = "days";
		return this;
	}

	/**
	 * Set the time unit in hours
	 */
	ScheduledTask function inHours(){
		doLog( "inHours" );

		variables.timeUnit = "hours";
		return this;
	}

	/**
	 * Set the time unit in microseconds
	 */
	ScheduledTask function inMicroseconds(){
		doLog( "inMicroseconds" );

		variables.timeUnit = "microseconds";
		return this;
	}

	/**
	 * Set the time unit in milliseconds
	 */
	ScheduledTask function inMilliseconds(){
		doLog( "inMilliseconds" );

		variables.timeUnit = "milliseconds";
		return this;
	}

	/**
	 * Set the time unit in minutes
	 */
	ScheduledTask function inMinutes(){
		doLog( "inMinutes" );

		variables.timeUnit = "minutes";
		return this;
	}

	/**
	 * Set the time unit in nanoseconds
	 */
	ScheduledTask function inNanoseconds(){
		doLog( "inNanoseconds" );

		variables.timeUnit = "nanoseconds";
		return this;
	}

	/**
	 * Set the time unit in seconds
	 */
	ScheduledTask function inSeconds(){
		doLog( "inSeconds" );

		variables.timeUnit = "seconds";
		return this;
	}

	/**
	 * Validates an incoming string to adhere to either: HH:mm
	 *
	 * @time The time to check
	 *
	 * @throws InvalidTimeException - If the time is invalid, else it just continues operation
	 */
	function validateTime( required time ){
		// Regex check
		if ( !reFind( "^[0-2][0-9]\:[0-5][0-9]$", arguments.time ) ) {
			throw(
				message = "Invalid time representation (#arguments.time#). Time is represented in 24 hour minute format => HH:mm",
				type    = "InvalidTimeException"
			);
		}
	}

	/**
	 * Get a Java localDateTime object using the current date/time and timezone
	 */
	function getJavaNow(){
		return variables.dateTimeHelper.toLocalDateTime( now(), this.getTimezone() );
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
	 * This utility method gives us the first business day of the month in Java format
	 *
	 * @time     The specific time using 24 hour format => HH:mm, defaults to midnight
	 * @addMonth Boolean to specify adding a month to today's date
	 * @now      The date to use as the starting point, defaults to now()
	 */
	private function getFirstBusinessDayOfTheMonth(
		string time      = "00:00",
		boolean addMonth = false,
		date now         = now()
	){
		// Get the last day of the month
		return variables.dateTimeHelper
			.toLocalDateTime(
				arguments.addMonth ? dateAdd( "m", 1, arguments.now ) : arguments.now,
				this.getTimezone()
			)
			// First business day of the month
			.with(
				createObject( "java", "java.time.temporal.TemporalAdjusters" ).firstInMonth(
					createObject( "java", "java.time.DayOfWeek" ).MONDAY
				)
			)
			// Specific Time
			.withHour( javacast( "int", getToken( arguments.time, 1, ":" ) ) )
			.withMinute( javacast( "int", getToken( arguments.time, 2, ":" ) ) )
			.withSecond( javacast( "int", 0 ) );
	}

	/**
	 * This utility method gives us the last business day of the month in Java format
	 *
	 * @time     The specific time using 24 hour format => HH:mm, defaults to midnight
	 * @addMonth Boolean to specify adding a month to today's date
	 * @now      The date to use as the starting point, defaults to now()
	 */
	private function getLastBusinessDayOfTheMonth(
		string time      = "00:00",
		boolean addMonth = false,
		date now         = now()
	){
		doLog( "getLastBusinessDayOfTheMonth" );

		// Get the last day of the month
		var lastDay = variables.dateTimeHelper
			.toLocalDateTime(
				arguments.addMonth ? dateAdd( "m", 1, arguments.now ) : arguments.now,
				this.getTimezone()
			)
			.with( createObject( "java", "java.time.temporal.TemporalAdjusters" ).lastDayOfMonth() )
			// Specific Time
			.withHour( javacast( "int", getToken( arguments.time, 1, ":" ) ) )
			.withMinute( javacast( "int", getToken( arguments.time, 2, ":" ) ) )
			.withSecond( javacast( "int", 0 ) );
		// Verify if on weekend
		switch ( lastDay.getDayOfWeek().getValue() ) {
			// Sunday - 2 days
			case 7: {
				lastDay = lastDay.minusDays( 2 );
				break;
			}
			// Saturday - 1 day
			case 6: {
				lastDay = lastDay.minusDays( 1 );
				break;
			}
		}

		return lastDay;
	}

	/**
	 * This method is called to set the initial next run time of the task
	 * if none exists it sets it to now or it can be also passed in as an argument
	 *
	 * If a delay is set, it will set the next run time based on the delay and timeUnit
	 *
	 * @nextRun  An instance of java.time.LocalDateTime to set the next run time to
	 * @delay    The delay to set the next run time to
	 * @timeUnit The time unit to use for the delay
	 */
	private function setInitialNextRunTime( any nextRun, numeric delay, string timeUnit ){
		var amount = structKeyExists( arguments, "delay" ) ? arguments.delay : variables.delay;
		var unit   = structKeyExists( arguments, "timeUnit" ) ? arguments.timeUnit : variables.timeUnit;

		if ( !isDate( variables.stats.nextRun ) ) {
			doLog(
				"setInitialNextRunTime",
				{
					delay         : amount,
					timeUnit      : unit,
					nextRunSet    : isDate( variables.stats.nextRun ) ? true : false,
					nextRunInArgs : !isNull( arguments.nextRun )
				}
			);

			if ( !isNull( arguments.nextRun ) && isInstanceOf( arguments.nextRun, "java.time.LocalDateTime" ) )
				variables.stats.nextRun = arguments.nextRun;
			else if ( !isInstanceOf( variables.stats.nextRun, "java.time.LocalDateTime" ) )
				variables.stats.nextRun = getJavaNow();

			if ( amount ) {
				switch ( unit ) {
					case "days":
						variables.stats.nextRun = variables.stats.nextRun.plusDays( javacast( "int", amount ) );
						break;
					case "hours":
						variables.stats.nextRun = variables.stats.nextRun.plusHours( javacast( "int", amount ) );
						break;
					case "minutes":
						variables.stats.nextRun = variables.stats.nextRun.plusMinutes( javacast( "int", amount ) );
						break;
					case "milliseconds":
						variables.stats.nextRun = variables.stats.nextRun.plusSeconds(
							javacast( "int", amount / 1000 )
						);
						break;
					case "microseconds":
						variables.stats.nextRun = variables.stats.nextRun.plusNanos(
							javacast( "int", amount * 1000 )
						);
						break;
					case "nanoseconds":
						variables.stats.nextRun = variables.stats.nextRun.plusNanos( javacast( "int", amount ) );
						break;
					default:
						variables.stats.nextRun = variables.stats.nextRun.plusSeconds( javacast( "int", amount ) );
						break;
				}
			}

			var now       = getJavaNow();
			var startTime = len( variables.startTime ) ? now
				.withHour( javacast( "int", getToken( variables.startTime, 1, ":" ) ) )
				.withMinute( javacast( "int", getToken( variables.startTime, 2, ":" ) ) )
				.withSecond( javacast( "int", 0 ) ) : now
				.withHour( javacast( "int", 0 ) )
				.withMinute( javacast( "int", 0 ) )
				.withSecond( javacast( "int", 0 ) );
			var endTime = len( variables.endTime ) ? now
				.withHour( javacast( "int", getToken( variables.endTime, 1, ":" ) ) )
				.withMinute( javacast( "int", getToken( variables.endTime, 2, ":" ) ) )
				.withSecond( javacast( "int", 0 ) ) : now
				.withHour( javacast( "int", 23 ) )
				.withMinute( javacast( "int", 59 ) )
				.withSecond( javacast( "int", 59 ) );


			doLog(
				"startTime",
				{
					startTime : startTime.toString(),
					comp      : now.compareTo( startTime )
				}
			);
			doLog(
				"endTime",
				{
					endTime : endTime.toString(),
					comp    : now.compareTo( endTime )
				}
			);

			if ( now.compareTo( startTime ) < 0 ) variables.stats.nextRun = startTime;

			if ( now.compareTo( endTime ) > 0 ) variables.stats.nextRun = startTime.plusDays( javacast( "int", 1 ) );

			variables.stats.nextRun = variables.stats.nextRun.toString();
		}
	}

	/**
	 * This method is called to set the next run time of the task based on the timeUnit and period.
	 */
	private function setNextRunTime(){
		doLog( "setNextRunTime", arguments );

		var now = getJavaNow();

		var amount = variables.spacedDelay != 0 ? variables.spacedDelay : variables.period;

		// if overlaps are allowed task is immediately scheduled
		if ( variables.spacedDelay == 0 && variables.stats.lastExecutionTime / 1000 > variables.period ) amount = 0;

		// reset nextRun to empty string to continue with process of setting
		// next run time
		variables.stats.nextRun = "";

		// check if we are a first or last business day of month entry
		if ( variables.firstBusinessDay ) {
			variables.stats.nextRun = getFirstBusinessDayOfTheMonth( variables.taskTime, true );
		} else if ( variables.lastBusinessDay ) {
			variables.stats.nextRun = getLastBusinessDayOfTheMonth( variables.taskTime, true );
		}
		// check if we have a daily start or end time
		else if ( len( variables.startTime ) || len( variables.endTime ) ) {
			var startTime = len( variables.startTime ) ? now
				.withHour( javacast( "int", getToken( variables.startTime, 1, ":" ) ) )
				.withMinute( javacast( "int", getToken( variables.startTime, 2, ":" ) ) )
				.withSecond( javacast( "int", 0 ) ) : now
				.withHour( javacast( "int", 0 ) )
				.withMinute( javacast( "int", 0 ) )
				.withSecond( javacast( "int", 0 ) );
			var endTime = len( variables.endTime ) ? now
				.withHour( javacast( "int", getToken( variables.endTime, 1, ":" ) ) )
				.withMinute( javacast( "int", getToken( variables.endTime, 2, ":" ) ) )
				.withSecond( javacast( "int", 0 ) ) : now
				.withHour( javacast( "int", 23 ) )
				.withMinute( javacast( "int", 59 ) )
				.withSecond( javacast( "int", 59 ) );

			if ( now.compareTo( startTime ) < 0 ) variables.stats.nextRun = startTime;
			else if ( now.compareTo( endTime ) > 0 )
				variables.stats.nextRun = startTime.plusDays( javacast( "int", 1 ) );
		}

		if ( !len( variables.stats.nextRun ) ) {
			switch ( variables.timeUnit ) {
				case "days":
					variables.stats.nextRun = now.plusDays( javacast( "int", amount ) );
					break;
				case "hours":
					variables.stats.nextRun = now.plusHours( javacast( "int", amount ) );
					break;
				case "minutes":
					variables.stats.nextRun = now.plusMinutes( javacast( "int", amount ) );
					break;
				case "milliseconds":
					variables.stats.nextRun = now.plusSeconds( javacast( "int", amount / 1000 ) );
					break;
				case "microseconds":
					variables.stats.nextRun = now.plusNanos( javacast( "int", amount * 1000 ) );
					break;
				case "nanoseconds":
					variables.stats.nextRun = now.plusNanos( javacast( "int", amount ) );
					break;
				default:
					variables.stats.nextRun = now.plusSeconds( javacast( "int", amount ) );
					break;
			}
		}

		variables.stats.nextRun = variables.stats.nextRun.toString();
	}

	/**
	 * Debug logging method
	 */
	private function doLog( required string caller, struct args = {} ){
		if ( variables.debugEnabled ) {
			var message = "ScheduledTask : " & variables.name & " : " & arguments.caller & "()" & (
				structIsEmpty( arguments.args ) ? "" : " : " & serializeJSON( arguments.args )
			);
			variables.System.out.println( message );
		}
	}

}
