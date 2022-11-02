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
		feature( "WireBox Delegators", function(){

			story( "A delegate will receive it's parent target injected into the variables scope as $parent", function(){
				given( "A computer target and a worker delegate", function(){
					then( "it will delegate and add the $parent (computer) into the worker", function(){
						var computer = injector.getinstance( "Computer" );
						expect( computer ).toHaveKey( "work" );
						expect( computer.sayHello() ).toBe( "Hola Computadora!" );
					} );
				} );
			})

			story( "I can inject delegators with the 'delegate' annotation", function(){
				given( "A computer target and a worker delegate", function(){
					then( "it will inject and compose the delegation for all public methods", function(){
						var computer = injector.getinstance( "Computer" );
						expect( computer ).toHaveKey( "work" );
						expect( computer ).toHaveKey( "vacation" );

						expect( function(){
							computer.work();
							computer.vacation();
						} ).notToThrow();
					} );
				} );
			} );

			story( "I can inject delegators with the 'delegate' annotation that has an inclusion list", function(){
				given( "A computer target and a worker delegate with a value of 'work'", function(){
					then( "it will inject and compose the delegation for only the 'work' method", function(){
						var computer = injector.getinstance( "Computer" );
						expect( computer ).toHaveKey( "workaholicWork" );
						expect( computer ).notToHaveKey( "workaholicVacation" );

						expect( function(){
							computer.workaholicWork();
						} ).notToThrow();
					} );
				} );
			} );

			story( "I can inject delegators with the 'delegate' annotation that has an exclusion list", function(){
				given( "A computer target and a worker delegate with an exclusion of 'work'", function(){
					then( "it will inject and compose the delegation for only the 'vacation' method", function(){
						var computer = injector.getinstance( "Computer" );
						expect( computer ).toHaveKey( "managerVacation" );
						expect( computer ).notToHaveKey( "managerWork" );

						expect( function(){
							computer.managerVacation();
						} ).notToThrow();
					} );
				} );
			} );

			story( "I can inject delegators with a delegate suffix", function(){
				given( "A computer target with a 'disk' delegate and an empty suffix", function(){
					then( "it will inject and compose the delegation with the suffix based on the property name", function(){
						var computer = injector.getinstance( "Computer" );
						expect( computer ).toHaveKey( "readDisk2" );
						expect( computer ).toHaveKey( "writeDisk2" );

						expect( function(){
							computer.readDisk2( 1 );
							computer.writeDisk2( { id : createUUID(), name : "unit test" } );
						} ).notToThrow();
					} );
				} );

				given( "A computer target with a 'disk' delegate and a suffix of 'disk'", function(){
					then( "it will inject and compose the delegation with the suffix", function(){
						var computer = injector.getinstance( "Computer" );
						expect( computer ).toHaveKey( "readDisk" );
						expect( computer ).toHaveKey( "writeDisk" );

						expect( function(){
							computer.readDisk( 1 );
							computer.writeDisk( { id : createUUID(), name : "unit test" } );
						} ).notToThrow();
					} );
				} );
			} );

			story( "I can inject delegators with a delegate prefix", function(){
				given( "A computer target with a 'memory' delegate and an empty prefix", function(){
					then( "it will inject and compose the delegation with the prefix based on the property name", function(){
						var computer = injector.getinstance( "Computer" );
						expect( computer ).toHaveKey( "memoryRead" );
						expect( computer ).toHaveKey( "memoryWrite" );

						expect( function(){
							computer.memoryRead( 1 );
							computer.memoryWrite( { id : createUUID(), name : "unit test" } );
						} ).notToThrow();
					} );
				} );

				given( "A computer target with a 'memory' delegate and a prefix of 'memory2'", function(){
					then( "it will inject and compose the delegation with a concrete prefix", function(){
						var computer = injector.getinstance( "Computer" );
						expect( computer ).toHaveKey( "memory2Read" );
						expect( computer ).toHaveKey( "memory2Write" );

						expect( function(){
							computer.memory2Read( 1 );
							computer.memory2Write( { id : createUUID(), name : "unit test" } );
						} ).notToThrow();
					} );
				} );
			} );
		} );
	}

}
