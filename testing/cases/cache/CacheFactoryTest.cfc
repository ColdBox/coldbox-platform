<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	
	function setup(){
		// init with defaults
		cacheFactory = getMockBox().createMock("coldbox.system.cache.CacheFactory");
		mockCache 	 = getMockBox().createMock("coldbox.system.cache.providers.MockProvider").init();
		
		// init factory
		cacheFactory.init();
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
	
	function testConfigureEventManager(){
		makePublic(cachefactory,"configureEventManager");
		cacheFactory.configureEventManager();
		
		assertTrue( isObject(cacheFactory.getEventManager()) );
	}
	
	function testgetDefaultCache(){
		cacheFactory.$("getCache", getMockBox().createEmptyMock("coldbox.system.cache.providers.MockProvider") );
		cacheFactory.getDefaultCache();
		assertEquals( 1, arrayLen(cacheFactory.$callLog().getCache) );
	}
	
	function testGetCacheNames(){
		caches = {test=1,luis=2,joe=3};
		cacheFactory.$property("caches","instance",caches);
		data = cacheFactory.getCacheNames();
		debug(data);
		assertEquals( structKeyArray(caches), data );
	}
	
	function testExpireAll(){
		caches = {
			cache1 = getMockBox().createEmptyMock("coldbox.system.cache.providers.MockProvider"),
			cache2 = getMockBox().createEmptyMock("coldbox.system.cache.providers.MockProvider")
		};
		//mock caches
		cacheFactory.$property("caches","instance",caches);
		caches.cache1.$("expireAll");
		caches.cache2.$("expireAll");
		
		cacheFactory.expireAll();
		
		assertEquals( 1, arrayLen(caches.cache1.$callLog().expireAll) );
	}
	
	function testClearAll(){
		caches = {
			cache1 = getMockBox().createEmptyMock("coldbox.system.cache.providers.MockProvider"),
			cache2 = getMockBox().createEmptyMock("coldbox.system.cache.providers.MockProvider")
		};
		//mock caches
		cacheFactory.$property("caches","instance",caches);
		caches.cache1.$("clearAll");
		caches.cache2.$("clearAll");
		
		cacheFactory.clearAll();
		
		assertEquals( 1, arrayLen(caches.cache1.$callLog().clearAll) );
	}
	
	function testReplaceCacheWithInstance(){
		caches = {
			cache1 = getMockBox().createEmptyMock("coldbox.system.cache.providers.MockProvider")
		};
		caches.cache1.$("getName","Cache1");
		cache2 = getMockBox().createEmptyMock("coldbox.system.cache.providers.MockProvider");
		cache2.$("getName","MockCache");
		
		//mock caches
		cacheFactory.$property("caches","instance",caches);
		
		cacheFactory.replaceCache(caches.cache1, cache2);
		
		assertEquals( "MockCache", caches.cache1.getName() );
		
	}
	
	function testCacheExists(){
		caches = {
			cache1 = getMockBox().createEmptyMock("coldbox.system.cache.providers.MockProvider"),
			cache2 = getMockBox().createEmptyMock("coldbox.system.cache.providers.MockProvider")
		};
		//mock caches
		cacheFactory.$property("caches","instance",caches);
		
		assertEquals( false, cacheFactory.cacheExists("jose") );
		assertEquals( true, cacheFactory.cacheExists("cache1") );
		assertEquals( true, cacheFactory.cacheExists("CACHE2") );
	}
	
	function testRemoveAll(){
		caches = {
			cache1 = getMockBox().createEmptyMock("coldbox.system.cache.providers.MockProvider"),
			cache2 = getMockBox().createEmptyMock("coldbox.system.cache.providers.MockProvider")
		};
		caches.cache1.$("shutdown");
		caches.cache2.$("shutdown");
		//mock caches
		cacheFactory.$property("caches","instance",caches);
		
		cacheFactory.removeAll();
		
		assertEquals( false, cacheFactory.cacheExists("jose") );
		assertEquals( false, cacheFactory.cacheExists("cache1") );
		assertEquals( false, cacheFactory.cacheExists("CACHE2") );
	}
	
	function testRemoveCache(){
		caches = {
			cache1 = getMockBox().createEmptyMock("coldbox.system.cache.providers.MockProvider"),
			cache2 = getMockBox().createEmptyMock("coldbox.system.cache.providers.MockProvider")
		};
		caches.cache2.$("shutdown");
		//mock caches
		cacheFactory.$property("caches","instance",caches);
		
		results = cacheFactory.removeCache("invalid");
		assertEquals( false, results );
		
		results = cacheFactory.removeCache("cache2");
		assertEquals( true, results );
		assertEquals( false, structKeyExists(caches, "cache2") );
	}
	
	function testShutdown(){
		caches = {
			cache1 = getMockBox().createEmptyMock("coldbox.system.cache.providers.MockProvider"),
			cache2 = getMockBox().createEmptyMock("coldbox.system.cache.providers.MockProvider")
		};
		caches.cache1.$("shutdown");
		caches.cache2.$("shutdown");
		
		//mock caches
		cacheFactory.$property("caches","instance",caches);
		
		cacheFactory.shutdown();
		
		assertEquals( false, cacheFactory.cacheExists("cache1") );
		assertEquals( false, cacheFactory.cacheExists("CACHE2") );
	}
	
	function testShutdownCache(){
		caches = {
			cache1 = getMockBox().createEmptyMock("coldbox.system.cache.providers.MockProvider"),
			cache2 = getMockBox().createEmptyMock("coldbox.system.cache.providers.MockProvider")
		};
		caches.cache1.$("shutdown");
		caches.cache2.$("shutdown");
		
		//mock caches
		cacheFactory.$property("caches","instance",caches);
		
		// cache invalid
		cacheFactory.shutdownCache("bogus");
		cacheFactory.shutdownCache("cache1");
		
		assertEquals( false, cacheFactory.cacheExists("cache1") );
	}
	
	function testAddDefaultCacheWithExceptions(){
		debug( cacheFactory.getconfig().getMemento() );
		
		try{
			results = cacheFactory.addDefaultCache('');
			fail("this should fail");
		}
		catch("CacheFactory.InvalidNameException" e){
		}
		catch(Any e){
			fail(e);
		}
		
		caches = {
			cache1 = getMockBox().createEmptyMock("coldbox.system.cache.providers.MockProvider"),
			cache2 = getMockBox().createEmptyMock("coldbox.system.cache.providers.MockProvider")
		};
		//mock caches
		cacheFactory.$property("caches","instance",caches);
		try{
			results = cacheFactory.addDefaultCache('cache2');
			fail("this should fail");
		}
		catch("CacheFactory.CacheExistsException" e){
		}
		catch(Any e){
			fail(e.type);
		}
	}
	
	function testAddDefaultCache(){
		mockCache = getMockBox().createEmptyMock("coldbox.system.cache.providers.MockProvider");
		mockCache.$("getName","helloCache");
		cacheFactory.$("createCache", mockCache);
		
		results = cacheFactory.addDefaultCache("helloCache");
		assertEquals( "helloCache", results.getName() );
		assertEquals( 1, arrayLen(cacheFactory.$callLog().createCache ) );
		assertEquals( "helloCache", cacheFactory.$callLog().createCache[1].name );
	}
	
	function testAddCache(){
		mockCache = getMockBox().createEmptyMock("coldbox.system.cache.providers.MockProvider");
		mockCache.$("getName","helloCache");
		cacheFactory.$("registerCache");
		
		results = cacheFactory.addCache(mockCache);
		
		assertEquals( 1, arrayLen(cacheFactory.$callLog().registerCache ) );
		assertEquals( mockCache, cacheFactory.$callLog().registerCache[1][1] );
	}
	
	function testGetCache(){
		caches = {
			cache1 = getMockBox().createEmptyMock("coldbox.system.cache.providers.MockProvider"),
			cache2 = getMockBox().createEmptyMock("coldbox.system.cache.providers.MockProvider")
		};
		
		//mock caches
		cacheFactory.$property("caches","instance",caches);
		
		try{
			cacheFactory.getCache("JOE");fail("cannot get here");
		}
		catch("CacheFactory.CacheNotFoundException" e){
		}
		catch(Any e){ fail(e); }
		
		results = cacheFactory.getCache("cache1");
		assertEquals( caches.cache1, results);
	}
	
	function testCreateCache(){
		makePublic(cacheFactory, "createCache");
		//mocks
		cacheFactory.$("registerCache");
	
		results = cacheFactory.createCache("Mock","coldbox.system.cache.providers.MockProvider",structNew());
		
		assertEquals("Mock", results.getName() );
		assertEquals(1, arrayLen(cacheFactory.$callLog().registerCache) );
	}
	
</cfscript>
</cfcomponent>