<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date        :	September 3, 2007
Description :
	debugger service tests

Modification History:
01/18/2007 - Created
----------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.testing.BasePluginTest" plugin="coldbox.system.plugins.IOC">
<cfscript>
	function setup(){
		super.setup();
		
		//namespace the plugin test target
		ioc = plugin;
		mockLogger.$("info").$("error").$("debug").$("canInfo", false).$("CanDebug", false);
		mockController.$("getAppRootPath",expandPath("/coldbox/test-harness"));
		mockController.$("getConfigSettings",structnew());
		application.cbController = mockController;
		
		// Mock Bean Factory
		mockBF = getMockBox().createEmptyMock( "coldbox.system.plugins.BeanFactory" )
			.$("autowire");
		ioc.$( "getPlugin", mockBF ); 
		
	}
	
	function teardown(){
		super.teardown();
		structDelete(application,"cbController");
	}
	
	function testBuildAdapter(){
		ioc.$("getSetting").$args("IOCObjectCaching").$results("false");
		ioc.$("getSetting").$args("IOCFramework").$results("coldspring");
		ioc.init( mockController );
		makePublic( ioc, "buildAdapter" );
		
		// established path
		factory = ioc.buildAdapter( "coldspring", "/coldbox/test-harness/config/coldspring.xml.cfm" );
		assertTrue( isObject( factory ) );
		
		// custom path
		factory = ioc.buildAdapter( "coldbox.system.ioc.adapters.ColdSpringAdapter", "/coldbox/test-harness/config/coldspring.xml.cfm" );
		assertTrue( isObject( factory ) );
	}
	
	function testConfigure(){
		ioc.$("getSetting").$args("IOCObjectCaching").$results("false");
		ioc.$("getSetting").$args("IOCFramework").$results("coldspring");
		ioc.$("getSetting").$args("IOCDefinitionFile").$results("/coldbox/test-harness/config/coldspring.xml.cfm");
		ioc.$("getSetting").$args("IOCParentFactory").$results("");
		ioc.$("getSetting").$args("IOCParentFactoryDefinitionFile").$results("");
		
		ioc.init( mockController ).configure();
		//debug( ioc.getAdapter() );
		assertTrue( isObject( ioc.getAdapter().getFactory() ) );
	}
	
	function testConfigureWithParent(){
		ioc.$("getSetting").$args("IOCObjectCaching").$results("false");
		ioc.$("getSetting").$args("IOCFramework").$results("coldspring");
		ioc.$("getSetting").$args("IOCDefinitionFile").$results("/coldbox/test-harness/config/coldspring.xml.cfm");
		ioc.$("getSetting").$args("IOCParentFactory").$results("coldspring");
		ioc.$("getSetting").$args("IOCParentFactoryDefinitionFile").$results("/coldbox/testing/resources/coldspring.xml.cfm");
		
		ioc.init( mockController ).configure();
		
		debug( ioc.getAdapter().getFactory() );
		debug( ioc.getAdapter().getParentFactory() );
		assertTrue( isObject( ioc.getAdapter().getFactory() ) );
		assertTrue( isObject( ioc.getAdapter().getParentFactory() ) );
	}
	
	function testGetBean(){
		// mock setup
		ioc.$("getSetting").$args("IOCFramework").$results("coldspring");
		ioc.$("getSetting").$args("IOCDefinitionFile").$results("/coldbox/test-harness/config/coldspring.xml.cfm");
		ioc.$("getSetting").$args("IOCObjectCaching").$results(false);
		ioc.$("getSetting").$args("IOCParentFactory").$results("");
		ioc.$("getSetting").$args("IOCParentFactoryDefinitionFile").$results("");
		ioc.init( mockController ).configure();
		
		// No Object Caching
		service = ioc.getBean("testService");
		assertTrue( isObject( service ) );
		assertEquals(1, mockBF.$count("autowire") );
	}
	
	function testGetBeanWithCaching(){
		// mock setup
		ioc.$("getSetting").$args("IOCFramework").$results("coldspring");
		ioc.$("getSetting").$args("IOCDefinitionFile").$results("/coldbox/test-harness/config/coldspring.xml.cfm");
		ioc.$("getSetting").$args("IOCObjectCaching").$results(true);
		ioc.$("getSetting").$args("IOCParentFactory").$results("");
		ioc.$("getSetting").$args("IOCParentFactoryDefinitionFile").$results("");
		ioc.init( mockController ).configure();
		
		// With object caching
		// mock cache
		mockService = getMockBox().createStub();
		mockCache = getMockBox().createStub().$("get", mockService);
		ioc.$("getColdboxOCM", mockCache ).$("processObjectCaching");
		
		service = ioc.getBean( "testService" );
		
		assertTrue( isObject( service ) );
		assertEquals( mockService, service );
		assertEquals( 0, mockBF.$count("autowire") );
		assertEquals( 0, ioc.$count("processObjectCaching") );
		
		// Not found in cache
		mockCache.$( "get", javaCast("null","") );
		service = ioc.getBean("testService");
		
		assertTrue( isObject(service) );
		assertEquals(1, mockBF.$count("autowire") );
		assertEquals(1, ioc.$count("processObjectCaching") );
	}
	
	function testGetIOCFactory(){
		testConfigure();
		assertTrue( isObject(ioc.getIOCFactory() ) );
	}
	
	function testContainsBean(){
		testConfigure();
		assertFalse( ioc.containsBean("Bogus") );
		assertTrue( ioc.containsBean("testService") );
	}
	
	function testReloadDefinitionFile(){
		testConfigure();
		ioc.$("configure");
		ioc.reloadDefinitionFile();
		debug( ioc.$callLog().configure );
		assertEquals( 1, ioc.$count("configure") );
	}
</cfscript>
</cfcomponent>