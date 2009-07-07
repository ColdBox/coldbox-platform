<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	function setup(){
		appender = getMockBox().createMock(className="coldbox.system.logging.AbstractAppender");
		appender.init('mytest',structnew());
	}
	
	function testIsInited(){
		assertEquals( appender.isInitialized(), false);
	}
	
</cfscript>
</cfcomponent>