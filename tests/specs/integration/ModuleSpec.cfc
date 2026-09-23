component extends="tests.resources.BaseIntegrationTest" {

	/*********************************** BDD SUITES ***********************************/

	function run(){
		describe( "Module Features", () => {
			beforeEach( ( currentSpec ) => {
				// Setup as a new ColdBox request, VERY IMPORTANT. ELSE EVERYTHING LOOKS LIKE THE SAME REQUEST.
				setup();
			} );

			it( "can detect invalid module events", () => {
				var event = execute( route = "/refs:main/index", renderResults = true );
				expect( event.getValue( "cbox_rendered_content" ) ).toInclude( "Invalid Page" );
			} );

			it( "can load models in a namespace", () => {
				var event = execute( event = "test1:test.namespaceModel", renderResults = true );
				expect( event.getValue( "cbox_rendered_content" ) ).toBe( "Hola Brother!" );
			} );

			it( "can execute a module with custom conventions", () => {
				var event = execute( event = "conventionsTest:test.index", renderResults = true );
				expect( event.getValue( "data" ) ).toBeStruct();
			} );

			it( "can register cfml mappings", () => {
				var event = execute( event = "test1:test.cfmlMapping", renderResults = true );
				expect( event.getValue( "cbox_rendered_content" ) ).toBe( "Hola Brother!" );
			} );

			it( "can have aliases for execution", () => {
				var event = execute( event = "cbtest1:test.index", renderResults = true );
				expect( event.getValue( "cbox_rendered_content" ) ).toMatch( "welcome" );
			} );

			it( "should not load disabled modules", () => {
				expect( getController().getSetting( "modules" ) ).notToHaveKey( "disabledModule" );
			} );

			it( "should not activate non-actavatable modules", () => {
				var config = getController().getSetting( "modules" );
				expect( config[ "notActivatedModule" ].activated ).toBeFalse();
			} );

			it( "should load modules in a bundle", () => {
				var config = getController().getSetting( "modules" );

				// debug( config );

				expect( config ).toHaveKey( "layouttest" ).toHaveKey( "test1" );
			} );

			it( "should merge module settings with framework moduleSettings by default", () => {
				var config         = getController().getSetting( "modules" );
				var parentSettings = getController().getConfigSettings();

				expect( parentSettings ).toHaveKey( "moduleSettings" );
				expect( parentSettings.moduleSettings ).toHaveKey( "test1" );

				expect( config ).toHaveKey( "test1" );
				expect( config[ "test1" ] ).toHaveKey( "settings" );

				expect( config[ "test1" ].settings ).toBe( parentSettings.moduleSettings[ "test1" ] );

				expect( parentSettings ).toHaveKey( "test1" );
				expect( parentSettings[ "test1" ] ).notToBe( config[ "test1" ].settings );
			} );

			it( "should not load modules that have been excluded, even in bundles", () => {
				var config = getController().getSetting( "modules" );
				expect( config ).notToHaveKey( "excludedmod" );
			} );
		} );

		story( "Modules can support nested module inception", () => {
			given( "A nested module: inception", () => {
				then( "the nested module: inception-mod1 should load and be active", () => {
					var config = getController().getSetting( "modules" );
					expect( config ).toHaveKey( "inception-mod1" );
					expect( config[ "inception-mod1" ].activated ).toBeTrue();
				} );
			} );

			given( "A nested module: a-inception", () => {
				then( "the nested module should only have its onLoad method called once", () => {
					expect( request ).toHaveKey( "a-inception" );
					expect( request[ "a-inception" ] ).toBeStruct();
					expect( request[ "a-inception" ] ).toHaveKey( "loadedCount" );
					expect( request[ "a-inception" ].loadedCount ).toBe(
						1,
						"Module onLoad should only have been called once."
					);
				} );
			} );

			given( "A nested module: inception with a 'modules_app' convention", () => {
				then( "it should load and activate its sub-modules", () => {
					var config = getController().getSetting( "modules" );
					expect( config ).toHaveKey( "inception-app1" );
					expect( config[ "inception-app1" ].activated ).toBeTrue();
				} );
			} );
		} );

		story( "Modules can register custom routing", () => {
			given( "A routing array", () => {
				then( "module routes should be registered", () => {
					var routingService = getController().getRoutingService();
					var routing        = routingService.getModuleRoutes( "conventionsTest" );

					expect( routing ).notToBeEmpty();
				} );

				then( "an explicit convention route should not be registered twice", () => {
					var routingService   = getController().getRoutingService();
					var routing          = routingService.getModuleRoutes( "resourcesTest" );
					var conventionRoutes = routing.filter( ( item ) => {
						return reFindNoCase( "^/?\:handler/\:action\??/?$", item.pattern );
					} );

					expect( conventionRoutes ).toHaveLength( 1 );
				} );
			} );
		} );

		story( "Modules can register application helpers", () => {
			given( "application helpers directive", () => {
				then( "the module service will load them by convention", () => {
					var event = execute( event = "conventionsTest:test.index", renderResults = true );
					expect( event.getRenderedContent() ).toInclude( "hello from module app helper" );
				} );
			} );
		} );

		story( "Modules can register custom resources", () => {
			given( "A resources array", () => {
				then( "module resourceful routes should be registered", () => {
					var routingService = getController().getRoutingService();
					var routing        = routingService.getModuleRoutes( "resourcesTest" );

					var photosFound = usersFound = false;
					for ( var thisRoute in routing ) {
						if ( findNoCase( "photos", thisRoute.handler ?: "" ) ) {
							photosFound = true;
							continue;
						}
						if ( findNoCase( "users", thisRoute.handler ?: "" ) ) {
							usersFound = true;
							continue;
						}
					}

					expect( photosFound ).toBeTrue();
					expect( usersFound ).toBeTrue();
				} );
			} );
		} );

		story( "Modules can support default model export", () => {
			given( "A module with a model of the same name", () => {
				then( "You will be able to get the model via @moduleName", () => {
					var oModel = getInstance( "@conventionsTest" );
					oModel.echo();
				} );
			} );
			given( "A model namespace", () => {
				then( "You will be able to get the model via @modelNamespace", () => {
					var oModel = getInstance( "@MyConventionsTest" );
					oModel.echo();
				} );
			} );
		} );
	}

}
