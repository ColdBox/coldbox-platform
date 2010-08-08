<cfcomponent extends="coldbox.system.testing.BaseTestCase" output="false">
<cfscript>
	function setup(){
		interceptor 	= getMockBox().createMock(className="coldbox.system.Interceptor");
		mockIService 	= getMockBox().createMock(className="coldbox.system.web.services.InterceptorService",clearMethods=true);
		mockController  = getMockBox().createMock(className="coldbox.system.web.Controller");
		mockRS 			= getMockBox().createMock(className="coldbox.system.web.services.RequestService");
		flashScope 		= getMockBox().createMock(className="coldbox.system.web.flash.MockFlash");
		mockLogBox 		= getMockBox().createMock(className="coldbox.system.logging.LogBox");
		mockLogger 		= getMockBox().createMock(className="coldbox.system.logging.Logger");
		
		
		mockController.$("getLogBox",mockLogBox);
		mockController.$("getRequestService",mockRS);
		mockRS.$("getFlashScope",flashScope);
		mockLogBox.$("getLogger",mockLogger);
		
		
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
		mockBuffer = getMockBox().createMock(className="coldbox.system.core.util.RequestBuffer").init();
		mockIService.$("getRequestBuffer",mockBuffer);
		
		interceptor.appendToBuffer("Hello");
		assertEquals( interceptor.getBufferString(), "Hello" );
		assertEquals( interceptor.getBufferObject(), mockBuffer);
		
		interceptor.clearBuffer();
		assertEquals( interceptor.getBufferString(), "" );
		
	}
	

</cfscript>	
</cfcomponent>