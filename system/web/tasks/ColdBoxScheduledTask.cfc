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

		// Get or set the lock, first one wins!
		getCache().getOrSet(
			// key
			keyName,
			// producer
			function(){
				return {
					"task"       : getName(),
					"lockOn"     : now(),
					"serverHost" : getStats().inetHost,
					"serverIp"   : getStats().localIp,
					"nextRun"    : getStats().nextRun
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
			return true;
		} else {
			variables.log.info(
				"Skipping task (#getName()#) as it is constrained to run on one server (#local.serverLock.serverHost#/#local.serverLock.serverIp#). This server (#getStats().inetHost#/#getStats().localIp#) is different."
			);
			return false;
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
