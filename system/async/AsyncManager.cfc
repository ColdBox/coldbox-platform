/**
 * The ColdBox Async Manager is in charge of creating runnable proxies based on
 * components or closures that can be spawned as native Java Completable future
 * to support you with multi-threaded and asynchronous programming.
 *
 * The manager can also help you create executor services so you can define your own
 * thread pools according to your needs.  If not, the majority of the asynchronous
 * methods will use the ForkJoin.commonPool() implementation
 */
component accessors="true" singleton {

	/**
	 * A collection of Schedulers you can register in the async manager
	 */
	property name="schedules" type="struct";

	// Static Executors Factory Class
	this.executors = new Executors();

	/**
	 * Constructor
	 *
	 * @debug Add debugging logs to System out, disabled by default
	 */
	function init( boolean debug = false ){
		variables.debug     = arguments.debug;
		variables.schedules = {};

		return this;
	}

	/****************************************************************
	 * Scheduler Methods *
	 ****************************************************************/

	/**
	 * Create and register a new ColdBox Scheduler task
	 *
	 * @name The name of the task, used for registration
	 * @threads How many threads to assign to the thread scheduler
	 *
	 * @return The ColdBox Schedule class to work with the schedule
	 */
	Schedule function newSchedule( required name, numeric threads = this.executors.DEFAULT_THREADS ){
		// Create the ColdBox Schedule and register it
		variables.schedules[ arguments.name ] = new Schedule(
			arguments.name,
			this.executors.newScheduledThreadPool( arguments.threads )
		);
		// Return it
		return variables.schedules[ arguments.name ];
	}

	/**
	 * Get a registered schedule in this async manager
	 *
	 * @name The scheduler name
	 *
	 * @throws NotFoundException
	 * @return The scheduler object
	 */
	function getSchedule( required name ){
		if ( hasSchedule( arguments.name ) ) {
			return variables.schedules[ arguments.name ];
		}
		throw(
			type    = "ScheduleNotFoundException",
			message = "The schedule you requested does not exist",
			detail  = "Registered schedules are: #variables.schedules.keyList()#"
		);
	}

	/**
	 * Get the array of registered schedules in the system
	 *
	 * @return Array of names
	 */
	array function getScheduleNames(){
		return variables.schedules.keyArray();
	}

	/**
	 * Verify if a scheduler exists
	 *
	 * @name The scheduler name
	 */
	boolean function hasSchedule( required name ){
		return variables.schedules.keyExists( arguments.name );
	}

	/**
	 * Delete a schedule from the registry, if the schedule has not shutdown, it will shutdown the schedule for you
	 *
	 * @name The scheduler name
	 */
	AsyncManager function deleteSchedule( required name ){
		if ( hasSchedule( arguments.name ) ) {
			if ( !variables.schedules[ arguments.name ].isShutdown() ) {
				variables.schedules[ arguments.name ].shutdownNow();
			}
			variables.schedules.delete( arguments.name );
		}
		return this;
	}

	/**
	 * Shutdown all registered schedules in the system
	 *
	 * @force By default it gracefullly shuts them down, else uses the shutdownNow() methods
	 *
	 * @return AsyncManager
	 */
	AsyncManager function shutdownAllSchedules( boolean force = false ){
		variables.schedules.each( function( key, schedule ){
			if ( force ) {
				arguments.schedule.shutdownNow();
			} else {
				arguments.schedule.shutdown();
			}
		} );
		return this;
	}

	/**
	 * Returns a structure of status maps for every registered schedule in the
	 * manager. This is composed of tons of stats about the schedule and its executor
	 *
	 * @return
	 */
	struct function getScheduleStatusMap(){
		return variables.schedules.map( function( key, scheduler ){
			return arguments.scheduler.getStats();
		} );
	}

	/****************************************************************
	 * Future Methods *
	 ****************************************************************/

	/**
	 * Create a new ColdBox future backed by a Java completable future
	 *
	 * @value The actual closure/lambda/udf to run with or a completed value to seed the future with
	 * @executor A custom executor to use with the future, else use the default
	 * @debug Add debugging to system out or not, defaults is false
	 * @loadAppContext Load the CFML engine context into the async threads or not, default is yes.
	 *
	 * @return ColdBox Future completed or new
	 */
	Future function newFuture(
		any value,
		any executor,
		boolean debug          = false,
		boolean loadAppContext = true
	){
		return new Future( argumentCollection = arguments );
	}

	/**
	 * Create a completed ColdBox future backed by a Java Completable Future
	 *
	 * @value The value to complete the future with
	 * @debug Add debugging to system out or not, defaults is false
	 * @loadAppContext Load the CFML engine context into the async threads or not, default is yes.
	 *
	 * @return ColdBox Future completed
	 */
	Future function newCompletedFuture(
		required any value,
		boolean debug          = false,
		boolean loadAppContext = true
	){
		return new Future( argumentCollection = arguments );
	}

	/****************************************************************
	 * Future Shortcuts *
	 ****************************************************************/

	/**
	 * Alias to newFuture().allOf()
	 */
	function allOf(){
		return newFuture().allOf( argumentCollection=arguments );
	}

	/**
	 * Alias to newFuture().allApply()
	 */
	function allApply(){
		return newFuture().allApply( argumentCollection=arguments );
	}

	/**
	 * Alias to newFuture().anyOf()
	 */
	function anyOf(){
		return newFuture().anyOf( argumentCollection=arguments );
	}

}