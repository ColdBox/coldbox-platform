/**
 * A date-based amount of time in the ISO-8601 calendar system, such as '2 years, 3 months and 4 days'.
 *
 * This class models a quantity or amount of time in terms of years, months and days. See Duration for the time-based equivalent to this class.
 *
 * Durations and periods differ in their treatment of daylight savings time when added to ZonedDateTime.
 * A Duration will add an exact number of seconds, thus a duration of one day is always exactly 24 hours. By contrast, a Period will add a
 * conceptual day, trying to maintain the local time.
 *
 * For example, consider adding a period of one day and a duration of one day to 18:00 on the evening before a daylight savings gap.
 * The Period will add the conceptual day and result in a ZonedDateTime at 18:00 the following day. By contrast, the Duration will add exactly
 * 24 hours, resulting in a ZonedDateTime at 19:00 the following day (assuming a one hour DST gap).
 *
 * @see https://docs.oracle.com/en/java/javase/11/docs/api/java.base/java/time/Period.html
 */
component accessors="true" {

	// The static java class we represent
	variables.jPeriod = createObject( "java", "java.time.Period" );
	// A standard set of date periods units.
	this.CHRONO_UNIT  = new ChronoUnit();

	/**
	 * Initialize to zero date base period
	 *
	 * @years The years
	 * @months The months
	 * @days The days
	 */
	Period function init( years = 0, months = 0, days = 0 ){
		return this.of( argumentCollection = arguments );
	}

	/**
	 * --------------------------------------------------------------------------
	 * Utility Methods
	 * --------------------------------------------------------------------------
	 */

	/**
	 * Get the native java class we proxy to.
	 *
	 * @return java.time.Period
	 */
	any function getNative(){
		return variables.jPeriod;
	}

	/**
	 * Checks if the period is negative, excluding zero
	 */
	boolean function isNegative(){
		return variables.jPeriod.isNegative();
	}

	/**
	 * Checks if the period is zero length
	 */
	boolean function isZero(){
		return variables.jPeriod.isZero();
	}

	/**
	 * Checks if this period is equal to the specified period.
	 *
	 * @otherPeriod The period to compare against
	 */
	boolean function isEquals( required Period otherPeriod ){
		return variables.jPeriod.equals( arguments.otherPeriod.getNative() );
	}

	/**
	 * Returns a copy of this duration with the length negated.
	 */
	Period function negated(){
		variables.jPeriod = variables.jPeriod.negated();
		return this;
	}

	/**
	 * Returns a copy of this period with the years and months normalized.
	 */
	Period function normalized(){
		variables.jPeriod = variables.jPeriod.normalized();
		return this;
	}

	/**
	 * --------------------------------------------------------------------------
	 * Retrieval Methods
	 * --------------------------------------------------------------------------
	 */

	/**
	 * Gets the value of the requested unit in seconds by default (days) or years, months, days
	 *
	 * @unit years, months, days
	 *
	 * @throws UnsupportedTemporalTypeException All other units throw an exception.
	 */
	numeric function get( unit = "days" ){
		return variables.jPeriod.get( this.CHRONO_UNIT[ arguments.unit ] );
	}

	/**
	 * Gets the chronology of this period, which is the ISO calendar system.
	 *
	 * @return java.time.chrono.IsoChronology
	 */
	function getChronology(){
		return variables.jPeriod.getChronology();
	}

	/**
	 * Gets the number of Days in this period.
	 */
	numeric function getDays(){
		return this.get( "days" );
	}

	/**
	 * Gets the number of Months in this period.
	 */
	numeric function getMonths(){
		return this.get( "months" );
	}

	/**
	 * Gets the number of Years in this period.
	 */
	numeric function getYears(){
		return this.get( "years" );
	}

	/**
	 * Gets the set (array) of units supported by this period.
	 */
	array function getUnits(){
		return arrayMap( variables.jPeriod.getUnits(), function( thisItem ){
			return arguments.thisItem.name();
		} );
	}

	/**
	 * Gets the total number of months in this period.
	 */
	numeric function toTotalMonths(){
		return variables.jPeriod.toTotalMonths();
	}

	/**
	 * Outputs this period as a String, such as P6Y3M1D.
	 */
	string function toString(){
		return variables.jPeriod.toString();
	}

	/**
	 * --------------------------------------------------------------------------
	 * Operations Methods
	 * --------------------------------------------------------------------------
	 */

	/**
	 * Adds this period to the specified temporal object and return back to you a date/time object
	 *
	 * @target The date/time object or string to incorporate the period into
	 * @asNative If true, we will give you the java.time.LocalDate object, else a ColdFusion date/time string
	 *
	 * @return The date/time object with the period added to it or a java LocalDate
	 */
	function addTo( required target, boolean asNative = false ){
		var results = variables.jPeriod.addTo( this.CHRONO_UNIT.toLocalDate( arguments.target ) );
		return ( arguments.asNative ? results : results.toString() );
	}

	/**
	 * Subtracts this period to the specified temporal object and return back to you a date/time object or a Java LocalDate object
	 *
	 * @target The date/time object or string to incorporate the period into
	 * @asNative If true, we will give you the java.time.LocalDate object, else a ColdFusion date/time string
	 *
	 * @return Return the result either as a date/time string or a java.time.LocalDate object
	 */
	function subtractFrom( required target, boolean asNative = false ){
		var results = variables.jPeriod.subtractFrom( this.CHRONO_UNIT.toLocalDate( arguments.target ) );
		return ( arguments.asNative ? results : results.toString() );
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
	Period function between( required start, required end ){
		// Do it!
		variables.jPeriod = variables.jPeriod.between(
			this.CHRONO_UNIT.toJavaDate( arguments.start ),
			this.CHRONO_UNIT.toJavaDate( arguments.end )
		);
		return this;
	}

	/**
	 * Returns a copy of this period with the specified period subtracted.
	 *
	 * @amountToSubtract The period to subtract
	 */
	Period function minus( required Period amountToSubtract ){
		variables.jPeriod = variables.jPeriod.minus( arguments.amountToSubtract.getNative() );
		return this;
	}

	Period function minusDays( required daysToSubtract ){
		variables.jPeriod = variables.jPeriod.minusDays( javacast( "long", arguments.daysToSubtract ) );
		return this;
	}

	Period function minusMonths( required monthsToSubtract ){
		variables.jPeriod = variables.jPeriod.minusMonths( javacast( "long", arguments.monthsToSubtract ) );
		return this;
	}

	Period function minusYears( required yearsToSubtract ){
		variables.jPeriod = variables.jPeriod.minusYears( javacast( "long", arguments.yearsToSubtract ) );
		return this;
	}

	Period function multipliedBy( required scalar ){
		variables.jPeriod = variables.jPeriod.multipliedBy( javacast( "int", arguments.scalar ) );
		return this;
	}

	/**
	 * Returns a copy of this period with the specified period added.
	 *
	 * @amountToAdd The period to Add
	 */
	Period function plus( required Period amountToAdd ){
		variables.jPeriod = variables.jPeriod.plus( arguments.amountToAdd.getNative() );
		return this;
	}

	Period function plusDays( required daysToAdd ){
		variables.jPeriod = variables.jPeriod.plusDays( javacast( "long", arguments.daysToAdd ) );
		return this;
	}

	Period function plusMonths( required monthsToAdd ){
		variables.jPeriod = variables.jPeriod.plusMonths( javacast( "long", arguments.monthsToAdd ) );
		return this;
	}

	Period function plusYears( required yearsToAdd ){
		variables.jPeriod = variables.jPeriod.plusYears( javacast( "long", arguments.yearsToAdd ) );
		return this;
	}

	/**
	 * --------------------------------------------------------------------------
	 * Creation Methods
	 * --------------------------------------------------------------------------
	 */

	/**
	 * Returns a copy of this period with the specified amount of days.
	 *
	 * @days The days
	 */
	function withDays( required days ){
		variables.jPeriod = variables.jPeriod.withDays( javacast( "long", arguments.days ) );
		return this;
	}

	/**
	 * Returns a copy of this period with the specified amount of months.
	 *
	 * @months The months
	 */
	function withMonths( required months ){
		variables.jPeriod = variables.jPeriod.withMonths( javacast( "long", arguments.months ) );
		return this;
	}

	/**
	 * Returns a copy of this period with the specified amount of years.
	 *
	 * @years The years
	 */
	function withYears( required years ){
		variables.jPeriod = variables.jPeriod.withYears( javacast( "long", arguments.years ) );
		return this;
	}

	/**
	 * Obtains a Period from a text string such as PnYnMnD.
	 *
	 * This will parse the string produced by toString() which is based on the ISO-8601 period formats PnYnMnD and PnW.
	 *
	 * Examples:
	 *
	 * "P2Y"             -- Period.ofYears(2)
	 * "P3M"             -- Period.ofMonths(3)
	 * "P4W"             -- Period.ofWeeks(4)
	 * "P5D"             -- Period.ofDays(5)
	 * "P1Y2M3D"         -- Period.of(1, 2, 3)
	 * "P1Y2M3W4D"       -- Period.of(1, 2, 25)
	 * "P-1Y2M"          -- Period.of(-1, 2, 0)
	 * "-P1Y2M"          -- Period.of(-1, -2, 0)
	 *
	 * @see https://docs.oracle.com/en/java/javase/11/docs/api/java.base/java/time/Period.html#parse(java.lang.CharSequence)
	 *
	 * @text The string to parse and build up to a period
	 */
	Period function parse( required text ){
		variables.jPeriod = variables.jPeriod.parse( arguments.text );
		return this;
	}

	/**
	 * Obtains an instance of Period from another period
	 *
	 * @amount The period
	 */
	function from( required Period amount ){
		variables.jPeriod = variables.jPeriod.from( arguments.amount.getNative() );
		return this;
	}

	/**
	 * Obtains a Period representing an amount in the specified arguments
	 *
	 * @years The years
	 * @months The months
	 * @days The days
	 */
	Period function of( years = 0, months = 0, days = 0 ){
		variables.jPeriod = variables.jPeriod.of(
			javacast( "int", arguments.years ),
			javacast( "int", arguments.months ),
			javacast( "int", arguments.days )
		);
		return this;
	}

	/**
	 * Obtains a Period representing a number of days.
	 *
	 * @days The number of days, positive or negative
	 */
	Period function ofDays( required days ){
		variables.jPeriod = variables.jPeriod.ofDays( javacast( "int", arguments.days ) );
		return this;
	}

	/**
	 * Obtains a Period representing a number of months.
	 *
	 * @months The number of months, positive or negative
	 */
	Period function ofMonths( required months ){
		variables.jPeriod = variables.jPeriod.ofMonths( javacast( "int", arguments.months ) );
		return this;
	}

	/**
	 * Obtains a Period representing a number of weeks.
	 *
	 * @weeks The number of weeks, positive or negative
	 */
	Period function ofWeeks( required weeks ){
		variables.jPeriod = variables.jPeriod.ofWeeks( javacast( "int", arguments.weeks ) );
		return this;
	}

	/**
	 * Obtains a Period representing a number of years.
	 *
	 * @years The number of years, positive or negative
	 */
	Period function ofYears( required years ){
		variables.jPeriod = variables.jPeriod.ofYears( javacast( "int", arguments.years ) );
		return this;
	}

}
