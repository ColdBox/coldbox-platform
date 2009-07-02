<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	function setup(){
		cf = getMockBox().createMock(className="coldbox.system.logging.loggers.CFLogger");
		cf.init('MyCFLogger',5);
	}
	
	function testLogMessage(){
		cf.logMessage("Unit Test Sample",3);
		props = {logType="application"};
		cf.init('MyCFLogger',5,props);
		cf.logMessage("Application Test Sample",3);
	}	
</cfscript>
</cfcomponent>