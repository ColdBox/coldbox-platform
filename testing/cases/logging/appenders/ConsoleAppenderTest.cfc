<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	function setup(){
		console = getMockBox().createMock(className="coldbox.system.logging.appenders.ConsoleAppender");
		console.init('MyConsoleAppender');
		
		loge = getMockBox().createMock(className="coldbox.system.logging.LogEvent");
		loge.init("Unit Test Sample",0,structnew(),"UnitTest");
	}
	function testLogMessage(){
		for(x=0; x lte 5; x++){
			loge.setSeverity(x);
			loge.setCategory("coldbox.system.testing");
			console.logMessage(loge);
		}
	}	
	
	function testMockLayout(){
		console = getMockBox().createMock(className="coldbox.system.logging.appenders.ConsoleAppender");
		console.init(name='MyConsoleAppender',layout="coldbox.testing.cases.logging.MockLayout");
		
		for(x=0; x lte 5; x++){
			loge.setSeverity(x);
			loge.setCategory("coldbox.system.testing");
			console.logMessage(loge);
		}
		
	}
</cfscript>
</cfcomponent>