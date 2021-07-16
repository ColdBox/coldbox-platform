<cfcomponent extends="coldbox.system.testing.BaseModelTest">
	<!--- setup and teardown --->

	<cffunction name="setUp" returntype="void" access="public">
		<cfscript>
		cm    = createEmptyMock( className = "coldbox.system.cache.providers.MockProvider" );
		stats = createMock( "coldbox.system.cache.util.CacheStats" ).init( cm );
		</cfscript>
	</cffunction>

	<cffunction name="tearDown" returntype="void" access="public"><!--- Any code needed to return your environment to normal goes here ---></cffunction>

	<!--- Begin specific tests --->

	<cffunction name="testclearStats" access="public" returnType="void">
		<cfscript>
		stats.clearStatistics();
		assertTrue( stats.getHits() eq 0 );
		assertTrue( stats.getMisses() eq 0 );
		assertTrue( stats.getEvictionCount() eq 0 );
		assertTrue( stats.getGarbageCollections() eq 0 );
		</cfscript>
	</cffunction>

	<cffunction name="testevictionHit" access="public" returnType="void">
		<cfscript>
		assertEquals( stats.getEvictionCount(), 0 );
		stats.evictionHit();
		assertEquals( stats.getEvictionCount(), 1 );
		</cfscript>
	</cffunction>

	<cffunction name="testgcHit" access="public" returnType="void">
		<cfscript>
		assertEquals( stats.getGarbageCollections(), 0 );
		stats.gcHit();
		assertEquals( stats.getGarbageCollections(), 1 );
		</cfscript>
	</cffunction>

	<cffunction name="testgetCachePerformanceRatio" access="public" returnType="void">
		<cfscript>
		hits     = 100;
		misses   = 10;
		requests = hits + misses;
		stats.$property( "hits", "variables", 100 );
		stats.$property( "misses", "variables", 10 );
		ratio = stats.getCachePerformanceRatio();

		assertEquals( ratio, ( hits / requests ) * 100 );
		</cfscript>
	</cffunction>

	<cffunction name="testgetEvictionCount" access="public" returnType="void">
		<cfscript>
		assertEquals( stats.getEvictionCount(), 0 );
		</cfscript>
	</cffunction>

	<cffunction name="testgetGarbageCollections" access="public" returnType="void">
		<cfscript>
		assertEquals( stats.getGarbageCollections(), 0 );
		</cfscript>
	</cffunction>

	<cffunction name="testgethits" access="public" returnType="void">
		<cfscript>
		assertEquals( stats.getHits(), 0 );
		stats.$property( "hits", "variables", 10 );
		assertEquals( stats.getHits(), 10 );
		</cfscript>
	</cffunction>
	<cffunction name="testgetmisses" access="public" returnType="void">
		<cfscript>
		assertEquals( stats.getMisses(), 0 );
		stats.$property( "misses", "variables", 10 );
		assertEquals( stats.getMisses(), 10 );
		</cfscript>
	</cffunction>

	<cffunction name="testgetlastReapDatetime" access="public" returnType="void">
		<cfscript>
		assertTrue( isDate( stats.getlastReapDatetime() ) );
		</cfscript>
	</cffunction>

	<cffunction name="testgetObjectCount" access="public" returnType="void">
		<cfscript>
		cm.$( "getSize", 100 );
		assertEquals( stats.getObjectCount(), 100 );
		</cfscript>
	</cffunction>

	<cffunction name="testhit" access="public" returnType="void">
		<cfscript>
		assertEquals( stats.getHits(), 0 );
		stats.hit();
		assertEquals( stats.getHits(), 1 );
		stats.hit();
		assertEquals( stats.getHits(), 2 );
		</cfscript>
	</cffunction>

	<cffunction name="testmiss" access="public" returnType="void">
		<cfscript>
		assertEquals( stats.getMisses(), 0 );
		stats.miss();
		assertEquals( stats.getMisses(), 1 );
		stats.miss();
		assertEquals( stats.getMisses(), 2 );
		</cfscript>
	</cffunction>

	<cffunction name="testsetEvictionCount" access="public" returnType="void">
		<cfscript>
		stats.$property( "evictionCount", "variables", 40 );
		assertEquals( stats.getEvictionCount(), 40 );
		</cfscript>
	</cffunction>

	<cffunction name="testsetGarbageCollections" access="public" returnType="void">
		<cfscript>
		stats.$property( "garbageCollections", "variables", 40 );
		assertEquals( stats.getGarbageCollections(), 40 );
		</cfscript>
	</cffunction>

	<cffunction name="testsetlastReapDatetime" access="public" returnType="void">
		<cfscript>
		myDate = now();

		stats.setlastReapDatetime( mydate );

		assertEquals( myDate, stats.getLastReapDateTime() );
		</cfscript>
	</cffunction>
</cfcomponent>
