<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	
	function setup(){
		// init with defaults
		cacheFactory = getMockBox().createMock("coldbox.system.cache.CacheFactory");
		mockCache 	 = getMockBox().createMock("coldbox.system.cache.providers.MockProvider").init();
		// mock configure()
		cacheFactory.$("createCache",mockCache);
		// init factory
		cacheFactory.init();
	}
	
	function testCreateCache(){
		makePublic(cacheFactory,"createCache");
		cacheFactory.createCache("test","coldbox.system.cache.providers.MockProvider");		
		
	}
	
	function testGetConfig(){
		debug( cacheFactory.getConfig() );
	}
	function testgetVersion(){
		debug( cacheFactory.getVersion() );
	}
	function testGetFactoryID(){
		debug( cacheFactory.getFactoryID() );
		assertEquals( createObject('java','java.lang.System').identityHashCode(cacheFactory), cacheFactory.getFactoryID() );
	}
	
	function testconfigureLogBox(){
		makePublic(cachefactory,"configureLogBox");
		cacheFactory.configureLogBox();
		
		assertTrue( isObject(cacheFactory.getLogBox()) );
	}
</cfscript>
</cfcomponent>