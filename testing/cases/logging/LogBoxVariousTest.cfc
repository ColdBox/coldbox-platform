<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	function setup(){
		config = createObject("component","coldbox.system.logging.config.LogBoxConfig").init();
		config.addAppender(name="CFConsole",class="coldbox.system.logging.appenders.ConsoleAppender");
		config.addAppender(name="DBConsole",class="coldbox.system.logging.appenders.DBAppender",
						   levelMin="0",levelMax="1",
						   properties={dsn="test",table="logs",autocreate="true",defaultCategory=""});
		
		logbox = getMockBox().createMock(className="coldbox.system.logging.LogBox").init(config);
		
	}
	
	function test1(){
		logBox.info(message="Hola Henrik");
	}
</cfscript>
</cfcomponent>