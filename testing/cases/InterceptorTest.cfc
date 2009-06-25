<cfcomponent extends="coldbox.system.testing.BaseTestCase" output="false">
<cfscript>
	function setup(){
		interceptor = getMockBox().createMock(className="coldbox.system.Interceptor");
		mockController = getMockBox().createMock("coldbox.system.Controller");
		mockIService = getMockBox().createMock(className="coldbox.system.services.InterceptorService",clearMethods=true);
		
		properties = {debugmode=true,configFile='config/routes.cfm'};
		interceptor.init(mockController,properties);
		interceptor.$("getInterceptorService",mockIService);
	}
	
	function testProperties(){
		assertEquals( interceptor.getProperty("debugMode"), true );
		interceptor.setProperty("luis","majano");
		assertEquals( interceptor.getProperty("luis"), "majano" );
		
		assertTrue( interceptor.propertyExists("luis") );
	}
	
	function testUnregister(){
		mockController.$("getInterceptorService",mockIService);
		mockIService.$("unregister",true);
		
		interceptor.unregister("preProcess");
		assertEquals( mockIService.$count("unregister"), 1 );
	}
	function testRequestBuffer(){
		mockBuffer = getMockBox().createMock(className="coldbox.system.util.RequestBuffer").init();
		mockIService.$("getRequestBuffer",mockBuffer);
		
		interceptor.appendToBuffer("Hello");
		assertEquals( interceptor.getBufferString(), "Hello" );
		assertEquals( interceptor.getBufferObject(), mockBuffer);
		
		interceptor.clearBuffer();
		assertEquals( interceptor.getBufferString(), "" );
		
	}
	

</cfscript>	
</cfcomponent>