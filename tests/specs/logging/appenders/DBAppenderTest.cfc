component extends="coldbox.system.testing.BaseModelTest" {

	this.loadColdBox = false;

	function setup(){
		logBox = new coldbox.system.logging.LogBox();
		props  = { dsn : "coolblog", table : "logs", autocreate : "true" };

		db = createMock( "coldbox.system.logging.appenders.DBAppender" )
			.init( "DBAppender", props )
			.setLogBox( logBox );

		loge = createMock( "coldbox.system.logging.LogEvent" ).init(
			"Unit Test Sample",
			0,
			structNew(),
			"DBAppender"
		);
	}

	function testSchema(){
		assertTrue( len( db.getProperty( "schema" ) ) eq 0 );
		props = {
			dsn        : "coolblog",
			table      : "logs",
			autocreate : "true",
			schema     : "test"
		};
		db.init( "UnitTest", props );
		assertTrue( len( db.getProperty( "schema" ) ) );
	}

	function testEnsureTable(){
		// drop table
		new Query( datasource = "coolblog", sql = "drop table logs" ).execute();
		makePublic( db, "ensureTable" );
		db.ensureTable();
		var r = new Query( datasource = "coolblog", sql = "check table logs" ).execute().getResult();
		assertEquals( r.msg_text, "ok" );
	}

	function testLogMessage(){
		db.logMessage( loge );
	}

	function testLogMessageWithColumnMap(){
		// Test with invalid map, where defaults should be used
		props.columnmap = {
			id           : "id",
			severity     : "severity",
			category     : "category",
			logdate      : "logdate",
			appendername : "appendername",
			messsage     : "message",
			extrainfo    : "extrainfo"
		};

		db.init( "UnitTest", props );

		// valid map
		props.columnmap = {
			id           : "id",
			severity     : "severity",
			category     : "category",
			logdate      : "logdate",
			appendername : "appendername",
			message      : "message",
			extrainfo    : "extrainfo"
		};

		db.init( "UnitTest", props );

		db.logMessage( loge );
	}

}
