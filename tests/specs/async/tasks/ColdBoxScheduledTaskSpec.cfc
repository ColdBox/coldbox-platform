component extends="tests.resources.BaseIntegrationTest" {

	/*********************************** BDD SUITES ***********************************/

	function beforeAll(){
		variables.asyncManager = new coldbox.system.async.AsyncManager();
		super.beforeAll();
	}

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "ColdBox Scheduled Task", function(){
			beforeEach( function( currentSpec ){
				variables.scheduler = getInstance(
					name         : "coldbox.system.web.tasks.ColdBoxScheduler",
					initArguments: {
						name         : "bdd-tests",
						asyncManager : variables.asyncManager
					}
				);
			} );

			afterEach( function( currentSpec ){
				getCache( "template" ).clearAll();
				variables.scheduler.shutdown();
			} );

			it( "can register a ColdBox enhanced task", function(){
				var t = scheduler.task( "cbTask" );
				expect( t.hasScheduler() ).toBeTrue();
				expect( t.getCacheName() ).toBe( "template" );
				expect( t.getServerFixation() ).toBeFalse();
				expect( scheduler.getTaskRecord( "cbTask" ).task ).toBe( t );
			} );

			it( "can register environment constraints", function(){
				var t = scheduler.task( "cbTask" ).onEnvironment( "development" );
				expect( t.getEnvironments() ).toInclude( "development" );
			} );

			it( "can be constrained by environment", function(){
				var t = scheduler.task( "cbTask" ).everyMinute();

				expect( t.isConstrained() ).toBeFalse();

				// Constrain it
				t.onEnvironment( "bogus" );
				expect( t.getEnvironments() ).toInclude( "bogus" );
				expect( t.isConstrained() ).toBeTrue();
			} );

			it( "can register server fixation", function(){
				var t = scheduler.task( "cbTask" ).onOneServer();
				expect( t.getServerFixation() ).toBeTrue();
			} );

			it( "can be constrained by server", function(){
				var t = scheduler
					.task( "cbTask-ServerFixation" )
					.onOneServer()
					.everyHourAt( 9 )
					.withNoOverlaps();

				expect( t.isConstrained() ).toBeFalse();
				expect( t.getCache().getKeys() ).toInclude( t.getFixationCacheKey() );

				// Constrain it
				t.cleanupTaskRun();
				expect( t.getCache().getKeys() ).notToInclude( t.getFixationCacheKey() );
				t.getCache()
					.set(
						t.getFixationCacheKey(),
						{
							"task"       : t.getName(),
							"lockOn"     : now(),
							"serverHost" : "10.10.10.10",
							"serverIp"   : "my.macdaddy.bogus.bdd.server"
						},
						5,
						0
					);
				expect( t.getCache().getKeys() ).toInclude( t.getFixationCacheKey() );
				expect( t.isConstrained() ).toBeTrue();
				t.cleanupTaskRun();
			} );
		} );
	}

}
