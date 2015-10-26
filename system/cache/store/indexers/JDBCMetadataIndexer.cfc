<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	11/14/2007
Description :
	This is a utility object that helps object stores keep their elements indexed
	and stored nicely.  It is also a nice way to give back metadata results.
	
----------------------------------------------------------------------->
<cfcomponent output="false" 
			 hint="This is a utility object that helps object stores keep their items indexed and pretty"
			 extends="coldbox.system.cache.store.indexers.MetadataIndexer">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	
	<cffunction name="init" access="public" output="false" returntype="JDBCMetadataIndexer" hint="Constructor">
		<cfargument name="fields" 	required="true" hint="The list or array of fields to bind this index on"/>
		<cfargument name="config" 	required="true" hint="JDBC Configuration structure"/>
		<cfargument name="store" 	required="true" hint="The associated storage"/>
		
		<cfset var DBData = "">
		<cfdbinfo type="version" datasource="#arguments.config.dsn#" name="DBData">
		
		<cfscript>
			super.init(arguments.fields);
			
			// store db sql compatibility type
			instance.sqlType = "MySQL";
			if( findNoCase("Microsoft SQL", DBData.database_productName) ){
				instance.sqlType = "MSSQL";
			} 
			
			// store jdbc configuration
			instance.config = arguments.config;
			
			// store storage reference
			instance.store = arguments.store;
			
			return this;
		</cfscript>
	</cffunction>
	
<!------------------------------------------- PUBLIC ------------------------------------------->
	
	<!--- getFields --->
	<cffunction name="getFields" access="public" returntype="any" output="false" hint="Get the bounded fields list">
    	<cfreturn instance.fields>
    </cffunction>
	
	<!--- setFields --->
    <cffunction name="setFields" output="false" access="public" returntype="void" hint="Override the constructed metadata fields this index is binded to">
    	<cfargument name="fields" type="any" required="true" hint="The list or array of fields to bind this index on"/>
		<cfscript>
			// Normalize fields
			if( isArray(arguments.fields) ){
				arguments.fields = arrayToList( arguments.fields );
			}
			
			// Store fields
			instance.fields = arguments.fields;
		</cfscript>
    </cffunction>

	<!--- objectExists --->
    <cffunction name="objectExists" output="false" access="public" returntype="any" hint="Check if the metadata entry exists for an object">
    	<cfargument name="objectKey" type="any" required="true" hint="The key of the object">
		
		<cfset var q 				= "">
		<cfset var normalizedID 	= instance.store.getNormalizedID(arguments.objectKey)>
		
		<!--- select entry --->
		<cfquery name="q" datasource="#instance.config.dsn#" username="#instance.config.dsnUsername#" password="#instance.config.dsnPassword#">
		SELECT id
		  FROM #instance.config.table#
		 WHERE id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#normalizedID#"> 
		</cfquery>
		
		<cfreturn (q.recordcount EQ 1)>
	</cffunction>
	
	<!--- getPoolMetadata --->
    <cffunction name="getPoolMetadata" output="false" access="public" returntype="any" hint="Get the entire pool reference">
    	<cfset var q = "">
		<cfset var x = "">
		<cfset var md = structnew()>
		
		<!--- select entry --->
		<cfquery name="q" datasource="#instance.config.dsn#" username="#instance.config.dsnUsername#" password="#instance.config.dsnPassword#">
		SELECT <cfif instance.sqlType eq "MSSQL">TOP 100 </cfif>#instance.fields#
		  FROM #instance.config.table#
		ORDER BY objectKey
		<cfif instance.sqlType eq "MySQL">LIMIT 100 </cfif>
		</cfquery>
		
		<cfloop from="1" to="#q.recordcount#" index="x" >
			<cfset md[ q.objectKey[x] ] = {
				hits = q.hits[x],
				timeout = q.timeout[x],
				lastAccessTimeout = q.lastAccessTimeout[x],
				created = q.created[x],
				LastAccessed = q.lastAccessed[x],
				isExpired = q.isExpired[x]
			}>
		</cfloop>
		
		<cfreturn md>
    </cffunction>
	
	<!--- getObjectMetadata --->
	<cffunction name="getObjectMetadata" access="public" returntype="any" output="false" hint="Get a metadata entry for a specific entry. Exception if key not found">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object">
		
		<cfset var q 				= "">
		<cfset var normalizedID 	= instance.store.getNormalizedID(arguments.objectKey)>
		<cfset var target			= {}>
		<cfset var thisField		= "">
		
		<!--- select entry --->
		<cfquery name="q" datasource="#instance.config.dsn#" username="#instance.config.dsnUsername#" password="#instance.config.dsnPassword#">
		SELECT #instance.fields#
		  FROM #instance.config.table#
		 WHERE id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#normalizedID#"> 
		</cfquery>
		
		<cfloop list="#instance.fields#" index="thisField">
			<cfset target[thisField] = q[thisField][1]>
		</cfloop>
		
		<cfreturn target>
	</cffunction>
	
	<!--- getObjectMetadataProperty --->
	<cffunction name="getObjectMetadataProperty" access="public" returntype="any" output="false" hint="Get a specific metadata property for a specific entry">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object">
		<cfargument name="property"  type="any" required="true" hint="The property of the metadata to retrieve, must exist in the binded fields or exception is thrown">
		<cfset var q 				= "">
		<cfset var normalizedID 	= instance.store.getNormalizedID(arguments.objectKey)>
		
		<cfset validateField( arguments.property )>
		
		<!--- select entry --->
		<cfquery name="q" datasource="#instance.config.dsn#" username="#instance.config.dsnUsername#" password="#instance.config.dsnPassword#">
		SELECT #arguments.property# as prop
		  FROM #instance.config.table#
		 WHERE id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#normalizedID#"> 
		</cfquery>
		
		<cfreturn q.prop>		
	</cffunction>
	
	<!--- getSize --->
    <cffunction name="getSize" output="false" access="public" returntype="any" hint="Get the size of the elements indexed">
    	<cfreturn instance.store.getSize()>
    </cffunction>
	
	<!--- getSortedKeys --->
    <cffunction name="getSortedKeys" output="false" access="public" returntype="any" hint="Get an array of sorted keys for this indexer according to parameters">
    	<cfargument name="property"  type="any" required="true" hint="The property field to sort the index on. It must exist in the binded fields or exception"/>
		<cfargument name="sortType"  type="any" required="false" default="text" hint="The sort ordering: numeric, text or textnocase"/>
		<cfargument name="sortOrder" type="any" required="false" default="asc" hint="The sort order: asc or desc"/>
		
		<cfset var q = "">
		
		<!--- select entry --->
		<cfquery name="q" datasource="#instance.config.dsn#" username="#instance.config.dsnUsername#" password="#instance.config.dsnPassword#">
		SELECT id, objectKey
		  FROM #instance.config.table#
		ORDER BY #arguments.property# #arguments.sortOrder#
		</cfquery>
		
		<cfreturn listToArray( valueList(q.objectKey) )>
    </cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------>


	<!--- validateField --->
    <cffunction name="validateField" output="false" access="private" returntype="void" hint="Validate or thrown an exception on an invalid field">
    	<cfargument name="target" type="any" required="true" hint="The target field to validate"/>
		<cfif NOT listFindNoCase(instance.fields, arguments.target)>
			<cfthrow message="Invalid index field property"
					 detail="The property sent: #arguments.target# is not valid. Valid fields are #instance.fields#"
					 type="MetadataIndexer.InvalidFieldException" >
		</cfif>
    </cffunction>

</cfcomponent>