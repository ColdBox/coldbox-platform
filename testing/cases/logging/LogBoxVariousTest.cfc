<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	function setup(){
		// Create logbox config
		config = createObject("component","coldbox.system.logging.config.LogBoxConfig").init();
		
		// Configure two appenders
		config.appender(name="CFConsole",class="coldbox.system.logging.appenders.ConsoleAppender");
		config.appender(name="MyCF",class="coldbox.system.logging.appenders.CFAppender");
		
		//create root
		config.root(levelMin=-1,appenders="*");
		
		//Create some nice categories
		config.category(name="coldbox.testing.VariousTests",levelMin=3,appenders="*");
		config.category(name="MyCat",levelMin=3,appenders="cfconsole");
		
		//nice cats with root logger appenders
		
		//create logbox
		logbox = getMockBox().createMock(className="coldbox.system.logging.LogBox").init(config);
		
	}
	
	function test1(){
		// good cat
		logger = logBox.getLogger("Mycat");
		logger.debug("MESSAGE VALID");
		
		// root logger
		logger = logBox.getRootLogger();
		logger.debug("nada");
		
		// not defined cat
		logger = logBox.getLogger("NONE TEST");
		logger.debug("nada");
			
				
	}
</cfscript>
</cfcomponent>