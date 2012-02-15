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
			dsn   = "cacheTest",
			table = "cacheBox"
		};
		mockProvider = getMockBox().createMock("coldbox.system.cache.providers.MockProvider");
		mockProvider.$("getConfiguration", config);
		store = getMockBox().createMock(className="coldbox.system.cache.store.JDBCStore").init(mockProvider);
	}
	
	function tearDown(){
		//store.clearAll();
	}
	
	function testClearAll(){
		store.clearAll();
		store.set("test", now(), 20);
		assertEquals( 1, store.getSize() );
		store.clearAll();
		assertEquals( 0, store.getSize() );
	}
	
	function testGetIndexer(){
		AssertTrue( isObject(store.getIndexer()) );
	}
	
	function testGetKeys(){
		store.clearAll();
		assertEquals( arrayNew(1), store.getKeys() );
		store.set("test", now() );
		store.set("test1", now() );
		store.set("test2", now() );
		assertEquals( 3 , arrayLen( store.getKeys() ) );
	}
	
	function testLookup(){
		store.clearAll();
		assertFalse( store.lookup('nada') );
		
		store.set("myKey","hello");
		
		assertTrue( store.lookup('myKey') );
		
		store.expireObject("myKey");
		
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
		assertEquals("123", store.get("test") );
		
		//2:Timeout = X
		store.set('test',"123",20,20);
		assertEquals("123", store.get("test") );
		
		//3 complex
		complex = createObject("component", "coldbox.testing.testmodel.formBean").init();
		store.set('test', complex, 20);
		results = store.get("test");
		assertEquals(complex, results );
		debug(results);
	}
	
	function testClear(){
		
		assertFalse( store.clear('invalid') );
		
		store.set("test", now(), 20);
		results = store.clear('test');
		
		assertTrue( results );
	}

	function testGetSize(){
		store.clearAll();
		assertTrue(store.getSize() eq 0);
		store.set('test',now(),0);
		assertTrue(store.getSize() eq 1);
	}
	
</cfscript>
</cfcomponent>