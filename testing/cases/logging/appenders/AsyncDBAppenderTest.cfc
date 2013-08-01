<cfcomponent extends="coldbox.testing.cases.logging.appenders.DBAppenderTest">
<cfscript>
	function setup(){
		props = {dsn='coolblog',table='logs',autocreate='true'};
		db = getMockBox().createMock(className="coldbox.system.logging.appenders.AsyncDBAppender");
		db.init('AsyncDBAppender',props);
		
		loge = getMockBox().createMock(className="coldbox.system.logging.LogEvent");
		loge.init("Unit Test Sample",0,structnew(),"UnitTest");
	}
	
</cfscript>
</cfcomponent>