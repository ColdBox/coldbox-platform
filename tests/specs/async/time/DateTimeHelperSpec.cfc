/**
 * Duration Specs
 */
component extends="tests.specs.async.BaseAsyncSpec" {

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "Date Time Helper", function(){
			beforeEach( function( currentSpec ){
				dateTimeHelper = new coldbox.system.async.time.DateTimeHelper();
			} );

			it( "can be created", function(){
				expect( dateTimeHelper ).toBeComponent();
			} );

			it( "can convert cf dates to java instants", function(){
				var instant = dateTimeHelper.toInstant( now() );
				expect( instant.getEpochSecond() ).toBeGT( 0 );

				var instant = dateTimeHelper.toInstant( "2021-01-01 12:00:00 pm" );
				expect( instant.getEpochSecond() ).toBeGT( 0 );
			} );

			it( "can convert cf dates to Java LocalDates", function(){
				var jdate = dateTimeHelper.toLocalDate( now() );
				expect( jDate.getYear() ).toBe( year( now() ) );
				var jdate = dateTimeHelper.toLocalDate( now(), "America/New_York" );
				expect( jDate.getYear() ).toBe( year( now() ) );
			} );

			it( "can get timezones", function(){
				var t = dateTimeHelper.getTimezone( "America/Chicago" );
				expect( t.getId() ).toInclude( "America/Chicago" );
			} );

			it( "can get the system timezone id", function(){
				var t = dateTimeHelper.getSystemTimezone();
				expect( t.getId() ).notToBeEmpty();
			} );

			it( "can validate a numeric time value", function(){
				var timeValue = dateTimeHelper.validateTime( 11 );
				expect( timeValue ).toBe( "11:00" );
			} );

			it( "can get the next day of month occurrence, clamping to the last day when it doesn't exist", function(){
				// April only has 30 days
				var aprilFirst = createODBCDateTime( "2024-04-01 00:00:00" );
				var result     = dateTimeHelper.getNextDayOfMonthOccurrence( day = 31, now = aprilFirst );
				expect( result.getMonthValue() ).toBe( 4 );
				expect( result.getDayOfMonth() ).toBe( 30 );

				// May has 31 days, so no clamping should occur
				var mayFirst = createODBCDateTime( "2024-05-01 00:00:00" );
				var result2  = dateTimeHelper.getNextDayOfMonthOccurrence( day = 31, now = mayFirst );
				expect( result2.getMonthValue() ).toBe( 5 );
				expect( result2.getDayOfMonth() ).toBe( 31 );

				// addMonth moves the target into the following month
				var result3 = dateTimeHelper.getNextDayOfMonthOccurrence(
					day     : 15,
					now     : aprilFirst,
					addMonth: true
				);
				expect( result3.getMonthValue() ).toBe( 5 );
				expect( result3.getDayOfMonth() ).toBe( 15 );
			} );

			var units = [
				"CENTURIES",
				"DAYS",
				"DECADES",
				"ERAS",
				"FOREVER",
				"HALF_DAYS",
				"HOURS",
				"MICROS",
				"MILLENNIA",
				"MILLIS",
				"MINUTES",
				"MONTHS",
				"NANOS",
				"SECONDS",
				"WEEKS",
				"YEARS"
			];

			units.each( function( thisUnit ){
				it(
					data  = { unit : thisUnit },
					title = "can produce the #thisUnit# java chrono unit",
					body  = function( data ){
						var unit = dateTimeHelper[ data.unit ];
						expect( unit.toString() ).toInclude( data.unit.replace( "_", "" ) );
					}
				);
			} );
		} );
	}

}
