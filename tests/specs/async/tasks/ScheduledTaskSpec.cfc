component extends="tests.specs.async.BaseAsyncSpec" {

	/*********************************** BDD SUITES ***********************************/

	function beforeAll(){
		variables.asyncManager = new coldbox.system.async.AsyncManager();
		super.beforeAll();
	}

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "Scheduled Task", function(){
			beforeEach( function( currentSpec ){
				variables.scheduler = asyncManager.newScheduler( "bdd-test" ).setTimezone( "America/Chicago" );
			} );

			afterEach( function( currentSpec ){
				variables.scheduler.shutdown();
			} );

			it( "can be created", function(){
				var t = scheduler.task( "test" );
				expect( t.getName() ).toBe( "test" );
				expect( t.hasScheduler() ).toBeTrue();
			} );

			it( "can call when", function(){
				var t = scheduler
					.task( "test" )
					.when( function(){
						return true;
					} );
				expect( isClosure( t.getWhen() ) ).toBeTrue();
			} );

			it( "can set a timezone", function(){
				var t = scheduler.task( "test" ).setTimezone( "America/Chicago" );
				expect( t.getTimezone().toString() ).toBe( "America/Chicago" );
			} );

			it( "can be disabled", function(){
				var t = scheduler.task( "test" );
				expect( t.isDisabled() ).toBeFalse();
				expect( t.disable().isDisabled() ).toBeTrue();
			} );

			it( "can call before", function(){
				var t = scheduler
					.task( "test" )
					.before( function(){
						return true;
					} );
				expect( isClosure( t.getBeforeTask() ) ).toBeTrue();
			} );
			it( "can call after", function(){
				var t = scheduler
					.task( "test" )
					.after( function(){
						return true;
					} );
				expect( isClosure( t.getafterTask() ) ).toBeTrue();
			} );
			it( "can call onTaskSuccess", function(){
				var t = scheduler
					.task( "test" )
					.onSuccess( function(){
						return true;
					} );
				expect( isClosure( t.getonTaskSuccess() ) ).toBeTrue();
			} );
			it( "can call onTaskFailure", function(){
				var t = scheduler
					.task( "test" )
					.onFailure( function(){
						return true;
					} );
				expect( isClosure( t.getonTaskFailure() ) ).toBeTrue();
			} );

			describe( "can register multiple frequencies using everyXXX() method calls", function(){
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
						title = "can register every 5 #thisUnit# as a time unit",
						body  = function( data ){
							var t = scheduler.task( "test" ).every( 5, data.unit );
							expect( t.getPeriod() ).toBe( 5 );
							expect( t.getTimeUnit() ).toBe( data.unit );
						},
						data = { unit : thisUnit }
					);
				} );

				it( "can register using everyMinute()", function(){
					var t = scheduler.task( "test" ).everyMinute();
					expect( t.getPeriod() ).toBe( 1 );
					expect( t.getTimeUnit() ).toBe( "minutes" );
				} );

				it( "can register everyHour()", function(){
					var t = scheduler.task( "test" ).everyHour();
					expect( t.getPeriod() ).toBe( 1 );
					expect( t.getTimeUnit() ).toBe( "hours" );
				} );

				it( "can register everyHourAt()", function(){
					var t = scheduler.task( "test" ).everyHourAt( 15 );
					expect( t.getDelay() ).notToBeEmpty();
					expect( t.getPeriod() ).toBe( 3600 );
					expect( t.getTimeUnit() ).toBe( "seconds" );
				} );

				it( "can register everyDay()", function(){
					var t = scheduler.task( "test" ).everyDay();
					expect( t.getPeriod() ).toBe( 86400 );
					expect( t.getTimeUnit() ).toBe( "seconds" );
				} );

				it( "can register everyDayAt()", function(){
					var t = scheduler.task( "test" ).everyDayAt( "04:00" );
					expect( t.getDelay() ).notToBeEmpty();
					expect( t.getPeriod() ).toBe( 86400 );
					expect( t.getTimeUnit() ).toBe( "seconds" );
				} );

				it( "can register everyWeek()", function(){
					var t = scheduler.task( "test" ).everyWeek();
					expect( t.getPeriod() ).toBe( 604800 );
					expect( t.getTimeUnit() ).toBe( "seconds" );
				} );

				it( "can register everyWeekOn()", function(){
					var t = scheduler.task( "test" ).everyWeekOn( 4, "09:00" );
					expect( t.getPeriod() ).toBe( 604800 );
					expect( t.getTimeUnit() ).toBe( "seconds" );
				} );

				it( "can register everyMonth()", function(){
					var t = scheduler.task( "test" ).everyMonth();
					expect( t.getPeriod() ).toBe( 86400 );
					expect( t.getTimeUnit() ).toBe( "seconds" );
				} );

				it( "can register everyMonthOn()", function(){
					var t = scheduler.task( "test" ).everyMonthOn( 10, "09:00" );
					expect( t.getPeriod() ).toBe( 86400 );
					expect( t.getTimeUnit() ).toBe( "seconds" );
				} );

				it( "can register everyYear()", function(){
					var t = scheduler.task( "test" ).everyYear();
					expect( t.getPeriod() ).toBe( 31536000 );
					expect( t.getTimeUnit() ).toBe( "seconds" );
				} );

				it( "can register everyYearOn()", function(){
					var t = scheduler.task( "test" ).everyYearOn( 4, 15, "09:00" );
					expect( t.getPeriod() ).toBe( 31536000 );
					expect( t.getTimeUnit() ).toBe( "seconds" );
				} );
			} );

			describe( "can register frequencies with constraints", function(){
				it( "can register to fire onWeekends()", function(){
					var t = scheduler.task( "test" ).onWeekends( "09:00" );
					expect( t.getPeriod() ).toBe( 86400 );
					expect( t.getTimeUnit() ).toBe( "seconds" );
					expect( t.getWeekends() ).toBeTrue();
					expect( t.getWeekdays() ).toBeFalse();
				} );

				it( "can register to fire onWeekdays()", function(){
					var t = scheduler.task( "test" ).onWeekdays( "09:00" );
					expect( t.getPeriod() ).toBe( 86400 );
					expect( t.getTimeUnit() ).toBe( "seconds" );
					expect( t.getWeekends() ).toBeFalse();
					expect( t.getWeekdays() ).toBeTrue();
				} );
			} );
		} );
	}

}
