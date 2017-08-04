<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	this.loadColdBox = false;
	
	function setup(){
		super.setup();
		
		mockColdBox = getMockBox().createEmptyMock("coldbox.system.web.Controller" );
		mockCacheBox =  getMockBox().createEmptyMock("coldbox.system.cache.CacheFactory" );
		mockLogger = getMockBox().createEmptyMock("coldbox.system.logging.Logger" ).$("canDebug",true).$("debug" ).$("error" ).$("canWarn",true).$("warn" );
		mockLogBox = getMockBox().createEmptyMock("coldbox.system.logging.LogBox" ).$("getLogger", mockLogger);
		mockInjector = getMockBox().createEmptyMock("coldbox.system.ioc.Injector" )
			.$("getLogbox", getMockBox().createstub().$("getLogger", mockLogger) )
			.$("getUtil", getMockBox().createMock("coldbox.system.core.util.Util" ))
			.$("isColdBoxLinked",true).$("isCacheBoxLinked",true)
			.$("getColdbox", mockColdbox )
			.$("getLogBox", mockLogBox )
			.$("getCacheBox",mockCacheBox );
		
		builder = getMockBox().createMock("coldbox.system.ioc.Builder" ).init( mockInjector );
		mockStub = createStub();
	}

	function testCacheboxLinkOff(){
		mockInjector.$("isColdBoxLinked", false).$("isCacheBoxLinked", false);
		expectException( "Builder.IllegalDSLException" );
		builder.buildDSLDependency( definition={dsl = "cachebox:default"}, targetID="unit-test", targetObject=getMockBox().createStub() );
	}
	
	function testGetJavaDSL(){
		makePublic(builder, "getJavaDSL" );
		def = {dsl="java:java.util.LinkedHashMap"};
		e = builder.getJavaDSL( def );
		assertTrue( isInstanceOf(e, "java.util.LinkedHashMap" ) );	
	}
	
	function testbuildJavaClass(){
		mapping = getMockBox().createMock("coldbox.system.ioc.config.Mapping" ).init("Buffer" );
		mapping.setPath("java.util.LinkedHashMap" )
			.addDIConstructorArgument(value="3" )
			.addDIConstructorArgument(value="5",javaCast="float" );
		r = builder.buildJavaClass(mapping);
		
		mapping = getMockBox().createMock("coldbox.system.ioc.config.Mapping" ).init("Buffer" );
		mapping.setPath("java.util.LinkedHashMap" );
		r = builder.buildJavaClass(mapping);
		//debug(r);
	}
	
	function testbuildWebservice(){
		mapping = getMockBox().createMock("coldbox.system.ioc.config.Mapping" ).init("Buffer" );
		mapping.setPath( "https://lucee.stg.ortussolutions.com/ExtensionProvider.cfc?wsdl" );
		r = builder.buildwebservice(mapping);
		//debug(r);
	}
	
	function testbuildcfc(){
		// simple cfc
		mapping = getMockBox().createMock("coldbox.system.ioc.config.Mapping" ).init("MyCFC" );
		mapping.setPath("coldbox.test-harness.models.ioc.Simple" );
		r = builder.buildCFC(mapping);
		//debug(r);
	}
	
	function testBuildCFCWithArguments(){
		//mocks
		mockObject = getMockBox().createMock("coldbox.test-harness.models.ioc.Simple" );
		builder.$("buildDSLDependency", mockObject);
		mockInjector.$("getInstance", mockObject )
			.$("containsInstance" ).$args("myBean" ).$results("path.found" )
			.$("containsInstance" ).$args("modelVarNonRequired" ).$results("" );
		
		// With constructor args
		mapping = getMockBox().createMock("coldbox.system.ioc.config.Mapping" ).init("MyCFC" );
		mapping.setPath("coldbox.test-harness.models.ioc.SimpleConstructors" )
			.addDIConstructorArgument( name="constant",value=45)
			.addDIConstructorArgument( name="dslVar",dsl="logbox" )
			.addDIConstructorArgument( name="modelVar",ref="myBean" )
			.addDIConstructorArgument( name="modelVarNonRequired",required="false",ref="modelNotFound" );
		r = builder.buildCFC(mapping);
		//debug(r);
		assertTrue( arrayLen(mockLogger.$callLog().debug) );
	}
	
	function testBuildCFCInjectorException(){
		//mocks
		mockObject = getMockBox().createMock("coldbox.test-harness.models.ioc.Simple" );
		builder.$("buildDSLDependency", mockObject);
		mockInjector.$("containsInstance" ).$results("" );
		
		// With constructor args
		mapping = getMockBox().createMock("coldbox.system.ioc.config.Mapping" ).init("MyCFC" );
		mapping.setPath("coldbox.test-harness.models.ioc.SimpleConstructors" )
			.addDIConstructorArgument( name="constant",value=45)
			.addDIConstructorArgument( name="dslVar",dsl="logbox" )
			.addDIConstructorArgument( name="modelVar",ref="myBean" );
		try{
			r = builder.buildCFC(mapping);
		}
		catch("Injector.ArgumentNotFoundException" e){}
		catch(Any e){ fail(e); }
	}
	
	function testBuildCFCDependencyException(){
		//mocks
		mockObject = getMockBox().createMock("coldbox.test-harness.models.ioc.Simple" );
		builder.$("buildDSLDependency", mockObject);
		mockInjector.$("getInstance", mockObject )
			.$("containsInstance" ).$args("myBean" ).$results("path.found" )
			.$("containsInstance" ).$args("modelVarNonRequired" ).$results("" );
		
		// With constructor args
		mapping = getMockBox().createMock("coldbox.system.ioc.config.Mapping" ).init("MyCFC" );
		mapping.setPath("coldbox.test-harness.models.ioc.SimpleConstructors" )
			.addDIConstructorArgument( name="constant",value=45)
			.addDIConstructorArgument( name="dslVar",dsl="logbox" )
			.addDIConstructorArgument( name="modelVar",ref="myBean" )
			.addDIConstructorArgument( name="modelVarNonRequired",required="false",ref="modelNotFound" )
			.addDIConstructorArgument( name="extraArg", value={"failMe" : true } );
		try{
			r = builder.buildCFC(mapping);
		}
		catch("Builder.BuildCFCDependencyException" e){}
		catch(Any e){ fail(e); }
	}
	
	function testbuildfeed(){
		mapping = getMockBox().createMock("coldbox.system.ioc.config.Mapping" ).init("GoogleNews" );
		mapping.setPath("http://news.google.com/?output=rss" );
		r = builder.buildfeed(mapping);
		debug(r);
		assertTrue( isStruct(r.metadata) );
		assertTrue( isQuery(r.items) );
	}
	
	function testBuildFactoryBean(){
		// map factory bean
		mapping = getMockBox().createMock("coldbox.system.ioc.config.Mapping" ).init("MyFactoryBean" );
		mapping.setPath("factory" ).setMethod("getBean" );
		
		// mocks
		mockTest = getMockBox().createStub();
		mockFactory = getMockBox().createStub().$("getBean", mockTest);
		mockInjector.$("containsInstance",true).$("getInstance",mockFactory);
		
		r = builder.buildFactoryMethod( mapping );
		assertEquals( mockTest, r);
		
		// With Arguments
		mapping.setPath("factory" ).setMethod("getBean" )
			.addDIMethodArgument( name="test",value="1" )
			.addDIMethodArgument( name="num2",value="3" );
		// mocks
		mockTest = getMockBox().createStub();
		mockFactory = getMockBox().createStub().$("getBean" ).$args(test="1",num2="3" ).$results(mockTest);
		mockInjector.$("containsInstance",true).$("getInstance",mockFactory);
		
		r = builder.buildFactoryMethod( mapping );
		assertEquals( mockTest, r);		
	}
	
	function testgetProviderDSL(){
		makePublic(builder,"getProviderDSL" );
		data = {name="luis", dsl="provider:luis"};
		
		// mocks
		mockLuis = getMockBox().createStub();
		scopeInfo = {enabled=true,scope="application",key="wirebox"};
		mockInjector.$("containsInstance",true).$("getInstance", mockLuis)
			.$("getScopeRegistration", scopeInfo)
			.$("getScopeStorage", getMockBox().createEmptyMock("coldbox.system.core.collections.ScopeStorage" )
				.$("exists",true).$("get",mockInjector) );
		
		p = builder.getProviderDSL(data);
		assertEquals(mockLuis, p.get() );
		
	}
	
	function testregisterCustomBuilders(){
		customDSL = {
			coolLuis = "coldbox.tests.specs.ioc.dsl.MyTestingDSL"
		};
		mockBinder = getMockBox().createMock("coldbox.system.ioc.config.Binder" )
			.$("getCustomDSL", customDSL);
		mockInjector.$("getBinder",mockBinder);
		builder.registerCustomBuilders();
		
		custom = builder.getCustomDSL();
		assertEquals( true, structKeyExists(custom, "coolLuis" ) );
	}
	
	function testbuildDSLDependencyCustom(){
		def = {name="test",dsl="coolLuis:woopee" };
		customDSL = {
			coolLuis = "coldbox.tests.specs.ioc.dsl.MyTestingDSL"
		};
		mockBinder = getMockBox().createMock("coldbox.system.ioc.config.Binder" )
			.$("getCustomDSL", customDSL);
		mockInjector.$("getBinder",mockBinder);
		builder.registerCustomBuilders();
		
		test = builder.buildDSLDependency(def, "UnitTest" );
		assertEquals( "woopee", test.getName() );
		
	}
	
	function testbuildSimpleDSL(){
		
		//mocks
		mockStub = getMockBox().createStub().$("verify", true);
		builder.$("buildDSLDependency", mockStub );
		
		// build it
		r = builder.buildSimpleDSL( dsl="logbox:logger:test", targetID="unit", targetObject=mockStub );
		assertEquals( "unit", builder.$callLog().buildDSLDependency[ 1 ].targetID );
		expect( builder.$callLog().buildDSLDependency[ 1 ].targetObject ).toBe( mockStub );
		assertEquals( "logbox:logger:test", builder.$callLog().buildDSLDependency[ 1 ].definition.dsl );
		assertEquals( "", builder.$callLog().buildDSLDependency[ 1 ].definition.name );
		
	}
	
	function testgetWireBoxDSL(){
		makePublic(builder,"getWireBoxDSL" );
		var data = {name="luis", dsl="wirebox"};
		
		// wirebox
		var p = builder.getWireBoxDSL(data);
		expect(	getMetadata( p ).name ).toMatch( "Injector" );
		
		// wirebox:parent
		data = {name="luis", dsl="wirebox:parent"};
		mockInjector.$("getParent","" );
		p = builder.getWireBoxDSL(data);
		assertEquals("", p);
		
		//wirebox:eventmanager
		data = {name="luis", dsl="wirebox:eventManager"};
		mockEventManager = getMockBox().createEmptyMock("coldbox.system.core.events.EventPoolManager" );
		mockInjector.$("getEventManager",mockEventManager);
		p = builder.getWireBoxDSL(data);
		assertEquals(mockEventManager, p);
		
		//wirebox:binder
		data = {name="luis", dsl="wirebox:binder"};
		mockBinder = getMockBox().createMock("coldbox.system.ioc.config.Binder" );
		mockInjector.$("getBinder",mockBinder);
		p = builder.getWireBoxDSL(data);
		assertEquals(mockBinder, p);
		
		//wirebox:populator
		data = {name="luis", dsl="wirebox:populator"};
		populator = getMockBox().createEmptyMock("coldbox.system.core.dynamic.BeanPopulator" );
		mockInjector.$("getObjectPopulator", populator);
		p = builder.getWireBoxDSL(data);
		assertEquals(populator, p);
		
		//wirebox:scope
		data = {name="luis", dsl="wirebox:scope:singleton"};
		mockScope = getMockBox().createEmptyMock("coldbox.system.ioc.scopes.Singleton" );
		mockInjector.$("getScope", mockScope);
		p = builder.getWireBoxDSL(data);
		assertEquals(mockScope, p);
		
		//wirebox:properties
		data = {name="luis", dsl="wirebox:properties"};
		props = {prop1='hello',name="luis"};
		mockBinder = getMockBox().createMock("coldbox.system.ioc.config.Binder" )
			.$("getProperties", props);
		mockInjector.$("getBinder",mockBinder);
		p = builder.getWireBoxDSL(data);
		assertEquals( props, p);
	
		//wirebox:property:{}
		data = {name="luis", dsl="wirebox:property:name"};
		props = {prop1='hello',name="luis"};
		mockBinder = getMockBox().createMock("coldbox.system.ioc.config.Binder" ).setProperties( props );
		mockInjector.$("getBinder",mockBinder);
		p = builder.getWireBoxDSL(data);
		assertEquals( "luis", p);	
	}
	
	function testbuildProviderMixer(){
		// mocks
		mockLuis = getMockBox().createStub();
		mockTarget = getMockBox().createStub();
		scopeInfo = {enabled=true, scope="application", key="wirebox"};
		mockInjector.$("getInstance", mockLuis)
			.$("containsInstance", true);
		scopeStorage = getMockBox().createStub()
				.$( "exists",true )
				.$( "get", mockInjector );
		
		// inject mocks on target
		mockTarget.$wbscopeInfo    = scopeInfo;
		mockTarget.$wbScopeStorage = scopeStorage;
		mockTarget.$wbProviders  = { buildProviderMixer = "luis" };
		mockTarget.buildProviderMixer = builder.buildProviderMixer;
		
		// 1. Via mapping first
		p = mockTarget.buildProviderMixer();
		assertEquals( "luis", mockInjector.$callLog().getInstance[ 1 ].name );
		assertEquals( mockLuis, p );
		
		// 2. Via DSL
		mockInjector.$("getInstance", mockLuis)
			.$("containsInstance", false);
		mockTarget.$wbProviders  = { buildProviderMixer = "logbox:logger:{this}" };
		p = mockTarget.buildProviderMixer();
		assertEquals( "logbox:logger:{this}", mockInjector.$callLog().getInstance[ 1 ].dsl );
		assertEquals( mockLuis, p );		
	}
	
</cfscript>
</cfcomponent>