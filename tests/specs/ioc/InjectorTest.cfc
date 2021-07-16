component extends="tests.resources.BaseIntegrationTest" {

	this.loadColdBox = false;

	function setup(){
		super.setup();

		// init with defaults
		injector = createMock( "coldbox.system.ioc.Injector" );

		// init injector
		injector.init();

		mockLogger = createStub().$( "canDebug", false ).$( "error" );
		util       = createMock( "coldbox.system.core.util.Util" )
			.$( "getInheritedMetaData" )
			.$results( { path : "path.to.object" } );
		injector.setUtility( util );
		injector.setLog( mockLogger );
	}

	function testShutdown(){
		// mocks
		parent       = createStub().$( "shutdown", injector );
		cachebox     = createStub().$( "shutdown" );
		eventManager = createStub().$( "announce" );

		injector.setParent( parent );
		injector
			.$property( "cachebox", "variables", cachebox )
			.$property( "eventManager", "variables", eventManager )
			.$( "isCacheBoxLinked", true )
			.$(
				method             = "removeFromScope",
				returns            = injector,
				preserveReturnType = false
			);
		mockLogger.$( "canInfo", true ).$( "info" );

		injector.shutdown();

		assertTrue( eventManager.$times( 2, "announce" ) );
		assertTrue( parent.$once( "shutdown" ) );
		assertTrue( injector.$once( "removeFromScope" ) );
		assertTrue( cacheBox.$once( "shutdown" ) );
	}

	function testbuildBinder(){
		// 1: plain CFC path
		makePublic( injector, "buildBinder" );
		binder = injector.buildBinder( "coldbox.tests.specs.ioc.config.samples.SampleWireBox", {} );
		assertTrue( isObject( binder ) );

		// 2: WireBox Binder instance
		binder = createMock( "coldbox.tests.specs.ioc.config.samples.WireBox" );
		binder.$( "configure" );
		injector.buildBinder( binder, {} );
		assertEquals( 1, binder.$count( "configure" ) );

		// 3: Simple Binder CFC
		binder  = createMock( "coldbox.tests.specs.ioc.config.samples.SampleWireBox" );
		system  = createObject( "java", "java.lang.System" );
		id      = system.identityHashCode( binder );
		binder2 = injector.buildBinder( binder, {} );
		assertFalse( system.identityHashCode( binder2 ) eq id );
	}

	function testGetBinder(){
		// debug( injector.getBinder() );
		assert( isObject( injector.getBinder() ) );
	}
	function testgetVersion(){
		// debug( injector.getVersion() );
		assert( len( injector.getVersion() ) );
	}
	function testGetInjectorID(){
		// debug( injector.getInjectorID() );
		assertEquals(
			createObject( "java", "java.lang.System" ).identityHashCode( injector ),
			injector.getInjectorID()
		);
	}

	function testRegisterListeners(){
		makePublic( injector, "registerListeners" );

		// Mock listeners
		var listeners = [
			{
				class      : "coldbox.tests.specs.ioc.config.listeners.MyListener",
				name       : "myDude",
				properties : {}
			},
			{
				class      : "coldbox.tests.specs.ioc.config.listeners.MyListener",
				name       : "lui",
				properties : {}
			}
		];
		injector.getBinder().setListeners( listeners );

		prepareMock( injector.getEventManager() ).$( "register" );

		injector.registerListeners();

		assertEquals( 2, injector.getEventManager().$count( "register" ) );

		// exception
		listeners = [
			{
				class      : "coldbox.tests.specs.ioc.config.listeners.MyLister",
				name       : "myDude",
				properties : {}
			}
		];
		injector.getBinder().setListeners( listeners );

		try {
			injector.registerListeners();
		} catch ( "Injector.ListenerCreationException" e ) {
		} catch ( Any e ) {
			fail( e );
		}
	}

	function testdoScopeRegistration(){
		makePublic( injector, "doScopeRegistration" );

		injector.getBinder().scopeRegistration( key: "mockWireBox", scope: "application" );

		try {
			structDelete( application, "mockWireBox" );
			injector.doScopeRegistration();
			structKeyExists( application, "mockWireBox" );
		} finally {
			structDelete( application, "mockWireBox" );
		}
	}

	function testConfigureCacheBox(){
		makePublic( injector, "configureCacheBox" );
		config = {
			enabled        : true,
			configFile     : "",
			classNamespace : "coldbox.system.cache"
		};

		assertFalse( injector.isCacheBoxLinked() );

		// 1 mock instance
		config.cacheFactory = createStub();
		injector.configureCacheBox( config );
		assertEquals( config.cacheFactory, injector.getCacheBox() );

		// 2: enabled, no config, default config
		config.cacheFactory = "";
		injector.configureCacheBox( config );
		assertEquals( true, injector.getCacheBox().cacheExists( "default" ) );

		// 3: with config
		config.configFile = "coldbox.system.web.config.CacheBox";
		injector.configureCacheBox( config );
		assertEquals( true, injector.getCacheBox().cacheExists( "template" ) );

		assertTrue( injector.isCacheBoxLinked() );
	}

	function testConfigureLogBox(){
		makePublic( injector, "configureLogBox" );
		injector.configureLogBox( "coldbox.system.ioc.config.LogBox" );

		assertTrue( isObject( injector.getLogBox() ) );
	}

	function testConfigureEventManager(){
		makePublic( injector, "configureEventManager" );
		injector.configureEventManager();

		assertTrue( isObject( injector.getEventManager() ) );
	}

	function testGetScopeRegistration(){
		reg = injector.getScopeRegistration();
		assertFalse( structIsEmpty( reg ) );
	}

	function testColdBox(){
		assertFalse( injector.isColdBoxLinked() );
		injector.$property( "coldbox", "variables", createStub() );
		assertTrue( injector.isColdBoxLinked() );
	}

	function testGetObjectPopulator(){
		pop = injector.getObjectPopulator();
		assertTrue( isInstanceOf( pop, "coldbox.system.core.dynamic.BeanPopulator" ) );
	}

	function testParenInjector(){
		assertTrue( isSimpleValue( injector.getParent() ) );
		assertFalse( isObject( injector.getParent() ) );

		injector.setParent( injector );
		assertTrue( isObject( injector.getParent() ) );
	}

	function testRemoveFromScope(){
		injector
			.getBinder()
			.scopeRegistration(
				enabled: true,
				key    : "mockWireBox",
				scope  : "application"
			);
		application.mockWireBox = createStub();

		injector.removeFromScope();
		assertFalse( structKeyExists( application, "mockWireBox" ) );
	}

	function testAutowireCallsGetInheritedMetaDataForTargetID(){
		injector.autowire( target = createStub() );
		assertTrue( util.$once( "getInheritedMetaData" ) );
	}

	function testAutowireCallsGetInheritedMetaDataForMD(){
		injector.autowire( target = createStub(), targetID = "myTargetID" );
		assertTrue( util.$once( "getInheritedMetaData" ) );
	}

}
