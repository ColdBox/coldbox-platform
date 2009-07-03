<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	function setup(){
		console = getMockBox().createMock(className="coldbox.system.logging.appenders.ConsoleAppender");
		console.init('MyConsoleAppender',5);
	}
	function testLogMessage(){
		for(x=0; x lte 5; x++){
			console.logMessage("I am sending amessage to the console man",x);
		}
	}	
</cfscript>
</cfcomponent>