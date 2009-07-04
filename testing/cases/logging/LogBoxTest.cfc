<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	function setup(){
		logbox = getMockBox().createMock(className="coldbox.system.logging.LogBox").init();
	}
	
	function testProperties(){
		assertTrue( len(logbox.getHash()) );
		assertFalse( logBox.hasAppenders() );
	}
	function testRegister(){
		appender = createObject("component","coldbox.system.logging.AbstractAppender").init(name="Luis");
		logBox.register(appender);
		logBox.register(appender);
		
		appender = createObject("component","coldbox.system.logging.AbstractAppender");
		try{
			logBox.register(appender);
			fail("this should have failed, no name.");
		}
		catch("LogBox.InvalidAppenderNameException" e){}
		catch(Any e){ fail(e.message & e.detail); }		
	}
	function testcreateAndRegister(){
		// Mock call, already tested
		logBox.$("register");
		//1: Basics
		appender = logBox.registerNew(name='unitTest',class="coldbox.system.logging.AbstractAppender");
		assertEquals( appender.getLevelMax(), appender.logLevels.TRACE);
		
		//2: with defaults
		appender = logBox.registerNew(name='unitTest',class="coldbox.system.logging.AbstractAppender",levelMax=logbox.logLevels.WARNING,category="Luis");
		assertEquals( appender.getLevelMax(), appender.logLevels.WARNING);
		
		//3: with properties
		propMap = {file="#expandPath('.')#unitTest.txt",charset='utf-8'};
		appender = logBox.registerNew(name='unitTest',class="coldbox.system.logging.AbstractAppender",properties=propMap);
		assertEquals( appender.getLevelMax(), appender.logLevels.TRACE);
		assertEquals( appender.getProperties(), propmap);
		assertEquals( appender.getProperty('file'), propmap.file);
	}
	function testLogMessage(){
		makePublic(logBox,"logMessage");
		
		logBox.logMessage("hello",1);
	}
	function testregisterWithConfig(){
		config = createObject("component","coldbox.system.logging.config.LogBoxConfig").init();
		config.add("luis","coldbox.system.logging.AbstractAppender");
		config.add("luis2","coldbox.system.logging.AbstractAppender");
		logBox.registerConfig(config);
	}
	
	function testgetLogger(){
		logger = logBox.getLogger('MyCat');	
	}
	
</cfscript>
</cfcomponent>