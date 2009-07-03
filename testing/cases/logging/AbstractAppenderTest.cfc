<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	function setup(){
		appender = getMockBox().createMock(className="coldbox.system.logging.AbstractAppender");
		appender.init('mytest',0,5,structnew());
	}
	
	function testIsInited(){
		assertEquals( appender.isInitialized(), false);
	}
	function testSetLevelMin(){
		try{
			appender.setLevelMin(10);
			appender.setLevelMin(-1);
		}
		catch("AbstractAppender.InvalidLogLevelException" e){
		
		}
		catch(Any e){ fail(e.message & e.detail); }
	}
	function testSetLevelMax(){
		try{
			appender.setLevelMax(10);
			appender.setLevelMax(-1);
		}
		catch("AbstractAppender.InvalidLogLevelException" e){
		
		}
		catch(Any e){ fail(e.message & e.detail); }
	}
	function testCanLog(){
		appender.setLevelMin(0);
		appender.setLevelmax(2);
		
		assertEquals( appender.canLog(5), false);
		assertEquals( appender.canLog(2), true);
	}
	
</cfscript>
</cfcomponent>