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
<cfcomponent name="cacheTest" extends="coldbox.system.testing.BaseTestCase" output="false">
<cfscript>

	function setup(){
		//Mocks
		mockFactory  = getMockBox().createEmptyMock(className='coldbox.system.cache.CacheFactory');
		mockEventManager  = getMockBox().createEmptyMock(className='coldbox.system.core.events.EventPoolManager');
		mockLogBox	 = getMockBox().createEmptyMock("coldbox.system.logging.LogBox");
		mockLogger	 = getMockBox().createEmptyMock("coldbox.system.logging.Logger");	
		// Mock Methods
		mockFactory.$("getLogBox",mockLogBox);
		mockLogBox.$("getLogger", mockLogger);
		mockLogger.$("error").$("debug").$("info");
		mockEventManager.$("process");
		
		// Config 
		config = {
			objectDefaultTimeout = 60,
			objectDefaultLastAccessTimeout = 30,
			useLastAccessTimeouts = true,
			reapFrequency = 2,
			freeMemoryPercentageThreshold = 0,
			evictionPolicy = "LRU",
			evictCount = 1,
			maxObjects = 200,
			objectStore = "ConcurrentSoftReferenceStore",
			// This switches the internal provider from normal cacheBox to coldbox enabled cachebox
			coldboxEnabled = false
		};
		
		// Create Provider
		cache = getMockBox().createMock("coldbox.system.cache.providers.CacheBoxProvider").init();
		// Decorate it
		cache.setConfiguration( config );
		cache.setCacheFactory( mockFactory );
		cache.setEventManager( mockEventManager );
		
		// Configure the provider
		cache.configure();
		
	}
	
	function testShutdown(){
		cache.shutdown();
	}
	
	function testLookupMulti(){
		cache.getObjectStore().set("test",now(),20);
		cache.getObjectStore().set("test2",now(),20);
		cache.clearStatistics();
		
		//list
		results = cache.lookupMulti(keys="test,test2,test3");
		debug(results);
		assertEquals( true, results.test );
		assertEquals( true, results.test2 );
		assertEquals( false, results.test3 );		
	}
	
	function testLookup(){
		cache.getObjectStore().set("test",now(),20);
		cache.clearStatistics();
		
		assertEquals( false, cache.lookup("invalid") );
		assertEquals( true, cache.lookup("test") );
		
		assertEquals( 1, cache.getStats().getMisses() );
		assertEquals( 1, cache.getStats().getHits() );
		
	}
	
	function testLookupQuiet(){
		cache.getObjectStore().set("test",now(),20);
		cache.clearStatistics();
	
		assertEquals( false, cache.lookupQuiet("invalid") );
		assertEquals( true, cache.lookupQuiet("test") );
		
		assertEquals( 0, cache.getStats().getMisses() );
		assertEquals( 0, cache.getStats().getHits() );
		
	}
	
	function testGet(){
		testVal = {name="luis", age=32};
		cache.getObjectStore().set("test",testVal,20);
		cache.clearStatistics();
	
		results = cache.get("test");
		assertEquals( results, testval );
		assertEquals( 0, cache.getStats().getMisses() );
		assertEquals( 1, cache.getStats().getHits() );
		
		results = cache.get("test2");
		assertFalse( isDefined("results") );
		assertEquals( 1, cache.getStats().getMisses() );
	}


</cfscript>
</cfcomponent>