component extends="coldbox.system.testing.BaseModelTest" {

	function run(){
		describe( "Logger", function(){
			beforeEach( function( currentSpec ){
				setup();

				mockLB           = createMock( className = "coldbox.system.logging.LogBox", clearMethods = true );
				logger           = createMock( "coldbox.system.logging.Logger" );
				rootLogger       = createMock( "coldbox.system.logging.Logger" ).init( "ROOT" );
				logger.logLevels = createMock( "coldbox.system.logging.LogLevels" );

				// init Logger
				logger.init( category = "coldbox.system.logging.UnitTest" );
				logger.setRootLogger( rootLogger );
			} );

			it( "can create the logger", function(){
				expect( logger ).toBeComponent();
			} );

			it( "can verify all canX Methods", function(){
				logger.setLevelMin( 0 );
				logger.setLevelMax( 3 );

				assertTrue( logger.canFatal() );
				assertTrue( logger.canError() );
				assertTrue( logger.canWarn() );
				assertTrue( logger.canInfo() );
				assertFalse( logger.canDebug() );
			} );

			it( "can verify all canX Methods with values", function(){
				logger.setLevelMin( 0 );
				logger.setLevelMax( 3 );

				assertTrue( logger.canLog( "fatal" ) );
				assertTrue( logger.canLog( 1 ) );
				// Invalid level should not log
				assertFalse( logger.canLog( "asdfasfdsd" ) );
			} );

			it( "can execute all logging methods", function(){
				// has appenders
				assertFalse( logger.hasAppenders() );
				// get appenders
				assertEquals( logger.getAppenders(), structNew() );
				var newAppender = new coldbox.system.logging.appenders.ConsoleAppender( "MyConsoleAppender" );
				logger.addAppender( newAppender );
				assertTrue( logger.appenderExists( "MyConsoleAppender" ) );
				assertEquals( newAppender, logger.getAppender( "MyConsoleAppender" ) );
				// Remove
				logger.removeAppender( "MyConsoleAppender" );
				assertFalse( logger.appenderExists( "MyConsoleAppender" ) );

				// remove all
				newAppender = createObject( "component", "coldbox.system.logging.appenders.ConsoleAppender" ).init(
					"MyConsoleAppender"
				);
				newAppender2 = createObject( "component", "coldbox.system.logging.appenders.ConsoleAppender" ).init(
					"MyConsoleAppender2"
				);
				logger.addAppender( newAppender );
				logger.addAppender( newAppender2 );
				assertTrue( logger.hasAppenders() );
				logger.removeAllAppenders();
				assertFalse( logger.hasAppenders() );
			} );

			it( "can verify logging levels", function(){
				logger.setLevelMin( 0 );
				logger.setLevelMax( 4 );

				// appender Add
				newAppender = createEmptyMock( "coldbox.system.logging.appenders.ConsoleAppender" )
					.$( "canLog", false )
					.$( "getName", "ConsoleAppender" )
					.$( "isInitialized", true )
					.$( "logMessage" )
					.$( "getProperty", false )
					.$( "propertyExists", false );

				// register appender in logger
				logger.removeAllAppenders();
				logger.addAppender( newAppender );

				// Logger can log with debug, but appender should not
				assertTrue( logger.canLog( 4 ) );

				logger.logMessage( "My Unit Test", 4 );

				assertEquals( 0, arrayLen( newAppender.$callLog().logMessage ) );

				newAppender.$( "canLog", true );
				logger.logMessage( "My Unit Test", 1 );

				assertEquals( 1, arrayLen( newAppender.$callLog().logMessage ) );
			} );

			describe( "can do logging with closures and automated canX inclusions", function(){
				beforeEach( function( currentSpec ){
					// MockAppender
					mockAppender = createStub()
						.$( "getName", "MockAppender" )
						.$( "isInitialized", true )
						.$( "canLog", true )
						.$( "getProperty", false )
						.$( "logmessage" );
					logger.addAppender( mockAppender );
				} );

				it( "can log with a valid severity", function(){
					// Test closure in logger
					logger.logMessage( () => "This is a closure message", "info" );
					expect( mockAppender.$callLog().logMessage.first().1.getMessage() ).toBe( "This is a closure message" );
				} );

				it( "won't log with a non-loggable severity", function(){
					logger.setLevelMax( 1 );
					// Test closure in logger
					logger.logMessage( () => "This is a closure message", "debug" );
					expect( mockAppender.$callLog().logmessage ).toBeEmpty();
				} );
			} );
		} );
	}

}
