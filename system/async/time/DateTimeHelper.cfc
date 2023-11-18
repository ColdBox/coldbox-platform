/**
 * We represent a static date/time helper class that assists with time units on date/time conversions
 * It doesn't hold any date/time information.
 *
 * @see https://docs.oracle.com/en/java/javase/11/docs/api/java.base/java/time/temporal/ChronoUnit.html
 * @see https://docs.oracle.com/en/java/javase/11/docs/api/java.base/java/time/ZoneId.html
 * @see https://docs.oracle.com/en/java/javase/11/docs/api/java.base/java/time/ZoneOffset.html
 */
component singleton {

	// TimeZone Helpers
	this.ZoneOffset  = createObject( "java", "java.time.ZoneOffset" );
	this.ZoneId      = createObject( "java", "java.time.ZoneId" );
	this.ChronoField = createObject( "java", "java.time.temporal.ChronoField" );

	// The java chrono unit we model
	variables.jChronoUnit    = createObject( "java", "java.time.temporal.ChronoUnit" );
	// Java LocalDateTime class
	variables.jLocalDateTime = createObject( "java", "java.time.LocalDateTime" );
	// Unit that represents the concept of a century.
	this.CENTURIES           = variables.jChronoUnit.CENTURIES;
	// Unit that represents the concept of a day.
	this.DAYS                = variables.jChronoUnit.DAYS;
	// Unit that represents the concept of a decade.
	this.DECADES             = variables.jChronoUnit.DECADES;
	// Unit that represents the concept of an era.
	this.ERAS                = variables.jChronoUnit.ERAS;
	// Artificial unit that represents the concept of forever.
	this.FOREVER             = variables.jChronoUnit.FOREVER;
	// Unit that represents the concept of half a day, as used in AM/PM.
	this.HALF_DAYS           = variables.jChronoUnit.HALF_DAYS;
	// Unit that represents the concept of an hour.
	this.HOURS               = variables.jChronoUnit.HOURS;
	// Unit that represents the concept of a microsecond.
	this.MICROS              = variables.jChronoUnit.MICROS;
	// Unit that represents the concept of a millennium.
	this.MILLENNIA           = variables.jChronoUnit.MILLENNIA;
	// Unit that represents the concept of a millisecond.
	this.MILLIS              = variables.jChronoUnit.MILLIS;
	// Unit that represents the concept of a minute.
	this.MINUTES             = variables.jChronoUnit.MINUTES;
	// Unit that represents the concept of a month.
	this.MONTHS              = variables.jChronoUnit.MONTHS;
	// Unit that represents the concept of a nanosecond, the smallest supported unit of time.
	this.NANOS               = variables.jChronoUnit.NANOS;
	// Unit that represents the concept of a second.
	this.SECONDS             = variables.jChronoUnit.SECONDS;
	// Unit that represents the concept of a week.
	this.WEEKS               = variables.jChronoUnit.WEEKS;
	// Unit that represents the concept of a year.
	this.YEARS               = variables.jChronoUnit.YEARS;

	/**
	 * Get the current date/time as a Java LocalDateTime object in the system timezone or passed timezone
	 *
	 * @timezone The timezone to use for the current date/time. Defaults to the system timezone
	 *
	 * @return Java LocalDateTime object
	 */
	function now( String timezone ){
		return variables.jLocalDateTime.now(
			isNull( arguments.timezone ) ? getSystemTimezone() : this.ZoneId.of( arguments.timezone )
		);
	}

	/**
	 * Convert any ColdFusion date/time or string date/time object to a Java instant temporal object
	 *
	 * @target The date/time or string object representing the date/time
	 *
	 * @return A Java temporal object as java.time.Instant
	 */
	function toInstant( required target ){
		// Is this a date/time object or a string?
		if ( findNoCase( "string", arguments.target.getClass().getName() ) ) {
			arguments.target = createODBCDateTime( arguments.target );
		}
		return arguments.target.toInstant();
	}

	/**
	 * Convert any ColdFusion date/time or string date/time object to the new Java.time.LocalDateTime class so we can use them as Temporal objects
	 *
	 * @target   The cf date/time or string object representing the date/time
	 * @timezone If passed, we will use this timezone to build the temporal object. Else we default to UTC
	 *
	 * @return A Java temporal object as java.time.LocalDateTime
	 *
	 * @throws DateTimeException  - if the zone ID has an invalid format
	 * @throws ZoneRulesException - if the zone ID is a region ID that cannot be found
	 */
	function toLocalDateTime( required target, timezone ){
		return this
			.toInstant( arguments.target )
			.atZone(
				isNull( arguments.timezone ) ? this.ZoneOffset.UTC : this.ZoneId.of(
					javacast( "string", arguments.timezone )
				)
			)
			.toLocalDateTime();
	}

	/**
	 * Convert an incoming ISO-8601 formatted string to a Java LocalDateTime object
	 *
	 * @target The ISO-8601 formatted string
	 *
	 * @return a java LocalDateTime object
	 */
	function parse( required target ){
		return variables.jLocalDateTime.parse( arguments.target );
	}

	/**
	 * Convert any ColdFusion date/time or string date/time object to the new Java.time.LocalDate class so we can use them as Temporal objects
	 *
	 * @target   The cf date/time or string object representing the date/time
	 * @timezone If passed, we will use this timezone to build the temporal object. Else we default to UTC
	 *
	 * @return A Java temporal object as java.time.LocalDate
	 *
	 * @throws DateTimeException  - if the zone ID has an invalid format
	 * @throws ZoneRulesException - if the zone ID is a region ID that cannot be found
	 */
	function toLocalDate( required target, timezone ){
		return this
			.toInstant( arguments.target )
			.atZone(
				isNull( arguments.timezone ) ? this.ZoneOffset.UTC : this.ZoneId.of(
					javacast( "string", arguments.timezone )
				)
			)
			.toLocalDate();
	}

	/**
	 * Get the Java Zone ID of the passed in timezone identifier string
	 *
	 * @see      https://docs.oracle.com/en/java/javase/11/docs/api/java.base/java/time/ZoneId.html
	 * @timezone The String timezone identifier
	 *
	 * @return Java Timezone java.time.ZoneId
	 *
	 * @throws DateTimeException  - if the zone ID has an invalid format
	 * @throws ZoneRulesException - if the zone ID is a region ID that cannot be found
	 */
	function getTimezone( required string timezone ){
		return this.ZoneId.of( javacast( "string", arguments.timezone ) );
	}

	/**
	 * This queries TimeZone.getDefault() to find the default time-zone and converts it to a ZoneId. If the system default time-zone is changed, then the result of this method will also change.
	 *
	 * @see https://docs.oracle.com/en/java/javase/11/docs/api/java.base/java/time/ZoneId.html
	 *
	 * @return Java Timezone java.time.ZoneId
	 */
	function getSystemTimezone(){
		return this.ZoneId.systemDefault();
	}

	/**
	 * Get the system timezone as a string
	 *
	 * @return The system timezone as a string
	 */
	function getSystemTimezoneAsString(){
		return getSystemTimezone().getId();
	}

	/**
	 * Convert any date/time or string date/time object to a Java Date/Time
	 *
	 * @target The date/time or string object representing the date/time
	 *
	 * @return A java date time object
	 */
	function toJavaDate( required target ){
		// Is this a date/time object or a string?
		if ( findNoCase( "string", arguments.target.getClass().getName() ) ) {
			arguments.target = createODBCDateTime( arguments.target );
		}
		return arguments.target;
	}

	/**
	 * Build out a new Duration class
	 */
	Duration function duration(){
		return new coldbox.system.async.time.Duration( argumentCollection = arguments );
	}

	/**
	 * Build out a new Period class
	 */
	Period function period(){
		return new coldbox.system.async.time.Period( argumentCollection = arguments );
	}

	/**
	 * Generate an iso8601 formatted string from an incoming date/time object
	 *
	 * @dateTime The input datetime or if not passed, the current date/time
	 * @toUTC    By default, we convert all times to UTC for standardization
	 */
	string function getIsoTime( dateTime = now(), boolean toUTC = true ){
		if ( arguments.toUTC ) {
			arguments.dateTime = dateConvert( "local2utc", arguments.dateTime );
		}
		return dateTimeFormat( arguments.dateTime, "iso" );
	}

	/**
	 * This utility method gives us the first business day of the month in Java format
	 *
	 * @time     The specific time using 24 hour format => HH:mm, defaults to midnight
	 * @addMonth Boolean to specify adding a month to today's date
	 * @now      The date to use as the starting point, defaults to now()
	 * @timezone The timezone to use for the current date/time. Defaults to the system timezone
	 *
	 * @return Java LocalDateTime object
	 */
	public function getFirstBusinessDayOfTheMonth(
		string time      = "00:00",
		boolean addMonth = false,
		date now         = now(),
		string timezone  = getSystemTimezoneAsString()
	){
		// Get the last day of the month
		return toLocalDateTime(
			arguments.addMonth ? dateAdd( "m", 1, arguments.now ) : arguments.now,
			arguments.timezone
		)
			// First business day of the month
			.with(
				createObject( "java", "java.time.temporal.TemporalAdjusters" ).firstInMonth(
					createObject( "java", "java.time.DayOfWeek" ).MONDAY
				)
			)
			// Specific Time
			.withHour( javacast( "int", getToken( arguments.time, 1, ":" ) ) )
			.withMinute( javacast( "int", getToken( arguments.time, 2, ":" ) ) )
			.withSecond( javacast( "int", 0 ) );
	}

	/**
	 * This utility method gives us the last business day of the month in Java format
	 *
	 * @time     The specific time using 24 hour format => HH:mm, defaults to midnight
	 * @addMonth Boolean to specify adding a month to today's date
	 * @now      The date to use as the starting point, defaults to now()
	 * @timezone The timezone to use for the current date/time. Defaults to the system timezone
	 *
	 * @return Java LocalDateTime object
	 */
	public function getLastBusinessDayOfTheMonth(
		string time      = "00:00",
		boolean addMonth = false,
		date now         = now(),
		string timezone  = getSystemTimezoneAsString()
	){
		// Get the last day of the month
		var lastDay = toLocalDateTime(
			arguments.addMonth ? dateAdd( "m", 1, arguments.now ) : arguments.now,
			arguments.timezone
		).with( createObject( "java", "java.time.temporal.TemporalAdjusters" ).lastDayOfMonth() )
			// Specific Time
			.withHour( javacast( "int", getToken( arguments.time, 1, ":" ) ) )
			.withMinute( javacast( "int", getToken( arguments.time, 2, ":" ) ) )
			.withSecond( javacast( "int", 0 ) );
		// Verify if on weekend
		switch ( lastDay.getDayOfWeek().getValue() ) {
			// Sunday - 2 days
			case 7: {
				lastDay = lastDay.minusDays( 2 );
				break;
			}
			// Saturday - 1 day
			case 6: {
				lastDay = lastDay.minusDays( 1 );
				break;
			}
		}

		return lastDay;
	}

	/**
	 * Validates an incoming string to adhere to HH:mm while allowing a user to simply enter an hour value
	 *
	 * @time The time to check
	 *
	 * @throws InvalidTimeException - If the time is invalid, else it returns the time value
	 */
	string function validateTime( required string time ){
		if ( !reFind( "^([0-1][0-9]|[2][0-3])\:[0-5][0-9]$", arguments.time ) ) {
			if ( arguments.time.findOneOf( ":" ) > 0 ) {
				throw(
					message = "Invalid time representation (#arguments.time#). Time is represented in 24 hour minute format => HH:mm",
					type    = "InvalidTimeException"
				);
			}

			// There were no minutes, so let's add them
			return validateTime( arguments.time + ":00" );
		}

		return arguments.time;
	}

	/**
	 * Transforms the incoming value in the specified time unit to seconds
	 *
	 * @value          The value to convert to seconds
	 * @targetTimeUnit The time unit of the incoming value
	 *
	 * @return The value in seconds
	 */
	numeric function timeUnitToSeconds( required value, required targetTimeUnit ){
		// transform all to seconds
		switch ( arguments.targetTimeUnit ) {
			case "SECONDS":
				arguments.value = arguments.value * 60 * 60 * 24;
				break;
			case "HOURS":
				arguments.value = arguments.value * 60 * 60;
				break;
			case "MINUTES":
				arguments.value = arguments.value * 60;
				break;
			case "MILLISECONDS":
				arguments.value = arguments.value / 1000;
				break;
			case "MICROSECONDS":
				arguments.value = arguments.value / 1000000;
				break;
			case "NANOSECONDS":
				arguments.value = arguments.value / 1000000000;
				break;
			default:
				break;
		}
		return arguments.value;
	}

	/**
	 * Adds the specified amount of time to the target date/time
	 *
	 * @target   The target date/time to add to, this must be a Java LocalDateTime
	 * @amount   The amount to add
	 * @timeUnit The time unit of the period of addition
	 *
	 * @return The calculated date/time
	 */
	function dateTimeAdd(
		required target,
		required numeric amount,
		required timeUnit
	){
		switch ( arguments.timeUnit ) {
			case "DAYS":
				return arguments.target.plusDays( javacast( "long", amount ) );
			case "HOURS":
				return arguments.target.plusHours( javacast( "long", amount ) );
			case "MINUTES":
				return arguments.target.plusMinutes( javacast( "long", amount ) );
			case "MILLISECONDS":
				return arguments.target.plusSeconds( javacast( "long", amount / 1000 ) );
			case "MICROSECONDS":
				return arguments.target.plusNanos( javacast( "long", amount * 1000 ) );
			case "NANOSECONDS":
				return arguments.target.plusNanos( javacast( "long", amount ) );
			default:
				return arguments.target.plusSeconds( javacast( "long", amount ) );
		}
	}

}
