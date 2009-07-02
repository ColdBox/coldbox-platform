<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	function setup(){
		prop = {limit=2};
		scope = getMockBox().createMock(className="coldbox.system.logging.loggers.ScopeLogger");
		scope.init('MyScopeLogger',5,prop);
	}
	
	function testLogMessage(){
		scope.logMessage("Unit Test Sample",3);
		scope.logMessage("Application Test Sample",3, structnew());
		scope.logMessage("Unit Test Sample",3);
		
		debug(request);
		assertEquals( arrayLen(request["MyScopeLogger"]), 2);
	}	
</cfscript>
</cfcomponent>