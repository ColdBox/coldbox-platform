<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Author 	    :	Luis Majano
Description :
	I am a concurrent object store. In other words, I am fancy!
	
	The structure for the metadata report can be found below for each objectKey, which in turn
	is stored in its own concurrent map for easy sorting and querying.
	
	objectKey = {
		hits,
		misses,
		timeout,
		lastAccessTimeout,
		created,
		lastAccessed,
		isExpired
	};
----------------------------------------------------------------------->
<cfcomponent hint="I am a concurrent object store. In other words, I am fancy!" output="false" implements="coldbox.system.cache.store.IObjectStore">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<!--- init --->
	<cffunction name="init" access="public" output="false" returntype="ConcurrentStore" hint="Constructor">
		<cfargument name="cacheProvider" type="coldbox.system.cache.ICacheProvider" required="true" hint="The associated cache provider"/>
		<cfscript>
			
			// Prepare instance
			instance = {
				storeID 		= createObject('java','java.lang.System').identityHashCode(this),
				cacheProvider   = arguments.cacheProvider,
				pool			= CreateObject("java","java.util.concurrent.ConcurrentHashMap").init(),
				poolMetadata    = CreateObject("java","java.util.concurrent.ConcurrentHashMap").init()
			};
			
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- INTERFACE PUBLIC METHODS ------------------------------------------->
	
	<!--- flush --->
    <cffunction name="flush" output="false" access="public" returntype="void" hint="Flush the store to a permanent storage">
    </cffunction>
	
	<!--- getStoreID --->
    <cffunction name="getStoreID" output="false" access="public" returntype="string" hint="Get this storage's ID">
    	<cfreturn instance.storeID>
    </cffunction>
	
	<!--- clearAll --->
    <cffunction name="clearAll" output="false" access="public" returntype="void" hint="Clear all elements of the store">
    	
    	<cflock name="store.metadata.#instance.storeID#" type="exclusive" timeout="10" throwonTimeout="true">
			<cfscript>
				instance.pool.clear();
				instance.poolMetadata.clear();
			</cfscript>
		</cflock>
		
    </cffunction>
	
	<!--- getPool --->
	<cffunction name="getPool" access="public" returntype="any" output="false" hint="Get a reference to the store's pool of objects">
		<cfreturn instance.pool>
	</cffunction>

	<!--- getPoolMetadata --->
	<cffunction name="getPoolMetadata" access="public" returntype="any" output="false" hint="Get the store's pool metadata report structure">
		<cflock name="store.metadata.#instance.storeID#" type="readonly" timeout="10" throwonTimeout="true">
			<cfreturn instance.poolMetadata >
		</cflock>
	</cffunction>
	
	<!--- getKeys --->
	<cffunction name="getKeys" output="false" access="public" returntype="array" hint="Get all the store's object keys">
		<cfreturn structKeyArray( getPoolMetadata() )>
	</cffunction>
	
	<!--- getObjectMetadata --->
	<cffunction name="getObjectMetadata" access="public" returntype="any" output="false" hint="Get a metadata entry for a specific cache entry">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object">
		
		<cflock name="store.metadata.#instance.storeID#" type="readonly" timeout="10" throwonTimeout="true">
			<cfreturn instance.poolMetadata[ arguments.objectKey ] >
		</cflock>
		
	</cffunction>
	
	<!--- setObjectMetadata --->
	<cffunction name="setObjectMetadata" access="public" returntype="void" output="false" hint="Set the metadata entry for a specific cache entry">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object">
		<cfargument name="metadata"  type="any" required="true" hint="The metadata structure to store for the cache entry">
		
		<cflock name="store.metadata.#instance.storeID#" type="exclusive" timeout="10" throwonTimeout="true">
			<cfset instance.poolMetadata[ arguments.objectKey ] = arguments.metadata>
		</cflock>
		
	</cffunction>
	
	<!--- getMetadataProperty --->
	<cffunction name="getMetadataProperty" access="public" returntype="any" output="false" hint="Get a specific metadata property for a specific cache entry">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object">
		<cfargument name="property"  type="any" required="true" hint="The property of the metadata to retrieve">
		
		<cflock name="store.metadata.#instance.storeID#" type="readonly" timeout="10" throwonTimeout="true">
			<cfreturn instance.poolMetadata[ arguments.objectKey ][ arguments.property ] >
		</cflock>
		
	</cffunction>
	
	<!--- setMetadataProperty --->
	<cffunction name="setMetadataProperty" access="public" returntype="void" output="false" hint="Set a metadata property for a specific cache entry">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object">
		<cfargument name="property"  type="any" required="true" hint="The property of the metadata to retrieve">
		<cfargument name="value"  	 type="any" required="true" hint="The value of the property">
		
		<cflock name="store.metadata.#instance.storeID#" type="exclusive" timeout="10" throwonTimeout="true">
			<cfset instance.poolMetadata[ arguments.objectKey ][ arguments.property ] = arguments.value >
		</cflock>
		
	</cffunction>
	
	<!--- lookup --->
	<cffunction name="lookup" access="public" output="false" returntype="boolean" hint="Check if an object is in cache.">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object">
		<cfscript>
			// Check if object in pool and object not dead
			if( structKeyExists(instance.pool, arguments.objectKey)  
			    AND structKeyExists(instance.poolMetadata,arguments.objectKey) 
				AND NOT instance.poolMetadata[arguments.objectkey].isExpired){
				return true;
			}
			
			return false;
		</cfscript>
	</cffunction>
	
	<!--- Get an object from the pool --->
	<cffunction name="get" access="public" output="false" returntype="any" hint="Get an object from cache">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object">
		<cfscript>
			// Record Metadata Access
			setMetadataProperty(arguments.objectKey,"hits", getMetaDataProperty(arguments.objectKey,"hits")+1);
			setMetadataProperty(arguments.objectKey,"lastAccesed", now());
			
			// Get Object
			return instance.pool[arguments.objectKey];
		</cfscript>
	</cffunction>
	
	<!--- expireObject --->
	<cffunction name="expireObject" output="false" access="public" returntype="void" hint="Mark an object for expiration">
		<cfargument name="objectKey" type="any"  required="true" hint="The object key">
		<cfscript>
			setMetadataProperty(arguments.objectKey,"isExpired", true );
		</cfscript>
	</cffunction>
	
	<!--- isExpired --->
    <cffunction name="isExpired" output="false" access="public" returntype="boolean" hint="Test if an object in the store has expired or not">
    	<cfargument name="objectKey" type="any"  required="true" hint="The object key">
		<cfreturn getMetadataProperty(arguments.objectKey,"isExpired")>
    </cffunction>

	<!--- Set an Object in the pool --->
	<cffunction name="set" access="public" output="false" returntype="void" hint="sets an object in the storage.">
		<!--- ************************************************************* --->
		<cfargument name="objectKey" 			type="any"  required="true" hint="The object key">
		<cfargument name="object"				type="any" 	required="true" hint="The object to save">
		<cfargument name="timeout"				type="any"  required="false" default="" hint="Timeout in minutes">
		<cfargument name="lastAccessTimeout"	type="any"  required="false" default="" hint="Timeout in minutes">
		<cfargument name="extras" 				type="struct" default="#structnew()#" hint="A map of extra name-value pairs"/>
		<!--- ************************************************************* --->
		<cfscript>
			var metaData 	= structnew();
			var targetObj 	= 0;
			
			// set target object to save
			targetObj = arguments.object;
			
			// Set new Object into cache pool
			instance.pool[arguments.objectKey] = targetObj;
			
			// Create object's metdata
			metaData.hits = 1;
			metaData.Timeout = arguments.timeout;
			metaData.LastAccessTimeout = arguments.LastAccessTimeout;
			metaData.Created = now();
			metaData.LastAccesed = now();		
			metaData.isExpired = false;	
			
			// Save the object's metadata
			setObjectMetaData(arguments.objectkey,metaData);
		</cfscript>
	</cffunction>

	<!--- Clear an object from the pool --->
	<cffunction name="clear" access="public" output="false" returntype="boolean" hint="Clears an object from the storage pool">
		<cfargument name="objectKey" 			type="any"  required="true" hint="The object key">
		<cfscript>
			var target = "";
		
			// Check if it exists
			if( NOT structKeyExists(instance.pool, arguments.objectKey) ){
				return false;
			}
			
			// Remove Normal Cache Entries
			structDelete(instance.pool, arguments.objectKey);
			structDelete(instance.poolMetadata, arguments.objectKey);
							
			// Removed
			return true;
		</cfscript>
	</cffunction>

	<!--- Get the size of the pool --->
	<cffunction name="getSize" access="public" output="false" returntype="numeric" hint="Get the cache's size in items">
		<cfreturn getPool().size()>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->

</cfcomponent>