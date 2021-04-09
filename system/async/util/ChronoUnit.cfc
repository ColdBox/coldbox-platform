component singleton {

	// A standard set of date periods units.
	variables.jChronoUnit = createObject( "java", "java.time.temporal.ChronoUnit" );
	// Unit that represents the concept of a century.
	this.CENTURIES        = variables.jChronoUnit.CENTURIES;
	// Unit that represents the concept of a day.
	this.DAYS             = variables.jChronoUnit.DAYS;
	// Unit that represents the concept of a decade.
	this.DECADES          = variables.jChronoUnit.DECADES;
	// Unit that represents the concept of an era.
	this.ERAS             = variables.jChronoUnit.ERAS;
	// Artificial unit that represents the concept of forever.
	this.FOREVER          = variables.jChronoUnit.FOREVER;
	// Unit that represents the concept of half a day, as used in AM/PM.
	this.HALF_DAYS        = variables.jChronoUnit.HALF_DAYS;
	// Unit that represents the concept of an hour.
	this.HOURS            = variables.jChronoUnit.HOURS;
	// Unit that represents the concept of a microsecond.
	this.MICROS           = variables.jChronoUnit.MICROS;
	// Unit that represents the concept of a millennium.
	this.MILLENNIA        = variables.jChronoUnit.MILLENNIA;
	// Unit that represents the concept of a millisecond.
	this.MILLIS           = variables.jChronoUnit.MILLIS;
	// Unit that represents the concept of a minute.
	this.MINUTES          = variables.jChronoUnit.MINUTES;
	// Unit that represents the concept of a month.
	this.MONTHS           = variables.jChronoUnit.MONTHS;
	// Unit that represents the concept of a nanosecond, the smallest supported unit of time.
	this.NANOS            = variables.jChronoUnit.NANOS;
	// Unit that represents the concept of a second.
	this.SECONDS          = variables.jChronoUnit.SECONDS;
	// Unit that represents the concept of a week.
	this.WEEKS            = variables.jChronoUnit.WEEKS;
	// Unit that represents the concept of a year.
	this.YEARS            = variables.jChronoUnit.YEARS;

	/**
	 * Convert any date/time or string date/time object to a Java instant temporal object
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
	 * Convert any date/time or string date/time object to a Java LocalDate
	 *
	 * @target The date/time or string object representing the date/time
	 *
	 * @return A java LocalDate object
	 */
	function toLocalDate( required target ){
		// Is this a date/time object or a string?
		if ( findNoCase( "string", arguments.target.getClass().getName() ) ) {
			arguments.target = createODBCDateTime( arguments.target );
		}
		return arguments.target;
	}

}
