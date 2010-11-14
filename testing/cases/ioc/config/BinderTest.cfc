<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	function setup(){
		dataConfigPath = "coldbox.testing.cases.ioc.config.samples.SampleWireBox";
		config = createObject("component","coldbox.system.ioc.config.Binder").init(dataConfigPath);
	}
	
	function testBinderStandalone(){
		config = createObject("component","coldbox.system.ioc.config.Binder").init();
		memento = config.getMemento();
		debug(memento);		
	}
	
	function testBinderWithConfigInstance(){
		// My Data Object
		dataConfig = createObject("component",dataConfigPath);
		config = createObject("component","coldbox.system.ioc.config.Binder").init(dataConfig);
		
		memento = config.getMemento();
		debug(memento);
		
		// assert Defaults
		assertTrue( arrayLen(memento.listeners) );
		assertEquals("coldbox.system.ioc.config.LogBox", memento.logBoxConfig);
		assertEquals(config.getDefaults().cacheBox, memento.cacheBox );
		assertEquals(config.getDefaults().scopeRegistration, config.getScopeRegistration() );
		assertEquals( "", config.getParentInjector() );	
		assertEquals( 0, structCount(config.getCustomScopes()) );
		assertEquals( 0, structCount(config.getCustomDSL()) );
		assertEquals( 0, structCount(config.getMappings()) );
		assertEquals( 0, structCount(config.getScanLocations()) );
	}
	
	function testBinderWithConfigPath(){
		// My Data Object
		config = createObject("component","coldbox.system.ioc.config.Binder").init(dataConfigPath);
		
		memento = config.getMemento();
		debug(memento);
		
		// assert Defaults
		assertTrue( arrayLen(memento.listeners) );
		assertEquals("coldbox.system.ioc.config.LogBox", memento.logBoxConfig);
		assertEquals(config.getDefaults().cacheBox, memento.cacheBox );
		assertEquals(config.getDefaults().scopeRegistration, config.getScopeRegistration() );
		assertEquals( "", config.getParentInjector() );	
		assertEquals( 0, structCount(config.getCustomScopes()) );
		assertEquals( 0, structCount(config.getCustomDSL()) );
		assertEquals( 0, structCount(config.getMappings()) );
		assertEquals( 0, structCount(config.getScanLocations()) );
	}
	
	function testParentInjector(){
		config.parentInjector( this );
		assertEquals( this, config.getParentInjector() );
	}
	
	function testResolveAlias(){
		assertEquals("hello", config.resolveAlias("hello") );
	}
	
	function testListenerMethods(){
		debug( config.getListeners() );
		assertEquals(1, arrayLen(config.getListeners()));
		
		config.listener("model.listener",{},"configListner");
		assertEquals(2, arrayLen(config.getListeners()));
		listeners = config.getListeners();
		assertEquals( "configListner", listeners[2].name);
		
		config.listener("model.FunkyTown");
		assertEquals(3, arrayLen(config.getListeners()));
		listeners = config.getListeners();
		assertEquals( "FunkyTown", listeners[3].name);
		
	}
	
	function testLoadDataDSL(){
	}
	
	function testLogBoxConfig(){
		lc = config.getLogBoxConfig();
		debug(lc);
		assertEquals("coldbox.system.ioc.config.LogBox", lc);
		config.logBoxConfig("mypath.logbox.Config");
		assertEquals("mypath.logbox.Config",config.getLogBoxConfig());
	}
	
	function testScopes(){
		scopes = config.getCustomScopes();
		assertEquals( true, structIsEmpty(scopes));
		config.mapScope("FunkyScope","my.scope.FunkyTown");
		assertEquals( false, structIsEmpty(scopes));
		debug(scopes);
	}
	
	function testDSLs(){
		dsls = config.getCustomDSL();
		debug(dsls);
		assertEquals( true, structIsEmpty(dsls));
		config.mapDSL("FunkyScope","my.scope.FunkyTown");
		assertEquals( false, structIsEmpty(dsls));
		debug(dsls);
	}
	
	function testCacheBoxIntegration(){
		// activate cachebox
		config.cacheBox(configFile="my.path.CacheBox");
		cbconfig = config.getCacheBoxConfig();
		assertEquals( true, cbconfig.enabled);
		assertEquals( "my.path.CacheBox", cbconfig.configFile);
		assertEquals( "coldbox.system.cache", cbconfig.classNamespace);
		debug(cbconfig);
		
		// test mapping into cachebox
	}
	
	function testScanLocations(){
		// array
		locs = ["coldbox","mxunit","coldbox.system.plugins"];
		config.scanLocations(locs);
		
		assertEquals(3, structCount(config.getScanLocations() ) );
		locations = config.getScanLocations();
		assertEquals( expandPath("/coldbox/")  , locations["coldbox"]);
		assertEquals( expandPath("/mxunit/")  , locations["mxunit"]);
		assertEquals( expandPath("/coldbox/system/plugins/")  , locations["coldbox.system.plugins"]);
		
		// Try with a list now
		config.reset();
		locs = "coldbox,mxunit,coldbox.system.plugins";
		config.scanLocations(locs);
		assertEquals(3, structCount(config.getScanLocations() ) );
		locations = config.getScanLocations();
		assertEquals( expandPath("/coldbox/")  , locations["coldbox"]);
		assertEquals( expandPath("/mxunit/")  , locations["mxunit"]);
		assertEquals( expandPath("/coldbox/system/plugins/")  , locations["coldbox.system.plugins"]);
		
	}
	
	function testRemoveScanLocations(){
		// array
		locs = ["coldbox","mxunit","coldbox.system.plugins"];
		config.scanLocations(locs);
		
		assertEquals(3, structCount(config.getScanLocations() ) );
		config.removeScanLocations("mxunit");
		assertEquals(2, structCount(config.getScanLocations() ) );
		assertFalse( structKeyExists( config.getScanLocations(), "mxunit") );		
	}
	
	function testScopeRegistration(){
		config.scopeRegistration(true,"server","woot");
		reg = config.getScopeRegistration();
		assertEquals( true, reg.enabled);
		assertEquals( "server", reg.scope);
		assertEquals( "woot", reg.key);
	}
	
	function testStopRecursions(){
		config.stopRecursions(["coldbox.system.Interceptor","coldbox.system.EventHandler"]);
		rec = config.getStopRecursions();
		assertEquals( 2, arrayLen(rec));
		assertEquals( "coldbox.system.Interceptor", rec[1]);
	}
	
</cfscript>
</cfcomponent>