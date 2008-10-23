<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Author 	 :	Luis Majano
Date     :	June 30, 2006
Description :
	I am a cache config bean. I configure a Cache Manager.

Modification History:

----------------------------------------------------------------------->
<cfcomponent name="CacheConfigBean"
			 hint="I configure a cache manager."
			 output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" output="false" hint="constructor" returntype="CacheConfigBean">
	    <!--- ************************************************************* --->
	    <cfargument name="CacheObjectDefaultTimeout" 			type="numeric" required="true">
	    <cfargument name="CacheObjectDefaultLastAccessTimeout"  type="numeric" required="true">
	    <cfargument name="CacheReapFrequency" 					type="numeric" required="true">
	    <cfargument name="CacheMaxObjects" 						type="numeric" required="true">
	    <cfargument name="CacheFreeMemoryPercentageThreshold" 	type="numeric" required="true">
	    <cfargument name="CacheUseLastAccessTimeouts"			type="boolean" required="true">
	    <cfargument name="CacheEvictionPolicy"					type="string"  required="true">
	    <!--- ************************************************************* --->
		<cfscript>
			variables.instance = structnew();
			instance.CacheObjectDefaultTimeout = arguments.CacheObjectDefaultTimeout;
			instance.CacheObjectDefaultLastAccessTimeout = arguments.CacheObjectDefaultLastAccessTimeout;
			instance.CacheReapFrequency = arguments.CacheReapFrequency;
			instance.CacheMaxObjects = arguments.CacheMaxObjects;
			instance.CacheFreeMemoryPercentageThreshold = arguments.CacheFreeMemoryPercentageThreshold;
			instance.CacheUseLastAccessTimeouts = arguments.CacheUseLastAccessTimeouts;
			instance.CacheEvictionPolicy = arguments.CacheEvictionPolicy;
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
	
	<!--- Getter/Setter For CacheUseLastAccessTimeouts --->
	<cffunction name="getCacheUseLastAccessTimeouts" access="public" output="false" returntype="boolean" hint="Get CacheUseLastAccessTimeouts">
		<cfreturn instance.CacheUseLastAccessTimeouts/>
	</cffunction>	
	<cffunction name="setCacheUseLastAccessTimeouts" access="public" output="false" returntype="void" hint="Set CacheUseLastAccessTimeouts">
		<cfargument name="CacheUseLastAccessTimeouts" type="boolean" required="true"/>
		<cfset instance.CacheUseLastAccessTimeouts = arguments.CacheUseLastAccessTimeouts/>
	</cffunction>
	
	<!--- Getter/Setter For CacheEvictionPolicy --->
	<cffunction name="getCacheEvictionPolicy" access="public" output="false" returntype="string" hint="Get CacheEvictionPolicy">
		<cfreturn instance.CacheEvictionPolicy/>
	</cffunction>
	<cffunction name="setCacheEvictionPolicy" access="public" output="false" returntype="void" hint="Set CacheEvictionPolicy">
		<cfargument name="CacheEvictionPolicy" type="string" required="true"/>
		<cfset instance.CacheEvictionPolicy = arguments.CacheEvictionPolicy/>
	</cffunction>

	<!--- Getter/Setter memento --->
	<cffunction  name="getmemento" access="public" returntype="struct" output="false" hint="Get the memento">
		<cfreturn variables.instance>
	</cffunction>
	<cffunction  name="setmemento" access="public" returntype="void" output="false" hint="Set the memento">
		<cfargument name="memento" type="struct" required="true">
		<cfset variables.instance = arguments.memento>
	</cffunction>
	
	<!--- Populate from struct --->
	<cffunction name="populate" access="public" returntype="void" hint="Populate with a memento">
		<!--- ************************************************************* --->
		<cfargument name="memento"  required="true" type="struct" 	hint="The structure to populate the object with.">
		<!--- ************************************************************* --->
		<cfscript>
			var key = "";
			
			/* Populate Bean */
			for(key in arguments.memento){
				/* Check if setter exists */
				if( structKeyExists(this,"set" & key) ){
					evaluate("set#key#(arguments.memento[key])");
				}
			}
		</cfscript>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->


</cfcomponent>