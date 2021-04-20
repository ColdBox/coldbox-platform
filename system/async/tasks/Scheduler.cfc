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
component accessors="true" singleton {

	/**
	 * --------------------------------------------------------------------------
	 * Properties
	 * --------------------------------------------------------------------------
	 */

	/**
	 * The name of this scheduler
	 */
	property name="name";

	/**
	 * An ordered struct of all the tasks this scheduler manages
	 */
	property name="tasks" type="struct";

	/**
	 * The Scheduled Executor we are bound to
	 */
	property name="executor";

	/**
	 * The default timezone to use for task executions
	 */
	property name="timezone";

	/**
	 * Constructor
	 *
	 * @name The name of this scheduler
	 * @asyncManager The async manager we are linked to
	 */
	function init( required name, required asyncManager ){
		// Utility class
		variables.util         = new coldbox.system.core.util.Util();
		// Name
		variables.name         = arguments.name;
		// The async manager
		variables.asyncManager = arguments.asyncManager;
		// The collection of tasks we will run
		variables.tasks        = structNew( "ordered" );
		// Default TimeZone to UTC for all tasks
		variables.timezone     = createObject( "java", "java.time.ZoneId" ).systemDefault();
		// Build out the executor for this scheduler
		variables.executor     = arguments.asyncManager.newExecutor(
			name: arguments.name & "-scheduler",
			type: "scheduled"
		);
		// Bit that denotes if this scheduler has been started or not
		variables.started = false;
		// Send notice
		arguments.asyncManager.out( "√ Scheduler (#arguments.name#) has been registered" );

		return this;
	}

	/**
	 * Usually where concrete implementations add their tasks and configs
	 */
	function configure(){
	}

	/**
	 * Set the timezone for all tasks to use using the timezone string identifier
	 *
	 * @see https://docs.oracle.com/en/java/javase/11/docs/api/java.base/java/time/ZoneId.html
	 *
	 * @timezone The timezone string identifier
	 */
	Scheduler function setTimezone( required timezone ){
		variables.timezone = createObject( "java", "java.time.ZoneId" ).of( arguments.timezone );
		return this;
	}

	/**
	 * Register a new task in this scheduler that will be executed once the `startup()` is fired or manually
	 * via the run() method of the task.
	 *
	 * @return a ScheduledTask object so you can work on the registration of the task
	 */
	ScheduledTask function task( required name ){
		// Create task with custom name
		var oTask = variables.executor
			// Give me the task broda!
			.newTask( arguments.name )
			// Register ourselves in the task
			.setScheduler( this )
			// Set default timezone into the task
			.setTimezone( getTimezone().getId() );

		// Register the task by name
		variables.tasks[ arguments.name ] = {
			// task name
			"name"         : arguments.name,
			// task object
			"task"         : oTask,
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

		return oTask;
	}

	/**
	 * --------------------------------------------------------------------------
	 * Startup/Shutdown Methods
	 * --------------------------------------------------------------------------
	 */

	/**
	 * Startup this scheduler and all of it's scheduled tasks
	 */
	Scheduler function startup(){
		if ( !variables.started ) {
			lock name="scheduler-#getName()#-startup" type="exclusive" timeout="45" throwOnTimeout="true" {
				if ( !variables.started ) {
					// Iterate over tasks and send them off for scheduling
					variables.tasks.each( function( taskName, taskRecord ){
						// Verify we can start it up the task or not
						if ( arguments.taskRecord.task.isDisabled() ) {
							arguments.taskRecord.disabled = true;
							variables.asyncManager.out(
								"- Scheduler (#getName()#) skipping task (#arguments.taskRecord.task.getName()#) as it is disabled."
							);
							// Continue iteration
							return;
						} else {
							// Log scheduling startup
							variables.asyncManager.out(
								"- Scheduler (#getName()#) scheduling task (#arguments.taskRecord.task.getName()#)..."
							);
						}

						// Send it off for scheduling
						try {
							arguments.taskRecord.future      = arguments.taskRecord.task.start();
							arguments.taskRecord.scheduledAt = now();
							variables.asyncManager.out(
								"√ Task (#arguments.taskRecord.task.getName()#) scheduled successfully."
							);
						} catch ( any e ) {
							variables.asyncManager.err(
								"X Error scheduling task (#arguments.taskRecord.task.getName()#) => #e.message# #e.detail#"
							);
							arguments.taskRecord.error        = true;
							arguments.taskRecord.errorMessage = e.message & e.detail;
							arguments.taskRecord.stackTrace   = e.stacktrace;
						}
					} );

					// Mark scheduler as started
					variables.started = true;

					// callback
					this.onStartup();

					// Log it
					variables.asyncManager.out( "√ Scheduler (#getname()#) has started!" );
				}
				// end double if not started
			}
			// end lock
		}
		// end if not started

		return this;
	}

	/**
	 * Check if this scheduler has started or not
	 */
	boolean function hasStarted(){
		return variables.started;
	}

	/**
	 * Shutdown this scheduler by calling the executor to shutdown and disabling all tasks
	 */
	Scheduler function shutdown(){
		// callback
		this.onShutdown();
		// shutdown executor
		variables.executor.shutdownNow();
		// Mark it
		variables.started = false;
		// Log it
		variables.asyncManager.out( "√ Scheduler (#getName()#) has been shutdown!" );
		return this;
	}

	/**
	 * --------------------------------------------------------------------------
	 * Life - Cycle Callbacks
	 * --------------------------------------------------------------------------
	 */

	/**
	 * Called before the scheduler is going to be shutdown
	 */
	function onShutdown(){
	}

	/**
	 * Called after the scheduler has registered all schedules
	 */
	function onStartup(){
	}

	/**
	 * Called whenever ANY task fails
	 *
	 * @task The task that got executed
	 * @exception The ColdFusion exception object
	 *
	 */
	function onAnyTaskError( required task, required exception ){
	}

	/**
	 * Called whenever ANY task succeeds
	 *
	 * @task The task that got executed
	 * @result The result (if any) that the task produced
	 *
	 */
	function onAnyTaskSuccess( required task, result ){
	}

	/**
	 * Called before ANY task runs
	 *
	 * @task The task about to be executed
	 *
	 */
	function beforeAnyTask( required task ){
	}

	/**
	 * Called after ANY task runs
	 *
	 * @task The task that got executed
	 * @result The result (if any) that the task produced
	 *
	 */
	function afterAnyTask( required task, result ){
	}

	/**
	 * --------------------------------------------------------------------------
	 * Utility Methods
	 * --------------------------------------------------------------------------
	 */

	/**
	 * Builds out a report for all the registered tasks in this scheduler
	 */
	struct function getTaskStats(){
		// return back a struct of stats for each registered task
		return variables.tasks.map( function( key, record ){
			return arguments.record.task.getStats();
		} );
	}

	/**
	 * Get an array of all the tasks managed by this scheduler
	 */
	array function getRegisteredTasks(){
		var taskKeys = variables.tasks.keyArray();
		taskKeys.sort( "textnocase" );
		return taskKeys;
	}

	/**
	 * Checks if this scheduler manages a task by name
	 *
	 * @name The name of the task to search
	 */
	boolean function hasTask( required name ){
		return variables.tasks.keyExists( arguments.name );
	}

	/**
	 * Get's a task record from the collection by name
	 *
	 * @name The name of the task
	 *
	 * @throws UnregisteredTaskException if no task is found under that name
	 *
	 * @return The task record struct: { name, task, future, scheduledAt, registeredAt, error, errorMessage, stacktrace }
	 */
	struct function getTaskRecord( required name ){
		if ( hasTask( arguments.name ) ) {
			return variables.tasks[ arguments.name ];
		}
		throw( type: "UnregisteredTaskException", message: "No task found with the name: #arguments.name#" );
	}

	/**
	 * Unregister a task from this scheduler
	 *
	 * @name The name of the task to remove
	 *
	 * @throws UnregisteredTaskException if no task is found under that name
	 */
	Scheduler function removeTask( required name ){
		// Remove from executor if registered
		var taskRecord = getTaskRecord( arguments.name );

		// Check if the task has been registered so we can cancel it
		if ( isObject( taskRecord.future ) ) {
			taskRecord.future.cancel( mayInterruptIfRunning = true );
		}

		// Delete it
		variables.tasks.delete( arguments.name );
		return this;
	}

}
