/**
 * Covers what registerAllModules() announces once every module has been registered,
 * with and without a `modules.include` list in the application configuration.
 */
component extends="coldbox.system.testing.BaseModelTest" model="coldbox.system.web.services.ModuleService" {

	function setup(){
		super.setup();

		variables.mockController         = getMockBox().createMock( "coldbox.system.testing.mock.web.MockController" );
		variables.mockLogger             = getMockBox().createEmptyMock( "coldbox.system.logging.Logger" ).$( "info" );
		variables.mockInterceptorService = getMockBox()
			.createEmptyMock( "coldbox.system.web.services.InterceptorService" )
			.$( "announce" );

		mockController.setSetting( "modules", {} );
		mockController.setSetting( "modulesInclude", [] );

		model
			.$property( "controller", "variables", mockController )
			.$property( "logger", "variables", mockLogger )
			.$property(
				"interceptorService",
				"variables",
				mockInterceptorService
			)
			.$property( "moduleRegistry", "variables", {} )
			// Disk scanning and real registrations are not what these specs are about
			.$( "rebuildModuleRegistry", model )
			.$( "registerModule", true )
			.$( "canLoad", true );
	}

	function run(){
		describe( "Registering all modules", function(){
			beforeEach( function( currentSpec ){
				setup();
			} );

			it( "announces afterModuleRegistrations when there is no include list", function(){
				model.registerAllModules();

				expect( mockInterceptorService.$count( "announce" ) ).toBe( 1 );
				expect( mockInterceptorService.$callLog().announce[ 1 ][ 1 ] ).toBe( "afterModuleRegistrations" );
			} );

			it( "announces afterModuleRegistrations when the application uses an include list", function(){
				mockController.setSetting( "modulesInclude", [ "myModule" ] );

				model.registerAllModules();

				expect( mockInterceptorService.$count( "announce" ) ).toBe( 1 );
				expect( mockInterceptorService.$callLog().announce[ 1 ][ 1 ] ).toBe( "afterModuleRegistrations" );
			} );
		} );
	}

}
