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

		feature( "Mappings survive a failed first processing (COLDBOX-1420)", function(){
			beforeEach( function( currentSpec ){
				variables.injector1420  = new coldbox.system.ioc.Injector();
				variables.ghostPath1420 = expandPath( "/tests/resources/Ghost1420.cfc" );
			} );

			afterEach( function( currentSpec ){
				if ( fileExists( variables.ghostPath1420 ) ) {
					fileDelete( variables.ghostPath1420 );
				}
			} );

			story( "I want explicit mappings to stay registered when their first processing fails", function(){
				given( "an explicit mapping to a path that does not exist", function(){
					then( "the mapping stays registered and a retry throws the original error, not InstanceNotFoundException", function(){
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
						expect( firstErrorType ).notToBe( "NONE", "The first getInstance() should have thrown" );
						expect( firstErrorType ).notToBe( "Injector.InstanceNotFoundException" );

						// The mapping must still be registered after the failure
						expect( injector1420.getBinder().mappingExists( "ghost1420@demo" ) ).toBeTrue();

						// A second lookup retries processing and throws the original error again
						var secondErrorType = "NONE";
						try {
							injector1420.getInstance( "ghost1420@demo" );
						} catch ( any e ) {
							secondErrorType = e.type;
						}
						expect( secondErrorType ).notToBe( "NONE", "The second getInstance() should have thrown" );
						expect( secondErrorType ).notToBe( "Injector.InstanceNotFoundException" );
					} );
				} );

				given( "an explicit mapping whose file is missing on the first lookup but present on the second", function(){
					then( "the second lookup recovers and builds the instance", function(){
						injector1420
							.getBinder()
							.map( "ghostFile1420@demo" )
							.to( "tests.resources.Ghost1420" );

						// First lookup fails because the file does not exist yet
						var firstErrorType = "NONE";
						try {
							injector1420.getInstance( "ghostFile1420@demo" );
						} catch ( any e ) {
							firstErrorType = e.type;
						}
						expect( firstErrorType ).notToBe( "NONE", "The first getInstance() should have thrown" );
						expect( injector1420.getBinder().mappingExists( "ghostFile1420@demo" ) ).toBeTrue();

						// Restore the file and retry the same mapping
						fileWrite( variables.ghostPath1420, "component {}" );
						var instance = injector1420.getInstance( "ghostFile1420@demo" );
						expect( isObject( instance ) ).toBeTrue();
					} );
				} );

				given( "a mapping registered under several names to a bad path", function(){
					then( "all names stay registered after a failed lookup", function(){
						injector1420
							.getBinder()
							.map( [ "aliasA1420", "aliasB1420" ] )
							.to( "tests.resources.DoesNotExist1420" );

						try {
							injector1420.getInstance( "aliasA1420" );
						} catch ( any e ) {
							// Expected: the bad path makes processing fail. This spec only checks the mappings below.
						}

						expect( injector1420.getBinder().mappingExists( "aliasA1420" ) ).toBeTrue();
						expect( injector1420.getBinder().mappingExists( "aliasB1420" ) ).toBeTrue();
					} );
				} );
			} );

			story( "I want processMappings() to keep mappings that fail processing", function(){
				given( "a binder with a mapping to a bad path", function(){
					then( "processMappings() throws but keeps the mapping registered", function(){
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
						expect( errorType ).notToBe( "NONE", "processMappings() should have thrown" );
						expect( injector1420.getBinder().mappingExists( "bad1420" ) ).toBeTrue();
					} );
				} );
			} );
		} );
	}

}
