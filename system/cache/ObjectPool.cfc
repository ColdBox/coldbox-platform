<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date        :	January 18, 2007
Description :
	This is an object cache pool.

Modification History:
01/18/2007 - Created
----------------------------------------------------------------------->
<cfcomponent name="ObjectPool" hint="I manage persistance for objects." output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" output="false" returntype="ObjectPool" hint="Constructor">
		<cfscript>
			var Collections = createObject("java", "java.util.Collections");
			/* Create the reference maps */
			var Map = CreateObject("java","java.util.HashMap").init();
			var MetadataMap = CreateObject("java","java.util.HashMap").init();
			var SoftRefKeyMap = CreateObject("java","java.util.HashMap").init();
			
			/* Prepare instance */
			variables.instance = structnew();
			
			/* Instantiate object pools */
			setpool( Collections.synchronizedMap( Map ) );
			setpool_metadata( Collections.synchronizedMap( MetadataMap ) );
			setSoftRefKeyMap( Collections.synchronizedMap(SoftRefKeyMap) );
			
			/* Register the reference queue for our soft references */
			setReferenceQueue( CreateObject("java","java.lang.ref.ReferenceQueue").init() );
			
			/* Return pool */
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->
	
	<!--- Get/Set the Ref Queue --->
	<cffunction name="getReferenceQueue" access="public" output="false" returntype="any" hint="Get ReferenceQueue">
		<cfreturn instance.ReferenceQueue/>
	</cffunction>	
	
	<!--- Get/Set Soft Reference KeyMap --->
	<cffunction name="getSoftRefKeyMap" access="public" output="false" returntype="any" hint="Get SoftRefKeyMap">
		<cfreturn instance.SoftRefKeyMap/>
	</cffunction>	
		
	<!--- Check if the soft reference exists --->
	<cffunction name="softRefLookup" access="public" returntype="boolean" hint="See if the soft reference is in the key map" output="false" >
		<cfargument name="softRef" required="true" type="any" hint="The soft reference to check">
		<cfreturn structKeyExists(getSoftRefKeyMap(),arguments.softRef)>
	</cffunction>
	
	<!--- Get the ref key --->
	<cffunction name="getSoftRefKey" access="public" returntype="any" hint="Get the soft reference's key from the soft reference lookback map" output="false" >
		<cfargument name="softRef" required="true" type="any" hint="The soft reference to check">
		<cfscript>
			var keyMap = getSoftRefKeyMap();
			if( structKeyExists(keyMap,arguments.softRef) ){
				return keyMap[arguments.softRef];
			}
			else{
				return "NOT_FOUND";
			}
		</cfscript>
	</cffunction>
	
	<!--- Getter/Setter For pool --->
	<cffunction name="getpool" access="public" returntype="any" output="false" hint="Get the cache pool">
		<cfreturn instance.pool>
	</cffunction>
	
	<!--- Getter/Setter for Pool Metdata --->
	<cffunction name="getpool_metadata" access="public" returntype="any" output="false" hint="Get the cache pool metadata">
		<cfreturn instance.pool_metadata >
	</cffunction>

	<!--- Setter/Getter metdata property --->
	<cffunction name="getObjectMetadata" access="public" returntype="any" output="false" hint="Get a metadata entry for a specific cache entry">
		<cfargument name="objectKey" type="any" required="true">
		<cfreturn instance.pool_metadata[arguments.objectKey] >
	</cffunction>
	<cffunction name="setObjectMetadata" access="public" returntype="void" output="false" hint="Set the metadata entry for a specific cache entry">
		<cfargument name="objectKey" type="any" required="true">
		<cfargument name="metadata"  type="any" required="true">
		<cfset instance.pool_metadata[arguments.objectKey] = arguments.metadata>
	</cffunction>
	<cffunction name="getMetadataProperty" access="public" returntype="any" output="false" hint="Get a metadata property for a specific cache entry">
		<cfargument name="objectKey" type="any" required="true">
		<cfargument name="property"  type="any" required="true">
		<cfreturn instance.pool_metadata[arguments.objectKey][arguments.property] >
	</cffunction>
	<cffunction name="setMetadataProperty" access="public" returntype="void" output="false" hint="Set a metadata property for a specific cache entry">
		<cfargument name="objectKey" type="any" required="true">
		<cfargument name="property"  type="any" required="true">
		<cfargument name="value"  	 type="any"    required="true">
		<cfset instance.pool_metadata[arguments.objectKey][arguments.property] = arguments.value >
	</cffunction>

	<!--- Simple Object Lookup --->
	<cffunction name="lookup" access="public" output="false" returntype="boolean" hint="Check if an object is in cache, it doesn't tell you if the soft reference expired or not">
		<!--- ************************************************************* --->
		<cfargument name="objectKey" type="any" required="true">
		<!--- ************************************************************* --->
		<!--- Check for Object in Cache. --->
		<cfreturn structKeyExists(instance.pool, arguments.objectKey) >
	</cffunction>

	<!--- Get an object from the pool --->
	<cffunction name="get" access="public" output="false" returntype="any" hint="Get an object from cache. If its a soft reference object it might return a null value.">
		<!--- ************************************************************* --->
		<cfargument name="objectKey" type="any" required="true">
		<!--- ************************************************************* --->
		<cfscript>
			var tmpObj = 0;
			
			/* Record Metadata Access */
			setMetadataProperty(arguments.objectKey,"hits", getMetaDataProperty(arguments.objectKey,"hits")+1);
			setMetadataProperty(arguments.objectKey,"lastAccesed", now());
			
			/* Get Object */
			tmpObj = instance.pool[arguments.objectKey];
			
			/* Validate if SR or eternal */
			if( isSoftReference(tmpObj) ){
				return tmpObj.get();
			}
			else{
				return tmpObj;
			}
		</cfscript>
	</cffunction>

	<!--- Set an Object in the pool --->
	<cffunction name="set" access="public" output="false" returntype="void" hint="sets an object in cache.">
		<!--- ************************************************************* --->
		<cfargument name="objectKey" 			type="any"  required="true">
		<cfargument name="MyObject"				type="any" 	required="true">
		<cfargument name="Timeout"				type="any"  required="false" default="" hint="Timeout in minutes. If timeout = 0 then object never times out. If timeout is blank, then timeout will be inherited from framework.">
		<cfargument name="LastAccessTimeout"	type="any"  required="false" default="" hint="Timeout in minutes. If timeout is blank, then timeout will be inherited from framework.">
		<!--- ************************************************************* --->
		<cfscript>
			var MetaData = structnew();
			var targetObj = 0;
			
			/* Check for eternal object */
			if( arguments.timeout neq 0 ){
				/* Cache as soft reference not an eternal object */
				targetObj = createSoftReference(arguments.objectKey,arguments.MyObject);
			}
			else{
				targetObj = arguments.MyObject;
			}
			
			/* Set new Object into cache pool */
			instance.pool[arguments.objectKey] = targetObj;
			
			/* Create object's metdata */
			MetaData.hits = 1;
			MetaData.Timeout = arguments.timeout;
			MetaData.LastAccessTimeout = arguments.LastAccessTimeout;
			MetaData.Created = now();
			MetaData.LastAccesed = now();			
			
			/* Save the metadata */
			setObjectMetaData(arguments.objectkey,MetaData);
		</cfscript>
	</cffunction>

	<!--- Clear an object from the pool --->
	<cffunction name="clearKey" access="public" output="false" returntype="boolean" hint="Clears a key from the cache.">
		<!--- ************************************************************* --->
		<cfargument name="objectKey" type="string" required="true">
		<!--- ************************************************************* --->
		<cfscript>
			var Results = false;
			var softRef = "";
			
			try{
				/* Is this a soft Ref */
				softRef = instance.pool[arguments.objectKey];
				/* Removal of Soft Ref Lookup */
				if( isSoftReference(softRef) ){
					structDelete(getSoftRefKeyMap(),softRef);
				}
				
				/* Remove Normal Cache Entries */
				structDelete(getPool(),arguments.objectKey);
				structDelete(getpool_metadata(),arguments.objectKey);
								
				/* Removed */
				Results = true;
			}
			catch(Any e){
				//Nothing;
			}
			return Results;
		</cfscript>
	</cffunction>

	<!--- Get the size of the pool --->
	<cffunction name="getSize" access="public" output="false" returntype="numeric" hint="Get the cache's size in items">
		<cfreturn StructCount(getPool())>
	</cffunction>

	<!--- Get the itemList --->
	<cffunction name="getObjectsKeyList" access="public" output="false" returntype="string" hint="Get the cache's object entries listing.">
		<cfreturn structKeyList(getPool())>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->

	<!--- Set the pool_metadata --->
	<cffunction name="setpool_metadata" access="public" returntype="void" output="false" hint="Set the cache pool metadata">
		<cfargument name="pool_metadata" type="struct" required="true">
		<cfset instance.pool_metadata = arguments.pool_metadata>
	</cffunction>
	
	<!--- Set the object pool --->
	<cffunction name="setpool" access="private" returntype="void" output="false" hint="Set the cache pool">
		<cfargument name="pool" type="struct" required="true">
		<cfset instance.pool = arguments.pool>
	</cffunction>

	<!--- Set the reference queue --->
	<cffunction name="setReferenceQueue" access="private" output="false" returntype="void" hint="Set ReferenceQueue">
		<cfargument name="ReferenceQueue" type="any" required="true"/>
		<cfset instance.ReferenceQueue = arguments.ReferenceQueue/>
	</cffunction>
	
	<!--- Set the soft ref key map --->
	<cffunction name="setSoftRefKeyMap" access="private" output="false" returntype="void" hint="Set SoftRefKeyMap">
		<cfargument name="SoftRefKeyMap" type="any" required="true"/>
		<cfset instance.SoftRefKeyMap = arguments.SoftRefKeyMap/>
	</cffunction>
	
	<!--- Create a soft referenec --->
	<cffunction name="createSoftReference" access="private" returntype="any" hint="Create SR, register cached object and reference" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="objectKey" type="any"  	required="true" hint="The value of the key pair">
		<cfargument name="MyObject"	 type="any" 	required="true" hint="The object to wrap">
		<!--- ************************************************************* --->
		<cfscript>
			/* Create Soft Reference Wrapper and register with Queue */
			var softRef = CreateObject("java","java.lang.ref.SoftReference").init(arguments.MyObject,getReferenceQueue());
			var RefKeyMap = getSoftRefKeyMap();
			
			/* Create Reverse Mapping */
			RefKeyMap[softRef] = arguments.objectKey;
			
			/* Return object */
			return softRef;
		</cfscript>
	</cffunction>
	
	<!--- Check if this is a soft referene --->
	<cffunction name="isSoftReference" access="private" returntype="boolean" hint="Whether the passed object is a soft reference" output="false" >
		<cfargument name="MyObject"	 type="any" required="true" hint="The object to test">
		<cfscript>
			if( isObject(arguments.myObject) and getMetaData(arguments.MyObject).name eq "java.lang.ref.SoftReference" ){
				return true;
			}
			else{
				return false;
			}			
		</cfscript>
	</cffunction>

</cfcomponent>