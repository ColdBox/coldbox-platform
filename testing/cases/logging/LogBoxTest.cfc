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
		
		logBox.init(config);
	}
	
	function testgetLogger(){
		logger = logBox.getLogger('MyCat');
		logger.debug("My Test");
	}
	
</cfscript>
</cfcomponent>