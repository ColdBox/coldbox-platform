<cfcomponent extends="coldbox.system.testing.BaseModelTest">
	<cfscript>
	function setup(){
		mockLB = createMock( className = "coldbox.system.logging.LogBox", clearMethods = true );
		logger = createMock( "coldbox.system.logging.Logger" );
		rootLogger = createMock( "coldbox.system.logging.Logger" ).init( "ROOT" );
		logger.logLevels = createMock( "coldbox.system.logging.LogLevels" );

		// init Logger
		logger.init( category = "coldbox.system.logging.UnitTest" );
		logger.setRootLogger( rootLogger );
	}

	function testCanMethods(){
		logger.setLevelMin( 0 );
		logger.setLevelMax( 3 );

		assertTrue( logger.canFatal() );
		assertTrue( logger.canError() );
		assertTrue( logger.canWarn() );
		assertTrue( logger.canInfo() );
		assertFalse( logger.canDebug() );
	}

	function testCanWithValues(){
		logger.setLevelMin( 0 );
		logger.setLevelMax( 3 );

		assertTrue( logger.canLog( "fatal" ) );
		assertTrue( logger.canLog( 1 ) );
		// Invalid level should not log
		assertFalse( logger.canLog( "asdfasfdsd" ) );
	}


	function testAppenderMethods(){
		// has appenders
		assertFalse( logger.hasAppenders() );
		// get appenders
		assertEquals( logger.getAppenders(), structNew() );
		// appender Add
		newAppender = createObject( "component", "coldbox.system.logging.appenders.ConsoleAppender" ).init(
			"MyConsoleAppender"
		);
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
	}

	function testAppenderLoggingLevels(){
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
	}
	</cfscript>
</cfcomponent>
