<cfcomponent extends="coldbox.system.testing.BaseModelTest" model="coldbox.system.ioc.scopes.CFScopes">
<cfscript>

	function setup(){
		mockLogger = createEmptyMock( "coldbox.system.logging.Logger" ).$( "canDebug",true).$( "debug" ).$( "error" ).$( "canWarn",true).$( "warn" );
		mockLogBox = createEmptyMock( "coldbox.system.logging.LogBox" ).$( "getLogger", mockLogger);
		mockInjector = createMock( "coldbox.system.ioc.Injector" )
			.setLogBox( createstub().$( "getLogger", mockLogger) )
			.$( "getUtil", createMock( "coldbox.system.core.util.Util" ))
			.setLogBox( mockLogBox )
			.setInjectorID( createUUID() );
		super.setup();
		scope = model.init( mockInjector );
		mockStub = createStub();
	}

	function testGetFromScopeExistsAlready(){
		var mapping = createMock( "coldbox.system.ioc.config.Mapping" ).init(name="CFScopeTest" );
		mapping.setScope( "session" );
		mapping.setThreadSafe( true );
		session[ "wirebox:CFScopeTest" ] = mockStub;
		var o = scope.getFromScope( mapping, {} );
		assertEquals( mockStub, o );
	}

	function testGetFromScope(){
		// 1: Default construction
		var mapping = createMock( "coldbox.system.ioc.config.Mapping" ).init(name="CFScopeTest" );
		mapping.setScope( "session" );
		mapping.setThreadSafe( true );
		mockInjector.$( "buildInstance", mockStub).$( "autowire", mockStub);
		var o = scope.getFromScope( mapping, {} );
		assertEquals( mockStub, o );
		assertEquals( mockStub, session[ "wirebox:CFScopeTest" ] );

		// 2: ThreadSafe singleton creations
		mapping = createMock( "coldbox.system.ioc.config.Mapping" ).init(name="CFScopeTest" );
		mapping.setScope( "session" );
		mapping.setThreadSafe( true );
		mockInjector.$( "buildInstance", mockStub).$( "autowire", mockStub);
		o = scope.getFromScope( mapping, {} );
		assertEquals( mockStub, session[ "wirebox:CFScopeTest" ] );
	}

</cfscript>
</cfcomponent>