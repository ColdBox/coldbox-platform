/**
 * This is a ColdBox Scheduled Future object modeled and backed by Java's ScheduledFuture & Future interface but with Dynamic Goodness!
 *
 * @see https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/ScheduledFuture.html
 */
component accessors="true" extends="FutureTask" {

	/**
	 * Build the ColdBox ScheduledFuture with the Java native class
	 *
	 * @native The native ScheduledFuture class we are wrapping
	 */
	ScheduledFuture function init( native ){
		if ( isNull( arguments.native ) ) {
			arguments.native = createObject(
				"java",
				"java.util.concurrent.ScheduledThreadPoolExecutor$ScheduledFutureTask"
			);
		}
		variables.native = arguments.native;
		return this;
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
	 * @timeUnit The time unit to use, available units are: days, hours, microseconds, milliseconds, minutes, nanoseconds, and seconds. The default is milliseconds
	 */
	numeric function getDelay( timeUnit = "milliseconds" ){
		return variables.native.getDelay( this.$timeUnit.get( arguments.timeUnit ) );
	}

}
