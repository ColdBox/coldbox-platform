<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	function setup(){
		mockLB = getMockBox().createMock(className="coldbox.system.logging.LogBox",clearMethods=true);
		logger = getMockBox().createMock(className="coldbox.system.logging.Logger");
		
		//init Logger
		logger.init(category="coldbox.system.logging.UnitTest");
	}
	function testAppenderMethods(){
		//has appenders
		assertFalse( logger.hasAppenders() );
		//get appenders
		assertEquals( logger.getAppenders(), structnew() );
		//appender Add
		newAppender = createObject("component","coldbox.system.logging.appenders.ConsoleAppender").init("MyConsoleAppender");
		logger.addAppender(newAppender);
		assertTrue( logger.appenderExists("MyConsoleAppender") );
		assertEquals( newAppender, logger.getAppender("MyConsoleAppender") );
		//Remove
		logger.removeAppender("MyConsoleAppender");
		assertFalse( logger.appenderExists("MyConsoleAppender") );
		
		//remove all
		newAppender = createObject("component","coldbox.system.logging.appenders.ConsoleAppender").init("MyConsoleAppender");
		newAppender2 = createObject("component","coldbox.system.logging.appenders.ConsoleAppender").init("MyConsoleAppender2");
		logger.addAppender(newAppender);
		logger.addAppender(newAppender2);
		assertTrue( logger.hasAppenders() );
		logger.removeAllAppenders();
		assertFalse( logger.hasAppenders() );		
	}
	
	
</cfscript>
</cfcomponent>