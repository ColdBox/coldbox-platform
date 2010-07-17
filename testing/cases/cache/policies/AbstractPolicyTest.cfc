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
<cfcomponent extends="coldbox.system.testing.BaseTestCase" output="false">

	<cffunction name="setUp" returntype="void" access="public" output="false">
		<cfscript>
		
		mockCM 		 = getMockBox().createEmptyMock(className='coldbox.system.cache.providers.MockProvider');
		mockFactory  = getMockBox().createEmptyMock(className='coldbox.system.cache.CacheFactory');
		mockLogBox	 = getMockBox().createEmptyMock("coldbox.system.logging.LogBox");
		mockLogger	 = getMockBox().createEmptyMock("coldbox.system.logging.Logger");	
		mockPool 	 = getMockBox().createEmptyMock(className='coldbox.system.cache.store.ConcurrentSoftReferenceStore');
		mockStats 	 = getMockBox().createEmptyMock(className='coldbox.system.cache.util.CacheStats');
		
		// Mocks
		mockCM.$("getCacheFactory", mockFactory);
		mockCM.$('getStats',mockStats);
		mockCM.$("getName","MockCache");
		mockFactory.$("getLogBox",mockLogBox);
		mockLogBox.$("getLogger", mockLogger);
		mockLogger.$("error").$("debug").$("info");
		mockStats.$('evictionHit');
		</cfscript>
	</cffunction>
	
</cfcomponent>