component extends="coldbox.system.testing.BaseTestCase"{
	this.loadColdBox = false;
	
	function beforeTests(){
		super.beforeTests();
		// Load our test injector for ORM entity binding
		new coldbox.system.ioc.Injector(binder="coldbox.testing.cases.orm.hibernate.WireBox");
	}
	
	function setup(){
		activeUser = getMockBox().prepareMock( entityNew("ActiveUser") );

		// Test ID's
		testUserID = '88B73A03-FEFA-935D-AD8036E1B7954B76';
		testCatID  = '3A2C516C-41CE-41D3-A9224EA690ED1128';
	}
	
	function testCountByDynamically(){
		// Test simple Equals
		t = activeUser.countByLastName("majano");
		assert( 1 eq t, "CountBylastName" );
		
	}
	function testFindByDynamically(){
		// Test simple Equals
		t = activeUser.findByLastName("majano");
		assert( isObject( t ), "FindBylastName" );
		// Test simple Equals with invalid
		t = activeUser.findByLastName("d");
		assert( isNull( t ), "Invalid last name" );
		// Using Conditionals
		t = activeUser.findAllByLastNameLessThanEquals( "Majano" );
		assert( arraylen( t ) , "Conditionals LessThanEquals");
		t = activeUser.findAllByLastNameLessThan( "Majano" );
		assert( arraylen( t ) , "Conditionals LessThan");
		t = activeUser.findAllByLastNameGreaterThan( "Majano" );
		assert( arraylen( t ) , "Conditionals GreaterThan");
		t = activeUser.findAllByLastNameGreaterThanEquals( "Majano" );
		assert( arraylen( t ) , "Conditionals GreaterThanEqauls");
		t = activeUser.findByLastNameLike( "ma%" );
		assert( isObject( t ) , "Conditionals Like");
		t = activeUser.findAllByLastNameNotEqual( "Majano" );
		assert( arrayLen( t ) , "Conditionals Equal");
		t = activeUser.findByLastNameIsNull();
		assert( isNull( t ) , "Conditionals isNull");
		t = activeUser.findAllByLastNameIsNotNull();
		assert( arrayLen( t ) , "Conditionals isNull");
		t = activeUser.findAllByLastLoginBetween( "01/01/2009", "01/01/2012");
		assert( arrayLen( t ) , "Conditionals between");
		t = activeUser.findByLastLoginBetween( "01/01/2008", "11/01/2008");
		assert( isNull( t ) , "Conditionals between");
		t = activeUser.findByLastLoginNotBetween( "01/01/2009", "01/01/2012");
		assert( isNull( t ) , "Conditionals not between");
		t = activeUser.findAllByLastNameInList( "Majano,Fernando");
		assert( arrayLen( t ) , "Conditionals inList");
		t = activeUser.findAllByLastNameInList( listToArray(  "Majano,Fernando" ));
		assert( arrayLen( t ) , "Conditionals inList");
		t = activeUser.findAllByLastNameNotInList( listToArray(  "Majano,Fernando" ));
		assert( arrayLen( t ) , "Conditionals NotinList");
	}	
	
	function testFindByDynamicallyBadProperty(){
		expectException("BaseORMService.InvalidEntityProperty");
		t = activeUser.findByLastAndFirst();
	}	
	
	function testFindByDynamicallyFailure(){
		expectException("BaseORMService.HQLQueryException");
		t = activeUser.findByLastName();
	}

	function testIsValid(){
		mockWireBox = getMockBox().createMock("coldbox.system.ioc.Injector").init();
		mockValidationManager = new coldbox.system.validation.ValidationManager();
		mockValidationManager.setResourceBundle('');
		mockValidationManager.setWireBox( mockWireBox );
		mockWireBox.getBinder().map("WireBoxValidationManager").toValue( mockValidationManager );

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