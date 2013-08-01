<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	
	function setup(){
		// init with defaults
		cacheFactory = getMockBox().createMock("coldbox.system.cache.CacheFactory");
		mockCache 	 = getMockBox().createMock("coldbox.system.cache.providers.MockProvider").init();
		config = createObject("component","coldbox.system.cache.config.CacheBoxConfig").init(CFCConfigPath="coldbox.testing.cases.cache.SampleCacheBox");
		// init factory
		cacheFactory.init(config);
	}
	
	function testGetConfig(){
		debug( cacheFactory.getDefaultCache().getConfiguration() );
	}
	
</cfscript>
</cfcomponent>