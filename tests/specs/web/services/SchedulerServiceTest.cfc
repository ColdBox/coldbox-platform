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
		} );
	}

}
