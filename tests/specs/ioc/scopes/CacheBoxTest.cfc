<cfcomponent extends="coldbox.system.testing.BaseModelTest" model="coldbox.system.ioc.scopes.CacheBox">
<cfscript>

	function setup(){
		mockLogger = createEmptyMock( "coldbox.system.logging.Logger" ).$( "canDebug",true).$( "debug" ).$( "error" ).$( "canWarn",true).$( "warn" );
		mockLogBox = createEmptyMock( "coldbox.system.logging.LogBox" ).$( "getLogger", mockLogger);
		mockCache = createEmptyMock( "coldbox.system.cache.providers.CacheBoxColdBoxProvider" );
		mockCacheBox = createEmptyMock( "coldbox.system.cache.CacheFactory" )
			.$( "getCache", mockCache);
		mockInjector = createMock( "coldbox.system.ioc.Injector" )
			.setLogBox( createstub().$( "getLogger", mockLogger) )
			.$( "getUtil", createMock( "coldbox.system.core.util.Util" ))
			.setCacheBox( mockCacheBox)
			.setLogBox( mockLogBox )
			.setInjectorID( createUUID() );
		super.setup();
		scope = model.init( mockInjector );
		mockStub = createStub();
	}

	function testGetFromScopeExistsAlready(){

		var mapping = createMock( "coldbox.system.ioc.config.Mapping" ).init(name="CacheTest" );
		mapping.setCacheProperties(key="CacheTest",timeout="",provider="default" );
		mapping.setThreadSafe( true );
		mockCache.$( "get", mockStub);
		
		var o = scope.getFromScope( mapping, {} );

		assertEquals( mockStub, o );
	}

	function testGetFromScope(){
		// 1: Default construction
		var mapping = createMock( "coldbox.system.ioc.config.Mapping" ).init(name="CacheTest" );

		mapping.setCacheProperties(key="CacheTest",timeout="",provider="default" );
		mapping.setThreadSafe( false );
		mockCache.$( "get" ).$( "set",true);
		mockInjector.$( "buildInstance", mockStub).$( "autowire", mockStub);

		var o = scope.getFromScope( mapping, {} );
		assertEquals( mockStub, o );

		// 2: ThreadSafe singleton creations
		mapping = createMock( "coldbox.system.ioc.config.Mapping" ).init(name="singletontest" );
		mapping.setThreadSafe( true );
		mockInjector.$( "buildInstance", mockStub).$( "autowire", mockStub);
		o = scope.getFromScope( mapping, {} );
	}

</cfscript>
</cfcomponent>