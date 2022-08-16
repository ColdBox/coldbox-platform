/**
 * My BDD Test
 */
component extends="tests.resources.BaseIntegrationTest" {

	this.loadColdBox = false;

	/*********************************** LIFE CYCLE Methods ***********************************/

	/**
	 * executes before all suites+specs in the run() method
	 */
	function beforeAll(){
		super.beforeAll();
		injector = createMock( "coldbox.system.ioc.Injector" ).init(
			"tests.specs.ioc.config.samples.TestHarnessBinder"
		);
	}

	/**
	 * executes after all suites+specs in the run() method
	 */
	function afterAll(){
		super.afterAll();
	}

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		feature( "WireBox Shorthand Delegators Syntax", function(){
			story( "I can declare delegators with the 'delegates' simple component annotation", function(){
				// SIMPLE SYNTAX
				given( "A computer target with a simple delegate syntax", function(){
					then( "it will inject all delegated methods with no suffix or prefix", function(){
						var computer = injector.getInstance( "ComputerShorthand" );
						expect( computer ).toHaveKey( "when" );
						expect( computer ).toHaveKey( "unless" );
					} );
				} );
			} );

			story( "I can inject delegators with the 'delegate' component annotation that has an inclusion list", function(){
				given( "A computer target and a worker delegate with a value of 'vacation'", function(){
					then( "it will inject and compose the delegation for only the 'vacation' method", function(){
						var computer = injector.getinstance( "ComputerShorthand" );
						expect( computer ).toHaveKey( "vacation" );
						expect( function(){
							computer.vacation();
						} ).notToThrow();
					} );
				} );
			} );

			story( "I can inject delegators with a delegate component annotation with a prefix", function(){
				given( "A computer target with a '>Memory' delegate", function(){
					then( "it will inject and compose the delegation with the prefix based on the model name", function(){
						var computer = injector.getinstance( "ComputerShorthand" );
						expect( computer ).toHaveKey( "memoryRead" );
						expect( computer ).toHaveKey( "memoryWrite" );

						expect( function(){
							computer.memoryRead( 1 );
							computer.memoryWrite( { id : createUUID(), name : "unit test" } );
						} ).notToThrow();
					} );
				} );

				given( "A computer target with a 'ram2>memory' delegate", function(){
					then( "it will inject and compose the delegation with the 'ram2' prefix", function(){
						var computer = injector.getinstance( "ComputerShorthand" );
						expect( computer ).toHaveKey( "ram2Read" );
						expect( computer ).toHaveKey( "ram2Write" );

						expect( function(){
							computer.ram2Read( 1 );
							computer.ram2Write( { id : createUUID(), name : "unit test" } );
						} ).notToThrow();
					} );
				} );
			} );

			story( "I can inject delegators with a delegate suffix", function(){
				given( "A computer target with a '<memory' delegate and an empty suffix", function(){
					then( "it will inject and compose the delegation with the suffix based on the model name", function(){
						var computer = injector.getinstance( "ComputerShorthand" );
						expect( computer ).toHaveKey( "readMemory" );
						expect( computer ).toHaveKey( "writeMemory" );

						expect( function(){
							computer.readMemory( 1 );
							computer.writeMemory( { id : createUUID(), name : "unit test" } );
						} ).notToThrow();
					} );
				} );

				given( "A computer target with a 'ram<memory' delegate'", function(){
					then( "it will inject and compose the delegation with the 'ram' suffix", function(){
						var computer = injector.getinstance( "ComputerShorthand" );
						expect( computer ).toHaveKey( "readRam" );
						expect( computer ).toHaveKey( "writeRam" );

						expect( function(){
							computer.readRam( 1 );
							computer.writeRam( { id : createUUID(), name : "unit test" } );
						} ).notToThrow();
					} );
				} );
			} );
		} );
	}

}
