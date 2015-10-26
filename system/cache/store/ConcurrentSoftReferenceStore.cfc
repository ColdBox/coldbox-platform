<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************
Author 	    :	Luis Majano
Description :
	I am a concurrent soft reference object store. In other words, I am fancy!
	This store is case-sensitive

----------------------------------------------------------------------->
<cfcomponent hint="I am a concurrent soft reference object store. In other words, I am fancy!" output="false" extends="coldbox.system.cache.store.ConcurrentStore">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<!--- init --->
	<cffunction name="init" access="public" output="false" returntype="ConcurrentSoftReferenceStore" hint="Constructor">
		<cfargument name="cacheProvider" type="any" required="true" hint="The associated cache provider as coldbox.system.cache.ICacheProvider" colddoc:generic="coldbox.system.cache.ICacheProvider"/>
		<cfscript>
			// Super size me
			super.init( arguments.cacheProvider );
			
			// Override Fields
			instance.indexer.setFields( instance.indexer.getFields() & ",isSoftReference");
			
			// Prepare soft reference lookup maps
			instance.softRefKeyMap	 = CreateObject("java","java.util.concurrent.ConcurrentHashMap").init();
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
	
	<!--- reap --->
    <cffunction name="reap" output="false" access="public" returntype="void" hint="Reap the storage, clean it from old stuff">
    	
    	<cfset var refLocal = {}>
    	
    	<cflock name="ConcurrentSoftReferenceStore.reap.#instance.storeID#" type="exclusive" timeout="20">
    	<cfscript>
    		
    		// Init Ref Key Vars
			refLocal.collected = instance.referenceQueue.poll();
			
			// Let's reap the garbage collected soft references
			while( structKeyExists(reflocal, "collected") ){
				
				// Clean if it still exists
				if( softRefLookup( reflocal.collected ) ){
					
					// expire it
					expireObject( getSoftRefKey(refLocal.collected) );
					
					// GC Collection Hit
					instance.cacheProvider.getStats().gcHit();
				}
				
				// Poll Again
				reflocal.collected = instance.referenceQueue.poll();
			}
		</cfscript>
		</cflock>
		
    </cffunction>
	
	<!--- lookup --->
	<cffunction name="lookup" access="public" output="false" returntype="any" hint="Check if an object is in cache.">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object">
		
		<cfset var refLocal = {}>
			
		<cflock name="ConcurrentSoftReferenceStore.#instance.storeID#.#arguments.objectKey#" type="readonly" timeout="10" throwonTimeout="true">
		<cfscript>
			// check existence via super, if not found, check as it might be a soft reference
			if( NOT super.lookup( arguments.objectKey ) ){ return false; }
			// get quiet to test it as it might be a soft reference
			refLocal.target = getQuiet( arguments.objectKey );
			// is it found?
			if( NOT structKeyExists(refLocal,"target") ){ return false; }
			
			// if we get here, it is found
			return true;					
		</cfscript>
		</cflock>
	</cffunction>
	
	<!--- Get an object from the pool --->
	<cffunction name="get" access="public" output="false" returntype="any" hint="Get an object from cache. If its a soft reference object it might return a null value.">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object">
		<cfscript>
			var refLocal = {};
			
			// Get via concurrent store
			refLocal.target = super.get( arguments.objectKey );
			if( structKeyExists(refLocal,"target") ){
				
				// Validate if SR or normal object
				if( isInstanceOf(refLocal.target, "java.lang.ref.SoftReference") ){
					return refLocal.target.get();
				}
				
				return refLocal.target;
			}	
		</cfscript>
	</cffunction>
	
	<!--- getQuiet --->
	<cffunction name="getQuiet" access="public" output="false" returntype="any" hint="Get an object from cache. If its a soft reference object it might return a null value.">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object">
		<cfscript>
			var refLocal = {};
			
			// Get via concurrent store
			refLocal.target = super.getQuiet( arguments.objectKey );
			
			if( structKeyExists(refLocal,"target") ){
				
				// Validate if SR or normal object
				if( isInstanceOf(refLocal.target, "java.lang.ref.SoftReference") ){
					return refLocal.target.get();
				}
				
				return refLocal.target;
			}		
		</cfscript>		
	</cffunction>
	
	<!--- Set an Object in the pool --->
	<cffunction name="set" access="public" output="false" returntype="void" hint="sets an object in the storage.">
		<!--- ************************************************************* --->
		<cfargument name="objectKey" 			type="any"  required="true" hint="The object key">
		<cfargument name="object"				type="any" 	required="true" hint="The object to save">
		<cfargument name="timeout"				type="any"  required="false" default="0" hint="Timeout in minutes">
		<cfargument name="lastAccessTimeout"	type="any"  required="false" default="0" hint="Idle Timeout in minutes">
		<cfargument name="extras" 				type="any" default="#structnew()#" hint="A map of extra name-value pairs"/>
		<!--- ************************************************************* --->
		
		<cfset var target 	= 0>
		<cfset var isSR	= (arguments.timeout GT 0)>
		
		<!--- Extra lock due to extra md --->
		<cflock name="ConcurrentSoftReferenceStore.#instance.storeID#.#arguments.objectKey#" type="exclusive" timeout="10" throwonTimeout="true">
		<cfscript>
			
			// Check for eternal object
			if( isSR ){
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
			
			// Set extra md in indexer
			instance.indexer.setObjectMetadataProperty(arguments.objectKey,"isSoftReference", isSR );
		</cfscript>
		</cflock>
	</cffunction>

	<!--- Clear an object from the pool --->
	<cffunction name="clear" access="public" output="false" returntype="any" hint="Clears an object from the storage pool">
		<cfargument name="objectKey" 			type="any"  required="true" hint="The object key">
		
		<cfset var softRef = "">
		
		<cflock name="ConcurrentSoftReferenceStore.#instance.storeID#.#arguments.objectKey#" type="exclusive" timeout="10" throwonTimeout="true">
		<cfscript>
			
			// Check if it exists
			if( NOT structKeyExists(instance.pool, arguments.objectKey) ){
				return false;
			}
			
			// Is this a soft reference?
			softRef = instance.pool[arguments.objectKey];
			
			// Removal of Soft Ref Lookup
			if( instance.indexer.getObjectMetadataProperty(arguments.objectKey,"isSoftReference") ){
				structDelete(getSoftRefKeyMap(),softRef);
			}
			
			return super.clear( arguments.objectKey );
		</cfscript>
		</cflock>
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
	<cffunction name="softRefLookup" access="public" returntype="any" hint="See if the soft reference is in the reference key map" output="false" >
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

</cfcomponent>