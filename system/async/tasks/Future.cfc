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
	 * The custom executor to use with the future execution, or it can be null
	 */
	property name="executor";

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
	 * The timeout you can set on this future via the withTimeout() method
	 * which is used in operations like allOf() and anyOf()
	 */
	property name="futureTimeout" type="struct";

	// Prepare the static time unit class
	this.$timeUnit = new coldbox.system.async.time.TimeUnit();

	/**
	 * Construct a new ColdBox Future backed by a Java Completable Future
	 *
	 * @value          The actual closure/lambda/udf to run with or a completed value to seed the future with
	 * @executor       A custom executor to use with the future, else use the default
	 * @debug          Add output debugging
	 * @loadAppContext Load the CFML App contexts or not, disable if not used
	 */
	Future function init(
		value,
		any executor,
		boolean debug          = false,
		boolean loadAppContext = true
	){
		// Prepare the completable future
		variables.native         = createObject( "java", "java.util.concurrent.CompletableFuture" );
		variables.debug          = arguments.debug;
		variables.loadAppContext = arguments.loadAppContext;
		variables.executor       = ( isNull( arguments.executor ) ? "" : arguments.executor );

		// Are we using a Java or CFML executor?
		if ( isObject( variables.executor ) && structKeyExists( variables.executor, "getNative" ) ) {
			variables.executor = variables.executor.getNative();
		}

		// Prepare initial timeouts
		variables.futureTimeout = { "timeout" : 0, "timeUnit" : "milliseconds" };

		// Default the future to be empty
		variables.isEmptyFuture = true;

		// Verify incoming value type
		if ( !isNull( arguments.value ) ) {
			// Mark as not empty
			variables.isEmptyFuture = false;
			// If the incoming value is a closure/lambda/udf, seed the future with it
			if ( isClosure( arguments.value ) || isCustomFunction( arguments.value ) ) {
				return run( arguments.value );
			}
			// It is just a value to set as the completion
			variables.native = variables.native.completedFuture( arguments.value );
		}

		return this;
	}

	/**
	 * If not already completed, completes this Future with a CancellationException.
	 * Dependent Futures that have not already completed will also complete exceptionally, with a CompletionException caused by this CancellationException.
	 *
	 * @return true if this task is now cancelled
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
	 * Completes this CompletableFuture with the given value if not otherwise completed before the given timeout.
	 *
	 * @value    The value to use upon timeout
	 * @timeout  how long to wait before completing normally with the given value, in units of unit
	 * @timeUnit The time unit to use, available units are: days, hours, microseconds, milliseconds, minutes, nanoseconds, and seconds. The default is milliseconds
	 */
	Future function completeOnTimeout(
		required value,
		required timeout,
		timeUnit = "milliseconds"
	){
		variables.native = variables.native.completeOnTimeout(
			arguments.value,
			javacast( "long", arguments.timeout ),
			this.$timeUnit.get( arguments.timeUnit )
		);
		return this;
	}

	/**
	 * Exceptionally completes this CompletableFuture with a TimeoutException if not otherwise completed before the given timeout.
	 *
	 * @timeout  how long to wait before completing normally with the given value, in units of unit
	 * @timeUnit The time unit to use, available units are: days, hours, microseconds, milliseconds, minutes, nanoseconds, and seconds. The default is milliseconds
	 */
	Future function orTimeout( required timeout, timeUnit = "milliseconds" ){
		variables.native = variables.native.orTimeout(
			javacast( "long", arguments.timeout ),
			this.$timeUnit.get( arguments.timeUnit )
		);
		return this;
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
	 * @return The same Future
	 */
	Future function completeExceptionally( message = "Future operation completed with manual exception" ){
		variables.native.completeExceptionally(
			createObject( "java", "java.lang.RuntimeException" ).init( arguments.message )
		);
		return this;
	}

	/**
	 * Alias to completeExceptionally
	 *
	 * @defaultValue
	 */
	Future function completeWithException(){
		return completeExceptionally( argumentCollection = arguments );
	}

	/**
	 * Returns the result value when complete, or throws an (unchecked) exception if completed exceptionally.
	 * To better conform with the use of common functional forms, if a computation involved in the completion of this CompletableFuture
	 * threw an exception, this method throws an (unchecked) CompletionException with the underlying exception as its cause.
	 *
	 * @defaultValue If the returned value is null, then we can pass a default value to return
	 *
	 * @return The result value
	 *
	 * @throws CompletionException   - if this future completed exceptionally or a completion computation threw an exception
	 * @throws CancellationException - if the computation was cancelled
	 */
	any function join( defaultValue ){
		var results = variables.native.join();

		if ( !isNull( local.results ) ) {
			return local.results;
		}

		if ( isNull( local.results ) && !isNull( arguments.defaultValue ) ) {
			return arguments.defaultValue;
		}
	}

	/**
	 * Waits if necessary for at most the given time for this future to complete, and then returns its result, if available.
	 * If the result is null, then you can pass the defaultValue argument to return it.
	 *
	 * @timeout      The timeout value to use, defaults to forever
	 * @timeUnit     The time unit to use, available units are: days, hours, microseconds, milliseconds, minutes, nanoseconds, and seconds. The default is milliseconds
	 * @defaultValue If the Future did not produce a value, then it will return this default value.
	 *
	 * @return The result value
	 *
	 * @throws CancellationException , ExecutionException, InterruptedException, TimeoutException
	 */
	any function get(
		numeric timeout = 0,
		string timeUnit = "milliseconds",
		defaultValue
	){
		// Do we have a timeout?
		if ( arguments.timeout != 0 ) {
			try {
				var results = variables.native.get(
					javacast( "long", arguments.timeout ),
					this.$timeUnit.get( arguments.timeUnit )
				);
			} catch ( "java.util.concurrent.TimeoutException" e ) {
				// If we have a result, return it, else rethrow
				if ( !isNull( arguments.defaultValue ) ) {
					return arguments.defaultValue;
				}
				rethrow;
			}
		}
		// No timeout, just block until done
		else {
			var results = variables.native.get();
		}

		// If we have results, return them
		if ( !isNull( local.results ) ) {
			return local.results;
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
	 * @return The result value, if completed, else the given defaultValue
	 *
	 * @throws CancellationException , CompletionException
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
	 * The function takes in the exception that occurred and can return a new value as well:
	 *
	 * <pre>
	 * ( exception ) => newValue;
	 * function( exception ) => {
	 * 	  return newValue;
	 * }
	 * </pre>
	 *
	 * Note that, the error will not be propagated further in the callback chain if you handle it once.
	 *
	 * @target The function that will be called when the exception is triggered
	 *
	 * @return The future with the exception handler registered
	 */
	Future function exceptionally( required target ){
		variables.native = variables.native.exceptionally(
			createDynamicProxy(
				new coldbox.system.async.proxies.Function(
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
	 * Alias to exceptionally()
	 */
	function onException( required target ){
		return exceptionally( argumentCollection = arguments );
	}

	/**
	 * Executes a runnable closure or component method via Java's CompletableFuture and gives you back a ColdBox Future:
	 *
	 * - This method calls `supplyAsync()` in the Java API
	 * - This future is asynchronously completed by a task running in the ForkJoinPool.commonPool() with the value obtained by calling the given Supplier.
	 *
	 * @supplier A CFC instance or closure or lambda or udf to execute and return the value to be used in the future
	 * @method   If the supplier is a CFC, then it executes a method on the CFC for you. Defaults to the `run()` method
	 * @executor An optional executor to use for asynchronous execution of the task
	 *
	 * @return The new completion stage (Future)
	 */
	Future function run(
		required supplier,
		method       = "run",
		any executor = variables.executor
	){
		var jSupplier = createDynamicProxy(
			new coldbox.system.async.proxies.Supplier(
				arguments.supplier,
				arguments.method,
				variables.debug,
				variables.loadAppContext
			),
			[ "java.util.function.Supplier" ]
		);

		// Supply the future and start the task
		if ( isObject( variables.executor ) ) {
			variables.native = variables.native.supplyAsync( jSupplier, variables.executor );
		} else {
			variables.native = variables.native.supplyAsync( jSupplier );
		}

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
		return run( argumentCollection = arguments );
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
	Future function runAsync( required runnable, any executor ){
		arguments.supplier = arguments.runnable;
		return run( argumentCollection = arguments );
	}

	/**
	 * Returns a new CompletionStage that, when this stage completes either normally or exceptionally, is executed with this stage's result
	 * and exception as arguments to the supplied function.
	 *
	 * When this stage is complete, the given function is invoked with the result (or null if none) and the exception (or null if none) of
	 * this stage as arguments, and the function's result is used to complete the returned stage.
	 *
	 * The action is a closure/udf with the incoming input (if any) or an exception (if any) and returns a new result if you want
	 *
	 * <pre>
	 * handle( (input, exception) => {} )
	 * handle( function( input, exception ){} )
	 * </pre>
	 *
	 * @action the function to use to compute the value of the returned CompletionStage
	 *
	 * @return The new completion stage
	 */
	Future function handle( required action ){
		var biFunction = createDynamicProxy(
			new coldbox.system.async.proxies.BiFunction(
				arguments.action,
				variables.debug,
				variables.loadAppContext
			),
			[ "java.util.function.BiFunction" ]
		);

		variables.native = variables.native.handle( biFunction );

		return this;
	}

	/**
	 * Returns a new CompletionStage that, when this stage completes either normally or exceptionally,
	 * is executed using this stage's default asynchronous execution facility, with this stage's result
	 *  and exception as arguments to the supplied function.
	 *
	 * When this stage is complete, the given function is invoked with the result (or null if none) and
	 * the exception (or null if none) of this stage as arguments, and the function's result is used to
	 * complete the returned stage.
	 *
	 *  The action is a closure/udf with the incoming input (if any) or an exception (if any) and returns a new result if you want
	 *
	 * <pre>
	 * handleAsync( (input, exception) => {} )
	 * handleAsync( function( input, exception ){} )
	 *
	 * handleAsync( (input, exception) => {}, asyncManager.$executors.newFixedThreadPool() )
	 * </pre>
	 *
	 * @action   the function to use to compute the value of the returned CompletionStage
	 * @executor the java executor to use for asynchronous execution, can be empty
	 *
	 * @return The new completion stage
	 */
	Future function handleAsync( required action, executor ){
		var biFunction = createDynamicProxy(
			new coldbox.system.async.proxies.BiFunction(
				arguments.action,
				variables.debug,
				variables.loadAppContext
			),
			[ "java.util.function.BiFunction" ]
		);

		if ( !isNull( arguments.executor ) ) {
			variables.native = variables.native.handleAsync( biFunction, arguments.executor );
		} else {
			variables.native = variables.native.handleAsync( biFunction );
		}

		return this;
	}

	/**
	 * Returns a new CompletionStage with the same result or exception as this stage, that executes the given action when this stage completes.
	 *
	 * When this stage is complete, the given action is invoked with the result (or null if none) and the exception (or null if none) of this stage as arguments.
	 * The returned stage is completed when the action returns. If the supplied action itself encounters an exception, then the returned stage exceptionally completes
	 * with this exception unless this stage also completed exceptionally.
	 *
	 * The action is a closure/udf with the incoming input (if any) or an exception (if any) and returns void.
	 *
	 * <pre>
	 * whenComplete( (input, exception) => {} )
	 * whenComplete( function( input, exception ){} )
	 * </pre>
	 *
	 * @action the action to perform
	 *
	 * @return The new completion stage
	 */
	Future function whenComplete( required action ){
		var biConsumer = createDynamicProxy(
			new coldbox.system.async.proxies.BiConsumer(
				arguments.action,
				variables.debug,
				variables.loadAppContext
			),
			[ "java.util.function.BiConsumer" ]
		);

		variables.native = variables.native.whenComplete( biConsumer );

		return this;
	}

	/**
	 * Returns a new CompletionStage with the same result or exception as this stage, that executes the given action using this stage's
	 * default asynchronous execution facility when this stage completes.
	 *
	 * When this stage is complete, the given action is invoked with the result (or null if none) and the exception (or null if none) of this stage as arguments.
	 * The returned stage is completed when the action returns. If the supplied action itself encounters an exception, then the returned stage exceptionally completes
	 * with this exception unless this stage also completed exceptionally.
	 *
	 * The action is a closure/udf with the incoming input (if any) or an exception (if any) and returns void.
	 *
	 * <pre>
	 * whenCompleteAsync( (input, exception) => {} )
	 * whenCompleteAsync( function( input, exception ){} )
	 *
	 * whenCompleteAsync( (input, exception) => {}, asyncManager.$executors.newFixedThreadPool() )
	 * </pre>
	 *
	 * @action   the action to perform
	 * @executor the java executor to use for asynchronous execution, can be empty
	 *
	 * @return The new completion stage
	 */
	Future function whenCompleteAsync( required action, executor ){
		var biConsumer = createDynamicProxy(
			new coldbox.system.async.proxies.BiConsumer(
				arguments.action,
				variables.debug,
				variables.loadAppContext
			),
			[ "java.util.function.BiConsumer" ]
		);

		if ( !isNull( arguments.executor ) ) {
			variables.native = variables.native.whenCompleteAsync( biConsumer, arguments.executor );
		} else {
			variables.native = variables.native.whenCompleteAsync( biConsumer );
		}

		return this;
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
			new coldbox.system.async.proxies.Function(
				arguments.target,
				variables.debug,
				variables.loadAppContext
			),
			[ "java.util.function.Function" ]
		);

		if ( variables.isEmptyFuture ) {
			variables.native.thenApply( apply );
		} else {
			variables.native = variables.native.thenApply( apply );
		}

		return this;
	}

	/**
	 * Alias to `then()` left to help Java devs feel at Home
	 * Remember, the closure accepts the data and MUST return the data if not the next stage
	 * could be receiving a null result.
	 */
	Future function thenApply(){
		return then( argumentCollection = arguments );
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
			new coldbox.system.async.proxies.Function(
				arguments.target,
				variables.debug,
				variables.loadAppContext
			),
			[ "java.util.function.Function" ]
		);

		if ( isNull( arguments.executor ) ) {
			variables.native = variables.native.thenApplyAsync( apply );
		} else {
			variables.native = variables.native.thenApplyAsync( apply, arguments.executor );
		}

		return this;
	}

	/**
	 * Alias to `thenAsync()` left to help Java devs feel at Home
	 */
	Future function thenApplyAsync(){
		return thenAsync( argumentCollection = arguments );
	}

	/**
	 * Returns a new CompletionStage that, when this stage completes normally, is executed with this
	 * stage's result as the argument to the supplied action. See the CompletionStage documentation
	 * for rules covering exceptional completion.
	 *
	 * - The target can use the result and return void
	 * - This stage executes in the calling thread
	 *
	 * <pre>
	 * // Just use the result and not return anything
	 * thenRun( (result) => systemOutput( result ) )
	 * </pre>
	 *
	 * @target The action to perform before completing the returned CompletionStage
	 *
	 * @return The new completion stage (Future)
	 */
	Future function thenRun( required target ){
		var fConsumer = createDynamicProxy(
			new coldbox.system.async.proxies.Consumer(
				arguments.target,
				variables.debug,
				variables.loadAppContext
			),
			[ "java.util.function.Consumer" ]
		);

		variables.native.thenAccept( fConsumer );

		return this;
	}

	/**
	 * Alias to thenRun()
	 */
	Future function thenAccept(){
		return thenRun( argumentCollection = arguments );
	}

	/**
	 * Returns a new CompletionStage that, when this stage completes normally,
	 * is executed using this stage's default asynchronous execution facility,
	 *  with this stage's result as the argument to the supplied action.
	 *  See the CompletionStage documentation for rules covering exceptional completion.
	 *
	 * - The target can use the result and return void
	 * - This stage executes in the passed executor or the stage's executor facility
	 *
	 * <pre>
	 * // Just use the result and not return anything
	 * thenRunAsync( (result) => systemOutput( result ) )
	 * thenRunAsync( (result) => systemOutput( result ), myExecutor )
	 * </pre>
	 *
	 * @target   The action to perform before completing the returned CompletionStage
	 * @executor If passed, the executor to use to run the target
	 *
	 * @return The new completion stage (Future)
	 */
	Future function thenRunAsync( required target, executor ){
		var fConsumer = createDynamicProxy(
			new coldbox.system.async.proxies.Consumer(
				arguments.target,
				variables.debug,
				variables.loadAppContext
			),
			[ "java.util.function.Consumer" ]
		);

		if ( !isNull( arguments.executor ) ) {
			variables.native.thenAcceptAsync( fConsumer, arguments.executor );
		} else {
			variables.native.thenAcceptAsync( fConsumer );
		}

		return this;
	}

	/**
	 * Alias to thenRunAsync()
	 */
	Future function thenAcceptAsync(){
		return thenRunAsync( argumentCollection = arguments );
	}

	/**
	 * Returns a new CompletionStage that, when this stage completes normally,
	 * is executed with this stage as the argument to the supplied function.
	 *
	 * Basically, this used to combine two Futures where one future is dependent on the other
	 * If not, you return a future of a future
	 *
	 * @fn the function returning a new CompletionStage
	 *
	 * @return the CompletionStage
	 */
	Future function thenCompose( required fn ){
		variables.native = variables.native.thenCompose(
			createDynamicProxy(
				new coldbox.system.async.proxies.FutureFunction(
					arguments.fn,
					variables.debug,
					variables.loadAppContext
				),
				[ "java.util.function.Function" ]
			)
		);
		return this;
	}

	/**
	 * This used when you want two Futures to run independently and do something after
	 * both are complete.
	 *
	 * @future The ColdBox Future to combine
	 * @fn     The closure that will combine them: ( r1, r2 ) =>
	 */
	Future function thenCombine( required future, fn ){
		variables.native = variables.native.thenCombine(
			arguments.future.getNative(),
			createDynamicProxy(
				new coldbox.system.async.proxies.BiFunction(
					arguments.fn,
					variables.debug,
					variables.loadAppContext
				),
				[ "java.util.function.BiFunction" ]
			)
		);
		return this;
	}

	/**
	 * This method accepts an infinite amount of future objects, closures or an array of future objects/closures
	 * in order to execute them in parallel.  It will return back to you a future that will return back an array
	 * of results from every future that was executed. This way you can further attach processing and pipelining
	 * on the constructed array of values.
	 *
	 * <pre>
	 * results = all( f1, f2, f3 ).get()
	 * all( f1, f2, f3 ).then( (values) => logResults( values ) );
	 * </pre>
	 *
	 * @result A future that will return the results in an array
	 */
	Future function all(){
		// Collect the java futures to send back into this one for parallel exec
		var jFutures = futuresWrap( argumentCollection = arguments );

		// Split implementation cause ACF sucks on closure pointer references
		variables.native = variables.native.allOf( jFutures );

		// Return a future that will process the results back into an array
		// once it completes
		return this.thenAsync( function(){
			// return back the completed array results
			return jFutures.map( function( jFuture ){
				return arguments.jFuture.get();
			} );
		} );
	}

	/**
	 * This function can accept an array of items or a struct of items and apply a function
	 * to each of the item's in parallel.  The `fn` argument receives the appropriate item
	 * and must return a result.  Consider this a parallel map() operation
	 *
	 * <pre>
	 * // Array
	 * allApply( items, ( item ) => item.getMemento() )
	 * // Struct: The result object is a struct of `key` and `value`
	 * allApply( data, ( item ) => item.key & item.value.toString() )
	 * </pre>
	 *
	 * @items    An array or struct to process in parallel
	 * @fn       The function that will be applied to each of the collection's items
	 * @executor The custom executor to use if passed, else the forkJoin Pool
	 * @timeout  The timeout to use when waiting for each item to be processed
	 * @timeUnit The time unit to use, available units are: days, hours, microseconds, milliseconds, minutes, nanoseconds, and seconds. The default is milliseconds
	 *
	 * @return An array or struct with the items processed in parallel
	 *
	 * @throws UnsupportedCollectionException - When something other than an array or struct is passed as items
	 */
	any function allApply( items, fn, executor, timeout, timeUnit ){
		var incomingExecutor = arguments.executor ?: "";
		// Boolean indicator to avoid `isObject()` calls on iterations
		var usingExecutor    = isObject( incomingExecutor );
		// Cast it here, so it only happens once
		var currentTimeout   = javacast( "long", arguments.timeout ?: variables.futureTimeout.timeout );
		var currentTimeunit  = arguments.timeUnit ?: variables.futureTimeout.timeUnit;

		// Create the function proxy once instead of many times during iterations
		var jApply = createDynamicProxy(
			new coldbox.system.async.proxies.Function(
				arguments.fn,
				variables.debug,
				variables.loadAppContext
			),
			[ "java.util.function.Function" ]
		);

		// Array Processing
		if ( isArray( arguments.items ) ) {
			// Return the array as a collection of processed values
			return arguments.items
				// Startup the tasks
				.map( function( thisItem ){
					// Create a new completed future
					var f = new Future( arguments.thisItem );

					// Execute it on a custom executor or core
					if ( usingExecutor ) {
						return f.setNative( f.getNative().thenApplyAsync( jApply, incomingExecutor ) );
					}

					// Core Executor
					return f.setNative( f.getNative().thenApplyAsync( jApply ) );
				} )
				// Collect the tasks
				.map( function( thisFuture ){
					return arguments.thisFuture.get( currentTimeout, currentTimeunit );
				} );
		}
		// Struct Processing
		else if ( isStruct( arguments.items ) ) {
			return arguments.items
				// Startup the tasks
				.map( function( key, value ){
					// Create a new completed future
					var f = new Future( { "key" : arguments.key, "value" : arguments.value } );

					// Execute it on a custom executor or core
					if ( usingExecutor ) {
						return f.setNative( f.getNative().thenApplyAsync( jApply, incomingExecutor ) );
					}

					// Core Executor
					return f.setNative( f.getNative().thenApplyAsync( jApply ) );
				} )
				// Collect the tasks
				.map( function( key, thisFuture ){
					return arguments.thisFuture.get( currentTimeout, currentTimeunit );
				} );
		} else {
			throw(
				message: "The collection type passed is not yet supported!",
				type   : "UnsupportedCollectionException",
				detail : getMetadata( arguments.items )
			);
		}
	}

	/**
	 * This method accepts an infinite amount of future objects or closures and will execute them in parallel.
	 * However, instead of returning all of the results in an array like allOf(), this method will return
	 * the future that executes the fastest!
	 *
	 * <pre>
	 * // Let's say f2 executes the fastest!
	 * f2 = anyOf( f1, f2, f3 )
	 * </pre>
	 *
	 * @return The fastest executed future
	 */
	Future function anyOf(){
		// Run the fastest future in the world!
		variables.native = variables.native.anyOf( futuresWrap( argumentCollection = arguments ) );

		return this;
	}

	/**
	 * This method seeds a timeout into this future that can be used by the following operations:
	 *
	 * - allApply()
	 *
	 * @timeout  The timeout value to use, defaults to forever
	 * @timeUnit The time unit to use, available units are: days, hours, microseconds, milliseconds, minutes, nanoseconds, and seconds. The default is milliseconds
	 *
	 * @return This future
	 */
	Future function withTimeout( numeric timeout = 0, string timeUnit = "milliseconds" ){
		variables.futureTimeout = arguments;
		return this;
	}

	/****************************************************************
	 * Private Functions *
	 ****************************************************************/

	/**
	 * This utility wraps in the coming futures or closures and makes sure the return
	 * is an array of futures.
	 */
	private function futuresWrap(){
		var target = arguments;

		// Is the first element an array? Then use that as the builder for workloads
		if ( !isNull( arguments[ 1 ] ) && isArray( arguments[ 1 ] ) ) {
			target = arguments[ 1 ];
		}

		// I have to use arrayMap() if not lucee does not use array notation
		// but struct notation and order get's lost
		return arrayMap( target, function( future ){
			// Is this a closure/lambda/udf? Then inflate to a future
			if ( isClosure( arguments.future ) || isCustomFunction( arguments.future ) ) {
				return new Future().run( arguments.future );
			}
			// Return it
			return arguments.future;
		} ).reduce( function( results, future ){
			// Now process it
			results.append( arguments.future.getNative() );
			return results;
		}, [] );
	}

}
