<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	function setup(){
		dataConfigPath = "coldbox.testing.cases.ioc.config.samples.SampleWireBox2";
		config = createObject("component","coldbox.system.ioc.config.WireBoxConfig").init(dataConfigPath);
	}
	
	function testLoader(){
		// My Data Object
		dataConfig = createObject("component",dataConfigPath);
		config = createObject("component","coldbox.system.ioc.config.WireBoxConfig").init(dataConfig);
		
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
	
	function testLoader2(){
		// My Data Object
		config = createObject("component","coldbox.system.ioc.config.WireBoxConfig").init(dataConfigPath);
		
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
	
	function testResolveAlias(){
		
		assertEquals("hello", config.resolveAlias("hello") );
	}
</cfscript>
</cfcomponent>