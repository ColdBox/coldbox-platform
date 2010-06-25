<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>

	function setup(){
		cp = getMockBox().createMock("coldbox.system.cache.providers.AbstractCacheBoxProvider").init();
	}
	
	function testName(){
		cp.setName("unitTest");
		
		assertEquals( "unitTest", cp.getName() );
	}
	
	function testEnabled(){
		assertFalse( cp.isEnabled() );
		cp.$property("enabled","instance",true);
		assertTrue( cp.isEnabled() );
	}

	function testClearStatistics(){
		mockStats = getMockBox().createMock("coldbox.system.cache.util.CacheStats");
		mockStats.$("clearStats");
		cp.$property("stats","instance",mockStats);
		cp.clearStatistics();
		asserttrue( arrayLen(mockStats.$callLog().clearStats) );
		debug( mockStats.$callLog() );
	}
	
	function testConfiguration(){
		config = {
			reapFrequency = 1,
			timeout = 4
		};
		cp.setConfiguration( config );
		
		assertEquals( config, cp.getConfiguration() );
	}
	
	function testCacheFactory(){
		mockFactory = getMockBox().createEmptyMock("coldbox.system.cache.CacheFactory");
		cp.setCacheFactory( mockFactory );
		
		assertEquals( mockFactory, cp.getCacheFactory() );
	}
	
	
	function testEventManager(){
		mockEventManager = getMockBox().createStub();
		cp.seteventManager( mockEventManager );
		
		assertEquals( mockEventManager, cp.getEventManager() );
	}


</cfscript>
</cfcomponent>