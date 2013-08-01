<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	function setup(){
		xmlFile = expandPath("/coldbox/testing/cases/logging/config/samples/Sample.LogBox.xml");
		config  = getMockBox().createMock(className="coldbox.system.logging.config.LogBoxConfig").init(xmlConfig=xmlFile);
	}
	
	function testCreations(){
		logbox = createObject("component","coldbox.system.logging.LogBox").init(config);
		
		root = logBox.getRootLogger();
		
		root.debug("Hello man");
		
	}
	
	function testInlineXML(){
		config = getMockBox().createMock(className="coldbox.system.logging.config.LogBoxConfig").init();
		configxml = xmlParse(expandpath('/coldbox/testing/cases/logging/config/samples/cbox.logbox.xml'));
		logbox = xmlSearch(configxml,"//LogBox");
		
		config.parseAndLoad(logBox[1]);
		
		config.validate();
	}
	
</cfscript>
</cfcomponent>