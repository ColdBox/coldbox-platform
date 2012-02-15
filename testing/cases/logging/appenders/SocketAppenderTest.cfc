<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	function setup(){
		
		prop = {host="localhost",timeout="3",port="80",persistConnection=false};
		socket = getMockBox().createMock(className="coldbox.system.logging.appenders.SocketAppender");
		socket.init('MyScoketAppender',prop);
		
		loge = getMockBox().createMock(className="coldbox.system.logging.LogEvent");
		loge.init("Unit Test Sample",0,structnew(),"UnitTest");		
	}
	
	function testLogMessage(){
		for(x=1;x lte 5; x++){
			loge.setSeverity(x);
			loge.setTimestamp(now());
			
			socket.logMessage(loge);
		}
	}	
</cfscript>
</cfcomponent>