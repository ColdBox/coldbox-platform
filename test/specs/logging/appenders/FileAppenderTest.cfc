<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	function setup(){
		props = {filePath=expandPath("/coldbox/testing/cases/logging/tmp"),autoExpand=false};
		debug(props);
		fileappender = getMockBox().createMock(className="coldbox.system.logging.appenders.FileAppender");
		
		// mock LogBox
		logBox = getMockBox().createMock(classname="coldbox.system.logging.LogBox",clearMethod=true);
		fileAppender.logBox = logBox;
		
		fileappender.init('MyFileAppender',props);
		
		loge = getMockBox().createMock(className="coldbox.system.logging.LogEvent");
		loge.init("Unit Test Sample",0,"","UnitTest");
	}
	function testOnRegistration(){
		fileAppender.onRegistration();	
	}
	function testLogMessage(){
		for(x=0; x lte 5; x++){
			loge.setSeverity(x);
			loge.setCategory("coldbox.system.testing");
			fileappender.logMessage(loge);
		}
	}	
</cfscript>
</cfcomponent>