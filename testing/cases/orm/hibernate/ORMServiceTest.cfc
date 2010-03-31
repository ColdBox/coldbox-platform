component extends="coldbox.system.testing.BaseTestCase"{

	function setup(){
		ormservice = getMockBox().createMock("coldbox.system.orm.hibernate.ORMService");
		// Mocks
		ormservice.init();
		
		testUserID = '88B73A03-FEFA-935D-AD8036E1B7954B76';
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
		stats = ormservice.getSessionStatistics();
		assertEquals( 0, stats.entityCount );
		assertEquals( 0, stats.collectionCount );
		assertEquals( '[]', stats.entityKeys );
		assertEquals( '[]', stats.collectionKeys );
	}
	
	function testIsDirty(){
		assertFalse( ormservice.isDirty() );
		test = entityLoad("User",{firstName="Luis"},true);
		test.setPassword('unit_tests');
		assertTrue(ormService.isDirty());
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
		ormservice.new("User");
	}
	
	function testGet(){
		user = ormService.get("User");
		assertFalse( len(user.getID()) );
		user = ormService.get("User",testUserID);
		assertEquals( testUserID, user.getID());
	}
	
	function testGetByCriteria(){
		test = ormservice.getByCriteria("Category",{category="general"});
		assertEquals( 'general', test.getCategory() );
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
	
	
	
}