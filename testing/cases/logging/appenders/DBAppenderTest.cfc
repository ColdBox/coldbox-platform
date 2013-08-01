<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	function setup(){
		props = {dsn='coolblog',table='logs',autocreate='true'};
		db = getMockBox().createMock(className="coldbox.system.logging.appenders.DBAppender");
		db.init('UnitTest',props);
		
		loge = getMockBox().createMock(className="coldbox.system.logging.LogEvent");
		loge.init("Unit Test Sample",0,structnew(),"UnitTest");
	}
	
	function testEnsureTable(){
		makePublic(db,"ensureTable");
		db.ensureTable();
	}
	
	function testLogMessage(){
		db.logMessage(loge);
	}
	function testLogMessageWithColumnMap(){
		//invalid map
		props.columnmap = {
			id = "id",
			severity = "severity",
			category = "category",
			logdate = "logdate",
			appendername = "appendername",
			messsage = "message",
			extrainfo = "extrainfo"
		};
		
		try{
			db.init('UnitTest',props);
			fail('map should have failed');
		}
		catch("DBAppender.InvalidColumnMapException" e){}
		catch(any e ){fail(e.message & e.detail);}
		
		//valid map
		props.columnmap = {
			id = "id",
			severity = "severity",
			category = "category",
			logdate = "logdate",
			appendername = "appendername",
			message = "message",
			extrainfo = "extrainfo"
		};
		
		db.init('UnitTest',props);
			
		db.logMessage(loge);
	}
</cfscript>
</cfcomponent>