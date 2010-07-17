<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	The main interface for CacheBox object storages.
	A store is a physical counterpart to a cache, in which objects are kept, indexed and monitored.

----------------------------------------------------------------------->
<cfinterface hint="The main interface for CacheBox object storages.">

	<!--- getKeys --->
	<cffunction name="getKeys" output="false" access="public" returntype="array" hint="Get all the store's object keys">
	</cffunction>
	
	<!--- clearAll --->
    <cffunction name="clearAll" output="false" access="public" returntype="void" hint="Clear all elements of the store">
    </cffunction>
	
	<!--- flush --->
    <cffunction name="flush" output="false" access="public" returntype="void" hint="Flush the store to a permanent storage">
    </cffunction>
	
	<!--- lookup --->
	<cffunction name="lookup" access="public" output="false" returntype="boolean" hint="Check if an object is in the store">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object">
	</cffunction>
	
	<!--- get --->
	<cffunction name="get" access="public" output="false" returntype="any" hint="Get an object from the store">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object">
	</cffunction>
	
	<!--- expireObject --->
	<cffunction name="expireObject" output="false" access="public" returntype="void" hint="Mark an object for expiration">
		<cfargument name="objectKey" type="any"  required="true" hint="The object key">
	</cffunction>
	
	<!--- isExpired --->
    <cffunction name="isExpired" output="false" access="public" returntype="boolean" hint="Test if an object in the store has expired or not">
    	<cfargument name="objectKey" type="any"  required="true" hint="The object key">
    </cffunction>
	
	<!--- Set an Object in the pool --->
	<cffunction name="set" access="public" output="false" returntype="void" hint="sets an object in the storage.">
		<cfargument name="objectKey" 			type="any"  required="true" hint="The object key">
		<cfargument name="object"				type="any" 	required="true" hint="The object to save">
		<cfargument name="timeout"				type="any"  hint="Timeout in minutes">
		<cfargument name="lastAccessTimeout"	type="any"  hint="Timeout in minutes">
		<cfargument name="extras" 				type="struct" hint="A map of extra name-value pairs"/>
	</cffunction>
	
	<!--- Clear an object from the pool --->
	<cffunction name="clear" access="public" output="false" returntype="boolean" hint="Clears an object from the storage pool">
		<cfargument name="objectKey" 			type="any"  required="true" hint="The object key">
	</cffunction>

	<!--- Get the size of the pool --->
	<cffunction name="getSize" access="public" output="false" returntype="numeric" hint="Get the store's size">
	</cffunction>
	
</cfinterface>