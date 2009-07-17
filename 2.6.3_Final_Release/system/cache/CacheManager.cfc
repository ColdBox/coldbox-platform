<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date        :	January 18, 2007
Description :
	This is a cfc that handles caching of event handlers.

Dependencies :
 - Controller to get to dependencies
 - Interceptor Service for event model
 - Handler Service for event caching

Modification History:
01/18/2007 - Created

----------------------------------------------------------------------->
<cfcomponent name="CacheManager" 
			 hint="Manages handler,plugin,custom plugin and object caching. It is thread safe and implements locking for you." 
			 output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	
	<cfscript>
		instance = structnew();
		
		/* Cache Key prefixes. These are used by ColdBox For specific type saving */
		this.VIEW_CACHEKEY_PREFIX = "cboxview_view-";
		this.EVENT_CACHEKEY_PREFIX = "cboxevent_event-";
		this.HANDLER_CACHEKEY_PREFIX = "cboxhandler_handler-";
		this.INTERCEPTOR_CACHEKEY_PREFIX = "cboxinterceptor_interceptor-";
		this.PLUGIN_CACHEKEY_PREFIX = "cboxplugin_plugin-";
		this.CUSTOMPLUGIN_CACHEKEY_PREFIX = "cboxplugin_customplugin-";
	</cfscript>

	<cffunction name="init" access="public" output="false" returntype="CacheManager" hint="Constructor">
		<cfargument name="controller" type="any" required="true">
		<cfscript>
			/* Set Controller Injection */
			instance.controller = arguments.controller;
			/* Runtime Java object */
			instance.javaRuntime = CreateObject("java", "java.lang.Runtime");
			/* Locking Timeout */
			instance.lockTimeout = "15";
			/* Event URL Facade Setup */
			instance.eventURLFacade = CreateObject("component","coldbox.system.cache.util.EventURLFacade").init(this);
			/* Cache Stats */
			instance.cacheStats = CreateObject("component","coldbox.system.cache.util.CacheStats").init(this);
			/* Set the NOTFOUND public constant */
			this.NOT_FOUND = '_NOTFOUND_';		
			/* Init the object Pool on instantiation */
			initPool();
			/* return Cache Manager reference */
			return this;
		</cfscript>
	</cffunction>

	<!--- Configure the Cache for Operation --->
	<cffunction name="configure" access="public" output="false" returntype="void" hint="Configures the cache for operation, sets the configuration object, sets and creates the eviction policy and clears the stats. If this method is not called, the cache is useless.">
		<!--- ************************************************************* --->
		<cfargument name="cacheConfigBean" type="coldbox.system.cache.config.CacheConfigBean" required="true" hint="The configuration object">
		<!--- ************************************************************* --->
		<cfscript>		
			var oEvictionPolicy = 0;
				
			//set the config bean
			setCacheConfigBean(arguments.cacheConfigBean);
			//Reset the statistics.
			getCacheStats().clearStats();
			
			//Setup the eviction Policy to use
			try{
				oEvictionPolicy = CreateObject("component","coldbox.system.cache.policies.#getCacheConfigBean().getCacheEvictionPolicy()#").init(this);
			}
			Catch(Any e){
				getUtil().throwit('Error creating eviction policy','Error creating the eviction policy object: #e.message# #e.detail#','cacheManager.EvictionPolicyCreationException');	
			}
			/* Save the Policy */
			instance.evictionPolicy = oEvictionPolicy;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Simple cache Lookup --->
	<cffunction name="lookup" access="public" output="false" returntype="boolean" hint="Check if an object is in cache, if not found it records a miss.">
		<!--- ************************************************************* --->
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object to lookup.">
		<!--- ************************************************************* --->
		<cfset var refLocal = structnew()>
		
		<!--- Init some vars --->
		<cfset refLocal.needCleanup = false>
		<cfset refLocal.ObjectFound = false>
		<cfset refLocal.tmpObj = 0>
		
		<cflock type="readonly" name="coldbox.cacheManager.#arguments.objectKey#" timeout="#instance.lockTimeout#" throwontimeout="true">
			<cfscript>
				/* Check if in pool first */
				if( getObjectPool().lookup(arguments.objectKey) ){
					/* Get Object from cache */
					refLocal.tmpObj = getobjectPool().get(arguments.objectKey);
					/* Validate it */
					if( not structKeyExists(refLocal, "tmpObj") ){
						refLocal.needCleanup = true;
						getCacheStats().miss();
					}
					else{
						/* Object Found */
						refLocal.ObjectFound = true;
					}					
				}// first lookup test
				else{
					/* log miss */
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
	
		<cflock type="exclusive" name="coldbox.cacheManager.#arguments.objectKey#" timeout="#instance.lockTimeout#" throwontimeout="true">
			<cfscript>
				/* Check if in pool first */
				if( getObjectPool().lookup(arguments.objectKey) ){
					/* Get Object from cache */
					refLocal.tmpObj = getobjectPool().get(arguments.objectKey);
					/* Validate it */
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
					/* log miss */
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
			/* Clear Prefix */
			arguments.prefix = trim(arguments.prefix);
			
			/* Loop on Keys */
			for(x=1;x lte listLen(arguments.keys);x=x+1){
				thisKey = arguments.prefix & listGetAt(arguments.keys,x);
				if( lookup(thisKey) ){
					returnStruct[thiskey] = get(thisKey);
				}
			}
			
			/* Return Struct */
			return returnStruct;
		</cfscript>
	</cffunction>
	
	<!--- getCachedObjectMetadata --->
	<cffunction name="getCachedObjectMetadata" output="false" access="public" returntype="struct" hint="Get the cached object's metadata structure. If the object does not exist, it returns an empty structure.">
		<!--- ************************************************************* --->
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object to lookup its metadata">
		<!--- ************************************************************* --->
		<cfscript>
			/* Check if in the pool first */
			if( getObjectPool().lookup(arguments.objectKey) ){
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
			/* Clear Prefix */
			arguments.prefix = trim(arguments.prefix);
			
			/* Loop on Keys */
			for(x=1;x lte listLen(arguments.keys);x=x+1){
				thisKey = arguments.prefix & listGetAt(arguments.keys,x);
				if( lookup(thisKey) ){
					returnStruct[thiskey] = getCachedObjectMetadata(thisKey);
				}
			}
			
			/* Return Struct */
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
			/* Clear Prefix */
			arguments.prefix = trim(arguments.prefix);
			/* Loop Over mappings */
			for(key in arguments.mapping){
				/* Cache theses puppies */
				set(objectKey=arguments.prefix & key,MyObject=arguments.mapping[key],Timeout=arguments.timeout,LastAccessTimeout=arguments.LastAccessTimeout);
			}
		</cfscript>
	</cffunction>
	
	<!--- Set an Object in the cache --->
	<cffunction name="set" access="public" output="false" returntype="boolean" hint="sets an object in cache. Sets might be expensive. If the JVM threshold is used and it has been reached, the object won't be cached. If the pool is at maximum it will expire using its eviction policy and still cache the object. Cleanup will be done later.">
		<!--- ************************************************************* --->
		<cfargument name="objectKey" 			type="any"  required="true" hint="The object cache key">
		<cfargument name="MyObject"				type="any" 	required="true" hint="The object to cache">
		<cfargument name="Timeout"				type="any"  required="false" default="" hint="Timeout in minutes. If timeout = 0 then object never times out. If timeout is blank, then timeout will be inherited from framework.">
		<cfargument name="LastAccessTimeout"	type="any"  required="false" default="" hint="Last Access Timeout in minutes. If timeout is blank, then timeout will be inherited from framework.">
		<!--- ************************************************************* --->
		<!---JVM Threshold Checks --->
		<cfset var isJVMSafe = ThresholdChecks()>
		<cfset var ccBean = getCacheConfigBean()>
		<cfset var interceptMetadata = structnew()>
		
		<!--- Clean Arguments --->
		<cfset arguments.objectKey = trim(arguments.objectKey)>
		<cfset arguments.Timeout = trim(arguments.Timeout)>
		<cfset arguments.LastAccessTimeout = trim(arguments.LastAccessTimeout)>
		
		<!--- JVMThreshold Check if enabled. --->
		<cfif ccBean.getCacheFreeMemoryPercentageThreshold() neq 0 and isJVMSafe eq false>
			<!--- Evict Using Policy --->
			<cfset instance.evictionPolicy.execute()>
			<!--- Do another Check, just in case --->
			<cfset isJVMSafe = ThresholdChecks()>
		</cfif>
		<!--- Check for max objects reached --->
		<cfif ccBean.getCacheMaxObjects() neq 0 and getSize() gte ccBean.getCacheMaxObjects()>
			<!--- Evict Using Policy --->
			<cfset instance.evictionPolicy.execute()>
		</cfif>
		
		<!--- Check if the JVM is safe for caching, if not, don't cache. --->
		<cfif ccBean.getCacheFreeMemoryPercentageThreshold() eq 0 or isJVMSafe>
			
			<!--- Test Timeout Argument, if false, then inherit framework's timeout --->
			<cfif arguments.Timeout eq "" or not isNumeric(arguments.Timeout) or arguments.Timeout lt 0>
				<cfset arguments.Timeout = ccBean.getCacheObjectDefaultTimeout()>
			</cfif>
			
			<!--- Test the Last Access Timeout --->
			<cfif arguments.LastAccessTimeout eq "" or not isNumeric(arguments.LastAccessTimeout) or arguments.LastAccessTimeout lte 0>
				<cfset arguments.LastAccessTimeout = ccBean.getCacheObjectDefaultLastAccessTimeout()>
			</cfif>
			
			<!--- Set object in Cache --->
			<cflock type="exclusive" name="coldbox.cacheManager.#arguments.objectKey#" timeout="#instance.lockTimeout#" throwontimeout="true">
				<cfset getobjectPool().set(arguments.objectKey,arguments.MyObject,arguments.Timeout,arguments.LastAccessTimeout)>
			</cflock>
			
			<!--- InterceptMetadata --->
			<cfset interceptMetadata.cacheObjectKey = arguments.objectKey>
			<cfset interceptMetadata.cacheObjectTimeout = arguments.Timeout>
			<cfset interceptMetadata.cacheObjectLastAccessTimeout = arguments.LastAccessTimeout>
			
			<!--- Execute afterCacheElementInsert Interception --->
			<cfset instance.controller.getInterceptorService().processState("afterCacheElementInsert",interceptMetadata)>				
			
			<!--- Return True --->
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>

	<!--- Clear an object from the cache --->
	<cffunction name="clearKey" access="public" output="false" returntype="boolean" hint="Clears an object from the cache by using its cache key. Returns false if object was not removed or did not exist anymore">
		<!--- ************************************************************* --->
		<cfargument name="objectKey" type="string" required="true" hint="The key the object was stored under.">
		<!--- ************************************************************* --->
		<cfset var ClearCheck = false>
		<cfset var interceptMetadata = structnew()>
		
		<!--- Remove Object --->
		<cflock type="exclusive" name="coldbox.cacheManager.#arguments.objectKey#" timeout="#instance.lockTimeout#" throwontimeout="true">
			<cfif getobjectPool().lookup(arguments.objectKey)>
				<cfset ClearCheck = getobjectPool().clearKey(arguments.objectKey)>
			</cfif>
		</cflock>
		<!--- Only fire if object removed. --->
		<cfif ClearCheck>
			<!--- InterceptMetadata --->
			<cfset interceptMetadata.cacheObjectKey = arguments.objectKey>
			<!--- Execute afterCacheElementInsert Interception --->
			<cfset instance.controller.getInterceptorService().processState("afterCacheElementRemoved",interceptMetadata)>
		</cfif>
		
		<cfreturn ClearCheck>
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
			/* Clear Prefix */
			arguments.prefix = trim(arguments.prefix);
			
			/* Loop on Keys */
			for(x=1;x lte listLen(arguments.keys);x=x+1){
				thisKey = arguments.prefix & listGetAt(arguments.keys,x);
				returnStruct[thiskey] = clearKey(thisKey);
			}
			
			/* Return Struct */
			return returnStruct;
		</cfscript>
	</cffunction>
	
	<!--- Clear By Key Snippet --->
	<cffunction name="clearByKeySnippet" access="public" returntype="void" hint="Clears keys using the passed in object key snippet" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="keySnippet"  	type="string"  required="true"  hint="the cache key snippet to use">
		<cfargument name="regex" 		type="boolean" required="false" default="false" hint="Use regex or not">
		<cfargument name="async" 		type="boolean" required="false" default="true" hint="Run asynchronously or not"/>
		<!--- ************************************************************* --->
		<cfscript>
			var poolKeys = listSort(structKeyList(getObjectPool().getpool_metadata()),"textnocase");
			var poolKeysLength = listlen(poolKeys);
			var x = 1;
			var tester = 0;
			var thisKey = "";
			
			//Find all the event keys.
			for(x=1; x lte poolKeysLength; x=x+1){
				/* Get List Value */
				thisKey = listGetAt(poolKeys,x);
				/* Using Regex */
				if( arguments.regex ){
					tester = refindnocase( arguments.keySnippet, thisKey );
				}
				else{
					tester = findnocase( arguments.keySnippet, thisKey );
				}
				/* Test Evaluation */
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
		<cfargument name="async" 		type="boolean"  required="false" default="true" hint="Run asynchronously or not"/>
		<!--- ************************************************************* --->
		<cfscript>
			//.*- = the cache suffix and appendages for regex to match
			var cacheKey = this.EVENT_CACHEKEY_PREFIX & replace(arguments.eventsnippet,".","\.","all") & ".*";
														  
			//Check if we are purging with query string
			if( len(arguments.queryString) neq 0 ){
				cacheKey = cacheKey & "-" & getEventURLFacade().buildHash(arguments.queryString);
			}
			
			/* Clear All Events by Criteria */
			clearByKeySnippet(keySnippet=cacheKey,regex=true,async=false);
		</cfscript>
	</cffunction>
	
	<!--- Clear All the Events form the cache --->
	<cffunction name="clearAllEvents" access="public" output="false" returntype="void" hint="Clears all events from the cache.">
		<!--- ************************************************************* --->
		<cfargument name="async" 		type="boolean"  required="false" default="true" hint="Run asynchronously or not"/>
		<!--- ************************************************************* --->
		<cfscript>
			var cacheKey = this.EVENT_CACHEKEY_PREFIX;
			
			/* Clear All Events */
			clearByKeySnippet(keySnippet=cacheKey,regex=false,async=false);
		</cfscript>
	</cffunction>

	<!--- clear View --->
	<cffunction name="clearView" output="false" access="public" returntype="void" hint="Clears all view name permutations from the cache according to the view name.">
		<!--- ************************************************************* --->
		<cfargument name="viewSnippet"  required="true" type="string" hint="The view name snippet to purge from the cache">
		<cfargument name="async" 		type="boolean"  required="false" default="true" hint="Run asynchronously or not"/>
		<!--- ************************************************************* --->
		<cfscript>
			var cacheKey = this.VIEW_CACHEKEY_PREFIX & arguments.viewSnippet;
			
			/* Clear All View snippets */
			clearByKeySnippet(keySnippet=cacheKey,regex=false,async=false);
		</cfscript>
	</cffunction>

	<!--- Clear All The Views from the Cache. --->
	<cffunction name="clearAllViews" access="public" output="false" returntype="void" hint="Clears all views from the cache.">
		<!--- ************************************************************* --->
		<cfargument name="async" 		type="boolean"  required="false" default="true" hint="Run asynchronously or not"/>
		<!--- ************************************************************* --->
		<cfscript>
			var cacheKey = this.VIEW_CACHEKEY_PREFIX;
			
			/* Clear All the views */
			clearByKeySnippet(keySnippet=cacheKey,regex=false,async=false);
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
			var poolStruct = "";
			var poolKeys = "";
			var poolKeysLength = 0;
			var thisKey = "";
			var ccBean = getCacheConfigBean();
			var reflocal = structNew();
			
			/* Expire and cleanup if in frequency */
			if ( dateDiff("n", getCacheStats().getlastReapDatetime(), now() ) gte ccBean.getCacheReapFrequency() ){
				
				/* Init Ref Key Vars */
				reflocal.softRef = getObjectPool().getReferenceQueue().poll();
				
				/* Let's reap the garbage collected soft references first before expriring */
				while( StructKeyExists(reflocal, "softRef") ){
					/* Clean if it still exists */
					if( getObjectPool().softRefLookup(reflocal.softRef) ){
						clearKey( getObjectPool().getSoftRefKey(refLocal.softRef) );
						/* GC Collection Hit */
						getCacheStats().gcHit();
					}
					/* Poll Again */
					reflocal.softRef = getObjectPool().getReferenceQueue().poll();
				}
				
				/* Let's Get our reaping vars ready */
				poolStruct = getObjectPool().getpool_metadata();
				poolKeys = listToArray(structKeyList(poolStruct));
				poolKeysLength = ArrayLen(poolKeys);
				
				//Loop Through Metadata
				for (keyIndex=1; keyIndex lte poolKeysLength; keyIndex=keyIndex+1){
					//This Key to check
					thisKey = poolKeys[keyIndex];
					//Reap only non-eternal objects that have timeous gt 0
					if ( poolStruct[thisKey].Timeout gt 0 ){
						//Check for creation timeouts and clear
						if ( dateDiff("n", poolStruct[thisKey].created, now() ) gte poolStruct[thisKey].Timeout ){
							/* Clear The Key */
							clearKey(thisKey);
							/* Announce Expiration */
							announceExpiration(thisKey);
							continue;
						}
						//Check for last accessed timeouts. If object has not been accessed in the default span
						if ( ccBean.getCacheUseLastAccessTimeouts() and 
						     dateDiff("n", poolStruct[thisKey].lastAccesed, now() ) gte poolStruct[thisKey].LastAccessTimeout ){
							/* Clear the Key */
							clearKey(thisKey);
							/* Announce Expiration */
							announceExpiration(thisKey);
							continue;
						}
					}//end timeout gt 0
				}//end looping over keys
				
				//Reaping about to start, set new reaping date.
				getCacheStats().setlastReapDatetime( now() );
								
			}// end reaping frequency check			
		</cfscript>
	</cffunction>
	
	<!--- Expire All Objects --->
	<cffunction name="expireAll" access="public" returntype="void" hint="Expire All Objects. Use this instead of clear() from within handlers or any cached object, this sets the metadata for the objects to expire in the next request. Note that this is not an inmmediate expiration. Clear should only be used from outside a cached object" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="async" 		type="boolean" required="false" default="true" hint="Run asynchronously or not"/>
		<!--- ************************************************************* --->
		<cfscript>
			/* Expire All Objects */
			expireByKeySnippet(keySnippet=".*",regex=true,async=false);
		</cfscript>
	</cffunction>
	
	<!--- Expire an Object --->
	<cffunction name="expireKey" access="public" returntype="void" hint="Expire an Object. Use this instead of clearKey() from within handlers or any cached object, this sets the metadata for the objects to expire in the next request. Note that this is not an inmmediate expiration. Clear should only be used from outside a cached object" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="objectKey" type="string" required="true">
		<cfargument name="async" 	 type="boolean" required="false" default="true" hint="Run asynchronously or not"/>
		<!--- ************************************************************* --->
		<cfscript>
			/* Expire this object */
			expireByKeySnippet(keySnippet=arguments.objectKey,regex=false,async=false);
		</cfscript>
	</cffunction>
	
	<!--- Expire an Object --->
	<cffunction name="expireByKeySnippet" access="public" returntype="void" hint="Same as expireKey but can touch multiple objects depending on the keysnippet that is sent in." output="false" >
		<!--- ************************************************************* --->
		<cfargument name="keySnippet" type="string"  required="true" hint="The key snippet to use">
		<cfargument name="regex" 	  type="boolean" required="false" default="false" hint="Use regex or not">
		<cfargument name="async" 	  type="boolean" required="false" default="true" hint="Run asynchronously or not"/>
		<!--- ************************************************************* --->
		<cfscript>
			var keyIndex = 1;
			var poolKeys = listToArray(structKeyList(getObjectPool().getpool_metadata()));
			var poolKeysLength = ArrayLen(poolKeys);
			var tester = 0;
			
			/* Loop Through Metadata */
			for (keyIndex=1; keyIndex lte poolKeysLength; keyIndex=keyIndex+1){
				/* Using Regex? */
				if( arguments.regex ){
					tester = reFindnocase(arguments.keySnippet, poolKeys[keyIndex]);
				}
				else{
					tester = findnocase(arguments.keySnippet, poolKeys[keyIndex]);
				}
				
				/* Override for Eternal Objects and we match keys */
				if ( getObjectPool().getMetadataProperty(poolKeys[keyIndex],"Timeout") gt 0 and tester ){
					getObjectPool().setMetadataProperty(poolKeys[keyIndex],"Timeout", 1);
					getObjectPool().setMetadataProperty(poolKeys[keyIndex],"created", dateadd("n",-5,now()) );
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
	<cffunction name="geteventURLFacade" access="public" returntype="coldbox.system.cache.util.EventURLFacade" output="false" hint="Get the event url facade object.">
		<cfreturn instance.eventURLFacade>
	</cffunction>

	<!--- The cache stats --->
	<cffunction name="getCacheStats" access="public" returntype="coldbox.system.cache.util.CacheStats" output="false" hint="Return the cache stats object.">
		<cfreturn instance.cacheStats>
	</cffunction>
	
	<!--- The cache Config Bean --->
	<cffunction name="setCacheConfigBean" access="public" returntype="void" output="false" hint="Set & Override the cache configuration bean. You can use this to programmatically alter the cache.">
		<cfargument name="CacheConfigBean" type="coldbox.system.cache.config.CacheConfigBean" required="true">
		<cfset instance.CacheConfigBean = arguments.CacheConfigBean>
	</cffunction>
	<cffunction name="getCacheConfigBean" access="public" returntype="coldbox.system.cache.config.CacheConfigBean" output="false" hint="Get the current cache configuration bean.">
		<cfreturn instance.CacheConfigBean >
	</cffunction>
	
	<!--- Get the internal object pool --->
	<cffunction name="getObjectPool" access="public" returntype="any" output="false" hint="Get the internal object pool: coldbox.system.cache.objectPool or MTobjectPool">
		<cfreturn instance.objectPool >
	</cffunction>

	<!--- Get the Pool Metadata --->
	<cffunction name="getpool_metadata" access="public" returntype="struct" output="false" hint="Get the pool's metadata structure">
		<cfreturn duplicate(getObjectPool().getpool_metadata())>
	</cffunction>

	<!--- Set The Eviction Policy --->
	<cffunction name="setevictionPolicy" access="public" returntype="void" output="false" hint="You can now override the set eviction policy by programmatically sending it in.">
		<cfargument name="evictionPolicy" type="coldbox.system.cache.policies.AbstractEvictionPolicy" required="true">
		<cfset instance.evictionPolicy = arguments.evictionPolicy>
	</cffunction>
	
	<!--- Get the Java Runtime --->
	<cffunction name="getjavaRuntime" access="public" returntype="any" output="false" hint="Get the java runtime object for reporting purposes.">
		<cfreturn instance.javaRuntime>
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------->
	
	<!--- announceExpiration --->
	<cffunction name="announceExpiration" output="false" access="private" returntype="void" hint="Announce an Expiration">
		<cfargument name="objectKey" type="string" required="true" hint="The object key to announce expiration"/>
		<cfscript>
			var interceptData = structnew();
			/* interceptData */
			interceptData.cacheObjectKey = arguments.objectKey;
			/* Execute afterCacheElementExpired Interception */
			instance.controller.getInterceptorService().processState("afterCacheElementExpired",interceptData);
		</cfscript>
	</cffunction>
	
	<!--- Initialize our object cache pool --->
	<cffunction name="initPool" access="private" output="false" returntype="void" hint="Initialize and set the internal object Pool">
		<cfscript>
			instance.objectPool = CreateObject("component","coldbox.system.cache.ObjectPool").init();
		</cfscript>
	</cffunction>

	<!--- Threshold JVM Checks --->
	<cffunction name="ThresholdChecks" access="private" output="false" returntype="boolean" hint="JVM Threshold checks">
		<cfset var check = true>
		<cfset var jvmThreshold = 0>
		
		<cftry>
			<!--- Checks --->
			<cfif getCacheConfigBean().getCacheFreeMemoryPercentageThreshold() neq 0>
				<cfset jvmThreshold = ( (instance.javaRuntime.getRuntime().freeMemory() / instance.javaRuntime.getRuntime().maxMemory() ) * 100 )>
				<cfset check = getCacheConfigBean().getCacheFreeMemoryPercentageThreshold() lt jvmThreshold>				
			</cfif>
			<cfcatch type="any">
				<cfset check = true>
			</cfcatch>
		</cftry>
		
		<cfreturn check>
	</cffunction>

	<!--- Get Util --->
	<cffunction name="getUtil" access="private" output="false" returntype="coldbox.system.util.Util" hint="Create and return a util object">
		<cfreturn CreateObject("component","coldbox.system.util.Util")/>
	</cffunction>

</cfcomponent>