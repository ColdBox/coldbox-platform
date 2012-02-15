<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	function setup(){
		props={to="info@coldboxframework.com,lmajano@gmail.com",from="info@coldboxframework.com",subject="Email Appender Test"};
		
		email = getMockBox().createMock(className="coldbox.system.logging.appenders.EmailAppender");
		email.init('MyEmailAppender',props);
		
		loge = getMockBox().createMock(className="coldbox.system.logging.LogEvent");
		loge.init("this is my awesome unit test sample",5,structnew(),"UnitTest");
	}
	function testLogMessage(){
		loge.setSeverity(3);
		loge.setCategory("coldbox.system.EmailAppenderTest");
		email.logMessage(loge);
		
	}	
</cfscript>
</cfcomponent>