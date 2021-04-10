/**
 * This is a ColdBox Future Task object modeled and backed by Java's Future interface but with Dynamic Goodness!
 *
 * This is the return of most of the executors when you send runnables to execute
 *
 * @see https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/Future.html
 */
component accessors="true" {

	/**
	 * The native future we model: java.util.concurrent.Future
	 */
	property name="native";

	// Prepare the static time unit class
	this.$timeUnit = new coldbox.system.async.time.TimeUnit();

	/**
	 * Build the ColdBox Future with the Java native class
	 *
	 * @native The native Future class we are wrapping
	 */
	FutureTask function init( native ){
		if ( isNull( arguments.native ) ) {
			arguments.native = createObject( "java", "java.util.concurrent.FutureTask" );
		}
		variables.native = arguments.native;
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
	 * Waits if necessary for at most the given time for this future to complete, and then returns its result, if available.
	 * If the result is null, then you can pass the defaultValue argument to return it.
	 *
	 * @timeout The timeout value to use, defaults to forever
	 * @timeUnit The time unit to use, available units are: days, hours, microseconds, milliseconds, minutes, nanoseconds, and seconds. The default is milliseconds
	 * @defaultValue If the Future did not produce a value, then it will return this default value.
	 *
	 * @returns The result value
	 * @throws CancellationException, ExecutionException, InterruptedException, TimeoutException
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
				// Empty, because we will return a default value if passed
			}
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
	 * Returns true if this Future was cancelled before it completed normally.
	 */
	boolean function isCancelled(){
		return variables.native.isCancelled();
	}

	/**
	 * Returns true if completed in any fashion: normally, exceptionally, or via cancellation.
	 */
	boolean function isDone(){
		return variables.native.isDone();
	}

}
