﻿<!-----------------------------------------------------------------------
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
		
		config = {
			evictCount = 2
		};
		
		pool = {};
		pool['obj1'] = structnew();
		pool['obj2'] = structnew();
		pool['obj3'] = structnew();
		
		pool['obj1'].Created = now();
		pool['obj1'].Timeout = 5;
		pool['obj1'].isExpired = false;
		pool['obj2'].Created = dateAdd( "n",-7,now());
		pool['obj2'].Timeout = 10;
		pool['obj2'].isExpired = false;
		pool['obj3'].Created = dateAdd( "n",-6,now());
		pool['obj3'].Timeout = 10;
		pool['obj3'].isExpired = false;
		
		mockCM.$( "getConfiguration",config);
		mockIndexer.$( "getPoolMetadata", pool).$( "objectExists",true);
		keys = structSort(pool,"numeric","desc","created" );
		
		mockIndexer.$( "getSortedKeys", keys);
		mockIndexer.$( "getObjectMetadata" ).$results(pool.obj2,pool.obj3,pool.obj1);
		
		lifo = createMock( "coldbox.system.cache.policies.LIFO" ).init(mockCM);
		
		</cfscript>
	</cffunction>
	
	<cffunction name="testPolicy" access="public" returntype="void" hint="" output="false" >
		<cfscript>
			lifo.execute();	
			assertEquals( 2 , arrayLen(mockCM.$callLog().clear) );			
			assertEquals( "obj1", mockCM.$callLog().clear[1][1] );
		</cfscript>
	</cffunction>
	
</cfcomponent>