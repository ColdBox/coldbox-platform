<cfcomponent extends="coldbox.system.testing.BaseTestCase" output="false">
<cfscript>
	function setup(){
		rssGen = getMockBox().createMock("coldbox.system.web.feeds.RSS2Generator").init();
	}
	
	function test(){
	
	}	
</cfscript>
</cfcomponent>