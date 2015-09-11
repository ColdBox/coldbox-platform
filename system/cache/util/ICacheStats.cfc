<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	The main interface for a CacheBox cache provider statistics object

----------------------------------------------------------------------->
<cfinterface hint="The main interface for a CacheBox cache provider statistics object">
	
	<!--- Get Cache Performance --->
	<cffunction name="getCachePerformanceRatio" access="public" output="false" returntype="any" hint="Get the cache's performance ratio" colddoc:generic="numeric">
	</cffunction>
	
	<!--- Get Cache object count --->
	<cffunction name="getObjectCount" access="public" output="false" returntype="any" hint="Get the associated cache's live object count" colddoc:generic="numeric">
	</cffunction>
	
	<!--- clearStats --->
	<cffunction name="clearStatistics" output="false" access="public" returntype="void" hint="Clear the stats">
	</cffunction>	
		
	<!--- Get/Set Garbage Collections --->
	<cffunction name="getGarbageCollections" access="public" output="false" returntype="any" hint="Get the total cache's garbage collections" colddoc:generic="numeric">
	</cffunction>
	
	<!--- Eviction Count --->
	<cffunction name="getEvictionCount" access="public" returntype="any" output="false" hint="Get the total cache's eviction count" colddoc:generic="numeric">
	</cffunction>
	
	<!--- The hits --->
	<cffunction name="getHits" access="public" returntype="any" output="false" hint="Get the total cache's hits" colddoc:generic="numeric">
	</cffunction>
	
	<!--- The Misses --->
	<cffunction name="getMisses" access="public" returntype="any" output="false" hint="Get the total cache's misses" colddoc:generic="numeric">
	</cffunction>
	
	<!--- Last Reap Date Time --->
	<cffunction name="getLastReapDatetime" access="public" returntype="any" output="false" hint="Get the date/time of the last reap the cache did">
	</cffunction>

</cfinterface>