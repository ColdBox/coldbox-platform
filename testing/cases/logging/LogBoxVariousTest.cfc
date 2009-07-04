<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	function setup(){
		// Create logbox config
		config = createObject("component","coldbox.system.logging.config.LogBoxConfig").init();
		// Configure two appenders
		config.addAppender(name="CFConsole",class="coldbox.system.logging.appenders.ConsoleAppender");
		config.addAppender(name="MyCF",class="coldbox.system.logging.appenders.CFAppender");
		
		//Create some nice categories
		config.addCategory(name="coldbox.testing.VariousTests",levelMin=3,appenders="CFConsole");
		config.addCategory(name="MyCat",levelMin=3,appenders="cfconsole");
		
		//create logbox
		logbox = getMockBox().createMock(className="coldbox.system.logging.LogBox").init(config);
		
	}
	
	function test1(){
		//Log to all appenders
		logBox.info(message="Hola from various testing.");
		
		logger = logBox.getLogger("Mycat");
		logger.trace("just an error message");
		
		
	}
</cfscript>
</cfcomponent>