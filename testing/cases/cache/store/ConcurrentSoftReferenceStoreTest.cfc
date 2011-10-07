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
		store = getMockBox().createMock(className="coldbox.system.cache.store.ConcurrentSoftReferenceStore").init(mockProvider);
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
	
	function testGetKeys(){
		assertEquals( arrayNew(1), store.getKeys() );
		store.set("test", now() );
		store.set("test1", now() );
		store.set("test2", now() );
		assertEquals( 3 , arrayLen( store.getKeys() ) );
	}
	
	function testLookup(){
		// don't exist
		assertFalse( store.lookup('nada') );
		
		// non sr
		store.set("test",now(),0);
		assertEquals(true, store.lookup("test") );
		
		// store SR
		store.set("test", now(), 10);
		assertEquals(true, store.lookup("test") );
		
		// expired one
		store.set("test", now(), 10);
		store.expireObject("test");
		assertEquals(false, store.lookup("test") );
		
		// expire SR
		store.set("test", now(), 10);
		pool = store.getPool();
		pool["test"].clear();
		assertEquals(false, store.lookup("test") );
	}
	
	function testGet(){
		test = {
			name="luis", created = now()
		};
		// non-sr
		store.set("test",test, 0);
		assertEquals( test, store.get("test") );
		assertEquals( 2, store.getIndexer().getObjectMetadataProperty("test","hits") );
	
		// sr	
		store.set("test",test, 10);
		assertEquals( test, store.get("test") );
		assertEquals( true, store.getIndexer().getObjectMetadataProperty("test","isSoftReference") );
		assertEquals( 2, store.getIndexer().getObjectMetadataProperty("test","hits") );
	}
	
	function testGetQuiet(){
		test = {
			name="luis", created = now()
		};
		// non-sr
		store.set("test",test, 0);
		assertEquals( test, store.getQuiet("test") );
		assertEquals( 1, store.getIndexer().getObjectMetadataProperty("test","hits") );
		
		// sr	
		store.set("test",test, 10);
		assertEquals( test, store.getQuiet("test") );
		assertEquals( true, store.getIndexer().getObjectMetadataProperty("test","isSoftReference") );
		assertEquals( 1, store.getIndexer().getObjectMetadataProperty("test","hits") );
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
		
		//2:Timeout = X
		store.$("createSoftReference","MySoftReference");
		store.set('test',"123",20,20);
		data = store.getPool();
		assertEquals( data['test'], "MySoftReference" );
		
	}
	
	function testClear(){
		
		// non sr
		store.set("test",now(),0);
		results = store.clear('test');
		assertEquals( results, true );
		
		// sr
		store.set("test",now(),10);
		results = store.clear('test');
		assertEquals( results, true );
	}

	function testGetSize(){
		assertTrue(store.getSize() eq 0);
		store.set('test',now(),0);
		assertTrue(store.getSize() eq 1);
	}

	
	function testgetReferenceQueue(){
		AssertEquals( getMetadata(store.getReferenceQueue()).name, "java.lang.ref.ReferenceQueue");
	}	
	
	function testgetSoftRefKeyMap(){
		AssertTrue( isStruct(store.getSoftRefKeyMap()) );
	}
	
	function testgetSoftRefKey(){
		map = {softRef='123'};
		store.$("getSoftRefKeyMap",map);
		assertEquals(map.softRef, store.getSoftRefKey('softRef') );
	}
	
	function testCreateSoftReference(){
		key = "myObj";
		obj = {name="luis",date=now()};
		
		makePublic(store,"createSoftReference");
		
		sr = store.createSoftReference(key,obj);
		
		// Test Reverse Mapping
		AssertTrue(store.softRefLookup(sr));
		refKey = store.getSoftRefKey(sr);
		AssertTrue(refKey eq key);
	}
	
</cfscript>
</cfcomponent>