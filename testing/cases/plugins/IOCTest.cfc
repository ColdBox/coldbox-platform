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
		ioc.$("getSetting").$args("IOCFrameworkDefinitionFile").$results("/coldbox/testharness/config/coldspring.xml.cfm");
		ioc.$("getSetting").$args("IOCParentFactory").$results("");
		ioc.$("getSetting").$args("IOCParentFactoryDefinitionFile").$results("");
		
		ioc.init( mockController );
		assertTrue( isObject(ioc.getAdapter().getFactory()) );
		
	}
	
	function testConfigureWithParent(){
		ioc.$("getSetting").$args("IOCFramework").$results("coldspring");
		ioc.$("getSetting").$args("IOCFrameworkDefinitionFile").$results("/coldbox/testharness/config/coldspring.xml.cfm");
		ioc.$("getSetting").$args("IOCParentFactory").$results("coldspring");
		ioc.$("getSetting").$args("IOCParentFactoryDefinitionFile").$results("/coldbox/testing/resources/coldspring.xml.cfm");
		ioc.init( mockController );
		
		assertTrue( isObject(ioc.getAdapter().getParentFactory()) );
	}
</cfscript>
</cfcomponent>