<cfcomponent extends="coldbox.system.testing.BaseModelTest">
<cfscript>
	function setup(){
		config = getMockBox().createMock(className="coldbox.system.logging.config.LogBoxConfig").init();
	}
	function testAddAppender(){
		config.appender("luis","coldbox.system.logging.AbstractAppender");
		config.appender("luis2","coldbox.system.logging.AbstractAppender");
		
		assertEquals( structCount(config.getAllAppenders()), 2);
		
		// Test bad Appender levels
		try{
			config.appender(name="luis2",class="coldbox.system.logging.AbstractAppender",levelMin=-40,levelMax=50);
		}
		catch("InvalidLevel" e){
		}
		catch(Any e){
			fail(e);
		}
	}
	
	function testAddCategory(){
		config.appender("luis","coldbox.system.logging.AbstractAppender");
		// Invalid appenders for category
		config.category(name="ses",levelMin=0,levelMax=2,appenders="luis2");
		config.root(appenders="luis");
		
		try{
			config.validate();
			fail("this should have failed.");
		}
		catch("AppenderNotFound" e){}
		catch(Any e){ fail(e.message); }
	}
	
	function testRoot(){
		config.appender("luis2","coldbox.system.logging.AbstractAppender");
		config.validate();
		
		//Add root
		config.root(appenders="luis2");
		config.validate();
	}
	function testRootAppenders(){
		//Add root
		config.appender("luis2","coldbox.system.logging.AbstractAppender");
		config.appender("luis3","coldbox.system.logging.AbstractAppender");
		config.root(appenders="*");
		config.validate();
		// debug(config.getRoot());
	}
	function testConventionMethods(){
		config.info("com.coldbox","com.transfer");
		assertEquals( structCount(config.getAllCategories()), 2);
		
		config.debug("com.coldbox","com.transfer");
		assertEquals( structCount(config.getAllCategories()), 2);
		
		config.warn("com.coldbox","com.transfer");
		assertEquals( structCount(config.getAllCategories()),2);
		
		config.error("com.coldbox","com.transfer");
		assertEquals( structCount(config.getAllCategories()), 2);
		
		config.fatal("com.coldbox","com.transfer");
		assertEquals( structCount(config.getAllCategories()), 2);
		
	}
</cfscript>
</cfcomponent>