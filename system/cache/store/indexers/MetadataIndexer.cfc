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
<cfcomponent output="false" hint="This is a utility object that helps object stores keep their items indexed and pretty">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	
	<cffunction name="init" access="public" output="false" returntype="MetadataIndexer" hint="Constructor">
		<cfargument name="fields" required="true" hint="The list or array of fields to bind this index on"/>
		<cfscript>
			instance = {
				// Create metadata pool
				poolMetadata = CreateObject("java","java.util.concurrent.ConcurrentHashMap").init(),
				// Index ID
				indexID = createObject('java','java.lang.System').identityHashCode(this)
			};
			
			// Store Fields
			setFields( arguments.fields );
			
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

	
	<!--- getPoolMetadata --->
    <cffunction name="getPoolMetadata" output="false" access="public" returntype="any" hint="Get the entire pool reference">
    	<cfreturn instance.poolMetadata>
    </cffunction>
	
	<!--- clearAll --->
    <cffunction name="clearAll" output="false" access="public" returntype="void" hint="Clear the entire metadata map">
    	<cfset instance.poolMetadata.clear()>
    </cffunction>
	
	<!--- clear --->
    <cffunction name="clear" output="false" access="public" returntype="void" hint="Clear a metadata key">
    	<cfargument name="objectKey" type="any" required="true" hint="The key of the object">
		<cfset structDelete( instance.poolMetadata, arguments.objectKey )>
    </cffunction>
	
	<!--- getKeys --->
    <cffunction name="getKeys" output="false" access="public" returntype="any" hint="Returns an array of the keys stored in the index" colddoc:generic="array">
    	<cfreturn structKeyArray( getPoolMetadata() )>
    </cffunction>

	<!--- getObjectMetadata --->
	<cffunction name="getObjectMetadata" access="public" returntype="any" output="false" hint="Get a metadata entry for a specific entry. Exception if key not found">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object">
		<cfreturn instance.poolMetadata[ arguments.objectKey ]>
	</cffunction>
	
	<!--- setObjectMetadata --->
	<cffunction name="setObjectMetadata" access="public" returntype="void" output="false" hint="Set the metadata entry for a specific entry">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object">
		<cfargument name="metadata"  type="any" required="true" hint="The metadata structure to store for the cache entry">
		<cfset instance.poolMetadata[ arguments.objectKey ] = arguments.metadata>
	</cffunction>
	
	<!--- objectExists --->
    <cffunction name="objectExists" output="false" access="public" returntype="any" hint="Check if the metadata entry exists for an object">
    	<cfargument name="objectKey" type="any" required="true" hint="The key of the object">
		<cfreturn structKeyExists( instance.poolMetadata, arguments.objectKey )>
    </cffunction>
	
	<!--- getObjectMetadataProperty --->
	<cffunction name="getObjectMetadataProperty" access="public" returntype="any" output="false" hint="Get a specific metadata property for a specific entry">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object">
		<cfargument name="property"  type="any" required="true" hint="The property of the metadata to retrieve, must exist in the binded fields or exception is thrown">
		
		<cfset validateField( arguments.property )>
		<cfreturn instance.poolMetadata[ arguments.objectKey ][ arguments.property ] >
	</cffunction>
	
	<!--- setObjectMetadataProperty --->
	<cffunction name="setObjectMetadataProperty" access="public" returntype="void" output="false" hint="Set a metadata property for a specific entry">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object">
		<cfargument name="property"  type="any" required="true" hint="The property of the metadata to retrieve">
		<cfargument name="value"  	 type="any" required="true" hint="The value of the property">
		
		<cfset validateField( arguments.property )>
		<cfset instance.poolMetadata[ arguments.objectKey ][ arguments.property ] = arguments.value >
		
	</cffunction>
	
	<!--- getSize --->
    <cffunction name="getSize" output="false" access="public" returntype="any" hint="Get the size of the indexer">
    	<cfreturn structCount( instance.poolMetadata )>
    </cffunction>
	
	<!--- getSortedKeys --->
    <cffunction name="getSortedKeys" output="false" access="public" returntype="any" hint="Get an array of sorted keys for this indexer according to parameters">
    	<cfargument name="property"  type="any" required="true" hint="The property field to sort the index on. It must exist in the binded fields or exception"/>
		<cfargument name="sortType"  type="any" required="false" default="text" hint="The sort ordering: numeric, text or textnocase"/>
		<cfargument name="sortOrder" type="any" required="false" default="asc" hint="The sort order: asc or desc"/>
		<cfscript>
			validateField( arguments.property );
			
			return structSort( instance.poolMetadata, arguments.sortType, arguments.sortOrder, arguments.property );
		</cfscript>
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