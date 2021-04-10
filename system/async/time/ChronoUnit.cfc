component singleton {

	variables.jChronoUnit = createObject( "java", "java.time.temporal.ChronoUnit" );
	variables.ZoneOffset  = createObject( "java", "java.time.ZoneOffset" );
	variables.ZoneId      = createObject( "java", "java.time.ZoneId" );

	// Unit that represents the concept of a century.
	this.CENTURIES = variables.jChronoUnit.CENTURIES;
	// Unit that represents the concept of a day.
	this.DAYS      = variables.jChronoUnit.DAYS;
	// Unit that represents the concept of a decade.
	this.DECADES   = variables.jChronoUnit.DECADES;
	// Unit that represents the concept of an era.
	this.ERAS      = variables.jChronoUnit.ERAS;
	// Artificial unit that represents the concept of forever.
	this.FOREVER   = variables.jChronoUnit.FOREVER;
	// Unit that represents the concept of half a day, as used in AM/PM.
	this.HALF_DAYS = variables.jChronoUnit.HALF_DAYS;
	// Unit that represents the concept of an hour.
	this.HOURS     = variables.jChronoUnit.HOURS;
	// Unit that represents the concept of a microsecond.
	this.MICROS    = variables.jChronoUnit.MICROS;
	// Unit that represents the concept of a millennium.
	this.MILLENNIA = variables.jChronoUnit.MILLENNIA;
	// Unit that represents the concept of a millisecond.
	this.MILLIS    = variables.jChronoUnit.MILLIS;
	// Unit that represents the concept of a minute.
	this.MINUTES   = variables.jChronoUnit.MINUTES;
	// Unit that represents the concept of a month.
	this.MONTHS    = variables.jChronoUnit.MONTHS;
	// Unit that represents the concept of a nanosecond, the smallest supported unit of time.
	this.NANOS     = variables.jChronoUnit.NANOS;
	// Unit that represents the concept of a second.
	this.SECONDS   = variables.jChronoUnit.SECONDS;
	// Unit that represents the concept of a week.
	this.WEEKS     = variables.jChronoUnit.WEEKS;
	// Unit that represents the concept of a year.
	this.YEARS     = variables.jChronoUnit.YEARS;

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
	 * Convert any ColdFUsion date/time or string date/time object to the new Java.time.LocalDate class so we can use them as Temporal objects
	 *
	 * @target The cf date/time or string object representing the date/time
	 * @timezone If passed, we will use this timezone to build the temporal object. Else we default to UTC
	 *
	 * @throws DateTimeException - if the zone ID has an invalid format
	 * @throws ZoneRulesException - if the zone ID is a region ID that cannot be found
	 *
	 * @return A Java temporal object as java.time.LocalDate
	 */
	function toLocalDate( required target, timezone ){
		return this
			.toInstant( arguments.target )
			.atZone(
				isNull( arguments.timezone ) ? variables.ZoneOffset.UTC : variables.ZoneId.of( arguments.timezone )
			)
			.toLocalDate();
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

}
