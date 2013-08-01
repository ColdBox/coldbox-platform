<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	
	function setup(){
		mockCacheBox = getMockBox().createEmptyMock("coldbox.system.cache.CacheFactory")
			.$("getCacheNames", ["test","default"]);
		mockLogger = getMockBox().createEmptyMock("coldbox.system.logging.Logger").$("canDebug",true).$("debug").$("error").$("canWarn",true).$("warn");
		mockLogBox = getMockBox().createEmptyMock("coldbox.system.logging.LogBox")
			.$("getLogger", mockLogger);
		mockInjector = getMockBox().createEmptyMock("coldbox.system.ioc.Injector")
			.$("getLogBox", mockLogBox )
			.$("getCacheBox", mockCacheBox);
		mockCache = getMockBox().createEmptyMock("coldbox.system.cache.providers.MockProvider");
		
		builder = getMockBox().createMock("coldbox.system.ioc.dsl.CacheBoxDSL").init( mockInjector );
	}
	
	function testProcess(){
		// cachebox
		def = {dsl="cachebox"};
		r = builder.process(def);
		assertEquals( mockCacheBox, r);
		
		// cachebox:Default
		def = {dsl="cachebox:default"};
		// make sure it exists
		mockCacheBox.$("cacheExists",true).$("getCache", mockCache );
		r = builder.process(def);
		assertEquals( mockCache, r);
		// Now make sure it does NOT exist
		mockCacheBox.$("cacheExists",false).$("getCache");
		r = builder.process(def);
		assertTrue( mockCacheBox.$never("getCache") );
		
		// cachebox:Default:MyKey
		def = {dsl="cachebox:default:MyKey"};
		// make sure it exists
		mockCacheBox.$("cacheExists",true).$("getCache", mockCache );
		mockCache.$("lookup",true).$("get", this);
		r = builder.process(def);
		assertEquals( this, r);
		// Now make sure it does NOT exist
		mockCache.$("lookup",false).$("get");
		r = builder.process(def);
		assertTrue( mockCache.$never("get") );
	}
	
	
</cfscript>
</cfcomponent>