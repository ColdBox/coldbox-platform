<cfcomponent extends="coldbox.system.testing.BaseModelTest" model="coldbox.system.ioc.scopes.RequestScope">
<cfscript>

	function setup(){
		mockLogger = getMockBox().createEmptyMock("coldbox.system.logging.Logger").$("canDebug",true).$("debug").$("error").$("canWarn",true).$("warn");
		mockLogBox = getMockBox().createEmptyMock("coldbox.system.logging.LogBox").$("getLogger", mockLogger);
		mockInjector = getMockBox().createEmptyMock("coldbox.system.ioc.Injector")
			.$("getLogbox", getMockBox().createstub().$("getLogger", mockLogger) )
			.$("getUtil", getMockBox().createMock("coldbox.system.core.util.Util"))
			.$("getLogBox", mockLogBox );

		scope = getMockBox().createMock("coldbox.system.ioc.scopes.RequestScope").init( mockInjector );
		mockStub = createStub();
	}

	function testGetFromScopeExistsAlready(){
		var mapping = getMockBox().createMock("coldbox.system.ioc.config.Mapping").init(name="RequestTest");
		mapping.setThreadSafe( true );
		request["wirebox:RequestTest"] = mockStub;
		var o = scope.getFromScope( mapping, {} );
		assertEquals( mockStub, o );

	}

	function testGetFromScope(){
		var mapping = getMockBox().createMock("coldbox.system.ioc.config.Mapping").init(name="RequestTest");
		mapping.setThreadSafe( true );
		mockInjector.$("buildInstance", mockStub).$("autowire", mockStub);
		var o = scope.getFromScope( mapping, {} );
		assertEquals( request["wirebox:RequestTest"], o );

	}


</cfscript>
</cfcomponent>