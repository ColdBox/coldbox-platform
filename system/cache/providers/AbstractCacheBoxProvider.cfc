<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	An abstract CacheBox Provider

Properties
- name : The cache name
- enabled : Boolean flag if cache is enabled
- reportingEnabled: Boolean falg if cache can report
- stats : The statistics object
- configuration : The configuration structure
- cacheFactory : The linkage to the cachebox factory
- eventManager : The linkage to the event manager
- cacheID : The unique identity code of this CFC
----------------------------------------------------------------------->
<cfcomponent hint="An abstract CacheBox Provider with basic/boring functionality built" 
			 output="false" 
			 implements="coldbox.system.cache.ICacheProvider" 
			 serializable="false"
			 colddoc:abstract="true">
	
	<!--- init --->
    <cffunction name="init" output="false" access="public" returntype="any" hint="Simple Constructor">
    	<cfscript>
    		instance = {
				name 				= "",
				enabled 			= false,
				reportingEnabled 	= false,
				stats   			= "",
				configuration 		= {},
				cacheFactory 		= "",
				eventManager		= "",
				cacheID				= createObject('java','java.lang.System').identityHashCode(this)
			};
			return this;
    	</cfscript>
    </cffunction>
	
	<!--- getCacheID --->
    <cffunction name="getCacheID" output="false" access="public" returntype="any" hint="The unique cache ID number">
    	<cfreturn instance.cacheID>
    </cffunction>

	<!--- getName --->
    <cffunction name="getName" output="false" access="public" returntype="string" hint="Get the name of this cache">
    	<cfreturn instance.name>
    </cffunction>
	
	<!--- setName --->
    <cffunction name="setName" output="false" access="public" returntype="void" hint="Set the cache name">
    	<cfargument name="name" type="string" required="true" hint="The cache name"/>
		<cfset instance.name = arguments.name>
    </cffunction>

	<!--- isEnabled --->
    <cffunction name="isEnabled" output="false" access="public" returntype="boolean" hint="Returns a flag indicating if the cache is ready for operation">
    	<cfreturn instance.enabled>
    </cffunction>
	
	<!--- isReportingEnabled --->
    <cffunction name="isReportingEnabled" output="false" access="public" returntype="boolean" hint="Returns a flag indicating if the cache has reporting enabled">
   		<cfreturn instance.reportingEnabled>
    </cffunction>

	<!--- getStats --->
    <cffunction name="getStats" output="false" access="public" returntype="any" hint="Get the cache statistics object as coldbox.system.cache.util.ICacheStats" colddoc:generic="coldbox.system.cache.util.ICacheStats">
    	<cfreturn instance.stats>
    </cffunction>
	
	<!--- clearStatistics --->
    <cffunction name="clearStatistics" output="false" access="public" returntype="void" hint="Clear the cache statistics">
    	<cfset instance.stats.clearStatistics()>
    </cffunction>

	<!--- getConfiguration --->
    <cffunction name="getConfiguration" output="false" access="public" returntype="struct" hint="Get the structure of configuration parameters for the cache">
    	<cfreturn instance.configuration>
    </cffunction>

	<!--- setConfiguration --->
    <cffunction name="setConfiguration" output="false" access="public" returntype="void" hint="Override the entire configuration structure for this cache">
    	<cfargument name="configuration" type="struct" required="true" hint="The configuration structure"/>
		<cfset instance.configuration = arguments.configuration>
    </cffunction>

	<!--- getCacheFactory --->
    <cffunction name="getCacheFactory" output="false" access="public" returntype="coldbox.system.cache.CacheFactory" hint="Get the cache factory reference this cache provider belongs to">
   		<cfreturn instance.cacheFactory>
    </cffunction>
	
	<!--- setCacheFactory --->
    <cffunction name="setCacheFactory" output="false" access="public" returntype="void" hint="Set the cache factory reference for this cache">
    	<cfargument name="cacheFactory" type="coldbox.system.cache.CacheFactory" required="true"/>
		<cfset instance.cacheFactory = arguments.cacheFactory>
    </cffunction>

	<!--- getEventManager --->
    <cffunction name="getEventManager" output="false" access="public" returntype="any" hint="Get this cache managers event listner manager">
    	<cfreturn instance.eventManager>
    </cffunction>
	
	<!--- setEventManager --->
    <cffunction name="setEventManager" output="false" access="public" returntype="void" hint="Set the event manager for this cache">
    	<cfargument name="eventManager" type="any" required="true" hint="The event manager class"/>
    	<cfset instance.eventManager = arguments.eventManager>
	</cffunction>
	
<!------------------------------------------- ABSTRACT CACHE OPERATIONS ------------------------------------------>

	<!--- configure --->
    <cffunction name="configure" output="false" access="public" returntype="void" hint="This method makes the cache ready to accept elements and run">
  		<cfthrow message="Abstract method, please implement" type="AbstractMethodException">
    </cffunction>
			
	<!--- shutdown --->
    <cffunction name="shutdown" output="false" access="public" returntype="void" hint="Shutdown command issued when CacheBox is going through shutdown phase">
    	<cfthrow message="Abstract method, please implement" type="AbstractMethodException">
    </cffunction>
	
	<!--- getObjectStore --->
    <cffunction name="getObjectStore" output="false" access="public" returntype="any" hint="If the cache provider implements it, this returns the cache's object store as type: coldbox.system.cache.store.IObjectStore" colddoc:generic="coldbox.system.cache.store.IObjectStore">
   		<cfthrow message="Abstract method, please implement" type="AbstractMethodException">
    </cffunction>
	
	<!--- getStoreMetadataReport --->
	<cffunction name="getStoreMetadataReport" output="false" access="public" returntype="struct" hint="Get a structure of all the keys in the cache with their appropriate metadata structures. This is used to build the reporting.">
		<cfthrow message="Abstract method, please implement" type="AbstractMethodException">
	</cffunction>

	<!--- getKeys --->
    <cffunction name="getKeys" output="false" access="public" returntype="array" hint="Returns a list of all elements in the cache, whether or not they are expired.">
    	<cfthrow message="Abstract method, please implement" type="AbstractMethodException">
    </cffunction>
	
	<!--- getCachedObjectMetadata --->
	<cffunction name="getCachedObjectMetadata" output="false" access="public" returntype="struct" hint="Get a cache objects metadata about its performance.">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object to lookup its metadata">
		<cfthrow message="Abstract method, please implement" type="AbstractMethodException">
	</cffunction>
	
	<!--- get --->
    <cffunction name="get" output="false" access="public" returntype="any" hint="Get an object from the cache and updates stats">
    	<cfargument name="objectKey" type="any" required="true" hint="The object key"/>
    	<cfthrow message="Abstract method, please implement" type="AbstractMethodException">
    </cffunction>
	
	<!--- getQuiet --->
    <cffunction name="getQuiet" output="false" access="public" returntype="any" hint="Get an object from the cache without updating stats or listners">
    	<cfargument name="objectKey" type="any" required="true" hint="The object key"/>
		<cfthrow message="Abstract method, please implement" type="AbstractMethodException">
    </cffunction>	
	
	<!--- isExpired --->
    <cffunction name="isExpired" output="false" access="public" returntype="boolean" hint="Has the object key expired in the cache">
   		<cfargument name="objectKey" type="any" required="true" hint="The object key"/>
		<cfthrow message="Abstract method, please implement" type="AbstractMethodException">
   	</cffunction>
	
	<!--- lookup --->
	<cffunction name="lookup" access="public" output="false" returntype="boolean" hint="Check if an object is in cache, if not found it records a miss.">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object to lookup.">
		<cfthrow message="Abstract method, please implement" type="AbstractMethodException">
    </cffunction>	
	
	<!--- lookupQuiet --->
	<cffunction name="lookupQuiet" access="public" output="false" returntype="boolean" hint="Check if an object is in cache, no stats updated or listeners">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object to lookup.">
		<cfthrow message="Abstract method, please implement" type="AbstractMethodException">
    </cffunction>

	<!--- Set --->
	<cffunction name="set" access="public" output="false" returntype="boolean" hint="sets an object in cache and returns true if set correctly, else false.">
		<!--- ************************************************************* --->
		<cfargument name="objectKey" 			type="any"  	required="true" hint="The object cache key">
		<cfargument name="object"				type="any" 		required="true" hint="The object to cache">
		<cfargument name="timeout"				type="any"  	required="false" default="" hint="The timeout to use on the object (if any, provider specific)">
		<cfargument name="lastAccessTimeout"	type="any" 	 	required="false" default="" hint="The idle timeout to use on the object (if any, provider specific)">
		<cfargument name="extra" 				type="struct" 	required="false" hint="A map of name-value pairs to use as extra arguments to pass to a providers set operation"/>
		<cfthrow message="Abstract method, please implement" type="AbstractMethodException">
    </cffunction>
	
	<!--- setQuiet --->
	<cffunction name="setQuiet" access="public" output="false" returntype="boolean" hint="sets an object in cache and returns true if set correctly, else false. With no statistic updates or listener updates">
		<!--- ************************************************************* --->
		<cfargument name="objectKey" 			type="any"  	required="true" hint="The object cache key">
		<cfargument name="object"				type="any" 		required="true" hint="The object to cache">
		<cfargument name="timeout"				type="any"  	required="false" default="" hint="The timeout to use on the object (if any, provider specific)">
		<cfargument name="lastAccessTimeout"	type="any" 	 	required="false" default="" hint="The idle timeout to use on the object (if any, provider specific)">
		<cfargument name="extra" 				type="struct" 	required="false" hint="A map of name-value pairs to use as extra arguments to pass to a providers set operation"/>
		<cfthrow message="Abstract method, please implement" type="AbstractMethodException">
    </cffunction>
	
	<!--- getSize --->
    <cffunction name="getSize" output="false" access="public" returntype="numeric" hint="Get the number of elements in the cache">
    	<cfthrow message="Abstract method, please implement" type="AbstractMethodException">
    </cffunction>

	<!--- reap --->
    <cffunction name="reap" output="false" access="public" returntype="void" hint="Reap the caches for expired objects and expiries">
    	<cfthrow message="Abstract method, please implement" type="AbstractMethodException">
    </cffunction>

	<!--- clearAll --->
    <cffunction name="clearAll" output="false" access="public" returntype="void" hint="Clear all the cache elements from the cache">
    	<cfthrow message="Abstract method, please implement" type="AbstractMethodException">
    </cffunction>

	<!--- clear --->
	<cffunction name="clear" access="public" output="false" returntype="boolean" hint="Clears an object from the cache by using its cache key. Returns false if object was not removed or did not exist anymore">
		<cfargument name="objectKey" 			type="any"  	required="true" hint="The object cache key">
		<cfthrow message="Abstract method, please implement" type="AbstractMethodException">
	</cffunction>
	
	<!--- clearQuiet --->
	<cffunction name="clearQuiet" access="public" output="false" returntype="boolean" hint="Clears an object from the cache by using its cache key. Returns false if object was not removed or did not exist anymore without doing statistics or updating listeners">
		<cfargument name="objectKey" 			type="any"  	required="true" hint="The object cache key">
		<cfthrow message="Abstract method, please implement" type="AbstractMethodException">
	</cffunction>
	
	<!--- expireAll --->
    <cffunction name="expireAll" output="false" access="public" returntype="void" hint="Expire all the elments in the cache">
   		<cfthrow message="Abstract method, please implement" type="AbstractMethodException">
    </cffunction>
	
	<!--- Expire Key --->
	<cffunction name="expireKey" access="public" output="false" returntype="void" hint="Expires an object from the cache by using its cache key. Returns false if object was not removed or did not exist anymore">
		<cfargument name="objectKey" 			type="any"  	required="true" hint="The object cache key">
		<cfthrow message="Abstract method, please implement" type="AbstractMethodException">
    </cffunction>
	
	<!--- getMemento --->
    <cffunction name="getMemento" output="false" access="public" returntype="any" hint="">
    	<cfreturn instance>
    </cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------>

	<!--- Get Util --->
	<cffunction name="getUtil" access="private" output="false" returntype="coldbox.system.core.util.Util" hint="Create and return a util object">
		<cfreturn CreateObject("component","coldbox.system.core.util.Util")/>
	</cffunction>	
	
</cfcomponent>