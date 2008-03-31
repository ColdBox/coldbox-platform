<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	11/14/2007
Description :
	This is a cache statistics object
----------------------------------------------------------------------->
<cfcomponent name="cacheStats" output="false" hint="This object keeps the cache statistics">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	
	<cfscript>
		instance = structnew();
	</cfscript>

	<cffunction name="init" access="public" output="false" returntype="cacheStats" hint="Constructor">
		<!--- ************************************************************************* --->
		<cfargument name="cacheManager" type="any" required="true" hint="THe cache manager"/>
		<!--- ************************************************************************* --->
		<cfscript>
			setCacheManager(arguments.cacheManager);
			setLastReapDateTime(now());
			clearStats();
			//return reference;
			return this;
		</cfscript>
	</cffunction>
	
<!------------------------------------------- PUBLIC ------------------------------------------->
	
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
		<cfscript>
	 	return getCacheManager().getSize();
		</cfscript>
	</cffunction>
	
	<!--- clear --->
	<cffunction name="clearStats" output="false" access="public" returntype="void" hint="Clear the stats">
		<cfscript>
			setHits(0);
			setMisses(0);
			setEvictionCount(0);
		</cfscript>
	</cffunction>
	
	<!--- The Cache Manager --->
	<cffunction name="getcacheManager" access="public" returntype="any" output="false">
		<cfreturn instance.cacheManager>
	</cffunction>
	<cffunction name="setcacheManager" access="public" returntype="void" output="false">
		<cfargument name="cacheManager" type="any" required="true">
		<cfset instance.cacheManager = arguments.cacheManager>
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