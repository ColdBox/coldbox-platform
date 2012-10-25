component extends="coldbox.system.testing.BaseTestCase"{
	this.loadColdBox = false;
	function setup(){
		factory   = getMockBox().createMock("coldbox.system.orm.hibernate.util.ORMUtilFactory");
	}
	
	function testAdobe(){
		factory.$("getPlatform","ColdFusion Server");
		u = factory.getORMUtil();
		assertEquals('coldbox.system.orm.hibernate.util.CFORMUtil', getMetadata(u).name );
	}
	
	function testOther(){
		factory.$("getPlatform","Railo");
		u = factory.getORMUtil();
		assertEquals('coldbox.system.orm.hibernate.util.ORMUtil', getMetadata(u).name );
	}
}