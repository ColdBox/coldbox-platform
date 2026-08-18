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
			beforeEach( function( currentSpec ){
				// Build out the global injector
				variables.injector = createMock( "coldbox.system.ioc.Injector" ).init(
					"tests.specs.ioc.config.samples.InjectorCreationTestsBinder"
				);
			} );

			story( "I want to get instances from specific child injectors via getInstance()", function(){
				given( "a valid child injector name to the getInstance() method", function(){
					then( "it should retrieve valid instances", function(){
						var child = new coldbox.system.ioc.Injector(
							"coldbox.tests.specs.ioc.config.samples.NoScopeBinder"
						);
						injector.registerChildInjector( "myChild", child );
						var results = injector.getInstance( name: "childValue", injector: "myChild" );
						expect( results ).toBe( "Luigi" );
					} );
				} );

				given( "an invalid child injector name to the getInstance() method", function(){
					then( "it should throw an injection", function(){
						expect( function(){
							injector.getInstance( name: "childValue", injector: "invalidBogus" );
						} ).toThrow();
					} );
				} );
			} );

			story( "I want the containsInstance() to search locally, the parent and then the child injectors for instances", function(){
				given( "A fake instance ", function(){
					then( "it should not be able to locate it", function(){
						var child = new coldbox.system.ioc.Injector(
							"coldbox.tests.specs.ioc.config.samples.NoScopeBinder"
						);
						expect( injector.containsInstance( "childValueFake" ) ).toBeFalse();
					} );
				} );
				given( "A valid child injector and child instance ", function(){
					then( "it should be able to locate it", function(){
						var child = new coldbox.system.ioc.Injector(
							"coldbox.tests.specs.ioc.config.samples.NoScopeBinder"
						);
						injector.registerChildInjector( "myChild", child );
						expect( injector.containsInstance( "childValue" ) ).toBeTrue();
					} );
				} );
			} );

			story( "I want to have a specific child injector DSL", function(){
				beforeEach( function( currentSpec ){
					var child = new coldbox.system.ioc.Injector(
						"coldbox.tests.specs.ioc.config.samples.NoScopeBinder"
					);
					injector.registerChildInjector( "myChild", child );
				} );

				given( "An injection DSL of wirebox:child:myChild", function(){
					then( "it should retrieve the instance according to property name", function(){
						var childSample = injector.getInstance( "tests.resources.ChildInjectorSample" );
						expect( childSample.getChildValue() ).toBe( "Luigi" );
					} );
				} );

				given( "An injection DSL of wirebox:child:myChild:childValue", function(){
					then( "it should retrieve the instance according to the 4th level DSL", function(){
						var childSample = injector.getInstance( "tests.resources.ChildInjectorSample" );
						expect( childSample.getTestValue() ).toBe( "Luigi" );
					} );
				} );
			} );

			story( "I want to retrieve instances from child injectors hierarchically", function(){
				beforeEach( function( currentSpec ){
					var child = new coldbox.system.ioc.Injector(
						"coldbox.tests.specs.ioc.config.samples.NoScopeBinder"
					);
					injector.registerChildInjector( "myChild", child );
				} );

				given( "A child injector instance name", function(){
					then( "it should retrieve the instance from the child", function(){
						var childSample = injector.getInstance( "ChildValue" );
						expect( childSample ).toBe( "Luigi" );
					} );
				} );
			} );

			story( "I want to retrieve root injectors via DSL", function(){
				beforeEach( function( currentSpec ){
					var child = new coldbox.system.ioc.Injector(
						"coldbox.tests.specs.ioc.config.samples.NoScopeBinder"
					).setRoot( variables.injector );
					injector.registerChildInjector( "myChild", child );
				} );
				given( "An object with a wirebox:root dsl", function(){
					then( "it should build and inject a root injector", function(){
						var childSample = injector.getInstance( "tests.resources.ChildInjectorSample" );
						expect( childSample.getRoot().getName() ).toBe( "root" );
					} );
				} );
			} );
		} );

		feature( "Keep mappings after a processing error (COLDBOX-1420)", function(){
			beforeEach( function( currentSpec ){
				variables.injector1420  = new coldbox.system.ioc.Injector();
				variables.ghostPath1420 = expandPath( "/tests/resources/Ghost1420.cfc" );
			} );

			afterEach( function( currentSpec ){
				if ( fileExists( variables.ghostPath1420 ) ) {
					fileDelete( variables.ghostPath1420 );
				}
			} );

			story( "Keep explicit mappings after a processing error", function(){
				given( "a mapping for a component that does not exist", function(){
					then( "each lookup reports a component error and keeps the mapping", function(){
						injector1420
							.getBinder()
							.map( "ghost1420@demo" )
							.to( "tests.resources.DoesNotExist1420" );

						var firstErrorType = "NONE";
						try {
							injector1420.getInstance( "ghost1420@demo" );
						} catch ( any e ) {
							firstErrorType = e.type;
						}
						expect( firstErrorType ).notToBe( "NONE", "The first lookup should report an error" );
						expect( firstErrorType ).notToBe( "Injector.InstanceNotFoundException" );

						// The failed lookup must not remove the mapping.
						expect( injector1420.getBinder().mappingExists( "ghost1420@demo" ) ).toBeTrue();

						// The second lookup must try to read the component again.
						var secondErrorType = "NONE";
						try {
							injector1420.getInstance( "ghost1420@demo" );
						} catch ( any e ) {
							secondErrorType = e.type;
						}
						expect( secondErrorType ).notToBe( "NONE", "The second lookup should report an error" );
						expect( secondErrorType ).notToBe( "Injector.InstanceNotFoundException" );
					} );
				} );

				given( "a mapped component added after the first lookup", function(){
					then( "the second lookup creates the instance", function(){
						injector1420
							.getBinder()
							.map( "ghostFile1420@demo" )
							.to( "tests.resources.Ghost1420" );

						// The first lookup fails because the component file does not exist.
						var firstErrorType = "NONE";
						try {
							injector1420.getInstance( "ghostFile1420@demo" );
						} catch ( any e ) {
							firstErrorType = e.type;
						}
						expect( firstErrorType ).notToBe( "NONE", "The first lookup should report an error" );
						expect( injector1420.getBinder().mappingExists( "ghostFile1420@demo" ) ).toBeTrue();

						// Add the component file and try the same mapping again.
						fileWrite( variables.ghostPath1420, "component {}" );
						var instance = injector1420.getInstance( "ghostFile1420@demo" );
						expect( isObject( instance ) ).toBeTrue();
					} );
				} );

				given( "one missing component mapped under two names", function(){
					then( "a failed lookup keeps both names", function(){
						injector1420
							.getBinder()
							.map( [ "aliasA1420", "aliasB1420" ] )
							.to( "tests.resources.DoesNotExist1420" );

						try {
							injector1420.getInstance( "aliasA1420" );
						} catch ( any e ) {
							// The missing component error is expected.
						}

						expect( injector1420.getBinder().mappingExists( "aliasA1420" ) ).toBeTrue();
						expect( injector1420.getBinder().mappingExists( "aliasB1420" ) ).toBeTrue();
					} );
				} );
			} );

			story( "Keep failed mappings during processMappings()", function(){
				given( "a mapping for a component that does not exist", function(){
					then( "processMappings() reports the error and keeps the mapping", function(){
						injector1420
							.getBinder()
							.map( "bad1420" )
							.to( "tests.resources.DoesNotExist1420" );

						var errorType = "NONE";
						try {
							injector1420.getBinder().processMappings();
						} catch ( any e ) {
							errorType = e.type;
						}
						expect( errorType ).notToBe( "NONE", "processMappings() should report an error" );
						expect( injector1420.getBinder().mappingExists( "bad1420" ) ).toBeTrue();
					} );
				} );
			} );
		} );
	}

}
