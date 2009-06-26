<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	9/3/2007
Description :
	object pool test
----------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.testing.BaseTestCase" output="false">

	<cffunction name="setUp" returntype="void" access="public" output="false">
		<cfscript>
		pool = getMockBox().createMock(className="coldbox.system.cache.ObjectPool").init();
		</cfscript>
	</cffunction>
	
	<cffunction name="testgetReferenceQueue" access="public" returntype="void" hint="" output="false" >
		<cfscript>
			AssertEquals( getMetadata(pool.getReferenceQueue()).name, "java.lang.ref.ReferenceQueue");
		</cfscript>
	</cffunction>
	
	<cffunction name="testgetSoftRefKeyMap" access="public" returntype="void" hint="" output="false" >
		<cfscript>
			AssertTrue( isStruct(pool.getSoftRefKeyMap()) );
		</cfscript>
	</cffunction>
	
	<cffunction name="testgetSoftRefKey">
		<cfscript>
			/*1: not found */
			pool.$("getSoftRefKeyMap",structnew());
			assertEquals( pool.getSoftRefKey('nada'), "NOT_FOUND" );
			
			//2: Found
			map = {softRef='123'};
			pool.$("getSoftRefKeyMap",map);
			assertEquals(map.softRef, pool.getSoftRefKey('softRef') );
			
		</cfscript>
	</cffunction>
	
	<cffunction name="testgetpool" access="public" returntype="void" hint="" output="false" >
		<cfscript>
			AssertTrue( isStruct(pool.getpool()) );
		</cfscript>
	</cffunction>
	
	<cffunction name="testgetpoolMD" access="public" returntype="void" hint="" output="false" >
		<cfscript>
			AssertTrue( isStruct(pool.getpool_metadata()) );
		</cfscript>
	</cffunction>
	
	
	<cffunction name="testObjectsMetadataProperties" access="public" returntype="void" hint="" output="false" >
		<cfscript>
			key = "oMyObj";
			metadata = {hits=1,lastAccessed=now(),created=now(),timeout=0};
			
			pool.setObjectMetadata(key,metadata);
			AssertEquals(pool.getObjectMetadata(key), metadata);
			
			AssertEquals(pool.getMetadataProperty(key,'hits'),1);
			pool.setMetadataProperty(key,"hits",40);
			AssertEquals(pool.getMetadataProperty(key,'hits'),40);
			
		</cfscript>
	</cffunction>
	
	<cffunction name="testLookup">
		<cfscript>
			assertFalse( pool.lookup('nada') );
			map = {myKey="hello"};
			
			makePublic(pool,"setPool");
			pool.setPool(map);
			assertTrue( pool.lookup('myKey') );
		</cfscript>
	</cffunction>
	
	<cffunction name="testGet">
		<cfscript>
			makePublic(pool,"setPool");
			pool.$("setMetadataProperty");
			map = {myKey="123"};
			pool.setPool(map);
			
			//1: non soft reference
			pool.$("getMetadataProperty",0);
			pool.$("isSoftReference",false);
			assertEquals( pool.get('myKey'), "123" );
			assertEquals( pool.$count('setMetadataProperty'), 2);
			
			//2: soft reference
			pool.$("isSoftReference",true);
			/* Mock Soft Reference Stub */
			stub = getMockBox().createStub();
			stub.$("get","123");
			map.myKey = stub;
			
			assertEquals( pool.get('myKey'), "123" );
			assertEquals( pool.$count('setMetadataProperty'), 4);
		</cfscript>
	</cffunction>
	
	<cffunction name="testSet">
		<cfscript>
			pool.$("setObjectMetaData");
			
			//1:Timeout = 0 (Eternal)
			pool.set('test',"123",0,0);
			assertEquals( pool.getPool()['test'], "123" );
			assertEquals(pool.$count('setObjectMetaData'),1);
			
			//2:Timeout = X
			pool.$("createSoftReference","MySoftReference");
			pool.set('test',"123",20,20);
			assertEquals( pool.getPool()['test'], "MySoftReference" );
			assertEquals(pool.$count('setObjectMetaData'),2);
			
		</cfscript>
	</cffunction>
	
	<cffunction name="testEternals" access="public" returntype="void" hint="" output="false" >
		<cfscript>
			obj = {name='luis',date=now()};
			key = "myObj";
			
			pool.set(key,obj,0);
			AssertSame( pool.get(key), obj);
			
			AssertTrue(pool.lookup(key) );
			AssertFalse(pool.lookup('nothing') );
			
			AssertEquals(pool.getMetadataProperty(key,'Timeout'),0);
			AssertEquals(pool.getMetadataProperty(key,'hits'),2);
			AssertEquals(pool.getMetadataProperty(key,'LastAccessTimeout'),'');
			AssertTrue( isDate(pool.getMetadataProperty(key,'Created')) );
			AssertTrue( isDate(pool.getMetadataProperty(key,'LastAccesed')) );
			

			pool.clearKey(key);
			AssertFalse(pool.lookup(key) );
			
			try{
				pool.getObjectMetadata(key);
				Fail("This method should have failed.");
			}
			catch(Any e){
				
			}			
		</cfscript>
	</cffunction>
	
	<cffunction name="testSoftReferences" access="public" returntype="void" hint="" output="false" >
		<cfscript>
			obj = {name='luis',date=now()};
			key = "myObj";
			
			pool.set(key,obj,30,10);
			AssertSame( pool.get(key), obj);
			
			AssertTrue(pool.lookup(key) );
			AssertFalse(pool.lookup('nothing') );
			
			AssertEquals(pool.getMetadataProperty(key,'Timeout'),30);
			AssertEquals(pool.getMetadataProperty(key,'hits'),2);
			AssertEquals(pool.getMetadataProperty(key,'LastAccessTimeout'),10);
			AssertTrue( isDate(pool.getMetadataProperty(key,'Created')) );
			AssertTrue( isDate(pool.getMetadataProperty(key,'LastAccesed')) );

			pool.clearKey(key);
			AssertFalse(pool.lookup(key) );
			
			try{
				pool.getObjectMetadata(key);
				Fail("This method should have failed.");
			}
			catch(Any e){
				
			}			
		</cfscript>
	</cffunction>
	
	<cffunction name="testClearKey">
		<cfscript>
			makePublic(pool,"setPool");
			map = {'test'='test'};
			map2 = duplicate(map);
			debug(map2);
			pool.setPool(map);			
			pool.$("getSoftRefKeyMap",map2);
			
			//1: softReference
			pool.$("isSoftReference",true);
			results = pool.clearKey('test');
			debug( pool.$callLog() );
			assertEquals( results, true );
			assertTrue( structIsEmpty(map) );
			assertTrue( structIsEmpty(map2) );
			
			//2: Not soft reference
			pool.$("isSoftReference",false);
			map = {'test' = '123' };
			pool.setPool(map);
			results = pool.clearKey('test');
			debug( pool.$callLog() );
			assertEquals( results, true );
			assertTrue( structIsEmpty(map) );
			
			
		</cfscript>
	</cffunction>
	
	<cffunction name="testgetSize" access="public" returntype="void" hint="" output="false" >
		<cfscript>
			assertTrue(pool.getSize() eq 0);
			pool.set('test',now(),0);
			assertTrue(pool.getSize() eq 1);
		</cfscript>
	</cffunction>
	
	<cffunction name="testgetObjectsKeyList" access="public" returntype="void" hint="" output="false" >
		<cfscript>
			assertEquals(pool.getObjectsKeyList(), '');
			
			pool.set('test',now(),0);
			pool.set('none',now(),0);
			
			assertTrue(listLen(pool.getObjectsKeyList()) eq 2);
		</cfscript>
	</cffunction>
	
	<cffunction name="testCreateSoftReference" access="public" returntype="void" hint="" output="false" >
		<cfscript>
			key = "myObj";
			obj = {name="luis",date=now()};
			
			makePublic(pool,"createSoftReference","_createSoftReference");
			
			sr = pool._createSoftReference(key,obj);
			
			/* Test Reverse Mapping */
			AssertTrue(pool.softRefLookup(sr));
			refKey = pool.getSoftRefKey(sr);
			AssertTrue(refKey eq key);
					
		</cfscript>
	</cffunction>
	
	<cffunction name="testisSoftReference" access="public" returntype="void" hint="" output="false" >
		<cfscript>
			key = "myObj";
			obj = {name="luis",date=now()};
			
			makePublic(pool,"createSoftReference");
			makePublic(pool,"isSoftReference");
			
			sr = pool.createSoftReference(key,obj);
			
			AssertFalse(pool.isSoftReference(now()));
			AssertTrue(pool.isSoftReference(sr));
			
		</cfscript>
	</cffunction>
	
	
	
</cfcomponent>