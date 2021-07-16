component extends="coldbox.system.testing.BaseModelTest" {

	function setup(){
		logBox = new coldbox.system.logging.LogBox();
		tracer = createMock( className = "coldbox.system.logging.appenders.TracerAppender" );
		tracer.init( "MyCFTracer" ).setLogBox( logBox );

		loge = createMock( className = "coldbox.system.logging.LogEvent" );
		loge.init( "Unit Test Sample", 0, structNew(), "UnitTest" );
	}

	function testLogMessage(){
		for ( x = 1; x lte 5; x++ ) {
			loge.setSeverity( x );
			loge.setTimestamp( now() );

			tracer.logMessage( loge );
		}
	}

}
