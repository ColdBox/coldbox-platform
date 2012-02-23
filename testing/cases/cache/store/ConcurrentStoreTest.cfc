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
		mockProvider = getMockBox().createMock("coldbox.system.cache.providers.MockProvider");
		store = getMockBox().createMock(className="coldbox.system.cache.store.ConcurrentStore").init(mockProvider);
	}
	
	function testClearAll(){
		store.set("test", now(), 20);
		assertEquals( 1, store.getSize() );
		store.clearAll();
		assertEquals( 0, store.getSize() );
	}

	function testGetPool(){
		AssertTrue( isStruct(store.getpool()) );
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
		map = {myKey="123"};
		store.$property("pool","instance",map);
		
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
		data = store.getPool();
		assertEquals( data['test'], "123" );
		assertEquals( 0, store.getIndexer().getObjectMetadataProperty("test","timeout") );
		
		//2:Timeout = X
		store.set('test',"123",20,20);
		data = store.getPool();
		assertEquals( data['test'], "123" );
		assertEquals( 20, store.getIndexer().getObjectMetadataProperty("test","timeout") );
	}
	
	function testSetEternals(){
		obj = {name='luis',date=now()};
		key = "myObj";
		
		store.set(key,obj,0);
		AssertSame( store.get(key), obj);
		
		AssertTrue(store.lookup(key) );
		AssertFalse(store.lookup('nothing') );
		
		assertEquals( 0, store.getIndexer().getObjectMetadataProperty( key,"timeout") );
		assertEquals( 2, store.getIndexer().getObjectMetadataProperty(key,"hits") );
		assertEquals( false, store.getIndexer().getObjectMetadataProperty(key,"isExpired") );
		assertEquals( '', store.getIndexer().getObjectMetadataProperty(key,"LastAccessTimeout") );
		AssertTrue( isDate(store.getIndexer().getObjectMetadataProperty(key,'Created')) );
		AssertTrue( isDate(store.getIndexer().getObjectMetadataProperty(key,'LastAccesed')) );
		
		store.clear( key );
		AssertFalse(store.lookup(key) );
	}
	
	function testClear(){
		map = {test='test'};
		map2 = duplicate(map);
		debug(map2);
		
		store.$property("pool","instance",map);			

		map = {test = '123' };
		store.$property("pool","instance",map);
		
		results = store.clear('test');
		
		debug( store.$callLog() );
		assertEquals( results, true );
		assertTrue( structIsEmpty(map) );
		
	}

	function testGetSize(){
		assertTrue(store.getSize() eq 0);
		store.set('test',now(),0);
		assertTrue(store.getSize() eq 1);
	}
	
</cfscript>
</cfcomponent>