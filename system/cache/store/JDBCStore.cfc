<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************
Author 	    :	Luis Majano
Description :
	I am a cool cool JDBC Store for CacheBox

You need to create the table first with the following columns

id 					- varchar(100) PK
objectKey 			- varchar(255)
objectValue			- clob, longtext, etc
hits				- integer
timeout				- integer
lastAccessTimeout 	- integer
created				- datetime or timestamp
lastAccessed		- datetime or timestamp
isExpired			- tinyint or boolean
isSimple			- tinyint or boolean

We also recommend indexes for: hits, created, lastAccessed, timeout and isExpired columns.

Or look in the /coldbox/system/cache/store/sql/*.sql for you sql script for your DB.
----------------------------------------------------------------------->
<cfcomponent hint="I am a cool cool JDBC Store for CacheBox" output="false" implements="coldbox.system.cache.store.IObjectStore">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<!--- init --->
	<cffunction name="init" access="public" output="false" returntype="JDBCStore" hint="Constructor">
		<cfargument name="cacheProvider" type="any" required="true" hint="The associated cache provider as coldbox.system.cache.ICacheProvider" colddoc:generic="coldbox.system.cache.ICacheProvider"/>
		<cfscript>
			// Store Fields
			var fields = "objectKey,hits,timeout,lastAccessTimeout,created,lastAccessed,isExpired,isSimple";
			var config = arguments.cacheProvider.getConfiguration();

			// Prepare instance
			instance = {
				storeID 		= createObject('java','java.lang.System').identityHashCode( this ),
				cacheProvider   = arguments.cacheProvider,
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

			// ensure the table
			if( config.tableAutoCreate ){
				ensureTable();
			}

			// Indexer
			instance.indexer = createObject("component","coldbox.system.cache.store.indexers.JDBCMetadataIndexer").init(fields, config, this);

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
		<cfset var q = "">

		<cfquery name="q" datasource="#instance.dsn#" username="#instance.dsnUsername#" password="#instance.dsnPassword#">
		TRUNCATE TABLE #instance.table#
		</cfquery>

    </cffunction>

	<!--- getIndexer --->
	<cffunction name="getIndexer" access="public" returntype="any" output="false" hint="Get the store's pool metadata indexer structure">
		<cfreturn instance.indexer >
	</cffunction>

	<!--- getKeys --->
	<cffunction name="getKeys" output="false" access="public" returntype="any" hint="Get all the store's object keys">
		<cfset var q = "">

		<cfquery name="q" datasource="#instance.dsn#" username="#instance.dsnUsername#" password="#instance.dsnPassword#">
		SELECT objectKey
		  FROM #instance.table#
		ORDER BY objectKey ASC
		</cfquery>

		<cfreturn listToArray( valueList( q.objectKey ) )>
	</cffunction>

	<!--- lookupQuery --->
    <cffunction name="lookupQuery" output="false" access="private" returntype="any" hint="Get the lookup query">
    	<cfargument name="objectKey" type="any" required="true" hint="The key of the object">

		<cfset var normalizedID 	= getNormalizedID( arguments.objectKey )>
		<cfset var q 				= "">

		<!--- db lookup --->
		<cfquery name="q" datasource="#instance.dsn#" username="#instance.dsnUsername#" password="#instance.dsnPassword#">
		SELECT id, isExpired
		  FROM #instance.table#
		 WHERE id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#normalizedID#">
		</cfquery>

		<cfreturn q>
    </cffunction>


	<!--- lookup --->
	<cffunction name="lookup" access="public" output="false" returntype="any" hint="Check if an object is in cache.">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object">
		<cfscript>
			var q = lookupQuery( arguments.objectKey );

			// Check if object in pool
			if( q.recordCount AND NOT q.isExpired){
				return true;
			}

			return false;
		</cfscript>
	</cffunction>

	<!--- get --->
	<cffunction name="get" access="public" output="false" returntype="any" hint="Get an object from cache">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object">

		<cfset var q 			= "">
		<cfset var qStats		= "">
		<cfset var normalizedID = getNormalizedID( arguments.objectKey )>
		<cfset var refLocal = {}>
		
		<cftransaction>
			<!--- select entry --->
			<cfquery name="q" datasource="#instance.dsn#" username="#instance.dsnUsername#" password="#instance.dsnPassword#">
			SELECT *
			  FROM #instance.table#
			 WHERE id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#normalizedID#">
			</cfquery>

			<!--- Update Stats If Found --->
			<cfif q.recordcount>
				<cfquery name="qStats" datasource="#instance.dsn#" username="#instance.dsnUsername#" password="#instance.dsnPassword#">
				UPDATE #instance.table#
				   SET lastAccessed = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
					    hits  = hits + 1
				  WHERE id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#normalizedID#">
				</cfquery>
			</cfif>
		</cftransaction>

		<!--- Object Check --->
		<cfscript>
			// Just return if records found, else null
			if( q.recordCount ){

				// if simple value, just return it
				if( q.isSimple ){
					return q.objectValue;
				}

				//else we return deserialized
				return instance.converter.deserializeObject(binaryObject=q.objectValue);
			}
		</cfscript>
	</cffunction>

	<!--- getQuiet --->
	<cffunction name="getQuiet" access="public" output="false" returntype="any" hint="Get an object from cache with no stats">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object">

		<cfset var q 				= "">
		<cfset var normalizedID 	= getNormalizedID( arguments.objectKey )>

		<!--- select entry --->
		<cfquery name="q" datasource="#instance.dsn#" username="#instance.dsnUsername#" password="#instance.dsnPassword#">
		SELECT *
		  FROM #instance.table#
		 WHERE id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#normalizedID#">
		</cfquery>

		<cfscript>
			// Just return if records found, else null
			if( q.recordCount ){

				// if simple value, just return it
				if( q.isSimple ){
					return q.objectValue;
				}

				//else we return deserialized
				return instance.converter.deserializeObject(binaryObject=q.objectValue);
			}
		</cfscript>
	</cffunction>

	<!--- expireObject --->
	<cffunction name="expireObject" output="false" access="public" returntype="void" hint="Mark an object for expiration">
		<cfargument name="objectKey" type="any"  required="true" hint="The object key">

		<cfset var q 				= "">
		<cfset var normalizedID 	= getNormalizedID( arguments.objectKey )>

		<cfquery name="q" datasource="#instance.dsn#" username="#instance.dsnUsername#" password="#instance.dsnPassword#">
		UPDATE #instance.table#
		   SET isExpired = <cfqueryparam cfsqltype="cf_sql_bit" value="1">
		  WHERE id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#normalizedID#">
		</cfquery>

	</cffunction>

	<!--- isExpired --->
    <cffunction name="isExpired" output="false" access="public" returntype="any" hint="Test if an object in the store has expired or not, returns false if object not found">
    	<cfargument name="objectKey" type="any"  required="true" hint="The object key">

		<cfset var normalizedID 	= getNormalizedID( arguments.objectKey )>
		<cfset var q 				= "">

		<!--- db lookup --->
		<cfquery name="q" datasource="#instance.dsn#" username="#instance.dsnUsername#" password="#instance.dsnPassword#">
		SELECT isExpired
		  FROM #instance.table#
		 WHERE id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#normalizedID#">
		</cfquery>

		<!--- Check if expired --->
		<cfif q.recordcount>
			<cfreturn q.isExpired>
		</cfif>

		<cfreturn false>
    </cffunction>

	<!--- Set an Object in the pool --->
	<cffunction name="set" access="public" output="false" returntype="void" hint="sets an object in the storage.">
		<!--- ************************************************************* --->
		<cfargument name="objectKey" 			type="any"  required="true" hint="The object key">
		<cfargument name="object"				type="any" 	required="true" hint="The object to save">
		<cfargument name="timeout"				type="any"  required="false" default="0" hint="Timeout in minutes">
		<cfargument name="lastAccessTimeout"	type="any"  required="false" default="0" hint="Timeout in minutes">
		<cfargument name="extras" 				type="any" default="#structnew()#" hint="A map of extra name-value pairs"/>
		<!--- ************************************************************* --->
		<cfset var q 				= "">
		<cfset var normalizedID 	= getNormalizedID( arguments.objectKey )>
		<cfset var isSimple			= true>

		<!--- Test if simple --->
		<cfif NOT isSimpleValue(arguments.object) >
			<!---serialize it--->
			<cfset arguments.object = instance.converter.serializeObject( arguments.object )>
			<cfset isSimple = false>
		</cfif>

		<!--- Check if already in DB or not --->
		<cftransaction>
			<cfif NOT lookupQuery( arguments.objectKey ).recordcount>
				<!--- store it --->
				<cfquery name="q" datasource="#instance.dsn#" username="#instance.dsnUsername#" password="#instance.dsnPassword#">
				INSERT INTO #instance.table# (id,objectKey,objectValue,hits,timeout,lastAccessTimeout,created,lastAccessed,isExpired,isSimple)
				     VALUES (
					 	<cfqueryparam cfsqltype="cf_sql_varchar" value="#normalizedID#">,
					 	<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.objectKey#">,
					 	<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#arguments.object#">,
					 	<cfqueryparam cfsqltype="cf_sql_integer" value="1">,
						<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.timeout#">,
						<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.lastAccessTimeout#">,
						<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
						<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
						<cfqueryparam cfsqltype="cf_sql_bit" value="0">,
						<cfqueryparam cfsqltype="cf_sql_bit" value="#isSimple#">
					 )
				</cfquery>
				<!--- Just go back --->
				<cfreturn>
			</cfif>

			<!--- Update it --->
			<cfquery name="q" datasource="#instance.dsn#" username="#instance.dsnUsername#" password="#instance.dsnPassword#">
			UPDATE #instance.table#
			   SET  objectKey 			= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.objectKey#">,
				 	objectValue			= <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#arguments.object#">,
				 	hits				= <cfqueryparam cfsqltype="cf_sql_integer" value="1">,
					timeout				= <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.timeout#">,
					lastAccessTimeout	= <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.lastAccessTimeout#">,
					created				= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
					lastAccessed		= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
					isExpired			= <cfqueryparam cfsqltype="cf_sql_bit" value="0">,
					isSimple			= <cfqueryparam cfsqltype="cf_sql_bit" value="#isSimple#">
			  WHERE id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#normalizedID#">
			</cfquery>

		</cftransaction>
	</cffunction>

	<!--- Clear an object from the pool --->
	<cffunction name="clear" access="public" output="false" returntype="any" hint="Clears an object from the storage pool">
		<cfargument name="objectKey" 			type="any"  required="true" hint="The object key">

		<cfset var normalizedID = getNormalizedID( arguments.objectKey )>
		<cfset var q = "">

		<!--- check if it exists --->
		<cfif NOT lookupQuery( arguments.objectKey ).recordcount>
			<cfreturn false>
		</cfif>

		<!--- clear it --->
		<cfquery name="q" datasource="#instance.dsn#" username="#instance.dsnUsername#" password="#instance.dsnPassword#">
		DELETE
		  FROM #instance.table#
		 WHERE id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#normalizedID#">
		</cfquery>

		<cfreturn true>
	</cffunction>

	<!--- Get the size of the pool --->
	<cffunction name="getSize" access="public" output="false" returntype="any" hint="Get the cache's size in items">
		<cfset var q = "">

		<!--- db lookup --->
		<cfquery name="q" datasource="#instance.dsn#" username="#instance.dsnUsername#" password="#instance.dsnPassword#">
		SELECT count(id) as totalCount
		  FROM #instance.table#
		</cfquery>

		<cfreturn q.totalCount>
	</cffunction>

	<!--- getNormalizedID --->
    <cffunction name="getNormalizedID" output="false" access="public" returntype="any" hint="Get the cached normalized id">
    	<cfargument name="objectKey" type="any" required="true" hint="The key of the object">
		<cfscript>
			return hash( arguments.objectKey );
		</cfscript>
    </cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->

	<!--- Get ColdBox Util --->
	<cffunction name="getUtil" access="private" output="false" returntype="any" hint="Create and return a util object">
		<cfreturn createObject("component","coldbox.system.core.util.Util")/>
	</cffunction>

	<!--- ensureTable --->
	<cffunction name="ensureTable" output="false" access="private" returntype="void" hint="Create the caching table if necessary">
		<cfset var qTables 		= 0>
		<cfset var qCreate 		= "">
		<cfset var qDBInfo		= "">
		<cfset var tableFound 	= false>
		<cfset var create		= {}>

		<!--- Get DB Info --->
		<cfdbinfo datasource="#instance.dsn#" name="qDBInfo" type="version" />

		<!--- Get Tables on this DSN --->
		<cfdbinfo datasource="#instance.dsn#" name="qTables" type="tables" />

		<!--- Choose Text Type --->
		<cfset create.afterCreate 	= "">
		<cfset create.afterLastProperty = "">
		<cfswitch expression="#qDBInfo.database_productName#">
			<cfcase value="PostgreSQL">
				<cfset create.valueType		= "text">
				<cfset create.timeType 		= "timestamp">
				<cfset create.intType 		= "integer">
				<cfset create.booleanType	= "boolean">
			</cfcase>
			<cfcase value="MySQL">
				<cfset create.valueType   = "longtext">
				<cfset create.afterCreate = "ENGINE=InnoDB DEFAULT CHARSET=utf8">
				<cfset create.timeType 	  = "datetime">
				<cfset create.intType 	  = "int">
				<cfset create.booleanType = "tinyint">
				<cfset create.afterLastProperty = "INDEX `hits` (`hits`),INDEX `created` (`created`),INDEX `lastAccessed` (`lastAccessed`),INDEX `timeout` (`timeout`),INDEX `isExpired` (`isExpired`)">
			</cfcase>
			<cfcase value="Microsoft SQL Server">
				<cfset create.valueType 	= "ntext">
				<cfset create.timeType  	= "datetime">
				<cfset create.intType 		= "int">
				<cfset create.booleanType 	= "tinyint">
			</cfcase>
			<cfcase value="Oracle">
				<cfset create.valueType 	= "clob">
				<cfset create.timeType 		= "timestamp">
				<cfset create.intType 		= "int">
				<cfset create.booleanType 	= "boolean">
			</cfcase>
			<cfdefaultcase>
				<cfset create.valueType 	= "text">
				<cfset create.timeType 		= "timestamp">
				<cfset create.intType 		= "integer">
				<cfset create.booleanType 	= "tinyint">
			</cfdefaultcase>
		</cfswitch>

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
			<cfquery name="qCreate" datasource="#instance.dsn#" username="#instance.dsnUsername#" password="#instance.dsnPassword#">
				CREATE TABLE #instance.table# (
					id VARCHAR(100) NOT NULL,
					objectKey VARCHAR(255) NOT NULL,
					objectValue #create.valueType# NOT NULL,
					hits #create.intType# NOT NULL DEFAULT '1',
					timeout #create.intType# NOT NULL,
					lastAccessTimeout integer NOT NULL,
					created #create.timeType# NOT NULL,
					lastAccessed #create.timeType# NOT NULL,
					isExpired #create.booleanType# NOT NULL DEFAULT '1',
					isSimple #create.booleanType# NOT NULL DEFAULT '0',
					PRIMARY KEY (id)
				) #create.afterCreate#
			</cfquery>
		</cfif>
	</cffunction>

</cfcomponent>