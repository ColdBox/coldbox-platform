﻿component
	extends="CFProviderTest"
	output ="false"
	skip   ="notAdobe"
{

	function setup(){
		super.setup();
		// Mock Controller
		mockController = createEmptyMock( "coldbox.system.web.Controller" );

		// Create Provider
		cache = createMock( "coldbox.system.cache.providers.CFColdBoxProvider" ).init();

		// Decorate it
		cache.setConfiguration( config );
		cache.setCacheFactory( mockFactory );
		cache.setEventManager( mockEventManager );
		cache.setColdbox( mockController );

		// Configure the provider
		cache.configure();
		// Clear everything first
		cache.clearAll();
	}

	function testPrefixes(){
		assertTrue( len( cache.getEventCacheKeyPrefix() ) );
		assertTrue( len( cache.getViewCacheKeyPrefix() ) );
	}

	function testgetEventURLFacade(){
		assertEquals( true, isInstanceOf( cache.getEventURLFacade(), "coldbox.system.cache.util.EventURLFacade" ) );
	}

	function testClearAllEvents(){
		cache.clearAllEvents();
	}
	function testClearAllViews(){
		cache.ClearAllViews();
	}
	function testclearByKeySnippet(){
		cache.clearByKeySnippet( "test", false );
	}
	function testclearEvent(){
		cache.clearEvent( "test" );
	}
	function testclearEventMulti(){
		cache.clearEventMulti( "test" );
	}
	function testclearViewMulti(){
		cache.clearViewMulti( "test" );
	}
	function testclearView(){
		cache.clearView( "test" );
	}

}
