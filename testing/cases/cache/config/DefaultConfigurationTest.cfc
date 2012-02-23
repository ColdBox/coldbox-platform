<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	
	function setup(){
		config = getMockBox().createMock("coldbox.system.cache.config.DefaultConfiguration");
	}

	function testConfigure(){
		config.configure();
	}
</cfscript>
</cfcomponent>