<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	function setup(){
		config = getMockBox().createMock(className="coldbox.system.logging.config.LogBoxConfig").init();
	}
	function testAdd(){
		config.add("luis","coldbox.system.logging.AbstractLogger");
		config.add("luis2","coldbox.system.logging.AbstractLogger");
		
		assertEquals( arraylen(config.getLoggers()), 2);
	}
</cfscript>
</cfcomponent>