<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date        :	January 18, 2007
Description :
	This is a cfc that handles caching of event handlers.

Dependencies :
 - Controller to get to dependencies
 - Interceptor Service for event model

----------------------------------------------------------------------->
<cfcomponent name="CacheManager" 
			 hint="Manages handler,plugin,custom plugin and object caching. It is thread safe and implements locking for you." 
			 output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	
	<cfscript>
		instance = structnew();
		
		// Cache Key prefixes. These are used by ColdBox For specific type saving
		this.VIEW_CACHEKEY_PREFIX 			= "cboxview_view-";
		this.EVENT_CACHEKEY_PREFIX 			= "cboxevent_event-";
		this.HANDLER_CACHEKEY_PREFIX 		= "cboxhandler_handler-";
		this.INTERCEPTOR_CACHEKEY_PREFIX 	= "cboxinterceptor_interceptor-";
		this.PLUGIN_CACHEKEY_PREFIX 		= "cboxplugin_plugin-";
		this.CUSTOMPLUGIN_CACHEKEY_PREFIX 	= "cboxplugin_customplugin-";
		this.CACHE_ID = hash(createObject('java','java.lang.System').identityHashCode(this));
	</cfscript>

	<cffunction name="init" access="public" output="false" returntype="CacheManager" hint="Constructor">
		<cfargument name="controller" type="any" required="true">
		<cfscript>
			// Set Controller Injection
			instance.controller = arguments.controller;
			// Logger object
			instance.logger = instance.controller.getLogBox().getLogger(this);
			// Runtime Java object
			instance.javaRuntime = CreateObject("java", "java.lang.Runtime");
			// Locking Timeout
			instance.lockTimeout = "15";
			// Event URL Facade Setup
			instance.eventURLFacade = CreateObject("component","coldbox.system.cache.archive.util.EventURLFacade").init(this);
			// Cache Stats
			instance.cacheStats = CreateObject("component","coldbox.system.cache.archive.util.CacheStats").init(this);
			// Set the NOTFOUND public constant
			this.NOT_FOUND = '_NOTFOUND_';		
			// Init the object Pool on instantiation 
			initPool();
			// Eviction Policy as struct
			instance.evictionPolicy = structnew();
			
			return this;
		</cfscript>
	</cffunction>

	<!--- Configure the Cache for Operation --->
	<cffunction name="configure" access="public" output="false" returntype="void" hint="Configures the cache for operation, sets the configuration object, sets and creates the eviction policy and clears the stats. If this method is not called, the cache is useless.">
		<!--- ************************************************************* --->
		<cfargument name="cacheConfig" type="coldbox.system.cache.archive.config.CacheConfig" required="true" hint="The configuration object">
		<!--- ************************************************************* --->
		<cfscript>		
			var oEvictionPolicy = 0;
				
			//set the config bean
			setCacheConfig(arguments.cacheConfig);
			
			//Reset the statistics.
			getCacheStats().clearStats();
			
			//Setup the eviction Policy to use
			try{
				oEvictionPolicy = CreateObject("component","coldbox.system.cache.archive.policies.#getCacheConfig().getEvictionPolicy()#").init(this);
			}
			Catch(Any e){
				getUtil().throwit('Error creating eviction policy','Error creating the eviction policy object: #e.message# #e.detail#','cacheManager.EvictionPolicyCreationException');	
			}
			
			// Save the Policy
			instance.evictionPolicy = oEvictionPolicy;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Lookup Multiple Keys --->
	<cffunction name="lookupMulti" access="public" output="false" returntype="struct" hint="The returned value is a structure of name-value pairs of all the keys that where found or not.">
		<!--- ************************************************************* --->
		<cfargument name="keys" 			type="string" required="true" hint="The comma delimited list of keys to lookup in the cache.">
		<cfargument name="prefix" 			type="string" required="false" default="" hint="A prefix to prepend to the keys">
		<!--- ************************************************************* --->
		<cfscript>
			var returnStruct = structnew();
			var x = 1;
			var thisKey = "";
			/* Clear Prefix */
			arguments.prefix = trim(arguments.prefix);
			
			/* Loop on Keys */
			for(x=1;x lte listLen(arguments.keys);x=x+1){
				thisKey = arguments.prefix & listGetAt(arguments.keys,x);
				returnStruct[thiskey] = lookup(thisKey);
			}
			
			/* Return Struct */
			return returnStruct;
		</cfscript>
	</cffunction>
	
	<!--- lookupQuiet --->
	<cffunction name="lookupQuiet" access="public" output="false" returntype="boolean" hint="For new COMPAT Mode only.">
		<!--- ************************************************************* --->
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object to lookup.">
		<!--- ************************************************************* --->
		<cfreturn lookup(arguments.objectKey)>
	</cffunction>
	
	<!--- Simple cache Lookup --->
	<cffunction name="lookup" access="public" output="false" returntype="boolean" hint="Check if an object is in cache, if not found it records a miss.">
		<!--- ************************************************************* --->
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object to lookup.">
		<!--- ************************************************************* --->
		<cfset var refLocal = structnew()>
		
		<cfset refLocal.needCleanup = false>
		<cfset refLocal.ObjectFound = false>
		<cfset refLocal.tmpObj = 0>
		
		<!--- Cleanup the key --->
		<cfset arguments.objectKey = lcase(trim(arguments.objectKey))>
		
		<cflock type="readonly" name="coldbox.cacheManager.#arguments.objectKey#" timeout="#instance.lockTimeout#" throwontimeout="true">
			<cfscript>
				// Check if in pool first
				if( getObjectPool().lookup(arguments.objectKey) ){
					// Get Object from cache
					refLocal.tmpObj = getobjectPool().get(arguments.objectKey);
					// Validate it
					if( not structKeyExists(refLocal, "tmpObj") ){
						refLocal.needCleanup = true;
						getCacheStats().miss();
					}
					else{
						// Object Found
						refLocal.ObjectFound = true;
					}					
				}// first lookup test
				else{
					// log miss
					getCacheStats().miss();
				}
			</cfscript>
		</cflock>
		
		<!--- Check if needs clearing --->
		<cfif refLocal.needCleanup>
			<cfset clearKey(arguments.objectKey)>
		</cfif>
		
		<cfreturn refLocal.ObjectFound>
	</cffunction>

	<!--- Get an object from the cache --->
	<cffunction name="get" access="public" output="false" returntype="any" hint="Get an object from cache. If it doesn't exist it returns the THIS.NOT_FOUND value">
		<!--- ************************************************************* --->
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object to lookup.">
		<!--- ************************************************************* --->
		<cfset var refLocal = structNew()>
		
		<!--- INit Vars --->
		<cfset refLocal.needCleanup = false>
		<cfset refLocal.tmpObj = 0>
		<cfset refLocal.targetObject = this.NOT_FOUND>
		
		<!--- Cleanup the key --->
		<cfset arguments.objectKey = lcase(trim(arguments.objectKey))>
		
		<cflock type="exclusive" name="coldbox.cacheManager.#arguments.objectKey#" timeout="#instance.lockTimeout#" throwontimeout="true">
			<cfscript>
				// Check if in pool first 
				if( getObjectPool().lookup(arguments.objectKey) ){
					// Get Object from cache
					refLocal.tmpObj = getobjectPool().get(arguments.objectKey);
					// Validate it 
					if( not structKeyExists(refLocal,"tmpObj") ){
						refLocal.needCleanup = true;
						getCacheStats().miss();
					}
					else{
						refLocal.targetObject = refLocal.tmpObj;
						getCacheStats().hit();
					}
				}
				else{
					// log miss
					getCacheStats().miss();
				}
			</cfscript>
		</cflock>
		
		<!--- Check if needs clearing --->
		<cfif refLocal.needCleanup>
			<cfset clearKey(arguments.objectKey)>
		</cfif>
		
		<!--- Return Target Object --->
		<cfreturn refLocal.targetObject>
	</cffunction>
	
	<!--- Get multiple objects from the cache --->
	<cffunction name="getMulti" access="public" output="false" returntype="struct" hint="The returned value is a structure of name-value pairs of all the keys that where found. Not found values will not be returned">
		<!--- ************************************************************* --->
		<cfargument name="keys" 			type="string" required="true" hint="The comma delimited list of keys to retrieve from the cache.">
		<cfargument name="prefix" 			type="string" required="false" default="" hint="A prefix to prepend to the keys">
		<!--- ************************************************************* --->
		<cfscript>
			var returnStruct = structnew();
			var x = 1;
			var thisKey = "";
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
				return getObjectPool().getObjectMetadata(arguments.objectKey);
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
		<cfargument name="objectKey" 			type="any"  required="true" hint="The object cache key">
		<cfargument name="myObject"				type="any" 	required="true" hint="The object to cache">
		<cfargument name="timeout"				type="any"  required="false" default="" hint="Timeout in minutes. If timeout = 0 then object never times out. If timeout is blank, then timeout will be inherited from framework.">
		<cfargument name="lastAccessTimeout"	type="any"  required="false" default="" hint="Last Access Timeout in minutes. If timeout is blank, then timeout will be inherited from framework.">
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
		<cflock type="exclusive" name="coldbox.cacheManager.#arguments.objectKey#" timeout="#instance.lockTimeout#" throwontimeout="true">
			<cfset getobjectPool().set(arguments.objectKey,arguments.myObject,arguments.timeout,arguments.lastAccessTimeout)>
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
	<cffunction name="clearKey" access="public" output="false" returntype="boolean" hint="Clears an object from the cache by using its cache key. Returns false if object was not removed or did not exist anymore">
		<!--- ************************************************************* --->
		<cfargument name="objectKey" type="string" required="true" hint="The key the object was stored under.">
		<!--- ************************************************************* --->
		<cfset var clearCheck = false>
		<cfset var interceptMetadata = structnew()>
		
		<!--- Cleanup the key --->
		<cfset arguments.objectKey = lcase(trim(arguments.objectKey))>
		
		<!--- Remove Object --->
		<cflock type="exclusive" name="coldbox.cacheManager.#arguments.objectKey#" timeout="#instance.lockTimeout#" throwontimeout="true">
			<cfif getobjectPool().lookup(arguments.objectKey)>
				<cfset clearCheck = getobjectPool().clearKey(arguments.objectKey)>
			</cfif>
		</cflock>
		<!--- Only fire if object removed. --->
		<cfif clearCheck>
			<!--- InterceptMetadata --->
			<cfset interceptMetadata.cacheObjectKey = arguments.objectKey>
			<!--- Execute afterCacheElementInsert Interception --->
			<cfset instance.controller.getInterceptorService().processState("afterCacheElementRemoved",interceptMetadata)>
		</cfif>
		
		<cfreturn clearCheck>
	</cffunction>
	
	<!--- Clear an object from the cache --->
	<cffunction name="clearKeyMulti" access="public" output="false" returntype="struct" hint="Clears objects from the cache by using its cache key. The returned value is a structure of name-value pairs of all the keys that where removed from the operation.">
		<!--- ************************************************************* --->
		<cfargument name="keys" 		type="string" required="true" hint="The comma-delimmitted list of keys to remove.">
		<cfargument name="prefix" 		type="string" required="false" default="" hint="A prefix to prepend to the keys">
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
				returnStruct[thiskey] = clearKey(thisKey);
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
			var poolKeys = listSort(getPoolKeys(),"textnocase");
			var poolKeysLength = listlen(poolKeys);
			var x = 1;
			var tester = 0;
			var thisKey = "";
			
			//Find all the event keys.
			for(x=1; x lte poolKeysLength; x=x+1){
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
					clearKey( thisKey );
				}
			}
		</cfscript>
	</cffunction>
	
	<!--- Clear an event --->
	<cffunction name="clearEvent" access="public" output="false" returntype="void" hint="Clears all the event permutations from the cache according to snippet and querystring. Be careful when using incomplete event name with query strings as partial event names are not guaranteed to match with query string permutations">
		<!--- ************************************************************* --->
		<cfargument name="eventsnippet" type="string" 	required="true" hint="The event snippet to clear on. Can be partial or full">
		<cfargument name="queryString" 	type="string" 	required="false" default="" hint="If passed in, it will create a unique hash out of it. For purging purposes"/>
		<!--- ************************************************************* --->
		<cfscript>
			//.*- = the cache suffix and appendages for regex to match
			var cacheKey = this.EVENT_CACHEKEY_PREFIX & replace(arguments.eventsnippet,".","\.","all") & ".*-.*";
														  
			//Check if we are purging with query string
			if( len(arguments.queryString) neq 0 ){
				cacheKey = cacheKey & "-" & getEventURLFacade().buildHash(arguments.queryString);
			}
			
			// Clear All Events by Criteria
			clearByKeySnippet(keySnippet=cacheKey,regex=true);
		</cfscript>
	</cffunction>
	
	<!--- Clear an event Multi --->
	<cffunction name="clearEventMulti" access="public" output="false" returntype="void" hint="Clears all the event permutations from the cache according to the list of snippets and querystrings. Be careful when using incomplete event name with query strings as partial event names are not guaranteed to match with query string permutations">
		<!--- ************************************************************* --->
		<cfargument name="eventsnippets"    type="string"   required="true"  hint="The comma-delimmitted list event snippet to clear on. Can be partial or full">
		<cfargument name="queryString"      type="string"   required="false" default="" hint="The comma-delimmitted list of queryStrings passed in. If passed in, it will create a unique hash out of it. For purging purposes.  If passed in the list length must be equal to the list length of the event snippets passed in."/>
		<!--- ************************************************************* --->
		<cfscript>
			var regexCacheKey = "";
			var x 			  = 1;
			var eventsnippet  = "";
			var cacheKey	  = "";
			
			// Loop on the incoming snippets
			for(x=1;x lte listLen(arguments.eventsnippets);x=x+1){
			      //.*- = the cache suffix and appendages for regex to match
			      cacheKey = this.EVENT_CACHEKEY_PREFIX & replace(listGetAt(arguments.eventsnippets,x),".","\.","all") & "-.*";
			      //Check if we are purging with query string
			      if( len(arguments.queryString) neq 0 ){
			            cacheKey = cacheKey & "-" & getEventURLFacade().buildHash(listGetAt(arguments.queryString,x));
			      }
			      regexCacheKey = regexCacheKey & cacheKey;
			      //check that we aren't at the end of the list, and the | char to the regex as the OR statement
			      if (x NEQ listLen(arguments.eventsnippets)) {
			            regexCacheKey = regexCacheKey & "|";
			      }
			}
			// Clear All Events by Criteria
			clearByKeySnippet(keySnippet=regexCacheKey,regex=true);
		</cfscript>
      </cffunction>
	
	<!--- Clear All the Events form the cache --->
	<cffunction name="clearAllEvents" access="public" output="false" returntype="void" hint="Clears all events from the cache.">
		<cfscript>
			var cacheKey = this.EVENT_CACHEKEY_PREFIX;
			
			// Clear All Events
			clearByKeySnippet(keySnippet=cacheKey,regex=false);
		</cfscript>
	</cffunction>

	<!--- clear View --->
	<cffunction name="clearView" output="false" access="public" returntype="void" hint="Clears all view name permutations from the cache according to the view name.">
		<!--- ************************************************************* --->
		<cfargument name="viewSnippet"  required="true" type="string" hint="The view name snippet to purge from the cache">
		<!--- ************************************************************* --->
		<cfscript>
			var cacheKey = this.VIEW_CACHEKEY_PREFIX & arguments.viewSnippet;
			
			// Clear All View snippets
			clearByKeySnippet(keySnippet=cacheKey,regex=false);
		</cfscript>
	</cffunction>

	<!--- Clear All The Views from the Cache. --->
	<cffunction name="clearAllViews" access="public" output="false" returntype="void" hint="Clears all views from the cache.">
		<cfscript>
			var cacheKey = this.VIEW_CACHEKEY_PREFIX;
			
			// Clear All the views
			clearByKeySnippet(keySnippet=cacheKey,regex=false);
		</cfscript>
	</cffunction>

	<!--- Clear The Pool --->
	<cffunction name="clear" access="public" output="false" returntype="void" hint="Clears the entire object cache and recreates the object pool and statistics. Call from a non-cached object or you will get 500 NULL errors, VERY VERY BAD!!. TRY NOT TO USE THIS METHOD">
		<cfscript>
			structDelete(variables,"objectPool");
			initPool();
			getCacheStats().clearStats();
		</cfscript>			
	</cffunction>

	<!--- Get the Cache Size --->
	<cffunction name="getSize" access="public" output="false" returntype="numeric" hint="Get the cache's size in items">
		<cfreturn getObjectPool().getSize()>
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
		<cflock type="exclusive" name="coldbox.cacheManager.#this.CACHE_ID#.reap" timeout="#instance.lockTimeout#">
		<cfscript>
			// Expire and cleanup if in frequency
			if ( dateDiff("n", getCacheStats().getlastReapDatetime(), now() ) gte ccBean.getReapFrequency() ){
				
				// Init Ref Key Vars
				reflocal.softRef = getObjectPool().getReferenceQueue().poll();
				
				// Let's reap the garbage collected soft references first before expriring
				while( StructKeyExists(reflocal, "softRef") ){
					// Clean if it still exists
					if( getObjectPool().softRefLookup(reflocal.softRef) ){
						clearKey( getObjectPool().getSoftRefKey(refLocal.softRef) );
						// GC Collection Hit
						getCacheStats().gcHit();
					}
					// Poll Again
					reflocal.softRef = getObjectPool().getReferenceQueue().poll();
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
		<cfargument name="objectKey" type="string" required="true">
		<!--- ************************************************************* --->
		<cfscript>
			getObjectPool().expireObject(lcase(trim(arguments.objectKey)));
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
					if ( getObjectPool().getMetadataProperty(poolKeys[keyIndex],"Timeout") gt 0 and tester ){
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
		var itemList = getObjectPool().getObjectsKeyList();
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

	<!--- get Event URL Facade --->
	<cffunction name="geteventURLFacade" access="public" returntype="coldbox.system.cache.archive.util.EventURLFacade" output="false" hint="Get the event url facade object.">
		<cfreturn instance.eventURLFacade>
	</cffunction>

	<!--- The cache stats --->
	<cffunction name="getCacheStats" access="public" returntype="coldbox.system.cache.archive.util.CacheStats" output="false" hint="Return the cache stats object.">
		<cfreturn instance.cacheStats>
	</cffunction>
	
	<!--- The cache Config Bean --->
	<cffunction name="setCacheConfig" access="public" returntype="void" output="false" hint="Set & Override the cache configuration bean. You can use this to programmatically alter the cache.">
		<cfargument name="CacheConfig" type="coldbox.system.cache.archive.config.CacheConfig" required="true">
		<cfset instance.CacheConfig = arguments.CacheConfig>
	</cffunction>
	<cffunction name="getCacheConfig" access="public" returntype="coldbox.system.cache.archive.config.CacheConfig" output="false" hint="Get the current cache configuration bean.">
		<cfreturn instance.CacheConfig >
	</cffunction>
	
	<!--- Get the internal object pool --->
	<cffunction name="getObjectPool" access="public" returntype="any" output="false" hint="Get the internal object pool: coldbox.system.cache.objectPool or MTobjectPool">
		<cfreturn instance.objectPool >
	</cffunction>

	<!--- Get the Pool Metadata --->
	<cffunction name="getPoolMetadata" access="public" returntype="struct" output="false" hint="Get a copy of the pool's metadata structure">
		<cfargument name="deepCopy" type="boolean" required="false" default="true" hint="Deep copy of structure or by reference. Default is deep copy"/>
		<cfif arguments.deepCopy>
			<cfreturn duplicate(getObjectPool().getPoolMetadata())>
		<cfelse>
			<cfreturn getObjectPool().getPoolMetadata()>
		</cfif>
	</cffunction>
	
	<!--- Get the Pool Keys --->
	<cffunction name="getPoolKeys" access="public" returntype="string" output="false" hint="Get a listing of all the keys of the objects in the cache pool">
		<cfreturn getObjectPool().getPoolKeys()>
	</cffunction>

	<!--- Set The Eviction Policy --->
	<cffunction name="setEvictionPolicy" access="public" returntype="void" output="false" hint="You can now override the set eviction policy by programmatically sending it in.">
		<cfargument name="evictionPolicy" type="coldbox.system.cache.archive.policies.AbstractEvictionPolicy" required="true">
		<cfset instance.evictionPolicy = arguments.evictionPolicy>
	</cffunction>
	
	<!--- Get the Java Runtime --->
	<cffunction name="getJavaRuntime" access="public" returntype="any" output="false" hint="Get the java runtime object for reporting purposes.">
		<cfreturn instance.javaRuntime>
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------->
	
	<!--- announceExpiration --->
	<cffunction name="announceExpiration" output="false" access="private" returntype="void" hint="Announce an Expiration">
		<cfargument name="objectKey" type="string" required="true" hint="The object key to announce expiration"/>
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
			instance.objectPool = CreateObject("component","coldbox.system.cache.archive.ObjectPool").init();
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

	<!--- Get Util --->
	<cffunction name="getUtil" access="private" output="false" returntype="coldbox.system.core.util.Util" hint="Create and return a util object">
		<cfreturn CreateObject("component","coldbox.system.core.util.Util")/>
	</cffunction>

</cfcomponent>