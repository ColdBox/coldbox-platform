<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	11/14/2007
Description :
	This is a cache statistics object
----------------------------------------------------------------------->
<cfcomponent name="CacheStats" output="false" hint="This object keeps the cache statistics">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	
	<cfscript>
		instance = structnew();
	</cfscript>

	<cffunction name="init" access="public" output="false" returntype="CacheStats" hint="Constructor">
		<!--- ************************************************************************* --->
		<cfargument name="cacheManager" type="any" required="true" hint="The associated cache manager"/>
		<!--- ************************************************************************* --->
		<cfscript>
			/* Set Dependencies */
			instance.cacheManager = arguments.cacheManager;
			setLastReapDateTime(now());
			/* Clear the stats */
			clearStats();
			//return reference;
			return this;
		</cfscript>
	</cffunction>
	
<!------------------------------------------- PUBLIC ------------------------------------------->
	
	<!--- getAssociatedCacheManager --->
	<cffunction name="getAssociatedCacheManager" output="false" access="public" returntype="coldbox.system.cache.CacheManager" hint="Get the associated Cache Manager for this stats object">
		<cfreturn instance.cacheManager>
	</cffunction>
	
	<!--- Get Cache Performance --->
	<cffunction name="getCachePerformanceRatio" access="public" output="false" returntype="numeric" hint="Get the cache's performance ratio">
		<cfscript>
	 	var requests = gethits() + getmisses();
	 	if ( requests eq 0)
	 		return 0;
		else
			return (getHits()/requests) * 100;
		</cfscript>
	</cffunction>
	
	<!--- Get Cache object count --->
	<cffunction name="getObjectCount" access="public" output="false" returntype="numeric" hint="Get the cache's object count">
		<cfreturn instance.cacheManager.getSize()>
	</cffunction>
	
	<!--- Record an eviction Hit --->
	<cffunction name="evictionHit" access="public" output="false" returntype="void" hint="Record an eviction hit">
		<cfscript>
			setEvictionCount(getEvictionCount()+1);
		</cfscript>
	</cffunction>
	
	<!--- Record a GC Hit --->
	<cffunction name="gcHit" access="public" output="false" returntype="void" hint="Record a garbage collection hit">
		<cfscript>
			setGarbageCollections(getGarbageCollections()+1);
		</cfscript>
	</cffunction>
	
	<!--- Record a Hit --->
	<cffunction name="hit" access="public" output="false" returntype="void" hint="Record a hit">
		<cfscript>
			setHits(getHits()+1);
		</cfscript>
	</cffunction>

	<!--- Record a Miss --->
	<cffunction name="miss" access="public" output="false" returntype="void" hint="Record a miss">
		<cfscript>
			setmisses(getmisses()+1);
		</cfscript>
	</cffunction>
	
	<!--- clear --->
	<cffunction name="clearStats" output="false" access="public" returntype="void" hint="Clear the stats">
		<cfscript>
			setHits(0);
			setMisses(0);
			setEvictionCount(0);
			setGarbageCollections(0);
		</cfscript>
	</cffunction>	
		
	<!--- Get/Set Garbage Collections --->
	<cffunction name="getGarbageCollections" access="public" output="false" returntype="numeric" hint="Get GarbageCollections">
		<cfreturn instance.GarbageCollections/>
	</cffunction>	
	<cffunction name="setGarbageCollections" access="public" output="false" returntype="void" hint="Set GarbageCollections">
		<cfargument name="GarbageCollections" type="numeric" required="true"/>
		<cfset instance.GarbageCollections = arguments.GarbageCollections/>
	</cffunction>
	
	<!--- Eviction Count --->
	<cffunction name="getEvictionCount" access="public" returntype="numeric" output="false">
		<cfreturn instance.evictionCount>
	</cffunction>
	<cffunction name="setEvictionCount" access="public" returntype="void" output="false">
		<cfargument name="evictionCount" type="numeric" required="true">
		<cfset instance.evictionCount = arguments.evictionCount>
	</cffunction>
	
	<!--- The hits --->
	<cffunction name="gethits" access="public" returntype="numeric" output="false">
		<cfreturn instance.hits>
	</cffunction>
	<cffunction name="sethits" access="public" returntype="void" output="false">
		<cfargument name="hits" type="numeric" required="true">
		<cfset instance.hits = arguments.hits>
	</cffunction>
	
	<!--- The Misses --->
	<cffunction name="getmisses" access="public" returntype="numeric" output="false">
		<cfreturn instance.misses>
	</cffunction>
	<cffunction name="setmisses" access="public" returntype="void" output="false">
		<cfargument name="misses" type="numeric" required="true">
		<cfset instance.misses = arguments.misses>
	</cffunction>
	
	<!--- Last Reap Date Time --->
	<cffunction name="getlastReapDatetime" access="public" returntype="string" output="false">
		<cfreturn instance.lastReapDatetime>
	</cffunction>
	<cffunction name="setlastReapDatetime" access="public" returntype="void" output="false">
		<cfargument name="lastReapDatetime" type="string" required="true">
		<cfset instance.lastReapDatetime = arguments.lastReapDatetime>
	</cffunction>

</cfcomponent>