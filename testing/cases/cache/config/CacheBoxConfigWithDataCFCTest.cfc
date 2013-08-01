<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	function setup(){
		//cacheBox = getMockBox().createMock(className="coldbox.system.logging.LogBox");
		dataConfigPath = "coldbox.testing.cases.cache.config.samples.SampleCacheBox";
	}
	
	function testLoader(){
		// My Data Object
		dataConfig = createObject("component",dataConfigPath);
		// Config LogBox
		config = createObject("component","coldbox.system.cache.config.CacheBoxConfig").init(CFCConfig=dataConfig);
		// Create it
		//cacheBox.init( config );
		
		memento = config.getMemento();
		debug(memento);
		
		assertFalse( structIsEmpty(memento.caches) );
		assertTrue( structKeyExists(memento.caches,"SampleCache1") );
		assertTrue( structKeyExists(memento.caches,"SampleCache2") );
		assertTrue( arrayLen(memento.listeners) );
		assertTrue( len(memento.logBoxConfig) );
		assertEquals( "cacheBoxAwesome", memento.scopeRegistration.key );
		assertEquals("coldbox.system.cache.config.LogBoxConfig", memento.logBoxConfig);
		
		config.validate();
	}
	
	function testLoader2(){
		// Config LogBox
		config = createObject("component","coldbox.system.cache.config.CacheBoxConfig").init(CFCConfigPath=dataConfigPath);
		// Create it
		//cacheBox.init( config );
		
		memento = config.getMemento();
		debug(memento);
		
		assertFalse( structIsEmpty(memento.caches) );
		assertTrue( structKeyExists(memento.caches,"SampleCache1") );
		assertTrue( structKeyExists(memento.caches,"SampleCache2") );
		assertTrue( arrayLen(memento.listeners) );
		assertTrue( len(memento.logBoxConfig) );
		assertEquals( "cacheBoxAwesome", memento.scopeRegistration.key );
		assertEquals("coldbox.system.cache.config.LogBoxConfig", memento.logBoxConfig);
		
		
		config.validate();
	}
	
	
</cfscript>
</cfcomponent>