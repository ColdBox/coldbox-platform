<cfcomponent extends="coldbox.system.testing.BaseTestCase" output="false">
<cfscript>
	function setup(){
		handler 		= getMockBox().createMock("coldbox.system.EventHandler");
		mockController  = getMockBox().createEmptyMock("coldbox.system.web.Controller");
		flashScope 		= getMockBox().createEmptyMock("coldbox.system.web.flash.MockFlash");
		mockRS 			= getMockBox().createEmptyMock("coldbox.system.web.services.RequestService")
			.$("getFlashScope",flashScope);
		mockLogBox 		= getMockBox().createEmptyMock("coldbox.system.logging.LogBox");
		mockLogger 		= getMockBox().createEmptyMock("coldbox.system.logging.Logger");
		mockCacheBox    = getMockBox().createEmptyMock("coldbox.system.cache.CacheFactory");
		mockWireBox     = getMockBox().createEmptyMock("coldbox.system.ioc.Injector");
		
		mockController.$("getLogBox",mockLogBox)
			.$("getRequestService",mockRS)
			.$("getCacheBox", mockCacheBox)
			.$("getWireBox", mockWireBox);
		mockLogBox.$("getLogger",mockLogger);
		mockController.$("getSetting","/coldbox/testing/resources/mixins.cfm");
		
		handler.init(mockController);
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