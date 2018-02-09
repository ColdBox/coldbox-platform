<cfcomponent extends="coldbox.system.testing.BaseModelTest">
<cfscript>
	function setup(){
		cf = createMock(className="coldbox.system.logging.appenders.CFAppender" );
		cf.init('MyCFLogger');
		
		loge = createMock(className="coldbox.system.logging.LogEvent" );
		loge.init( "Unit Test Sample",0,structnew(),"UnitTest" );
	}
	
	function testLogMessage(){
		cf.logMessage(loge);
		props = {logType="application" };
		cf.init('MyCFLogger',props);
		cf.logMessage(loge);
	}	
</cfscript>
</cfcomponent>