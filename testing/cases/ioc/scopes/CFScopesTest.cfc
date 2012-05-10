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
	}

	function testGetFromScopeExistsAlready(){
		mapping = getMockBox().createMock("coldbox.system.ioc.config.Mapping").init(name="CFScopeTest");
		mapping.setScope( "session" );
		session["wirebox:CFScopeTest"] = this;
		o = scope.getFromScope( mapping, {} );
		assertEquals( this, o );
	}

	function testGetFromScope(){
		// 1: Default construction
		mapping = getMockBox().createMock("coldbox.system.ioc.config.Mapping").init(name="CFScopeTest");
		mapping.setScope( "session" );
		mockInjector.$("buildInstance", this).$("autowire", this);
		o = scope.getFromScope( mapping, {} );
		assertEquals( this, o );
		assertEquals( this, session["wirebox:CFScopeTest"] );

		// 2: ThreadSafe singleton creations
		mapping = getMockBox().createMock("coldbox.system.ioc.config.Mapping").init(name="CFScopeTest");
		mapping.setScope( "session" );
		mapping.setThreadSafe( true );
		mockInjector.$("buildInstance", this).$("autowire", this);
		o = scope.getFromScope( mapping, {} );
		assertEquals( this, session["wirebox:CFScopeTest"] );
	}

</cfscript>
</cfcomponent>