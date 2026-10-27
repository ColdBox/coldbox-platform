/**
 * Scheduler Service Tests
 */
component extends="tests.resources.BaseIntegrationTest" {

	function run( testResults, testBox ){
		describe( "Scheduler Service", function(){
			beforeEach( function( currentSpec ){
				setup();
				variables.schedulerService = getController().getSchedulerService();
			} );

			it( "gives virtually-inherited schedulers their own distinct LogBox logger", function(){
				var appScheduler    = variables.schedulerService.getSchedulers()[ "appScheduler@coldbox" ];
				var moduleScheduler = variables.schedulerService.getSchedulers()[ "cbScheduler@resourcesTest" ];

				// Each scheduler's logger category should reflect its own real path, not a shared
				// generic one inherited from the base ColdBoxScheduler class.
				expect( appScheduler.getLog().getCategory() ).notToBeEmpty();
				expect( moduleScheduler.getLog().getCategory() ).notToBeEmpty();
				expect( moduleScheduler.getLog().getCategory() ).toInclude( "resourcesTest" );
				expect( appScheduler.getLog().getCategory() ).notToBe( moduleScheduler.getLog().getCategory() );

				// COLDBOX-1272: the two schedulers used to end up sharing the EXACT SAME LogBox
				// Logger instance (virtual inheritance resolves the `log` property's `{this}` DSL
				// against a fresh instance of the *base* ColdBoxScheduler class, which is identical
				// for every scheduler, so LogBox's category-keyed logger cache handed all of them
				// back the same object). Mutating one scheduler's category would silently mutate
				// every other scheduler's category too, since it was the same shared object.
				// Prove they are genuinely separate instances now.
				var originalAppCategory = appScheduler.getLog().getCategory();
				appScheduler.getLog().setCategory( "coldbox-1272-regression-marker" );
				expect( moduleScheduler.getLog().getCategory() ).notToBe( "coldbox-1272-regression-marker" );

				// Restore, in case another spec in this app scope relies on the original category.
				appScheduler.getLog().setCategory( originalAppCategory );
			} );

			describe( "Schedulers that listen to interception points", function(){
				beforeEach( function( currentSpec ){
					variables.firstName   = "first@schedulerfixtures";
					variables.secondName  = "second@schedulerfixtures";
					variables.fixtureRoot = "tests.resources.schedulerfixtures";
					removeFixtureSchedulers();
				} );

				afterEach( function( currentSpec ){
					removeFixtureSchedulers();
				} );

				it( "registers each scheduler under its own name", function(){
					variables.schedulerService.loadScheduler( firstName, "#fixtureRoot#.first.Scheduler" );
					variables.schedulerService.loadScheduler( secondName, "#fixtureRoot#.second.Scheduler" );

					var preProcess = getController().getInterceptorService().getStateContainer( "preProcess" );

					// Both classes are called Scheduler, so both used to be registered as "Scheduler"
					// and the second one was silently dropped.
					expect( preProcess.exists( firstName ) ).toBeTrue( "The first scheduler is not listening" );
					expect( preProcess.exists( secondName ) ).toBeTrue( "The second scheduler is not listening" );
				} );

				it( "stops a scheduler from listening when it is removed", function(){
					variables.schedulerService.loadScheduler( firstName, "#fixtureRoot#.first.Scheduler" );
					variables.schedulerService.loadScheduler( secondName, "#fixtureRoot#.second.Scheduler" );

					variables.schedulerService.removeScheduler( firstName );

					var preProcess = getController().getInterceptorService().getStateContainer( "preProcess" );

					expect( preProcess.exists( firstName ) ).toBeFalse( "The removed scheduler is still listening" );
					expect( preProcess.exists( secondName ) ).toBeTrue( "The other scheduler stopped listening" );
				} );
			} );
		} );
	}

	/*********************************** HELPERS ***********************************/

	/**
	 * Removes the fixture schedulers and anything they registered, so every spec starts clean.
	 */
	private function removeFixtureSchedulers(){
		var interceptorService = getController().getInterceptorService();

		for ( var thisName in [ firstName, secondName ] ) {
			variables.schedulerService.removeScheduler( thisName );
			interceptorService.unregister( thisName );
			// Loading a scheduler maps it as a singleton, drop both so it can be loaded again
			getWireBox().getBinder().unMap( thisName );
			getWireBox()
				.getScope( "singleton" )
				.getSingletons()
				.remove( lCase( thisName ) );
		}
	}

}
