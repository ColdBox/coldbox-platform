<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	
	function setup(){
		cacheFactory = getMockBox().createMock("coldbox.system.cache.CacheFactory");
	}

	function testgetVersion(){
		debug( cacheFactory.getVersion() );
	}
	
	function testconfigureLogBox(){
		makePublic(cachefactory,"configureLogBox");
		cacheFactory.configureLogBox();
		
		assertTrue( isObject(cacheFactory.getLogBox()) );
	}
</cfscript>
</cfcomponent>