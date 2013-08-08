<cfcomponent extends="coldbox.system.testing.BaseModelTest" model="coldbox.system.ioc.scopes.CacheBox">
<cfscript>

	function setup(){
		mockLogger = getMockBox().createEmptyMock("coldbox.system.logging.Logger").$("canDebug",true).$("debug").$("error").$("canWarn",true).$("warn");
		mockLogBox = getMockBox().createEmptyMock("coldbox.system.logging.LogBox").$("getLogger", mockLogger);
		mockCache = getMockBox().createEmptyMock("coldbox.system.cache.providers.CacheBoxColdBoxProvider");
		mockCacheBox = getMockBox().createEmptyMock("coldbox.system.cache.CacheFactory")
			.$("getCache", mockCache);
		mockInjector = getMockBox().createEmptyMock("coldbox.system.ioc.Injector")
			.$("getLogbox", getMockBox().createstub().$("getLogger", mockLogger) )
			.$("getUtil", getMockBox().createMock("coldbox.system.core.util.Util"))
			.$("getCacheBox", mockCacheBox)
			.$("getLogBox", mockLogBox );
		super.setup();
		scope = model.init( mockInjector );
	}

	function testGetFromScopeExistsAlready(){

		mapping = getMockBox().createMock("coldbox.system.ioc.config.Mapping").init(name="CacheTest");
		mapping.setCacheProperties(key="CacheTest",timeout="",provider="default");

		mockCache.$("get", this);
		o = scope.getFromScope( mapping, {} );

		assertEquals( this, o );
	}

	function testGetFromScope(){
		// 1: Default construction
		mapping = getMockBox().createMock("coldbox.system.ioc.config.Mapping").init(name="CacheTest");
		mapping.setCacheProperties(key="CacheTest",timeout="",provider="default");
		mockCache.$("get").$("set",true);
		mockInjector.$("buildInstance", this).$("autowire", this);
		o = scope.getFromScope( mapping, {} );
		assertEquals( this, o );

		// 2: ThreadSafe singleton creations
		mapping = getMockBox().createMock("coldbox.system.ioc.config.Mapping").init(name="singletontest");
		mapping.setThreadSafe( true );
		mockInjector.$("buildInstance", this).$("autowire", this);
		o = scope.getFromScope( mapping, {} );
	}

</cfscript>
</cfcomponent>