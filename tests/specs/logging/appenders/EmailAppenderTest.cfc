component extends="coldbox.system.testing.BaseModelTest" {

	function setup(){
		logBox = new coldbox.system.logging.LogBox();
		props  = {
			to      : "info@coldboxframework.com,automation@coldbox.org",
			from    : "info@coldboxframework.com",
			subject : "Email Appender Test"
		};

		email = createMock( className = "coldbox.system.logging.appenders.EmailAppender" );
		email.init( "MyEmailAppender", props ).setLogBox( logBox );

		loge = createMock( className = "coldbox.system.logging.LogEvent" );
		loge.init(
			"this is my awesome unit test sample",
			5,
			structNew(),
			"UnitTest"
		);
	}
	function testLogMessage(){
		loge.setSeverity( 3 );
		loge.setCategory( "coldbox.system.EmailAppenderTest" );
		email.logMessage( loge );
	}

}
