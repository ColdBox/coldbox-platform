/**
 * The Async Scheduler is in charge of registering scheduled tasks, starting them, monitoring them and shutting them down if needed.
 *
 * Each scheduler is bound to an scheduled executor class. You can override the executor using the `setExecutor()` method if you so desire.
 * The scheduled executor will be named <code>{name}-scheduler</code>
 *
 * In a ColdBox context, you might have the global scheduler in charge of the global tasks and also 1 per module as well in HMVC fashion.
 * In a ColdBox context, this object will inherit from the ColdBox super type as well dynamically at runtime.
 *
 */
component
	extends  ="coldbox.system.async.tasks.Scheduler"
	accessors="true"
	delegates="Rendering@cbDelegates,
			Interceptor@cbDelegates,
			Settings@cbDelegates,
			Locators@cbDelegates,
			Env@coreDelegates"
	threadsafe
	singleton
{

	/**
	 * --------------------------------------------------------------------------
	 * DI
	 * --------------------------------------------------------------------------
	 */

	property
		name    ="controller"
		inject  ="coldbox" 
		delegate="runEvent,runRoute";
	property
		name    ="cachebox"  
		inject  ="cachebox"
		delegate="getCache";
	property name="log" inject="logbox:logger:{this}";
	property
		name    ="wirebox"
		inject  ="wirebox"
		delegate="getInstance";

	/**
	 * --------------------------------------------------------------------------
	 * Properties
	 * --------------------------------------------------------------------------
	 */

	/**
	 * The cache name to use for server fixation and more. By default we use the <code>template</code> region
	 */
	property name="cacheName";

	/**
	 * The bit that can be used to set all tasks created by this scheduler to always run on one server
	 */
	property name="serverFixation" type="boolean";

	/**
	 * Constructor
	 *
	 * @name                The name of this scheduler
	 * @asyncManager        The async manager we are linked to
	 * @asyncManager.inject coldbox:asyncManager
	 */
	function init( required name, required asyncManager ){
		// Super init
		super.init( arguments.name, arguments.asyncManager );
		// CacheBox Region
		variables.cacheName      = "template";
		// Server fixation
		variables.serverFixation = false;
		return this;
	}

	/**
	 * --------------------------------------------------------------------------
	 * Overidden Methods
	 * --------------------------------------------------------------------------
	 */

	/**
	 * Register a new task in this scheduler that will be executed once the `startup()` is fired or manually
	 * via the run() method of the task.
	 *
	 * @name  The name of this task
	 * @debug Add debugging logs to System out, disabled by default in coldbox.system.web.tasks.ColdBoxScheduledTask
	 *
	 * @return a ScheduledTask object so you can work on the registration of the task
	 */
	ColdBoxScheduledTask function task( required name, boolean debug = false ){
		// Create task with custom name
		var oColdBoxTask = variables.wirebox
			.getInstance(
				"coldbox.system.web.tasks.ColdBoxScheduledTask",
				{
					name     : arguments.name,
					executor : variables.executor,
					debug    : arguments.debug
				}
			)
			// Set ourselves into the task
			.setScheduler( this )
			// Set the default cachename into the task
			.setCacheName( getCacheName() )
			// Server fixation
			.setServerFixation( getServerFixation() )
			// Set default timezone into the task
			.setTimezone( this.getTimezone().getId() );

		// Register the task by name
		variables.tasks[ arguments.name ] = {
			// task name
			"name"         : arguments.name,
			// task object
			"task"         : oColdBoxTask,
			// task scheduled future object
			"future"       : "",
			// when it registers
			"registeredAt" : now(),
			// when it's scheduled
			"scheduledAt"  : "",
			// Tracks if the task has been disabled for startup purposes
			"disabled"     : false,
			// If there is an error scheduling the task
			"error"        : false,
			// Any error messages when scheduling
			"errorMessage" : "",
			// The exception stacktrace if something went wrong scheduling the task
			"stacktrace"   : "",
			// Server Host
			"inetHost"     : variables.util.discoverInetHost(),
			// Server IP
			"localIp"      : variables.util.getServerIp()
		};

		return oColdBoxTask;
	}

}
