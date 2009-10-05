<cfcomponent extends="coldbox.system.testing.BaseTestCase" output="false">
<cfscript>
	function setup(){
		handler = getMockBox().createMock("coldbox.system.EventHandler");
		mockController = getMockBox().createMock(className="coldbox.system.web.Controller");
		
	}	
	function testInit(){
		mockController.$("getSetting","/coldbox/testing/resources/mixins.cfm");
		handler.init(mockController);
	}
</cfscript>
</cfcomponent>