<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	The main interface for a CacheBox cache manager statistics object

----------------------------------------------------------------------->
<cfinterface hint="The main interface for a CacheBox cache manager statistics object">

	<!--- Get Cache Performance --->
	<cffunction name="getCachePerformanceRatio" access="public" output="false" returntype="numeric" hint="Get the cache's performance ratio">
	</cffunction>
	
	<!--- Get Cache object count --->
	<cffunction name="getObjectCount" access="public" output="false" returntype="numeric" hint="Get the cache's object count">
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
	
	<!--- clear --->
	<cffunction name="clearStats" output="false" access="public" returntype="void" hint="Clear the stats">
	</cffunction>	
		
	<!--- Get/Set Garbage Collections --->
	<cffunction name="getGarbageCollections" access="public" output="false" returntype="numeric" hint="Get Garbage Collections">
	</cffunction>	
	<cffunction name="setGarbageCollections" access="public" output="false" returntype="void" hint="Set Garbage Collections">
		<cfargument name="GarbageCollections" type="numeric" required="true"/>
	</cffunction>
	
	<!--- Eviction Count --->
	<cffunction name="getEvictionCount" access="public" returntype="numeric" output="false" hint="Get the eviction count">
	</cffunction>
	<cffunction name="setEvictionCount" access="public" returntype="void" output="false" hint="Set the eviction count">
		<cfargument name="evictionCount" type="numeric" required="true">
	</cffunction>
	
	<!--- The hits --->
	<cffunction name="getHits" access="public" returntype="numeric" output="false" hint="Get the hits">
	</cffunction>
	<cffunction name="setHits" access="public" returntype="void" output="false" hint="Set the hits">
		<cfargument name="hits" type="numeric" required="true">
	</cffunction>
	
	<!--- The Misses --->
	<cffunction name="getMisses" access="public" returntype="numeric" output="false" hint="Get the misses">
	</cffunction>
	<cffunction name="setMisses" access="public" returntype="void" output="false" hint="Set the misses">
		<cfargument name="misses" type="numeric" required="true">
	</cffunction>
	
	<!--- Last Reap Date Time --->
	<cffunction name="getLastReapDatetime" access="public" returntype="string" output="false" hint="Get the last reap date time property">
	</cffunction>
	<cffunction name="setLastReapDatetime" access="public" returntype="void" output="false" hint="Set the last reap date time property">
		<cfargument name="lastReapDatetime" type="string" required="true">
	</cffunction>

	<!--- getMemento --->
	<cffunction name="getMemento" output="false" access="public" returntype="struct" hint="Get stats memento structure">
	</cffunction>

</cfinterface>