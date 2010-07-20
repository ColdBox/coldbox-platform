<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
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
			// Store Fields
			var fields = "hits,timeout,lastAccessTimeout,created,lastAccesed,isExpired";
			
			// Prepare instance
			instance = {
				storeID 		= createObject('java','java.lang.System').identityHashCode(this),
				cacheProvider   = arguments.cacheProvider,
				pool			= CreateObject("java","java.util.concurrent.ConcurrentHashMap").init(),
				indexer    		= CreateObject("component","coldbox.system.cache.util.MetadataIndexer").init(fields)
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
	<cffunction name="getIndexer" access="public" returntype="coldbox.system.cache.util.MetadataIndexer" output="false" hint="Get the store's pool metadata indexer structure">
		<cfreturn instance.indexer >
	</cffunction>
	
	<!--- getKeys --->
	<cffunction name="getKeys" output="false" access="public" returntype="array" hint="Get all the store's object keys">
		<cfreturn structKeyArray( getPool() )>
	</cffunction>
	
	<!--- lookup --->
	<cffunction name="lookup" access="public" output="false" returntype="boolean" hint="Check if an object is in cache.">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object">
		<cfscript>
			// Check if object in pool and object not dead
			if( structKeyExists(instance.pool, arguments.objectKey)  
			    AND instance.indexer.objectExists( arguments.objectKey ) 
				AND NOT instance.indexer.getObjectMetadataProperty(arguments.objectKey,"isExpired") ){
				return true;
			}
			
			return false;
		</cfscript>
	</cffunction>
	
	<!--- get --->
	<cffunction name="get" access="public" output="false" returntype="any" hint="Get an object from cache">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object">
		<cfscript>
			// Record Metadata Access
			instance.indexer.setObjectMetadataProperty(arguments.objectKey,"hits", instance.indexer.getObjectMetadataProperty(arguments.objectKey,"hits")+1);
			instance.indexer.setObjectMetadataProperty(arguments.objectKey,"lastAccesed", now());
			
			// return object
			return instance.pool[arguments.objectKey];
		</cfscript>
	</cffunction>
	
	<!--- getQuiet --->
	<cffunction name="getQuiet" access="public" output="false" returntype="any" hint="Get an object from cache with no stats">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object">
		<cfreturn instance.pool[arguments.objectKey]>
	</cffunction>
	
	<!--- expireObject --->
	<cffunction name="expireObject" output="false" access="public" returntype="void" hint="Mark an object for expiration">
		<cfargument name="objectKey" type="any"  required="true" hint="The object key">
		<cfset instance.indexer.setObjectMetadataProperty(arguments.objectKey,"isExpired", true)>
	</cffunction>
	
	<!--- isExpired --->
    <cffunction name="isExpired" output="false" access="public" returntype="boolean" hint="Test if an object in the store has expired or not">
    	<cfargument name="objectKey" type="any"  required="true" hint="The object key">
		<cfreturn instance.indexer.getObjectMetadataProperty(arguments.objectKey,"isExpired")>
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
			
			// Set new Object into cache pool
			instance.pool[arguments.objectKey] = arguments.object;
			
			// Create object's metdata
			metaData = {
				hits = 1,
				timeout = arguments.timeout,
				lastAccessTimeout = arguments.LastAccessTimeout,
				created = now(),
				lastAccesed = now(),		
				isExpired = false
			};
			
			// Save the object's metadata
			instance.indexer.setObjectMetadata(arguments.objectKey, metaData);
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
			
			// Remove it
			structDelete(instance.pool, arguments.objectKey);
			instance.indexer.clear( arguments.objectKey );
							
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