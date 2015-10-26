<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************
Author 	    :	Luis Majano
Description :
	I am a concurrent object store. In other words, I am fancy!
	This store is case-sensitive
----------------------------------------------------------------------->
<cfcomponent hint="I am a concurrent object store. In other words, I am fancy!" output="false" implements="coldbox.system.cache.store.IObjectStore">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<!--- init --->
	<cffunction name="init" access="public" output="false" returntype="ConcurrentStore" hint="Constructor">
		<cfargument name="cacheProvider" type="any" required="true" hint="The associated cache provider as coldbox.system.cache.ICacheProvider" colddoc:generic="coldbox.system.cache.ICacheProvider"/>
		<cfscript>
			// Indexing Fields
			var fields = "hits,timeout,lastAccessTimeout,created,LastAccessed,isExpired";
			
			// Prepare instance
			instance = {
				cacheProvider   = arguments.cacheProvider,
				storeID 		= createObject('java','java.lang.System').identityHashCode(this),
				pool			= createObject("java","java.util.concurrent.ConcurrentHashMap").init(),
				indexer    		= createObject("component","coldbox.system.cache.store.indexers.MetadataIndexer").init(fields)
			};
			
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- INTERFACE PUBLIC METHODS ------------------------------------------->
	
	<!--- flush --->
    <cffunction name="flush" output="false" access="public" returntype="void" hint="Flush the store to a permanent storage">
    </cffunction>
	
	<!--- reap --->
    <cffunction name="reap" output="false" access="public" returntype="void" hint="Reap the storage, clean it from old stuff">
    </cffunction>
	
	<!--- getStoreID --->
    <cffunction name="getStoreID" output="false" access="public" returntype="any" hint="Get this storage's ID">
    	<cfreturn instance.storeID>
    </cffunction>
	
	<!--- clearAll --->
    <cffunction name="clearAll" output="false" access="public" returntype="void" hint="Clear all elements of the store">
		<cfscript>
			instance.pool.clear();
			instance.indexer.clearAll();
		</cfscript>
    </cffunction>
	
	<!--- getPool --->
	<cffunction name="getPool" access="public" returntype="any" output="false" hint="Get a reference to the store's pool of objects">
		<cfreturn instance.pool>
	</cffunction>

	<!--- getIndexer --->
	<cffunction name="getIndexer" access="public" returntype="any" output="false" hint="Get the store's pool metadata indexer structure">
		<cfreturn instance.indexer>
	</cffunction>
	
	<!--- getKeys --->
	<cffunction name="getKeys" output="false" access="public" returntype="any" hint="Get all the store's object keys">
		<cfreturn structKeyArray( getPool() )>
	</cffunction>
	
	<!--- lookup --->
	<cffunction name="lookup" access="public" output="false" returntype="any" hint="Check if an object is in cache.">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object">
		
		<cflock name="ConcurrentStore.#instance.storeID#.#arguments.objectKey#" type="readonly" timeout="10" throwonTimeout="true">
		<cfscript>
			// Check if object in pool and object not dead
			if( structKeyExists( instance.pool , arguments.objectKey)  
			    AND instance.indexer.objectExists( arguments.objectKey ) 
				AND NOT instance.indexer.getObjectMetadataProperty(arguments.objectKey,"isExpired") ){
				return true;
			}
			
			return false;
		</cfscript>
		</cflock>
	</cffunction>
	
	<!--- get --->
	<cffunction name="get" access="public" output="false" returntype="any" hint="Get an object from the object store, returns java null if not found">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object">
		
		<cfset var refLocal = structnew()>
		
		<cflock name="ConcurrentStore.#instance.storeID#.#arguments.objectKey#" type="exclusive" timeout="10" throwonTimeout="true">
		<cfscript>
			// retrieve from map
			refLocal.results = instance.pool.get( arguments.objectKey );
			if( structKeyExists(refLocal,"results") ){
			
				// Record Metadata Access
				instance.indexer.setObjectMetadataProperty(arguments.objectKey,"hits", instance.indexer.getObjectMetadataProperty(arguments.objectKey,"hits")+1);
				instance.indexer.setObjectMetadataProperty(arguments.objectKey,"LastAccessed", now());
				
				// return object
				return refLocal.results;
			}
		</cfscript>
		</cflock>
	</cffunction>
	
	<!--- getQuiet --->
	<cffunction name="getQuiet" access="public" output="false" returntype="any" hint="Get an object from cache with no stats, null if not found">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object">
		<cfset var refLocal = structnew()>
		
		<cflock name="ConcurrentStore.#instance.storeID#.#arguments.objectKey#" type="readonly" timeout="10" throwonTimeout="true">
			<cfscript>
				// retrieve from map
				refLocal.results = instance.pool.get( arguments.objectKey );
				if( structKeyExists(refLocal,"results") ){
					return refLocal.results;
				}
			</cfscript>
		</cflock>
	</cffunction>
	
	<!--- expireObject --->
	<cffunction name="expireObject" output="false" access="public" returntype="void" hint="Mark an object for expiration">
		<cfargument name="objectKey" type="any"  required="true" hint="The object key">
		
		<cflock name="ConcurrentStore.#instance.storeID#.#arguments.objectKey#" type="exclusive" timeout="10" throwonTimeout="true">
			<cfset instance.indexer.setObjectMetadataProperty(arguments.objectKey,"isExpired", true)>
		</cflock>
		
	</cffunction>
	
	<!--- isExpired --->
    <cffunction name="isExpired" output="false" access="public" returntype="any" hint="Test if an object in the store has expired or not">
    	<cfargument name="objectKey" type="any"  required="true" hint="The object key">
		
		<cflock name="ConcurrentStore.#instance.storeID#.#arguments.objectKey#" type="readonly" timeout="10" throwonTimeout="true">
			<cfreturn instance.indexer.getObjectMetadataProperty(arguments.objectKey,"isExpired")>
		</cflock>
		
    </cffunction>

	<!--- Set an Object in the pool --->
	<cffunction name="set" access="public" output="false" returntype="void" hint="sets an object in the storage.">
		<!--- ************************************************************* --->
		<cfargument name="objectKey" 			type="any"  required="true" hint="The object key">
		<cfargument name="object"				type="any" 	required="true" hint="The object to save">
		<cfargument name="timeout"				type="any"  required="false" default="" hint="Timeout in minutes">
		<cfargument name="lastAccessTimeout"	type="any"  required="false" default="" hint="Timeout in minutes">
		<cfargument name="extras" 				type="any" default="#structnew()#" hint="A map of extra name-value pairs"/>
		<!--- ************************************************************* --->
		
		<cfset var metadata = {}>
		
		<cflock name="ConcurrentStore.#instance.storeID#.#arguments.objectKey#" type="exclusive" timeout="10" throwonTimeout="true">
		<cfscript>
			// Set new Object into cache pool
			instance.pool[arguments.objectKey] = arguments.object;
			
			// Create object's metdata
			metaData = {
				hits = 1,
				timeout = arguments.timeout,
				lastAccessTimeout = arguments.LastAccessTimeout,
				created = now(),
				LastAccessed = now(),		
				isExpired = false
			};
			
			// Save the object's metadata
			instance.indexer.setObjectMetadata(arguments.objectKey, metaData);
		</cfscript>
		</cflock>
	</cffunction>

	<!--- Clear an object from the pool --->
	<cffunction name="clear" access="public" output="false" returntype="any" hint="Clears an object from the storage pool">
		<cfargument name="objectKey" 			type="any"  required="true" hint="The object key">
		
		<cfset var target = "">
		
		<cflock name="ConcurrentStore.#instance.storeID#.#arguments.objectKey#" type="exclusive" timeout="10" throwonTimeout="true">
		<cfscript>
			
			// Check if it exists
			if( NOT structKeyExists(instance.pool, arguments.objectKey) ){
				return false;
			}
			
			// Remove it
			structDelete(instance.pool, arguments.objectKey);
			instance.indexer.clear( arguments.objectKey );
							
			// Removed
			return true;
		</cfscript>
		</cflock>
	</cffunction>

	<!--- Get the size of the pool --->
	<cffunction name="getSize" access="public" output="false" returntype="any" hint="Get the cache's size in items">
		<cfreturn structCount( instance.pool )>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->

</cfcomponent>