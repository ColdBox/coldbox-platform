<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
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
			getIndexer().setFields( getIndexer().getFields() & ",isSoftReference");
			
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
					instance.provider.getStats().gcHit();
				}
				
				// Poll Again
				reflocal.collected = instance.referenceQueue.poll();
			}
		</cfscript>
		</cflock>
		
    </cffunction>
	
	<!--- lookup --->
	<cffunction name="lookup" access="public" output="false" returntype="boolean" hint="Check if an object is in cache.">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object">
		
		<cfset var results 	= super.lookup( arguments.objectKey )>
		<cfset var target 	= "">
		<cfset var refLocal = {}>
			
		<cflock name="ConcurrentSoftReferenceStore.#arguments.objectKey#" type="readonly" timeout="10" throwonTimeout="true">
		<cfscript>
			
			// Check if false and return immediately
			if( NOT results ){
				return results;
			}
			
			// Validate if SR or normal object and if SR is null
			refLocal.target = getQuiet( arguments.objectKey );
			if( getIndexer().getObjectMetadataProperty(arguments.objectKey,"isSoftReference") 
				AND NOT structKeyExists(refLocal,"target") ){
				
				// Mark as dead
				expireObject( arguments.objectKey );
				return false;
			}
			
			//found
			return true;			
		</cfscript>
		</cflock>
	</cffunction>
	
	<!--- Get an object from the pool --->
	<cffunction name="get" access="public" output="false" returntype="any" hint="Get an object from cache. If its a soft reference object it might return a null value.">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object">
		<cfscript>
			var target = 0;
			
			// Get via concurrent store
			target = super.get( arguments.objectKey );
			
			// Validate if SR or normal object
			if( getIndexer().getObjectMetadataProperty(arguments.objectKey,"isSoftReference") ){
				return target.get();
			}
			
			return target;
		</cfscript>
	</cffunction>
	
	<!--- getQuiet --->
	<cffunction name="getQuiet" access="public" output="false" returntype="any" hint="Get an object from cache. If its a soft reference object it might return a null value.">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object">
		<cfscript>
			var target = 0;
			
			// Get via concurrent store, locking already done here
			target = super.getQuiet( arguments.objectKey );
			
			// Validate if SR or normal object
			if( getIndexer().getObjectMetadataProperty(arguments.objectKey,"isSoftReference") ){
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
		<cfargument name="timeout"				type="any"  required="false" default="0" hint="Timeout in minutes">
		<cfargument name="lastAccessTimeout"	type="any"  required="false" default="0" hint="Idle Timeout in minutes">
		<cfargument name="extras" 				type="struct" default="#structnew()#" hint="A map of extra name-value pairs"/>
		<!--- ************************************************************* --->
		
		<cfset var target 	= 0>
		<cfset var isSR	= (arguments.timeout GT 0)>
		
		<!--- Extra lock due to extra md --->
		<cflock name="ConcurrentSoftReferenceStore.#arguments.objectKey#" type="exclusive" timeout="10" throwonTimeout="true">
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
			getIndexer().setObjectMetadataProperty(arguments.objectKey,"isSoftReference", isSR );
		</cfscript>
		</cflock>
	</cffunction>

	<!--- Clear an object from the pool --->
	<cffunction name="clear" access="public" output="false" returntype="boolean" hint="Clears an object from the storage pool">
		<cfargument name="objectKey" 			type="any"  required="true" hint="The object key">
		
		<cfset var softRef = "">
		
		<cflock name="ConcurrentSoftReferenceStore.#arguments.objectKey#" type="exclusive" timeout="10" throwonTimeout="true">
		<cfscript>
			
			// Check if it exists
			if( NOT structKeyExists(instance.pool, arguments.objectKey) ){
				return false;
			}
			
			// Is this a soft reference?
			softRef = instance.pool[arguments.objectKey];
			
			// Removal of Soft Ref Lookup
			if( getIndexer().getObjectMetadataProperty(arguments.objectKey,"isSoftReference") ){
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