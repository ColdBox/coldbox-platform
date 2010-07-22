<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	The coolest standalone CacheBox Provider ever built.

Properties
- name : The cache name
- enabled : Boolean flag if cache is enabled
- reportingEnabled: Boolean falg if cache can report
- stats : The statistics object
- configuration : The configuration structure
- cacheFactory : The linkage to the cachebox factory
- eventManager : The linkage to the event manager
- cacheID : The unique identity code of this CFC
----------------------------------------------------------------------->
<cfcomponent hint="The coolest standalone CacheBox Provider ever built" 
			 output="false" 
			 extends="coldbox.system.cache.providers.AbstractCacheBoxProvider"
			 serializable="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	
	<cffunction name="init" access="public" output="false" returntype="CacheBoxProvider" hint="Constructor">
		<cfscript>
			// super size me
			super.init();
			
			// Logger object
			instance.logger = "";
			// Runtime Java object
			instance.javaRuntime = createObject("java", "java.lang.Runtime");
			// Locking Timeout
			instance.lockTimeout = "15";
			// Eviction Policy
			instance.evictionPolicy = "";
			
			return this;
		</cfscript>
	</cffunction>

	<!--- Configure the Cache for Operation --->
	<cffunction name="configure" access="public" output="false" returntype="void" hint="Configures the cache for operation, sets the configuration object, sets and creates the eviction policy and clears the stats. If this method is not called, the cache is useless.">
		<cfscript>		
			var cacheConfig     = getConfiguration();
			var evictionPolicy  = "";
			var objectStore		= "";
			
			// Prepare the logger
			instance.logger = getCacheFactory().getLogBox().getLogger( this );
			instance.logger.debug("Starting up CacheBox Cache: #getName()# with configuration: #cacheConfig.toString()#");
			
			// Prepare Statistics
			instance.stats = CreateObject("component","coldbox.system.cache.util.CacheStats").init(this);
			
			// Setup the eviction Policy to use
			try{
				evictionPolicy = locateEvictionPolicy( cacheConfig.evictionPolicy );
				instance.evictionPolicy = CreateObject("component", evictionPolicy).init(this);
			}
			catch(Any e){
				instance.logger.error("Error creating eviction policy: #evictionPolicy#", e);
				getUtil().throwit('Error creating eviction policy: #evictionPolicy#','#e.message# #e.detail# #e.stackTrace#','CacheBoxProvider.EvictionPolicyCreationException');	
			}
			
			// Create the object store the configuration mandated
			try{
				objectStore = locateObjectStore( cacheConfig.objectStore );
				instance.objectStore = CreateObject("component", objectStore).init(this);
			}
			catch(Any e){
				instance.logger.error("Error creating object store: #objectStore#", e);
				getUtil().throwit('Error creating object store #objectStore#','#e.message# #e.detail# #e.stackTrace#','CacheBoxProvider.ObjectStoreCreationException');	
			}
			
			// Enable cache
			instance.enabled = true;
			// Enable reporting
			instance.reportingEnabled = true;
			
			// startup message
			instance.logger.info("CacheBox Cache: #getName()# has been initialized successfully for operation");			
		</cfscript>
	</cffunction>
	
	<!--- shutdown --->
    <cffunction name="shutdown" output="false" access="public" returntype="void" hint="Shutdown command issued when CacheBox is going through shutdown phase">
   		<cfscript>
   			// TODO: We can do fancy shmancy stuff later on here.
			
   			instance.logger.info("CacheBox Cache: #getName()# has been shutdown.");
   		</cfscript>
    </cffunction>
	
	<!--- locateEvictionPolicy --->
    <cffunction name="locateEvictionPolicy" output="false" access="private" returntype="any" hint="Locate the eviction policy">
    	<cfargument name="policy" type="string"/>
    	<cfscript>
    		if( fileExists( expandPath("/coldbox/system/cache/policies/#arguments.policy#.cfc") ) ){
				return "coldbox.system.cache.policies.#arguments.policy#";
			}
			return arguments.policy;
    	</cfscript>
    </cffunction>
	
	<!--- locateObjectStore --->
    <cffunction name="locateObjectStore" output="false" access="private" returntype="any" hint="Locate the object store">
    	<cfargument name="store" type="string"/>
    	<cfscript>
    		if( fileExists( expandPath("/coldbox/system/cache/store/#arguments.store#.cfc") ) ){
				return "coldbox.system.cache.store.#arguments.store#";
			}
			return arguments.store;
    	</cfscript>
    </cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Lookup Multiple Keys --->
	<cffunction name="lookupMulti" access="public" output="false" returntype="struct" hint="The returned value is a structure of name-value pairs of all the keys that where found or not.">
		<cfargument name="keys" 	type="any" 		required="true" hint="The comma delimited list or an array of keys to lookup in the cache.">
		<cfargument name="prefix" 	type="string" 	required="false" default="" hint="A prefix to prepend to the keys">
		<cfscript>
			var returnStruct 	= structnew();
			var x 				= 1;
			var thisKey 		= "";
			
			// Normalize keys
			if( isArray(arguments.keys) ){
				arguments.keys = arrayToList( arguments.keys );
			}
			
			// Loop on Keys
			for(x=1;x lte listLen(arguments.keys);x++){
				thisKey = arguments.prefix & listGetAt(arguments.keys,x);
				returnStruct[thiskey] = lookup( thisKey );
			}
			
			return returnStruct;
		</cfscript>
	</cffunction>
	
	<!--- lookup --->
	<cffunction name="lookup" access="public" output="false" returntype="boolean" hint="Check if an object is in cache, if not found it records a miss.">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object to lookup.">
		<cfscript>
			
			if( lookupQuiet(arguments.objectKey) ){
				// record a hit
				getStats().hit();
				return true;
			}
			
			// record a miss
			getStats().miss();
		
			return false;
		</cfscript>
	</cffunction>
	
	<!--- lookupQuiet --->
	<cffunction name="lookupQuiet" access="public" output="false" returntype="boolean" hint="Check if an object is in cache quietly, advising nobody!">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object to lookup.">

		<!--- Cleanup the key --->
		<cfset arguments.objectKey = lcase(arguments.objectKey)>
		
		<cflock type="readonly" name="CacheBox.#getName()#.#arguments.objectKey#" timeout="#instance.lockTimeout#" throwontimeout="true">
			<cfreturn instance.objectStore.lookup( arguments.objectKey )>
		</cflock>
		
	</cffunction>

	<!--- Get an object from the cache --->
	<cffunction name="get" access="public" output="false" returntype="any" hint="Get an object from cache. If object does not exist it returns null">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object to lookup.">
		
		<!--- Cleanup the key --->
		<cfset arguments.objectKey = lcase(trim(arguments.objectKey))>
		
		<cflock type="readonly" name="CacheBox.#getName()#.#arguments.objectKey#" timeout="#instance.lockTimeout#" throwontimeout="true">
			<cfscript>
				// Check if it exists
				if( instance.objectStore.lookup(arguments.objectKey) ){
					getStats().hit();
					return instance.objectStore.get( arguments.objectKey );
				}
				getStats().miss();
				// don't return anything = null
			</cfscript>
		</cflock>
	</cffunction>
	
	<!--- Get multiple objects from the cache --->
	<cffunction name="getMulti" access="public" output="false" returntype="struct" hint="The returned value is a structure of name-value pairs of all the keys that where found. Not found values will not be returned">
		<!--- ************************************************************* --->
		<cfargument name="keys" 		type="any" 		required="true" hint="The comma delimited list or array of keys to retrieve from the cache.">
		<cfargument name="prefix"		type="string" 	required="false" default="" hint="A prefix to prepend to the keys">
		<!--- ************************************************************* --->
		<cfscript>
			var returnStruct = structnew();
			var x = 1;
			var thisKey = "";
			
			// Normalize keys
			if( isArray(arguments.keys) ){
				arguments.keys = arrayToList( arguments.keys );
			}
			
			// Clear Prefix
			arguments.prefix = trim(arguments.prefix);
			
			// Loop keys
			for(x=1;x lte listLen(arguments.keys);x=x+1){
				thisKey = arguments.prefix & listGetAt(arguments.keys,x);
				if( lookup(thisKey) ){
					returnStruct[thiskey] = get(thisKey);
				}
			}
			
			return returnStruct;
		</cfscript>
	</cffunction>
	
	<!--- getCachedObjectMetadata --->
	<cffunction name="getCachedObjectMetadata" output="false" access="public" returntype="struct" hint="Get the cached object's metadata structure. If the object does not exist, it returns an empty structure.">
		<!--- ************************************************************* --->
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object to lookup its metadata">
		<!--- ************************************************************* --->
		<cfscript>
			// Cleanup the key
			arguments.objectKey = lcase(trim(arguments.objectKey));
			// Check if in the pool first
			if( lookup(arguments.objectKey) ){
				return getObjectStore().getObjectMetadata(arguments.objectKey);
			}
			else{
				return structnew();
			}
		</cfscript>
	</cffunction>
	
	<!--- getCachedObjectMetadata --->
	<cffunction name="getCachedObjectMetadataMulti" output="false" access="public" returntype="struct" hint="Get the cached object's metadata structure. If the object does not exist, it returns an empty structure.">
		<!--- ************************************************************* --->
		<cfargument name="keys" 	type="string" required="true" hint="The comma delimited list of keys to retrieve from the cache.">
		<cfargument name="prefix" 	type="string" required="false" default="" hint="A prefix to prepend to the keys">
		<!--- ************************************************************* --->
		<cfscript>
			var returnStruct = structnew();
			var x = 1;
			var thisKey = "";
			
			// Clear Prefix
			arguments.prefix = trim(arguments.prefix);
			
			// Loop on Keys
			for(x=1;x lte listLen(arguments.keys);x=x+1){
				thisKey = arguments.prefix & listGetAt(arguments.keys,x);
				if( lookup(thisKey) ){
					returnStruct[thiskey] = getCachedObjectMetadata(thisKey);
				}
			}
			
			return returnStruct;
		</cfscript>
	</cffunction>

	<!--- Set Multi Object in the cache --->
	<cffunction name="setMulti" access="public" output="false" returntype="void" hint="Sets Multiple Ojects in the cache. Sets might be expensive. If the JVM threshold is used and it has been reached, the object won't be cached. If the pool is at maximum it will expire using its eviction policy and still cache the object. Cleanup will be done later.">
		<!--- ************************************************************* --->
		<cfargument name="mapping" 				type="struct"  	required="true" hint="The structure of name value pairs to cache">
		<cfargument name="Timeout"				type="any"  	required="false" default="" hint="Timeout in minutes. If timeout = 0 then object never times out. If timeout is blank, then timeout will be inherited from framework.">
		<cfargument name="LastAccessTimeout"	type="any"  	required="false" default="" hint="Last Access Timeout in minutes. If timeout is blank, then timeout will be inherited from framework.">
		<cfargument name="prefix" 				type="string" 	required="false" default="" hint="A prefix to prepend to the keys">
		<!--- ************************************************************* --->
		<cfscript>
			var key = 0;
			// Clear Prefix
			arguments.prefix = trim(arguments.prefix);
			// Loop Over mappings
			for(key in arguments.mapping){
				// Cache theses puppies
				set(objectKey=arguments.prefix & key,MyObject=arguments.mapping[key],Timeout=arguments.timeout,LastAccessTimeout=arguments.LastAccessTimeout);
			}
		</cfscript>
	</cffunction>
	
	<!--- Set an Object in the cache --->
	<cffunction name="set" access="public" output="false" returntype="boolean" hint="sets an object in cache. Sets might be expensive. If the JVM threshold is used and it has been reached, the object won't be cached. If the pool is at maximum it will expire using its eviction policy and still cache the object. Cleanup will be done later.">
		<!--- ************************************************************* --->
		<cfargument name="objectKey" 			type="any"  	required="true" hint="The object cache key">
		<cfargument name="object"				type="any" 		required="true" hint="The object to cache">
		<cfargument name="timeout"				type="any"  	required="false" default="" hint="The timeout to use on the object (if any, provider specific)">
		<cfargument name="lastAccessTimeout"	type="any" 	 	required="false" default="" hint="The idle timeout to use on the object (if any, provider specific)">
		<cfargument name="extra" 				type="struct" 	required="false" hint="A map of name-value pairs to use as extra arguments to pass to a providers set operation"/>
		<!--- ************************************************************* --->
		<!---JVM Threshold Checks --->
		<cfset var isJVMSafe = true>
		<cfset var ccBean = getCacheConfig()>
		<cfset var interceptMetadata = structnew()>
		
		<!--- Clean Arguments --->
		<cfset arguments.objectKey = lcase(trim(arguments.objectKey))>
		<cfset arguments.timeout = trim(arguments.timeout)>
		<cfset arguments.lastAccessTimeout = trim(arguments.lastAccessTimeout)>
		
		<!--- JVMThreshold Check if enabled. --->
		<cfif ccBean.getFreeMemoryPercentageThreshold() neq 0 and ThresholdChecks() eq false>
			<!--- Evict Using Policy --->
			<cfset instance.evictionPolicy.execute()>
		</cfif>
		
		<!--- Check for max objects reached --->
		<cfif ccBean.getMaxObjects() NEQ 0 and getSize() GTE ccBean.getMaxObjects()>
			<!--- Evict Using Policy --->
			<cfset instance.evictionPolicy.execute()>
		</cfif>
			
		<!--- Test Timeout Argument, if false, then inherit framework's timeout --->
		<cfif len(arguments.timeout) eq 0 or not isNumeric(arguments.timeout) or arguments.timeout lt 0>
			<cfset arguments.timeout = ccBean.getObjectDefaultTimeout()>
		</cfif>
		
		<!--- Test the Last Access Timeout --->
		<cfif len(arguments.lastAccessTimeout) eq 0 or not isNumeric(arguments.lastAccessTimeout) or arguments.lastAccessTimeout lte 0>
			<cfset arguments.lastAccessTimeout = ccBean.getObjectDefaultLastAccessTimeout()>
		</cfif>
		
		<!--- Set object in Cache --->
		<cflock type="exclusive" name="CacheBox.#getName()#.#arguments.objectKey#" timeout="#instance.lockTimeout#" throwontimeout="true">
			<cfset getObjectStore().set(arguments.objectKey,arguments.myObject,arguments.timeout,arguments.lastAccessTimeout)>
		</cflock>
		
		<!--- InterceptMetadata --->
		<cfset interceptMetadata.cacheObjectKey = arguments.objectKey>
		<cfset interceptMetadata.cacheObjectTimeout = arguments.timeout>
		<cfset interceptMetadata.cacheObjectLastAccessTimeout = arguments.lastAccessTimeout>
		
		<!--- Execute afterCacheElementInsert Interception --->
		<cfset instance.controller.getInterceptorService().processState("afterCacheElementInsert",interceptMetadata)>				
		
		<cfreturn true>
	</cffunction>

	<!--- Clear an object from the cache --->
	<cffunction name="clearMulti" access="public" output="false" returntype="struct" hint="Clears objects from the cache by using its cache key. The returned value is a structure of name-value pairs of all the keys that where removed from the operation.">
		<!--- ************************************************************* --->
		<cfargument name="keys" 		type="any" 	  required="true" hint="The comma-delimmitted list or array of keys to remove.">
		<cfargument name="prefix" 		type="string" required="false" default="" hint="A prefix to prepend to the keys">
		<!--- ************************************************************* --->
		<cfscript>
			var returnStruct = {};
			var x = 1;
			var thisKey = "";
			
			// Clear Prefix
			arguments.prefix = trim(arguments.prefix);
			
			// array?
			if( isArray(arguments.keys) ){
				arguments.keys = arrayToList( arguments.keys );
			}
			
			// Loop on Keys
			for(x=1;x lte listLen(arguments.keys); x++){
				thisKey = arguments.prefix & listGetAt(arguments.keys,x);
				returnStruct[thiskey] = clear(thisKey);
			}
			
			return returnStruct;
		</cfscript>
	</cffunction>
	
	<!--- Clear By Key Snippet --->
	<cffunction name="clearByKeySnippet" access="public" returntype="void" hint="Clears keys using the passed in object key snippet" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="keySnippet"  	type="string"  required="true"  hint="the cache key snippet to use">
		<cfargument name="regex" 		type="boolean" required="false" default="false" hint="Use regex or not">
		<!--- ************************************************************* --->
		<cfscript>
			var poolKeys 		= listSort(getPoolKeys(),"textnocase");
			var poolKeysLength 	= listlen(poolKeys);
			var x = 1;
			var tester = 0;
			var thisKey = "";
			
			//Find all the event keys.
			for(x=1; x lte poolKeysLength; x++){
				// Get List Value
				thisKey = listGetAt(poolKeys,x);
				
				// Using Regex
				if( arguments.regex ){
					tester = refindnocase( arguments.keySnippet, thisKey );
				}
				else{
					tester = findnocase( arguments.keySnippet, thisKey );
				}
				
				// Test Evaluation
				if ( tester ){
					clear( thisKey );
				}
			}
		</cfscript>
	</cffunction>

	<!--- clearQuiet --->
	<cffunction name="clearQuiet" access="public" output="false" returntype="boolean" hint="Clears an object from the cache by using its cache key. Returns false if object was not removed or did not exist anymore">
		<cfargument name="objectKey" 			type="any"  	required="true" hint="The object cache key">
		<cfset var clearCheck 	= false>
		<cfset var objectStore	= getObjectStore()>
		
		<!--- Cleanup the key --->
		<cfset arguments.objectKey = lcase(trim(arguments.objectKey))>
		
		<!--- Remove Object --->
		<cflock type="exclusive" name="CacheBox.#getName()#.#arguments.objectKey#" timeout="#instance.lockTimeout#" throwontimeout="true">
			<cfif objectStore.lookup( arguments.objectKey )>
				<cfset clearCheck = objectStore.clearKey( arguments.objectKey )>
			</cfif>
		</cflock>
		
		<cfreturn clearCheck>		
	</cffunction>
	
	<!--- clear --->
	<cffunction name="clear" access="public" output="false" returntype="boolean" hint="Clears an object from the cache by using its cache key. Returns false if object was not removed or did not exist anymore">
		<cfargument name="objectKey" 			type="any"  	required="true" hint="The object cache key">
		<cfscript>
			var clearCheck = clearQuiet( arguments.objectKey );
			var iData = {
				cacheObjectKey 	= arguments.objectKey,
				cacheProvider	= this
			};
			
			// If cleared notify listeners
			if( clearCheck ){
				getEventManager().processState("afterCacheElementRemoved",iData);
			}
			
			return clearCheck;
		</cfscript>		
	</cffunction>
	
	<!--- clearAll --->
    <cffunction name="clearAll" output="false" access="public" returntype="void" hint="Clear all the cache elements from the cache">
    	<cfscript>
			var iData = {
				cacheProvider	= this
			};
			
			getObjectStore().clearAll();		
			// TODO: notify listeners: afterCacheClearAll		
			//getEventManager().processState("afterCacheClearAll",iData);
		</cfscript>
    </cffunction>
	
	<!--- Clear an object from the cache --->
	<cffunction name="clearKey" access="public" output="false" returntype="boolean" hint="Deprecated, please use clear()">
		<cfargument name="objectKey" 			type="any"  	required="true" hint="The object cache key">
		<cfreturn clear( arguments.objectKey )>
	</cffunction>

	<!--- Get the Cache Size --->
	<cffunction name="getSize" access="public" output="false" returntype="numeric" hint="Get the cache's size in items">
		<cfreturn getObjectStore().getSize()>
	</cffunction>

	<!--- Reap the Cache --->
	<cffunction name="reap" access="public" output="false" returntype="void" hint="Reap the cache.">
		<cfscript>
			var keyIndex = 1;
			var poolKeys = "";
			var poolKeysLength = 0;
			var thisKey = "";
			var thisMD = "";
			var ccBean = getCacheConfig();
			var reflocal = structNew();
		</cfscript>
		
		<!--- Lock Reaping, so only one can be ran even if called manually, for concurrency protection --->
		<cflock type="exclusive" name="CacheBox.#getName()#.#this.CACHE_ID#.reap" timeout="#instance.lockTimeout#">
		<cfscript>
			// Expire and cleanup if in frequency
			if ( dateDiff("n", getCacheStats().getlastReapDatetime(), now() ) gte ccBean.getReapFrequency() ){
				
				// Init Ref Key Vars
				reflocal.softRef = getObjectStore().getReferenceQueue().poll();
				
				// Let's reap the garbage collected soft references first before expriring
				while( StructKeyExists(reflocal, "softRef") ){
					// Clean if it still exists
					if( getObjectStore().softRefLookup(reflocal.softRef) ){
						clearKey( getObjectStore().getSoftRefKey(refLocal.softRef) );
						// GC Collection Hit
						getCacheStats().gcHit();
					}
					// Poll Again
					reflocal.softRef = getObjectStore().getReferenceQueue().poll();
				}
				
				// Let's Get our reaping vars ready, get a duplicate of the pool metadata so we can work on a good copy
				poolKeys = listToArray(getPoolKeys());
				poolKeysLength = ArrayLen(poolKeys);
				
				//Loop Through Metadata
				for (keyIndex=1; keyIndex lte poolKeysLength; keyIndex=keyIndex+1){
					
					//The Key to check
					thisKey = poolKeys[keyIndex];
					//Get the key's metadata thread safe.
					thisMD = getCachedObjectMetadata(thisKey);
					// Check if found, else continue, already reaped.
					if( structIsEmpty(thisMD) ){ continue; }
					
					//Reap only non-eternal objects
					if ( thisMD.Timeout gt 0 ){
						
						// Check if expired already
						if( thisMD.isExpired ){ 
							// Clear The Key
							if( clearKey(thisKey) ){
								// Announce Expiration only if removed, else maybe another thread cleaned it
								announceExpiration(thisKey);
							}	
							continue;						
						}
						
						//Check for creation timeouts and clear
						if ( dateDiff("n", thisMD.created, now() ) gte thisMD.Timeout ){
							
							// Clear The Key
							if( clearKey(thisKey) ){
								// Announce Expiration only if removed, else maybe another thread cleaned it
								announceExpiration(thisKey);
							}	
							continue;
						}
						
						//Check for last accessed timeouts. If object has not been accessed in the default span
						if ( ccBean.getUseLastAccessTimeouts() and 
						     dateDiff("n", thisMD.lastAccesed, now() ) gte thisMD.LastAccessTimeout ){
							
							// Clear The Key
							if( clearKey(thisKey) ){
								// Announce Expiration only if removed, else maybe another thread cleaned it
								announceExpiration(thisKey);
							}
							continue;
						}
					}//end timeout gt 0
					
				}//end looping over keys
				
				//Reaping about to start, set new reaping date.
				getCacheStats().setlastReapDatetime( now() );
								
			}// end reaping frequency check			
		</cfscript>
		</cflock>
	</cffunction>
	
	<!--- Expire All Objects --->
	<cffunction name="expireAll" access="public" returntype="void" hint="Expire All Objects. Use this instead of clear() from within handlers or any cached object, this sets the metadata for the objects to expire in the next request. Note that this is not an inmmediate expiration. Clear should only be used from outside a cached object" output="false" >
		<cfscript>
			expireByKeySnippet(keySnippet=".*",regex=true);
		</cfscript>
	</cffunction>
	
	<!--- Expire an Object --->
	<cffunction name="expireKey" access="public" returntype="void" hint="Expire an Object. Use this instead of clearKey() from within handlers or any cached object, this sets the metadata for the objects to expire in the next request. Note that this is not an inmmediate expiration. Clear should only be used from outside a cached object" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="objectKey" 			type="any"  	required="true" hint="The object cache key">
		<!--- ************************************************************* --->
		<cfscript>
			getObjectStore().expireObject(lcase(trim(arguments.objectKey)));
		</cfscript>
	</cffunction>
	
	<!--- Expire an Object --->
	<cffunction name="expireByKeySnippet" access="public" returntype="void" hint="Same as expireKey but can touch multiple objects depending on the keysnippet that is sent in." output="false" >
		<!--- ************************************************************* --->
		<cfargument name="keySnippet" type="string"  required="true" hint="The key snippet to use">
		<cfargument name="regex" 	  type="boolean" required="false" default="false" hint="Use regex or not">
		<!--- ************************************************************* --->
		<cfscript>
			var keyIndex = 1;
			var poolKeys = listToArray(getPoolKeys());
			var poolKeysLength = ArrayLen(poolKeys);
			var tester = 0;
			
			// Loop Through Metadata
			for (keyIndex=1; keyIndex lte poolKeysLength; keyIndex=keyIndex+1){
				
				// Using Regex?
				if( arguments.regex ){
					tester = reFindnocase(arguments.keySnippet, poolKeys[keyIndex]);
				}
				else{
					tester = findnocase(arguments.keySnippet, poolKeys[keyIndex]);
				}
				
				// Check if object still exists
				if( lookup(poolKeys[keyIndex]) ){
					// Override for Eternal Objects and the match keys
					if ( getObjectStore().getMetadataProperty(poolKeys[keyIndex],"Timeout") gt 0 and tester ){
						expireKey(poolKeys[keyIndex]);
					}
				}
			}//end key loops
		</cfscript>
	</cffunction>
	
	<!--- Get The Cache Item Types --->
	<cffunction name="getItemTypes" access="public" output="false" returntype="struct" hint="Get the item types of the cache. These are calculated according to internal coldbox entry prefixes">
		<cfscript>
		var x = 1;
		var itemList = getObjectStore().getObjectsKeyList();
		var itemTypes = Structnew();

		//Init types
		itemTypes.plugins = 0;
		itemTypes.handlers = 0;
		itemTypes.other = 0;
		itemTypes.ioc_beans = 0;
		itemTypes.interceptors = 0;
		itemTypes.events = 0;
		itemTypes.views = 0;

		//Sort the listing.
		itemList = listSort(itemList, "textnocase");

		//Count objects
		for (x=1; x lte listlen(itemList) ; x = x+1){
			if ( findnocase("cboxplugin", listGetAt(itemList,x)) )
				itemTypes.plugins = itemTypes.plugins + 1;
			else if ( findnocase("cboxhandler", listGetAt(itemList,x)) )
				itemTypes.handlers = itemTypes.handlers + 1;
			else if ( findnocase("cboxioc", listGetAt(itemList,x)) )
				itemTypes.ioc_beans = itemTypes.ioc_beans + 1;
			else if ( findnocase("cboxinterceptor", listGetAt(itemList,x)) )
				itemTypes.interceptors = itemTypes.interceptors + 1;
			else if ( findnocase("cboxevent", listGetAt(itemList,x)) )
				itemTypes.events = itemTypes.events + 1;
			else if ( findnocase("cboxview", listGetAt(itemList,x)) )
				itemTypes.views = itemTypes.views + 1;
			else
				itemTypes.other = itemTypes.other + 1;
		}
		return itemTypes;
		</cfscript>
	</cffunction>

<!------------------------------------------- ACCESSOR/MUTATORS ------------------------------------------->
	
	<!--- getObjectStore --->
	<cffunction name="getObjectStore" output="false" access="public" returntype="any" hint="If the cache provider implements it, this returns the cache's object store as type: coldbox.system.cache.store.IObjectStore" colddoc:generic="coldbox.system.cache.store.IObjectStore">
    	<cfreturn instance.objectStore>
	</cffunction>

	<!--- Get the Pool Metadata --->
	<cffunction name="getPoolMetadata" access="public" returntype="struct" output="false" hint="Get a copy of the pool's metadata structure">
		<cfargument name="deepCopy" type="boolean" required="false" default="true" hint="Deep copy of structure or by reference. Default is deep copy"/>
		<cfif arguments.deepCopy>
			<cfreturn duplicate(getObjectStore().getPoolMetadata())>
		<cfelse>
			<cfreturn getObjectStore().getPoolMetadata()>
		</cfif>
	</cffunction>
	
	<!--- Get the Pool Keys --->
	<cffunction name="getPoolKeys" access="public" returntype="array" output="false" hint="Get a listing of all the keys of the objects in the cache pool">
		<cfreturn getObjectStore().getPoolKeys()>
	</cffunction>

	<!--- Set The Eviction Policy --->
	<cffunction name="setEvictionPolicy" access="public" returntype="void" output="false" hint="You can now override the set eviction policy by programmatically sending it in.">
		<cfargument name="evictionPolicy" type="coldbox.system.cache.policies.AbstractEvictionPolicy" required="true">
		<cfset instance.evictionPolicy = arguments.evictionPolicy>
	</cffunction>
	
	<!--- Get the Java Runtime --->
	<cffunction name="getJavaRuntime" access="public" returntype="any" output="false" hint="Get the java runtime object for reporting purposes.">
		<cfreturn instance.javaRuntime>
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------->
	
	<!--- announceExpiration --->
	<cffunction name="announceExpiration" output="false" access="private" returntype="void" hint="Announce an Expiration">
		<cfargument name="objectKey" 			type="any"  	required="true" hint="The object cache key">
		<cfscript>
			var interceptData = structnew();
			// interceptData
			interceptData.cacheObjectKey = arguments.objectKey;
			// Execute afterCacheElementExpired Interception
			instance.controller.getInterceptorService().processState("afterCacheElementExpired",interceptData);
		</cfscript>
	</cffunction>
	
	<!--- Initialize our object cache pool --->
	<cffunction name="initPool" access="private" output="false" returntype="void" hint="Initialize and set the internal object Pool">
		<cfscript>
			instance.objectStore = CreateObject("component","coldbox.system.cache.ObjectPool").init();
		</cfscript>
	</cffunction>

	<!--- Threshold JVM Checks --->
	<cffunction name="ThresholdChecks" access="private" output="false" returntype="boolean" hint="JVM Threshold checks">
		<cfset var check = true>
		<cfset var jvmThreshold = 0>
		
		<cftry>
			<!--- Checks --->
			<cfif getCacheConfig().getFreeMemoryPercentageThreshold() neq 0>
				<cfset jvmThreshold = ( (instance.javaRuntime.getRuntime().freeMemory() / instance.javaRuntime.getRuntime().maxMemory() ) * 100 )>
				<cfset check = getCacheConfig().getFreeMemoryPercentageThreshold() lt jvmThreshold>				
			</cfif>
			<cfcatch type="any">
				<cfset check = true>
			</cfcatch>
		</cftry>
		
		<cfreturn check>
	</cffunction>

</cfcomponent>