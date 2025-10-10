/**
 * Static class to build executors from Java:
 *
 * - CachedThreadPool
 * - FixedThreadPool
 * - ForkJoinPool
 * - SingleThreadPool
 * - ScheduledThreadPool
 * - WorkStealingPool
 * - VirtualThreadPool
 *
 * @see https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/Executors.html
 */
component singleton {

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
	 * @see     https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/ExecutorService.html
	 * @threads The number of threads in the pool, defaults to 20
	 *
	 * @return ExecutorService: The newly created thread pool
	 */
	function newFixedThreadPool( numeric threads = this.DEFAULT_THREADS ){
		return variables.jExecutors.newFixedThreadPool( javacast( "int", arguments.threads ) );
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
	 * @see          https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/ScheduledExecutorService.html
	 * @corePoolSize The number of threads to keep in the pool, even if they are idle, default is 20
	 *
	 * @return ScheduledExecutorService: The newly created thread pool
	 */
	function newScheduledThreadPool( corePoolSize = this.DEFAULT_THREADS ){
		return variables.jExecutors.newScheduledThreadPool( javacast( "int", arguments.corePoolSize ) );
	}

	/**
	 * Create a virtual thread executor that can be used to run tasks in a virtual thread context.
	 *
	 * @see https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/VirtualThreadExecutor.html
	 *
	 * @return VirtualThreadExecutor: The newly created virtual thread executor
	 */
	function newVirtualThreadExecutor(){
		return variables.jExecutors.newVirtualThreadPerTaskExecutor();
	}

	/**
	 * Create a work stealing pool executor that can be used to run tasks in a work-stealing context.
	 *
	 * @see https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/WorkStealingPoolExecutor.html
	 *
	 * @return WorkStealingPoolExecutor: The newly created work stealing pool executor
	 */
	function newWorkStealingPoolExecutor( numeric parallelism = 0 ){
		if ( arguments.parallelism > 0 ) {
			return variables.jExecutors.newWorkStealingPool( javacast( "int", arguments.parallelism ) );
		}
		// If no parallelism is specified, use the default behavior
		// which is to use the number of available processors.
		// This is similar to the default behavior of the Java Executors class.
		// This will create a work-stealing pool with a parallelism level
		// equal to the number of available processors.
		// This is useful for tasks that can benefit from parallel execution.
		return variables.jExecutors.newWorkStealingPool();
	}

	/**
	 * New ForkJoinPool executor.
	 *
	 * @see   https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/ForkJoinPool.html
	 * @param maxThreads The maximum number of threads to use in the pool, defaults to 20.
	 *
	 * @return ForkJoinPool: The newly created ForkJoinPool
	 */
	function newForkJoinPool( numeric maxThreads = this.DEFAULT_THREADS ){
		if ( maxThreads > 0 ) {
			return createObject( "java", "java.util.concurrent.ForkJoinPool" ).init(
				javacast( "int", arguments.maxThreads )
			);
		}
		// If no maxThreads is specified, use the default behavior
		// which is to use the number of available processors.
		return createObject( "java", "java.util.concurrent.ForkJoinPool" ).commonPool();
	}

}
