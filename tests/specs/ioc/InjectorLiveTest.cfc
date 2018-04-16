
/**
* My BDD Test
*/
component extends="coldbox.system.testing.BaseTestCase"{

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
				injector = createMock( "coldbox.system.ioc.Injector" )
					.init( "tests.specs.ioc.config.samples.InjectorCreationTestsBinder" );
			});

		});
	}

}
