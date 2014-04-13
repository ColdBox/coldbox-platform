<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	function setup(){
		xmlFile = expandPath("/coldbox/testing/cases/cache/config/samples/Sample.CacheBox.xml");
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
		configxml = xmlParse(expandpath('/coldbox/testing/cases/cache/config/samples/cbox.cachebox.xml'));
		cacheBox = xmlSearch(configxml,"//CacheBox");
		config.parseAndLoad(cacheBox[1]);
		
		memento = config.getMemento();
		debug(memento);
		
		assertFalse( structIsEmpty(memento.caches) );
		assertTrue( structKeyExists(memento.caches,"SampleCache1") );
		assertTrue( structKeyExists(memento.caches,"SampleCache2") );
		assertTrue( arrayLen(memento.listeners) );
		assertTrue( len(memento.logBoxConfig) );
		assertEquals("coldbox.system.cache.config.LogBoxConfig", memento.logBoxConfig);
		
		
		config.validate();
	}
	
	function testNormalXML(){
		config = getMockBox().createMock(className="coldbox.system.cache.config.CacheBoxConfig").init();
		configxml = xmlParse( xmlFile );
		config.parseAndLoad( configxml );
		
		memento = config.getMemento();
		debug(memento);
		
		assertFalse( structIsEmpty(memento.caches) );
		assertTrue( structKeyExists(memento.caches,"SampleCache1") );
		assertTrue( structKeyExists(memento.caches,"SampleCache2") );
		//assertTrue( arrayLen(memento.listeners) );
		assertTrue( len(memento.logBoxConfig) );
		assertEquals("coldbox.system.cache.config.LogBoxConfig", memento.logBoxConfig);
		
		config.validate();
	}
	
</cfscript>
</cfcomponent>