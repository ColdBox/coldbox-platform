<cfcomponent extends="coldbox.system.testing.BaseTestCase" output="false">
<cfscript>
	function setup(){
		mockController = getMockBox().createEmptyMock(className="coldbox.system.web.Controller");
		feedReader = getMockBox().createMock("coldbox.system.web.feeds.FeedReader").init(mockController);
	}
	
	function test(){
	
	}	
</cfscript>
</cfcomponent>