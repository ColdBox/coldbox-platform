component extends="coldbox.system.testing.BaseModelTest" {

	function setup(){
		cp = createMock( "coldbox.system.cache.AbstractCacheBoxProvider" ).init();
	}

	function testName(){
		cp.setName( "unitTest" );

		assertEquals( "unitTest", cp.getName() );
	}

	function testEnabled(){
		assertFalse( cp.isEnabled() );
		cp.$property( "enabled", "variables", true );
		assertTrue( cp.isEnabled() );
	}

	function testReportingEnabled(){
		assertFalse( cp.isEnabled() );
		cp.$property( "enabled", "variables", true );
		assertTrue( cp.isEnabled() );
	}

	function testClearStatistics(){
		mockStats = createMock( "coldbox.system.cache.util.CacheStats" );
		mockStats.$( "clearStatistics" );
		cp.$property( "stats", "variables", mockStats );
		cp.clearStatistics();
		asserttrue( arrayLen( mockStats.$callLog().clearStatistics ) );
		// debug( mockStats.$callLog() );
	}

	function testConfiguration(){
		config = { reapFrequency : 1, timeout : 4 };
		cp.setConfiguration( config );

		assertEquals( config, cp.getConfiguration() );
	}

	function testCacheFactory(){
		mockFactory = createEmptyMock( "coldbox.system.cache.CacheFactory" );
		cp.setCacheFactory( mockFactory );

		assertEquals( mockFactory, cp.getCacheFactory() );
	}


	function testEventManager(){
		mockEventManager = createStub();
		cp.seteventManager( mockEventManager );

		assertEquals( mockEventManager, cp.getEventManager() );
	}

}
