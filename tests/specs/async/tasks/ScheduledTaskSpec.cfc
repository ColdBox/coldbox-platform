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

			it( "can have truth based restrictions using when()", function(){
				var t = scheduler
					.task( "test" )
					.when( function(){
						return true;
					} );
				expect( isClosure( t.getWhenClosure() ) ).toBeTrue();
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

			describe( "can have life cycle methods", function(){
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
				it( "can register to fire onFirstBusinessDayOfTheMonth()", function(){
					var t = scheduler.task( "test" ).onFirstBusinessDayOfTheMonth( "09:00" );
					expect( t.getPeriod() ).toBe( 86400 );
					expect( t.getTimeUnit() ).toBe( "seconds" );
					expect( t.getDayOfTheMonth() ).toBe( 1 );
				} );

				it( "can register to fire onLastBusinessDayOfTheMonth()", function(){
					var t = scheduler.task( "test" ).onLastBusinessDayOfTheMonth( "09:00" );
					expect( t.getPeriod() ).toBe( 86400 );
					expect( t.getTimeUnit() ).toBe( "seconds" );
					expect( t.getLastBusinessDay() ).toBeTrue();
				} );


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

				var daysOfTheWeek = [
					"mondays",
					"tuesdays",
					"wednesdays",
					"thursdays",
					"fridays",
					"saturdays",
					"sundays"
				];
				daysOfTheWeek.each( function( thisDay ){
					it(
						title = "can register to fire on the #thisDay#",
						body  = function( data ){
							var t = scheduler.task( "test" );

							invoke( t, "on#data.thisDay#" );

							expect( t.getPeriod() ).toBe( 604800 );
							expect( t.getTimeUnit() ).toBe( "seconds" );
						},
						data = { thisDay : thisDay }
					);
				} );
			} );

			it( "can register tasks with no overlaps", function(){
				var t = scheduler
					.task( "test" )
					.everyMinute()
					.withNoOverlaps();
				expect( t.getPeriod() ).toBe( 1 );
				expect( t.getNoOverlaps() ).toBeTrue();
				expect( t.getTimeUnit() ).toBe( "minutes" );
			} );

			describe( "can have multiple constraints", function(){
				it( "can have a truth value constraint", function(){
					var t = scheduler
						.task( "test" )
						.when( function(){
							return false;
						} );
					expect( t.isConstrained() ).toBeTrue();
				} );

				it( "can have a day of the month constraint", function(){
					var t      = scheduler.task( "test" );
					var target = t
						.getJavaNow()
						.plusDays( javacast( "int", 3 ) )
						.getDayOfMonth();
					t.setDayOfTheMonth( target );
					expect( t.isConstrained() ).toBeTrue( "Day is : #target#" );

					var target = t.getJavaNow().getDayOfMonth();
					t.setDayOfTheMonth( t.getJavaNow().getDayOfMonth() );
					expect( t.isConstrained() ).toBeFalse( "!Day is #target#" );
				} );

				it( "can have a last business day of the month constraint", function(){
					var nowDate = new coldbox.system.async.time.ChronoUnit().toLocalDateTime( now(), "UTC" );

					var t = prepareMock( scheduler.task( "test" ) ).setLastBusinessDay( true );

					makePublic( t, "getLastDayOfTheMonth" );

					// If we are at the last day, increase it
					if ( nowDate.getDayOfMonth() == t.getLastDayOfTheMonth().getDayOfMonth() ) {
						nowDate = nowDate.plusDays( javacast( "int", -1 ) );
					}

					t.$( "getJavaNow", nowDate );
					expect( t.isConstrained() ).toBeTrue();

					var mockNow = t.getJavaNow();
					prepareMock( t ).$( "getLastDayOfTheMonth", mockNow );

					expect( t.isConstrained() ).toBeFalse();
				} );

				it( "can have a day of the week constraint", function(){
					var t       = scheduler.task( "test" );
					var mockNow = t.getJavaNow();
					// Reduce date enough to do computations on it
					if ( mockNow.getDayOfWeek().getValue() > 6 ) {
						mockNow = mockNow.minusDays( javacast( "long", 3 ) );
					}

					t.setDayOfTheWeek( mockNow.getDayOfWeek().getValue() + 1 );
					expect( t.isConstrained() ).toBeTrue( "Constrained!!" );

					t.setDayOfTheWeek(
						t.getJavaNow()
							.getDayOfWeek()
							.getValue()
					);
					expect( t.isConstrained() ).toBeFalse( "Should execute" );
				} );

				it( "can have a weekend constraint", function(){
					var t = scheduler.task( "test" ).setWeekends( true );

					// build a weekend date
					var mockNow   = t.getJavaNow();
					var dayOfWeek = mockNow.getDayOfWeek().getValue();

					if ( dayOfWeek < 6 ) {
						mockNow = mockNow.plusDays( javacast( "long", 6 - dayOfWeek ) );
					}

					prepareMock( t ).$( "getJavaNow", mockNow );
					expect( t.isConstrained() ).toBeFalse(
						"Weekend day (#mockNow.getDayOfWeek().getvalue()#) should pass"
					);

					// Test non weekend
					mockNow = mockNow.minusDays( javacast( "long", 3 ) );
					t.$( "getJavaNow", mockNow );
					expect( t.isConstrained() ).toBeTrue(
						"Weekday (#mockNow.getDayOfWeek().getvalue()#) should be constrained"
					);
				} );

				it( "can have a weekday constraint", function(){
					var t = scheduler.task( "test" ).setWeekdays( true );

					// build a weekday date
					var mockNow   = t.getJavaNow();
					var dayOfWeek = mockNow.getDayOfWeek().getValue();
					if ( dayOfWeek >= 6 ) {
						mockNow = mockNow.minusDays( javacast( "long", 3 ) );
					}

					prepareMock( t ).$( "getJavaNow", mockNow );
					expect( t.isConstrained() ).toBeFalse(
						"Weekday (#mockNow.getDayOfWeek().getvalue()#) should pass"
					);

					// Test weekend
					mockNow = mockNow.plusDays( javacast( "long", 6 - mockNow.getDayOfWeek().getValue() ) );
					t.$( "getJavaNow", mockNow );
					expect( t.isConstrained() ).toBeTrue(
						"Weekend (#mockNow.getDayOfWeek().getvalue()#) should be constrained"
					);
				} );
			} );
		} );
	}

}
