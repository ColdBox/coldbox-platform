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
<cfcomponent name="cacheTest" extends="coldbox.testing.tests.resources.baseMockCase" output="false">

	<cffunction name="setUp" returntype="void" access="public" output="false">
		<cfscript>
		super.setup();
		mockController = mockfactory.createMock('coldbox.system.controller');
		mockService = mockFactory.createMock('coldbox.system.services.interceptorService');
		
		mockController.mockMethod('getInterceptorService').returns(mockService);
		mockController.mockMethod('getAppHash').returns(hash(createUUID()) );
		
		ccbean = createObject("component","coldbox.system.beans.cacheConfigBean");
		memento = structnew();
		memento.CacheObjectDefaultTimeout = 20;
		memento.CacheObjectDefaultLastAccessTimeout = 20;
		memento.CacheReapFrequency = 1;
		memento.CacheMaxObjects = 100;
		memento.CacheFreeMemoryPercentageThreshold = 1;
		memento.CacheUseLastAccessTimeouts = true;
		memento.CacheEvictionPolicy = "FIFO";
		ccbean.init(argumentCollection=memento);
		
		cm = createObject("component","coldbox.system.cache.cacheManager").init(mockController);
		</cfscript>
	</cffunction>
	
	<cffunction name="testConfigure" access="public" returntype="void" hint="" output="false" >
		<cfscript>
			cm.configure(ccbean);
		</cfscript>
	</cffunction>
	
	<cffunction name="testannounceExpiration" output="false">
		<cfscript>
			makePublic(cm,"announceExpiration","_announceExpiration");
			cm._announceExpiration('test');
		</cfscript>
	</cffunction>
	
</cfcomponent>