/**
 * Covers how a parent module tracks its nested (inception) child modules when a
 * child fails to register. A child that never registered must not be tracked,
 * otherwise the activation cascade throws IllegalModuleState.
 */
component extends="tests.resources.BaseIntegrationTest" {

	function beforeAll(){
		super.beforeAll();
		variables.moduleService = getController().getModuleService();
		variables.fixtureRoot   = "tests.resources.inceptionfixtures";
	}

	function run(){
		describe( "Nested (inception) module registration", function(){
			beforeEach( function( currentSpec ){
				// Setup as a new ColdBox request, VERY IMPORTANT. ELSE EVERYTHING LOOKS LIKE THE SAME REQUEST.
				setup();
				// Clean even if a previous spec failed mid-flight
				cleanupFixtures();
			} );

			afterEach( function( currentSpec ){
				cleanupFixtures();
			} );

			it( "does not track a disabled nested child and still activates the parent", function(){
				variables.moduleService.registerAndActivateModule( "disabledChildParent", variables.fixtureRoot );

				var modules = getController().getSetting( "modules" );

				expect( modules[ "disabledChildParent" ].activated ).toBeTrue();
				// The disabled child never registered, so the parent must not claim it
				expect( modules[ "disabledChildParent" ].childModules ).notToInclude( "disabledChild" );
				expect( modules ).notToHaveKey( "disabledChild" );
			} );
		} );
	}

	/*********************************** HELPERS ***********************************/

	/**
	 * Removes every fixture module from the live test app so each spec starts clean.
	 * unload() does not touch the module registry, so we clean that explicitly.
	 */
	private function cleanupFixtures(){
		var ms       = variables.moduleService;
		var registry = ms.getModuleRegistry();

		// Children first, then parents
		for ( var moduleName in [ "disabledChild", "disabledChildParent" ] ) {
			if ( ms.isModuleRegistered( moduleName ) ) {
				ms.unload( moduleName );
			}
			// The registry keeps entries after unload; remove so re-registration is possible
			structDelete( registry, moduleName );
		}
	}

}
