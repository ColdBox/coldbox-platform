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
<cfcomponent name="AbstractEvictionPolicy" hint="An abstract CacheBox eviction policy" output="false">

	<cfscript>
		instance = {};
	</cfscript>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- execute --->
	<cffunction name="execute" output="false" access="public" returntype="void" hint="Execute the eviction policy on the associated cache">
		<!--- Implemented by Concrete Classes --->
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->
	
	<!--- Get/Set Associated Cache --->
	<cffunction name="getAssociatedCache" access="private" returntype="coldbox.system.cache.ICacheProvider" output="false" hint="Get the Associated Cache Provider">
		<cfreturn instance.cacheProvider>
	</cffunction>
	
	<!--- Get ColdBox Util --->
	<cffunction name="getUtil" access="private" output="false" returntype="coldbox.system.core.util.Util" hint="Create and return a ColdBox utility object">
		<cfreturn createObject("component","coldbox.system.core.util.Util")/>
	</cffunction>

	<!--- $log --->
	<cffunction name="$log" output="false" access="public" returntype="void" hint="Log an internal message to the ColdFusion facilities.  Used when errors ocurrs or diagnostics">
		<cfargument name="severity" type="string" required="true" default="INFO" hint="The severity to use."/>
		<cfargument name="message" type="string" required="true" default="" hint="The message to log"/>
		<cflog type="#arguments.severity#" file="ColdBoxCache-#getCacheProvider().CACHE_ID#" text="#arguments.message#">
	</cffunction>
	
</cfcomponent>