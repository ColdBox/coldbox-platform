<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>

	function setup(){
		config = {
			dsn   = "cacheTest",
			table = "cacheBox"
		};
		mockProvider = getMockBox().createMock("coldbox.system.cache.providers.MockProvider");
		mockProvider.$("getConfiguration", config);
		store = getMockBox().createMock(className="coldbox.system.cache.store.JDBCStore").init(mockProvider);
		index = store.getIndexer();
	}

	function testGetFields(){
		assertEquals("hits,timeout,lastAccessTimeout,created,lastAccessed,isExpired,isSimple", index.getFields() );
	}
	
	function testgetObjectMetadata(){
		store.set("test1",now(),1);
		store.set("test2",now(),1);
		store.set("test3",now(),1);
		results = index.getObjectMetadata("test1");
		
		assertTrue( not structIsEmpty(results) );
	}
	
	function testgetObjectMetadataProperty(){
		store.set("test1",now(),1);
		assertEquals( 1, index.getObjectMetadataProperty("test1","hits") );
	}
	
	function getSortedKeys(){
		store.clearAll();
		store.set("test1",now(),1);
		store.set("test2",now(),1);
		store.set("test3",now(),1);
		
		store.get("test1");
		store.get("test1");
		store.get("test3");
		
		keys = index.getSortedKeys("hits","","asc");
		
		debug(keys);
		assertEquals( "test2", keys[1] );
	
	}
	
</cfscript>		
</cfcomponent>