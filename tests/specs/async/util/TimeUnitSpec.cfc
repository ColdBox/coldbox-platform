/**
 * My BDD Test
 */
component extends="tests.specs.async.BaseAsyncSpec"{

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "TimeUnit", function(){
			beforeEach( function( currentSpec ){
				timeUnit = new coldbox.system.async.util.TimeUnit();
			} );

			it( "can be created", function(){
				expect( timeUnit ).toBeComponent();
			});

			var timeUnits = [
				"days",
				"hours",
				"microseconds",
				"milliseconds",
				"minutes",
				"nanoseconds",
				"seconds"
			];

			timeUnits.each( function( thisUnit ){
				it(
					title="can produce the #thisUnit# java unit",
					body=function( data ){
						var unit = timeUnit.get( data.unit );
						expect( unit.toString() ).toInclude( data.unit );
					},
					data={ unit : thisUnit }
				);
			} );

		} );
	}

}
