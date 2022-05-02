component extends="coldbox.system.testing.BaseModelTest" model="coldbox.system.ioc.scopes.CFScopes"{

	/*********************************** LIFE CYCLE Methods ***********************************/

	/**
	 * executes before all suites+specs in the run() method
	 */
	function beforeAll(){
		mockLogger = createEmptyMock( "coldbox.system.logging.Logger" )
			.$( "canDebug", true )
			.$( "debug" )
			.$( "error" )
			.$( "canWarn", true )
			.$( "warn" );
		mockLogBox   = createEmptyMock( "coldbox.system.logging.LogBox" ).$( "getLogger", mockLogger );
		mockInjector = createMock( "coldbox.system.ioc.Injector" )
			.setLogBox( createstub().$( "getLogger", mockLogger ) )
			.$( "getUtility", createMock( "coldbox.system.core.util.Util" ) )
			.setLogBox( mockLogBox )
			.setInjectorID( createUUID() )
			.setScopeStorage( new coldbox.system.core.collections.ScopeStorage() );

		super.setup();
		scope    = model.init( mockInjector );
		mockStub = createStub();
	}

	/**
	 * executes after all suites+specs in the run() method
	 */
	function afterAll(){

	}

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "CF Scopes Suite", function(){

			story( "Can store and get objects from a CF scope", function(){
				given( "A new object request", function(){
					then( "it should store it into the right scope", function(){
						// 1: Default construction
						var mapping = createMock( "coldbox.system.ioc.config.Mapping" ).init( name = "CFScopeTest" );
						mapping.setScope( "session" );
						mapping.setThreadSafe( true );
						mockInjector.$( "buildInstance", mockStub ).$( "autowire", mockStub );
						structClear( session );

						var o = scope.getFromScope( mapping: mapping, initArguments: {} );
						expect( o ).toBe( mockStub );
						expect( mockStub ).toBe( session[ "wirebox:CFScopeTest" ] );
					});
				});

				given( "a previously created object", function(){
					then( "it should retrieve the same object", function(){
						var mapping = createMock( "coldbox.system.ioc.config.Mapping" ).init( name = "CFScopeTest" );
						mapping.setScope( "session" );
						mapping.setThreadSafe( true );
						session[ "wirebox:CFScopeTest" ] = mockStub;
						var o                            = scope.getFromScope( mapping, {} );
						expect( o ).toBe( mockStub );
					});
				});
			});
		} );
	}

}
