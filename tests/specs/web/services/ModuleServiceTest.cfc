component extends="tests.resources.BaseIntegrationTest" {

	function beforeAll(){
		super.beforeAll();
		variables.moduleService = getController().getModuleService();
	}

	function run(){
		describe( "Module Lifecycle", function(){
			beforeEach( function( currentSpec ){
				// Setup as a new ColdBox request, VERY IMPORTANT. ELSE EVERYTHING LOOKS LIKE THE SAME REQUEST.
				setup();
			} );

			it( "Tests the ModuleService configuration", function(){
				expect( variables.moduleService.getModuleRegistry() ).toBeStruct().toHaveKey( "HTMLHelper" );
			} );

			it( "Can rebuild the module registry", function(){
				var existingRegistry = duplicate( variables.moduleService.getModuleRegistry() );
				variables.moduleService.rebuildModuleRegistry();
				expect( variables.moduleService.getModuleRegistry() ).toBe( existingRegistry );
			} );

			it( "Can register and activate an ad-hoc module", function(){
				variables.moduleService.registerAndActivateModule( "test-module", "tests.resources" );
				expect( variables.moduleService.getModuleRegistry() ).toHaveKey( "test-module" );
				// Test that the module invocation paths registered are using the virtual mapping
				debug( getMetadata( getWirebox().getInstance( "MyModel@mserv" ) ).name );
				expect( getWirebox().getInstance( "MyModel@mserv" ) )
					.toBeComponent()
					.toBeInstanceOf( "mserv.models.MyModel" );
			} );

			it( "Can reload a convention registered module", function(){
				variables.moduleService.reload( "api" );
				expect( variables.moduleService.getModuleRegistry() ).toHaveKey( "api" );
			} );

			it( "Can reload an ad-hoc registered module", function(){
				if ( !variables.moduleService.isModuleRegistered( "test-module" ) ) {
					variables.moduleService.registerAndActivateModule( "test-module", "tests.resources" );
				}
				variables.moduleService.reload( "test-module" );
				expect( variables.moduleService.getModuleRegistry() ).toHaveKey( "test-module" );
			} )
		} );
	}

}
