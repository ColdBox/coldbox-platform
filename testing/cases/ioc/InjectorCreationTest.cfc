<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	
	function setup(){
		// init with defaults
		injector = getMockBox().createMock("coldbox.system.ioc.Injector");
		//2: WireBox Binder instance
		binder = getMockBox().createMock("coldbox.testing.cases.ioc.config.samples.InjectorCreationTestsBinder");
		// init injector
		injector.init(binder);
		// mock lock
		mockLogger = getMockBox().createEmptyMock("coldbox.system.logging.Logger").$("canDebug",true).$("debug");
		injector.$property("log","instance",mockLogger);
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
	
	function testbuildJavaClass(){
		makePublic(injector,"buildJavaClass");
		mapping = getMockBox().createMock("coldbox.system.ioc.config.Mapping").init("Buffer");
		mapping.setPath("java.util.LinkedHashMap")
			.addDIConstructorArgument(value="3")
			.addDIConstructorArgument(value="5",javaCast="float");
		r = injector.buildJavaClass(mapping);
		//debug(r);
	}
	
</cfscript>
</cfcomponent>