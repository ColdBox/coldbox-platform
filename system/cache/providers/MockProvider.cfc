<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	A mock cache provider that keeps cache data in a simple map for testing 
	and assertions

----------------------------------------------------------------------->
<cfcomponent hint="A mock cache provider" 
			 output="false" 
			 implements="coldbox.system.cache.IColdboxApplicationCache"
			 extends="coldbox.system.cache.AbstractCacheBoxProvider">
	
	<!--- init --->
    <cffunction name="init" output="false" access="public" returntype="any" hint="Simple Constructor">
    	<cfscript>
    		super.init();
			
			instance.cache = {};
			
			return this;
		</cfscript>
    </cffunction>

	<!--- configure --->
    <cffunction name="configure" output="false" access="public" returntype="void" hint="This method makes the cache ready to accept elements and run">
    	<cfscript>
    		instance.cache 	 = {};
			instance.enabled = true;
			instance.reportingEnabled = true;
		</cfscript>
    </cffunction>
	
	<!--- shutdown --->
    <cffunction name="shutdown" output="false" access="public" returntype="void" hint="Shutdown command issued when CacheBox is going through shutdown phase">
    </cffunction>
	
	<!--- getObjectStore --->
    <cffunction name="getObjectStore" output="false" access="public" returntype="any" hint="If the cache provider implements it, this returns the cache's object store as type: coldbox.system.cache.store.IObjectStore" colddoc:generic="coldbox.system.cache.store.IObjectStore">
   		<cfreturn instance.cache>
    </cffunction>
	
	<!--- getStoreMetadataReport --->
	<cffunction name="getStoreMetadataReport" output="false" access="public" returntype="any" hint="Get a structure of all the keys in the cache with their appropriate metadata structures. This is used to build the reporting.">
		<cfreturn structNew()>
	</cffunction>
	
	<!--- getStoreMetadataKeyMap --->
	<cffunction name="getStoreMetadataKeyMap" output="false" access="public" returntype="any" hint="Get a key lookup structure where cachebox can build the report on. Ex: [timeout=timeout,lastAccessTimeout=idleTimeout].  It is a way for the visualizer to construct the columns correctly on the reports">
		<cfscript>	
			var keyMap = {
				timeout = "timeout", hits = "hits", lastAccessTimeout = "lastAccessTimeout",
				created = "created", LastAccessed = "LastAccessed", isExpire="isExpired"
			};
			return keymap;
		</cfscript>
	</cffunction>

<!------------------------------------------- CACHE OPERATIONS ------------------------------------------>

	<!--- getKeys --->
    <cffunction name="getKeys" output="false" access="public" returntype="any" hint="Returns a list of all elements in the cache, whether or not they are expired.">
   		<cfreturn structKeyList(instance.cache)>
    </cffunction>
	
	<!--- getCachedObjectMetadata --->
	<cffunction name="getCachedObjectMetadata" output="false" access="public" returntype="any" hint="Get a cache objects metadata about its performance.">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object to lookup its metadata">
		<cfreturn structNew()>
	</cffunction>
	
	<!--- get --->
    <cffunction name="get" output="false" access="public" returntype="any" hint="Get an object from the cache and updates stats">
    	<cfargument name="objectKey" type="any" required="true" hint="The object key"/>
    	<cfreturn instance.cache[ arguments.objectKey ]>
	</cffunction>
	
	<!--- getQuiet --->
    <cffunction name="getQuiet" output="false" access="public" returntype="any" hint="Get an object from the cache without updating stats or listners">
    	<cfargument name="objectKey" type="any" required="true" hint="The object key"/>
		<cfreturn instance.cache[ arguments.objectKey ]>
    </cffunction>	
	
	<!--- isExpired --->
    <cffunction name="isExpired" output="false" access="public" returntype="any" hint="Has the object key expired in the cache">
   		<cfargument name="objectKey" type="any" required="true" hint="The object key"/>
		<cfreturn lookup(arguments.objectKey)>
   	</cffunction>
	
	<!--- lookup --->
	<cffunction name="lookup" access="public" output="false" returntype="any" hint="Check if an object is in cache, if not found it records a miss.">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object to lookup.">
		<cfreturn structKeyExists(instance.cache, arguments.objectKey)>
	</cffunction>	
	
	<!--- lookupQuiet --->
	<cffunction name="lookupQuiet" access="public" output="false" returntype="any" hint="Check if an object is in cache, no stats updated or listeners">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object to lookup.">
		<cfreturn structKeyExists(instance.cache, arguments.objectKey)>
    </cffunction>
	
	<!--- lookupValue --->
	<cffunction name="lookupValue" access="public" output="false" returntype="any" hint="Check if an object is in cache, if not found it records a miss.">
		<cfargument name="objectValue" type="any" required="true" hint="The value of the object to lookup.">
		<cfreturn instance.cache.containsValue( arguments.objectValue )>
	</cffunction>	
	
	<!--- Set --->
	<cffunction name="set" access="public" output="false" returntype="any" hint="sets an object in cache.">
		<!--- ************************************************************* --->
		<cfargument name="objectKey" 			type="any"  	required="true" hint="The object cache key">
		<cfargument name="object"				type="any" 		required="true" hint="The object to cache">
		<cfargument name="timeout"				type="any"  	required="false" hint="The timeout to use on the object (if any, provider specific)">
		<cfargument name="lastAccessTimeout"	type="any" 	 	required="false" hint="The idle timeout to use on the object (if any, provider specific)">
		<cfargument name="extra" 				type="any" 		required="false" hint="A map of name-value pairs to use as extra arguments to pass to a providers set operation"/>
		<cfset instance.cache[ arguments.objectKey ] = arguments.object>
		<cfreturn true>
	</cffunction>
	
	<!--- setQuiet --->
	<cffunction name="setQuiet" access="public" output="false" returntype="any" hint="sets an object in cache and returns true if set correctly, else false. With no statistic updates or listener updates">
		<!--- ************************************************************* --->
		<cfargument name="objectKey" 			type="any"  	required="true" hint="The object cache key">
		<cfargument name="object"				type="any" 		required="true" hint="The object to cache">
		<cfargument name="timeout"				type="any"  	required="false" hint="The timeout to use on the object (if any, provider specific)">
		<cfargument name="lastAccessTimeout"	type="any" 	 	required="false" hint="The idle timeout to use on the object (if any, provider specific)">
		<cfargument name="extra" 				type="any" 		required="false" hint="A map of name-value pairs to use as extra arguments to pass to a providers set operation"/>
		<cfset instance.cache[ arguments.objectKey ] = arguments.object>
		<cfreturn true>
	</cffunction>
	
	<!--- getSize --->
    <cffunction name="getSize" output="false" access="public" returntype="any" hint="Get the number of elements in the cache">
    	<cfreturn structCount(instance.cache)>
    </cffunction>

	<!--- reap --->
    <cffunction name="reap" output="false" access="public" returntype="void" hint="Reap the caches for expired objects and expiries">
    </cffunction>

	<!--- clearAll --->
    <cffunction name="clearAll" output="false" access="public" returntype="void" hint="Clear all the cache elements from the cache">
    	<cfset instance.cache = {}>
    </cffunction>
	
	<!--- clear --->
	<cffunction name="clear" access="public" output="false" returntype="any" hint="Clears an object from the cache by using its cache key. Returns false if object was not removed or did not exist anymore">
		<cfargument name="objectKey" 			type="any"  	required="true" hint="The object cache key">
		<cfreturn structDelete(instance.cache, arguments.objectKey, true)>
	</cffunction>
	
	<!--- expireAll --->
    <cffunction name="expireAll" output="false" access="public" returntype="void" hint="Expire all the elments in the cache">
    </cffunction>
	
	<!--- Expire Key --->
	<cffunction name="expireObject" access="public" output="false" returntype="void" hint="Expires an object from the cache by using its cache key. Returns false if object was not removed or did not exist anymore">
		<cfargument name="objectKey" 			type="any"  	required="true" hint="The object cache key">
	</cffunction>
	
	<!--- clearQuiet --->
	<cffunction name="clearQuiet" access="public" output="false" returntype="any" hint="Clears an object from the cache by using its cache key. Returns false if object was not removed or did not exist anymore without doing statistics or updating listeners">
		<cfargument name="objectKey" 			type="any"  	required="true" hint="The object cache key">
		<cfset clear(arguments.objectKey)>
	</cffunction>
	
<!------------------------------------------- ColdBox Application Cache Methods ------------------------------------------>

	<!--- getViewCacheKeyPrefix --->
    <cffunction name="getViewCacheKeyPrefix" output="false" access="public" returntype="any" hint="Get the cached view key prefix">
    	<cfreturn "mock-">
    </cffunction>

	<!--- getEventCacheKeyPrefix --->
    <cffunction name="getEventCacheKeyPrefix" output="false" access="public" returntype="any" hint="Get the event cache key prefix">
    	<cfreturn "mock-">
    </cffunction>

	<!--- getColdbox --->
    <cffunction name="getColdbox" output="false" access="public" returntype="any" hint="Get the coldbox application reference">
   		<cfreturn instance.coldbox>
    </cffunction>

	<!--- setColdbox --->
    <cffunction name="setColdbox" output="false" access="public" returntype="void" hint="Set the coldbox application reference">
    	<cfargument name="coldbox" type="any" required="true" hint="The coldbox application reference"/>
    	<cfset instance.coldbox = arguments.coldbox>
	</cffunction>

	<!--- getEventURLFacade --->
    <cffunction name="getEventURLFacade" output="false" access="public" returntype="any" hint="Get the event caching URL facade utility">
    	<cfreturn instance.eventURLFacade>
    </cffunction>

	<!--- Clear By Key Snippet --->
	<cffunction name="clearByKeySnippet" access="public" returntype="void" hint="Clears keys using the passed in object key snippet" output="false" >
		<cfargument name="keySnippet"  	type="any" required="true"  hint="the cache key snippet to use">
		<cfargument name="regex" 		type="any" hint="Use regex or not">
		<cfargument name="async" 		type="any" hint="Run command asynchronously or not"/>
	</cffunction>
	
	<!--- Clear All the Events form the cache --->
	<cffunction name="clearAllEvents" access="public" output="false" returntype="void" hint="Clears all events from the cache.">
		<cfargument name="async" type="any" hint="Run command asynchronously or not"/>
	</cffunction>
	
	<!--- clearEvent --->
	<cffunction name="clearEvent" access="public" output="false" returntype="void" hint="Clears all the event permutations from the cache according to snippet and querystring. Be careful when using incomplete event name with query strings as partial event names are not guaranteed to match with query string permutations">
		<cfargument name="eventsnippet" type="any" 	required="true"  hint="The event snippet to clear on. Can be partial or full">
		<cfargument name="queryString" 	type="any" 	required="false" default="" hint="If passed in, it will create a unique hash out of it. For purging purposes"/>
	</cffunction>
	
	<!--- Clear an event Multi --->
	<cffunction name="clearEventMulti" access="public" output="false" returntype="void" hint="Clears all the event permutations from the cache according to the list of snippets and querystrings. Be careful when using incomplete event name with query strings as partial event names are not guaranteed to match with query string permutations">
		<cfargument name="eventsnippets"    type="any"   	required="true"  hint="The comma-delimmitted list event snippet to clear on. Can be partial or full">
		<cfargument name="queryString"      type="any"   required="false" default="" hint="The comma-delimmitted list of queryStrings passed in. If passed in, it will create a unique hash out of it. For purging purposes.  If passed in the list length must be equal to the list length of the event snippets passed in."/>
      </cffunction>
	
	<!--- clearView --->
	<cffunction name="clearView" output="false" access="public" returntype="void" hint="Clears all view name permutations from the cache according to the view name.">
		<cfargument name="viewSnippet"  required="true" type="any" hint="The view name snippet to purge from the cache">
	</cffunction>
	
	<!--- clearViewMulti --->
	<cffunction name="clearViewMulti" output="false" access="public" returntype="void" hint="Clears all view name permutations from the cache according to the view name.">
		<cfargument name="viewSnippets"    type="any"   required="true"  hint="The comma-delimmitted list or array of view snippet to clear on. Can be partial or full">
	</cffunction>

	<!--- Clear All The Views from the Cache. --->
	<cffunction name="clearAllViews" access="public" output="false" returntype="void" hint="Clears all views from the cache.">
		<cfargument name="async" type="any" hint="Run command asynchronously or not"/>
	</cffunction>
	
</cfcomponent>