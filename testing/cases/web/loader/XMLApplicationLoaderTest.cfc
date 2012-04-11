<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	function setup(){
		//mocks
		fwloader = getMockBox().createMock("coldbox.system.web.loader.FrameworkLoader").init();
		mockController = getMockBox().createMock(className="coldbox.system.web.Controller");
		mockEngine = getMockBox().createMock("coldbox.system.core.cf.CFMLEngine").init();
		mockController.$("getCFMLEngine",mockEngine);
		mockController.$("getAppRootPath",expandPath("/coldbox/testHarness"));
		fwloader.loadSettings(mockController);
		
		loader = getMockBox().createMock("coldbox.system.web.loader.XMLApplicationLoader").init(mockController);
	}
	
	function testLoadSettings(){
		
	}
	function testParseModules(){
		config = {};
		xml = xmlParse("<Modules></Modules>");
		
		// Test layouts as sstruct first
		loader.parseModules(xml, config, false);
		
		assertEquals( false, config.modulesAutoReload);
		assertEquals( arrayNew(1), config.modulesInclude);
		assertEquals( arrayNew(1), config.modulesExclude);
		
		xml = xmlParse("<Modules>
			<AutoReload>True</AutoReload>
			<Include>mod1,test2</Include>
			<Exclude>mod2</Exclude>
		</Modules>");
		
		// Test layouts as sstruct first
		loader.parseModules(xml, config, false);
		
		assertEquals( true, config.modulesAutoReload);
		assertEquals( 'mod1,test2', config.modulesInclude);
		assertEquals( 'mod2', config.modulesExclude);
		
		debug(config);
	
	}
	
	
</cfscript>
	
</cfcomponent>