/**
 * This object represents a scheduled task that will be sent in to a scheduled executor for scheduling.
 * It has a fluent and human dsl for setting it up and restricting is scheduling and frequency of scheduling.
 *
 * A task can be represented as either a closure or a cfc with a `run()` or custom runnable method.
 */
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
	 * How long does the server fixation lock remain for. Deafult is 60 minutes.
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
	 * any type of cleanups
	 */
	function cleanupTaskRun(){
		var cacheKey     = getFixationCacheKey();
		// Only cleanup if your are the fixated server
		var fixationData = getCache().get( cacheKey );
		if (
			!isNull( local.fixationData ) && isStruct( local.fixationData ) && local.fixationData.serverhost eq getStats().inetHost && local.fixationData.serverIp eq getStats().localIp
		) {
			// Cleanup server fixation locks after task execution, wether failure or success
			// This way, the tasks can run on a round-robin approach on a clustered environment
			// and not fixated on a specific server
			getCache().clear( cacheKey );
			// Debugging
			variables.log.debug( "Fixation cache key (#cacheKey#) removed by fixated server, task ran!" );
		}
	}

	/**
	 * Verifies if a task can run on the executed server by using our distributed cache lock strategy
	 */
	boolean function canRunOnThisServer(){
		var keyName = getFixationCacheKey();
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
					"serverIp"   : getStats().localIp
				};
			},
			// timeout in minutes: defaults to 60 minutes and 0 last access timeout
			variables.serverLockTimeout,
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
		// Else, it exists, check we are the same server that locked! If true, then we can run it baby!
		else if (
			local.serverLock.serverHost eq getStats().inetHost && local.serverLock.serverIp eq getStats().localIp
		) {
			return true;
		} else {
			variables.log.info(
				"Skipping task (#getName()#) as it is constrained to run on one server (#local.serverLock.serverHost#/#local.serverLock.serverIp#). This server (#getStats().inetHost#/#getStats().localIp#) is different."
			);
			return false;
		}
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
