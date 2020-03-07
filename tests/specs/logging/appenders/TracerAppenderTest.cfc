<cfcomponent extends="coldbox.system.testing.BaseModelTest">
	<cfscript>
	function setup(){
		tracer = createMock( className = "coldbox.system.logging.appenders.TracerAppender" );
		tracer.init( "MyCFTracer" );

		loge = createMock( className = "coldbox.system.logging.LogEvent" );
		loge.init(
			"Unit Test Sample",
			0,
			structNew(),
			"UnitTest"
		);
	}

	function testLogMessage(){
		for ( x = 1; x lte 5; x++ ) {
			loge.setSeverity( x );
			loge.setTimestamp( now() );

			tracer.logMessage( loge );
		}
	}
	</cfscript>
</cfcomponent>
