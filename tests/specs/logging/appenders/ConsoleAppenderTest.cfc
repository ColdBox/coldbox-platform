component extends = "coldbox.system.testing.BaseModelTest"{
	function setup(){
		logBox  = new coldbox.system.logging.LogBox();
		console = createMock( className = "coldbox.system.logging.appenders.ConsoleAppender" );
		console.init( "MyConsoleAppender" ).setLogBox( logBox );

		loge = createMock( className = "coldbox.system.logging.LogEvent" );
		loge.init(
			"Unit Test Sample",
			0,
			structNew(),
			"UnitTest"
		);
	}
	function testLogMessage(){
		for ( x = 0; x lte 5; x++ ) {
			loge.setSeverity( x );
			loge.setCategory( "coldbox.system.testing" );
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
