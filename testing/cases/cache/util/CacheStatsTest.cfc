<cfcomponent extends="coldbox.system.testing.BaseTestCase">
	<!--- setup and teardown --->
	
	<cffunction name="setUp" returntype="void" access="public">
		<cfscript>
			cm = getMockBox().createEmptyMock(className='coldbox.system.cache.providers.MockProvider');
			stats = getMockBox().createMock("coldbox.system.cache.util.CacheStats").init(cm);		
		</cfscript>
	</cffunction>

	<cffunction name="tearDown" returntype="void" access="public">
		<!--- Any code needed to return your environment to normal goes here --->
	</cffunction>
	
	<!--- Begin specific tests --->
	
	<cffunction name="testclearStats" access="public" returnType="void">
		<cfscript>
			stats.clearStatistics();
			assertTrue(stats.getHits() eq 0);
			assertTrue(stats.getMisses() eq 0);
			assertTrue(stats.getEvictionCount() eq 0);
			assertTrue(stats.getGarbageCollections() eq 0);			
		</cfscript>
	</cffunction>		
	
	<cffunction name="testevictionHit" access="public" returnType="void">
		<cfscript>
			AssertEquals( stats.getEvictionCount(), 0);
			stats.evictionHit();
			AssertEquals( stats.getEvictionCount(), 1);
		</cfscript>
	</cffunction>		
	
	<cffunction name="testgcHit" access="public" returnType="void">
		<cfscript>
			AssertEquals( stats.getGarbageCollections(), 0);
			stats.gcHit();
			AssertEquals( stats.getGarbageCollections(), 1);
		</cfscript>
	</cffunction>		
		
	<cffunction name="testgetCachePerformanceRatio" access="public" returnType="void">
		<cfscript>
			hits = 100;
			misses = 10;
			requests = hits+misses;
			stats.$property("hits","instance",100);
			stats.$property("misses","instance",10);
			ratio = stats.getCachePerformanceRatio();
			
			AssertEquals(ratio, (hits/requests)*100 );
		</cfscript>
	</cffunction>		
	
	<cffunction name="testgetEvictionCount" access="public" returnType="void">
		<cfscript>
			AssertEquals( stats.getEvictionCount(), 0);
		</cfscript>
	</cffunction>		
	
	<cffunction name="testgetGarbageCollections" access="public" returnType="void">
		<cfscript>
			AssertEquals( stats.getGarbageCollections(), 0);
		</cfscript>
	</cffunction>		
	
	<cffunction name="testgethits" access="public" returnType="void">
		<cfscript>
			AssertEquals( stats.getHits(), 0);
			stats.$property("hits","instance",10);
			AssertEquals( stats.getHits(), 10);
		</cfscript>
	</cffunction>	
		<cffunction name="testgetmisses" access="public" returnType="void">
		<cfscript>
			AssertEquals( stats.getMisses(), 0);
			stats.$property("misses","instance",10);
			AssertEquals( stats.getMisses(), 10);
		</cfscript>
	</cffunction>		
	
	<cffunction name="testgetlastReapDatetime" access="public" returnType="void">
		<cfscript>
			AssertTrue( isDate(stats.getlastReapDatetime()) );
		</cfscript>
	</cffunction>		
	
	<cffunction name="testgetObjectCount" access="public" returnType="void">
		<cfscript>
			cm.$('getSize',100);
			AssertEquals( stats.getObjectCount(),100);
		</cfscript>
	</cffunction>		
	
	<cffunction name="testhit" access="public" returnType="void">
		<cfscript>
			AssertEquals( stats.getHits(), 0);
			stats.hit();
			AssertEquals( stats.getHits(), 1);
			stats.hit();
			AssertEquals( stats.getHits(), 2);
		</cfscript>
	</cffunction>		
	
	<cffunction name="testmiss" access="public" returnType="void">
		<cfscript>
			AssertEquals( stats.getMisses(), 0);
			stats.miss();
			AssertEquals( stats.getMisses(), 1);
			stats.miss();
			AssertEquals( stats.getMisses(), 2);
		</cfscript>
	</cffunction>		
	
	<cffunction name="testsetEvictionCount" access="public" returnType="void">
		<cfscript>
			stats.$property("evictionCount","instance",40);
			AssertEquals(stats.getEvictionCount(),40);
		</cfscript>
	</cffunction>		
	
	<cffunction name="testsetGarbageCollections" access="public" returnType="void">
		<cfscript>
			stats.$property("garbageCollections","instance",40);
			AssertEquals(stats.getGarbageCollections(),40);
		</cfscript>
	</cffunction>		
	
	
	<cffunction name="testsetlastReapDatetime" access="public" returnType="void">
		<cfscript>
			myDate = now();
			
			stats.setlastReapDatetime(mydate);
			
			AssertEquals(myDate, stats.getLastReapDateTime());
		</cfscript>
	</cffunction>				

</cfcomponent>