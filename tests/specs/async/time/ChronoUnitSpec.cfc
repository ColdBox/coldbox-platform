/**
 * Duration Specs
 */
component extends="tests.specs.async.BaseAsyncSpec" {

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "Chrono Units", function(){
			beforeEach( function( currentSpec ){
				chronounit = new coldbox.system.async.time.ChronoUnit();
			} );

			it( "can be created", function(){
				expect( chronounit ).toBeComponent();
			} );

			it( "can convert cf dates to java instants", function(){
				var instant = chronounit.toInstant( now() );
				expect( instant.getEpochSecond() ).toBeGT( 0 );

				var instant = chronounit.toInstant( "2021-01-01 12:00:00 pm" );
				expect( instant.getEpochSecond() ).toBeGT( 0 );
			} );

			it( "can convert cf dates to Java LocalDates", function(){
				var jdate = chronounit.toLocalDate( now() );
				expect( jDate.getYear() ).toBe( year( now() ) );
				var jdate = chronounit.toLocalDate( now(), "America/New_York" );
				expect( jDate.getYear() ).toBe( year( now() ) );
			} );

			it( "can get timezones", function(){
				var t = chronounit.getTimezone( "America/Chicago" );
				expect( t.getId() ).toInclude( "America/Chicago" );
			} );

			it( "can get the system timezone id", function(){
				var t = chronounit.getSystemTimezone();
				expect( t.getId() ).notToBeEmpty();
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
						var unit = chronoUnit[ data.unit ];
						expect( unit.toString() ).toInclude( data.unit.replace( "_", "" ) );
					}
				);
			} );
		} );
	}

}
