<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	function setup(){
		//mocks
		mockController = getMockBox().createEmptyMock(className="coldbox.system.web.Controller");
		mockEngine = getMockBox().createMock("coldbox.system.core.cf.CFMLEngine").init();
		mockController.$("getCFMLEngine",mockEngine);
		mockController.$("getAppRootPath",expandPath("/coldbox/testHarness"));
		mockController.$("setAppRootPath");
		mockController.$("setColdboxSettings");
		
		loader = getMockBox().createMock("coldbox.system.web.loader.FrameworkLoader").init();
	}
	
	function testLoadSettings(){
	
		loader.loadSettings(mockController);
		//debug(mockController.$callLog().setColdboxSettings[1][1]);
		assertTrue( not structIsEmpty(mockController.$callLog().setColdboxSettings[1][1]) );
		
	}
	
	function testLoadingLoad(){
		stime = getTickCount();
		for(x=1; x lte 100; x++){
			loader = getMockBox().createMock("coldbox.system.web.loader.FrameworkLoader").init();
			loader.loadSettings(mockController);
		}
		debug("Total Time: " & getTickCount()-stime & " ms");
	}
	
</cfscript>
	
</cfcomponent>