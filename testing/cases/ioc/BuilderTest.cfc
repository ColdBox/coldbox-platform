<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	
	function setup(){
		mockLogger = getMockBox().createEmptyMock("coldbox.system.logging.Logger").$("canDebug",true).$("debug").$("error");
		mockInjector = getMockBox().createEmptyMock("coldbox.system.ioc.Injector")
			.$("getLogbox", getMockBox().createstub().$("getLogger", mockLogger) );
		
		builder = getMockBox().createMock("coldbox.system.ioc.Builder").init( mockInjector );
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
		catch("Injector.ConstructorArgumentNotFoundException" e){}
		catch(Any e){ faile(e); }
	}
	
	function testbuildfeed(){
		mapping = getMockBox().createMock("coldbox.system.ioc.config.Mapping").init("GoogleNews");
		mapping.setPath("http://news.google.com/?output=rss");
		r = builder.buildfeed(mapping);
		debug(r);
		assertTrue( isStruct(r.metadata) );
		assertTrue( isQuery(r.items) );
	}
	
</cfscript>
</cfcomponent>