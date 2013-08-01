<cfcomponent extends="coldbox.system.testing.BaseTestCase">
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
		catch("LogBoxConfig.InvalidLevel" e){
		}
		catch(Any e){
			fail(e);
		}
	}
	function testValidateCategories(){
		config.category(name="ses",levelMin=0,levelMax=2,appenders="luis,2");
		try{
			config.validate();
			fail("this should have failed.");
		}
		catch("coldbox.system.logging.config.LogBoxConfig.NoAppendersFound" e){}
		catch(Any e){ fail(e.message); }
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
		catch("coldbox.system.logging.config.LogBoxConfig.AppenderNotFound" e){}
		catch(Any e){ fail(e.message); }
	}
	
	function testRoot(){
		try{
			config.validate();
			fail("this should have failed.");
		}
		catch("coldbox.system.logging.config.LogBoxConfig.NoAppendersFound" e){}
		catch(Any e){ fail(e.message); }
		
		//add appender, but still fails, no root logger
		config.appender("luis2","coldbox.system.logging.AbstractAppender");
		try{
			config.validate();
			fail("this should have failed.");
		}
		catch("coldbox.system.logging.config.LogBoxConfig.RootLoggerNotFound" e){}
		catch(Any e){ fail(e.message); }
		
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
		debug(config.getRoot());
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