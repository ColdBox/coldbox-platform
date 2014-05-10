<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	function setup(){
		tracer = getMockBox().createMock(className="coldbox.system.logging.appenders.TracerAppender");
		tracer.init('MyCFTracer');
		
		loge = getMockBox().createMock(className="coldbox.system.logging.LogEvent");
		loge.init("Unit Test Sample",0,structnew(),"UnitTest");
	}
	
	function testLogMessage(){
		for(x=1;x lte 5; x++){
			loge.setSeverity(x);
			loge.setTimestamp(now());
			
			tracer.logMessage(loge);
		}
	}	
</cfscript>
</cfcomponent>