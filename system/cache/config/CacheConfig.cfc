<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Author 	 :	Luis Majano
Date     :	June 30, 2006
Description :
	I am a cache config bean. I configure a Cache Manager.

Modification History:

----------------------------------------------------------------------->
<cfcomponent hint="I configure a generic ColdBox Cache Manager."
			 output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cfscript>
		instance = structnew();
	</cfscript>

	<cffunction name="init" access="public" output="false" hint="constructor" returntype="CacheConfig">
	    <!--- ************************************************************* --->
	    <cfargument name="ObjectDefaultTimeout" 			type="numeric" required="true">
	    <cfargument name="ObjectDefaultLastAccessTimeout"  type="numeric" required="true">
	    <cfargument name="ReapFrequency" 					type="numeric" required="true">
	    <cfargument name="MaxObjects" 						type="numeric" required="true">
	    <cfargument name="FreeMemoryPercentageThreshold" 	type="numeric" required="true">
	    <cfargument name="UseLastAccessTimeouts"			type="boolean" required="true">
	    <cfargument name="EvictionPolicy"					type="string"  required="true">
	    <cfargument name="EvictCount"						type="numeric" required="true">
	    <!--- ************************************************************* --->
		<cfscript>
			for(key in arguments){
				instance[key] = arguments[key];
			}
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Getter/Setter For ObjectDefaultTimeout --->
	<cffunction name="getObjectDefaultTimeout" access="public" returntype="numeric" output="false">
		<cfreturn instance.ObjectDefaultTimeout >
	</cffunction>
	<cffunction name="setObjectDefaultTimeout" access="public" returntype="void" output="false">
		<cfargument name="ObjectDefaultTimeout" type="numeric" required="true">
		<cfset instance.ObjectDefaultTimeout = arguments.ObjectDefaultTimeout>
	</cffunction>

	<!--- Getter/Setter For ObjectDefaultLastAccessTimeout --->
	<cffunction name="getObjectDefaultLastAccessTimeout" access="public" returntype="numeric" output="false">
		<cfreturn instance.ObjectDefaultLastAccessTimeout >
	</cffunction>
	<cffunction name="setObjectDefaultLastAccessTimeout" access="public" returntype="void" output="false">
		<cfargument name="ObjectDefaultLastAccessTimeout" type="numeric" required="true">
		<cfset instance.ObjectDefaultLastAccessTimeout = arguments.ObjectDefaultLastAccessTimeout>
	</cffunction>

	<!--- Getter/Setter For ReapFrequency --->
	<cffunction name="getReapFrequency" access="public" returntype="numeric" output="false">
		<cfreturn instance.ReapFrequency >
	</cffunction>
	<cffunction name="setReapFrequency" access="public" returntype="void" output="false">
		<cfargument name="ReapFrequency" type="numeric" required="true">
		<cfset instance.ReapFrequency = arguments.ReapFrequency>
	</cffunction>

	<!--- Getter/Setter For MaxObjects --->
	<cffunction name="getMaxObjects" access="public" returntype="numeric" output="false">
		<cfreturn instance.MaxObjects >
	</cffunction>
	<cffunction name="setMaxObjects" access="public" returntype="void" output="false">
		<cfargument name="MaxObjects" type="numeric" required="true">
		<cfset instance.MaxObjects = arguments.MaxObjects>
	</cffunction>

	<!--- Getter/Setter For FreeMemoryPercentageThreshold --->
	<cffunction name="getFreeMemoryPercentageThreshold" access="public" returntype="numeric" output="false">
		<cfreturn instance.FreeMemoryPercentageThreshold >
	</cffunction>
	<cffunction name="setFreeMemoryPercentageThreshold" access="public" returntype="void" output="false">
		<cfargument name="FreeMemoryPercentageThreshold" type="numeric" required="true">
		<cfset instance.FreeMemoryPercentageThreshold = arguments.FreeMemoryPercentageThreshold>
	</cffunction>
	
	<!--- Getter/Setter For UseLastAccessTimeouts --->
	<cffunction name="getUseLastAccessTimeouts" access="public" output="false" returntype="boolean" hint="Get UseLastAccessTimeouts">
		<cfreturn instance.UseLastAccessTimeouts/>
	</cffunction>	
	<cffunction name="setUseLastAccessTimeouts" access="public" output="false" returntype="void" hint="Set UseLastAccessTimeouts">
		<cfargument name="UseLastAccessTimeouts" type="boolean" required="true"/>
		<cfset instance.UseLastAccessTimeouts = arguments.UseLastAccessTimeouts/>
	</cffunction>
	
	<!--- Getter/Setter For EvictionPolicy --->
	<cffunction name="getEvictionPolicy" access="public" output="false" returntype="string" hint="Get EvictionPolicy">
		<cfreturn instance.EvictionPolicy/>
	</cffunction>
	<cffunction name="setEvictionPolicy" access="public" output="false" returntype="void" hint="Set EvictionPolicy">
		<cfargument name="EvictionPolicy" type="string" required="true"/>
		<cfset instance.EvictionPolicy = arguments.EvictionPolicy/>
	</cffunction>

	<!--- Getter/Setter memento --->
	<cffunction  name="getMemento" access="public" returntype="struct" output="false" hint="Get the memento">
		<cfreturn variables.instance>
	</cffunction>
	<cffunction  name="setMemento" access="public" returntype="void" output="false" hint="Set the memento">
		<cfargument name="memento" type="struct" required="true">
		<cfset variables.instance = arguments.memento>
	</cffunction>
	
	<!--- Getter/setter evict Count --->
	<cffunction name="getEvictCount" access="public" returntype="numeric" output="false" hint="Get the evict count">
		<cfreturn instance.EvictCount>
	</cffunction>
	<cffunction name="setEvictCount" access="public" returntype="void" output="false" hint="Set the evict count">
		<cfargument name="EvictCount" type="numeric" required="true">
		<cfset instance.EvictCount = arguments.EvictCount>
	</cffunction>
	
	<!--- Populate from struct --->
	<cffunction name="populate" access="public" returntype="any" hint="Populate with a memento" output="false">
		<!--- ************************************************************* --->
		<cfargument name="memento"  required="true" type="struct" 	hint="The structure to populate the object with.">
		<!--- ************************************************************* --->
		<cfscript>
			var key = "";
			var udfCall = "";
			
			for(key in arguments.memento){
				if( structKeyExists(this,"set" & key) ){
					udfCall = this["set#key#"];
					udfCall(arguments.memento[key]);
				}
			}
			
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->


</cfcomponent>