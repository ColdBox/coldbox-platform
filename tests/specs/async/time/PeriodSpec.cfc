/**
 * period Specs
 */
component extends="tests.specs.async.BaseAsyncSpec" {

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "Period", function(){
			beforeEach( function( currentSpec ){
				period = new coldbox.system.async.time.Period();
			} );

			it( "can be created", function(){
				expect( period ).toBeComponent();
			} );

			it( "can do creations with of methods", function(){
				var p = period.of();
				expect( p.getyears() ).toBe( 0 );
				expect( p.getMonths() ).toBe( 0 );
				expect( p.getDays() ).toBe( 0 );

				var p = period.of( 1, 5, 2 );
				expect( p.getyears() ).toBe( 1 );
				expect( p.getMonths() ).toBe( 5 );
				expect( p.getDays() ).toBe( 2 );
			} );

			it( "can build days", function(){
				expect( period.ofDays( 10 ).getDays() ).toBe( 10 );
			} );

			it( "can build months", function(){
				expect( period.ofMonths( 10 ).getMonths() ).toBe( 10 );
			} );

			it( "can build weeks", function(){
				var p = period.ofWeeks( 2 );
				expect( p.getDays() ).toBe( 14 );
			} );

			it( "can build years", function(){
				expect( period.ofyears( 10 ).getyears() ).toBe( 10 );
			} );

			it( "can parse strings into periods", function(){
				var p = period.parse( "P2Y" );
				expect( p.getYears() ).toBe( 2 );

				var p = period.parse( "P2Y5M" );
				expect( p.getYears() ).toBe( 2 );
				expect( p.getMonths() ).toBe( 5 );

				var p = period.parse( "P2Y5M10D" );
				expect( p.getYears() ).toBe( 2 );
				expect( p.getMonths() ).toBe( 5 );
				expect( p.getDays() ).toBe( 10 );
			} );

			it( "can check utility methods", function(){
				expect( period.iszero() ).toBeTrue();
				expect( period.get() ).toBe( 0 );
				expect( period.isNegative() ).toBeFalse();
			} );

			it( "can get total months", function(){
				var p = period.parse( "P10Y5M20D" )
				expect( p.toTotalMonths() ).toBe( 125 );
			} );

			it( "can do minus", function(){
				expect(
					period
						.of( 5 )
						.minus( period.ofDays( 5 ) )
						.getDays()
				).toBe( 0 );

				expect(
					period
						.init()
						.ofDays( 5 )
						.minusDays( 1 )
						.getDays()
				).toBe( 4 );

				expect(
					period
						.init()
						.ofMonths( 5 )
						.minusMonths( 1 )
						.getMonths()
				).toBe( 4 );

				expect(
					period
						.init()
						.ofYears( 5 )
						.minusYears( 1 )
						.getYears()
				).toBe( 4 );
			} );

			it( "can do plus", function(){
				expect(
					period
						.of( 5 )
						.plus( period.ofDays( 5 ) )
						.getDays()
				).toBe( 10 );

				expect(
					period
						.ofDays( 5 )
						.plusDays( 1 )
						.getDays()
				).toBe( 6 );

				expect(
					period
						.init()
						.ofMonths( 5 )
						.plusMonths( 1 )
						.getMonths()
				).toBe( 6 );

				expect(
					period
						.init()
						.ofYears( 5 )
						.plusYears( 1 )
						.getYears()
				).toBe( 6 );
			} );

			it( "can do multiplication", function(){
				var d = period.ofDays( 10 );
				expect( period.multipliedBy( 10 ).getDays() ).toBe( 100 );
			} );

			it( "can do negations", function(){
				var d = period.ofDays( -1 );
				expect( d.negated().isNegative() ).toBeFalse();

				var d = period.ofDays( -1 );
				expect( d.isNegative() ).toBeTrue();
			} );

			it( "can addTo", function(){
				var p      = period.of( 2, 5, 10 );
				var target = "2021-01-01";

				expect( p.addTo( target ) ).tobe( "2023-06-11" )
			} );
		} );
	}

}
