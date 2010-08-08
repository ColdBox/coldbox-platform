<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	11/14/2007
Description :
	This is an AbstractEviction Policy object.
----------------------------------------------------------------------->
<cfcomponent name="AbstractEvictionPolicy" hint="An abstract cache eviction policy" output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	
	<cfscript>
		instance = structnew();
	</cfscript>


<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- execute --->
	<cffunction name="execute" output="false" access="public" returntype="void" hint="Execute the policy">
		<!--- Implemented by Concrete Classes --->
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->
	
	<!--- The Cache Manager --->
	<cffunction name="getCacheManager" access="private" returntype="coldbox.system.cache.archive.CacheManager" output="false">
		<cfreturn instance.cacheManager>
	</cffunction>
	<cffunction name="setCacheManager" access="private" returntype="void" output="false">
		<cfargument name="cacheManager" type="coldbox.system.cache.archive.CacheManager" required="true">
		<cfset instance.cacheManager = arguments.cacheManager>
	</cffunction>
	
	<!--- Get ColdBox Util --->
	<cffunction name="getUtil" access="private" output="false" returntype="coldbox.system.core.util.Util" hint="Create and return a util object">
		<cfreturn createObject("component","coldbox.system.core.util.Util")/>
	</cffunction>

	<!--- $log --->
	<cffunction name="$log" output="false" access="public" returntype="void" hint="Log an internal message to the ColdFusion facilities.  Used when errors ocurrs or diagnostics">
		<cfargument name="severity" type="string" required="true" default="INFO" hint="The severity to use."/>
		<cfargument name="message" type="string" required="true" default="" hint="The message to log"/>
		<cflog type="#arguments.severity#" file="ColdBoxCache-#getCacheManager().CACHE_ID#" text="#arguments.message#">
	</cffunction>
	
</cfcomponent>