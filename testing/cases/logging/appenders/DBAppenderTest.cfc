<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	function setup(){
		props = {dsn='testmssql',table='logs',autocreate='true'};
		db = getMockBox().createMock(className="coldbox.system.logging.appenders.DBAppender");
		db.init('UnitTest',0,5,props);
	}
	
	function testensureDSN(){
		makePublic(db,"ensureDSN");
		db.ensureDSN();
		
		// invalid
		props.dsn = 'invalid';
		db.init('UnitTest',0,5,props);
		try{
			db.ensureDSN();
			fail('invalid dsn');
		}
		catch("DBLogger.DSNException" e){}
		catch(Any e){ fail(e.message & e.detail);}
	}
	
	function testEnsureTable(){
		makePublic(db,"ensureTable");
		db.ensureTable();
	}
	
	function testLogMessage(){
		db.logMessage("My First Test",1);
	}
	function testLogMessageWithColumnMap(){
		//invalid map
		props.columnmap = {
			id = "id",
			severity = "severity",
			category = "category",
			logdate = "logdate",
			loggername = "loggername",
			messsage = "message"
		};
		
		try{
			db.init('UnitTest',0,5,props);
			fail('map should have failed');
		}
		catch("DBLogger.InvalidColumnMapException" e){}
		catch(any e ){fail(e.message & e.detail);}
		
		//valid map
		props.columnmap = {
			id = "id",
			severity = "severity",
			category = "category",
			logdate = "logdate",
			loggername = "loggername",
			message = "message"
		};
		
		db.init('UnitTest',0,5,props);
			
		db.logMessage(message="My First Test",severity=1);
	}
</cfscript>
</cfcomponent>