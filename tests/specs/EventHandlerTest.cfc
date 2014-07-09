﻿<cfcomponent extends="coldbox.system.testing.BaseModelTest" output="false">
<cfscript>
	function setup(){
		handler 		= getMockBox().createMock("coldbox.system.EventHandler");
		mockController  = getMockBox().createEmptyMock("coldbox.system.web.Controller");
		flashScope 		= getMockBox().createEmptyMock("coldbox.system.web.flash.MockFlash");
		mockRS 			= getMockBox().createEmptyMock("coldbox.system.web.services.RequestService")
			.$("getFlashScope",flashScope);
		mockLogger 		= getMockBox().createEmptyMock("coldbox.system.logging.Logger");
		mockLogBox 		= getMockBox().createEmptyMock("coldbox.system.logging.LogBox")
			.$("getLogger",mockLogger);
		mockCacheBox    = getMockBox().createEmptyMock("coldbox.system.cache.CacheFactory");
		mockWireBox     = getMockBox().createEmptyMock("coldbox.system.ioc.Injector");

		mockController.$("getLogBox",mockLogBox)
			.$("getRequestService",mockRS)
			.$("getCacheBox", mockCacheBox)
			.$("getWireBox", mockWireBox);
		mockController.$("getSetting").$args("UDFLibraryFile").$results( ["/tests/resources/mixins.cfm","/tests/resources/mixins2"] )
			.$("getSetting").$args("AppMapping").$results( "/coldbox/testing" );

		handler.init( mockController );
	}

	function testMixins(){
		assertTrue( structKeyExists(handler, "mixinTest") );
		assertTrue( structKeyExists(handler, "repeatThis") );
		assertTrue( structKeyExists(handler, "add") );
	}

</cfscript>
</cfcomponent>