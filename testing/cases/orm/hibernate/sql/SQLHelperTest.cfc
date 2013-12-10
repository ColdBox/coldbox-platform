component extends="coldbox.system.testing.BaseTestCase" {

	this.loadColdbox = false;
	
	function beforeTests(){
		super.beforeTests();
		// Load our test injector for ORM entity binding
		new coldbox.system.ioc.Injector(binder="coldbox.testing.cases.orm.hibernate.WireBox");
	}
	
	function setup(){
		criteria   = getMockBox().createMock("coldbox.system.orm.hibernate.CriteriaBuilder");
		criteria.init("User");
		SQLHelper = getMockBox().createMock("coldbox.system.orm.hibernate.sql.SQLHelper");
		SQLHelper.init( criteria );

		// Test ID's
		testUserID = '88B73A03-FEFA-935D-AD8036E1B7954B76';
		testCatID  = '3A2C516C-41CE-41D3-A9224EA690ED1128';
	}
	
	function testLog() {
		SQLHelper.log( "Anything" );
		SQLHelper.log( "Mother" );
		// check that it's an array
		assertIsArray( SQLHelper.getLog() );
		// check that the array is the length we expect
		assertTrue( arrayLen( SQLHelper.getLog() )==2 );
	}
	
	function testGetSQL() {
		criteria.like("lastName","M%");
		// test it returns a string
		assertTrue( isSimpleValue( SQLHelper.getSQL() ) );
		// test it returns non-executable sql
		assertTrue( findNoCase( "?", SQLHelper.getSQL( returnExecutableSql=false ) ) );
		// test it returns executable sql
		assertFalse( findNoCase( "?", SQLHelper.getSQL( returnExecutableSql=true ) ) );
		// test it returns non-formatted sql
		assertFalse( findNoCase( "<pre>", SQLHelper.getSQL( formatSql=false) ) );
		// test it returns formatted sql
		assertTrue( findNoCase( "<pre>", SQLHelper.getSQL( formatSql=true ) ) );
	}
	
	function testApplyFormatting() {
		criteria.like("lastName","M%");
		var sql = SQLHelper.getSql( false, false );
		var formatted = SQLHelper.applyFormatting( sql );
		// test it returns formatted sql
		assertTrue( findNoCase( "<pre>", formatted ) );
	}
	
	function testGetPositionalSQLParameterValues() {
		r = criteria.init("Role")
			.createAlias("users", "u", criteria.INNER_JOIN )
			.like("u.lastName","M%");
		var values = r.getPositionalSQLParameterValues();
		// test it returns an array
		assertIsArray( values );
		// test it returns the number of param values we expect (1)
		assertTrue( arrayLen( values )==1 );
	}
	
	function testGetPositionalSQLParameterTypes() {
		r = criteria.init("Role")
			.createAlias("users", "u", criteria.INNER_JOIN )
			.like("u.lastName","M%");
		var simpletypes = r.getPositionalSQLParameterTypes( true );
		var complexttypes=r.getPositionalSQLParameterTypes( false );
		// test it returns an array
		assertIsArray( simpletypes );
		// test it returns the number of param types we expect (1)
		assertTrue( arrayLen( simpletypes )==1 );
		// if not simple, test that the result is an object
		assertTrue( isObject( complexttypes[ 1 ] ) );
	}
	
	function testGetPositionalSQLParameters() {
		r = criteria.init("Role")
			.createAlias("users", "u", criteria.INNER_JOIN )
			.like("u.lastName","M%");
		var params = r.getPositionalSQLParameters();
		// test it returns an array
		assertIsArray( params );
		// test it returns the number of param types we expect (1)
		assertTrue( arrayLen( params )==1 );
	}
	
	function testGenerateSQLAlias() {
        assertTrue( isSimpleValue( SQLHelper.generateSQLAlias() ) );
    }
    
    function testGetRootSQLAlias() {
        assertTrue( isSimpleValue( SQLHelper.getRootSQLAlias() ) );
    }

    function testGetProjectedTypes() {
    	criteria.withProjections( count="id" );
        assertIsArray( SQLHelper.getProjectedTypes() );
    }
	
	function testGetProjectionAlias() {
		criteria.withProjections( count="id" );
		assertEquals( SQLHelper.getProjectionAlias(), "id" );
	}
	
	function testCanLogLimitOffset() {
        assertTrue( isBoolean( SQLHelper.canLogLimitOffset() ) );
    }
	
	function testGetDialect() {
        assertEquals( getMetaData( SQLHelper.getDialect() ).getSuperClass().getName(), "org.hibernate.dialect.Dialect" );
    }
	
	function testGetQueryParameters() {
		criteria.like("lastName","M%");
		makePublic( SQLHelper, "getQueryParameters" );
		
		assertTrue( isInstanceOf( SQLHelper.getQueryParameters(), "org.hibernate.engine.QueryParameters" ) );
	}
	
	function testReplaceQueryParameters() {
		criteria.like("lastName","M%");
		var sql = criteria.getSQL( false, false );
		makePublic( SQLHelper, "replaceQueryParameters" );
		replaced = SQLHelper.replaceQueryParameters( sql );
		// prove that old value had query param
		assertTrue( findNoCase( "?", sql ) );
		// test it returns a string
		assertTrue( isSimpleValue( replaced ) );
		// test it returns executable sql
		assertFalse( findNoCase( "?", replaced ) );
    }
	
	function testBindLimitParameters() {
		criteria.like("lastName","M%");
		criteria.list( max=10, offset=2 );
		// make public
		makePublic( SQLHelper, "convertToCFArray" );
		makePublic( SQLHelper, "getQueryParameters" );
		makePublic( SQLHelper, "bindLimitParameters" );
		params = SQLHelper.getQueryParameters();
		selection = params.getRowSelection();
		// run method
		var test1 = SQLHelper.bindLimitParameters( SQLHelper.convertToCFArray( params.getPositionalParameterValues() ), false, selection );
		// max/limit will be prepended
		assertTrue( test1[1]==2 );
		assertTrue( test1[2]==10 );
		
		var test2 = SQLHelper.bindLimitParameters( SQLHelper.convertToCFArray( params.getPositionalParameterValues() ), true, selection );
		// max/limit will be appended
		assertTrue( test2[2]==2 );
		assertTrue( test2[3]==10 );
	}
	
	function testUseLimit() {
		makePublic( SQLHelper, "useLimit" );
		makePublic( SQLHelper, "getQueryParameters" );
		assertTrue( isBoolean( SQLHelper.useLimit( SQLHelper.getQueryParameters().getRowSelection() ) ) );
	}
	
	function testHasMaxRows() {
		makePublic( SQLHelper, "hasMaxRows" );
		makePublic( SQLHelper, "getQueryParameters" );
		assertTrue( isBoolean( SQLHelper.hasMaxRows( SQLHelper.getQueryParameters().getRowSelection() ) ) );
	}
	
	function testGetFirstRow() {
		criteria.like("lastName","M%");
		criteria.list( max=10, offset=2 );
		makePublic( SQLHelper, "getFirstRow" );
		makePublic( SQLHelper, "getQueryParameters" );
		assertTrue( isNumeric( SQLHelper.getFirstRow( SQLHelper.getQueryParameters().getRowSelection() ) ) );
	}
	
	function testGetMaxOrLimit() {
		criteria.like("lastName","M%");
		criteria.list( max=10, offset=2 );
		makePublic( SQLHelper, "getMaxOrLimit" );
		makePublic( SQLHelper, "getQueryParameters" );
		assertTrue( isNumeric( SQLHelper.getMaxOrLimit( SQLHelper.getQueryParameters().getRowSelection() ) ) );
	}   

    function testGetCriteriaJoinWalker() {
        makePublic( SQLHelper, "getCriteriaJoinWalker" );
        assertTrue( getMetaData( SQLHelper.getCriteriaJoinWalker() ).getName()=="org.hibernate.loader.criteria.CriteriaJoinWalker" );
    }
    
    function testGetCriteriaQueryTranslator() {
        makePublic( SQLHelper, "getCriteriaQueryTranslator" );
        assertTrue( getMetaData( SQLHelper.getCriteriaQueryTranslator() ).getName()=="org.hibernate.loader.criteria.CriteriaQueryTranslator" );
    } 
}