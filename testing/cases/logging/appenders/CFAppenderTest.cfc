<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	function setup(){
		cf = getMockBox().createMock(className="coldbox.system.logging.appenders.CFAppender");
		cf.init('MyCFLogger',0,5);
		
		loge = getMockBox().createMock(className="coldbox.system.logging.LogEvent");
		loge.init("Unit Test Sample",0,structnew(),"UnitTest");
	}
	
	function testLogMessage(){
		cf.logMessage(loge);
		props = {logType="application"};
		cf.init('MyCFLogger',0,5,props);
		cf.logMessage(loge);
	}	
</cfscript>
</cfcomponent>