﻿<cfcomponent extends="coldbox.system.testing.BaseModelTest">
<cfscript>
	function setup(){
		prop = {limit=2};
		scope = createMock(className="coldbox.system.logging.appenders.ScopeAppender" );
		scope.init('MyScopeLogger',prop);
		
		loge = createMock(className="coldbox.system.logging.LogEvent" );
		loge.init( "Unit Test Sample",0,structnew(),"UnitTest" );
	}
	
	function testLogMessage(){
		scope.logMessage(loge);
		scope.logMessage(loge);
		scope.logMessage(loge);
		
		// debug(request);
		assertEquals( arrayLen(request[ "MyScopeLogger" ]), 2);
	}	
</cfscript>
</cfcomponent>