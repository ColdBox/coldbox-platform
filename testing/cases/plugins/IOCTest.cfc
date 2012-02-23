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
<cfcomponent extends="coldbox.system.testing.BasePluginTest" output="false" plugin="coldbox.system.plugins.IOC">
<cfscript>
	function setup(){
		super.setup();
		
		//namespace the plugin test target
		ioc = plugin;
		mockLogger.$("info").$("error").$("debug");
		mockController.$("getAppRootPath",expandPath("/coldbox/testharness"));
		mockController.$("getConfigSettings",structnew());
		application.cbController = mockController;
	}
	function teardown(){
		structDelete(application,"cbController");
	}
	function testConfigure(){
		ioc.$("getSetting").$args("IOCFramework").$results("coldspring");
		ioc.$("getSetting").$args("IOCDefinitionFile").$results("/coldbox/testharness/config/coldspring.xml.cfm");
		ioc.$("getSetting").$args("IOCParentFactory").$results("");
		ioc.$("getSetting").$args("IOCParentFactoryDefinitionFile").$results("");
		
		ioc.init( mockController );
		assertTrue( isObject(ioc.getAdapter().getFactory()) );
		
	}
	
	function testConfigureWithParent(){
		ioc.$("getSetting").$args("IOCFramework").$results("coldspring");
		ioc.$("getSetting").$args("IOCDefinitionFile").$results("/coldbox/testharness/config/coldspring.xml.cfm");
		ioc.$("getSetting").$args("IOCParentFactory").$results("coldspring");
		ioc.$("getSetting").$args("IOCParentFactoryDefinitionFile").$results("/coldbox/testing/resources/coldspring.xml.cfm");
		ioc.init( mockController );
		
		assertTrue( isObject(ioc.getAdapter().getParentFactory()) );
	}
	
	function testGetBean(){
		testConfigure();
		// mock bean factory
		mockBeanFactory = getMockBox().createStub().$("autowire");
		ioc.$("getPlugin", mockBeanFactory);
		ioc.$("getSetting").$args("IOCObjectCaching").$results(false,true,true);
		
		// No Object Caching
		service = ioc.getBean("testService");
		assertTrue( isObject(service) );
		assertEquals(1, mockBeanFactory.$count("autowire") );
		
		// With object caching
		// mock cache
		mockCache = getMockBox().createStub().$("get", service);
		ioc.$("getColdboxOCM",mockCache);
		ioc.$("processObjectCaching");
		service = ioc.getBean("testService");
		assertTrue( isObject(service) );
		assertEquals(1, mockBeanFactory.$count("autowire") );
		assertEquals(0, ioc.$count("processObjectCaching") );
		
		// Not found in cache
		mockCache.$("get", javaCast("null",""));
		service = ioc.getBean("testService");
		assertTrue( isObject(service) );
		assertEquals(2, mockBeanFactory.$count("autowire") );
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