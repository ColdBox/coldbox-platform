component extends="coldbox.system.testing.BaseModelTest" {

	function setup(){
		logBox  = new coldbox.system.logging.LogBox();
		console = createMock( "coldbox.system.logging.appenders.ConsoleAppender" );
		console.init( "MyConsoleAppender" ).setLogBox( logBox );

		loge = createMock( "coldbox.system.logging.LogEvent" );
		loge.init( "Unit Test Sample", 0, structNew(), "UnitTest" );
	}
	function testLogMessage(){
		for ( x = 0; x lte 1000; x++ ) {
			loge.setSeverity( randRange( 1, 5 ) );
			loge.setCategory( "coldbox.system.testing" );
			loge.setMessage( "Unit testing message (#x#)" );

			console.logMessage( loge );
		}
	}

	function testMockLayout(){
		console = createMock( className = "coldbox.system.logging.appenders.ConsoleAppender" );
		console.init( name = "MyConsoleAppender", layout = "coldbox.tests.specs.logging.MockLayout" );
		console.setLogBox( logBox );

		for ( x = 0; x lte 5; x++ ) {
			loge.setSeverity( x );
			loge.setCategory( "coldbox.system.testing" );
			console.logMessage( loge );
		}
	}

}
