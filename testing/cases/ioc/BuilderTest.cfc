<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	
	function setup(){
		mockColdBox = getMockBox().createEmptyMock("coldbox.system.web.Controller");
		mockCacheBox =  getMockBox().createEmptyMock("coldbox.system.cache.CacheFactory");
		mockLogger = getMockBox().createEmptyMock("coldbox.system.logging.Logger").$("canDebug",true).$("debug").$("error").$("canWarn",true).$("warn");
		mockLogBox = getMockBox().createEmptyMock("coldbox.system.logging.LogBox").$("getLogger", mockLogger);
		mockInjector = getMockBox().createEmptyMock("coldbox.system.ioc.Injector")
			.$("getLogbox", getMockBox().createstub().$("getLogger", mockLogger) )
			.$("getUtil", getMockBox().createMock("coldbox.system.core.util.Util"))
			.$("isColdBoxLinked",true).$("isCacheBoxLinked",true)
			.$("getColdbox", mockColdbox )
			.$("getLogBox", mockLogBox )
			.$("getCacheBox",mockCacheBox );
		
		builder = getMockBox().createMock("coldbox.system.ioc.Builder").init( mockInjector );
	}
	
	function testGetEntityServiceDSL(){
		makePublic(builder, "getEntityServiceDSL");
		def = {dsl="entityService"};
		e = builder.getentityServiceDSL(def);
		assertTrue( isInstanceOf(e, "coldbox.system.orm.hibernate.BaseORMService") );	
		
		def = {dsl="entityService:User"};
		e = builder.getentityServiceDSL(def);
		assertTrue( isInstanceOf(e, "coldbox.system.orm.hibernate.VirtualEntityService") );	
	}
	
	function testbuildJavaClass(){
		mapping = getMockBox().createMock("coldbox.system.ioc.config.Mapping").init("Buffer");
		mapping.setPath("java.util.LinkedHashMap")
			.addDIConstructorArgument(value="3")
			.addDIConstructorArgument(value="5",javaCast="float");
		r = builder.buildJavaClass(mapping);
		
		mapping = getMockBox().createMock("coldbox.system.ioc.config.Mapping").init("Buffer");
		mapping.setPath("java.util.LinkedHashMap");
		r = builder.buildJavaClass(mapping);
		debug(r);
	}
	
	function testbuildWebservice(){
		mapping = getMockBox().createMock("coldbox.system.ioc.config.Mapping").init("Buffer");
		mapping.setPath("http://www.coldbox.org/distribution/updatews.cfc?wsdl");
		r = builder.buildwebservice(mapping);
		debug(r);
	}
	
	function testbuildcfc(){
		// simple cfc
		mapping = getMockBox().createMock("coldbox.system.ioc.config.Mapping").init("MyCFC");
		mapping.setPath("coldbox.testing.testmodel.ioc.Simple");
		r = builder.buildCFC(mapping);
		debug(r);
	}
	
	function testBuildCFCWithArguments(){
		//mocks
		mockObject = getMockBox().createMock("coldbox.testing.testmodel.ioc.Simple");
		builder.$("buildDSLDependency", mockObject);
		mockInjector.$("getInstance", mockObject )
			.$("containsInstance").$args("myBean").$results("path.found")
			.$("containsInstance").$args("modelVarNonRequired").$results("");
		
		// With constructor args
		mapping = getMockBox().createMock("coldbox.system.ioc.config.Mapping").init("MyCFC");
		mapping.setPath("coldbox.testing.testmodel.ioc.SimpleConstructors")
			.addDIConstructorArgument(name="constant",value=45)
			.addDIConstructorArgument(name="dslVar",dsl="logbox")
			.addDIConstructorArgument(name="modelVar",ref="myBean")
			.addDIConstructorArgument(name="modelVarNonRequired",required="false",ref="modelNotFound");
		r = builder.buildCFC(mapping);
		//debug(r);
		assertTrue( arrayLen(mockLogger.$callLog().debug) );
	}
	
	function testBuildCFCException(){
		//mocks
		mockObject = getMockBox().createMock("coldbox.testing.testmodel.ioc.Simple");
		builder.$("buildDSLDependency", mockObject);
		mockInjector.$("containsInstance").$results("");
		
		// With constructor args
		mapping = getMockBox().createMock("coldbox.system.ioc.config.Mapping").init("MyCFC");
		mapping.setPath("coldbox.testing.testmodel.ioc.SimpleConstructors")
			.addDIConstructorArgument(name="constant",value=45)
			.addDIConstructorArgument(name="dslVar",dsl="logbox")
			.addDIConstructorArgument(name="modelVar",ref="myBean");
		try{
			r = builder.buildCFC(mapping);
		}
		catch("Injector.ArgumentNotFoundException" e){}
		catch(Any e){ fail(e); }
	}
	
	function testbuildfeed(){
		mapping = getMockBox().createMock("coldbox.system.ioc.config.Mapping").init("GoogleNews");
		mapping.setPath("http://news.google.com/?output=rss");
		r = builder.buildfeed(mapping);
		debug(r);
		assertTrue( isStruct(r.metadata) );
		assertTrue( isQuery(r.items) );
	}
	
	function testBuildFactoryBean(){
		// map factory bean
		mapping = getMockBox().createMock("coldbox.system.ioc.config.Mapping").init("MyFactoryBean");
		mapping.setPath("factory").setMethod("getBean");
		
		// mocks
		mockTest = getMockBox().createStub();
		mockFactory = getMockBox().createStub().$("getBean", mockTest);
		mockInjector.$("containsInstance",true).$("getInstance",mockFactory);
		
		r = builder.buildFactoryMethod( mapping );
		assertEquals( mockTest, r);
		
		// With Arguments
		mapping.setPath("factory").setMethod("getBean")
			.addDIMethodArgument(name="test",value="1")
			.addDIMethodArgument(name="num2",value="3");
		// mocks
		mockTest = getMockBox().createStub();
		mockFactory = getMockBox().createStub().$("getBean").$args(test="1",num2="3").$results(mockTest);
		mockInjector.$("containsInstance",true).$("getInstance",mockFactory);
		
		r = builder.buildFactoryMethod( mapping );
		assertEquals( mockTest, r);		
	}
	
	function testgetProviderDSL(){
		makePublic(builder,"getProviderDSL");
		data = {name="luis", dsl="provider:luis"};
		
		// mocks
		mockLuis = getMockBox().createStub();
		scopeInfo = {enabled=true,scope="application",key="wirebox"};
		mockInjector.$("containsInstance",true).$("getInstance", mockLuis)
			.$("getScopeRegistration", scopeInfo)
			.$("getScopeStorage", getMockBox().createEmptyMock("coldbox.system.core.collections.ScopeStorage")
				.$("exists",true).$("get",mockInjector) );
		
		p = builder.getProviderDSL(data);
		assertEquals(mockLuis, p.get() );
		
	}
	
	function testregisterCustomBuilders(){
		customDSL = {
			coolLuis = "coldbox.testing.cases.ioc.dsl.MyTestingDSL"
		};
		mockBinder = getMockBox().createMock("coldbox.system.ioc.config.Binder")
			.$("getCustomDSL", customDSL);
		mockInjector.$("getBinder",mockBinder);
		builder.registerCustomBuilders();
		
		custom = builder.getCustomDSL();
		assertEquals( true, structKeyExists(custom, "coolLuis") );
	}
	
	function testbuildDSLDependencyCustom(){
		def = {name="test",dsl="coolLuis:woopee" };
		customDSL = {
			coolLuis = "coldbox.testing.cases.ioc.dsl.MyTestingDSL"
		};
		mockBinder = getMockBox().createMock("coldbox.system.ioc.config.Binder")
			.$("getCustomDSL", customDSL);
		mockInjector.$("getBinder",mockBinder);
		builder.registerCustomBuilders();
		
		test = builder.buildDSLDependency(def, "UnitTest");
		assertEquals( "woopee", test.getName() );
		
	}
	
	function testgetWireBoxDSL(){
		makePublic(builder,"getWireBoxDSL");
		data = {name="luis", dsl="wirebox"};
		
		// wirebox
		p = builder.getWireBoxDSL(data);
		assertEquals(mockInjector, p);
		
		// wirebox:parent
		data = {name="luis", dsl="wirebox:parent"};
		mockInjector.$("getParent","");
		p = builder.getWireBoxDSL(data);
		assertEquals("", p);
		
		//wirebox:eventmanager
		data = {name="luis", dsl="wirebox:eventManager"};
		mockEventManager = getMockBox().createEmptyMock("coldbox.system.core.events.EventPoolManager");
		mockInjector.$("getEventManager",mockEventManager);
		p = builder.getWireBoxDSL(data);
		assertEquals(mockEventManager, p);
		
		//wirebox:binder
		data = {name="luis", dsl="wirebox:binder"};
		mockBinder = getMockBox().createMock("coldbox.system.ioc.config.Binder");
		mockInjector.$("getBinder",mockBinder);
		p = builder.getWireBoxDSL(data);
		assertEquals(mockBinder, p);
		
		//wirebox:populator
		data = {name="luis", dsl="wirebox:populator"};
		populator = getMockBox().createEmptyMock("coldbox.system.core.dynamic.BeanPopulator");
		mockInjector.$("getObjectPopulator", populator);
		p = builder.getWireBoxDSL(data);
		assertEquals(populator, p);
		
		//wirebox:scope
		data = {name="luis", dsl="wirebox:scope:singleton"};
		mockScope = getMockBox().createEmptyMock("coldbox.system.ioc.scopes.Singleton");
		mockInjector.$("getScope", mockScope);
		p = builder.getWireBoxDSL(data);
		assertEquals(mockScope, p);
		
		//wirebox:properties
		data = {name="luis", dsl="wirebox:properties"};
		props = {prop1='hello',name="luis"};
		mockBinder = getMockBox().createMock("coldbox.system.ioc.config.Binder")
			.$("getProperties", props);
		mockInjector.$("getBinder",mockBinder);
		p = builder.getWireBoxDSL(data);
		assertEquals( props, p);
	
		//wirebox:property:{}
		data = {name="luis", dsl="wirebox:property:name"};
		props = {prop1='hello',name="luis"};
		mockBinder = getMockBox().createMock("coldbox.system.ioc.config.Binder").setProperties( props );
		mockInjector.$("getBinder",mockBinder);
		p = builder.getWireBoxDSL(data);
		assertEquals( "luis", p);	
	}
	
	function testbuildProviderMixer(){
		// mocks
		mockLuis = getMockBox().createStub();
		scopeInfo = {enabled=true,scope="application",key="wirebox"};
		scopeStorage = getMockBox().createEmptyMock("coldbox.system.core.collections.ScopeStorage")
				.$("exists",true).$("get",mockInjector);
		mockInjector.$("getInstance", mockLuis);
		
		//mocks
		builder.$wbscopeInfo    = scopeInfo;
		builder.$wbScopeStorage = scopeStorage;
		builder.$wbProviders  = {buildProviderMixer="luis"};
		
		p = builder.buildProviderMixer();
		assertEquals(mockLuis, p );		
	}
	
</cfscript>
</cfcomponent>