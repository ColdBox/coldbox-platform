component extends="coldbox.system.testing.BaseTestCase"{

	function setup(){
		ormUtil   = getMockBox().createMock("coldbox.system.orm.hibernate.util.ORMUtil");
	}
	
	function testflush(){
		ormutil.flush();
	}
	
	function testGetSession(){
		t = ormutil.getSession();
	}
	
	function testgetSessionFactory(){
		t = ormutil.getSessionFactory();
	}
	
	function testclearSession(){
		t = ormutil.clearSession();
	}
	
	function testcloseSession(){
		t = ormutil.closeSession();
	}
	
	function testevictQueries(){
		t = ormutil.evictQueries();
		t = ormutil.evictQueries('users');
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