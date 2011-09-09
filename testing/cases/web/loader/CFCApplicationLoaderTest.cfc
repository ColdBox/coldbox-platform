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
		
		coldboxSettings = {};
		mockController.$("getColdboxSettings",coldboxSettings);
		
		loader = getMockBox().createMock("coldbox.system.web.loader.CFCApplicationLoader").init(mockController);
		getMockBox().prepareMock(this);
	}
	
	function testparseLayoutsViews(){
		config = {};
		layoutSettings = {defaultLayout='layout.main.cfm'};
		layouts = {
			login = {file="layout.login.cfm",folders="tags",views="test"}
		};
		
		// Test layouts as sstruct first
		this.$("getPropertyMixin").$results(layoutSettings,layouts);
		loader.parseLayoutsViews(this, config);
		assertEquals( layoutSettings.defaultLayout, config.defaultLayout);
		assertEquals( layouts.login.file, config.registeredLayouts.login);
		assertEquals( layouts.login.file, config.folderLayouts["tags"]);
		assertEquals( layouts.login.file, config.viewLayouts["test"]);
		
		// Test now with array for order
		layouts = [
			{name="login",  file="layout.login.cfm", folders="tags/admin",views="test"},
			{name="login2", file="layout.login2.cfm",folders="tags",views="test"}
		];
		this.$("getPropertyMixin").$results(layoutSettings,layouts);
		loader.parseLayoutsViews(this, config);
		assertEquals( layoutSettings.defaultLayout, config.defaultLayout);
		assertEquals( "tags/admin,tags", structKeyList(config.folderLayouts) );
		
		debug(config);
	}
	
	function testParseModules(){
		config = {};
		modules= {};
		
		// Test layouts as sstruct first
		this.$("getPropertyMixin").$results(modules);
		loader.parseModules(this, config);
		assertEquals( false, config.modulesAutoReload);
		assertEquals( arrayNew(1), config.modulesInclude);
		assertEquals( arrayNew(1), config.modulesExclude);
		
		modules= {
			autoReload = true,
			include = [
				"test1","blog"
			],
			exclude = [
				"paidModule"
			]
		};
		
		this.$("getPropertyMixin").$results(modules);
		// Test layouts as sstruct first
		loader.parseModules(this, config);
		assertEquals( true, config.modulesAutoReload);
		assertEquals( modules.include, config.modulesInclude);
		assertEquals( modules.exclude, config.modulesExclude);
		
		debug(config);
	}
</cfscript>
	
</cfcomponent>