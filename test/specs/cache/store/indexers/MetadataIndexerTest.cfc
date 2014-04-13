<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>

	function setup(){
		index = getMockBox().createMock("coldbox.system.cache.store.indexers.MetadataIndexer").init("hits,timeout,created,lastAccessed");
	}

	function testGetFields(){
		assertEquals("hits,timeout,created,lastAccessed", index.getFields() );
	}
	
	function testGetPool(){
		assertEquals( 0, index.getPoolMetadata().size() );
	}
	
	function testClearAll(){
		var pool = index.getPoolMetadata();
		
		assertEquals( 0, index.getPoolMetadata().size() );
		pool.put("test", now() );
		assertEquals( 1, index.getPoolMetadata().size() );
		
		index.clearAll();
		assertEquals( 0, index.getPoolMetadata().size() );
	}
	
	function testGetKeys(){
		var pool = index.getPoolMetadata();
		pool.put("test1", now());
		pool.put("test2", now());
		pool.put("test3", now());
		
		assertEquals(3, arrayLen(index.getKeys()) );
	}
	
	function getSetObjectMetdata(){
		md = {
			hits = 1, lastAccessed = now(), created = now()
		};
		assertEquals( false, index.objectExists("pio") );
		index.setObjectMetadata("pio", md);
		assertEquals( md, index.getObjectMetadata("pio") );
		assertEquals( true, index.objectExists("pio") );
	}
	
	function getSetMetdataProperty(){
		tdate = now();
		md = {
			hits = randRange(100,10000), lastAccessed = tDate, created = tdate
		};
		index.setObjectMetadata("test", md);
		
		// invalid one
		try{
			index.getObjectMetadataProperty("test", "invalid");
			fail("This should fail");
		}
		catch("MetadataIndexer.InvalidFieldException" e){}
		catch(Any e){ fail(e); }
		
		// Try good ones
		assertEquals( tdate, index.getObjectMetadataProperty("test","created") );
	}
	
	function testGetSize(){
		assertEquals( 0, index.getSize() );
		md = {
			hits = randRange(100,10000), lastAccessed = tDate, created = tdate
		};
		index.setObjectMetadata("test", md);
		assertEquals( 1, index.getSize() );
	}
	
	function testGetSortedKeys(){
		md1 = {
			hits = 40, created = dateAdd("n",-10,now()) , lastAccessed= dateAdd("n",-7,now())
		};
		index.setObjectMetadata("md1", md1);
		md2 = {
			hits = 99, created = dateAdd("n",-1,now()) , lastAccessed= dateAdd("n",-2,now())
		};
		index.setObjectMetadata("md2", md2);
		md3 = {
			hits = 1, created = dateAdd("n",-100,now()) , lastAccessed= dateAdd("n",-83,now())
		};
		index.setObjectMetadata("md3", md3);
		
		results = index.getSortedKeys("hits","text","asc");
		assertEquals( "md3", results[1] );
		
		results = index.getSortedKeys("hits","text","desc");
		assertEquals( "md2", results[1] );
		
		results = index.getSortedKeys("created","numeric","asc");
		assertEquals( "md3", results[1] );
		
		results = index.getSortedKeys("lastAccessed","numeric","desc");
		assertEquals( "md2", results[1] );
	}
	
	function speedTests(){
		// 100 elements
		populateIndex(100);
		stime=getTickCOunt();
		results = index.getSortedKeys("lastAccessed","numeric","asc");
		debug("100 sorted: #getTickCount()-stime#ms"); 
		index.clearAll();
		
		// 500 elements
		populateIndex(500);
		stime=getTickCOunt();
		results = index.getSortedKeys("lastAccessed","numeric","asc");
		debug("500 sorted: #getTickCount()-stime#ms");
		index.clearAll();
		
		// 1000 elements
		populateIndex(1000);
		stime=getTickCOunt();
		results = index.getSortedKeys("lastAccessed","numeric","asc");
		debug("1000 sorted: #getTickCount()-stime#ms");
		index.clearAll();
		
		// 5000 elements
		populateIndex(5000);
		stime=getTickCOunt();
		results = index.getSortedKeys("lastAccessed","numeric","asc");
		debug("5000 sorted: #getTickCount()-stime#ms");
		index.clearAll();
		
		// 10000 elements
		populateIndex(10000);
		stime=getTickCOunt();
		results = index.getSortedKeys("lastAccessed","numeric","asc");
		debug("10000 sorted: #getTickCount()-stime#ms");
		index.clearAll();
	}
</cfscript>		

	<!--- populateIndex --->
    <cffunction name="populateIndex" output="false" access="private" returntype="any" hint="">
    	<cfargument name="elements" type="numeric" required="true" default="" hint=""/>
    	<cfscript>
    		var x = 1;
    		for( x=1; x lte arguments.elements; x++){
				md = {
					hits = randRange(10,10000),
					created = dateAdd("n", randRange(-100,100),now()) , 
					lastAccessed= dateAdd("n",randRange(-10,10),now())
				};
				index.setObjectMetadata("item#x#", md);
			}
		</cfscript>
    </cffunction>


</cfcomponent>