<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Author 	    :	Luis Majano
Description :
	I am a cool cool JDBC Store for CacheBox
	
You need to create the table first with the following columns

id 			- varchar(100)
objectKey 	- varchar(255)
objectValue	- blob

MYSQL Script
CREATE TABLE `cacheBox` (
  `id` varchar(100) NOT NULL DEFAULT '',
  `objectKey` varchar(255) NOT NULL,
  `objectValue` longtext NOT NULL,
  `createDate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

MSSQL

----------------------------------------------------------------------->
<cfcomponent hint="I am a cool cool JDBC Store for CacheBox" output="false" implements="coldbox.system.cache.store.IObjectStore">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<!--- init --->
	<cffunction name="init" access="public" output="false" returntype="JDBCStore" hint="Constructor">
		<cfargument name="cacheProvider" type="any" required="true" hint="The associated cache provider as coldbox.system.cache.ICacheProvider" colddoc:generic="coldbox.system.cache.ICacheProvider"/>
		<cfscript>
			// Store Fields
			var fields = "hits,timeout,lastAccessTimeout,created,lastAccesed,isExpired,isSimple";
			var config = arguments.cacheProvider.getConfiguration();
			
			// Prepare instance
			instance = {
				storeID 		= createObject('java','java.lang.System').identityHashCode(this),
				cacheProvider   = arguments.cacheProvider,
				indexer    		= createObject("component","coldbox.system.cache.util.MetadataIndexer").init(fields),
				converter 		= createObject("component","coldbox.system.core.conversion.ObjectMarshaller").init()
			};
			
			// Get Extra config data
			instance.dsn 	= config.dsn;
			instance.table	= config.table;
			
			// Check credentials
			if( NOT structKeyExists(config, "dsnUsername") ){
				config.dsnUsername = "";
			}
			if( NOT structKeyExists(config, "dsnPassword") ){
				config.dsnPassword = "";
			}
			instance.dsnUsername = config.dsnUsername;
			instance.dsnPassword = config.dsnPassword;
			
			// Check autoCreate
			if( NOT structKeyExists(config, "tableAutoCreate") ){
				config.tableAutoCreate = true;
			}
			instance.tableAutoCreate = config.tableAutoCreate;
			
			// Check column type, use for autoCreate, defaults to longtext
			if( NOT structKeyExists(config,"textDBType") ){
				instance.textDBType = "longtext";
			}
			
			// ensure the table
			if( config.tableAutoCreate ){
				ensureTable();
			}
			
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
		<cfset var q = "">
		
		<cfquery name="q" datasource="#instance.dsn#" username="#instance.dsnUsername#" password="#instance.dsnPassword#">
		TRUNCATE TABLE #instance.table#
		</cfquery>
		
		<cfset instance.indexer.clearAll()>
		
    </cffunction>

	<!--- getIndexer --->
	<cffunction name="getIndexer" access="public" returntype="coldbox.system.cache.util.MetadataIndexer" output="false" hint="Get the store's pool metadata indexer structure">
		<cfreturn instance.indexer >
	</cffunction>
	
	<!--- getKeys --->
	<cffunction name="getKeys" output="false" access="public" returntype="array" hint="Get all the store's object keys">
		<cfreturn instance.indexer.getKeys()>
	</cffunction>
	
	<!--- lookup --->
	<cffunction name="lookup" access="public" output="false" returntype="boolean" hint="Check if an object is in cache.">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object">
		
		<cfset var normalizedID = getNormalizedID(arguments.objectKey)>
		<cfset var q = "">
		
		<cfquery name="q" datasource="#instance.dsn#" username="#instance.dsnUsername#" password="#instance.dsnPassword#">
		SELECT id
		  FROM #instance.table#
		 WHERE id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#normalizedID#">
		</cfquery>
		
		<cfscript>
			// Check if object in pool
			if( q.recordCount
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
			
			return getQuiet( arguments.objectKey );
		</cfscript>
	</cffunction>
	
	<!--- getQuiet --->
	<cffunction name="getQuiet" access="public" output="false" returntype="any" hint="Get an object from cache with no stats">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object">
		
		<cfset var q = "">
		<cfset var normalizedID = getNormalizedID(arguments.objectKey)>
		
		<cfquery name="q" datasource="#instance.dsn#" username="#instance.dsnUsername#" password="#instance.dsnPassword#">
		SELECT *
		  FROM #instance.table#
		 WHERE id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#normalizedID#">
		</cfquery>
		
		<cfscript>
			// if simple value, just return it
			if( instance.indexer.getObjectMetadataProperty(arguments.objectKey,"isSimple") ){
				return q.objectValue;
			}
			
			//else we return deserialized
			return instance.converter.deserializeObject(binaryObject=q.objectValue);
		</cfscript>
		
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
		<cfset var metaData		= {}>
		<cfset var q 			= "">
		<cfset var normalizedID = getNormalizedID(arguments.objectKey)>
		<cfset var normalizedValue = "">
		
		<!--- set object metadata --->
		<cfset metaData = {
			hits = 1,
			timeout = arguments.timeout,
			lastAccessTimeout = arguments.LastAccessTimeout,
			created = now(),
			lastAccesed = now(),		
			isExpired = false,
			isSimple = true
		}>
		
		<!--- Test if simple --->
		<cfif isSimpleValue(arguments.object) >
			<cfset normalizedValue = arguments.object>
		<cfelse>
			<!---serialize it--->
			<cfset normalizedValue = instance.converter.serializeObject(arguments.object)>
			<cfset metaData.isSimple = false>
		</cfif>
		
		<!--- Check if ID exists --->
		<cfif NOT instance.indexer.objectExists( arguments.objectKey )>
			
			<!--- store it --->	
			<cfquery name="q" datasource="#instance.dsn#" username="#instance.dsnUsername#" password="#instance.dsnPassword#">
			INSERT INTO #instance.table# (id,objectKey,objectValue,createDate)
			     VALUES (
				 	<cfqueryparam cfsqltype="cf_sql_varchar" value="#normalizedID#">,
				 	<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.objectKey#">,
				 	<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#normalizedValue#">,
				 	<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
				 )
			</cfquery>
			
		<cfelse>
		
			<!--- Update it --->	
			<cfquery name="q" datasource="#instance.dsn#" username="#instance.dsnUsername#" password="#instance.dsnPassword#">
			UPDATE #instance.table# 
			   SET objectValue = <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#normalizedValue#">,
				   createDate  = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
			  WHERE id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#normalizedID#">
			</cfquery>
		
		</cfif>
		
		<!--- Save Metadata --->
		<cfset instance.indexer.setObjectMetadata(arguments.objectKey, metaData)>
	</cffunction>

	<!--- Clear an object from the pool --->
	<cffunction name="clear" access="public" output="false" returntype="boolean" hint="Clears an object from the storage pool">
		<cfargument name="objectKey" 			type="any"  required="true" hint="The object key">
		
		<cfset var normalizedID = getNormalizedID(arguments.objectKey)>
		<cfset var q = "">
		
		<cfif NOT instance.indexer.objectExists( arguments.objectKey )>
			<cfreturn false>
		</cfif>
		
		<!--- clear it --->	
		<cfquery name="q" datasource="#instance.dsn#" username="#instance.dsnUsername#" password="#instance.dsnPassword#">
		DELETE 
		  FROM #instance.table#
		 WHERE id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#normalizedID#">
		</cfquery>
		
		<!--- Clean MD --->
		<cfset instance.indexer.clear( arguments.objectKey )>
		
		<cfreturn true>		
	</cffunction>

	<!--- Get the size of the pool --->
	<cffunction name="getSize" access="public" output="false" returntype="numeric" hint="Get the cache's size in items">
		<cfreturn instance.indexer.getSize()>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->

	<!--- getNormalizedID --->
    <cffunction name="getNormalizedID" output="false" access="private" returntype="any" hint="Get the cached normalized id">
    	<cfargument name="objectKey" type="any" required="true" hint="The key of the object">
		<cfscript>
			return hash(arguments.objectKey & instance.storeID);
		</cfscript>
    </cffunction>
	
	<!--- Get ColdBox Util --->
	<cffunction name="getUtil" access="private" output="false" returntype="coldbox.system.core.util.Util" hint="Create and return a util object">
		<cfreturn createObject("component","coldbox.system.core.util.Util")/>
	</cffunction>

	<!--- ensureTable --->
	<cffunction name="ensureTable" output="false" access="private" returntype="void" hint="Verify or create the caching table">
		<cfset var dsn 			= instance.dsn>
		<cfset var qTables 		= 0>
		<cfset var tableFound 	= false>
		<cfset var qCreate 		= "">
		
		<!--- Get Tables on this DSN --->
		<cfdbinfo datasource="#instance.dsn#" name="qTables" type="tables" />

		<!--- Verify it exists --->
		<cfloop query="qTables">
			<cfif qTables.table_name eq instance.table>
				<cfset tableFound = true>
				<cfbreak>
			</cfif>
		</cfloop>
		
		<!--- AutoCreate Table? --->
		<cfif NOT tableFound>
			<!--- Try to Create Table  --->
			<cfquery name="qCreate" datasource="#dsn#">
				CREATE TABLE #instance.table# (
					id VARCHAR(100) NOT NULL,
					objectKey VARCHAR(255) NOT NULL,
					objectValue #instance.textDBType# NOT NULL,
					createDate DATETIME NOT NULL
					PRIMARY KEY (id)
				)
			</cfquery>
		</cfif>
	</cffunction>

</cfcomponent>