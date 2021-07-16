/**
 * Duration Specs
 */
component extends="tests.specs.async.BaseAsyncSpec" {

	engineUtil = new coldbox.system.core.util.CFMLEngine();

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "Duration", function(){
			beforeEach( function( currentSpec ){
				duration = new coldbox.system.async.time.Duration();
			} );

			it( "can be created", function(){
				expect( duration ).toBeComponent();
			} );

			it( "can do creations with of methods", function(){
				expect( duration.ofDays( 7 ).toString() ).toBe( "PT168H" );
				expect( duration.ofHours( 8 ).toString() ).toBe( "PT8H" );
				expect( duration.ofMinutes( 15 ).toString() ).toBe( "PT15M" );
				expect( duration.ofSeconds( 10 ).toString() ).toBe( "PT10S" );
				expect( duration.ofSeconds( 30, 123456789 ).toString() ).toBe( "PT30.123456789S" );
				expect( duration.between( "2017-10-03T10:15:30.00Z", "2017-10-03T10:16:30.00Z" ).getSeconds() ).toBe(
					60
				);
				expect( duration.between( "2021-01-01 00:00:00", "2021-01-01 00:00:01" ).toString() ).toBe(
					"PT1S"
				);
				expect(
					duration
						.between( createDateTime( 2019, 1, 1, 0, 0, 0 ), createDateTime( 2021, 1, 1, 0, 0, 0 ) )
						.toString()
				).toBe( "PT17544H" );
			} );

			it( "can parse strings into durations", function(){
				var d = duration.parse( "P1DT8H15M10.345000S" );
				expect( d.getSeconds() ).toBe( 116110 );
				expect( d.getNano() ).toBe( 345000000 );
				expect( d.getUnits() ).toInclude( "seconds" ).toInclude( "nanos" );
			} );

			it( "can check utility methods", function(){
				expect( duration.iszero() ).toBeTrue();
				expect( duration.get() ).toBe( 0 );
				expect( duration.getSeconds() ).toBe( 0 );
				expect( duration.getNano() ).toBe( 0 );
				expect( duration.isNegative() ).toBeFalse();
			} );

			it( "can do minus", function(){
				var d = duration.of( 10 );
				expect( duration.minus( 1 ).get() ).toBe( 9 );
			} );

			it( "can do plus", function(){
				var d = duration.of( 10 );
				expect( duration.plus( 1 ).get() ).toBe( 11 );
			} );

			it( "can do multiplication", function(){
				var d = duration.of( 10 );
				expect( duration.multipliedBy( 10 ).get() ).toBe( 100 );
			} );

			it( "can do division", function(){
				var d = duration.of( 10 );
				expect( duration.dividedBy( 10 ).get() ).toBe( 1 );
			} );

			it( "can do negations", function(){
				var d = duration.of( -1 );
				expect( d.negated().isNegative() ).toBeFalse();

				var d = duration.of( -1 );
				expect( d.isNegative() ).toBeTrue();
				expect( d.abs().isNegative() ).toBeFalse();
			} );

			it( "can create it from another duration", function(){
				var test = duration.ofSeconds( 5 );
				expect( duration.from( test ).get() ).toBe( 5 );
			} );

			it( "can convert to other time units", function(){
				expect( duration.ofMinutes( 60 ).toHours() ).toBe( 1 );
				if ( listFirst( engineUtil.JDK_VERSION, "." ) >= 11 ) {
					expect( duration.ofMinutes( 60 ).toSeconds() ).toBe( 60 * 60 );
				}
				expect( duration.ofMinutes( 60 ).toMillis() ).toBe( 60 * 60 * 1000 );
			} );

			it( "can add durations to date/time objects", function(){
				var now = now();
				var t   = duration.ofDays( 10 ).addTo( now );
				expect( dateDiff( "d", now, t ) ).toBe( 10 );
			} );

			it( "can subtract durations to date/time objects", function(){
				var now = now();
				var t   = duration.ofDays( 10 ).subtractFrom( now );
				expect( dateDiff( "d", now, t ) ).toBe( -10 );
			} );
		} );
	}

}
