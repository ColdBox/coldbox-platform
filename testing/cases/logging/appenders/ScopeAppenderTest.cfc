<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	function setup(){
		prop = {limit=2};
		scope = getMockBox().createMock(className="coldbox.system.logging.appenders.ScopeAppender");
		scope.init('MyScopeLogger',0,5,prop);
	}
	
	function testLogMessage(){
		scope.logMessage("Unit Test Sample",3);
		scope.logMessage("Application Test Sample",0,3, structnew());
		scope.logMessage("Unit Test Sample",3);
		
		debug(request);
		assertEquals( arrayLen(request["MyScopeLogger"]), 2);
	}	
</cfscript>
</cfcomponent>