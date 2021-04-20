/**
 * This object represents a scheduled task that will be sent in to a scheduled executor for scheduling.
 * It has a fluent and human dsl for setting it up and restricting is scheduling and frequency of scheduling.
 *
 * A task can be represented as either a closure or a cfc with a `run()` or custom runnable method.
 */
component accessors="true" {

	/**
	 * The delay or time to wait before we execute the task in the scheduler
	 */
	property name="delay" type="numeric";

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
	property name="timeunit";

	/**
	 * The task closure or CFC to execute in the task
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
	 * A closure, that if registered, determines if this task will be sent for scheduling or not.
	 * It is both evaluated at scheduling and at runtime.
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
	 * The collection of stats for the task: { created, lastRun, nextRun, totalRuns, totalFailures, totalSuccess, lastResult, neverRun, lastExecutionTime }
	 */
	property name="stats" type="struct";

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
	 * The constraint of what day of the month we need to run on: 1-31
	 */
	property name="dayOfTheMonth" type="numeric";

	/**
	 * The constraint of what day of the week this runs on: 1-7
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
	 * Constraint to run only on the last business day of the month
	 */
	property name="lastBusinessDay" type="boolean";

	/**
	 * By default tasks execute in an interval frequency which can cause overlaps if tasks
	 * take longer than their periods. With this boolean flag turned on, the schedulers
	 * don't kick off the intervals until the tasks finish executing. Meaning no overlaps.
	 */
	property name="noOverlaps" type="boolean";

	/**
	 * Get the ColdBox utility object
	 */
	property name="util";

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
		// Utility class
		variables.util             = new coldbox.system.core.util.Util();
		// Link up the executor and name
		variables.executor         = arguments.executor;
		variables.name             = arguments.name;
		// time unit helper
		variables.chronoUnitHelper = new coldbox.system.async.time.ChronoUnit();
		variables.timeUnitHelper   = new coldbox.system.async.time.TimeUnit();
		// System Helper
		variables.System           = createObject( "java", "java.lang.System" );
		// Init Properties
		variables.task             = arguments.task;
		variables.method           = arguments.method;
		// Default Frequencies
		variables.period           = 0;
		variables.delay            = 0;
		variables.spacedDelay      = 0;
		variables.timeUnit         = "milliseconds";
		variables.noOverlap        = false;
		// Constraints
		variables.disabled         = false;
		variables.when             = "";
		variables.dayOfTheMonth    = 0;
		variables.dayOfTheWeek     = 0;
		variables.weekends         = false;
		variables.weekdays         = false;
		variables.lastBusinessDay  = false;
		variables.noOverlaps       = false;
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
			// When's the next execution
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
		variables.timezone = createObject( "java", "java.time.ZoneId" ).of( arguments.timezone );
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
	 * Enable the task when disabled so we can run again
	 */
	ScheduledTask function enable(){
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
		return variables.disabled;
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
		var now = getJavaNow();

		// When Closure that dictates if the task can be scheduled/ran: true => yes, false => no
		if ( isClosure( variables.when ) && !variables.when( this ) ) {
			return true;
		}

		// Do we have a day of the month constraint? and the same as the running date/time? Else skip it
		if (
			variables.dayOfTheMonth > 0 &&
			now.getDayOfMonth() != variables.dayOfTheMonth
		) {
			return true;
		}

		// Do we have a last business day constraint
		if (
			variables.lastBusinessDay &&
			now.getDayOfMonth() != getLastDayOfTheMonth().getDayOfMonth()
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

		return false;
	}

	/**
	 * This is the runnable proxy method that executes your code by the executors
	 */
	function run(){
		var sTime = getTickCount();

		// If disabled or paused
		if ( isDisabled() ) {
			return;
		}

		// Check for constraints of execution
		if ( isConstrained() ) {
			return;
		}

		// Mark the task as it wil run now for the first time
		variables.stats.neverRun = false;

		try {
			// Before Interceptors
			if ( hasScheduler() ) {
				getScheduler().beforeAnyTask( this );
			}
			if ( isClosure( variables.beforeTask ) ) {
				variables.beforeTask( this );
			}

			// Target task call callable
			if ( isClosure( variables.task ) || isCustomFunction( variables.task ) ) {
				variables.stats.lastResult = variables.task() ?: "";
			} else {
				variables.stats.lastResult = invoke( variables.task, variables.method ) ?: "";
			}

			// After Interceptor
			if ( isClosure( variables.afterTask ) ) {
				variables.afterTask( this, variables.stats.lastResult );
			}
			if ( hasScheduler() ) {
				getScheduler().afterAnyTask( this, variables.stats.lastResult );
			}

			// store successes and call success interceptor
			variables.stats.totalSuccess = variables.stats.totalSuccess + 1;
			if ( isClosure( variables.onTaskSuccess ) ) {
				variables.onTaskSuccess( this, variables.stats.lastResult );
			}
			if ( hasScheduler() ) {
				getScheduler().onAnyTaskSuccess( this, variables.stats.lastResult );
			}
		} catch ( any e ) {
			// store failures
			variables.stats.totalFailures = variables.stats.totalFailures + 1;
			// Life Cycle
			if ( isClosure( variables.onTaskFailure ) ) {
				variables.onTaskFailure( this, e );
			}
			if ( hasScheduler() ) {
				getScheduler().onAnyTaskError( this, e );
			}
		} finally {
			// Store finalization stats
			variables.stats.lastRun           = now();
			variables.stats.totalRuns         = variables.stats.totalRuns + 1;
			variables.stats.lastExecutionTime = getTickCount() - sTime;
			// Call internal cleanups event
			cleanupTaskRun();
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
		if ( variables.noOverlaps and variables.spacedDelay eq 0 ) {
			variables.spacedDelay = variables.period;
		}

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
	ScheduledTask function delay( numeric delay, timeUnit = "milliseconds" ){
		variables.delay    = arguments.delay;
		variables.timeUnit = arguments.timeUnit;
		return this;
	}

	/**
	 * Run the task every custom spaced delay of execution, meaning no overlaps
	 *
	 * @delay The delay that will be used before executing the task
	 * @timeUnit The time unit to use, available units are: days, hours, microseconds, milliseconds, minutes, nanoseconds, and seconds. The default is milliseconds
	 */
	ScheduledTask function spacedDelay( numeric spacedDelay, timeUnit = "milliseconds" ){
		variables.spacedDelay = arguments.spacedDelay;
		variables.timeUnit    = arguments.timeUnit;
		return this;
	}

	/**
	 * Calling this method prevents task frequencies to overlap.  By default all tasks are executed with an
	 * interval but ccould potentially overlap if they take longer to execute than the period.
	 *
	 * @period
	 * @timeUnit
	 */
	ScheduledTask function withNoOverlaps(){
		variables.noOverlaps = true;
		return this;
	}

	/**
	 * Run the task every custom period of execution
	 *
	 * @period The period of execution
	 * @timeUnit The time unit to use, available units are: days, hours, microseconds, milliseconds, minutes, nanoseconds, and seconds. The default is milliseconds
	 */
	ScheduledTask function every( numeric period, timeUnit = "milliseconds" ){
		variables.period   = arguments.period;
		variables.timeUnit = arguments.timeUnit;
		return this;
	}

	/**
	 * Run the task every minute from the time it get's scheduled
	 */
	ScheduledTask function everyMinute(){
		variables.period   = 1;
		variables.timeUnit = "minutes";
		return this;
	}

	/**
	 * Run the task every hour from the time it get's scheduled
	 */
	ScheduledTask function everyHour(){
		variables.period   = 1;
		variables.timeUnit = "hours";
		return this;
	}

	/**
	 * Set the period to be hourly at a specific minute mark and 00 seconds
	 *
	 * @minutes The minutes past the hour mark
	 */
	ScheduledTask function everyHourAt( required numeric minutes ){
		var now     = getJavaNow();
		var nextRun = now.withMinute( javacast( "int", arguments.minutes ) ).withSecond( javacast( "int", 0 ) );
		// If we passed it, then move the hour by 1
		if ( now.compareTo( nextRun ) > 0 ) {
			nextRun = nextRun.plusHours( javacast( "int", 1 ) );
		}
		// Get the duration time for the next run and delay accordingly
		this.delay(
			variables.chronoUnitHelper
				.duration()
				.getNative()
				.between( now, nextRun )
				.getSeconds(),
			"seconds"
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
			variables.chronoUnitHelper
				.duration()
				.getNative()
				.between( now, nextRun )
				.getSeconds(),
			"seconds"
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
		// Check for mintues else add them
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
			variables.chronoUnitHelper
				.duration()
				.getNative()
				.between( now, nextRun )
				.getSeconds(),
			"seconds"
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
		var now     = getJavaNow();
		// Set at midnight
		var nextRun = now
			// Sunday
			.with( variables.chronoUnitHelper.ChronoField.DAY_OF_WEEK, javacast( "int", 7 ) )
			// Midnight
			.withHour( javacast( "int", 0 ) )
			.withMinute( javacast( "int", 0 ) )
			.withSecond( javacast( "int", 0 ) );
		// If we passed it, then move to the next week
		if ( now.compareTo( nextRun ) > 0 ) {
			nextRun = nextRun.plusWeeks( javacast( "int", 1 ) );
		}
		// Get the duration time for the next run and delay accordingly
		this.delay(
			variables.chronoUnitHelper
				.duration()
				.getNative()
				.between( now, nextRun )
				.getSeconds(),
			"seconds"
		);
		// Set the period to every week in seconds
		variables.period       = variables.timeUnitHelper.get( "days" ).toSeconds( 7 );
		variables.timeUnit     = "seconds";
		variables.dayOfTheWeek = 7;
		return this;
	}

	/**
	 * Run the task weekly on the given day of the week and time
	 *
	 * @dayOfWeek The day of the week from 1 (Monday) -> 7 (Sunday)
	 * @time The specific time using 24 hour format => HH:mm, defaults to midnight
	 */
	ScheduledTask function everyWeekOn( required numeric dayOfWeek, string time = "00:00" ){
		var now = getJavaNow();
		// Check for mintues else add them
		if ( !find( ":", arguments.time ) ) {
			arguments.time &= ":00";
		}
		// Validate time format
		validateTime( arguments.time );
		var nextRun = now
			// Given day
			.with( variables.chronoUnitHelper.ChronoField.DAY_OF_WEEK, javacast( "int", arguments.dayOfWeek ) )
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
			variables.chronoUnitHelper
				.duration()
				.getNative()
				.between( now, nextRun )
				.getSeconds(),
			"seconds"
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
		var now     = getJavaNow();
		// Set at midnight
		var nextRun = now
			// First day of the month
			.with( variables.chronoUnitHelper.ChronoField.DAY_OF_MONTH, javacast( "int", 1 ) )
			// Midnight
			.withHour( javacast( "int", 0 ) )
			.withMinute( javacast( "int", 0 ) )
			.withSecond( javacast( "int", 0 ) );

		if ( now.compareTo( nextRun ) > 0 ) {
			nextRun = nextRun.plusMonths( javacast( "int", 1 ) );
		}
		// Get the duration time for the next run and delay accordingly
		this.delay(
			variables.chronoUnitHelper
				.duration()
				.getNative()
				.between( now, nextRun )
				.getSeconds(),
			"seconds"
		);
		// Set the period to one day. And make sure we add a constraint for it
		// Mostly because every month is different
		variables.period        = variables.timeUnitHelper.get( "days" ).toSeconds( 1 );
		variables.timeUnit      = "seconds";
		variables.dayOfTheMonth = 1;
		return this;
	}

	/**
	 * Run the task every month on a specific day and time
	 *
	 * @day Which day of the month
	 * @time The specific time using 24 hour format => HH:mm, defaults to midnight
	 */
	ScheduledTask function everyMonthOn( required numeric day, string time = "00:00" ){
		var now = getJavaNow();
		// Check for mintues else add them
		if ( !find( ":", arguments.time ) ) {
			arguments.time &= ":00";
		}
		// Validate time format
		validateTime( arguments.time );
		// Get new time
		var nextRun = now
			// First day of the month
			.with( variables.chronoUnitHelper.ChronoField.DAY_OF_MONTH, javacast( "int", arguments.day ) )
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
			variables.chronoUnitHelper
				.duration()
				.getNative()
				.between( now, nextRun )
				.getSeconds(),
			"seconds"
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
		var now = getJavaNow();
		// Check for mintues else add them
		if ( !find( ":", arguments.time ) ) {
			arguments.time &= ":00";
		}
		// Validate time format
		validateTime( arguments.time );
		// Get new time
		var nextRun = now
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
		// Have we passed it
		if ( now.compareTo( nextRun ) > 0 ) {
			nextRun = nextRun.plusMonths( javacast( "int", 1 ) );
		}
		// Get the duration time for the next run and delay accordingly
		this.delay(
			variables.chronoUnitHelper
				.duration()
				.getNative()
				.between( now, nextRun )
				.getSeconds(),
			"seconds"
		);
		// Set the period to one day. And make sure we add a constraint for it
		// Mostly because every month is different
		variables.period        = variables.timeUnitHelper.get( "days" ).toSeconds( 1 );
		variables.timeUnit      = "seconds";
		variables.dayOfTheMonth = 1;
		return this;
	}

	/**
	 * This utility method gives us the last day of the month in Java format
	 */
	private function getLastDayOfTheMonth(){
		// Get the last day of the month
		var lastDay = variables.chronoUnitHelper
			.toLocalDateTime( now(), getTimezone() )
			.with( createObject( "java", "java.time.temporal.TemporalAdjusters" ).lastDayOfMonth() );
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
	 * Run the task on the last business day of the month
	 *
	 * @time The specific time using 24 hour format => HH:mm, defaults to midnight
	 */
	ScheduledTask function onLastBusinessDayOfTheMonth( string time = "00:00" ){
		var now = getJavaNow();
		// Check for mintues else add them
		if ( !find( ":", arguments.time ) ) {
			arguments.time &= ":00";
		}
		// Validate time format
		validateTime( arguments.time );
		// Get the last day of the month
		var nextRun = getLastDayOfTheMonth()
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
			variables.chronoUnitHelper
				.duration()
				.getNative()
				.between( now, nextRun )
				.getSeconds(),
			"seconds"
		);
		// Set the period to one day. And make sure we add a constraint for it
		// Mostly because every month is different
		variables.period          = variables.timeUnitHelper.get( "days" ).toSeconds( 1 );
		variables.timeUnit        = "seconds";
		variables.lastBusinessDay = true;
		return this;
	}

	/**
	 * Run the task on the first day of the year at midnight
	 */
	ScheduledTask function everyYear(){
		var now     = getJavaNow();
		// Set at midnight
		var nextRun = now
			// First day of the month
			.with( variables.chronoUnitHelper.ChronoField.DAY_OF_YEAR, javacast( "int", 1 ) )
			// Midnight
			.withHour( javacast( "int", 0 ) )
			.withMinute( javacast( "int", 0 ) )
			.withSecond( javacast( "int", 0 ) );

		if ( now.compareTo( nextRun ) > 0 ) {
			nextRun = nextRun.plusYears( javacast( "int", 1 ) );
		}
		// Get the duration time for the next run and delay accordingly
		this.delay(
			variables.chronoUnitHelper
				.duration()
				.getNative()
				.between( now, nextRun )
				.getSeconds(),
			"seconds"
		);
		// Set the period to
		variables.period   = variables.timeUnitHelper.get( "days" ).toSeconds( 365 );
		variables.timeUnit = "seconds";
		return this;
	}

	/**
	 * Set the period to be weekly at a specific time at a specific day of the week
	 *
	 * @month The month in numeric format 1-12
	 * @day Which day of the month
	 * @time The specific time using 24 hour format => HH:mm, defaults to 00:00
	 */
	ScheduledTask function everyYearOn(
		required numeric month,
		required numeric day,
		required string time = "00:00"
	){
		var now = getJavaNow();
		// Check for mintues else add them
		if ( !find( ":", arguments.time ) ) {
			arguments.time &= ":00";
		}
		// Validate time format
		validateTime( arguments.time );
		var nextRun = now
			// Specific month
			.with( variables.chronoUnitHelper.ChronoField.MONTH_OF_YEAR, javacast( "int", arguments.month ) )
			// Specific day of the month
			.with( variables.chronoUnitHelper.ChronoField.DAY_OF_MONTH, javacast( "int", arguments.day ) )
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
			variables.chronoUnitHelper
				.duration()
				.getNative()
				.between( now, nextRun )
				.getSeconds(),
			"seconds"
		);
		// Set the period to
		variables.period   = variables.timeUnitHelper.get( "days" ).toSeconds( 365 );
		variables.timeUnit = "seconds";
		return this;
	}

	/**
	 * Run the task on saturday and sundays
	 *
	 * @time The specific time using 24 hour format => HH:mm, defaults to 00:00
	 */
	ScheduledTask function onWeekends( string time = "00:00" ){
		// Check for mintues else add them
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
			variables.chronoUnitHelper
				.duration()
				.getNative()
				.between( now, nextRun )
				.getSeconds(),
			"seconds"
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
		// Check for mintues else add them
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
			variables.chronoUnitHelper
				.duration()
				.getNative()
				.between( now, nextRun )
				.getSeconds(),
			"seconds"
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
		return this.everyWeekOn( 1, arguments.time );
	}

	/**
	 * Set the period to be on Tuesdays
	 *
	 * @time The specific time using 24 hour format => HH:mm, defaults to 00:00
	 */
	ScheduledTask function onTuesdays( string time = "00:00" ){
		return this.everyWeekOn( 2, arguments.time );
	}

	/**
	 * Set the period to be on Wednesdays
	 *
	 * @time The specific time using 24 hour format => HH:mm, defaults to 00:00
	 */
	ScheduledTask function onWednesdays( string time = "00:00" ){
		return this.everyWeekOn( 3, arguments.time );
	}

	/**
	 * Set the period to be on Thursdays
	 *
	 * @time The specific time using 24 hour format => HH:mm, defaults to 00:00
	 */
	ScheduledTask function onThursdays( string time = "00:00" ){
		return this.everyWeekOn( 4, arguments.time );
	}

	/**
	 * Set the period to be on Fridays
	 *
	 * @time The specific time using 24 hour format => HH:mm, defaults to 00:00
	 */
	ScheduledTask function onFridays( string time = "00:00" ){
		return this.everyWeekOn( 5, arguments.time );
	}

	/**
	 * Set the period to be on Saturdays
	 *
	 * @time The specific time using 24 hour format => HH:mm, defaults to 00:00
	 */
	ScheduledTask function onSaturdays( string time = "00:00" ){
		return this.everyWeekOn( 6, arguments.time );
	}

	/**
	 * Set the period to be on Sundays
	 *
	 * @time The specific time using 24 hour format => HH:mm, defaults to 00:00
	 */
	ScheduledTask function onSundays( string time = "00:00" ){
		return this.everyWeekOn( 7, arguments.time );
	}

	/**
	 * --------------------------------------------------------------------------
	 * TimeUnit Methods
	 * --------------------------------------------------------------------------
	 */

	/**
	 * Set the time unit in days
	 */
	ScheduledTask function inDays(){
		variables.timeUnit = "days";
		return this;
	}

	/**
	 * Set the time unit in hours
	 */
	ScheduledTask function inHours(){
		variables.timeUnit = "hours";
		return this;
	}

	/**
	 * Set the time unit in microseconds
	 */
	ScheduledTask function inMicroseconds(){
		variables.timeUnit = "microseconds";
		return this;
	}

	/**
	 * Set the time unit in milliseconds
	 */
	ScheduledTask function inMilliseconds(){
		variables.timeUnit = "milliseconds";
		return this;
	}

	/**
	 * Set the time unit in minutes
	 */
	ScheduledTask function inMinutes(){
		variables.timeUnit = "minutes";
		return this;
	}

	/**
	 * Set the time unit in nanoseconds
	 */
	ScheduledTask function inNanoseconds(){
		variables.timeUnit = "nanoseconds";
		return this;
	}

	/**
	 * Set the time unit in seconds
	 */
	ScheduledTask function inSeconds(){
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
	private function validateTime( required time ){
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
		return variables.chronoUnitHelper.toLocalDateTime( now(), getTimezone() );
	}

}
