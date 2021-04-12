/**
 * Static class to map ColdFusion strings units to Java units
 * A TimeUnit does not maintain time information,
 * but only helps organize and use time representations that may be maintained separately across various contexts
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
				return variables.jTimeUnit.DAYS;
			}
			case "hours": {
				return variables.jTimeUnit.HOURS;
			}
			case "microseconds": {
				return variables.jTimeUnit.MICROSECONDS;
			}
			case "milliseconds": {
				return variables.jTimeUnit.MILLISECONDS;
			}
			case "minutes": {
				return variables.jTimeUnit.MINUTES;
			}
			case "nanoseconds": {
				return variables.jTimeUnit.NANOSECONDS;
			}
			case "seconds": {
				return variables.jTimeUnit.SECONDS;
			}
		}
	}

}
