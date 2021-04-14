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
		// init
		super.init( argumentCollection = arguments );
		// seed environments
		variables.environments   = [];
		// Can we run on all servers, or just one
		variables.serverFixation = false;
		// CacheBox Region
		variables.cacheName      = "template";

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
	 * Verifies if we can schedule this task or not by looking at the following constraints:
	 *
	 * - disabled
	 * - environments
	 * - when closure
	 */
	boolean function isDisabled(){
		// Call super and if disabled already, then just exit out.
		if ( super.isDisabled() ) {
			return true;
		}

		// Environments Check
		if (
			variables.environments.len() && !variables.environments.containsNoCase(
				variables.controller.getSetting( "environment" )
			)
		) {
			variables.log.info(
				"Skipping task (#getName()#) as it is disabled in the current environment: #variables.controller.getSetting( "environment" )#"
			);
			return true;
		}

		// Not disabled
		return false;
	}

	/**
	 * This method retrieves the selected CacheBox provider that will be used for server fixation and much more.
	 *
	 * @return coldbox.system.cache.providers.IColdBoxProvider
	 */
	function getCache(){
		return variables.cachebox.getCache( variables.cacheName );
	}

}
