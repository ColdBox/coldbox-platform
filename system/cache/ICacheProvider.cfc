<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	The main interface for a CacheBox cache provider.  You need to implement 
	all the methods in order for CacheBox to work correctly for the implementing
	cache provider.
	
	Please note that all cache providers have a reference back to the CacheBox Factory.

----------------------------------------------------------------------->
<cfinterface hint="The main interface for a CacheBox cache provider object, you implement it so CacheBox can manage it for you.">

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
	
	<!--- isReportingEnabled --->
    <cffunction name="isReportingEnabled" output="false" access="public" returntype="boolean" hint="Returns a flag indicating if the cache has reporting enabled">
    </cffunction>

	<!--- getStats --->
    <cffunction name="getStats" output="false" access="public" returntype="any" hint="Get the cache statistics object as coldbox.system.cache.util.ICacheStats" colddoc:generic="coldbox.system.cache.util.ICacheStats">
    </cffunction>
	
	<!--- clearStatistics --->
    <cffunction name="clearStatistics" output="false" access="public" returntype="void" hint="Clear the cache statistics">
    </cffunction>
	
	<!--- getConfiguration --->
    <cffunction name="getConfiguration" output="false" access="public" returntype="struct" hint="Get the structure of configuration parameters for the cache">
    </cffunction>

	<!--- setConfiguration --->
    <cffunction name="setConfiguration" output="false" access="public" returntype="void" hint="Set the entire configuration structure for this cache">
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
    <cffunction name="getEventManager" output="false" access="public" returntype="any" hint="Get this cache managers event listener manager">
    </cffunction>
	
	<!--- setEventManager --->
    <cffunction name="setEventManager" output="false" access="public" returntype="void" hint="Set the event manager for this cache">
    	<cfargument name="eventManager" type="any" required="true" hint="The event manager class"/>
    </cffunction>

	<!--- configure --->
    <cffunction name="configure" output="false" access="public" returntype="void" hint="This method makes the cache ready to accept elements and run.  Usualy a cache is first created (init), then wired and then the factory calls configure() on it">
    </cffunction>
			
	<!--- shutdown --->
    <cffunction name="shutdown" output="false" access="public" returntype="void" hint="Shutdown command issued when CacheBox is going through shutdown phase">
    </cffunction>
	
	<!--- getObjectStore --->
    <cffunction name="getObjectStore" output="false" access="public" returntype="any" hint="If the cache provider implements it, this returns the cache's object store as type: coldbox.system.cache.store.IObjectStore" colddoc:generic="coldbox.system.cache.store.IObjectStore">
    </cffunction>
	
	<!--- getStoreMetadataReport --->
	<cffunction name="getStoreMetadataReport" output="false" access="public" returntype="struct" hint="Get a structure of all the keys in the cache with their appropriate metadata structures. This is used to build the reporting.[keyX->[metadataStructure]]">
	</cffunction>
	
<!------------------------------------------- CACHE OPERATIONS ------------------------------------------>

	<!--- getKeys --->
    <cffunction name="getKeys" output="false" access="public" returntype="array" hint="Returns a list of all elements in the cache, whether or not they are expired.">
    </cffunction>
	
	<!--- getCachedObjectMetadata --->
	<cffunction name="getCachedObjectMetadata" output="false" access="public" returntype="struct" hint="Get a cache objects metadata about its performance. This value is a structure of name-value pairs of metadata.">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object to lookup its metadata">
	</cffunction>
	
	<!--- get --->
    <cffunction name="get" output="false" access="public" returntype="any" hint="Get an object from the cache and updates stats">
    	<cfargument name="objectKey" type="any" required="true" hint="The object key"/>
    </cffunction>
	
	<!--- getQuiet --->
    <cffunction name="getQuiet" output="false" access="public" returntype="any" hint="Get an object from the cache without updating stats or listners">
    	<cfargument name="objectKey" type="any" required="true" hint="The object key"/>
    </cffunction>	
	
	<!--- isExpired --->
    <cffunction name="isExpired" output="false" access="public" returntype="boolean" hint="Has the object key expired in the cache">
   		<cfargument name="objectKey" type="any" required="true" hint="The object key"/>
   	</cffunction>
	
	<!--- lookup --->
	<cffunction name="lookup" access="public" output="false" returntype="boolean" hint="Check if an object is in cache, if not found it records a miss.">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object to lookup.">
	</cffunction>	
	
	<!--- lookupQuiet --->
	<cffunction name="lookupQuiet" access="public" output="false" returntype="boolean" hint="Check if an object is in cache, no stats updated or listeners">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object to lookup.">
	</cffunction>
	
	<!--- Set --->
	<cffunction name="set" access="public" output="false" returntype="boolean" hint="sets an object in cache and returns true if set correctly, else false.">
		<!--- ************************************************************* --->
		<cfargument name="objectKey" 			type="any"  	required="true" hint="The object cache key">
		<cfargument name="object"				type="any" 		required="true" hint="The object to cache">
		<cfargument name="timeout"				type="any"  	required="false" hint="The timeout to use on the object (if any, provider specific)">
		<cfargument name="lastAccessTimeout"	type="any" 	 	required="false" hint="The idle timeout to use on the object (if any, provider specific)">
		<cfargument name="extra" 				type="struct" 	required="false" hint="A map of name-value pairs to use as extra arguments to pass to a providers set operation"/>
	</cffunction>
	
	<!--- setQuiet --->
	<cffunction name="setQuiet" access="public" output="false" returntype="boolean" hint="sets an object in cache and returns true if set correctly, else false. With no statistic updates or listener updates">
		<!--- ************************************************************* --->
		<cfargument name="objectKey" 			type="any"  	required="true" hint="The object cache key">
		<cfargument name="object"				type="any" 		required="true" hint="The object to cache">
		<cfargument name="timeout"				type="any"  	required="false" hint="The timeout to use on the object (if any, provider specific)">
		<cfargument name="lastAccessTimeout"	type="any" 	 	required="false" hint="The idle timeout to use on the object (if any, provider specific)">
		<cfargument name="extra" 				type="struct" 	required="false" hint="A map of name-value pairs to use as extra arguments to pass to a providers set operation"/>
	</cffunction>
	
	<!--- getSize --->
    <cffunction name="getSize" output="false" access="public" returntype="numeric" hint="Get the number of elements in the cache">
    </cffunction>

	<!--- reap --->
    <cffunction name="reap" output="false" access="public" returntype="void" hint="Send a reap or flush command to the cache">
    </cffunction>

	<!--- clearAll --->
    <cffunction name="clearAll" output="false" access="public" returntype="void" hint="Clear all the cache elements from the cache">
    </cffunction>

	<!--- clear --->
	<cffunction name="clear" access="public" output="false" returntype="boolean" hint="Clears an object from the cache by using its cache key. Returns false if object was not removed or did not exist anymore">
		<cfargument name="objectKey" 			type="any"  	required="true" hint="The object cache key">
	</cffunction>
	
	<!--- clearQuiet --->
	<cffunction name="clearQuiet" access="public" output="false" returntype="boolean" hint="Clears an object from the cache by using its cache key. Returns false if object was not removed or did not exist anymore without doing statistics or updating listeners">
		<cfargument name="objectKey" 			type="any"  	required="true" hint="The object cache key">
	</cffunction>
	
	<!--- expireAll --->
    <cffunction name="expireAll" output="false" access="public" returntype="void" hint="Expire all the elments in the cache (if supported by the provider)">
    </cffunction>
	
	<!--- Expire Key --->
	<cffunction name="expireKey" access="public" output="false" returntype="void" hint="Expires an object from the cache by using its cache key. Returns false if object was not removed or did not exist anymore (if supported by the provider)">
		<cfargument name="objectKey" 			type="any"  	required="true" hint="The object cache key">
	</cffunction>

</cfinterface>