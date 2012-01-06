component extends="coldbox.system.testing.BaseTestCase"{

	function setup(){
		ormUtil   = getMockBox().createMock("coldbox.system.orm.hibernate.util.CFORMUtil");
		// CF ENGINE MUST HAVE coolblog as a DSN
		dsn = "coolblog";
	}
	
	function testflush(){
		ormutil.flush();
		ormutil.flush( dsn );
	}
	
	function testGetSession(){
		t = ormutil.getSession();
		t = ormutil.getSession( dsn );
	}
	
	function testgetSessionFactory(){
		t = ormutil.getSessionFactory();
		t = ormutil.getSessionFactory( dsn );
	}
	
	function testclearSession(){
		t = ormutil.clearSession();
		t = ormutil.clearSession( dsn );
	}
	
	function testcloseSession(){
		t = ormutil.closeSession();
		t = ormutil.closeSession( dsn );
	}
	
	function testevictQueries(){
		t = ormutil.evictQueries();
		t = ormutil.evictQueries('users');
		t = ormutil.evictQueries('users', dsn );
	}
	
	function testGetEntityDatasource(){
		d = ormutil.getEntityDatasource('User');
		assertEquals('coolblog', d);
		
		d = ormutil.getEntityDatasource( entityNew('User') );
		assertEquals('coolblog', d);
		
		d = ormutil.getEntityDatasource( entityNew('Category') );
		assertEquals('coolblog', d);
	}
	
	function testGetDefaultDatasource(){
		assertEquals('coolblog', ormutil.getDefaultDatasource() );
	}
}