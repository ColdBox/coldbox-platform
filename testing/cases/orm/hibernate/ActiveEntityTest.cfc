component extends="coldbox.system.testing.BaseTestCase"{

	function setup(){
		activeUser = getMockBox().prepareMock( entityNew("ActiveUser") );

		// Test ID's
		testUserID = '88B73A03-FEFA-935D-AD8036E1B7954B76';
		testCatID  = '3A2C516C-41CE-41D3-A9224EA690ED1128';
	}

	function testIsValid(){
		mockWireBox = getMockBox().createMock("coldbox.system.ioc.Injector").init();
		mockWireBox.getBinder().map("WireBoxValidationManager").toValue( new coldbox.system.validation.ValidationManager( mockWireBox ) );

		activeUser.setWireBox( mockWireBox );
		r = activeUser.isValid();
		assertFalse( r );

		activeUser.setFirstName("Luis");
		activeUser.setLastName("Majano");
		activeUser.setUsername("LuisMajano");
		activeUser.setPassword("LuisMajano");
		r = activeUser.isValid();
		assertTrue( r );
	}

	function testValidationResults(){
		r = activeUser.getValidationResults();
		assertTrue( isInstanceOf(r, "coldbox.system.validation.result.IValidationResult") );
	}

	function testNew(){
		//mocks
		mockEventHandler = getMockBox().createEmptyMock("coldbox.system.orm.hibernate.EventHandler");
		mockEventHandler.$("postNew");
		activeUser.$property("ORMEventHandler","variables",mockEventHandler);

		user = activeUser.new();
		assertFalse( isNull(user) );

		user = activeUser.new(properties={firstName="Luis",lastName="UnitTest"});
		assertEquals( "Luis", user.getFirstName() );
	}

	function testGet(){
		user = activeUser.get("123");
		assertTrue( isNull(user) );

		user = activeUser.get(testUserID);
		assertEquals( testUserID, user.getID());
	}

	function testGetAll(){
		r = activeUser.getAll();
		assertTrue( arrayLen(r) );

		r = activeUser.getAll([1,2]);
		assertFalse( arrayLen(r) );

		r = activeUser.getAll(testUserID);
		assertTrue( isObject( r[1] ) );

		r = activeUser.getAll([testUserID,testUserID]);
		assertTrue( isObject( r[1] ) );
	}

	function testSave(){

		//mocks
		mockEventHandler = getMockBox().createEmptyMock("coldbox.system.orm.hibernate.EventHandler");
		mockEventHandler.$("preSave");
		mockEventHandler.$("postSave");

		user = getMockBox().prepareMock( entityNew("ActiveUser") );
		user.$property("ORMEventHandler","variables",mockEventHandler);
		user.setFirstName('unitTest');
		user.setLastName('unitTest');
		user.setUsername('unitTest');
		user.setPassword('unitTest');

		try{
			user.save();
			assertTrue( len(user.getID()) );
			assertTrue( arrayLen(mockEventHandler.$callLog().preSave) );
			assertTrue( arrayLen(mockEventHandler.$callLog().postSave) );
		}
		catch(any e){
			fail(e.detail & e.message);
		}
		finally{
			var q = new Query(datasource="coolblog");
			q.execute(sql="delete from users where firstName = 'unitTest'");
		}
	}

	function testDelete(){
		user = entityNew("ActiveUser");
		user.setFirstName('unitTest');
		user.setLastName('unitTest');
		user.setUsername('unitTest');
		user.setPassword('unitTest');
		entitySave(user);ORMFlush();

		try{
			user.delete();
			test = entityLoad("ActiveUser",{firstName="unittest"}, true);
			assertTrue( isNull(test) );
		}
		catch(any e){
			fail(e.detail & e.message);
		}
		finally{
			q = new Query(datasource="coolblog");
			q.execute(sql="delete from users where firstName = 'unitTest'");
		}
	}

	function testDeleteByID(){
		user = entityNew("ActiveUser");
		user.setFirstName('unitTest');
		user.setLastName('unitTest');
		user.setUsername('unitTest');
		user.setPassword('unitTest');
		entitySave(user); ORMFlush();

		try{
			activeUser.deleteByID( user.getID() );
			test = entityLoad("ActiveUser",{firstName="unittest"}, true);
			assertTrue( isNull(test) );
		}
		catch(any e){
			fail(e.detail & e.message);
		}
		finally{
			q = new Query(datasource="coolblog");
			q.execute(sql="delete from users where firstName = 'unitTest'");
		}
	}

	function testDeleteWhere(){
		for(var x=1; x lte 3; x++){
			user = entityNew("ActiveUser");
			user.setFirstName('unitTest#x#');
			user.setLastName('unitTest');
			user.setUsername('unitTest');
			user.setPassword('unitTest');
			entitySave(user);
		}
		ORMFlush();
		q = new Query(datasource="coolblog");

		try{
			activeUser.deleteWhere(userName="unitTest");

			result = q.execute(sql="select * from users where userName = 'unitTest'");
			assertEquals( 0, result.getResult().recordcount );
		}
		catch(any e){
			fail(e.detail & e.message & e.stackTrace);
		}
		finally{
			q.execute(sql="delete from users where userName = 'unitTest'");
		}
	}

	function testCount(){
		count = activeUser.count();
		assertTrue( count gt 0 );

		count = activeUser.count("firstname='luis'");
		assertEquals(1,  count);

	}

	function testList(){
		test = activeUser.list(sortorder="lastName asc");

		assertTrue( test.recordcount );
	}

	function testFindWhere(){

		test = activeUser.findWhere({firstName="Luis"});
		assertEquals( 'Majano', test.getLastName() );
	}

	function testFindAllWhere(){

		test = activeUser.findAllWhere({firstName="Luis"});
		assertEquals( 1, arrayLen(test) );
	}


	function testGetKey(){

		test = activeUser.getKey(entityName="User");
		assertEquals( 'id', test );
	}

	function testGetPropertyNames(){

		test = activeUser.getPropertyNames(entityName="User");
		assertEquals( 6, arrayLen(test) );
	}

	function testGetTableName(){

		test = activeUser.getTableName();
		assertEquals( 'users', test );
	}

	function testNewCriteria(){
		c = activeUser.newCriteria();
		assertEquals( "ActiveUser", c.getEntityName() );

	}
}