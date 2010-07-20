<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	The main interface for a CacheBox cache provider statistics object

----------------------------------------------------------------------->
<cfinterface hint="The main interface for a CacheBox cache provider statistics object">

	<!--- Constructor --->
	<cffunction name="init" access="public" output="false" returntype="any" hint="Constructor">
		<cfargument name="cacheProvider" type="any" required="true" hint="The associated cache manager/provider of type coldbox.system.cache.ICacheProvider" colddoc:generic="coldbox.system.cache.ICacheProvider"/>
	</cffunction>
	
	<!--- Get Cache Performance --->
	<cffunction name="getCachePerformanceRatio" access="public" output="false" returntype="numeric" hint="Get the cache's performance ratio">
	</cffunction>
	
	<!--- Get Cache object count --->
	<cffunction name="getObjectCount" access="public" output="false" returntype="numeric" hint="Get the associated cache's live object count">
	</cffunction>
	
	<!--- clearStats --->
	<cffunction name="clearStats" output="false" access="public" returntype="void" hint="Clear the stats">
	</cffunction>	
		
	<!--- Get/Set Garbage Collections --->
	<cffunction name="getGarbageCollections" access="public" output="false" returntype="numeric" hint="Get the total cache's garbage collections">
	</cffunction>
	
	<!--- Eviction Count --->
	<cffunction name="getEvictionCount" access="public" returntype="numeric" output="false" hint="Get the total cache's eviction count">
	</cffunction>
	
	<!--- The hits --->
	<cffunction name="getHits" access="public" returntype="numeric" output="false" hint="Get the total cache's hits">
	</cffunction>
	
	<!--- The Misses --->
	<cffunction name="getMisses" access="public" returntype="numeric" output="false" hint="Get the total cache's misses">
	</cffunction>
	
	<!--- Last Reap Date Time --->
	<cffunction name="getLastReapDatetime" access="public" returntype="string" output="false" hint="Get the date/time of the last reap the cache did">
	</cffunction>
	
	<!--- Record an eviction Hit --->
	<cffunction name="evictionHit" access="public" output="false" returntype="void" hint="Record an eviction hit">
	</cffunction>
	
	<!--- Record a GC Hit --->
	<cffunction name="GCHit" access="public" output="false" returntype="void" hint="Record a garbage collection hit">
	</cffunction>
	
	<!--- Record a Hit --->
	<cffunction name="hit" access="public" output="false" returntype="void" hint="Record a hit">
	</cffunction>

	<!--- Record a Miss --->
	<cffunction name="miss" access="public" output="false" returntype="void" hint="Record a miss">
	</cffunction>

</cfinterface>