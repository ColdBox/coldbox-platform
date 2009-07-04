<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	function setup(){
		config = getMockBox().createMock(className="coldbox.system.logging.config.LogBoxConfig").init();
	}
	function testAddAppender(){
		config.addAppender("luis","coldbox.system.logging.AbstractLogger");
		config.addAppender("luis2","coldbox.system.logging.AbstractLogger");
		
		assertEquals( structCount(config.getAppenders()), 2);
	}
	function testAddCategory(){
		try{
			config.addCategory(name="ses",levelMin=0,levelMax=2,appenders="luis,2");
			fail("This should have failed.");
		}
		catch("LogBoxConfig.AppenderNotFound" e){}
		catch(Any e){
			fail(e.message & e.detail);
		}
		
		config.addAppender("luis","coldbox.system.logging.AbstractLogger");
		config.addAppender("luis2","coldbox.system.logging.AbstractLogger");
		config.addCategory(name="ses",levelMin=0,levelMax=2,appenders="luis,luis2");
	}
</cfscript>
</cfcomponent>