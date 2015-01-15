<cfcomponent extends="coldbox.system.testing.BaseModelTest" model="coldbox.system.ioc.scopes.CFScopes">
<cfscript>

	function setup(){
		mockLogger = getMockBox().createEmptyMock("coldbox.system.logging.Logger").$("canDebug",true).$("debug").$("error").$("canWarn",true).$("warn");
		mockLogBox = getMockBox().createEmptyMock("coldbox.system.logging.LogBox").$("getLogger", mockLogger);
		mockInjector = getMockBox().createEmptyMock("coldbox.system.ioc.Injector")
			.$("getLogbox", getMockBox().createstub().$("getLogger", mockLogger) )
			.$("getUtil", getMockBox().createMock("coldbox.system.core.util.Util"))
			.$("getLogBox", mockLogBox );
		super.setup();
		scope = model.init( mockInjector );
		mockStub = createStub();
	}

	function testGetFromScopeExistsAlready(){
		var mapping = getMockBox().createMock("coldbox.system.ioc.config.Mapping").init(name="CFScopeTest");
		mapping.setScope( "session" );
		mapping.setThreadSafe( true );
		session["wirebox:CFScopeTest"] = mockStub;
		var o = scope.getFromScope( mapping, {} );
		assertEquals( mockStub, o );
	}

	function testGetFromScope(){
		// 1: Default construction
		var mapping = getMockBox().createMock("coldbox.system.ioc.config.Mapping").init(name="CFScopeTest");
		mapping.setScope( "session" );
		mapping.setThreadSafe( true );
		mockInjector.$("buildInstance", mockStub).$("autowire", mockStub);
		var o = scope.getFromScope( mapping, {} );
		assertEquals( mockStub, o );
		assertEquals( mockStub, session["wirebox:CFScopeTest"] );

		// 2: ThreadSafe singleton creations
		mapping = getMockBox().createMock("coldbox.system.ioc.config.Mapping").init(name="CFScopeTest");
		mapping.setScope( "session" );
		mapping.setThreadSafe( true );
		mockInjector.$("buildInstance", mockStub).$("autowire", mockStub);
		o = scope.getFromScope( mapping, {} );
		assertEquals( mockStub, session["wirebox:CFScopeTest"] );
	}

</cfscript>
</cfcomponent>