/**
 * Static class to map ColdFusion string timeouts to Java Timeouts
 */
component singleton {

	// The static java class
	variables.jTimeUnit = createObject( "java", "java.util.concurrent.TimeUnit" );

	/**
	 * Get the appropriate Java timeunit class according to string conventions
	 *
	 * @timeUnit The time unit to use, available units are: days, hours, microseconds, milliseconds, minutes, nanoseconds, and seconds. The default is milliseconds
	 *
	 * @return The Java time unit class
	 */
	function get( required timeUnit = "milliseconds" ){
		switch ( arguments.timeUnit ) {
			case "days": {
				return jTimeUnit.DAYS;
			}
			case "hours": {
				return jTimeUnit.HOURS;
			}
			case "microseconds": {
				return jTimeUnit.MICROSECONDS;
			}
			case "milliseconds": {
				return jTimeUnit.MILLISECONDS;
			}
			case "minutes": {
				return jTimeUnit.MINUTES;
			}
			case "nanoseconds": {
				return jTimeUnit.NANOSECONDS;
			}
			case "seconds": {
				return jTimeUnit.SECONDS;
			}
		}
	}

}
