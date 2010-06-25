<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	The CacheBox Cache Provider

----------------------------------------------------------------------->
<cfcomponent hint="A mock cache provider" output="false" implements="coldbox.system.cache.ICacheProvider">
	
	<!--- init --->
    <cffunction name="init" output="false" access="public" returntype="any" hint="Simple Constructor">
    	<cfreturn this>
    </cffunction>

	<!--- getName --->
    <cffunction name="getName" output="false" access="public" returntype="string" hint="Get the name of this cache">
    </cffunction>
	
	<!--- setName --->
    <cffunction name="setName" output="false" access="public" returntype="void" hint="Set the cache name">
    	<cfargument name="name" type="string" required="true" hint="The cache name"/>
    </cffunction>

	<!--- isEnabled --->
    <cffunction name="isEnabled" output="false" access="public" returntype="boolean" hint="Returns a flag indicating if the cache is ready for operation">
    </cffunction>

	<!--- getStats --->
    <cffunction name="getStats" output="false" access="public" returntype="coldbox.system.cache.util.ICacheStats" hint="Get the cache statistics object">
    </cffunction>
	
	<!--- clearStatistics --->
    <cffunction name="clearStatistics" output="false" access="public" returntype="void" hint="Clear the cache statistics">
    </cffunction>

	<!--- getConfiguration --->
    <cffunction name="getConfiguration" output="false" access="public" returntype="struct" hint="Get the structure of configuration parameters for the cache">
    </cffunction>

	<!--- setConfiguration --->
    <cffunction name="setConfiguration" output="false" access="public" returntype="void" hint="Override the entire configuration structure for this cache">
    	<cfargument name="configuration" type="struct" required="true" hint="The configuration structure"/>
    </cffunction>

	<!--- getCacheFactory --->
    <cffunction name="getCacheFactory" output="false" access="public" returntype="coldbox.system.cache.CacheFactory" hint="Get the cache factory reference this cache provider belongs to">
    </cffunction>
	
	<!--- setCacheFactory --->
    <cffunction name="setCacheFactory" output="false" access="public" returntype="void" hint="Set the cache factory reference for this cache">
    	<cfargument name="cacheFactory" type="coldbox.system.cache.CacheFactory" required="true"/>
    </cffunction>

	<!--- getEventManager --->
    <cffunction name="getEventManager" output="false" access="public" returntype="any" hint="Get this cache managers event listner manager">
    </cffunction>
	
	<!--- setEventManager --->
    <cffunction name="setEventManager" output="false" access="public" returntype="void" hint="Set the event manager for this cache">
    	<cfargument name="eventManager" type="any" required="true" hint="The event manager class"/>
    </cffunction>

	<!--- configure --->
    <cffunction name="configure" output="false" access="public" returntype="void" hint="This method makes the cache ready to accept elements and run">
    </cffunction>
			
	<!--- shutdown --->
    <cffunction name="shutdown" output="false" access="public" returntype="void" hint="Shutdown command issued when CacheBox is going through shutdown phase">
    </cffunction>

<!------------------------------------------- CACHE OPERATIONS ------------------------------------------>

	<!--- getKeys --->
    <cffunction name="getKeys" output="false" access="public" returntype="array" hint="Returns a list of all elements in the cache, whether or not they are expired.">
    </cffunction>
	
	<!--- get --->
    <cffunction name="get" output="false" access="public" returntype="any" hint="Get an object from the cache and updates stats">
    	<cfargument name="objectKey" type="any" required="true" hint="The object key"/>
    </cffunction>
	
	<!--- exists --->
	<cffunction name="exists" access="public" output="false" returntype="boolean" hint="Check if an object is in cache, if not found it records a miss.">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object to lookup.">
	</cffunction>	
	
	<!--- isExpired --->
    <cffunction name="isExpired" output="false" access="public" returntype="Boolean" hint="Checks if an object has expired in the cache">
    	<cfargument name="objectKey" type="any" required="true" hint="The key of the object to lookup its metadata">
	</cffunction>
	
	<!--- getCachedObjectMetadata --->
	<cffunction name="getCachedObjectMetadata" output="false" access="public" returntype="struct" hint="Get the cached object's metadata structure. If the object does not exist, it returns an empty structure.">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object to lookup its metadata">
	</cffunction>	
	
	<!--- Set --->
	<cffunction name="set" access="public" output="false" returntype="boolean" hint="sets an object in cache.">
		<!--- ************************************************************* --->
		<cfargument name="objectKey" 	type="any"  required="true" hint="The object cache key">
		<cfargument name="object"		type="any" 	required="true" hint="The object to cache">
	</cffunction>
	
	<!--- getSize --->
    <cffunction name="getSize" output="false" access="public" returntype="numeric" hint="Get the number of elements in the cache">
    </cffunction>

	<!--- reap --->
    <cffunction name="reap" output="false" access="public" returntype="void" hint="Reap the caches for expired objects and expiries">
    </cffunction>

	<!--- clearAll --->
    <cffunction name="clearAll" output="false" access="public" returntype="void" hint="Clear all the cache elements from the cache">
    </cffunction>

	<!--- Clear Key --->
	<cffunction name="clearKey" access="public" output="false" returntype="boolean" hint="Clears an object from the cache by using its cache key. Returns false if object was not removed or did not exist anymore">
		<cfargument name="objectKey" type="string" required="true" hint="The key the object was stored under.">
	</cffunction>
	
	<!--- expireAll --->
    <cffunction name="expireAll" output="false" access="public" returntype="void" hint="Expire all the elments in the cache">
    </cffunction>
	
	<!--- Expire Key --->
	<cffunction name="expireKey" access="public" output="false" returntype="boolean" hint="Expires an object from the cache by using its cache key. Returns false if object was not removed or did not exist anymore">
		<cfargument name="objectKey" type="string" required="true" hint="The key the object was stored under.">
	</cffunction>
	
</cfcomponent>