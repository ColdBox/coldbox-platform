/**
 * Static class to build executors from Java:
 *
 * - FixedThreadPool
 * - SingleThreadPool
 * - CachedThreadPool
 * - ScheduledThreadPool
 *
 * @see https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/Executors.html
 */
component singleton{

	// Java core executors class
	variables.jExecutors = createObject( "java", "java.util.concurrent.Executors" );
	// We choose a more IO bound approach to scheduling.
	// This can be reduced to be a more CPU bound
	this.DEFAULT_THREADS = 20;

	/****************************************************************
	 * Executor Service Creation Methods *
	 ****************************************************************/

	/**
	 * Creates a thread pool that reuses a fixed number of threads operating off a shared unbounded queue.
	 *
	 * @see https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/ExecutorService.html
	 *
	 * @threads The number of threads in the pool, defaults to 20
	 *
	 * @return ExecutorService: The newly created thread pool
	 */
	function newFixedThreadPool( numeric threads=this.DEFAULT_THREADS ){
		return variables.jExecutors.newFixedThreadPool(
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
	 *
	 * @see https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/ExecutorService.html
	 *
	 * @return ExecutorService: The newly created thread pool
	 */
	function newSingleThreadPool(){
		return variables.jExecutors.newSingleThreadExecutor();
	}

	/**
	 * Creates a thread pool that creates new threads as needed, but will
	 * reuse previously constructed threads when they are available.
	 *
	 * @see https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/ExecutorService.html
	 *
	 * @return ExecutorService: The newly created thread pool
	 */
	function newCachedThreadPool(){
		return variables.jExecutors.newCachedThreadPool();
	}

	/**
	 * Creates a thread pool that can schedule commands to run after a given delay,
	 * or to execute periodically.
	 *
	 * @see https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/ScheduledExecutorService.html
	 *
	 * @corePoolSize The number of threads to keep in the pool, even if they are idle, default is 20
	 *
	 * @return ScheduledExecutorService: The newly created thread pool
	 */
	function newScheduledThreadPool( corePoolSize=this.DEFAULT_THREADS ){
		return variables.jExecutors.newScheduledThreadPool(
			javaCast( "int", arguments.corePoolSize )
		);
	}

}