/**
 * This is the ColdBox Future object modeled and backed by Java's CompletableFuture but with Dynamic Goodness!
 *
 * @see https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/CompletableFuture.html
 */
component accessors="true"{

	/**
	 * The native Completable future we model: java.util.concurrent.CompletableFuture
	 */
	property name="native";

	/**
	 * Add debugging output to the thread management and operations. Defaults to false
	 */
	property name="debug" 			type="boolean" default="false";

	/**
	 * Load the CFML App context and page context's into the spawned threads. Defaults to true
	 */
	property name="loadAppContext" 	type="boolean" default="true";

	/**
	 * Constructor
	 *
	 * @value Seed the future with a completed value if passed
	 * @debug Add output debugging
	 * @loadAppContext Load the CFML App contexts or not, disable if not used
	 */
	function init( value, boolean debug=false, boolean loadAppContext=true ){
		variables.native 			= createObject( "java", "java.util.concurrent.CompletableFuture" );
		variables.debug 			= arguments.debug;
		variables.loadAppContext 	= arguments.loadAppContext;

		if( !isNull( arguments.value ) ){
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
	boolean function cancel( boolean mayInterruptIfRunning=true ){
		return variables.native.cancel(
			javaCast( "boolean", arguments.mayInterruptIfRunning )
		);
	}

	/**
	 * If not already completed, sets the value returned by get() and related methods to the given value.
	 *
	 * @value The value to set
	 *
	 * @return true if this invocation caused this CompletableFuture to transition to a completed state, else false
	 */
	boolean function complete( value ){
		return variables.native.complete( arguments.value );
	}

	/**
	 * If not already completed, causes invocations of get() and related methods to throw the given exception.
	 *
	 * @message An optional message to add to the exception to be thrown.
	 *
	 * @returns true if this invocation caused this CompletableFuture to transition to a completed state, else false
	 */
	boolean function completeWithException( message="Future operation completed with manual exception" ){
		return variables.native.completeExceptionally(
			createObject( "java", "java.lang.RuntimeException" ).init( arguments.message )
		);
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
	any function get( numeric timeout=0, string timeUnit="seconds", defaultValue ){
		var jTimeUnit = createObject( "java", "java.util.concurrent.TimeUnit" );

		switch( arguments.timeUnit ){
			case "days"         : { arguments.timeUnit = jTimeUnit.DAYS; break; }
			case "hours"        : { arguments.timeUnit = jTimeUnit.HOURS; break; }
			case "microseconds" : { arguments.timeUnit = jTimeUnit.MICROSECONDS; break; }
			case "milliseconds" : { arguments.timeUnit = jTimeUnit.MILLISECONDS; break; }
			case "minutes"      : { arguments.timeUnit = jTimeUnit.MINUTES; break; }
			case "nanoseconds"  : { arguments.timeUnit = jTimeUnit.NANOSECONDS; break; }
			case "seconds"      : { arguments.timeUnit = jTimeUnit.SECONDS; break; }
		}

		// Do we have a timeout?
		if( arguments.timeout != 0 ){
			var results = variables.native.get(
				javaCast( "long", arguments.timeout ),
				arguments.timeUnit
			);
		} else {
			var results = variables.native.get();
		}


		// If we have results, return them
		if( !isNull( results ) ){
			return results;
		}

		// If we didn't, do we have a default value
		if( !isNull( arguments.defaultValue ) ){
			return arguments.defaultValue;
		}
		// Else return null
	}

	/**
	 * Returns the result value (or throws any encountered exception) if completed, else returns the given defaultValue.
	 *
	 * @defaultValue The value to return  if not completed
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
	boolean function isCompletedWithException(){
		return variables.native.isCompletedExceptionally();
	}

	/**
	 * Returns true if completed in any fashion: normally, exceptionally, or via cancellation.
	 */
	boolean function isDone(){
		return variables.native.isDone();
	}

	/**
	 *
	 * @ex
	 */
	function onException( ex ){

	}

	/**
	 * Executes a runnable closure or component method via Java's CompletableFuture and gives you back a ColdBox Future
	 *
	 * @runnable A CFC instance or closure/lambda to execute async
	 * @method If the runnable is a CFC, then it executes a method on the CFC for you. Defaults to the `run()` method
	 */
	Future function run(
		required runnable,
		method="run"
	){
		var supplier = createDynamicProxy(
			new proxies.Supplier( arguments.runnable, arguments.method, variables.debug, variables.loadAppContext ),
			[ "java.util.function.Supplier" ]
		);

		// Supply the future and start the task
		variables.native = variables.native.supplyAsync( supplier );

		return this;
	}

	/**
	 * Executed once the computation has finalized and a result is passed in to the target.  The target can then run anything it likes and either return a value or not.
	 */
	Future function then( required target ){
		var apply = createDynamicProxy(
			new proxies.Function( arguments.target, variables.debug, variables.loadAppContext ),
			[ "java.util.function.Function" ]
		);

		variables.native = variables.native.thenApply( apply );

		return this;
	}
}