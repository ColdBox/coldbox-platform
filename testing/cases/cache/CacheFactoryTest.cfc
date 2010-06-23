<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	
	function setup(){
		cacheFactory = getMockBox().createMock("coldbox.system.cache.CacheFactory").init();
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