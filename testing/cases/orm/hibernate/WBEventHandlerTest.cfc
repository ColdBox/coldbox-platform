component extends="coldbox.system.testing.BaseTestCase"{

	function setup(){
		testUserID = '88B73A03-FEFA-935D-AD8036E1B7954B76';
	}
	
	function testInjection(){
		var user = entityLoad("ActiveUser", testUserID, true);
		//debug( user );
		assertTrue( isObject( user.getWireBox() ) );
	}

}