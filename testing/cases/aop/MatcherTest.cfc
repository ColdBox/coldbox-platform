<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	
	function setup(){
		// matcher
		matcher = getMockBox().createMock("coldbox.system.aop.Matcher").init();
	}
	
	function testAny(){
		matcher.any();
				
	}
	
</cfscript>
</cfcomponent>