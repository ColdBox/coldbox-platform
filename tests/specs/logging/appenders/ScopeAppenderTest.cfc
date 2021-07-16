component extends="coldbox.system.testing.BaseModelTest" {

	function setup(){
		logBox = new coldbox.system.logging.LogBox();
		prop   = { limit : 2 };
		scope  = createMock( className = "coldbox.system.logging.appenders.ScopeAppender" );
		scope.init( "MyScopeLogger", prop ).setLogBox( logBox );

		loge = createMock( className = "coldbox.system.logging.LogEvent" );
		loge.init( "Unit Test Sample", 0, structNew(), "UnitTest" );
	}

	function testLogMessage(){
		scope.logMessage( loge );
		scope.logMessage( loge );
		scope.logMessage( loge );

		// debug(request);
		assertEquals( arrayLen( request[ "MyScopeLogger" ] ), 2 );
	}

}
