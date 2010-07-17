<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Author 	    :	Luis Majano
Description :
	I am a concurrent soft reference object store. In other words, I am fancy!
	
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
<cfcomponent hint="I am a concurrent soft reference object store. In other words, I am fancy!" output="false" extends="coldbox.system.cache.store.ConcurrentStore">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<!--- init --->
	<cffunction name="init" access="public" output="false" returntype="ConcurrentSoftReferenceStore" hint="Constructor">
		<cfargument name="cacheProvider" type="coldbox.system.cache.ICacheProvider" required="true" hint="The associated cache provider"/>
		<cfscript>
			// Super size me
			super.init(arguments.cacheProvider);
			
			// Prepare instance
			instance.softRefKeyMap	= CreateObject("java","java.util.concurrent.ConcurrentHashMap").init();
			instance.referenceQueue  = CreateObject("java","java.lang.ref.ReferenceQueue").init();
			
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- INTERFACE PUBLIC METHODS ------------------------------------------->
	
	<!--- clearAll --->
    <cffunction name="clearAll" output="false" access="public" returntype="void" hint="Clear all elements of the store">
    	<cfscript>
    		super.clearAll();
			instance.softRefKeyMap.clear();
		</cfscript>
    </cffunction>
	
	<!--- Get an object from the pool --->
	<cffunction name="get" access="public" output="false" returntype="any" hint="Get an object from cache. If its a soft reference object it might return a null value.">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object">
		<cfscript>
			var target = 0;
			
			// Get via concurrent store
			target = super.get( arguments.objectKey );
			
			// Validate if SR or normal object
			if( isSoftReference( target ) ){
				return target.get();
			}
			
			return target;
		</cfscript>
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
			var target 	= 0;
			
			// Check for eternal object
			if( arguments.timeout GT 0 ){
				// Cache as soft reference not an eternal object
				target = createSoftReference(arguments.objectKey,arguments.object);
			}
			else{
				target = arguments.object;
			}
			
			// Store it
			super.set(objectKey=arguments.objectKey,
					  object=target,
					  timeout=arguments.timeout,
					  lastAccessTimeout=arguments.lastAccessTimeout,
					  extras=arguments.extras);
		</cfscript>
	</cffunction>

	<!--- Clear an object from the pool --->
	<cffunction name="clear" access="public" output="false" returntype="boolean" hint="Clears an object from the storage pool">
		<cfargument name="objectKey" 			type="any"  required="true" hint="The object key">
		<cfscript>
			var softRef = "";
		
			// Check if it exists
			if( NOT structKeyExists(instance.pool, arguments.objectKey) ){
				return false;
			}
			
			// Is this a soft reference?
			softRef = instance.pool[arguments.objectKey];
			
			// Removal of Soft Ref Lookup
			if( isSoftReference(softRef) ){
				structDelete(getSoftRefKeyMap(),softRef);
			}
			
			return super.clear( arguments.objectKey );
		</cfscript>
	</cffunction>

	<!--- getReferenceQueue --->
	<cffunction name="getReferenceQueue" access="public" output="false" returntype="any" hint="Get soft reference queue object">
		<cfreturn instance.referenceQueue/>
	</cffunction>	
	
	<!--- Get Soft Reference KeyMap --->
	<cffunction name="getSoftRefKeyMap" access="public" output="false" returntype="any" hint="Get the soft reference key map">
		<cfreturn instance.softRefKeyMap/>
	</cffunction>	
		
	<!--- softRefLookup --->
	<cffunction name="softRefLookup" access="public" returntype="boolean" hint="See if the soft reference is in the reference key map" output="false" >
		<cfargument name="softRef" required="true" type="any" hint="The soft reference to check">
		<cfreturn structKeyExists(instance.softRefKeyMap,arguments.softRef)>
	</cffunction>
	
	<!--- getSoftRefKey --->
	<cffunction name="getSoftRefKey" access="public" returntype="any" hint="Get the soft reference's key from the soft reference lookback map" output="false" >
		<cfargument name="softRef" required="true" type="any" hint="The soft reference to check">
		<cfscript>
			var keyMap = getSoftRefKeyMap();
			
			if( structKeyExists(keyMap,arguments.softRef) ){
				return keyMap[arguments.softRef];
			}
			
			// TODO: check why I do this? DOn't remember
			return "NOT_FOUND";
		</cfscript>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->

	<!--- Create a soft reference --->
	<cffunction name="createSoftReference" access="private" returntype="any" hint="Create SR, register cached object and reference" output="false" >
		<cfargument name="objectKey" type="any"  	required="true" hint="The value of the key pair">
		<cfargument name="target"	 type="any" 	required="true" hint="The object to wrap">
		<cfscript>
		
			// Create Soft Reference Wrapper and register with Queue
			var softRef = CreateObject("java","java.lang.ref.SoftReference").init(arguments.target,getReferenceQueue());
			var refKeyMap = getSoftRefKeyMap();
			
			// Create Reverse Mapping
			refKeyMap[ softRef ] = arguments.objectKey;
			
			return softRef;
		</cfscript>
	</cffunction>
	
	<!--- Check if this is a soft reference --->
	<cffunction name="isSoftReference" access="private" returntype="boolean" hint="Checks whether the passed object is a soft reference" output="false" >
		<cfargument name="target"	 type="any" required="true" hint="The object to test">
		<cfscript>
			return isInstanceOf( arguments.target, "java.lang.ref.SoftReference");
		</cfscript>
	</cffunction>

</cfcomponent>