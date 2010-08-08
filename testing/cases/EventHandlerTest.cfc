<cfcomponent extends="coldbox.system.testing.BaseTestCase" output="false">
<cfscript>
	function setup(){
		handler 		= getMockBox().createMock("coldbox.system.EventHandler");
		mockController  = getMockBox().createMock(className="coldbox.system.web.Controller");
		mockRS 			= getMockBox().createMock(className="coldbox.system.web.services.RequestService");
		flashScope 		= getMockBox().createMock(className="coldbox.system.web.flash.MockFlash");
		mockLogBox 		= getMockBox().createMock(className="coldbox.system.logging.LogBox");
		mockLogger 		= getMockBox().createMock(className="coldbox.system.logging.Logger");
		
		
		mockController.$("getLogBox",mockLogBox);
		mockController.$("getRequestService",mockRS);
		mockRS.$("getFlashScope",flashScope);
		mockLogBox.$("getLogger",mockLogger);
		
		
	}	
	function testInit(){
		mockController.$("getSetting","/coldbox/testing/resources/mixins.cfm");
		handler.init(mockController);
	}
</cfscript>
</cfcomponent>