/**
 * This is a ColdBox Scheduled Future object modeled and backed by Java's ScheduledFuture interface but with Dynamic Goodness!
 *
 * @see https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/ScheduledFuture.html
 */
component accessors="true" {

	/**
	 * The native Scheduled future we model: java.util.concurrent.ScheduledFuture
	 */
	property name="native";

	// Prepare the static time unit class
	this.timeUnit = new TimeUnit();

	/**
	 * Build the ColdBox ScheduledFuture with the Java native class
	 *
	 * @native The native ScheduledFuture class we are wrapping
	 */
	ScheduledFuture function init( native ){
		if( isNull( arguments.native ) ){
			arguments.native = createObject( "java", "java.util.concurrent.ScheduledThreadPoolExecutor$ScheduledFutureTask" );
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
				this.timeUnit.get( arguments.timeUnit )
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

	/**
	 * Returns true if the scheduled task is periodic or not
	 */
	boolean function isPeriodic(){
		return variables.native.isPeriodic();
	}

	/**
	 * Get the delay of the scheduled task in the given time unit
	 *
	 * @timeUnit The time unit to use, available units are: days, hours, microseconds, milliseconds, minutes, nanoseconds, and seconds. The default is seconds
	 */
	numeric function getDelay( timeUnit="seconds" ){
		return variables.native.getDelay(
			variables.timeUnit.get( arguments.timeUnit )
		);
	}

}