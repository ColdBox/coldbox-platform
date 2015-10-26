<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************
Author 	    :	Luis Majano
Description :
	I am a disk store, I am not that fancy as I am slower.

----------------------------------------------------------------------->
<cfcomponent hint="I am a disk store, I am not that fancy as I am slower." output="false" implements="coldbox.system.cache.store.IObjectStore">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<!--- init --->
	<cffunction name="init" access="public" output="false" returntype="DiskStore" hint="Constructor">
		<cfargument name="cacheProvider" type="any" required="true" hint="The associated cache provider as coldbox.system.cache.ICacheProvider" colddoc:generic="coldbox.system.cache.ICacheProvider"/>
		<cfscript>
			// Store Fields
			var fields = "hits,timeout,lastAccessTimeout,created,LastAccessed,isExpired,isSimple";
			var config = arguments.cacheProvider.getConfiguration();

			// Prepare instance
			instance = {
				cacheProvider   = arguments.cacheProvider,
				storeID 		= createObject('java','java.lang.System').identityHashCode(this),
				indexer    		= createObject("component","coldbox.system.cache.store.indexers.MetadataIndexer").init(fields),
				converter 		= createObject("component","coldbox.system.core.conversion.ObjectMarshaller").init(),
				fileUtils		= createObject("component","coldbox.system.core.util.FileUtils")
			};

			// Get extra configuration details from cacheProvider's configuration for this diskstore
			// Auto Expand
			if( NOT structKeyExists(config, "autoExpandPath") ){
				config.autoExpandPath = true;
			}

			// Check directory path
			if( NOT structKeyExists(config,"directoryPath") ){
				throw(message="The 'directoryPath' configuration property was not found in the cache configuration",
					  detail="Please check the cache configuration and add the 'directoryPath' property. Current Configuration: #config.toString()#",
					  type="DiskStore.InvalidConfigurationException");
			}

			//AutoExpand
			if( config.autoExpandPath ){
				instance.directoryPath = expandPath( config.directoryPath );
			}
			else{
				instance.directoryPath = config.directoryPath;
			}

			//Check if directory exists else create it
			if( NOT directoryExists(instance.directoryPath) ){
				instance.fileUtils.directoryCreate(path=instance.directoryPath);
			}

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
			instance.fileUtils.directoryRemove(path=instance.directoryPath,recurse=true);
			instance.indexer.clearAll();
			instance.fileUtils.directoryCreate(path=instance.directoryPath);
		</cfscript>
    </cffunction>

	<!--- getIndexer --->
	<cffunction name="getIndexer" access="public" returntype="any" output="false" hint="Get the store's pool metadata indexer structure">
		<cfreturn instance.indexer >
	</cffunction>

	<!--- getKeys --->
	<cffunction name="getKeys" output="false" access="public" returntype="any" hint="Get all the store's object keys">
		<cfreturn instance.indexer.getKeys()>
	</cffunction>

	<!--- lookup --->
	<cffunction name="lookup" access="public" output="false" returntype="any" hint="Check if an object is in cache.">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object">

		<cflock name="DiskStore.#instance.storeID#.#arguments.objectKey#" type="readonly" timeout="10" throwonTimeout="true">
		<cfscript>
			// check if object is missing and in indexer
			if( NOT instance.fileUtils.isFile( getCacheFilePath(arguments.objectKey) ) AND instance.indexer.objectExists( arguments.objectKey ) ){
				instance.indexer.clear( arguments.objectKey );
				return false;
			}

			// Check if object on disk, on indexer and NOT expired
			if( instance.fileUtils.isFile( getCacheFilePath(arguments.objectKey) )
			    AND instance.indexer.objectExists( arguments.objectKey )
				AND NOT instance.indexer.getObjectMetadataProperty(arguments.objectKey,"isExpired") ){
				return true;
			}

			return false;
		</cfscript>
		</cflock>

	</cffunction>

	<!--- get --->
	<cffunction name="get" access="public" output="false" returntype="any" hint="Get an object from cache">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object">

		<cflock name="DiskStore.#instance.storeID#.#arguments.objectKey#" type="exclusive" timeout="10" throwonTimeout="true">
		<cfscript>
			if( lookup(arguments.objectKey) ){
				// Record Metadata Access
				instance.indexer.setObjectMetadataProperty(arguments.objectKey,"hits", instance.indexer.getObjectMetadataProperty(arguments.objectKey,"hits")+1);
				instance.indexer.setObjectMetadataProperty(arguments.objectKey,"LastAccessed", now());

				return getQuiet( arguments.objectKey );
			}
		</cfscript>
		</cflock>

	</cffunction>

	<!--- getQuiet --->
	<cffunction name="getQuiet" access="public" output="false" returntype="any" hint="Get an object from cache with no stats">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object">

		<cfset var thisFilePath = getCacheFilePath(arguments.objectKey)>

		<cflock name="DiskStore.#instance.storeID#.#arguments.objectKey#" type="exclusive" timeout="10" throwonTimeout="true">
		<cfscript>
			if( lookup(arguments.objectKey) ){

				// if simple value, just return it
				if( instance.indexer.getObjectMetadataProperty(arguments.objectKey,"isSimple") ){
					return trim(instance.fileUtils.readFile( thisFilePath ));
				}

				//else we deserialize
				return instance.converter.deserializeObject(filePath=thisFilePath);

			}
		</cfscript>
		</cflock>

	</cffunction>

	<!--- expireObject --->
	<cffunction name="expireObject" output="false" access="public" returntype="void" hint="Mark an object for expiration">
		<cfargument name="objectKey" type="any"  required="true" hint="The object key">

		<cflock name="DiskStore.#instance.storeID#.#arguments.objectKey#" type="exclusive" timeout="10" throwonTimeout="true">
			<cfset instance.indexer.setObjectMetadataProperty(arguments.objectKey,"isExpired", true)>
		</cflock>

	</cffunction>

	<!--- isExpired --->
    <cffunction name="isExpired" output="false" access="public" returntype="any" hint="Test if an object in the store has expired or not">
    	<cfargument name="objectKey" type="any"  required="true" hint="The object key">

		<cflock name="DiskStore.#instance.storeID#.#arguments.objectKey#" type="readonly" timeout="10" throwonTimeout="true">
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
		<cfset var metaData		= {}>
		<cfset var thisFilePath = getCacheFilePath(arguments.objectKey)>

		<!--- set object metadata --->
		<cfset metaData = {
			hits = 1,
			timeout = arguments.timeout,
			lastAccessTimeout = arguments.LastAccessTimeout,
			created = now(),
			LastAccessed = now(),
			isExpired = false,
			isSimple = true
		}>

		<cflock name="DiskStore.#instance.storeID#.#arguments.objectKey#" type="exclusive" timeout="10" throwonTimeout="true">
		<cfscript>
			// If simple value just write it out to disk
			if( isSimpleValue(arguments.object) ){
				instance.fileUtils.saveFile( thisFilePath, trim(arguments.object) );
			}
			else{
				// serialize it
				instance.converter.serializeObject(arguments.object, thisFilePath);
				metaData.isSimple = false;
			}
			// Save the object's metadata
			instance.indexer.setObjectMetadata(arguments.objectKey, metaData);
		</cfscript>
		</cflock>
	</cffunction>

	<!--- Clear an object from the pool --->
	<cffunction name="clear" access="public" output="false" returntype="any" hint="Clears an object from the storage pool">
		<cfargument name="objectKey" 			type="any"  required="true" hint="The object key">

		<cfset var thisFilePath = getCacheFilePath(arguments.objectKey)>

		<cflock name="DiskStore.#instance.storeID#.#arguments.objectKey#" type="exclusive" timeout="10" throwonTimeout="true">
			<cfscript>
			// check it
			if( NOT instance.fileUtils.isFile(thisFilePath) ){
				return false;
			}
			// Remove it
			instance.fileUtils.removeFile( thisFilePath );
			instance.indexer.clear( arguments.objectKey );

			return true;
			</cfscript>
		</cflock>
	</cffunction>

	<!--- Get the size of the pool --->
	<cffunction name="getSize" access="public" output="false" returntype="any" hint="Get the cache's size in items">
		<cfreturn instance.indexer.getSize()>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->

	<!--- getCacheFilePath --->
    <cffunction name="getCacheFilePath" output="false" access="private" returntype="any" hint="Get the cached file path">
    	<cfargument name="objectKey" type="any" required="true" hint="The key of the object">
		<cfscript>
			return instance.directoryPath & "/" & hash(arguments.objectKey) & ".cachebox";
		</cfscript>
    </cffunction>

	<!--- Get ColdBox Util --->
	<cffunction name="getUtil" access="private" output="false" returntype="any" hint="Create and return a util object">
		<cfreturn createObject("component","coldbox.system.core.util.Util")/>
	</cffunction>

</cfcomponent>