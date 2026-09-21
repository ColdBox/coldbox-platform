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

			it( "Still resolves a handler-only URL when a module only declares the mandatory-action convention route", function(){
				variables.moduleService.registerAndActivateModule( "test-module-conventions", "tests.resources" );

				// A module that only declares "/:handler/:action" (mandatory action, like
				// ContentBox's contentbox-admin module) must still resolve a handler-only,
				// single-segment URL by way of ColdBox's auto-injected optional-action
				// convention route ("/:handler/:action?"). If ColdBox fails to auto-inject it
				// (the regression this test guards against), this lookup returns an empty route
				// and the request would fall through to the parent application's own routes.
				var mockEvent = createMock( "coldbox.system.web.context.RequestContext" ).init(
					controller = getController(),
					properties = {
						defaultLayout : "Main.cfm",
						defaultView   : "",
						eventName     : "event",
						modules       : {}
					}
				);

				var results = getController().getRoutingService().findRoute(
					action = "home",
					event  = mockEvent,
					module = "test-module-conventions"
				);

				expect( results.route ).notToBeEmpty(
					"Expected the handler-only URL 'home' to match a route within the module; got no match, meaning the request would fall through to the parent app's routes."
				);
				expect( results.params.handler ?: "" ).toBe( "home" );
			} )
		} );
	}

}
