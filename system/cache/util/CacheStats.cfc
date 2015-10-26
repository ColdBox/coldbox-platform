<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	11/14/2007
Description :
	This is a cache statistics object.  We do not use internal method calls but
	leverage the properties directly so it is faster.
----------------------------------------------------------------------->
<cfcomponent output="false" hint="This object keeps the cache statistics" implements="coldbox.system.cache.util.ICacheStats">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	
	<cffunction name="init" access="public" output="false" returntype="CacheStats" hint="Constructor">
		<cfargument name="cacheProvider"required="true" hint="The associated cache manager/provider of type: coldbox.system.cache.ICacheProvider" colddoc:generic="coldbox.system.cache.ICacheProvider"/>
		<cfscript>
			instance = {
				cacheProvider = arguments.cacheProvider
			};
			
			// Init reap to right now
			setLastReapDateTime(now());
			
			// Clear the stats to start fresh.
			clearStatistics();
			
			return this;
		</cfscript>
	</cffunction>
	
<!------------------------------------------- PUBLIC ------------------------------------------->
	
	<!--- Get Associated Cache --->
	<cffunction name="getAssociatedCache" access="public" output="false" returntype="any" hint="Get the associated cache provider/manager of type: coldbox.system.cache.ICacheProvider" colddoc:generic="coldbox.system.cache.ICacheProvider">
		<cfreturn instance.cacheProvider>
	</cffunction>
	
	<!--- Get Cache Performance --->
	<cffunction name="getCachePerformanceRatio" access="public" output="false" returntype="any" hint="Get the cache's performance ratio">
		<cfscript>
		 	var requests = instance.hits + instance.misses;
			
		 	if ( requests eq 0){
		 		return 0;
			}
			
			return (instance.hits/requests) * 100;
		</cfscript>
	</cffunction>
	
	<!--- getObjectCount --->
	<cffunction name="getObjectCount" access="public" output="false" returntype="any" hint="Get the associated cache's live object count">
		<cfreturn getAssociatedCache().getSize()>
	</cffunction>
	
	<!--- clear --->
	<cffunction name="clearStatistics" output="false" access="public" returntype="void" hint="Clear the stats">
		<cfscript>
			instance.hits 					= 0;
			instance.misses 				= 0;
			instance.evictionCount 			= 0;
			instance.garbageCollections 	= 0;
		</cfscript>
	</cffunction>	

	<!--- Get/Set Garbage Collections --->
	<cffunction name="getGarbageCollections" access="public" output="false" returntype="any" hint="Get the cache garbage collections">
		<cfreturn instance.garbageCollections/>
	</cffunction>	
	
	<!--- Eviction Count --->
	<cffunction name="getEvictionCount" access="public" returntype="any" output="false" hint="Get the total cache eviction counts">
		<cfreturn instance.evictionCount>
	</cffunction>
	
	<!--- The hits --->
	<cffunction name="getHits" access="public" returntype="any" output="false" hint="Get the cache hits">
		<cfreturn instance.hits>
	</cffunction>
	
	<!--- The Misses --->
	<cffunction name="getMisses" access="public" returntype="any" output="false" hint="Get the cache misses">
		<cfreturn instance.misses>
	</cffunction>
	
	<!--- Last Reap Date Time --->
	<cffunction name="getLastReapDatetime" access="public" returntype="any" output="false" hint="Get the last reaping date of the cache">
		<cfreturn instance.lastReapDatetime>
	</cffunction>
	<cffunction name="setLastReapDatetime" access="public" returntype="void" output="false" hint="Set when the last reaping date of the cache was done">
		<cfargument name="lastReapDatetime" type="string" required="true">
		<cfset instance.lastReapDatetime = arguments.lastReapDatetime>
	</cffunction>
	
	<!--- Record an eviction Hit --->
	<cffunction name="evictionHit" access="public" output="false" returntype="void" hint="Record an eviction hit">
		<cfscript>
			instance.evictionCount++;
		</cfscript>
	</cffunction>
	
	<!--- Record a GC Hit --->
	<cffunction name="GCHit" access="public" output="false" returntype="void" hint="Record a garbage collection hit">
		<cfscript>
			instance.garbageCollections++;
		</cfscript>
	</cffunction>
	
	<!--- Record a Hit --->
	<cffunction name="hit" access="public" output="false" returntype="void" hint="Record a hit">
		<cfscript>
			instance.hits++;
		</cfscript>
	</cffunction>

	<!--- Record a Miss --->
	<cffunction name="miss" access="public" output="false" returntype="void" hint="Record a miss">
		<cfscript>
			instance.misses++;
		</cfscript>
	</cffunction>
	
	<!--- getMemento --->
	<cffunction name="getMemento" output="false" access="public" returntype="any" hint="Get the stats memento">
		<cfreturn instance>
	</cffunction>

</cfcomponent>