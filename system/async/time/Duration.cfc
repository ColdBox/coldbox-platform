/**
 * A time-based amount of time, such as '34.5 seconds'.
 *
 * This class models a quantity or amount of time in terms of seconds and nanoseconds.
 * It can be accessed using other duration-based units, such as minutes and hours.
 * In addition, the DAYS unit can be used and is treated as exactly equal to 24 hours, thus ignoring daylight savings effects.
 * See Period for the date-based equivalent to this class.
 *
 * Static class to map to the Java JDK Duration static class with some CF Goodness
 *
 * @see https://docs.oracle.com/en/java/javase/11/docs/api/java.base/java/time/Duration.html
 */
component accessors="true" {

	// The static java class we represent
	variables.jDuration = createObject( "java", "java.time.Duration" );
	// A standard set of date periods units.
	this.CHRONO_UNIT    = new ChronoUnit();

	/**
	 * Initialize to zero
	 */
	function init(){
		return this.of( 0 );
	}

	/**
	 * --------------------------------------------------------------------------
	 * Utility Methods
	 * --------------------------------------------------------------------------
	 */

	/**
	 * Get the native java class we proxy to.
	 *
	 * @return java.time.Duration
	 */
	any function getNative(){
		return variables.jDuration;
	}

	/**
	 * Returns a copy of this duration with a positive length.
	 */
	Duration function abs(){
		variables.jDuration = variables.jDuration.abs();
		return this;
	}

	/**
	 * Checks if the duration is negative, excluding zero
	 */
	boolean function isNegative(){
		return variables.jDuration.isNegative();
	}

	/**
	 * Checks if the duration is zero length
	 */
	boolean function isZero(){
		return variables.jDuration.isZero();
	}

	/**
	 * Checks if this duration is equal to the specified Duration.
	 *
	 * @otherDuration The duration to compare against
	 */
	boolean function isEquals( required Duration otherDuration ){
		return variables.jDuration.equals( arguments.otherDuration.getNative() );
	}

	/**
	 * Returns a copy of this duration with the length negated.
	 */
	Duration function negated(){
		variables.jDuration = variables.jDuration.negated();
		return this;
	}

	/**
	 * --------------------------------------------------------------------------
	 * Retrieval Methods
	 * --------------------------------------------------------------------------
	 */

	/**
	 * Gets the value of the requested unit in seconds by default or by nanoseconds
	 *
	 * @unit Seconds or nano
	 *
	 * @throws UnsupportedTemporalTypeException This returns a value for each of the two supported units, SECONDS and NANOS. All other units throw an exception.
	 */
	numeric function get( unit = "seconds" ){
		return variables.jDuration.get( this.CHRONO_UNIT[ arguments.unit ] );
	}

	/**
	 * Gets the number of seconds in this duration.
	 */
	numeric function getSeconds(){
		return this.get();
	}

	/**
	 * Gets the number of nano seconds in this duration.
	 */
	numeric function getNano(){
		return this.get( "nanos" );
	}

	/**
	 * Gets the set (array) of units supported by this duration.
	 */
	array function getUnits(){
		return arrayMap( variables.jDuration.getUnits(), function( thisItem ){
			return arguments.thisItem.name();
		} );
	}

	/**
	 * Gets the number of days in this duration.
	 */
	numeric function toDays(){
		return variables.jDuration.toDays();
	}

	/**
	 * Extracts the number of days in the duration.
	 */
	numeric function toDaysPart(){
		return variables.jDuration.toDaysPart();
	}

	/**
	 * Gets the number of Hours in this duration.
	 */
	numeric function toHours(){
		return variables.jDuration.toHours();
	}

	/**
	 * Extracts the number of HoursPart in this duration.
	 */
	numeric function toHoursPart(){
		return variables.jDuration.toHoursPart();
	}

	/**
	 * Gets the number of Millis in this duration.
	 */
	numeric function toMillis(){
		return variables.jDuration.toMillis();
	}

	/**
	 * Extracts the number of MillisPart in this duration.
	 */
	numeric function toMillisPart(){
		return variables.jDuration.toMillisPart();
	}

	/**
	 * Gets the number of Minutes in this duration.
	 */
	numeric function toMinutes(){
		return variables.jDuration.toMinutes();
	}

	/**
	 * Extracts the number of MinutesPart in this duration.
	 */
	numeric function toMinutesPart(){
		return variables.jDuration.toMinutesPart();
	}

	/**
	 * Gets the number of Nanos in this duration.
	 */
	numeric function toNanos(){
		return variables.jDuration.toNanos();
	}

	/**
	 * Extracts the number of NanosPart in this duration.
	 */
	numeric function toNanosPart(){
		return variables.jDuration.toNanosPart();
	}

	/**
	 * Gets the number of Seconds in this duration.
	 */
	numeric function toSeconds(){
		return variables.jDuration.toSeconds();
	}

	/**
	 * Extracts the number of SecondsPart in this duration.
	 */
	numeric function toSecondsPart(){
		return variables.jDuration.toSecondsPart();
	}

	/**
	 * A string representation of this duration using ISO-8601 seconds based representation, such as PT8H6M12.345S.
	 */
	string function toString(){
		return variables.jDuration.toString();
	}

	/**
	 * --------------------------------------------------------------------------
	 * Operations Methods
	 * --------------------------------------------------------------------------
	 */

	/**
	 * Adds this duration to the specified temporal object and return back to you a date/time object
	 *
	 * @target The date/time object or string to incorporate the duration into
	 * @asInstant Return the result either as a date/time string or a java.time.Instant object
	 *
	 * @return Return the result either as a date/time string or a java.time.Instant object
	 */
	function addTo( required target, boolean asInstant = false ){
		var results = variables.jDuration.addTo( this.CHRONO_UNIT.toInstant( arguments.target ) );
		return ( arguments.asInstant ? results : results.toString() );
	}

	/**
	 * Subtracts this duration to the specified temporal object and return back to you a date/time object
	 *
	 * @target The date/time object or string to subtract the duration from
	 * @asInstant Return the result either as a date/time string or a java.time.Instant object
	 *
	 * @return Return the result either as a date/time string or a java.time.Instant object
	 */
	function subtractFrom( required target, boolean asInstant = false ){
		var results = variables.jDuration.subtractFrom( this.CHRONO_UNIT.toInstant( arguments.target ) );
		return ( arguments.asInstant ? results : results.toString() );
	}

	/**
	 * Obtains a Duration representing the duration between two temporal date objects.
	 *
	 * This calculates the duration between two temporal objects. If the objects are of different types,
	 * then the duration is calculated based on the type of the first object. For example, if the first argument is a
	 * LocalTime then the second argument is converted to a LocalTime.
	 *
	 * @start The start date/time object
	 * @end The end date/time object
	 */
	Duration function between( required start, required end ){
		// Do it!
		variables.jDuration = variables.jDuration.between(
			this.CHRONO_UNIT.toInstant( arguments.start ),
			this.CHRONO_UNIT.toInstant( arguments.end )
		);
		return this;
	}

	/**
	 * Compares this duration to the specified Duration.
	 *
	 * The comparison is based on the total length of the durations. It is "consistent with equals", as defined by Comparable.
	 *
	 * @otherDuration the other duration to compare to
	 *
	 * @return -1 if the duration is less than the otherDuration, 0 if equals, and 1 if greater than
	 */
	function compareTo( required Duration otherDuration ){
		return variables.jDuration.compareTo( arguments.otherDuration.getNative() );
	}

	/**
	 * Returns a copy of this duration divided by the specified value.
	 *
	 * @divisor Divide by what?
	 */
	Duration function dividedBy( required divisor ){
		variables.jDuration = variables.jDuration.dividedBy( javacast( "long", arguments.divisor ) );
		return this;
	}

	/**
	 * Returns a copy of this duration with the specified duration subtracted.
	 *
	 * @amountToSubtract The amount to subtract
	 * @unit The units to use
	 */
	Duration function minus( required amountToSubtract, unit = "seconds" ){
		variables.jDuration = variables.jDuration.minus(
			javacast( "long", arguments.amountToSubtract ),
			this.CHRONO_UNIT[ arguments.unit ]
		);
		return this;
	}

	Duration function minusDays( required daysToSubtract ){
		return this.minus( arguments.daysToSubtract, "days" );
	}

	Duration function minusHours( required hoursToSubtract ){
		return this.minus( arguments.hoursToSubtract, "hours" );
	}

	Duration function minusMillis( required millisToSubtract ){
		return this.minus( arguments.millisToSubtract, "millis" );
	}

	Duration function minusMinutes( required minutesToSubtract ){
		return this.minus( arguments.minutesToSubtract, "minutes" );
	}

	Duration function minusNanos( required nanosToSubtract ){
		return this.minus( arguments.nanosToSubtract, "nanos" );
	}

	Duration function minusSeconds( required secondsToSubtract ){
		return this.minus( arguments.secondsToSubtract, "seconds" );
	}

	Duration function multipliedBy( required multiplicand ){
		variables.jDuration = variables.jDuration.multipliedBy( javacast( "long", arguments.multiplicand ) );
		return this;
	}

	/**
	 * Returns a copy of this duration with the specified duration added.
	 *
	 * @amountToAdd The amount to add
	 * @unit The units to use
	 */
	Duration function plus( required amountToAdd, unit = "seconds" ){
		variables.jDuration = variables.jDuration.plus(
			javacast( "long", arguments.amountToAdd ),
			this.CHRONO_UNIT[ arguments.unit ]
		);
		return this;
	}

	Duration function plusDays( required daysToAdd ){
		return this.plus( arguments.daysToAdd, "days" );
	}

	Duration function plusHours( required hoursToAdd ){
		return this.plus( arguments.hoursToAdd, "hours" );
	}

	Duration function plusMillis( required millisToAdd ){
		return this.plus( arguments.millisToAdd, "millis" );
	}

	Duration function plusMinutes( required minutesToAdd ){
		return this.plus( arguments.minutesToAdd, "minutes" );
	}

	Duration function plusNanos( required nanosToAdd ){
		return this.plus( arguments.nanosToAdd, "nanos" );
	}

	Duration function plusSeconds( required secondsToAdd ){
		return this.plus( arguments.secondsToAdd, "seconds" );
	}

	/**
	 * --------------------------------------------------------------------------
	 * Creation Methods
	 * --------------------------------------------------------------------------
	 */

	/**
	 * Returns a copy of this duration with the specified nano-of-second.
	 * This returns a duration with the specified nano-of-second, retaining the seconds part of this duration.
	 *
	 * @nanoOfSecond the nano-of-second to represent, from 0 to 999,999,999
	 */
	function withNanos( required nanoOfSecond ){
		variables.jDuration = variables.jDuration.withNanos( javacast( "long", arguments.nanoOfSecond ) );
		return this;
	}

	/**
	 * Returns a copy of this duration with the specified amount of seconds.
	 * This returns a duration with the specified seconds, retaining the nano-of-second part of this duration.
	 *
	 * @seconds the seconds to represent, may be negative
	 */
	function withSeconds( required seconds ){
		variables.jDuration = variables.jDuration.withSeconds( javacast( "long", arguments.seconds ) );
		return this;
	}

	/**
	 * Obtains a Duration from a text string such as PnDTnHnMn.nS.
	 *
	 *  This will parse a textual representation of a duration, including the string produced by toString(). The formats accepted are based on the ISO-8601 duration format PnDTnHnMn.nS with days considered to be exactly 24 hours.
	 *
	 * Examples:
	 * "PT20.345S" -- parses as "20.345 seconds"
	 * "PT15M"     -- parses as "15 minutes" (where a minute is 60 seconds)
	 * "PT10H"     -- parses as "10 hours" (where an hour is 3600 seconds)
	 * "P2D"       -- parses as "2 days" (where a day is 24 hours or 86400 seconds)
	 * "P2DT3H4M"  -- parses as "2 days, 3 hours and 4 minutes"
	 * "PT-6H3M"    -- parses as "-6 hours and +3 minutes"
	 * "-PT6H3M"    -- parses as "-6 hours and -3 minutes"
	 * "-PT-6H+3M"  -- parses as "+6 hours and -3 minutes"
	 *
	 * @see https://docs.oracle.com/en/java/javase/11/docs/api/java.base/java/time/Duration.html#parse(java.lang.CharSequence)
	 *
	 * @text The string to parse and build up to a duration
	 */
	Duration function parse( required text ){
		variables.jDuration = variables.jDuration.parse( arguments.text );
		return this;
	}

	/**
	 * Obtains an instance of Duration from another duration
	 *
	 * @amount
	 */
	function from( required Duration amount ){
		variables.jDuration = variables.jDuration.from( arguments.amount.getNative() );
		return this;
	}

	/**
	 * Obtains a Duration representing an amount in the specified unit (seconds)
	 *
	 * @amount the amount of the duration, measured in terms of the unit, positive or negative
	 * @unit The time unit: CENTURIES,DAYS,DECADES,ERAS,FOREVER,HALF_DAYS,HOURS,MICROS,MILLENNIA,MILLIS,MINUTES,MONTHS,NANOS,SECONDS,WEEKS,YEARS
	 */
	Duration function of( required amount, unit = "seconds" ){
		variables.jDuration = variables.jDuration.of(
			javacast( "long", arguments.amount ),
			this.CHRONO_UNIT[ arguments.unit ]
		);
		return this;
	}

	/**
	 * Obtains a Duration representing a number of standard 24 hour days.
	 *
	 * @days The number of days, positive or negative
	 */
	Duration function ofDays( required days ){
		return this.of( arguments.days, "days" );
	}

	/**
	 * Obtains a Duration representing a number of standard hours.
	 *
	 * @hours The number of hours, positive or negative
	 */
	Duration function ofHours( required hours ){
		return this.of( arguments.hours, "hours" );
	}

	/**
	 * Obtains a Duration representing a number of standard minutes
	 *
	 * @minutes The number of minutes, positive or negative
	 */
	Duration function ofMinutes( required minutes ){
		return this.of( arguments.minutes, "minutes" );
	}

	/**
	 * Obtains a Duration representing a number of seconds and/or an adjustment in nanoseconds.
	 *
	 * This method allows an arbitrary number of nanoseconds to be passed in.
	 * The factory will alter the values of the second and nanosecond in order to ensure that the stored nanosecond is in the range
	 * 0 to 999,999,999. For example, the following will result in exactly the same duration:
	 *
	 * @seconds The number of seconds, positive or negative
	 * @nanoAdjustment the nanosecond adjustment to the number of seconds, positive or negative
	 */
	Duration function ofSeconds( required seconds, nanoAdjustment ){
		if ( isNull( arguments.nanoAdjustment ) ) {
			return this.of( arguments.seconds, "seconds" );
		}
		// Width Adjustment
		variables.jDuration = variables.jDuration.ofSeconds(
			javacast( "long", arguments.seconds ),
			javacast( "long", arguments.nanoAdjustment )
		);
		return this;
	}

	/**
	 * Obtains a Duration representing a number of standard milliseconds
	 *
	 * @millis The number of millis, positive or negative
	 */
	Duration function ofMillis( required millis ){
		return this.of( arguments.millis, "millis" );
	}

	/**
	 * Obtains a Duration representing a number of standard nanoseconds
	 *
	 * @nanos The number of nanos, positive or negative
	 */
	Duration function ofNanos( required nanos ){
		return this.of( arguments.nanos, "nanos" );
	}

}
