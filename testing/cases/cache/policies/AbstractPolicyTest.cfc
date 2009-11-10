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
<cfcomponent extends="coldbox.system.testing.BaseTestCase" output="false">

	<cffunction name="setUp" returntype="void" access="public" output="false">
		<cfscript>
		
		mockCM = getMockBox().createMock(className='coldbox.system.cache.cacheManager',clearMethods=true,callLogging=true);
		mockPool = getMockBox().createMock(className='coldbox.system.cache.objectPool',clearMethods=true);
		mockStats = getMockBox().createMock(className='coldbox.system.cache.util.cacheStats',clearMethods=true);
		mockConfig = getMockBox().createEmptyMock(className='coldbox.system.cache.config.CacheConfig');
		
		/* Mock */
		mockCM.$('getObjectPool',mockPool);
		mockCM.$('getCacheStats',mockStats);
		mockCM.$('getCacheConfig',mockConfig);
		mockStats.$('evictionHit');
		
		/* Mock Injections expire to get data locally */
		mockCM.expireKey = variables.expireKey;
		mockCM.logExpire = variables.logExpire;
			
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