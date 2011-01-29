<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	
	function setup(){
		// init with defaults
		injector = getMockBox().createMock("coldbox.system.ioc.Injector");
		//2: WireBox Binder instance
		binder = getMockBox().createMock("coldbox.testing.cases.ioc.config.samples.InjectorCreationTestsBinder");
		// init injector
		injector.init(binder);
		// mock logger
		mockLogger = getMockBox().createEmptyMock("coldbox.system.logging.Logger").$("canDebug",true).$("debug");
		injector.$property("log","instance",mockLogger);
		// mock event manager
		getMockBox().prepareMock( injector.getEventManager() );
	}
	
	function testLocateInstance(){
		// Locate by package scan
		r = injector.locateInstance("ioc.category.CategoryBean");
		assertEquals("coldbox.testing.testmodel.ioc.category.CategoryBean", r);
		
		// Locate Not Found
		r = injector.locateInstance("com.com.com.Whatever");
		assertEquals('', r);
		
		// Locate by Full Path
		r = injector.locateInstance("coldbox.system.Plugin");
		assertEquals("coldbox.system.Plugin", r);
	}
		
	function testConstant(){
	
		// get Constant
		//r = injector.getInstance("jsonProperty");
		
	}
	
	function testByConvention(){
	
		//r = injector.getInstance("ioc.category.categoryService");
	}
	
	function testbuildInstance(){
		//mapping
		mapping = getMockBox().createMock("coldbox.system.ioc.config.Mapping").init("MyTest");
		// mocks
		mockBuilder = getMockBox().createMock("coldbox.system.ioc.Builder").init( injector );
		injector.$property("builder","instance",mockBuilder);
		mockStub = getMockbox().createStub();
		injector.getEventManager().$("process");
		
		// CFC
		mapping.setType("cfc");
		mockBuilder.$("buildCFC", mockStub);
		val = injector.buildInstance( mapping );
		assertEquals(mockStub, val);
		
		// JAVA
		mapping.setType("java");
		mockBuilder.$("buildJavaClass", mockStub);
		val = injector.buildInstance( mapping );
		assertEquals(mockStub, val);
		
		// Webservice
		mapping.setType("webservice");
		mockBuilder.$("buildWebService", mockStub);
		val = injector.buildInstance( mapping );
		assertEquals(mockStub, val);
		
		// Feed
		mapping.setType("rss");
		mockBuilder.$("buildFeed", mockStub);
		val = injector.buildInstance( mapping );
		assertEquals(mockStub, val);
		
		// Constant
		mapping.setType("constant").setValue("testbaby");
		val = injector.buildInstance( mapping );
		assertEquals("testbaby", val);
	}
	
</cfscript>
</cfcomponent>