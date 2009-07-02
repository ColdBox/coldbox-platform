<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	function setup(){
		logbox = getMockBox().createMock(className="coldbox.system.logging.LogBox").init();
	}
	
	function testProperties(){
		assertTrue( len(logbox.getHash()) );
		assertTrue( structIsEmpty( logbox.getLoggers() ));
		assertFalse( logBox.hasLoggers() );
	}
	function testRegister(){
		logger = createObject("component","coldbox.system.logging.AbstractLogger").init(name="Luis");
		logBox.register(logger);
		logBox.register(logger);
		
		logger = createObject("component","coldbox.system.logging.AbstractLogger");
		try{
			logBox.register(logger);
			fail("this should have failed, no name.");
		}
		catch("LogBox.InvalidLoggerNameException" e){}
		catch(Any e){ fail(e.message & e.detail); }		
	}
	function testcreateAndRegister(){
		// Mock call, already tested
		logBox.$("register");
		//1: Basics
		logger = logBox.registerNew(name='unitTest',class="coldbox.system.logging.AbstractLogger");
		assertEquals( logger.getLogLevel(), logger.logLevels.TRACE);
		
		//2: with defaults
		logger = logBox.registerNew(name='unitTest',class="coldbox.system.logging.AbstractLogger",level=logbox.logLevels.WARNING,category="Luis");
		assertEquals( logger.getLogLevel(), logger.logLevels.WARNING);
		
		//3: with properties
		propMap = {file="#expandPath('.')#unitTest.txt",charset='utf-8'};
		logger = logBox.registerNew(name='unitTest',class="coldbox.system.logging.AbstractLogger",properties=propMap);
		assertEquals( logger.getLogLevel(), logger.logLevels.TRACE);
		assertEquals( logger.getProperties(), propmap);
		assertEquals( logger.getProperty('file'), propmap.file);
	}
	function testLogMessage(){
		makePublic(logBox,"logMessage");
		
		logBox.logMessage("hello",1);
	}
	function testregisterWithConfig(){
		config = createObject("component","coldbox.system.logging.config.LogBoxConfig").init();
		config.add("luis","coldbox.system.logging.AbstractLogger");
		config.add("luis2","coldbox.system.logging.AbstractLogger");
		logBox.registerConfig(config);
	}
</cfscript>
</cfcomponent>