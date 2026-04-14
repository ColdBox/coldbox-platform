/**
 * This object represents a scheduled task that will be sent in to a scheduled executor for scheduling.
 * It has a fluent and human dsl for setting it up and restricting is scheduling and frequency of scheduling.
 *
 * A task can be represented as either a closure or a cfc with a `run()` or custom runnable method.
 */
import coldbox.system.async.time.DateTimeHelper;

component extends="coldbox.system.async.tasks.ScheduledTask" accessors="true" {

	/**
	 * --------------------------------------------------------------------------
	 * DI
	 * --------------------------------------------------------------------------
	 */

	property name="controller" inject="coldbox";
	property name="wirebox"    inject="wirebox";
	property name="cachebox"   inject="cachebox";
	property name="log"        inject="logbox:logger:{this}";

	/**
	 * --------------------------------------------------------------------------
	 * Properties
	 * --------------------------------------------------------------------------
	 */

	/**
	 * Execution Environment
	 */
	property name="environments" type="array";

	/**
	 * This indicates that the task should ONLY run on one server and not on all servers clustered for the application.
	 * Please note that this will ONLY work if you are using a distributed cache in your application via CacheBox.
	 * The default cache region we will use is the <code>template</code> cache, which you can connect to any distributed
	 * caching engine like: Redis, Couchbase, Mongo, Elastic, DB etc.
	 */
	property name="serverFixation" type="boolean";

	/**
	 * The cache name to use for server fixation and more. By default we use the <code>template</code> region
	 */
	property name="cacheName";

	/**
	 * How long does the server fixation lock remain for in minutes. This is a fallback value used when
	 * the task period cannot be determined. By default, the lock timeout is calculated from the task's
	 * period to ensure it persists until the next scheduled run. Default fallback is 60 minutes.
	 */
	property name="serverLockTimeout" type="numeric";

	/**
	 * Constructor
	 *
	 * @name     The name of this task
	 * @executor The executor this task will run under and be linked to
	 * @task     The closure or cfc that represents the task (optional)
	 * @method   The method on the cfc to call, defaults to "run" (optional)
	 */
	ColdBoxScheduledTask function init(
		required name,
		required executor,
		any task = "",
		method   = "run"
	){
		// init
		super.init( argumentCollection = arguments );
		// seed environments
		variables.environments      = [];
		// Can we run on all servers, or just one
		variables.serverFixation    = false;
		// How long in minutes will the lock be set for before it expires.
		variables.serverLockTimeout = 60;
		// CacheBox Region
		variables.cacheName         = "template";

		return this;
	}

	/**
	 * Set the environments that this task can run under ONLY
	 *
	 * @environment A string, a list, or an array of environments
	 */
	ColdBoxScheduledTask function onEnvironment( required environment ){
		if ( isSimpleValue( arguments.environment ) ) {
			arguments.environment = listToArray( arguments.environment );
		}
		variables.environments = arguments.environment;
		return this;
	}

	/**
	 * This indicates that the task should ONLY run on one server and not on all servers clustered for the application.
	 * Please note that this will ONLY work if you are using a distributed cache in your application via CacheBox.
	 * The default cache region we will use is the <code>template</code> cache, which you can connect to any distributed
	 * caching engine like: Redis, Couchbase, Mongo, Elastic, DB etc.
	 */
	ColdBoxScheduledTask function onOneServer(){
		variables.serverFixation = true;
		return this;
	}

	/**
	 * This method verifies if the running task is constrained to run on specific valid constraints:
	 *
	 * - when
	 * - dayOfTheMonth
	 * - dayOfTheWeek
	 * - lastBusinessDay
	 * - weekends
	 * - weekdays
	 * - environments
	 * - server fixation
	 *
	 * This method is called by the `run()` method at runtime to determine if the task can be ran at that point in time
	 */
	boolean function isConstrained(){
		// Call super and if constrained already, then just exit out.
		if ( super.isConstrained() ) {
			return true;
		}

		// Environments Check
		if (
			variables.environments.len() && !arrayContainsNoCase(
				variables.environments,
				variables.controller.getSetting( "environment" )
			)
		) {
			variables.log.info(
				"Skipping task (#getName()#) as it is constrained in the current environment: #variables.controller.getSetting( "environment" )#"
			);
			return true;
		}

		// Server fixation constrained
		if ( variables.serverFixation && !canRunOnThisServer() ) {
			return true;
		}

		// Not constrained, run it!
		return false;
	}

	/**
	 * Get the server fixation cache key according to name and scheduler (if any)
	 */
	string function getFixationCacheKey(){
		var key = "cbtasks-server-fixation-#replace( getName(), " ", "-", "all" )#";
		return ( hasScheduler() ? "#key#-#replace( getScheduler().getName(), " ", "-", "all" )#" : key );
	}

	/**
	 * This method is called ALWAYS after a task runs, wether in failure or success but used internally for
	 * any type of cleanups. We override this to handle server fixation cleanup ONLY when needed.
	 */
	function cleanupTaskRun(){
		// Only process cleanup if server fixation is enabled for this task
		if ( !variables.serverFixation ) {
			return;
		}

		// NOTE: We intentionally DO NOT clear the cache item here anymore.
		// The cache item needs to remain in place until it naturally expires (based on task period)
		// so other servers know not to run the task during this period.
		// The cache timeout is set to match the task period in canRunOnThisServer()
		// This prevents the task from running multiple times across different servers.
	}

	/**
	 * Verifies if a task can run on the executed server by using our distributed cache lock strategy.
	 * The cache timeout is set to match the task period so the lock persists until the next scheduled run,
	 * preventing other servers from running the task during this period while still allowing failover
	 * if the locked server goes offline.
	 */
	boolean function canRunOnThisServer(){
		var keyName = getFixationCacheKey();

		// Calculate cache timeout in minutes based on task period
		// This ensures the lock persists until the next run, preventing duplicate executions
		var lockTimeout = calculateLockTimeout();

		// Get existing lock to preserve schedule anchor
		var existingLock = getCache().get( keyName );

		// Get or set the lock, first one wins!
		getCache().getOrSet(
			// key
			keyName,
			// producer
			() => {
				return {
					"task"          : getName(),
					"lockOn"        : now(),
					"serverHost"    : getStats().inetHost,
					"serverIp"      : getStats().localIp,
					"nextRun"       : getStats().nextRun,
					"scheduleStart" : hasScheduler() ? getScheduler().getStartedAt() : now(),
					"period"        : getPeriod(),
					"spacedDelay"   : getSpacedDelay(),
					"timeUnit"      : getTimeUnit()
				};
			},
			// timeout in minutes based on task period
			lockTimeout,
			// no last access timeout
			0
		);

		// Get the lock now. At least one server must have set it by now
		var serverLock = getCache().get( keyName );

		// If no lock something really went wrong, so constrain it and log it
		if ( isNull( local.serverLock ) || !isStruct( local.serverLock ) ) {
			variables.log.error(
				"Server lock for task (#getName()#) is null or not a struct, something is wrong with the cache set, please verify it with key (#keyName#).",
				( !isNull( local.serverLock ) ? local.serverLock : "" )
			);
			return false;
		}

		// Check if we are the same server that holds the lock
		if ( local.serverLock.serverHost eq getStats().inetHost && local.serverLock.serverIp eq getStats().localIp ) {
			// We hold the lock - refresh it while preserving the original scheduleStart
			if (
				!isNull( local.existingLock ) && isStruct( local.existingLock ) && local.existingLock.keyExists( "scheduleStart" )
			) {
				var refreshedLock           = duplicate( local.serverLock );
				refreshedLock.lockOn        = now();
				refreshedLock.nextRun       = getStats().nextRun;
				// Preserve the original schedule anchor
				refreshedLock.scheduleStart = local.existingLock.scheduleStart;
				// Update the lock
				getCache().set( keyName, refreshedLock, lockTimeout, 0 );
			}
			return true;
		} else {
			variables.log.info(
				"Skipping task (#getName()#) as it is constrained to run on one server (#local.serverLock.serverHost#/#local.serverLock.serverIp#). This server (#getStats().inetHost#/#getStats().localIp#) is different."
			);
			return false;
		}
	}

	/**
	 * Override start() to synchronize schedules across servers when server fixation is enabled.
	 * This ensures all servers run the task at aligned intervals even if they start at different times.
	 *
	 * @return A ScheduledFuture from where you can monitor the task
	 */
	function start(){
		// Sync schedules before starting if server fixation is enabled
		if ( variables.serverFixation ) {
			syncScheduleWithCluster();
		}
		return super.start();
	}

	/**
	 * Synchronizes this task's schedule with any existing schedule in the cluster.
	 * If another server has already started this task, we align our schedule to match.
	 * This prevents schedule drift across servers and ensures consistent execution timing.
	 */
	public function syncScheduleWithCluster(){
		var existingLock = getCache().get( getFixationCacheKey() );

		// No existing lock means we're the first server - no sync needed
		if ( isNull( local.existingLock ) || !isStruct( local.existingLock ) ) {
			variables.log.debug( "Task (#getName()#): No existing schedule found, will create schedule anchor" );
			return;
		}

		// Only sync period-based tasks (not spaced delay tasks as they depend on execution time)
		if ( getPeriod() == 0 ) {
			variables.log.debug( "Task (#getName()#): Not a period-based task, skipping schedule sync" );
			return;
		}

		// Verify the lock has schedule metadata
		if (
			!local.existingLock.keyExists( "scheduleStart" ) ||
			!local.existingLock.keyExists( "period" ) ||
			!local.existingLock.keyExists( "timeUnit" )
		) {
			variables.log.warn( "Task (#getName()#): Existing lock missing schedule metadata, cannot sync" );
			return;
		}

		// Calculate when the next aligned run should occur
		var nextAlignedRun = calculateNextAlignedRun(
			local.existingLock.scheduleStart,
			local.existingLock.period,
			local.existingLock.timeUnit
		);

		if ( isNull( local.nextAlignedRun ) ) {
			variables.log.warn( "Task (#getName()#): Could not calculate next aligned run time" );
			return;
		}

		// Calculate delay in our timeUnit to align with the cluster schedule
		adjustDelayToAlignWith( local.nextAlignedRun );

		variables.log.info(
			"Task (#getName()#): Synchronized schedule with cluster. Schedule anchor: #local.existingLock.scheduleStart#, Next aligned run: #local.nextAlignedRun#"
		);
	}

	/**
	 * Calculates the next execution time aligned with the cluster's schedule.
	 *
	 * @scheduleStart The original schedule anchor timestamp
	 * @period        The period value
	 * @timeUnit      The time unit (days, hours, minutes, etc.)
	 *
	 * @return The next aligned execution time as a Java LocalDateTime, or null if calculation fails
	 */
	private function calculateNextAlignedRun(
		required scheduleStart,
		required numeric period,
		required string timeUnit
	){
		try {
			var dateTimeHelper = new coldbox.system.async.time.DateTimeHelper();
			var now            = dateTimeHelper.now( getTimezone().getId() );
			var anchor         = dateTimeHelper.toLocalDateTime( arguments.scheduleStart, getTimezone().getId() );

			// Calculate how much time has passed since the schedule started
			var chronoUnit       = getChronoUnit( arguments.timeUnit );
			var elapsedPeriods   = anchor.until( now, chronoUnit );
			// Calculate how many full periods have passed
			var completedPeriods = ceiling( elapsedPeriods / arguments.period );
			// Calculate the next aligned run time
			var periodsToAdd     = completedPeriods * arguments.period;

			// Add the periods to the anchor to get next aligned time
			switch ( arguments.timeUnit ) {
				case "days":
					return anchor.plusDays( javacast( "long", periodsToAdd ) );
				case "hours":
					return anchor.plusHours( javacast( "long", periodsToAdd ) );
				case "minutes":
					return anchor.plusMinutes( javacast( "long", periodsToAdd ) );
				case "seconds":
					return anchor.plusSeconds( javacast( "long", periodsToAdd ) );
				case "milliseconds":
					return anchor.plusNanos( javacast( "long", periodsToAdd * 1000000 ) );
				default:
					return anchor.plusSeconds( javacast( "long", periodsToAdd ) );
			}
		} catch ( any e ) {
			variables.log.error( "Error calculating next aligned run for task (#getName()#): #e.message#", e );
			return;
		}
	}

	/**
	 * Adjusts the task's initial delay to align with the target execution time.
	 *
	 * @targetTime The target execution time as a Java LocalDateTime
	 */
	private function adjustDelayToAlignWith( required targetTime ){
		try {
			var dateTimeHelper = new coldbox.system.async.time.DateTimeHelper();
			var now            = dateTimeHelper.now( getTimezone().getId() );
			var chronoUnit     = getChronoUnit( getTimeUnit() );

			// Calculate the delay in our timeUnit
			var delayAmount = now.until( arguments.targetTime, chronoUnit );

			// If the target is in the past, set minimal delay
			if ( delayAmount <= 0 ) {
				delayAmount = 1;
			}

			// Update the task's delay
			delay( delayAmount, getTimeUnit(), true );

			variables.log.debug(
				"Task (#getName()#): Adjusted initial delay to #delayAmount# #getTimeUnit()# to align with cluster schedule"
			);
		} catch ( any e ) {
			variables.log.error( "Error adjusting delay for task (#getName()#): #e.message#", e );
		}
	}

	/**
	 * Get the Java ChronoUnit constant for the given time unit string
	 *
	 * @timeUnit The time unit string (days, hours, minutes, etc.)
	 *
	 * @return The Java ChronoUnit constant
	 */
	private function getChronoUnit( required string timeUnit ){
		var dateTimeHelper = new coldbox.system.async.time.DateTimeHelper();
		switch ( arguments.timeUnit ) {
			case "days":
				return dateTimeHelper.DAYS;
			case "hours":
				return dateTimeHelper.HOURS;
			case "minutes":
				return dateTimeHelper.MINUTES;
			case "seconds":
				return dateTimeHelper.SECONDS;
			case "milliseconds":
				return dateTimeHelper.MILLIS;
			default:
				return dateTimeHelper.SECONDS;
		}
	}

	/**
	 * Calculate the cache lock timeout in minutes based on the task's period.
	 * This ensures the lock persists until the next scheduled run while allowing failover.
	 * Falls back to serverLockTimeout if period cannot be determined.
	 *
	 * @return numeric The timeout in minutes
	 */
	private numeric function calculateLockTimeout(){
		// If we have a period set, convert it to minutes
		if ( getPeriod() > 0 ) {
			return max(
				1,
				ceiling(
					DateTimeHelper.timeUnitToMinutes(
						value          = getPeriod(),
						targetTimeUnit = getTimeUnit(),
						defaultValue   = variables.serverLockTimeout
					)
				)
			);
		}
		// If we have a spaced delay, use that
		else if ( getSpacedDelay() > 0 ) {
			return max(
				1,
				ceiling(
					DateTimeHelper.timeUnitToMinutes(
						value          = getSpacedDelay(),
						targetTimeUnit = getTimeUnit(),
						defaultValue   = variables.serverLockTimeout
					)
				)
			);
		}
		// Fall back to the configured serverLockTimeout
		return variables.serverLockTimeout;
	}

	/**
	 * This method retrieves the selected CacheBox provider that will be used for server fixation and much more.
	 *
	 * @return coldbox.system.cache.providers.IColdBoxProvider
	 */
	function getCache(){
		return variables.cachebox.getCache( variables.cacheName );
	}

	/**
	 * Send info messages to LogBox
	 *
	 * @var Variable/Message to send
	 */
	ScheduledTask function out( required var ){
		variables.log.info( arguments.var.toString() );
		return this;
	}

	/**
	 * Send errors to LogBox
	 *
	 * @var Variable/Message to send
	 */
	ScheduledTask function err( required var ){
		variables.log.error( arguments.var.toString() );
		return this;
	}

}
