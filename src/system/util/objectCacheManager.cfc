<!-----------------------------------------------------------------------
Copyright 2005 - 2006 ColdBox Framework by Luis Majano
www.coldboxframework.com | www.coldboxframework.org
-------------------------------------------------------------------------

Author 	    :	Luis Majano
Date        :	January 18, 2007
Description :
	This is a cfc that handles caching of event handlers.

Modification History:
01/18/2007 - Created
----------------------------------------------------------------------->
<cfcomponent name="objectCacheManager" hint="Manages handler caching." output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	
	<cffunction name="init" access="public" output="false" returntype="coldbox.system.util.objectCacheManager" hint="Constructor">
		<cfargument name="controller" type="any" required="true">
		<cfscript>
		variables.controller = arguments.controller;
		variables.cb_objects = structnew();
		variables.cb_objects_metadata = structnew();
		variables.cachePerformance = structNew();
		variables.cachePerformance.Hits = 0;
		variables.cachePerformance.Misses = 0;
		variables.reapFrequency = "";
		variables.lastReapDatetime = now();
		variables.CacheObjectDefaultTimeout = "";
		variables.CacheObjectDefaultLastAccessTimeout = "";
		return this;
		</cfscript>
	</cffunction>
	
	<cffunction name="configure" access="public" output="false" returntype="void" hint="Configure the cache.">
		<cfscript>
		variables.reapFrequency = variables.controller.getSetting("CacheReapFrequency",true);
		variables.CacheObjectDefaultTimeout = variables.controller.getSetting("CacheObjectDefaultTimeout",true);
		variables.CacheObjectDefaultLastAccessTimeout = variables.controller.getSetting("CacheObjectDefaultLastAccessTimeout",true);
		variables.cachePerformance.Hits = 0;
		variables.cachePerformance.Misses = 0;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->
	
	<cffunction name="lookup" access="public" output="false" returntype="boolean" hint="Check if an object is in cache.">
		<!--- ************************************************************* --->
		<cfargument name="objectKey" type="string" required="true">
		<!--- ************************************************************* --->
		<cfscript>
		var ObjectFound = false;
		//Check for empty cache.
		if ( structisEmpty(variables.cb_objects) ){
			return false;
		}
		//Check if we need to do a reap First.
		needToReap();
		//Check for Object in Cache.
		if ( structKeyExists(variables.cb_objects, arguments.objectKey) ){
			ObjectFound = true;
		}
		else{
			//Log miss because,user might not call get.
			miss();
		}
		//return result	
		return ObjectFound;
		</cfscript>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="get" access="public" output="false" returntype="any" hint="Get an object from cache. If it doesn't exist it return a blank structure.">
		<!--- ************************************************************* --->
		<cfargument name="objectKey" type="string" required="true">
		<!--- ************************************************************* --->
		<cfscript>
		//Check if we need to do a reap First.
		needToReap();
		//Normal Lookup
		if ( lookup(arguments.objectKey) ){
			hit();
			variables.cb_objects_metadata[arguments.objectKey].hits = variables.cb_objects_metadata[arguments.objectKey].hits + 1;
			variables.cb_objects_metadata[arguments.objectKey].lastAccesed = now();
			return variables.cb_objects[arguments.objectKey];
		}
		else{
			return structNew();
		}
		</cfscript>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="set" access="public" output="false" returntype="void" hint="set a handler in cache.">
		<!--- ************************************************************* --->
		<cfargument name="objectKey" 		type="string"  required="true">
		<cfargument name="MyObject"			type="any" 	   required="true">
		<cfargument name="Timeout"			type="numeric" required="false" default="0" hint="Timeout in minutes, else inherits from framework.">
		<!--- ************************************************************* --->
		<cfscript>
		//Check if we need to do a reap First.
		needToReap();
		//Set new Object
		variables.cb_objects[arguments.objectKey] = arguments.MyObject;
		//Compute Object Timeout
		if ( arguments.Timeout eq 0 ){
			arguments.Timeout = variables.CacheObjectDefaultTimeout;
		}
		//Set object's metdata
		variables.cb_objects_metadata[arguments.objectKey] = structNew();
		variables.cb_objects_metadata[arguments.objectKey].hits = 1;
		variables.cb_objects_metadata[arguments.objectKey].Timeout = arguments.timeout;
		variables.cb_objects_metadata[arguments.objectKey].Created = now();
		variables.cb_objects_metadata[arguments.objectKey].lastAccesed = now();
		</cfscript>
		
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="clearKey" access="public" output="false" returntype="boolean" hint="Clears a key from the cache.">
		<!--- ************************************************************* --->
		<cfargument name="objectKey" type="string" required="true">
		<!--- ************************************************************* --->
		<cfscript>
		if ( lookup(arguments.objectKey) ){
			structDelete(variables.cb_objects,arguments.objectKey);
			structDelete(variables.cb_objects_metadata,arguments.objectKey);
			return true;
		}
		else
			return false;
		</cfscript>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="clear" access="public" output="false" returntype="void" hint="Clears the entire object cache.">
		<cfscript>
		structClear(variables.cb_objects);
		structClear(variables.cb_objects_metadata);
		resetStatistics();
		</cfscript>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="resetStatistics" access="public" output="false" returntype="void" hint="Resets the cache statistics.">
		<cfscript>
		variables.cachePerformance.Hits = 0;
		variables.cachePerformance.Misses = 0;
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->
	
	<cffunction name="hit" access="public" output="false" returntype="void" hint="Record a hit">
		<cfscript>
		variables.cachePerformance.Hits = variables.cachePerformance.Hits + 1;
		</cfscript>
	</cffunction>
	
	<cffunction name="miss" access="public" output="false" returntype="void" hint="Record a miss">
		<cfscript>
		variables.cachePerformance.misses = variables.cachePerformance.misses + 1;
		</cfscript>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="getCachePerformanceRatio" access="public" output="false" returntype="numeric" hint="Get the cache's performance ratio">
		<cfscript>
	 	var requests = variables.cachePerformance.hits + variables.cachePerformance.misses;
	 	if ( requests eq 0)
	 		return 0;
		else
			return (variables.cachePerformance.Hits/requests) * 100;
		</cfscript>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="getlastReapDatetime" access="public" output="false" returntype="string" hint="Get the lastReapDatetime">
		<cfscript>
		return variables.lastReapDatetime;
		</cfscript>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="getSize" access="public" output="false" returntype="numeric" hint="Get the cache's size in items">
		<cfscript>
		reap();
		return StructCount(variables.cb_objects);
		</cfscript>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="getcachePerformance" access="public" output="false" returntype="any" hint="Get the cachePerformance structure">
		<cfscript>
		return variables.cachePerformance;
		</cfscript>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="getItemTypes" access="public" output="false" returntype="any" hint="">
		<cfscript>
		var x = 1;
		var itemList = structKeyList(variables.cb_objects);
		var itemTypes = Structnew();
		itemTypes.plugins = 0;
		itemTypes.handlers = 0;
		itemTypes.other = 0;
		
		itemList = listSort(itemList, "textnocase");
		for (x=1; x lte listlen(itemList) ; x = x+1){
			if ( findnocase("plugin", listGetAt(itemList,x)) )
				itemTypes.plugins = itemTypes.plugins + 1;
			else if ( findnocase("handler", listGetAt(itemList,x)) )
				itemTypes.handlers = itemTypes.handlers + 1;
				else
					itemTypes.other = itemTypes.other + 1;
		}
		return itemTypes;
		</cfscript>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="reap" access="public" output="false" returntype="void" hint="Reap the cache. Must be run from an exclusive lock">
		<cfscript>
		var key = "";
		var objStruct = variables.cb_objects_metadata;
		dump(objStruct);
		//Loop Through Metadata
		for (key in objStruct){
			//Check for creation timeouts and clear
			if ( dateDiff("n", objStruct[key].created, now() ) gt  objStruct[key].Timeout){
				clearKey(key);
				continue;
			}
			//Check for last accessed timeout. If object has not been accessed in the default span
			if ( dateDiff("n", objStruct[key].lastAccesed, now() ) gt  variables.CacheObjectDefaultLastAccessTimeout ){
				clearKey(key);
				continue;
			}
		}
		dump(objStruct);
		</cfscript>
	</cffunction>
	
	<!--- ************************************************************* --->
	
<!------------------------------------------- PRIVATE ------------------------------------------->
	<cffunction name="dump" access="private" hint="Facade for cfmx dump" returntype="void">
		<!--- ************************************************************* --->
		<cfargument name="var" required="yes" type="any">
		<!--- ************************************************************* --->
		<cfdump var="#var#">
	</cffunction>
	
	<cffunction name="abort" access="private" hint="Facade for cfabort" returntype="void" output="false">
		<cfabort>
	</cffunction>
	<!--- ************************************************************* --->
	
	<cffunction name="needToReap" access="private" output="false" returntype="void" hint="Checks wether we need to reap or not according to reaping frequency. If yes, then it reaps">
		<cfscript>
		//Check reaping frequency
		if ( dateDiff("n", variables.lastReapDatetime, now()) gt variables.reapFrequency){
			variables.lastReapDatetime = now();
			reap();
		}
		</cfscript>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<!--- Controller Accessor/Mutators --->
	<cffunction name="getcontroller" access="private" output="false" returntype="any" hint="Get controller">
		<cfreturn variables.controller/>
	</cffunction>	
	
	<!--- ************************************************************* --->
	
	<cffunction name="setcontroller" access="private" output="false" returntype="void" hint="Set controller">
		<cfargument name="controller" type="any" required="true"/>
		<cfset variables.controller = arguments.controller/>
	</cffunction>
</cfcomponent>