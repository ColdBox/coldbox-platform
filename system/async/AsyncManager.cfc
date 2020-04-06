/**
 * The ColdBox Async Manager is in charge of creating runnable proxies based on
 * components or closures that can be spawned as native Java Completable future
 * to support you with multi-threaded and asynchronous programming.
 *
 * The manager can also help you create executor services so you can define your own
 * thread pools according to your needs.  If not, the majority of the asynchronous
 * methods will use the ForkJoin.commonPool() implementation
 */
component accessors="true" singleton{

	/**
	 * A collection of Schedulers you can register in the async manager
	 */
	property name="schedules" type="struct";

	// Static Executors Factory Class
	variables.executors = createObject( "java", "java.util.concurrent.Executors" );

	/**
	 * Constructor
	 *
	 * @debug Add debugging logs to System out, disabled by default
	 */
	function init( boolean debug=false ){
		variables.debug = arguments.debug;
		variables.schedules = {};

		return this;
	}

	/****************************************************************
	 * Scheduler Methods *
	 ****************************************************************/

	/**
	 * Create and register a new ColdBox Scheduler task
	 *
	 * @name The name of the task
	 * @threads How many threads to assign to the thread scheduler
	 *
	 * @return The ColdBox Schedule class to work with the schedule
	 */
	Schedule function newSchedule( required name, int threads=1 ){
		// Create the schedule executor
		var executor = variables.executors.newScheduledThreadPool(
			javacast( "int", arguments.threads )
		);
		// Create the ColdBox Schedule and register it
		variables.schedules[ arguments.name ] = new Schedule( executor );
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
		if( hasSchedule( arguments.name ) ){
			return variables.schedules[ arguments.name ];
		}
		throw(
			type="ScheduleNotFoundException",
			message="The schedule you requested does not exist",
			detail = "Registered schedules are: #variables.schedules.keyArray()#"
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
		if( hasSchedule( arguments.name ) ){
			if( !variables.schedules[ arguments.name ].isShutdown() ){
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
	AsyncManager function shutdownAllSchedules( boolean force=false ){
		variables.schedules.each( function( thisSchedule ) {
			if( force ){
				thisSchedule.shutdownNow();
			} else {
				thisSchedule.shutdown();
			}
		} );
		return this;
	}

	/**
	 * Returns a structure of status maps for every registered schedule in the manager
	 *
	 * @return struct : { isTerminated:boolean, isShutdown: boolean, isRunning:boolean }
	 */
	struct function getScheduleStatusMap(){
		return variables.schedules.map( function( key, scheduler ){
			return {
				"isTerminated" : scheduler.isTerminated(),
				"isShutdown" : scheduler.isShutdown(),
				"isRunning"	: scheduler.isRunning()
			};
		} );
	}

	/****************************************************************
	 * Future Methods *
	 ****************************************************************/

	function newFuture( any value, boolean debug=false, boolean loadAppContext=true ){
		return new Future( argumentCollection = arguments );
	}

	function newCompletedFuture( required any value, boolean debug=false, boolean loadAppContext=true ){
		return newFuture( argumentCollection=arguments );
	}

	/****************************************************************
	 * Executor Service Creation Methods *
	 ****************************************************************/

	/**
	 * Creates a thread pool that reuses a fixed number of threads operating off a shared unbounded queue.
	 *
	 * - https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/ExecutorService.html
	 *
	 * @threads The number of threads in the pool, defaults to 20
	 *
	 * @return ExecutorService: The newly created thread pool
	 */
	function newFixedThreadPool( numeric threads=20 ){
		return variables.executors.newFixedThreadPool(
			javacast( "int", arguments.threads )
		);
	}

	/**
	 * Creates an Executor that uses a single worker thread operating off an
	 * unbounded queue. (Note however that if this single thread terminates
	 * due to a failure during execution prior to shutdown, a new one will
	 * take its place if needed to execute subsequent tasks.)
	 *
	 * Tasks are guaranteed to execute sequentially, and no more than one
	 * task will be active at any given time. Unlike the otherwise equivalent
	 * newFixedThreadPool(1) the returned executor is guaranteed not to be
	 * reconfigurable to use additional threads.
	 */
	function newSingleThreadPool(){
		return variables.executors.newSingleThreadExecutor();
	}
}