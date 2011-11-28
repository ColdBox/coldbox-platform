<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	function setup(){
		prop = {username="",password="",logType="status"};
		twitter = getMockBox().createMock(className="coldbox.system.logging.appenders.TwitterAppender");
		twitter.init('MyScoketAppender',prop);
		
		loge = getMockBox().createMock(className="coldbox.system.logging.LogEvent");
		loge.init(message="I am logging an information message from LogBox to my twitter status.",severity=twitter.logLevels.INFO,extraInfo=structnew(),category="coldbox.testing.logging");
	}
	
	function testLogMessage(){
		twitter.logMessage(loge);		
	}	
</cfscript>
</cfcomponent>