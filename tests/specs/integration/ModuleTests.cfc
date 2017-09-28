/*******************************************************************************
*	Integration Test as BDD (CF10+ or Railo 4.1 Plus)
*
*	Extends the integration class: coldbox.system.testing.BaseTestCase
*
*	so you can test your ColdBox application headlessly. The 'appMapping' points by default to
*	the '/root' mapping created in the test folder Application.cfc.  Please note that this
*	Application.cfc must mimic the real one in your root, including ORM settings if needed.
*
*	The 'execute()' method is used to execute a ColdBox event, with the following arguments
*	* event : the name of the event
*	* private : if the event is private or not
*	* prePostExempt : if the event needs to be exempt of pre post interceptors
*	* eventArguments : The struct of args to pass to the event
*	* renderResults : Render back the results of the event
*******************************************************************************/
component extends="coldbox.system.testing.BaseTestCase" appMapping="/cbTestHarness"{

	/*********************************** LIFE CYCLE Methods ***********************************/

	function beforeAll(){
		super.beforeAll();
		// do your own stuff here
	}

	function afterAll(){
		// do your own stuff here
		super.afterAll();
	}

/*********************************** BDD SUITES ***********************************/

	function run(){

		describe( "Module Features", function(){

			beforeEach(function( currentSpec ){
				// Setup as a new ColdBox request, VERY IMPORTANT. ELSE EVERYTHING LOOKS LIKE THE SAME REQUEST.
				setup();
			});

			it( "can load models in a namespace", function(){
				var event = execute( event="test1:test.namespaceModel", renderResults=true );
				expect(	event.getValue( "cbox_rendered_content" ) ).toBe( "Hola Brother!" );
			});

			it( "can execute a module with custom conventions", function(){
				var event = execute( event="conventionsTest:test.index", renderResults=true );
				expect(	event.getValue( "data" ) ).toBeStruct();
			});

			it( "can register cfml mappings", function(){
				var event = execute( event="test1:test.cfmlMapping", renderResults=true );
				expect(	event.getValue( "cbox_rendered_content" ) ).toBe( "Hola Brother!" );
			});

			it( "can have aliases for execution", function(){
				var event = execute( event="cbtest1:test.index", renderResults=true );
				expect(	event.getValue( "cbox_rendered_content" ) ).toMatch( "welcome" );
			});

			it( "should not load disabled modules", function(){
				expect(	getController().getSetting( "modules" ) ).notToHaveKey( "disabledModule" );
			});

			it( "should not activate non-actavatable modules", function(){
				var config = getController().getSetting( "modules" );
				expect( config[ "notActivatedModule" ].activated ).toBeFalse();
			});

			it( "should load modules in a bundle", function(){
				var config = getController().getSetting( "modules" );

				// debug( config );

				expect(	config ).toHaveKey( 'layouttest' )
					.toHaveKey( 'test1' );
			});

			it( "should merge module settings with framework moduleSettings by default", function() {
				var config = getController().getSetting( "modules" );
				var parentSettings = getController().getConfigSettings();

				expect( parentSettings ).toHaveKey( "moduleSettings" );
				expect( parentSettings.moduleSettings ).toHaveKey( "test1" );

				expect(	config ).toHaveKey( 'test1' );
				expect( config[ "test1" ] ).toHaveKey( "settings" );
				
				expect( config[ "test1" ].settings ).toBe( parentSettings.moduleSettings[ "test1" ] );

				expect( parentSettings ).toHaveKey( "test1" );
				expect( parentSettings[ "test1" ] ).notToBe( config[ "test1" ].settings );
			} );

			it( "should not load modules that have been excluded, even in bundles", function(){
				var config = getController().getSetting( "modules" );
				expect(	config ).notToHaveKey( 'excludedmod' );
			});

		});

		story( "Modules can support nested module inception", function(){
			given( "A nested module: inception", function(){
				then( "the nested module: inception-mod1 should load and be active", function(){
					var config = getController().getSetting( "modules" );
					expect(	config ).toHaveKey( "inception-mod1" );
					expect(	config[ "inception-mod1" ].activated ).toBeTrue();
				});
			});

			given( "A nested module: a-inception", function(){
				then( "the nested module should only have its onLoad method called once", function(){
					expect( request ).toHaveKey( "a-inception" );
					expect( request[ "a-inception" ] ).toBeStruct();
					expect( request[ "a-inception" ] ).toHaveKey( "loadedCount" );
					expect( request[ "a-inception" ].loadedCount ).toBe( 1, "Module onLoad should only have been called once." );
				});
			});

			given( "A nested module: inception with a 'modules_app' convention", function(){
				then( "it should load and activate its sub-modules", function(){
					var config = getController().getSetting( "modules" );
					expect(	config ).toHaveKey( "inception-app1" );
					expect(	config[ "inception-app1" ].activated ).toBeTrue();
				});
			});
		});

		story( "Modules can support default model export", function(){
			given( "A module with a model of the same name", function(){
				then( "You will be able to get the model via @moduleName", function(){
					var oModel = getInstance( "@conventionsTest" );
					oModel.echo();
				});
			});
			given( "A model namespace", function(){
				then( "You will be able to get the model via @modelNamespace", function(){
					var oModel = getInstance( "@MyConventionsTest" );
					oModel.echo();
				});
			});
		});
	}

}