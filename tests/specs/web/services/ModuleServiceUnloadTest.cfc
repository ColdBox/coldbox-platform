/**
 * Covers what unload() and unloadAll() clean up when a module goes away.
 */
component extends="tests.resources.BaseIntegrationTest" {

	function beforeAll(){
		super.beforeAll();
		variables.moduleService      = getController().getModuleService();
		variables.interceptorService = getController().getInterceptorService();
		variables.asyncManager       = getController().getAsyncManager();
		variables.fixtureRoot        = "tests.resources.unloadfixtures";
	}

	function run(){
		describe( "Unloading a module", function(){
			beforeEach( function( currentSpec ){
				// Setup as a new ColdBox request, VERY IMPORTANT. ELSE EVERYTHING LOOKS LIKE THE SAME REQUEST.
				setup();
				cleanupFixtures();
				structDelete( request, "unloadMainCount" );
				// An executor that exists before the module loads, so the module does not own it
				variables.asyncManager.newExecutor( name = "unloadShared", threads = 1 );
				variables.moduleService.registerAndActivateModule( "unloadMain", variables.fixtureRoot );
			} );

			afterEach( function( currentSpec ){
				cleanupFixtures();
			} );

			it( "stops the module's interceptors from listening", function(){
				var preProcess = variables.interceptorService.getStateContainer( "preProcess" );
				expect( preProcess.exists( "Listener@unloadMain" ) ).toBeTrue( "The fixture interceptor never registered" );

				variables.moduleService.unload( "unloadMain" );

				expect( preProcess.exists( "Listener@unloadMain" ) ).toBeFalse();
			} );

			it( "stops the module's router from listening", function(){
				var postProcess = variables.interceptorService.getStateContainer( "postProcess" );
				expect( postProcess.exists( "Router@unloadMain" ) ).toBeTrue( "The fixture router never registered" );

				variables.moduleService.unload( "unloadMain" );

				expect( postProcess.exists( "Router@unloadMain" ) ).toBeFalse();
			} );

			it( "removes the module's aliases", function(){
				expect( getController().getSetting( "modules" ) ).toHaveKey( "unloadAlias" );

				variables.moduleService.unload( "unloadMain" );

				expect( getController().getSetting( "modules" ) ).notToHaveKey( "unloadAlias" );
				expect( variables.moduleService.getModuleConfigCache() ).notToHaveKey( "unloadAlias" );
			} );

			it( "only shuts down the executors the module created", function(){
				expect( variables.asyncManager.hasExecutor( "unloadOwn" ) ).toBeTrue( "The fixture executor never registered" );

				variables.moduleService.unload( "unloadMain" );

				expect( variables.asyncManager.hasExecutor( "unloadOwn" ) ).toBeFalse();
				expect( variables.asyncManager.hasExecutor( "unloadShared" ) ).toBeTrue(
					"An executor the module did not create was shut down"
				);
			} );
		} );

		describe( "Unloading all modules", function(){
			it( "unloads a module with aliases only once", function(){
				var mockController = getMockBox().createMock( "coldbox.system.testing.mock.web.MockController" );
				var unloaded       = [];
				var withAlias      = { "aliases" : [ "myAlias" ] };
				var plain          = { "aliases" : [] };
				var model          = getMockBox().createMock( "coldbox.system.web.services.ModuleService" );

				// Aliases are stored as extra keys that point to the same module configuration.
				// The alias comes first so it is the first key unloadAll() sees.
				var registered          = structNew( "ordered" );
				registered[ "myAlias" ] = withAlias;
				registered[ "aliased" ] = withAlias;
				registered[ "plain" ]   = plain;

				model
					.$property( "controller", "variables", mockController )
					.$property( "registeredModules", "variables", registered )
					.$property(
						"moduleRegistry",
						"variables",
						{ "aliased" : {}, "plain" : {} }
					)
					.$( "unload", true );

				model.unloadAll();

				var unloadedNames = model
					.$callLog()
					.unload
					.map( function( args ){
						return args[ 1 ];
					} );
				expect( unloadedNames ).toHaveLength( 2 );
				expect( unloadedNames ).toInclude( "aliased" );
				expect( unloadedNames ).toInclude( "plain" );
			} );

			it( "unloads a module that lists its own name as an alias", function(){
				var mockController = getMockBox().createMock( "coldbox.system.testing.mock.web.MockController" );
				var model          = getMockBox().createMock( "coldbox.system.web.services.ModuleService" );

				model
					.$property( "controller", "variables", mockController )
					.$property(
						"registeredModules",
						"variables",
						{ "selfAliased" : { "aliases" : [ "selfAliased" ] } }
					)
					.$property(
						"moduleRegistry",
						"variables",
						{ "selfAliased" : {} }
					)
					.$( "unload", true );

				model.unloadAll();

				expect( model.$count( "unload" ) ).toBe( 1 );
				expect( model.$callLog().unload[ 1 ][ 1 ] ).toBe( "selfAliased" );
			} );
		} );
	}

	/*********************************** HELPERS ***********************************/

	/**
	 * Removes the fixture module and what it registered, so every spec starts clean.
	 * unload() does not touch the module registry, so we clean that explicitly.
	 */
	private function cleanupFixtures(){
		if ( variables.moduleService.isModuleRegistered( "unloadMain" ) ) {
			variables.moduleService.unload( "unloadMain" );
		}
		structDelete( variables.moduleService.getModuleRegistry(), "unloadMain" );
		structDelete( getController().getSetting( "modules" ), "unloadAlias" );
		structDelete( variables.moduleService.getModuleConfigCache(), "unloadAlias" );

		variables.interceptorService.unregister( "Listener@unloadMain" );
		variables.interceptorService.unregister( "Router@unloadMain" );

		variables.asyncManager.deleteExecutor( "unloadShared" );
		variables.asyncManager.deleteExecutor( "unloadOwn" );
	}

}
