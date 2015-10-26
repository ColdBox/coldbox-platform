<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	The main interface for CacheBox object storages.
	A store is a physical counterpart to a cache, in which objects are kept, indexed and monitored.

----------------------------------------------------------------------->
<cfinterface hint="The main interface for CacheBox object storages.">

	<!--- flush --->
    <cffunction name="flush" output="false" access="public" returntype="void" hint="Flush the store to a permanent storage">
    </cffunction>
	
	<!--- reap --->
    <cffunction name="reap" output="false" access="public" returntype="void" hint="Reap the storage, clean it from old stuff">
    </cffunction>
	
	<!--- clearAll --->
    <cffunction name="clearAll" output="false" access="public" returntype="void" hint="Clear all elements of the store">
    </cffunction>
	
	<!--- getIndexer --->
	<cffunction name="getIndexer" access="public" returntype="any" output="false" hint="Get the store's pool metadata indexer structure" colddoc:generic="coldbox.system.cache.store.indexers.MetadataIndexer">
	</cffunction>
	
	<!--- getKeys --->
	<cffunction name="getKeys" output="false" access="public" returntype="any" hint="Get all the store's object keys array" colddoc:generic="Array">
	</cffunction>
	
	<!--- lookup --->
	<cffunction name="lookup" access="public" output="false" returntype="any" hint="Check if an object is in the store">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object">
	</cffunction>
	
	<!--- get --->
	<cffunction name="get" access="public" output="false" returntype="any" hint="Get an object from the store">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object">
	</cffunction>
	
	<!--- getQuiet --->
	<cffunction name="getQuiet" access="public" output="false" returntype="any" hint="Get an object from the store with no stat updates">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object">
	</cffunction>
	
	<!--- expireObject --->
	<cffunction name="expireObject" output="false" access="public" returntype="void" hint="Mark an object for expiration">
		<cfargument name="objectKey" type="any"  required="true" hint="The object key">
	</cffunction>
	
	<!--- isExpired --->
    <cffunction name="isExpired" output="false" access="public" returntype="any" hint="Test if an object in the store has expired or not" colddoc:generic="Boolean">
    	<cfargument name="objectKey" type="any"  required="true" hint="The object key">
    </cffunction>
	
	<!--- Set an Object in the pool --->
	<cffunction name="set" access="public" output="false" returntype="void" hint="sets an object in the storage.">
		<cfargument name="objectKey" 			type="any"  required="true" hint="The object key">
		<cfargument name="object"				type="any" 	required="true" hint="The object to save">
		<cfargument name="timeout"				type="any"  hint="Timeout in minutes">
		<cfargument name="lastAccessTimeout"	type="any"  hint="Timeout in minutes">
		<cfargument name="extras" 				type="any" 	hint="A map of extra name-value pairs"/>
	</cffunction>
	
	<!--- Clear an object from the pool --->
	<cffunction name="clear" access="public" output="false" returntype="any" hint="Clears an object from the storage pool" colddoc:generic="Boolean">
		<cfargument name="objectKey" type="any"  required="true" hint="The object key">
	</cffunction>

	<!--- Get the size of the pool --->
	<cffunction name="getSize" access="public" output="false" returntype="any" hint="Get the store's size" colddoc:generic="numeric">
	</cffunction>
	
</cfinterface>