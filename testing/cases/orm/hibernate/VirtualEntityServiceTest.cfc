component extends="coldbox.system.testing.BaseTestCase"{

	function setup(){
		ormservice = getMockBox().createMock("coldbox.system.orm.hibernate.VirtualEntityService");
		// Mocks
		ormservice.init("User");

		// Test ID's
		testUserID = '88B73A03-FEFA-935D-AD8036E1B7954B76';
		testCatID  = '3A2C516C-41CE-41D3-A9224EA690ED1128';
	}

	
	function testNew(){
		//mocks
		mockEventHandler = getMockBox().createEmptyMock("coldbox.system.orm.hibernate.EventHandler");
		mockEventHandler.$("postNew");
		ormService.$property("ORMEventHandler","variables",mockEventHandler);
		
		user = ormservice.new();
		assertFalse( isNull(user) );
		
		user = ormService.new(properties={firstName="Luis",lastName="UnitTest"});
		assertEquals( "Luis", user.getFirstName() );
	}

	function testGet(){
		user = ormService.get("123");
		assertTrue( isNull(user) );

		user = ormService.get(testUserID);
		assertEquals( testUserID, user.getID());
	}
	
	function testGetAll(){
		r = ormService.getAll();
		assertTrue( arrayLen(r) );
		
		r = ormService.getAll([1,2]);
		assertFalse( arrayLen(r) );

		r = ormService.getAll(testUserID);
		assertTrue( isObject( r[1] ) );

		r = ormService.getAll([testUserID,testUserID]);
		assertTrue( isObject( r[1] ) );
	}

	function testDeleteByID(){
		user = entityNew("User");
		user.setFirstName('unitTest');
		user.setLastName('unitTest');
		user.setUsername('unitTest');
		user.setPassword('unitTest');
		entitySave(user); ORMFlush();

		try{
			ormservice.deleteByID( user.getID() );
			test = entityLoad("User",{firstName="unittest"}, true);
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
			user = entityNew("User");
			user.setFirstName('unitTest#x#');
			user.setLastName('unitTest');
			user.setUsername('unitTest');
			user.setPassword('unitTest');
			entitySave(user); 
		}
		ORMFlush();
		q = new Query(datasource="coolblog");

		try{
			ormService.deleteWhere(userName="unitTest");

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
		count = ormService.count();
		assertTrue( count gt 0 );

		count = ormService.count("firstname='luis'");
		assertEquals(1,  count);

	}

	function testList(){
		test = ormservice.list(sortorder="lastName asc");

		assertTrue( test.recordcount );
	}

	function testFindWhere(){

		test = ormservice.findWhere({firstName="Luis"});
		assertEquals( 'Majano', test.getLastName() );
	}

	function testFindAllWhere(){

		test = ormservice.findAllWhere({firstName="Luis"});
		assertEquals( 1, arrayLen(test) );
	}


	function testGetKey(){

		test = ormservice.getKey(entityName="User");
		assertEquals( 'id', test );
	}

	function testGetPropertyNames(){

		test = ormservice.getPropertyNames(entityName="User");
		assertEquals( 6, arrayLen(test) );
	}

	function testGetTableName(){

		test = ormservice.getTableName();
		assertEquals( 'users', test );
	}
	
	function testNewCriteria(){
		c = ormservice.newCriteria();
		assertEquals( "User", c.getEntityName() );
		
	}
}