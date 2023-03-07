component extends="tests.resources.BaseIntegrationTest" {

	function beforeAll(){
		super.beforeAll();
		variables.model = getController().getModuleService();
	}

	function run(){
		describe( "Module Lifecycle", function(){
			beforeEach( function( currentSpec ){
				// Setup as a new ColdBox request, VERY IMPORTANT. ELSE EVERYTHING LOOKS LIKE THE SAME REQUEST.
				setup();
			} );

			it( "Tests the ModuleService configuration", function(){
				expect( variables.model.getModuleRegistry() ).toBeStruct();
			} );

			it( "Can rebuild the module registry", function(){
				var existingRegistry = duplicate( variables.model.getModuleRegistry() );
				variables.model.rebuildModuleRegistry();
				expect( variables.model.getModuleRegistry() ).toBe( existingRegistry );
			} );

			it( "Can register and activate an ad-hoc module", function(){
				variables.model.registerAndActivateModule( "test-module", "tests.resources" );
				expect( variables.model.getModuleRegistry() ).toHaveKey( "test-module" );
				// Test that the module invocation paths registered are using the virtual mapping
				debug( getMetadata( getWirebox().getInstance( "MyModel@mserv" ) ).name );
				expect( getWirebox().getInstance( "MyModel@mserv" ) )
					.toBeComponent()
					.toBeInstanceOf( "mserv.models.MyModel" );
			} );

			it( "Can reload a convention registered module", function(){
				variables.model.reload( "cborm" );
				expect( variables.model.getModuleRegistry() ).toHaveKey( "cborm" );
			} );

			it( "Can reload an ad-hoc registered module", function(){
				if ( !variables.model.isModuleRegistered( "test-module" ) ) {
					variables.model.registerAndActivateModule( "test-module", "tests.resources" );
				}
				variables.model.reload( "test-module" );
				expect( variables.model.getModuleRegistry() ).toHaveKey( "test-module" );
			} )
		} );
	}

}
