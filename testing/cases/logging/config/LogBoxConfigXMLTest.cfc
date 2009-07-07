<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	function setup(){
		xmlFile = expandPath("/coldbox/system/logging/config/Sample.LogBox.xml");
		config = getMockBox().createMock(className="coldbox.system.logging.config.LogBoxConfig").init(xmlFile);
	}
	
	function testCreations(){
		logbox = createObject("component","coldbox.system.logging.LogBox").init(config);
		
		root = logBox.getRootLogger();
		
		root.debug("Hello man");
	}
</cfscript>
</cfcomponent>