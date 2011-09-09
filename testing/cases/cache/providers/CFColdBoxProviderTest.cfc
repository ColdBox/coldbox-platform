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
<cfcomponent name="cacheTest" extends="CFProviderTest" output="false">
<cfscript>

	function setup(){
		super.setup();
		// Mock Controller
		mockController = getMockBox().createEmptyMock("coldbox.system.web.Controller");
		
		// Create Provider
		cache = getMockBox().createMock("coldbox.system.cache.providers.CFColdBoxProvider").init();
		
		// Decorate it
		cache.setConfiguration( config );
		cache.setCacheFactory( mockFactory );
		cache.setEventManager( mockEventManager );
		cache.setColdbox( mockController );
		
		// Configure the provider
		cache.configure();		
	}
	
	function testPrefixes(){
		assertTrue( len(cache.getEventCacheKeyPrefix()) );
		assertTrue( len(cache.getViewCacheKeyPrefix()) );
		assertTrue( len(cache.getHandlerCacheKeyPrefix()) );
		assertTrue( len(cache.getInterceptorCacheKeyPrefix()) );
		assertTrue( len(cache.getPluginCacheKeyPrefix()) );
		assertTrue( len(cache.getCustomPluginCacheKeyPrefix()) );
	}
	
	function testgetEventURLFacade(){
		assertEquals(true, isInstanceOf(cache.getEventURLFacade(),"coldbox.system.cache.util.EventURLFacade") );
	}

	function testClearAllEvents(){
		cache.clearAllEvents();
	}
	function testClearAllViews(){
		cache.ClearAllViews();
	}
	function testclearByKeySnippet(){
		cache.clearByKeySnippet("test",false);
	}
	function testclearEvent(){
		cache.clearEvent("test");
	}
	function testclearEventMulti(){
		cache.clearEventMulti("test");
	}
	function testclearViewMulti(){
		cache.clearViewMulti("test");
	}
	function testclearView(){
		cache.clearView("test");
	}
</cfscript>
</cfcomponent>