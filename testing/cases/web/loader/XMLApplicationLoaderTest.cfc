<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	function setup(){
		//mocks
		fwloader = getMockBox().createMock("coldbox.system.web.loader.FrameworkLoader").init();
		mockController = getMockBox().createMock(className="coldbox.system.web.Controller");
		mockEngine = getMockBox().createMock("coldbox.system.core.util.CFMLEngine").init();
		mockController.$("getCFMLEngine",mockEngine);
		mockController.$("getAppRootPath",expandPath("/coldbox/testHarness"));
		fwloader.loadSettings(mockController);
		
		loader = getMockBox().createMock("coldbox.system.web.loader.XMLApplicationLoader").init(mockController);
	}
	
	function testLoadSettings(){
	
		
		
	}
	
	
	
</cfscript>
	
</cfcomponent>