<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Author 	 :	Luis Majano
Date     :	June 30, 2006
Description :
	I am a cache config bean. I configure a Cache Manager.

Modification History:

----------------------------------------------------------------------->
<cfcomponent name="cacheConfigBean"
			 hint="I configure a cache manager."
			 output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" output="false" hint="constructor" returntype="coldbox.system.beans.cacheConfigBean">
	    <!--- ************************************************************* --->
	    <cfargument name="CacheObjectDefaultTimeout" 			type="numeric" required="true">
	    <cfargument name="CacheObjectDefaultLastAccessTimeout"  type="numeric" required="true">
	    <cfargument name="CacheReapFrequency" 					type="numeric" required="true">
	    <cfargument name="CacheMaxObjects" 						type="numeric" required="true">
	    <cfargument name="CacheFreeMemoryPercentageThreshold" 	type="numeric" required="true">
	    <!--- ************************************************************* --->
		<cfscript>
		variables.instance = structnew();
		variables.instance.CacheObjectDefaultTimeout = arguments.CacheObjectDefaultTimeout;
		variables.instance.CacheObjectDefaultLastAccessTimeout = arguments.CacheObjectDefaultLastAccessTimeout;
		variables.instance.CacheReapFrequency = arguments.CacheReapFrequency;
		variables.instance.CacheMaxObjects = arguments.CacheMaxObjects;
		variables.instance.CacheFreeMemoryPercentageThreshold = arguments.CacheFreeMemoryPercentageThreshold;
		return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Getter/Setter For CacheObjectDefaultTimeout --->
	<cffunction name="getCacheObjectDefaultTimeout" access="public" returntype="numeric" output="false">
		<cfreturn instance.CacheObjectDefaultTimeout >
	</cffunction>
	<cffunction name="setCacheObjectDefaultTimeout" access="public" returntype="void" output="false">
		<cfargument name="CacheObjectDefaultTimeout" type="numeric" required="true">
		<cfset instance.CacheObjectDefaultTimeout = arguments.CacheObjectDefaultTimeout>
	</cffunction>

	<!--- Getter/Setter For CacheObjectDefaultLastAccessTimeout --->
	<cffunction name="getCacheObjectDefaultLastAccessTimeout" access="public" returntype="numeric" output="false">
		<cfreturn instance.CacheObjectDefaultLastAccessTimeout >
	</cffunction>
	<cffunction name="setCacheObjectDefaultLastAccessTimeout" access="public" returntype="void" output="false">
		<cfargument name="CacheObjectDefaultLastAccessTimeout" type="numeric" required="true">
		<cfset instance.CacheObjectDefaultLastAccessTimeout = arguments.CacheObjectDefaultLastAccessTimeout>
	</cffunction>

	<!--- Getter/Setter For CacheReapFrequency --->
	<cffunction name="getCacheReapFrequency" access="public" returntype="numeric" output="false">
		<cfreturn instance.CacheReapFrequency >
	</cffunction>
	<cffunction name="setCacheReapFrequency" access="public" returntype="void" output="false">
		<cfargument name="CacheReapFrequency" type="numeric" required="true">
		<cfset instance.CacheReapFrequency = arguments.CacheReapFrequency>
	</cffunction>

	<!--- Getter/Setter For CacheMaxObjects --->
	<cffunction name="getCacheMaxObjects" access="public" returntype="numeric" output="false">
		<cfreturn instance.CacheMaxObjects >
	</cffunction>
	<cffunction name="setCacheMaxObjects" access="public" returntype="void" output="false">
		<cfargument name="CacheMaxObjects" type="numeric" required="true">
		<cfset instance.CacheMaxObjects = arguments.CacheMaxObjects>
	</cffunction>

	<!--- Getter/Setter For CacheFreeMemoryPercentageThreshold --->
	<cffunction name="getCacheFreeMemoryPercentageThreshold" access="public" returntype="numeric" output="false">
		<cfreturn instance.CacheFreeMemoryPercentageThreshold >
	</cffunction>
	<cffunction name="setCacheFreeMemoryPercentageThreshold" access="public" returntype="void" output="false">
		<cfargument name="CacheFreeMemoryPercentageThreshold" type="numeric" required="true">
		<cfset instance.CacheFreeMemoryPercentageThreshold = arguments.CacheFreeMemoryPercentageThreshold>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->


</cfcomponent>