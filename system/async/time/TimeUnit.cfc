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
			case "days":
			case "day": {
				return variables.jTimeUnit.DAYS;
			}
			case "hours":
			case "hour": {
				return variables.jTimeUnit.HOURS;
			}
			case "microseconds":
			case "microsecond": {
				return variables.jTimeUnit.MICROSECONDS;
			}
			case "milliseconds":
			case "millisecond": {
				return variables.jTimeUnit.MILLISECONDS;
			}
			case "minutes":
			case "minute": {
				return variables.jTimeUnit.MINUTES;
			}
			case "nanoseconds":
			case "nanosecond": {
				return variables.jTimeUnit.NANOSECONDS;
			}
			case "seconds":
			case "second": {
				return variables.jTimeUnit.SECONDS;
			}
			default: {
				throw(
					type    = "InvalidTimeUnitException",
					message = "The timeunit passed (#arguments.timeunit#) is not valid",
					detail  = "Valid timeunits are days, hours, microseconds, milliseconds, minutes, nanoseconds, seconds"
				);
			}
		}
	}

}
