/**
 * Flow specs
 */
component extends="testbox.system.BaseSpec" {

	/*********************************** LIFE CYCLE Methods ***********************************/

	/**
	 * executes before all suites+specs in the run() method
	 */
	function beforeAll(){
		env = createMock( "coldbox.system.core.delegates.Env" );
	}

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "Env spec", function(){
			it( "can get a system property", function(){
				var systemMock = createObject( "java", "java.lang.System" );
				systemMock.setProperty( "foo", "bar" );

				env.$( "getJavaSystem", systemMock );

				var setting = env.getSystemProperty( "foo" );
				expect( setting ).toBe( "bar" );

				var exceptionThrown = false;
				expect( function(){
					var setting = env.getSystemProperty( "bar" );
				} ).toThrow();
				setting = env.getSystemProperty( "bar", "baz" );
				expect( setting ).toBe( "baz" );
			} );

			it( "can get a system setting", function(){
				var systemMock = createStub();
				systemMock
					.$( "getProperty" )
					.$args( "foo" )
					.$results( "bar" );
				systemMock
					.$( "getProperty" )
					.$args( "bar" )
					.$results( javacast( "null", "" ) );
				systemMock
					.$( "getProperty" )
					.$args( "baz" )
					.$results( javacast( "null", "" ) );

				systemMock
					.$( "getEnv" )
					.$args( "bar" )
					.$results( "baz" );
				systemMock
					.$( "getEnv" )
					.$args( "baz" )
					.$results( javacast( "null", "" ) );

				env.$( "getJavaSystem", systemMock );

				var setting = env.getSystemSetting( "foo" );
				expect( setting ).toBe( "bar" );

				setting = env.getSystemSetting( "bar" );
				expect( setting ).toBe( "baz" );

				var exceptionThrown = false;

				expect( function(){
					var setting = env.getSystemSetting( "baz" );
				} ).toThrow();
				setting = env.getSystemSetting( "baz", "default" );
				expect( setting ).toBe( "default" );
			} );

			it( "can get an env variable", function(){
				var systemMock = createStub();
				systemMock
					.$( "getEnv" )
					.$args( "foo" )
					.$results( "bar" );
				systemMock
					.$( "getEnv" )
					.$args( "bar" )
					.$results( javacast( "null", "" ) );

				env.$( "getJavaSystem", systemMock );

				var setting = env.getEnv( "foo" );
				expect( setting ).toBe( "bar" );

				expect( function(){
					var setting = env.getEnv( "bar" );
				} ).toThrow();

				setting = env.getEnv( "bar", "baz" );
				expect( setting ).toBe( "baz" );
			} );
		} );
	}

}
