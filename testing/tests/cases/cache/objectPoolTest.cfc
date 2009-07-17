<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	9/3/2007
Description :
	Request service Test
----------------------------------------------------------------------->
<cfcomponent name="requestserviceTest" extends="coldbox.testing.tests.resources.baseMockCase" output="false">

	<cffunction name="setUp" returntype="void" access="public" output="false">
		<cfscript>
		super.setup();
		pool = CreateObject("component","coldbox.system.cache.objectPool").init();
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
	
	<cffunction name="testgetSize" access="public" returntype="void" hint="" output="false" >
		<cfscript>
			
			AssertTrue(pool.getSize() eq 0);
			pool.set('test',now(),0);
			AssertTrue(pool.getSize() eq 1);
		</cfscript>
	</cffunction>
	
	<cffunction name="testgetObjectsKeyList" access="public" returntype="void" hint="" output="false" >
		<cfscript>
			AssertEquals(pool.getObjectsKeyList(), '');
			
			pool.set('test',now(),0);
			pool.set('none',now(),0);
			
			AssertTrue(listLen(pool.getObjectsKeyList()) eq 2);
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
			
			makePublic(pool,"createSoftReference","_createSoftReference");
			makePublic(pool,"isSoftReference","_isSoftReference");
			
			sr = pool._createSoftReference(key,obj);
			
			AssertFalse(pool._isSoftReference(now()));
			AssertTrue(pool._isSoftReference(sr));
			
		</cfscript>
	</cffunction>
	
	
	
</cfcomponent>