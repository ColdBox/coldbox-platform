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
	
	function testGetPoolMetadata(){
		AssertTrue( isStruct(store.getPoolMetadata()) );
	}
	
	function testGetKeys(){
		assertEquals( arrayNew(1), store.getKeys() );
		store.set("test", now() );
		store.set("test1", now() );
		store.set("test2", now() );
		assertEquals( 3 , arrayLen( store.getKeys() ) );
	}
	
	function testObjectsMetadataProperties(){
		key = "oMyObj";
		metadata = {hits=1,lastAccessed=now(),created=now(),timeout=0,isExpired=false};
		
		store.setObjectMetadata(key,metadata);
		AssertEquals(store.getObjectMetadata(key), metadata);
		
		AssertEquals(store.getMetadataProperty(key,'hits'),1);
		store.setMetadataProperty(key,"hits",40);
		AssertEquals(store.getMetadataProperty(key,'hits'),40);
	}
	
	function testLookup(){
		assertFalse( store.lookup('nada') );
		map = {myKey="hello"};
		md  = {myKey={isExpired=false}};
		
		store.$property("pool","instance",map);
		store.$property("poolMetadata","instance",md);
		
		assertTrue( store.lookup('myKey') );
		
		md.myKey.isExpired=true;
		
		assertFalse( store.lookup('myKey') );
	}
	
	function testGet(){
		store.$("setMetadataProperty");
		map = {myKey="123"};
		store.$property("pool","instance",map);
		
		store.$("getMetadataProperty",0);
		assertEquals( store.get('myKey'), "123" );
		assertEquals( store.$count('setMetadataProperty'), 2);
	}
	
	function testExpirations(){
		store.set("test", now());
		assertFalse( store.isExpired("test") );
		store.expireObject("test");
		assertTrue( store.isExpired("test") );
	}
	
	function testSet(){
		store.$("setObjectMetaData");
			
		//1:Timeout = 0 (Eternal)
		store.set('test',"123",0,0);
		assertEquals( store.getPool()['test'], "123" );
		assertEquals(store.$count('setObjectMetaData'),1);
		
		//2:Timeout = X
		store.set('test',"123",20,20);
		assertEquals( store.getPool()['test'], "123" );
		assertEquals(store.$count('setObjectMetaData'),2);
	}
	
	function testSetEternals(){
		obj = {name='luis',date=now()};
		key = "myObj";
		
		store.set(key,obj,0);
		AssertSame( store.get(key), obj);
		
		AssertTrue(store.lookup(key) );
		AssertFalse(store.lookup('nothing') );
		
		AssertEquals(store.getMetadataProperty(key,'Timeout'),0);
		AssertEquals(store.getMetadataProperty(key,'hits'),2);
		AssertEquals(false, store.getMetadataProperty(key,'isExpired'));
		AssertEquals(store.getMetadataProperty(key,'LastAccessTimeout'),'');
		AssertTrue( isDate(store.getMetadataProperty(key,'Created')) );
		AssertTrue( isDate(store.getMetadataProperty(key,'LastAccesed')) );
		
		store.clear( key );
		AssertFalse(store.lookup(key) );
		
		try{
			store.getObjectMetadata(key);
			Fail("This method should have failed.");
		}
		catch(Any e){
			
		}	
	
	}
	
	function testClear(){
		map = {'test'='test'};
		map2 = duplicate(map);
		debug(map2);
		
		store.$property("pool","instance",map);			

		map = {'test' = '123' };
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