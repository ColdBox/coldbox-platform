<cfcomponent extends="coldbox.system.testing.BaseModelTest" model="coldbox.system.ioc.scopes.Singleton">
    <cfscript>
    function setup(){
        mockLogger = createEmptyMock( "coldbox.system.logging.Logger" )
            .$( "canDebug", true )
            .$( "debug" )
            .$( "error" )
            .$( "canWarn", true )
            .$( "warn" );
        mockLogBox = createEmptyMock( "coldbox.system.logging.LogBox" ).$( "getLogger", mockLogger );
        mockInjector = createMock( "coldbox.system.ioc.Injector" )
            .$( "getUtil", createMock( "coldbox.system.core.util.Util" ) )
            .setLogBox( mockLogBox )
            .setInjectorID( createUUID() );
        super.setup();
        scope = model.init( mockInjector );
        mockStub = createStub();
    }

    function testGetFromScopeExistsAlready(){
        var mapping = createMock( "coldbox.system.ioc.config.Mapping" ).init( name = "SingletonTest" );
        var singletons = scope.getSingletons();
        singletons[ "singletontest" ] = mockStub;
        var o = scope.getFromScope( mapping, {} );
        assertEquals( mockStub, o );
    }

    function testGetFromScope(){
        // 1: Default construction
        var mapping = createMock( "coldbox.system.ioc.config.Mapping" ).init( name = "singletontest" );
        mapping.setThreadSafe( true );
        mockInjector.$( "buildInstance", mockStub ).$( "autowire", mockStub );
        var o = scope.getFromScope( mapping, {} );

        // 2: ThreadSafe singleton creations
        mapping = createMock( "coldbox.system.ioc.config.Mapping" ).init( name = "singletontest" );
        mapping.setThreadSafe( true );
        mockInjector.$( "buildInstance", mockStub ).$( "autowire", mockStub );
        o = scope.getFromScope( mapping, {} );
    }

    function testgetSingletons(){
        assertTrue( structCount( scope.getSingletons() ) eq 0 );
        scope.getSingletons().test = mockStub;
        assertTrue( structCount( scope.getSingletons() ) eq 1 );
    }

    function testClear(){
        assertTrue( structCount( scope.getSingletons() ) eq 0 );
        scope.getSingletons().test = mockStub;
        assertTrue( structCount( scope.getSingletons() ) eq 1 );
        scope.clear();
        assertTrue( structCount( scope.getSingletons() ) eq 0 );
    }
    </cfscript>
</cfcomponent>
