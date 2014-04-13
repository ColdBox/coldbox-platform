<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	function setup(){
		logbox = getMockBox().createMock(className="coldbox.system.logging.LogBox");
		
		config = createObject("component","coldbox.system.logging.config.LogBoxConfig").init();
		//Appenders
		config.appender(name="luis",class="coldbox.system.logging.appenders.ConsoleAppender");
		config.appender(name="luis2",class="coldbox.system.logging.appenders.ConsoleAppender");
		//root
		config.root(appenders="luis,luis2");
		
		//Sample categories
		config.OFF("coldbox.system");
		config.debug("coldbox.system.interceptors");
		
		//init logBox
		logBox.init(config);
	}
	
	function testgetLogger(){
		logger = logBox.getLogger('MyCat');
		logger.debug("My Test");
		
		//2: category inheritance
		logger = logBox.getLogger("coldbox.system.interceptors.SES");
		
		assertEquals( logger.logLevels.DEBUG, logger.getLevelMax() );
		assertEquals( logger.getRootLogger().getCategory(), "coldbox.system.interceptors");
		
		//3: category inheritance
		logger = logBox.getLogger("coldbox.system.plugins");
		assertEquals( logger.getLevelMin(), logger.logLevels.OFF);
		assertEquals( logger.getRootLogger().getCategory(), "coldbox.system");
	}
	
	function testgetRootLogger(){
		logger = logBox.getRootLogger();
		logger.info("Test");
	}
	
	function testGetCurrentLoggers(){
		debug( logBox.getCurrentLoggers() );
	}
	function testGetCurrentAppenders(){
		debug( logBox.getCurrentAppenders() );
	}
	
	function testLocateCategoryParentLogger(){
		makePublic(logbox,"locateCategoryParentLogger");
		// 1: root logger
		assertEquals( logBox.getRootLogger(), logBox.locateCategoryParentLogger("invalid") );
		
		// 2: Expecting a logger with debug levels only
		logger = logBox.locateCategoryParentLogger("coldbox.system.interceptors.SES");
		assertEquals( logger.getLevelMax(), logger.logLevels.DEBUG);
		
		// 3: Expecting an OFF logger
		logger = logBox.locateCategoryParentLogger("coldbox.system.plugins");
		assertEquals( logger.getLevelMin(), logger.logLevels.OFF);
	}
</cfscript>
</cfcomponent>