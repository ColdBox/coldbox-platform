<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author      :	Sana Ullah
Date        :	Jan 13, 2009
Description :   Logger Plugin Test
----------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.testing.BasePluginTest"
			 plugin="coldbox.system.plugins.Logger">
<cfscript>

	function setup(){
		super.setup();
		mockController.$("getSetting").$args("AppName").$results("UnitTesting");
		logger = plugin.init(mockController);
		// setup mocking
		mockDebuggerService = getMockBox().createStub().$("pushTracer");
		mockController.$("getDebuggerService", mockDebuggerService );
		mockLogger.$("debug").$("info").$("error").$("warn").$("fatal");
		complex = {
			data=createUUID(),
			name="unit tTest",
			date = now()
		};
	}

	function testGetLogger(){
		log = logger.getLogger();
		assertTrue( isOBject(log) );
	}
	function testDebug(){
		logger.debug("Hello", complex);
		assertEquals("Hello", mockLogger.$callLog().debug[1].message);
		assertEquals(complex, mockLogger.$callLog().debug[1].extrainfo);
	}
	function testInfo(){
		logger.info("Hello", complex);
		assertEquals("Hello", mockLogger.$callLog().info[1].message);
		assertEquals(complex, mockLogger.$callLog().info[1].extrainfo);
	}
	function testWarn(){
		logger.warn("Hello", complex);
		assertEquals("Hello", mockLogger.$callLog().warn[1].message);
		assertEquals(complex, mockLogger.$callLog().warn[1].extrainfo);
	}
	function testError(){
		logger.error("Hello", complex);
		assertEquals("Hello", mockLogger.$callLog().error[1].message);
		assertEquals(complex, mockLogger.$callLog().error[1].extrainfo);
	}
	function testFatal(){
		logger.fatal("Hello", complex);
		assertEquals("Hello", mockLogger.$callLog().fatal[1].message);
		assertEquals(complex, mockLogger.$callLog().fatal[1].extrainfo);
	}
	
	function testTracer(){
		logger.tracer("hello", complex);
		assertEquals("Hello", mockDebuggerService.$callLog().pushTracer[1].message);
		assertEquals(complex, mockDebuggerService.$callLog().pushTracer[1].extrainfo);
	}
</cfscript>
</cfcomponent>
