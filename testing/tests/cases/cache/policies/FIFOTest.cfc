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
<cfcomponent name="LRUTest" extends="coldbox.testing.tests.resources.baseMockCase" output="false">

	<cffunction name="setUp" returntype="void" access="public" output="false">
		<cfscript>
		super.setup();
		cm = mockFactory.createMock('coldbox.system.cache.cacheManager');
		pool = mockFactory.createMock('coldbox.system.cache.objectPool');
		stats = mockFactory.createMock('coldbox.system.cache.util.cacheStats');
		
		
		/* Mock */
		cm.mockMethod('getObjectPool').returns(pool);
		cm.mockMethod('getCacheStats').returns(stats);
		stats.mockMethod('evictionHit');
		
		/* Mock Injections expire to get data locally */
		cm.expireKey = variables.expireKey;
		cm.logExpire = variables.logExpire;
		
		fifo = createObject("component","coldbox.system.cache.policies.FIFO").init(cm);		
		</cfscript>
	</cffunction>
	
	<cffunction name="testPolicy" access="public" returntype="void" hint="" output="false" >
		<cfscript>
			mockPool['obj1'] = structnew();
			mockPool['obj2'] = structnew();
			mockPool['obj3'] = structnew();
			
			mockPool['obj1'].Created = now();
			mockPool['obj1'].Timeout = 5;
			mockPool['obj2'].Created = dateAdd("n",-7,now());
			mockPool['obj2'].Timeout = 10;
			mockPool['obj3'].Created = dateAdd("n",-6,now());
			mockPool['obj3'].Timeout = 10;
			
			/* Mock Pool */
			pool.mockMethod('getpool_metadata').returns(mockpool);
			
			debug(mockpool);
			fifo.execute();	
			
			//debug(cm._logTest);
				
			AssertTrue( arrayLen(cm._logTest) eq 1);
			AssertEquals( cm._logTest[1] , "obj2" );		
		</cfscript>
	</cffunction>
	
	<!--- expireKey --->
	<cffunction name="expireKey" output="false" access="private" returntype="void" hint="">
		<cfargument name="key" type="string" required="true" hint=""/>
		<cfscript>
			this.logExpire('#arguments.key#');
		</cfscript>
	</cffunction>
	<cffunction name="logExpire" output="false" access="private" returntype="void" hint="">
		<cfargument name="msg" type="string" required="true" hint=""/>
		<cfscript>
			if( not structKeyExists(this,"_logTest") ){
				this._logTest = ArrayNew(1); 
			}
			ArrayAppend(this._logTest,arguments.msg);
		</cfscript>
	</cffunction>
	
</cfcomponent>