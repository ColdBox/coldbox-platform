/**
 * Covers how a parent module tracks its nested (inception) child modules when a
 * child fails to register. A disabled child must not be tracked, otherwise the
 * activation cascade throws IllegalModuleState. A child whose name was already
 * known must still be tracked, and a disabled child the parent declares in
 * this.dependencies must still stop activation.
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

			it( "still fails when the parent lists its disabled nested child in this.dependencies", function(){
				expect( function(){
					variables.moduleService.registerAndActivateModule(
						"disabledDependencyParent",
						variables.fixtureRoot
					);
				} ).toThrow( "IllegalModuleState" );
			} );

			it( "tracks a nested child whose name is already known to the registry", function(){
				var ms              = variables.moduleService;
				// Simulate a top-level copy: registerAllModules() fills the registry before registering anything
				var knownInvocation = variables.fixtureRoot & ".sharedChildParent.modules";
				var knownLocation   = "/" & replace( knownInvocation, ".", "/", "all" );
				ms.getModuleRegistry()[ "sharedChild" ] = {
					locationPath   : knownLocation,
					physicalPath   : expandPath( knownLocation ),
					invocationPath : knownInvocation
				};

				ms.registerModule( "sharedChildParent", variables.fixtureRoot );
				// The known copy registers on its own, as registerAllModules() would
				ms.registerModule( "sharedChild" );
				ms.activateModule( "sharedChildParent" );

				var modules = getController().getSetting( "modules" );

				expect( modules[ "sharedChildParent" ].childModules ).toInclude( "sharedChild" );
				// Only the parent's activation cascade activates it
				expect( modules[ "sharedChild" ].activated ).toBeTrue();
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
		for (
			var moduleName in [
				"disabledChild",
				"disabledDependency",
				"sharedChild",
				"disabledChildParent",
				"disabledDependencyParent",
				"sharedChildParent"
			]
		) {
			if ( ms.isModuleRegistered( moduleName ) ) {
				ms.unload( moduleName );
			}
			// The registry keeps entries after unload; remove so re-registration is possible
			structDelete( registry, moduleName );
		}
	}

}
