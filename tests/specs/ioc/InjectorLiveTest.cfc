/**
 * My BDD Test
 */
component extends="tests.resources.BaseIntegrationTest" {

	this.loadColdBox = false;

	/*********************************** LIFE CYCLE Methods ***********************************/

	// executes before all suites+specs in the run() method
	function beforeAll(){
	}

	// executes after all suites+specs in the run() method
	function afterAll(){
	}

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		// all your suites go here.
		story( "I can load WireBox standalone with a custom LogBox configuration", function(){
			it( "can load correctly", function(){
				var injector = createMock( "coldbox.system.ioc.Injector" ).init(
					"tests.specs.ioc.config.samples.InjectorCreationTestsBinder"
				);
			} );
		} );

		feature( "WireBox Child Injectors", function(){

			beforeEach(function( currentSpec ){
				// Build out the global injector
				injector = createMock( "coldbox.system.ioc.Injector" ).init(
					"tests.specs.ioc.config.samples.InjectorCreationTestsBinder"
				);
			});

			story( "I want to get instances from specific child injectors via getInstance()", function(){

				given( "a valid child injector name to the getInstance() method", function(){
					then( "it should retrieve valid instances", function(){
						var child = new coldbox.system.ioc.Injector( "coldbox.tests.specs.ioc.config.samples.NoScopeBinder" );
						injector.registerChildInjector( "myChild", child );
						var results = injector.getInstance( name: "childValue", injector: "myChild" );
						expect( results ).toBe( "Luigi" );
					});
				});

				given( "an invalid child injector name to the getInstance() method", function(){
					then( "it should throw an injection", function(){
						expect( function(){
							injector.getInstance( name: "childValue", injector: "invalidBogus" );
						} ).toThrow();
					});
				});
			});

			story( "I want the containsInstance() to search locally, the parent and then the child injectors for instances", function(){
				given( "A fake instance ", function(){
					then( "it should not be able to locate it", function(){
						var child = new coldbox.system.ioc.Injector( "coldbox.tests.specs.ioc.config.samples.NoScopeBinder" );
						expect( injector.containsInstance( "childValueFake" ) ).toBeFalse();
					});
				});
				given( "A valid child injector and child instance ", function(){
					then( "it should be able to locate it", function(){
						var child = new coldbox.system.ioc.Injector( "coldbox.tests.specs.ioc.config.samples.NoScopeBinder" );
						injector.registerChildInjector( "myChild", child );
						expect( injector.containsInstance( "childValue" ) ).toBeTrue();
					});
				});
			});

		});

	}

}
