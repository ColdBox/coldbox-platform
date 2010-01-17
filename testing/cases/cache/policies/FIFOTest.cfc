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
<cfcomponent extends="AbstractPolicyTest" output="false">

	<cffunction name="setUp" returntype="void" access="public" output="false">
		<cfscript>
		
		super.setup();
		
		fifo = createObject("component","coldbox.system.cache.policies.FIFO").init(mockCM);		
		</cfscript>
	</cffunction>
	
	<cffunction name="testPolicy" access="public" returntype="void" hint="" output="false" >
		<cfscript>
			pool['obj1'] = structnew();
			pool['obj2'] = structnew();
			pool['obj3'] = structnew();
			
			pool['obj1'].Created = now();
			pool['obj1'].Timeout = 5;
			pool['obj1'].isExpired = false;
			pool['obj2'].Created = dateAdd("n",-7,now());
			pool['obj2'].Timeout = 10;
			pool['obj2'].isExpired = false;
			pool['obj3'].Created = dateAdd("n",-6,now());
			pool['obj3'].Timeout = 10;
			pool['obj3'].isExpired = false;
			
			mockCM.$('getPoolMetadata',pool);
			mockCM.$('getCachedObjectMetadata').$args("obj1").$results(pool.obj1);
			mockCM.$('getCachedObjectMetadata').$args("obj2").$results(pool.obj2);
			mockCM.$('getCachedObjectMetadata').$args("obj3").$results(pool.obj3);
			
			mockConfig.$("getEvictCount",1);
			
			debug(pool);
			
			fifo.execute();	
			
			//debug(cm._logTest);
				
			AssertTrue( arrayLen(mockCM._logTest) eq 1);
			AssertEquals( mockCM._logTest[1] , "obj2" );		
		</cfscript>
	</cffunction>
	
</cfcomponent>