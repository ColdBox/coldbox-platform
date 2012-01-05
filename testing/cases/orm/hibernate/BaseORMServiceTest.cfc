component extends="coldbox.system.testing.BaseTestCase"{

	function setup(){
		ormservice   = getMockBox().createMock("coldbox.system.orm.hibernate.BaseORMService");
		mockEH = getMockBox().createEmptyMock("coldbox.system.orm.hibernate.EventHandler");

		// Mocks
		ormservice.init();

		// Mock event handler
		ormservice.$property("ORMEventHandler","variables",mockEH);

		// Test ID's
		testUserID = '88B73A03-FEFA-935D-AD8036E1B7954B76';
		testCatID  = '3A2C516C-41CE-41D3-A9224EA690ED1128';
		test2 = ["1","2"];
	}

	function testExists(){
		assertEquals( false, ormservice.exists("Category", "123") );
		assertEquals( true, ormservice.exists("Category", testCatID) );

	}

	function testClear(){
		test = entityLoad("User");
		stats = ormservice.getSessionStatistics();
		debug(stats);

		ormservice.clear();

		stats = ormservice.getSessionStatistics();
		assertEquals( 0, stats.entityCount );
	}

	function testGetSessionStatistics(){
		ormservice.clear();
		stats = ormservice.getSessionStatistics();
		assertEquals( 0, stats.entityCount );
		assertEquals( 0, stats.collectionCount );
		assertEquals( '[]', stats.entityKeys );
		assertEquals( '[]', stats.collectionKeys );
	}

	function testisSessionDirty(){
		assertFalse( ormservice.isSessionDirty() );
		test = entityLoad("User",{firstName="Luis"},true);
		test.setPassword('unit_tests');
		assertTrue(ormService.isSessionDirty());
		ORMClearSession();
	}

	function testSessionContains(){
		assertFalse( ormservice.sessionContains( entityNew("User") ));
		test = entityLoad("User",{firstName="Luis"},true);
		assertTrue( ormservice.sessionContains( test ));
		ORMEvictEntity("user");
		assertFalse( ormservice.sessionContains( entityNew("User") ));
	}

	function testNew(){
		//mocks
		mockEventHandler = getMockBox().createEmptyMock("coldbox.system.orm.hibernate.EventHandler");
		mockEventHandler.$("postNew");
		ormService.$property("ORMEventHandler","variables",mockEventHandler);

		ormservice.new("User");

		// Test with arguments.
		user = ormService.new(entityName="User",properties={firstName="luis",lastName="majano"});
		debug(user);
		assertEquals( "luis", user.getFirstName() );
		assertEquals( "majano", user.getLastName() );

		assertTrue( arrayLen(mockEventHandler.$callLog().postNew) );
	}

	function testNewWithProperties(){
		//mocks
		mockEventHandler = getMockBox().createEmptyMock("coldbox.system.orm.hibernate.EventHandler");
		mockEventHandler.$("postNew");
		ormService.$property("ORMEventHandler","variables",mockEventHandler);
		// Test Porperties
		user = ormService.new("User",{firstName="pio",lastName="majano"});
		debug(user);
		assertEquals( "pio", user.getFirstName() );
		assertEquals( "majano", user.getLastName() );
	}

	function testNewWithEvents(){
		//mocks
		mockEventHandler = getMockBox().createEmptyMock("coldbox.system.orm.hibernate.EventHandler");
		mockEventHandler.$("postNew");
		ormService.setEventHandling( true );
		ormService.$property("ORMEventHandler","variables",mockEventHandler);

		// Call it
		ormservice.new("User");

		assertTrue( arrayLen(mockEventHandler.$callLog().postNew) );
	}

	function testGet(){
		//mocks
		mockEventHandler = getMockBox().createEmptyMock("coldbox.system.orm.hibernate.EventHandler");
		mockEventHandler.$("postNew");
		ormService.$property("ORMEventHandler","variables",mockEventHandler);

		user = ormService.get("User","123");
		assertTrue( isNull(user) );

		user = ormService.get("User",testUserID);
		assertEquals( testUserID, user.getID());

		user = ormService.get("User",0);
		assertTrue( isNull( user.getID() ) );

		user = ormService.get("User",'');
		assertTrue( isNull( user.getID() ) );
		
		// ReturnNew = false
		user = ormService.get(entityName="User",id=4,returnNew=false);
		assertTrue( isNull( user ) );
		user = ormService.get(entityName="User",id=0,returnNew=false);
		assertTrue( isNull( user ) );
	}
	function testGetAll(){
		r = ormService.getAll('Category');
		assertTrue( arrayLen(r) );

		r = ormService.getAll('Category',"A13C0DB0-0CBC-4D85-A5261F2E3FCBEF91","category");
		assertTrue( arraylen( r ) eq 1 );
		
		r = ormService.getAll('Category',[1,2]);
		assertFalse( arraylen( r ) );

		r = ormService.getAll('Category',testCatID);
		assertTrue( isObject( r[1] ) );

		r = ormService.getAll('Category',[testCatID,testCatID]);
		assertTrue( isObject( r[1] ) );
		
		r = ormService.getAll(entityName='Category',sortOrder="category desc");
		assertTrue( arrayLen(r) );

	}

	function testDelete(){
		cat = entityNew("Category");
		cat.setCategory('unitTest');
		cat.setDescription('unitTest');
		entitySave(cat);ORMFlush();

		try{
			test = entityLoad("Category",{category="unittest"}, true);
			//debug(test);
			ormservice.delete( test );
			test = entityLoad("Category",{category="unittest"}, true);
			assertTrue( isNull(test) );
		}
		catch(any e){
			fail(e.detail & e.message);
		}
		finally{
			q = new Query(datasource="coolblog");
			q.execute(sql="delete from categories where category = 'unitTest'");
		}
	}

	function testDeleteByID(){
		cat = entityNew("Category");
		cat.setCategory('unitTest');
		cat.setDescription('unitTest');
		entitySave(cat);ORMFlush();

		try{
			count=ormservice.deleteByID( "Category", cat.getCatID() );
			debug(count);
			test = entityLoad("Category",{category="unittest"}, true);
			assertTrue( isNull(test) );
		}
		catch(any e){
			fail(e.detail & e.message);
		}
		finally{
			q = new Query(datasource="coolblog");
			q.execute(sql="delete from categories where category = 'unitTest'");
		}
	}

	function testDeleteByQuery(){
		for(var x=1; x lte 3; x++){
			cat = entityNew("Category");
			cat.setCategory('unitTest');
			cat.setDescription('unitTest at #now()#');
			entitySave(cat);
		}
		ORMFlush();
		q = new Query(datasource="coolblog");

		try{
			ormservice.deleteByQuery(query="from Category where category = :category",params={category='unitTest'});
			result = q.execute(sql="select * from categories where category = 'unitTest'");
			assertEquals( 0, result.getResult().recordcount );
		}
		catch(any e){
			fail(e.detail & e.message);
		}
		finally{
			q.execute(sql="delete from categories where category = 'unitTest'");
		}
	}

	function testDeleteWhere(){
		for(var x=1; x lte 3; x++){
			cat = entityNew("Category");
			cat.setCategory('unitTest');
			cat.setDescription('unitTest at #now()#');
			entitySave(cat);
		}
		ORMFlush();
		q = new Query(datasource="coolblog");

		try{
			count=ormService.deleteWhere(entityName="Category",category="unitTest");
			debug(count);

			result = q.execute(sql="select * from categories where category = 'unitTest'");
			assertEquals( 0, result.getResult().recordcount );
		}
		catch(any e){
			fail(e.detail & e.message);
		}
		finally{
			q.execute(sql="delete from categories where category = 'unitTest'");
		}
	}

	function testSave(){

		//mocks
		mockEventHandler = getMockBox().createEmptyMock("coldbox.system.orm.hibernate.EventHandler");
		mockEventHandler.$("preSave");
		mockEventHandler.$("postSave");
		ormService.$property("ORMEventHandler","variables",mockEventHandler);

		cat = entityNew("Category");
		cat.setCategory('unitTest');
		cat.setDescription('unitTest at #now()#');

		try{
			ormservice.save( cat );
			assertTrue( len(cat.getCatID()) );
			assertTrue( arrayLen(mockEventHandler.$callLog().preSave) );
			assertTrue( arrayLen(mockEventHandler.$callLog().postSave) );
		}
		catch(any e){
			fail(e.detail & e.message);
		}
		finally{
			var q = new Query(datasource="coolblog");
			q.execute(sql="delete from categories where category = 'unitTest'");
		}
	}
	
	function testSaveNoTransaction(){

		//mocks
		mockEventHandler = getMockBox().createEmptyMock("coldbox.system.orm.hibernate.EventHandler");
		mockEventHandler.$("preSave");
		mockEventHandler.$("postSave");
		ormService.$property("ORMEventHandler","variables",mockEventHandler);

		cat = entityNew("Category");
		cat.setCategory('unitTest');
		cat.setDescription('unitTest at #now()#');

		try{
			ormservice.save(entity=cat,transactional=false);
			assertTrue( len(cat.getCatID()) );
			assertTrue( arrayLen(mockEventHandler.$callLog().preSave) );
			assertTrue( arrayLen(mockEventHandler.$callLog().postSave) );
			var q = new Query(datasource="coolblog");
			var result = q.execute(sql="select * from categories where category = 'unitTest'").getResult();
			assertTrue( result.recordcount eq 0 ); 
		}
		catch(any e){
			fail(e.detail & e.message);
		}
	}
	
	function testSaveAll(){

		//mocks
		mockEventHandler = getMockBox().createEmptyMock("coldbox.system.orm.hibernate.EventHandler");
		mockEventHandler.$("preSave").$("postSave");
		ormService.$property("ORMEventHandler","variables",mockEventHandler);

		cat = entityNew("Category");
		cat.setCategory('unitTest');
		cat.setDescription('unitTest at #now()#');
		
		cat2 = entityNew("Category");
		cat2.setCategory("unitTest");
		cat2.setDescription('unitTest at #now()#');

		try{
			ormservice.saveAll( [cat,cat2] );
			assertTrue( len(cat.getCatID()) );
			assertTrue( len(cat2.getCatID()) );
			assertTrue( arrayLen(mockEventHandler.$callLog().preSave) );
			assertTrue( arrayLen(mockEventHandler.$callLog().postSave) );
		}
		catch(any e){
			fail(e.detail & e.message);
		}
		finally{
			var q = new Query(datasource="coolblog");
			q.execute(sql="delete from categories where category = 'unitTest'");
		}
	}

	function testRefresh(){
		cat = entityLoad("Category",{category="Training"},true);
		id = cat.getCatID();
		originalDescription = cat.getDescription();

		try{
			var q = new Query(datasource="coolblog");
			q.execute(sql="update categories set description = 'unittest' where category_id = '#id#'");

			ormservice.refresh( cat );

			assertEquals( "unittest" , cat.getDescription() );
		}
		catch(any e){
			fail(e.detail & e.message);
		}
		finally{
			var q = new Query(datasource="coolblog");
			q.execute(sql="update categories set description = '#originalDescription#' where category_id = '#id#'");
		}
	}

	function testCount(){
		count = ormService.count("Category");
		assertTrue( count gt 0 );

		count = ormService.count("Category","category='general'");
		assertEquals(2,  count);

		count = ormService.count("Category","category=?",['Training']);
		assertEquals(1,  count);

		count = ormService.count("Category","category=:category",{category="Training"});
		assertEquals(1,  count);

		count = ormService.count("Category","category like 'gen%'");
		assertEquals(2,  count);

		count = ormService.countWhere(entityName="Category",category="Training");
		assertEquals(1,  count);
	}

	function testList(){
		criteria = {category="general"};
		test = ormservice.list(entityName="Category",sortorder="category asc",criteria=criteria);
		assertTrue( test.recordcount );
	
		// as array
		ormservice.setDefaultAsQuery( false );
		test = ormservice.list(entityName="Category",sortorder="category asc",criteria=criteria);
		assertTrue( arrayLen( test ) );
			
	}

	function testExecuteQuery(){
		test = ormservice.executeQuery(query="from Category");
		debug(test);
		assertTrue( test.recordcount );

		params = ["general"];
		test = ormservice.executeQuery(query="from Category where category = ?",params=params);
		assertTrue( test.recordcount );
	}

	function testFind(){

		test = ormservice.findit("from Category where category = ?",['Training']);
		assertEquals( 'Training', test.getCategory() );

		test = ormservice.findit("from Category where category = :category",{category="Training"});
		assertEquals( 'Training', test.getCategory() );

		sample = entityLoad("Category",{category="Training"},true);
		test = ormService.findit(example=sample);
		assertEquals( 'Training', test.getCategory() );
	}

	function testFindByExample(){
		sample = entityLoad("Category",{category="Training"},true);	
		test = ormService.findByExample(sample,true);
		assertEquals( 'Training', test.getCategory() );	
		
		sample = entityLoad("Category",{category="Training"},true);	
		test = ormService.findByExample(sample);
		//debug(test);
		assertEquals( 'Training', test[1].getCategory() );	
	}
	
	function testFindAll(){

		test = ormservice.findAll("from Category where category = ?",['Training']);
		assertEquals( 1, arrayLen(test) );

		test = ormservice.findAll("from Category where category = :category",{category="Training"});
		assertEquals( 1, arrayLen(test) );

		sample = entityLoad("Category",{category="Training"},true);
		test = ormService.findAll(example=sample);
		assertEquals( 1, arrayLen(test) );

		test = ormService.findAll(query="from Category",max=2,offset=1);
		assertEquals( 2, arrayLen(test) );

	}

	function testFindWhere(){

		test = ormservice.findWhere("Category",{category="Training"});
		assertEquals( 'Training', test.getCategory() );

		test = ormservice.findWhere("User",{ firstName="Luis", lastName="Majano"});
		assertEquals( 'Majano', test.getLastName() );
	}

	function testFindAllWhere(){

		test = ormservice.findAllWhere("Category",{category="general"});
		assertEquals( 2, arrayLen(test) );
		
		test = ormservice.findAllWhere("Category",{category="general"},"category desc");
		assertEquals( 2, arrayLen(test) );

		test = ormservice.findAllWhere("User",{firstName="Luis", lastName="Majano"});
		assertEquals( 1, arrayLen(test) );
	}


	function testGetKey(){

		test = ormservice.getKey(entityName="Category");
		assertEquals( 'catid', test );

		test = ormservice.getKey(entityName="User");
		assertEquals( 'id', test );
	}

	function testGetPropertyNames(){

		test = ormservice.getPropertyNames(entityName="Category");
		assertEquals( 3, arrayLen(test) );

		test = ormservice.getPropertyNames(entityName="User");
		assertEquals( 6, arrayLen(test) );
	}

	function testGetTableName(){

		test = ormservice.getTableName(entityName="Category");
		assertEquals( 'categories', test );

		test = ormservice.getTableName(entityName="User");
		assertEquals( 'users', test );
	}

	function testConvertIDValueToJavaType(){

		test = ormservice.convertIDValueToJavaType(entityName="User",id=1);
		assertEquals( [1], test );

		test = ormservice.convertIDValueToJavaType(entityName="User",id=["1","2","3"]);
		assertEquals( [1,2,3], test );
	}

	function testCreateService(){

		UserService = ormservice.CreateService(entityName="User");
		CategoryService = ormservice.CreateService(entityName="Category");

		test = UserService.getKey();
		assertEquals( 'id', test );

		test=UserService.getTableName();
		assertEquals( 'users', test );

		test = CategoryService.getKey();
		assertEquals( 'catid', test );

		test=CategoryService.getTableName();
		assertEquals( 'categories', test );
	}
	
	function testgetEntityGivenName(){
		// loaded entity
		test = entityLoad("User",{firstName="Luis"},true);
		r = ormservice.getEntityGivenName( test );
		//debug( r );
		assertEquals( "User", r );
		
		r = ormservice.getEntityGivenName( entityNew("User") );
		//debug( r );
		assertEquals( "User", r );		
	}
	
	function testNewCriteria(){
		c = ormservice.newCriteria("User");
		
	}
}