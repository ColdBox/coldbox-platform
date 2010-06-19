<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	function setup(){
		xmlFile = expandPath("/coldbox/system/cache/config/Sample.CacheBox.xml");
		config  = getMockBox().createMock(className="coldbox.system.cache.config.CacheBoxConfig").
		init(xmlConfig=xmlFile);
	}
	
	function testCreations(){
		//logbox = createObject("component","coldbox.system.logging.LogBox").init(config);
		
		//root = logBox.getRootLogger();
		
		//root.debug("Hello man");
		
	}
	
	function testInlineXML(){
		config = getMockBox().createMock(className="coldbox.system.cache.config.CacheBoxConfig").init();
		configxml = xmlParse(expandpath('/coldbox/testing/cases/cache/config/cbox.cachebox.xml'));
		cacheBox = xmlSearch(configxml,"//CacheBox");
		
		//config.parseAndLoad(cacheBox[1]);
		
		//config.validate();
	}
	
	function testXML(){
		config = getMockBox().createMock(className="coldbox.system.cache.config.CacheBoxConfig").init();
		configxml = xmlParse( xmlFile );
		
		config.parseAndLoad( configxml );
	}
	
</cfscript>
</cfcomponent>