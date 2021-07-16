<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Author 	    :	Luis Majano
Description :
The main interface for a CacheBox cache provider statistics object
DEPRECATED USE IStats.cfc instead
----------------------------------------------------------------------->
<cfinterface
	hint="The main interface for a CacheBox cache provider statistics object: DEPRECATED USE IStats.cfc instead"
>
	<!--- Get Cache Performance --->
	<cffunction
		name      ="getCachePerformanceRatio"
		access    ="public"
		output    ="false"
		returntype="any"
		hint      ="Get the cache's performance ratio"
	>
		
	</cffunction>

	<!--- Get Cache object count --->
	<cffunction
		name      ="getObjectCount"
		access    ="public"
		output    ="false"
		returntype="any"
		hint      ="Get the associated cache's live object count"
	>
		
	</cffunction>

	<!--- clearStats --->
	<cffunction name="clearStatistics" output="false" access="public" returntype="void" hint="Clear the stats">
		
	</cffunction>

	<!--- Get/Set Garbage Collections --->
	<cffunction
		name      ="getGarbageCollections"
		access    ="public"
		output    ="false"
		returntype="any"
		hint      ="Get the total cache's garbage collections"
	>
		
	</cffunction>

	<!--- Eviction Count --->
	<cffunction
		name      ="getEvictionCount"
		access    ="public"
		returntype="any"
		output    ="false"
		hint      ="Get the total cache's eviction count"
	>
		
	</cffunction>

	<!--- The hits --->
	<cffunction name="getHits" access="public" returntype="any" output="false" hint="Get the total cache's hits">
		
	</cffunction>

	<!--- The Misses --->
	<cffunction name="getMisses" access="public" returntype="any" output="false" hint="Get the total cache's misses">
		
	</cffunction>

	<!--- Last Reap Date Time --->
	<cffunction
		name      ="getLastReapDatetime"
		access    ="public"
		returntype="any"
		output    ="false"
		hint      ="Get the date/time of the last reap the cache did"
	>
		
	</cffunction>
</cfinterface>
