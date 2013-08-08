<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	
	function setup(){
		// init with defaults
		cacheFactory = getMockBox().createMock("coldbox.system.cache.CacheFactory");
		mockCache 	 = getMockBox().createMock("coldbox.system.cache.providers.MockProvider").init();
		
		config = createObject("component","coldbox.system.cache.config.CacheBoxConfig").init(CFCConfigPath="coldbox.testing.cases.cache.listeners.Config");
		
		// init factory
		cacheFactory.init(config=config);	
	}
	
	function testRegisterListeners(){
		eventContainers = cacheFactory.getEventManager().getEventPoolContainer();
		
		assertEquals( true, structKeyExists(eventContainers,"afterCacheElementInsert") );
		assertEquals( true, structKeyExists(eventContainers,"beforeCacheShutdown") );
		assertEquals( true, structKeyExists(eventContainers,"afterCacheFactoryConfiguration") );
		
		
	}
	
</cfscript>
</cfcomponent>