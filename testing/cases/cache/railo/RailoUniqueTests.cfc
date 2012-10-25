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
		mockEventManager.$("processState");

		// Config
		config = {
			cacheName = "cachelite"
		};

		// Create Provider
		cache = getMockBox().createMock("coldbox.system.cache.providers.RailoProvider").init();

		// Decorate it
		cache.setConfiguration( config );
		cache.setCacheFactory( mockFactory );
		cache.setEventManager( mockEventManager );

		// Configure the provider
		cache.configure();
	}

	function teardown(){
		cache.clearAll();
	}

	function testTimeouts(){
		testVal = {name="luis", age=32};
		cache.clearAll();

		cache.set("test", testVal, 10, createTimeSpan(0,0,1,0) );
		assertEquals( testVal, cache.get("test") );
		md = cache.getCachedObjectMetadata("test");
		//debug( md );
		assertEquals( 600*1000, md.timespan );
		assertEquals( 60*1000, md.idleTime );
		cache.clearAll();
		
		cache.set("test", testVal );
		assertEquals( testVal, cache.get("test") );
		cache.clearAll();
		
		cache.set("test", testVal, "" );
		assertEquals( testVal, cache.get("test") );
		cache.clearAll();
	}

</cfscript>
</cfcomponent>