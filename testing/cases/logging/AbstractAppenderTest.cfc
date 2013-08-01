<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	function setup(){
		appender = getMockBox().createMock(className="coldbox.system.logging.AbstractAppender");
		appender.init('mytest',structnew());
	}
	
	function testIsInited(){
		assertEquals( appender.isInitialized(), false);
		assertEquals( 0, appender.getLevelMin() );
		assertEquals( 4, appender.getLevelMax() );
	}
	
	function testcanLog(){
		for(x=0; x lte 4; x++)
			assertTrue( appender.canLog(x) );
		
		assertFalse( appender.canLog(5) );
		
		appender.setLevelMax(0);
		for(x=1; x lte 4; x++)
			assertFalse( appender.canLog(x) );
		
	}
</cfscript>
</cfcomponent>