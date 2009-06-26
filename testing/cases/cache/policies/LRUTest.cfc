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
<cfcomponent name="LRUTest" extends="AbstractPolicyTest" output="false">

	<cffunction name="setUp" returntype="void" access="public" output="false">
		<cfscript>
		super.setup();
		
		lru = createObject("component","coldbox.system.cache.policies.LRU").init(mockCM);		
		</cfscript>
	</cffunction>
	
	<cffunction name="testPolicy" access="public" returntype="void" hint="" output="false" >
		<cfscript>
			pool['obj1'] = structnew();
			pool['obj2'] = structnew();
			pool['obj3'] = structnew();
			
			pool['obj1'].LastAccessTimeout = now();
			pool['obj1'].Timeout = 5;
			pool['obj2'].LastAccessTimeout = dateAdd("n",-7,now());
			pool['obj2'].Timeout = 10;
			pool['obj3'].LastAccessTimeout = dateAdd("n",-6,now());
			pool['obj3'].Timeout = 10;
			
			/* Mock Pool */
			mockPool.$('getpool_metadata',pool);
			
			lru.execute();	
			
			//debug(cm._logTest);
				
			AssertTrue( arrayLen(mockCM._logTest) eq 1);
			AssertEquals( mockCM._logTest[1] , "obj2" );		
		</cfscript>
	</cffunction>
	
</cfcomponent>