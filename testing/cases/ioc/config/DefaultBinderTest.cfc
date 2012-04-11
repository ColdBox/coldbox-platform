<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	
	function setup(){
		config = getMockBox().createMock("coldbox.system.ioc.config.DefaultBinder");
	}

	function testConfigure(){
		config.configure();
	}
</cfscript>
</cfcomponent>