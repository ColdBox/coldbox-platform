<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	9/3/2007
Description :
	object pool test
----------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>

	function setup(){
		config = {
			autoExpandPath = true
			//directoryPath  = "/coldbox/testing/cacheDepot"
		};
		mockProvider = getMockBox().createMock("coldbox.system.cache.providers.MockProvider");
		mockProvider.$("getConfiguration", config);
		
		try{
			store = getMockBox().createMock(className="coldbox.system.cache.store.DiskStore").init(mockProvider);
			fail("this should have failed");
		}
		catch("DiskStore.InvalidConfigurationException" e){}
		catch(any e){ fail(e); }
		
		
		// good directory
		config.directoryPath = "/coldbox/testing/cacheDepot";
		store = getMockBox().createMock(className="coldbox.system.cache.store.DiskStore").init(mockProvider);
	}
	
	function tearDown(){
		if( structKeyExists(variables,"store") ){
			store.clearAll();
		}
	}
	
	function testClearAll(){
		store.set("test", now(), 20);
		assertEquals( 1, store.getSize() );
		store.clearAll();
		assertEquals( 0, store.getSize() );
	}
	
	function testGetIndexer(){
		AssertTrue( isObject(store.getIndexer()) );
	}
	
	function testGetKeys(){
		assertEquals( arrayNew(1), store.getKeys() );
		store.set("test", now() );
		store.set("test1", now() );
		store.set("test2", now() );
		assertEquals( 3 , arrayLen( store.getKeys() ) );
	}
	
	function testLookup(){
		assertFalse( store.lookup('nada') );
		
		store.set("myKey","hello");
		
		assertTrue( store.lookup('myKey') );
		
		store.getIndexer().setObjectMetadataProperty("myKey","isExpired",true);
		
		assertFalse( store.lookup('myKey') );
	}
	
	function testGet(){
		store.set("myKey","123");
		assertEquals( store.get('myKey'), "123" );
	}
	
	function testGetQuiet(){
		store.set("myKey","123",0);
		assertEquals( store.getQuiet('myKey'), "123" );
	}
	
	function testExpirations(){
		store.set("test", now());
		assertFalse( store.isExpired("test") );
		store.expireObject("test");
		assertTrue( store.isExpired("test") );
	}
	
	function testSet(){
		//1:Timeout = 0 (Eternal)
		store.set('test',"123",0,0);
		assertEquals( 0, store.getIndexer().getObjectMetadataProperty("test","timeout") );
		assertEquals("123", store.get("test") );
		
		//2:Timeout = X
		store.set('test',"123",20,20);
		assertEquals( 20, store.getIndexer().getObjectMetadataProperty("test","timeout") );
		assertEquals("123", store.get("test") );
	}
	
	function testClear(){
		
		assertFalse( store.clear('invalid') );
		
		store.set("test", now(), 20);
		results = store.clear('test');
		assertTrue( results );
	}

	function testGetSize(){
		assertTrue(store.getSize() eq 0);
		store.set('test',now(),0);
		assertTrue(store.getSize() eq 1);
	}
	
</cfscript>
</cfcomponent>