/**
 * My BDD Test
 */
component extends="testbox.system.BaseSpec" {

	/*********************************** LIFE CYCLE Methods ***********************************/

	// executes before all suites+specs in the run() method
	function beforeAll(){
	}

	// executes after all suites+specs in the run() method
	function afterAll(){
	}

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "TimeUnit", function(){
			beforeEach( function( currentSpec ){
				timeUnit = new coldbox.system.async.TimeUnit();
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
						var unit = timeUnit.getTimeUnit( data.unit );
						expect( unit.toString() ).toInclude( data.unit );
					},
					data={ unit : thisUnit }
				)
			} );

		} );
	}

}
