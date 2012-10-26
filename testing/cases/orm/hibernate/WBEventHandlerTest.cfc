component extends="coldbox.system.testing.BaseTestCase"{
	this.loadColdBox = false;
	
	function beforeTests(){
		super.beforeTests();
		// Load our test injector for ORM entity binding
		new coldbox.system.ioc.Injector(binder="coldbox.testing.cases.orm.hibernate.WireBox");
	}
	
	function setup(){
		testUserID = '88B73A03-FEFA-935D-AD8036E1B7954B76';
	}
	
	function testInjection(){
		var user = entityLoad("ActiveUser", testUserID, true);
		//debug( user );
		assertTrue( isObject( user.getWireBox() ) );
	}

}