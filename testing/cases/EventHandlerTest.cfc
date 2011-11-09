<cfcomponent extends="coldbox.system.testing.BaseTestCase" output="false">
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
		mockController.$("getSetting").$args("UDFLibraryFile").$results( ["/coldbox/testing/resources/mixins.cfm","/coldbox/testing/resources/mixins2"] )
			.$("getSetting").$args("AppMapping").$results( "/coldbox/testing" );
		
		handler.init( mockController );
	}	
	
	function testMixins(){
		assertTrue( structKeyExists(handler, "mixinTest") );
		assertTrue( structKeyExists(handler, "repeatThis") );
		assertTrue( structKeyExists(handler, "add") );
	}
	
	function testgetMailSettings(){
		s = handler.getMailSettings();
		assertTrue( isInstanceOf(s,"coldbox.system.core.mail.MailSettingsBean") );
	}
	
	function testGetMailService(){
		mockService = getMockBox().createStub();
		mockController.$("getPlugin").$args("MailService").$results( mockService );
		s = handler.getMailService();
		assertEquals( mockService, s);
	}
	
	function testgetNewMail(){
		mockService = getMockBox().createStub()
			.$("newMail", this );
		mockController.$("getPlugin").$args("MailService").$results( mockService );
		s = handler.getNewMail();
		assertEquals( this, s);
	}
</cfscript>
</cfcomponent>