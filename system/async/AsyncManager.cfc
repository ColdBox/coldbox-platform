/**
 * The ColdBox Async Manager is in charge of creating runnable proxies based on
 * components or closures that can be spawned as native Java Completable futures
 * to support you with multi-threaded and asynchronous programming.
 *
 * The manager can also help you create executor services (queues or work pools) so you can define your own
 * thread pools according to your needs.  If not, the majority of the asynchronous
 * methods will use the ForkJoin.commonPool() implementation.
 *
 * Every ColdBox application has a single AsyncManager loaded with 1 work queue created
 * mostly for internal ColdBox operations: `coldbox-tasks` with 20 threads.
 *
 * However, you can define as many executor pools in your configuration file and ColdBox will
 * manage them for you via this Async Manager.
 *
 * Welcome to the world of async and parallel programming!
 */
component accessors="true" singleton {

	/**
	 * --------------------------------------------------------------------------
	 * Properties
	 * --------------------------------------------------------------------------
	 */

	/**
	 * A collection of executors you can register in the async manager
	 * so you can run queues, tasks or even scheduled tasks
	 */
	property name="executors" type="struct";

	/**
	 * This scheduler can be linked to a ColdBox context
	 */
	property name="coldbox";

	// Static class to Executors: java.util.concurrent.Executors
	this.$executors = new coldbox.system.async.executors.ExecutorBuilder();

	/**
	 * Constructor
	 *
	 * @debug Add debugging logs to System out, disabled by default
	 */
	AsyncManager function init( boolean debug = false ){
		variables.System = createObject( "java", "java.lang.System" );
		variables.debug  = arguments.debug;

		// Build out our executors map
		variables.executors = {};

		return this;
	}

	/****************************************************************
	 * Executor Methods *
	 ****************************************************************/

	/**
	 * Creates and registers an Executor according to the passed name, type and options.
	 * The allowed types are: fixed, cached, single, scheduled with fixed being the default.
	 *
	 * You can then use this executor object to submit tasks for execution and if it's a
	 * scheduled executor then actually execute scheduled tasks.
	 *
	 * Types of Executors:
	 * - fixed : By default it will build one with 20 threads on it. Great for multiple task execution and worker processing
	 * - single : A great way to control that submitted tasks will execute in the order of submission: FIFO
	 * - cached : An unbounded pool where the number of threads will grow according to the tasks it needs to service. The threads are killed by a default 60 second timeout if not used and the pool shrinks back
	 * - scheduled : A pool to use for scheduled tasks that can run one time or periodically
	 *
	 * @see            https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/ExecutorService.html
	 * @name           The name of the executor used for registration
	 * @type           The type of executor to build fixed, cached, single, scheduled
	 * @threads        How many threads to assign to the thread scheduler, default is 20
	 * @debug          Add output debugging
	 * @loadAppContext Load the CFML App contexts or not, disable if not used
	 *
	 * @return The ColdBox Schedule class to work with the schedule: coldbox.system.async.executors.Executor
	 */
	Executor function newExecutor(
		required name,
		type                   = "fixed",
		numeric threads        = this.$executors.DEFAULT_THREADS,
		boolean debug          = false,
		boolean loadAppContext = true
	){
		// Build it if not found
		if ( !variables.executors.keyExists( arguments.name ) ) {
			// Create the ColdBox executor and register it
			variables.executors[ arguments.name ] = buildExecutor( argumentCollection = arguments );
		}

		// Return it
		return variables.executors[ arguments.name ];
	}

	/**
	 * Build a Java executor according to passed type and threads
	 *
	 * @see            https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/Executors.html
	 * @type           Available types are: fixed, cached, single, scheduled, {WireBoxID}
	 * @threads        The number of threads to seed the executor with, if it allows it
	 * @debug          Add output debugging
	 * @loadAppContext Load the CFML App contexts or not, disable if not used
	 *
	 * @return A Java ExecutorService: https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/ExecutorService.html
	 */
	private function buildExecutor(
		required type,
		numeric threads,
		boolean debug          = false,
		boolean loadAppContext = true
	){
		// Factory to build the right executor
		switch ( arguments.type ) {
			case "fixed": {
				arguments.executor = this.$executors.newFixedThreadPool( arguments.threads );
				return new executors.Executor( argumentCollection = arguments );
			}
			case "cached": {
				arguments.executor = this.$executors.newCachedThreadPool();
				return new executors.Executor( argumentCollection = arguments );
			}
			case "single": {
				arguments.executor = this.$executors.newFixedThreadPool( 1 );
				return new executors.Executor( argumentCollection = arguments );
			}
			case "scheduled": {
				arguments.executor = this.$executors.newScheduledThreadPool( arguments.threads );
				return new executors.ScheduledExecutor( argumentCollection = arguments );
			}
			default: {
			}
		}
		throw(
			type    = "InvalidExecutorType",
			message = "The executor you requested :#arguments.type# does not exist.",
			detail  = "Valid executors are: fixed, cached, single, scheduled"
		);
	}

	/**
	 * Shortcut to newExecutor( type: "scheduled" )
	 */
	Executor function newScheduledExecutor(
		required name,
		numeric threads        = this.$executors.DEFAULT_THREADS,
		boolean debug          = false,
		boolean loadAppContext = true
	){
		arguments.type = "scheduled";
		return newExecutor( argumentCollection = arguments );
	}

	/**
	 * Shortcut to newExecutor( type: "single", threads: 1 )
	 */
	Executor function newSingleExecutor(
		required name,
		boolean debug          = false,
		boolean loadAppContext = true
	){
		arguments.type = "single";
		return newExecutor( argumentCollection = arguments );
	}

	/**
	 * Shortcut to newExecutor( type: "cached" )
	 */
	Executor function newCachedExecutor(
		required name,
		numeric threads        = this.$executors.DEFAULT_THREADS,
		boolean debug          = false,
		boolean loadAppContext = true
	){
		arguments.type = "cached";
		return newExecutor( argumentCollection = arguments );
	}

	/**
	 * Get a registered executor registered in this async manager
	 *
	 * @name The executor name
	 *
	 * @return The executor object: coldbox.system.async.executors.Executor
	 *
	 * @throws ExecutorNotFoundException
	 */
	Executor function getExecutor( required name ){
		if ( hasExecutor( arguments.name ) ) {
			return variables.executors[ arguments.name ];
		}
		throw(
			type    = "ExecutorNotFoundException",
			message = "The schedule you requested does not exist",
			detail  = "Registered schedules are: #variables.executors.keyList()#"
		);
	}

	/**
	 * Get the array of registered executors in the system
	 *
	 * @return Array of names
	 */
	array function getExecutorNames(){
		return variables.executors.keyArray();
	}

	/**
	 * Verify if an executor exists
	 *
	 * @name The executor name
	 */
	boolean function hasExecutor( required name ){
		return variables.executors.keyExists( arguments.name );
	}

	/**
	 * Delete an executor from the registry, if the executor has not shutdown, it will shutdown the executor for you
	 * using the shutdownNow() event
	 *
	 * @name The scheduler name
	 */
	AsyncManager function deleteExecutor( required name ){
		if ( hasExecutor( arguments.name ) ) {
			if ( !variables.executors[ arguments.name ].isShutdown() ) {
				variables.executors[ arguments.name ].shutdownNow();
			}
			variables.executors.delete( arguments.name );
		}
		return this;
	}

	/**
	 * Shutdown an executor or force it to shutdown, you can also do this from the Executor themselves.
	 * If an un-registered executor name is passed, it will ignore it
	 *
	 * @name    The name of the executor to shutdown
	 * @force   Use the shutdownNow() instead of the shutdown() method
	 * @timeout The timeout to use when force=false, to make sure all tasks finish gracefully. Deafult is 30 seconds.
	 */
	AsyncManager function shutdownExecutor(
		required name,
		boolean force   = false,
		numeric timeout = 30
	){
		if ( hasExecutor( arguments.name ) ) {
			if ( arguments.force ) {
				variables.executors[ arguments.name ].shutdownNow();
			} else {
				variables.executors[ arguments.name ].shutdownAndAwaitTermination( arguments.timeout );
			}
		}
		return this;
	}

	/**
	 * Shutdown all registered executors in the system gracefully or not by using force = true
	 *
	 * @force   By default (false) it gracefully shuts them down, else uses the shutdownNow() methods
	 * @timeout The timeout to use when force=false, to make sure all tasks finish gracefully. Deafult is 30 seconds.
	 *
	 * @return AsyncManager
	 */
	AsyncManager function shutdownAllExecutors( boolean force = false, numeric timeout = 30 ){
		variables.executors.each( function( key, schedule ){
			if ( force ) {
				arguments.schedule.shutdownNow();
			} else {
				arguments.schedule.shutdownAndAwaitTermination( timeout );
			}
		} );
		return this;
	}

	/**
	 * Returns a structure of status maps for every registered executor in the
	 * manager. This is composed of tons of stats about the executor
	 *
	 * @name The name of the executor to retrieve th status map ONLY!
	 *
	 * @return A struct of metadata about the executor or all executors
	 */
	struct function getExecutorStatusMap( name ){
		if ( !isNull( arguments.name ) ) {
			return getExecutor( arguments.name ).getStats();
		}

		return variables.executors.map( function( key, thisExecutor ){
			return arguments.thisExecutor.getStats();
		} );
	}

	/****************************************************************
	 * Future Creation Methods *
	 ****************************************************************/

	/**
	 * Create a new ColdBox future backed by a Java completable future
	 *
	 * @value          The actual closure/lambda/udf to run with or a completed value to seed the future with
	 * @executor       A custom executor to use with the future, else use the default
	 * @debug          Add debugging to system out or not, defaults is false
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
		return new tasks.Future( argumentCollection = arguments );
	}

	/**
	 * Create a completed ColdBox future backed by a Java Completable Future
	 *
	 * @value          The value to complete the future with
	 * @debug          Add debugging to system out or not, defaults is false
	 * @loadAppContext Load the CFML engine context into the async threads or not, default is yes.
	 *
	 * @return ColdBox Future completed
	 */
	Future function newCompletedFuture(
		required any value,
		boolean debug          = false,
		boolean loadAppContext = true
	){
		return new tasks.Future( argumentCollection = arguments );
	}

	/****************************************************************
	 * Future Creation Shortcuts *
	 ****************************************************************/

	/**
	 * Alias to newFuture().all()
	 */
	Future function all(){
		return newFuture().all( argumentCollection = arguments );
	}

	/**
	 * Alias to newFuture().allApply()
	 */
	any function allApply(){
		return newFuture().allApply( argumentCollection = arguments );
	}

	/**
	 * Alias to newFuture().anyOf()
	 */
	Future function anyOf(){
		return newFuture().anyOf( argumentCollection = arguments );
	}

	/****************************************************************
	 * Utilities *
	 ****************************************************************/

	/**
	 * Build out a scheduler object for usage within this async manager context and return it to you.
	 * You must manage it's persistence, we only wire it and create it for you so you can use it
	 * to schedule tasks.
	 *
	 * @name The unique name for the scheduler
	 */
	Scheduler function newScheduler( required name ){
		return new coldbox.system.async.tasks.Scheduler( arguments.name, this );
	}

	/**
	 * Build out a new Duration class
	 */
	Duration function duration(){
		return new time.Duration( argumentCollection = arguments );
	}

	/**
	 * Build out a new Period class
	 */
	Period function period(){
		return new time.Period( argumentCollection = arguments );
	}

	/**
	 * Build an array out of a range of numbers or using our range syntax.
	 * You can also build negative ranges
	 *
	 * <pre>
	 * arrayRange( "1..5" )
	 * arrayRange( "-10..5" )
	 * arrayRange( 1, 500 )
	 * </pre>
	 *
	 * @from The initial index, defaults to 1 or you can use the {start}..{end} notation
	 * @to   The last index item
	 */
	array function arrayRange( any from = 1, numeric to ){
		// shortcut notation
		if ( find( "..", arguments.from ) ) {
			arguments.to   = getToken( arguments.from, 2, ".." );
			arguments.from = getToken( arguments.from, 1, ".." );
		}

		// cap to if larger than from
		if ( arguments.to < arguments.from ) {
			arguments.to = arguments.from;
		}

		// build it up
		var javaArray = createObject( "java", "java.util.stream.IntStream" )
			.rangeClosed( arguments.from, arguments.to )
			.toArray();
		var cfArray = [];
		cfArray.append( javaArray, true );
		return cfArray;
	}

	/**
	 * Utility to send to output to the output stream
	 *
	 * @var Variable/Message to send
	 */
	AsyncManager function out( required var ){
		variables.System.out.println( arguments.var.toString() );
		return this;
	}

	/**
	 * Utility to send to output to the error stream
	 *
	 * @var Variable/Message to send
	 */
	AsyncManager function err( required var ){
		variables.System.err.println( arguments.var.toString() );
		return this;
	}

}
