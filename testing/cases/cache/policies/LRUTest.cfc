<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	9/3/2007
Description :
	Request service Test
----------------------------------------------------------------------->
<cfcomponent name="LRUTest" extends="AbstractPolicyTest" output="false">

	<cffunction name="setUp" returntype="void" access="public" output="false">
		<cfscript>
		super.setup();
		
		config = {
			evictCount = 2
		};
		
		pool['obj1'] = structnew();
		pool['obj2'] = structnew();
		pool['obj3'] = structnew();
		
		pool['obj1'].Created = now();
		pool['obj1'].LastAccesed = now();
		pool['obj1'].Timeout = 5;
		pool['obj1'].isExpired = false;
		pool['obj1'].hits = 999;
		
		pool['obj2'].Created = dateAdd("n",-15,now());
		pool['obj2'].LastAccesed = dateAdd("n",-14,now());
		pool['obj2'].Timeout = 10;
		pool['obj2'].isExpired = false;
		pool['obj2'].hits = 555;
		
		pool['obj3'].Created = dateAdd("n",-15,now());
		pool['obj3'].LastAccesed = dateAdd("n",-7,now());
		pool['obj3'].Timeout = 10;
		pool['obj3'].isExpired = false;
		pool['obj3'].hits = 111;
		
		mockCM.$("getConfiguration",config);
		mockIndexer.$("getPoolMetadata", pool).$("objectExists",true);
		keys = structSort(pool,"numeric","asc","lastAccesed");
		mockIndexer.$("getSortedKeys", keys);
		mockIndexer.$("getObjectMetadata").$results(pool.obj2,pool.obj3,pool.obj1);
		
		lru = getMockBox().createMock("coldbox.system.cache.policies.LRU").init(mockCM);
		</cfscript>
	</cffunction>
	
	<cffunction name="testPolicy" access="public" returntype="void" hint="" output="false" >
		<cfscript>
			lru.execute();	
			debug( mockLogger.$callLog() );
			assertEquals(2, arrayLen(mockCM.$callLog().expireObject) );		
			assertEquals( "obj2", mockCM.$callLog().expireObject[1][1] );		
		</cfscript>
	</cffunction>
	
</cfcomponent>