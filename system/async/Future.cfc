/**
 * This is the ColdBox Future object modeled and backed by Java's CompletableFuture but with Dynamic Goodness!
 *
 * @see https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html
 * @see https://docs.oracle.com/en/java/javase/11/docs/api/java.base/java/util/concurrent/CompletableFuture.html
 */
component accessors="true" {

	/**
	 * The native Completable future we model: java.util.concurrent.CompletableFuture
	 */
	property name="native";

	/**
	 * Add debugging output to the thread management and operations. Defaults to false
	 */
	property
		name   ="debug"
		type   ="boolean"
		default="false";

	/**
	 * Load the CFML App context and page context's into the spawned threads. Defaults to true
	 */
	property
		name   ="loadAppContext"
		type   ="boolean"
		default="true";

	/**
	 * Construct a new ColdBox Future
	 *
	 * @value Seed the future with a completed value if passed
	 * @debug Add output debugging
	 * @loadAppContext Load the CFML App contexts or not, disable if not used
	 */
	function init(
		value,
		boolean debug          = false,
		boolean loadAppContext = true
	){
		variables.native         = createObject( "java", "java.util.concurrent.CompletableFuture" );
		variables.debug          = arguments.debug;
		variables.loadAppContext = arguments.loadAppContext;
		variables.timeUnit       = new TimeUnit();

		if ( !isNull( arguments.value ) ) {
			variables.native = variables.native.completedFuture( arguments.value );
		}

		return this;
	}

	/**
	 * If not already completed, completes this Future with a CancellationException.
	 * Dependent Futures that have not already completed will also complete exceptionally, with a CompletionException caused by this CancellationException.
	 *
	 * @returns true if this task is now cancelled
	 */
	boolean function cancel( boolean mayInterruptIfRunning = true ){
		return variables.native.cancel( javacast( "boolean", arguments.mayInterruptIfRunning ) );
	}

	/**
	 * If not already completed, sets the value returned by get() and related methods to the given value.
	 *
	 * @value The value to set
	 *
	 * @return true if this invocation caused this CompletableFuture to transition to a completed state, else false
	 */
	boolean function complete( required value ){
		return variables.native.complete( arguments.value );
	}

	/**
	 * Returns a new ColdBox Future that is already completed with the given value.
	 *
	 * @value The value to set
	 *
	 * @return The ColdBox completed future
	 */
	Future function completedFuture( required value ){
		variables.native = variables.native.completedFuture( arguments.value );
		return this;
	}

	/**
	 * If not already completed, causes invocations of get() and related methods to throw the given exception.
	 * The exception type is of `java.lang.RuntimeException` and you can choose the message to throw with it.
	 *
	 * @message An optional message to add to the exception to be thrown.
	 *
	 * @returns The same Future
	 */
	Future function completeExceptionally( message = "Future operation completed with manual exception" ){
		variables.native.completeExceptionally(
			createObject( "java", "java.lang.RuntimeException" ).init( arguments.message )
		);
		return this;
	}

	/**
	 * Waits if necessary for at most the given time for this future to complete, and then returns its result, if available.
	 * If the result is null, then you can pass the defaultValue argument to return it.
	 *
	 * @timeout The timeout value to use, defaults to forever
	 * @timeUnit The time unit to use, available units are: days, hours, microseconds, milliseconds, minutes, nanoseconds, and seconds. The default is seconds
	 * @defaultValue If the Future did not produce a value, then it will return this default value.
	 *
	 * @returns The result value
	 * @throws CancellationException, ExecutionException, InterruptedException, TimeoutException
	 */
	any function get(
		numeric timeout = 0,
		string timeUnit = "seconds",
		defaultValue
	){
		// Do we have a timeout?
		if ( arguments.timeout != 0 ) {
			var results = variables.native.get(
				javacast( "long", arguments.timeout ),
				variables.timeUnit.get( arguments.timeUnit )
			);
		} else {
			var results = variables.native.get();
		}

		// If we have results, return them
		if ( !isNull( results ) ) {
			return results;
		}

		// If we didn't, do we have a default value
		if ( !isNull( arguments.defaultValue ) ) {
			return arguments.defaultValue;
		}
		// Else return null
	}

	/**
	 * Returns the result value (or throws any encountered exception) if completed, else returns the given defaultValue.
	 *
	 * @defaultValue The value to return if not completed
	 *
	 * @returns The result value, if completed, else the given defaultValue
	 *
	 * @throws CancellationException, CompletionException
	 */
	function getNow( required defaultValue ){
		return variables.native.getNow( arguments.defaultValue );
	}

	/**
	 * Returns true if this Future was cancelled before it completed normally.
	 */
	boolean function isCancelled(){
		return variables.native.isCancelled();
	}

	/**
	 * Returns true if this Future completed exceptionally, in any way. Possible causes include cancellation, explicit invocation of completeWithException, and abrupt termination of a CompletionStage action.
	 */
	boolean function isCompletedExceptionally(){
		return variables.native.isCompletedExceptionally();
	}

	/**
	 * Returns true if completed in any fashion: normally, exceptionally, or via cancellation.
	 */
	boolean function isDone(){
		return variables.native.isDone();
	}

	/**
	 * Register an event handler for any exceptions that happen before it is registered
	 * in the future pipeline.  Whatever this function returns, will be used for the next
	 * registered functions in the pipeline.
	 *
	 * The function takes in the exception that ocurred and can return a new value as well:
	 *
	 * <pre>
	 * ( exception ) => newValue;
	 * function( exception ) => {
	 * 	  return newValue;
	 * }
	 * </pre>
	 *
	 * @target The function that will be called when the exception is triggered
	 *
	 * @return The future with the exception handler registered
	 */
	Future function exceptionally( required target ){
		variables.native = variables.native.exceptionally(
			createDynamicProxy(
				new proxies.Function(
					arguments.target,
					variables.debug,
					variables.loadAppContext
				),
				[ "java.util.function.Function" ]
			)
		);
		return this;
	}

	/**
	 * Executes a runnable closure or component method via Java's CompletableFuture and gives you back a ColdBox Future:
	 *
	 * - This method calls `supplyAsync()` in the Java API
	 * - This future is asynchronously completed by a task running in the ForkJoinPool.commonPool() with the value obtained by calling the given Supplier.
	 *
	 * @supplier A CFC instance or closure or lambda or udf to execute and return the value to be used in the future
	 * @method If the supplier is a CFC, then it executes a method on the CFC for you. Defaults to the `run()` method
	 * @executor An optional executor to use for asynchronous execution of the task
	 *
	 * @return The new completion stage (Future)
	 */
	Future function run(
		required supplier,
		method = "run",
		any executor
	){
		var jSupplier = createDynamicProxy(
			new proxies.Supplier(
				arguments.supplier,
				arguments.method,
				variables.debug,
				variables.loadAppContext
			),
			[ "java.util.function.Supplier" ]
		);

		// Supply the future and start the task
		variables.native = variables.native.supplyAsync( jSupplier );

		return this;
	}

	/**
	 * Alias to the `run()` method but left here to help Java developers
	 * feel at home. Since in our futures, everything becomes a supplier
	 * of some sort.
	 *
	 * @supplier A CFC instance or closure or lambda or udf to execute and return the value to be used in the future
	 * @executor An optional executor to use for asynchronous execution of the task
	 *
	 * @return The new completion stage (Future)
	 */
	Future function supplyAsync( required supplier, any executor ){
		return run( argumentCollection=arguments );
	}

	/**
	 * Alias to the `run()` method but left here to help Java developers
	 * feel at home. Since in our futures, everything becomes a supplier
	 * of some sort.
	 *
	 * @runnable A CFC instance or closure or lambda or udf to execute and return the value to be used in the future
	 * @executor An optional executor to use for asynchronous execution of the task
	 *
	 * @return The new completion stage (Future)
	 */
	Future function supplyAsync( required runnable, any executor ){
		arguments.supplier = arguments.runnable;
		return run( argumentCollection=arguments );
	}

	/**
	 * Executed once the computation has finalized and a result is passed in to the target:
	 *
	 * - The target can use the result, manipulate it and return a new result from the this completion stage
	 * - The target can use the result and return void
	 * - This stage executes in the calling thread
	 *
	 * <pre>
	 * // Just use the result and not return anything
	 * then( (result) => systemOutput( result ) )
	 * // Get the result and manipulate it, much like a map() function
	 * then( (result) => ucase( result ) );
	 * </pre>
	 *
	 * @target The closure/lambda or udf that will receive the result
	 *
	 * @return The new completion stage (Future)
	 */
	Future function then( required target ){
		var apply = createDynamicProxy(
			new proxies.Function(
				arguments.target,
				variables.debug,
				variables.loadAppContext
			),
			[ "java.util.function.Function" ]
		);

		variables.native = variables.native.thenApply( apply );

		return this;
	}

	/**
	 * Executed once the computation has finalized and a result is passed in to the target but
	 * this will execute in a separate thread. By default it uses the ForkJoin.commonPool() but you can
	 * pass your own executor service.
	 *
	 * - The target can use the result, manipulate it and return a new result from the this completion stage
	 * - The target can use the result and return void
	 *
	 * <pre>
	 * // Just use the result and not return anything
	 * then( (result) => systemOutput( result ) )
	 * // Get the result and manipulate it, much like a map() function
	 * then( (result) => ucase( result ) );
	 * </pre>
	 *
	 * @target The closure/lambda or udf that will receive the result
	 *
	 * @return The new completion stage (Future)
	 */
	Future function thenAsync( required target, executor ){
		var apply = createDynamicProxy(
			new proxies.Function(
				arguments.target,
				variables.debug,
				variables.loadAppContext
			),
			[ "java.util.function.Function" ]
		);

		variables.native = variables.native.thenApplyAsync( apply );

		return this;
	}

}
