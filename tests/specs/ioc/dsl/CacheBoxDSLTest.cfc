<cfcomponent extends="coldbox.system.testing.BaseModelTest">
<cfscript>
  	
	function setup(){
		mockCacheBox = createEmptyMock( "coldbox.system.cache.CacheFactory" )
			.$( "getCacheNames", [ "test","default" ]);
		mockLogger = createEmptyMock( "coldbox.system.logging.Logger" ).$( "canDebug",true).$( "debug" ).$( "error" ).$( "canWarn",true).$( "warn" );
		mockLogBox = createEmptyMock( "coldbox.system.logging.LogBox" )
			.$( "getLogger", mockLogger);
		mockInjector = createMock( "coldbox.system.ioc.Injector" )
			.setLogBox( mockLogBox )
			.setCacheBox( mockCacheBox);
		mockCache = createEmptyMock( "coldbox.system.cache.providers.MockProvider" );
		
		builder = createMock( "coldbox.system.ioc.dsl.CacheBoxDSL" ).init( mockInjector );
		mockStub = createStub();
	}
	
	function testProcess(){
		// cachebox
		var def = {dsl="cachebox" };
		var r = builder.process(def);
		assertEquals( mockCacheBox, r);
		
		// cachebox:Default
		def = {dsl="cachebox:default" };
		// make sure it exists
		mockCacheBox.$( "cacheExists",true).$( "getCache", mockCache );
		r = builder.process(def);
		//assertEquals( mockCache, r);
		// Now make sure it does NOT exist
		mockCacheBox.$( "cacheExists",false).$( "getCache" );
		r = builder.process(def);
		assertTrue( mockCacheBox.$never( "getCache" ) );
		
		// cachebox:Default:MyKey
		def = {dsl="cachebox:default:MyKey" };
		// make sure it exists
		mockCacheBox.$( "cacheExists",true).$( "getCache", mockCache );
		mockCache.$( "lookup",true).$( "get", mockStub);
		r = builder.process(def);
		assertEquals( mockStub, r);
		// Now make sure it does NOT exist
		mockCache.$( "lookup",false).$( "get" );
		r = builder.process(def);
		assertTrue( mockCache.$never( "get" ) );
	}
	
	
</cfscript>
</cfcomponent>