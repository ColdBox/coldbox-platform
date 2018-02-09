﻿<cfcomponent extends="coldbox.system.testing.BaseModelTest">
<cfscript>
	this.loadColdBox = false;

	function setup(){
		props = {dsn='coolblog',table='logs',autocreate='true'};
		db = createMock(className="coldbox.system.logging.appenders.DBAppender" );
		db.init('UnitTest',props);
		
		loge = createMock(className="coldbox.system.logging.LogEvent" );
		loge.init( "Unit Test Sample",0,structnew(),"UnitTest" );
	}

	function testSchema(){
		assertTrue( len( db.getProperty('schema') ) eq 0 );
		props = {dsn='coolblog',table='logs',autocreate='true', schema="test" };
		db.init( 'UnitTest', props );
		assertTrue( len( db.getProperty('schema') ) );
	}
	
	function testEnsureTable(){
		// drop table
		new Query( datasource="coolblog", sql="drop table logs" ).execute();
		makePublic(db,"ensureTable" );
		db.ensureTable();
		var r = new Query( datasource="coolblog", sql="check table logs" ).execute().getResult();
		assertEquals( r.msg_text, "ok" );
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
		catch( "DBAppender.InvalidColumnMapException" e){}
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