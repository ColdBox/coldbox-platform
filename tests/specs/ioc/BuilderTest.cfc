﻿component extends="tests.resources.BaseIntegrationTest" {

	this.loadColdBox = false;

	function setup(){
		super.setup();

		mockColdBox  = createEmptyMock( "coldbox.system.web.Controller" );
		mockCacheBox = createEmptyMock( "coldbox.system.cache.CacheFactory" );
		mockLogger   = createEmptyMock( "coldbox.system.logging.Logger" )
			.$( "canDebug", true )
			.$( "debug" )
			.$( "error" )
			.$( "canWarn", true )
			.$( "warn" );

		mockLogBox = createEmptyMock( "coldbox.system.logging.LogBox" ).$( "getLogger", mockLogger );

		mockInjector = createMock( "coldbox.system.ioc.Injector" )
			.setLogBox( createstub().$( "getLogger", mockLogger ) )
			.setUtility( createMock( "coldbox.system.core.util.Util" ) )
			.$( "isColdBoxLinked", true )
			.$( "isCacheBoxLinked", true )
			.setColdBox( mockColdbox )
			.setLogBox( mockLogBox )
			.setCacheBox( mockCacheBox )
			.setChildInjectors( {} );

		builder  = createMock( "coldbox.system.ioc.Builder" ).init( mockInjector );
		mockStub = createStub();
	}

	function testCacheboxLinkOff(){
		mockInjector.$( "isColdBoxLinked", false ).$( "isCacheBoxLinked", false );
		expectException( "Builder.IllegalDSLException" );
		builder.buildDSLDependency(
			definition   = { dsl : "cachebox:default" },
			targetID     = "unit-test",
			targetObject = createStub()
		);
	}

	function testGetJavaDSL(){
		makePublic( builder, "getJavaDSL" );
		def = { dsl : "java:java.util.LinkedHashMap" };
		e   = builder.getJavaDSL( def );
		assertTrue( isInstanceOf( e, "java.util.LinkedHashMap" ) );
	}

	function testbuildJavaClass(){
		mapping = createMock( "coldbox.system.ioc.config.Mapping" ).init( "Buffer" );
		mapping
			.setPath( "java.util.LinkedHashMap" )
			.addDIConstructorArgument( value = "3" )
			.addDIConstructorArgument( value = "5", javaCast = "float" );
		r = builder.buildJavaClass( mapping );

		mapping = createMock( "coldbox.system.ioc.config.Mapping" ).init( "Buffer" );
		mapping.setPath( "java.util.LinkedHashMap" );
		r = builder.buildJavaClass( mapping );
		// debug(r);
	}

	function testbuildcfc(){
		// simple cfc
		var mapping = createMock( "coldbox.system.ioc.config.Mapping" ).init( "MyCFC" );
		mapping.setPath( "coldbox.test-harness.models.ioc.Simple" );
		var r = builder.buildCFC( mapping );
		expect( r ).toBeComponent();
	}

	function testBuildCFCWithArguments(){
		// mocks
		var mockObject = createMock( "coldbox.test-harness.models.ioc.Simple" );
		builder.$( "buildDSLDependency", mockObject );
		mockInjector
			.$( "getInstance", mockObject )
			.$( "containsInstance" )
			.$args( "myBean" )
			.$results( true )
			.$( "containsInstance" )
			.$args( "modelNotFound" )
			.$results( false );

		// With constructor args
		var mapping = createMock( "coldbox.system.ioc.config.Mapping" ).init( "MyCFC" );
		mapping
			.setPath( "coldbox.test-harness.models.ioc.SimpleConstructors" )
			.addDIConstructorArgument( name = "constant", value = 45 )
			.addDIConstructorArgument( name = "dslVar", dsl = "logbox" )
			.addDIConstructorArgument( name = "modelVar", ref = "myBean" )
			.addDIConstructorArgument(
				name     = "modelVarNonRequired",
				required = "false",
				ref      = "modelNotFound"
			);
		var r = builder.buildCFC( mapping );
		expect( r ).toBeComponent();
	}

	function testBuildCFCInjectorException(){
		// mocks
		var mockObject = createMock( "coldbox.test-harness.models.ioc.Simple" );
		builder.$( "buildDSLDependency", mockObject );
		mockInjector.$( "containsInstance" ).$results( false );

		// With constructor args
		var mapping = createMock( "coldbox.system.ioc.config.Mapping" ).init( "MyCFC" );
		mapping
			.setPath( "coldbox.test-harness.models.ioc.SimpleConstructors" )
			.addDIConstructorArgument( name = "constant", value = 45 )
			.addDIConstructorArgument( name = "dslVar", dsl = "logbox" )
			.addDIConstructorArgument( name = "modelVar", ref = "myBean" );
		try {
			var r = builder.buildCFC( mapping );
		} catch ( "Injector.ArgumentNotFoundException" e ) {
		} catch ( Any e ) {
			fail( e );
		}
	}

	function testBuildCFCDependencyException(){
		// mocks
		var mockObject = createMock( "coldbox.test-harness.models.ioc.Simple" );
		builder.$( "buildDSLDependency", mockObject );
		mockInjector
			.$( "getInstance", mockObject )
			.$( "containsInstance" )
			.$args( "myBean" )
			.$results( true )
			.$( "containsInstance" )
			.$args( "modelNotFound" )
			.$results( false );

		// With constructor args
		var mapping = createMock( "coldbox.system.ioc.config.Mapping" ).init( "MyCFC" );
		mapping
			.setPath( "coldbox.test-harness.models.ioc.SimpleConstructors" )
			.addDIConstructorArgument( name = "constant", value = 45 )
			.addDIConstructorArgument( name = "dslVar", dsl = "logbox" )
			.addDIConstructorArgument( name = "modelVar", ref = "myBean" )
			.addDIConstructorArgument(
				name     = "modelVarNonRequired",
				required = "false",
				ref      = "modelNotFound"
			)
			.addDIConstructorArgument( name = "extraArg", value = { "failMe" : true } );
		try {
			var r = builder.buildCFC( mapping );
		} catch ( "Builder.BuildCFCDependencyException" e ) {
		} catch ( Any e ) {
			fail( e );
		}
	}

	// TODO: ACTIVATE ONCE THE FEEDS MODULE IS BUILT
	function testbuildfeed() skip="isBoxLang"{
		var mapping = createMock( "coldbox.system.ioc.config.Mapping" ).init( "GoogleNews" );
		mapping.setPath(
			"https://www.nytimes.com/svc/collections/v1/publish/https://www.nytimes.com/section/world/rss.xml"
		);
		var r = builder.buildfeed( mapping );
		// debug(r);
		expect( r.metadata ).toBeStruct();
		expect( r.items ).toBeQuery();
	}

	function testBuildFactoryBean(){
		// map factory bean
		var mapping = createMock( "coldbox.system.ioc.config.Mapping" ).init( "MyFactoryBean" );
		mapping.setPath( "factory" ).setMethod( "getBean" );

		// mocks
		var mockTest    = createStub();
		var mockFactory = createStub().$( "getBean", mockTest );
		mockInjector.$( "containsInstance", true ).$( "getInstance", mockFactory );

		var r = builder.buildFactoryMethod( mapping );
		assertEquals( mockTest, r );

		// With Arguments
		mapping
			.setPath( "factory" )
			.setMethod( "getBean" )
			.addDIMethodArgument( name = "test", value = "1" )
			.addDIMethodArgument( name = "num2", value = "3" );
		// mocks
		mockTest    = createStub();
		mockFactory = createStub()
			.$( "getBean" )
			.$args( test = "1", num2 = "3" )
			.$results( mockTest );
		mockInjector.$( "containsInstance", true ).$( "getInstance", mockFactory );

		r = builder.buildFactoryMethod( mapping );
		assertEquals( mockTest, r );
	}

	function testgetProviderDSL(){
		makePublic( builder, "getProviderDSL" );
		var data = { name : "luis", dsl : "provider:luis" };

		// mocks
		var mockLuis  = createStub();
		var scopeInfo = { enabled : true, scope : "application", key : "wirebox" };
		mockInjector
			.$( "getInstance", mockLuis )
			.$( "getScopeRegistration", scopeInfo )
			.$( "getName", "root" )
		;
		var p = builder.getProviderDSL( data );
		p.setScopeStorage(
			createEmptyMock( "coldbox.system.core.collections.ScopeStorage" )
				.$( "exists", true )
				.$( "get", mockInjector )
		);

		assertEquals( mockLuis, p.$get() );
	}

	function testregisterCustomBuilders(){
		var customDSL  = { coolLuis : "coldbox.tests.specs.ioc.dsl.MyTestingDSL" };
		var mockBinder = createMock( "coldbox.system.ioc.config.Binder" ).setCustomDSL( customDSL );

		mockInjector.setBinder( mockBinder );
		builder.registerCustomBuilders();

		var custom = builder.getCustomDSL();
		assertEquals( true, structKeyExists( custom, "coolLuis" ) );
	}

	function testbuildDSLDependencyCustom(){
		var def        = { name : "test", dsl : "coolLuis:woopee" };
		var customDSL  = { coolLuis : "coldbox.tests.specs.ioc.dsl.MyTestingDSL" };
		var mockBinder = createMock( "coldbox.system.ioc.config.Binder" ).setCustomDSL( customDSL );
		mockInjector.setBinder( mockBinder );
		builder.registerCustomBuilders();

		var test = builder.buildDSLDependency( def, "UnitTest" );
		expect( test.getName() ).toBe( "woopee" );
	}

	function testbuildSimpleDSL(){
		// mocks
		mockStub = createStub().$( "verify", true );
		builder.$( "buildDSLDependency", mockStub );

		// build it
		var r = builder.buildSimpleDSL(
			dsl          = "logbox:logger:test",
			targetID     = "unit",
			targetObject = mockStub
		);
		expect( builder.$callLog().buildDSLDependency[ 1 ].targetID ).toBe( "unit" );
		expect( builder.$callLog().buildDSLDependency[ 1 ].targetObject ).toBe( mockStub );
		expect( builder.$callLog().buildDSLDependency[ 1 ].definition.dsl ).toBe( "logbox:logger:test" );
		expect( builder.$callLog().buildDSLDependency[ 1 ].definition.name ).toBe( "" );
	}

	function testgetWireBoxDSL(){
		makePublic( builder, "getWireBoxDSL" );

		var targetID = "testWireBoxDSL";
		var data     = { name : "luis", dsl : "wirebox" };

		// wirebox
		var p = builder.getWireBoxDSL( definition: data, targetID: targetID );
		expect( getMetadata( p ).name ).toMatch( "Injector" );

		// wirebox:parent
		data = { name : "luis", dsl : "wirebox:parent" };
		mockInjector.$( "getParent", "" );
		p = builder.getWireBoxDSL( definition: data, targetID: targetID );
		assertEquals( "", p );

		// wirebox:eventmanager
		data             = { name : "luis", dsl : "wirebox:eventManager" };
		mockEventManager = createEmptyMock( "coldbox.system.core.events.EventPoolManager" );
		mockInjector.setEventManager( mockEventManager );
		p = builder.getWireBoxDSL( definition: data, targetID: targetID );
		assertEquals( mockEventManager, p );

		// wirebox:binder
		data       = { name : "luis", dsl : "wirebox:binder" };
		mockBinder = createMock( "coldbox.system.ioc.config.Binder" );
		mockInjector.setBinder( mockBinder );
		p = builder.getWireBoxDSL( definition: data, targetID: targetID );
		assertEquals( mockBinder, p );

		// wirebox:populator
		data      = { name : "luis", dsl : "wirebox:populator" };
		populator = createEmptyMock( "coldbox.system.core.dynamic.ObjectPopulator" );
		mockInjector.$( "getObjectPopulator", populator );
		p = builder.getWireBoxDSL( definition: data, targetID: targetID );
		assertEquals( populator, p );

		// wirebox:scope
		data      = { name : "luis", dsl : "wirebox:scope:singleton" };
		mockScope = createEmptyMock( "coldbox.system.ioc.scopes.Singleton" );
		mockInjector.$( "getScope", mockScope );
		p = builder.getWireBoxDSL( definition: data, targetID: targetID );
		assertEquals( mockScope, p );

		// wirebox:properties
		data       = { name : "luis", dsl : "wirebox:properties" };
		props      = { prop1 : "hello", name : "luis" };
		mockBinder = createMock( "coldbox.system.ioc.config.Binder" ).setProperties( props );
		mockInjector.setBinder( mockBinder );
		p = builder.getWireBoxDSL( definition: data, targetID: targetID );
		assertEquals( props, p );

		// wirebox:property:{}
		data       = { name : "luis", dsl : "wirebox:property:name" };
		props      = { prop1 : "hello", name : "luis" };
		mockBinder = createMock( "coldbox.system.ioc.config.Binder" ).setProperties( props );
		mockInjector.setBinder( mockBinder );
		p = builder.getWireBoxDSL( definition: data, targetID: targetID );
		assertEquals( "luis", p );

		// wirebox:targetID
		data = { name : "luis", dsl : "wirebox:targetID" };
		p    = builder.getWireBoxDSL( definition: data, targetID: targetID );
		expect( p ).toBe( targetID );

		// wirebox:objectMetadata
		data            = { name : "luis", dsl : "wirebox:objectMetadata" };
		var mockMapping = createMock( "coldbox.system.ioc.config.Mapping" );
		mockMapping.$( "isDiscovered", true );
		mockMapping.$(
			method             = "getObjectMetadata",
			returns            = sampleObjectMetadata(),
			preserveReturnType = false
		);
		mockBinder = createMock( "coldbox.system.ioc.config.Binder" )
			.$( "getMapping" )
			.$args( targetID )
			.$results( mockMapping );
		mockInjector.setBinder( mockBinder );
		p = builder.getWireBoxDSL( definition: data, targetID: targetID );
		expect( sampleObjectMetadata() ).toBe( p );
	}

	function testbuildProviderMixer(){
		// mocks
		mockLuis   = createStub();
		mockTarget = createStub();
		scopeInfo  = { enabled : true, scope : "application", key : "wirebox" };
		mockInjector.$( "getInstance", mockLuis ).$( "getName", "root" );
		scopeStorage = createStub().$( "exists", true ).$( "get", mockInjector );

		// inject mocks on target
		mockTarget.$wbInjector        = mockInjector;
		mockTarget.$wbProviders       = { buildProviderMixer : "luis" };
		mockTarget.buildProviderMixer = builder.buildProviderMixer;

		p = mockTarget.buildProviderMixer();
		assertEquals( "luis", mockInjector.$callLog().getInstance[ 1 ].name );
		assertEquals( mockLuis, p );
	}

	function testBuildDependecyWithDSLDefaults(){
		// Register Object
		var mapping = createMock( "coldbox.system.ioc.config.Mapping" ).init( "MyCFC" );
		mapping.setPath( "coldbox.test-harness.models.ioc.Simple" );
		var mockObject = createStub();
		mockInjector.$( "containsInstance", true ).$( "getInstance", mockObject );

		// 1: No DSL, rely on property name
		var def    = { name : "MyCFC", dsl : "" };
		var target = builder.buildDSLDependency( definition = def, targetID = "MyCFC" );
		expect( target ).toBe( mockObject, "no dsl" );

		// 2: id only
		var def    = { name : "MyCFC", dsl : "id" };
		var target = builder.buildDSLDependency( definition = def, targetID = "MyCFC" );
		expect( target ).toBe( mockObject, "simple id" );

		// 3: id: only
		var def    = { name : "MyCFC", dsl : "id:" };
		var target = builder.buildDSLDependency( definition = def, targetID = "MyCFC" );
		expect( target ).toBe( mockObject, "simple id with :" );

		// 4: id withname
		var def    = { name : "service", dsl : "id:MyCFC" };
		var target = builder.buildDSLDependency( definition = def, targetID = "MyCFC" );
		expect( target ).toBe( mockObject, "id with alias" );
	}

	private struct function sampleObjectMetadata(){
		return {
			"remoteAddress" : "http://127.0.0.1:8599/cbtestharness/models/Photos.cfc?wsdl",
			"hint"          : "I model a photos",
			"path"          : "/home/elpete/code/github/ColdBox/coldbox-platform/test-harness/models/Photos.cfc",
			"fullname"      : "test-harness.models.Photos",
			"synchronized"  : false,
			"properties"    : [],
			"extends"       : {
				"remoteAddress" : "http://127.0.0.1:8599/lucee/Component.cfc?wsdl",
				"hint"          : "This is the Base Component",
				"path"          : "/home/elpete/.CommandBox/server/EFAB5F85DB5928A5BC49A57B104C1B0E-coldbox-lucee@5/lucee-5.3.8.206/WEB-INF/lucee-web/context/Component.cfc",
				"displayname"   : "Component",
				"fullname"      : "lucee.Component",
				"synchronized"  : false,
				"properties"    : [],
				"name"          : "lucee.Component",
				"type"          : "component",
				"accessors"     : false,
				"persistent"    : false,
				"functions"     : [],
				"hashCode"      : 1199271094
			},
			"name"       : "test-harness.models.Photos",
			"type"       : "component",
			"accessors"  : true,
			"persistent" : false,
			"functions"  : [
				{
					"access"       : "public",
					"position"     : { "start" : 12, "end" : 14 },
					"hint"         : "Constructor",
					"returnFormat" : "wddx",
					"returntype"   : "Photos",
					"output"       : true,
					"closure"      : false,
					"parameters"   : [],
					"modifier"     : "",
					"name"         : "init",
					"owner"        : "/home/elpete/code/github/ColdBox/coldbox-platform/test-harness/models/Photos.cfc",
					"description"  : ""
				}
			],
			"hashCode" : 546083746
		};
	}

}
