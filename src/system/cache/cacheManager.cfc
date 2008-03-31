<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date        :	January 18, 2007
Description :
	This is a cfc that handles caching of event handlers.

Modification History:
01/18/2007 - Created

----------------------------------------------------------------------->
<cfcomponent name="cacheManager" 
			 hint="Manages handler,plugin,custom plugin and object caching. It is thread safe and implements locking for you." 
			 output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	
	<cfscript>
		instance = structnew();
	</cfscript>

	<cffunction name="init" access="public" output="false" returntype="cacheManager" hint="Constructor">
		<cfargument name="controller" type="any" required="true">
		<cfscript>
			/* Set Controller Injection */
			setController( arguments.controller );
			/* Lock Name */
			instance.lockName = getController().getAppHash() & "_OCM_OPERATION";
			/* Runtime Java object */
			instance.javaRuntime = CreateObject("java", "java.lang.Runtime");
			/* Event URL Facade Setup */
			instance.eventURLFacade = CreateObject("component","coldbox.system.cache.util.eventURLFacade").init(arguments.controller);
			/* Cache Stats */
			instance.cacheStats = CreateObject("component","coldbox.system.cache.util.cacheStats").init(this);
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
		<cfargument name="cacheConfigBean" type="coldbox.system.beans.cacheConfigBean" required="true" hint="The configuration object">
		<!--- ************************************************************* --->
		<cfscript>			
			//set the config bean
			setCacheConfigBean(arguments.cacheConfigBean);
			//Reset the statistics.
			getCacheStats().clearStats();
			//Setup the eviction Policy to use
			setEvictionPolicy( CreateObject("component","coldbox.system.cache.policies.#getCacheConfigBean().getCacheEvictionPolicy()#").init(this) );
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Simple cache Lookup --->
	<cffunction name="lookup" access="public" output="false" returntype="boolean" hint="Check if an object is in cache, if not found it records a miss.">
		<!--- ************************************************************* --->
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object to lookup.">
		<!--- ************************************************************* --->
		<cfset var local = structnew()>
		
		<!--- Init some vars --->
		<cfset local.needCleanup = false>
		<cfset local.ObjectFound = false>
		<cfset local.tmpObj = 0>
		
		<cflock type="readonly" name="#getLockName()#" timeout="30" throwontimeout="true">
			<cfscript>
				/* Check if in pool first */
				if( getObjectPool().lookup(arguments.objectKey) ){
					/* Get Object from cache */
					local.tmpObj = getobjectPool().get(arguments.objectKey);
					/* Validate it */
					if( not structKeyExists(local, "tmpObj") ){
						needCleanup = true;
						miss();
					}
					else{
						/* Object Found */
						local.ObjectFound = true;
					}					
				}// first lookup test
				else{
					/* log miss */
					miss();
				}
			</cfscript>
		</cflock>
		
		<!--- Check if needs clearing --->
		<cfif local.needCleanup>
			<cfset clearKey(arguments.objectKey)>
		</cfif>
		
		<cfreturn local.ObjectFound>
	</cffunction>

	<!--- Get an object from the cache --->
	<cffunction name="get" access="public" output="false" returntype="any" hint="Get an object from cache. If it doesn't exist it returns the THIS.NOT_FOUND value">
		<!--- ************************************************************* --->
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object to lookup.">
		<!--- ************************************************************* --->
		<cfset var local = structNew()>
		
		<!--- INit Vars --->
		<cfset local.needCleanup = false>
		<cfset local.tmpObj = 0>
		<cfset local.targetObject = this.NOT_FOUND>
	
		<cflock type="exclusive" name="#getLockName()#" timeout="30" throwontimeout="true">
			<cfscript>
				/* Check if in pool first */
				if( getObjectPool().lookup(arguments.objectKey) ){
					/* Get Object from cache */
					local.tmpObj = getobjectPool().get(arguments.objectKey);
					/* Validate it */
					if( not structKeyExists(local,"tmpObj") ){
						needCleanup = true;
						miss();
					}
					else{
						local.targetObject = local.tmpObj;
						hit();
					}
				}
				else{
					/* log miss */
					miss();
				}
			</cfscript>
		</cflock>
		
		<!--- Check if needs clearing --->
		<cfif local.needCleanup>
			<cfset clearKey(arguments.objectKey)>
		</cfif>
		
		<!--- Return Target Object --->
		<cfreturn local.targetObject>
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
			<cfset getEvictionPolicy().execute()>
			<!--- Do another Check, just in case --->
			<cfset isJVMSafe = ThresholdChecks()>
		</cfif>
		<!--- Check for max objects reached --->
		<cfif ccBean.getCacheMaxObjects() neq 0 and getSize() gte ccBean.getCacheMaxObjects()>
			<!--- Evict Using Policy --->
			<cfset getEvictionPolicy().execute()>
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
			<cflock type="exclusive" name="#getLockName()#" timeout="30" throwontimeout="true">
				<cfset getobjectPool().set(arguments.objectKey,arguments.MyObject,arguments.Timeout,arguments.LastAccessTimeout)>
			</cflock>
			
			<!--- Only execute once the framework has been initialized --->
			<cfif getController().getColdboxInitiated()>
				<!--- InterceptMetadata --->
				<cfset interceptMetadata.cacheObjectKey = arguments.objectKey>
				<cfset interceptMetadata.cacheObjectTimeout = arguments.Timeout>
				<cfset interceptMetadata.cacheObjectLastAccessTimeout = arguments.LastAccessTimeout>
				<!--- Execute afterCacheElementInsert Interception --->
				<cfset getController().getInterceptorService().processState("afterCacheElementInsert",interceptMetadata)>				
			</cfif>
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
		<cflock type="exclusive" name="#getLockName()#" timeout="30" throwontimeout="true">
			<cfif getobjectPool().lookup(arguments.objectKey)>
				<cfset ClearCheck = getobjectPool().clearKey(arguments.objectKey)>
			</cfif>
		</cflock>
		
		<!--- Only fire if object removed. --->
		<cfif ClearCheck>
			<!--- InterceptMetadata --->
			<cfset interceptMetadata.cacheObjectKey = arguments.objectKey>
			<!--- Execute afterCacheElementInsert Interception --->
			<cfset getController().getInterceptorService().processState("afterCacheElementRemoved",interceptMetadata)>
		</cfif>
		
		<cfreturn ClearCheck>
	</cffunction>
	
	<!--- Clear By Key Snippet --->
	<cffunction name="clearByKeySnippet" access="public" returntype="void" hint="Clears keys using the passed in object key snippet" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="keySnippet" 	type="string" 	required="true" hint="The key snippet to use to clear keys. It matches using findnocase">
		<cfargument name="async" 		type="boolean"  required="false" default="true" hint="Run asynchronously or not. It defaults to true"/>
		<!--- ************************************************************* --->
		<cfscript>
			var poolKeys = listSort(structKeyList(getObjectPool().getpool_metadata()),"textnocase");
			var poolKeysLength = listlen(poolKeys);
			var x = 1;
			
			//Find all the keys that match
			for(x=1; x lte poolKeysLength; x=x+1){
				if ( findnocase( arguments.keySnippet, listGetAt(poolKeys,x) ) ){
					clearKey(listGetAt(poolKeys,x));
				}
			}
		</cfscript>
	</cffunction>
	
	<!--- Clear an event --->
	<cffunction name="clearEvent" access="public" output="false" returntype="void" hint="Clears all the event permutations from the cache.">
		<!--- ************************************************************* --->
		<cfargument name="eventsnippet" type="string" 	required="true" hint="The event snippet to clear on. Can be partial or full">
		<cfargument name="queryString" 	type="string" 	required="false" default="" hint="If passed in, it will create a unique hash out of it. For purging purposes"/>
		<cfargument name="async" 		type="boolean"  required="false" default="true" hint="Run asynchronously or not"/>
		<!--- ************************************************************* --->
		<cfscript>
			var poolKeys = listSort(structKeyList(getObjectPool().getpool_metadata()),"textnocase");
			var poolKeysLength = listlen(poolKeys);
			var x = 1;
			var cacheKey = getController().getHandlerService().EVENT_CACHEKEY_PREFIX & arguments.eventsnippet;
			
			//Check if we are purging with query string
			if( len(arguments.queryString) neq 0 ){
				cacheKey = cacheKey & "-" & getEventURLFacade().buildHash(arguments.eventsnippet,arguments.queryString);
			}
			
			//Find all the event keys.
			for(x=1; x lte poolKeysLength; x=x+1){
				if ( findnocase( cacheKey, listGetAt(poolKeys,x) ) ){
					clearKey(listGetAt(poolKeys,x));
				}
			}
		</cfscript>
	</cffunction>

	<!--- Clear All the Events form the cache --->
	<cffunction name="clearAllEvents" access="public" output="false" returntype="void" hint="Clears all events from the cache.">
		<!--- ************************************************************* --->
		<cfargument name="async" 		type="boolean"  required="false" default="true" hint="Run asynchronously or not"/>
		<!--- ************************************************************* --->
		<cfscript>
			var poolKeys = listSort(structKeyList(getObjectPool().getpool_metadata()),"textnocase");
			var poolKeysLength = listlen(poolKeys);
			var x = 1;
			
			//Find all the event keys.
			for(x=1; x lte poolKeysLength; x=x+1){
				if ( findnocase( getController().getHandlerService().EVENT_CACHEKEY_PREFIX, listGetAt(poolKeys,x) ) ){
					clearKey(listGetAt(poolKeys,x));
				}
			}
		</cfscript>
	</cffunction>

	<!--- Clear All The Views from the Cache. --->
	<cffunction name="clearAllViews" access="public" output="false" returntype="void" hint="Clears all views from the cache.">
		<!--- ************************************************************* --->
		<cfargument name="async" 		type="boolean"  required="false" default="true" hint="Run asynchronously or not"/>
		<!--- ************************************************************* --->
		<cfscript>
			var poolKeys = listSort(structKeyList(getObjectPool().getpool_metadata()),"textnocase");
			var poolKeysLength = listlen(poolKeys);
			var x = 1;
			var cacheKey = getController().getPlugin("renderer").VIEW_CACHEKEY_PREFIX;
			
			//Find all the event keys.
			for(x=1; x lte poolKeysLength; x=x+1){
				if ( findnocase( cacheKey, listGetAt(poolKeys,x) ) ){
					clearKey(listGetAt(poolKeys,x));
				}
			}
		</cfscript>
	</cffunction>

	<!--- Clear The Pool --->
	<cffunction name="clear" access="public" output="false" returntype="void" hint="Clears the entire object cache and recreates the object pool and statistics. Call from a non-cached object or you will get 500 NULL errors, VERY VERY BAD!!.">
		<cflock type="exclusive" name="#getLockName()#" timeout="30" throwontimeout="true">
			<cfset structDelete(variables,"objectPool")>
			<cfset initPool()>
			<cfset getCacheStats().clearStats()>
		</cflock>
	</cffunction>

	<!--- Get the Cache Size --->
	<cffunction name="getSize" access="public" output="false" returntype="numeric" hint="Get the cache's size in items">
		<cfscript>
		return getObjectPool().getSize();
		</cfscript>
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
					}
					/* Poll Again */
					reflocal.softRef = getObjectPool().getReferenceQueue().poll();
				}
				
				/* Let's Get our reaping vars ready */
				poolStruct = getObjectPool().getpool_metadata();
				poolKeys = listToArray(structKeyList(poolStruct));
				poolKeysLength = ArrayLen(poolKeys);
				
				//Reaping about to start, set new reaping date.
				getCacheStats().setlastReapDatetime( now() );
				
				//Loop Through Metadata
				for (keyIndex=1; keyIndex lte poolKeysLength; keyIndex=keyIndex+1){
					
					//This Key
					thisKey = poolKeys[keyIndex];
					
					//Override Timeout Check
					if ( poolStruct[thisKey].Timeout gt 0 ){
						//Check for creation timeouts and clear
						if ( dateDiff("n", poolStruct[thisKey].created, now() ) gte poolStruct[thisKey].Timeout ){
							clearKey(thisKey);
							continue;
						}
						//Check for last accessed timeouts. If object has not been accessed in the default span
						if ( ccBean.getCacheUseLastAccessTimeouts() and 
						     dateDiff("n", poolStruct[thisKey].lastAccesed, now() ) gte ccBean.getCacheObjectDefaultLastAccessTimeout() ){
							clearKey(thisKey);
							continue;
						}
					}//end timeout gt 0
					
				}//end looping over keys				
			}// end reaping frequency check			
		</cfscript>
	</cffunction>
	
	<!--- Expire All Objects --->
	<cffunction name="expireAll" access="public" returntype="void" hint="Expire All Objects. Use this instead of clear() from within handlers or any cached object, this sets the metadata for the objects to expire in the next request. Note that this is not an inmmediate expiration. Clear should only be used from outside a cached object" output="false" >
		<cfscript>
			var keyIndex = 1;
			var poolKeys = listToArray(structKeyList(getObjectPool().getpool_metadata()));
			var poolKeysLength = ArrayLen(poolKeys);
			
			//Loop Through Metadata
			for (keyIndex=1; keyIndex lte poolKeysLength; keyIndex=keyIndex+1){
				//Override for Eternal Objects
				if ( getObjectPool().getMetadataProperty(poolKeys[keyIndex],"Timeout") gt 0 ){
					getObjectPool().setMetadataProperty(poolKeys[keyIndex],"Timeout", 1);
					getObjectPool().setMetadataProperty(poolKeys[keyIndex],"created", dateadd("n",-5,now()) );
				}
			}
		</cfscript>
	</cffunction>
	
	<!--- Expire an Object --->
	<cffunction name="expireKey" access="public" returntype="void" hint="Expire an Object. Use this instead of clearKey() from within handlers or any cached object, this sets the metadata for the objects to expire in the next request. Note that this is not an inmmediate expiration. Clear should only be used from outside a cached object" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="objectKey" type="string" required="true">
		<!--- ************************************************************* --->
		<cfscript>
			//Expire the object
			getObjectPool().setMetadataProperty(arguments.objectKey,"Timeout", 1);
			getObjectPool().setMetadataProperty(arguments.objectKey,"Created", dateAdd("n",-5,now()));
		</cfscript>
	</cffunction>
	
	<!--- Expire an Object --->
	<cffunction name="expireByKeySnippet" access="public" returntype="void" hint="Same as expireKey but can touch multiple objects depending on the keysnippet that is sent in." output="false" >
		<!--- ************************************************************* --->
		<cfargument name="keySnippet" type="string" required="true">
		<!--- ************************************************************* --->
		<cfscript>
			var keyIndex = 1;
			var poolKeys = listToArray(structKeyList(getObjectPool().getpool_metadata()));
			var poolKeysLength = ArrayLen(poolKeys);
			
			//Loop Through Metadata
			for (keyIndex=1; keyIndex lte poolKeysLength; keyIndex=keyIndex+1){
				//Override for Eternal Objects and we match keys
				if ( getObjectPool().getMetadataProperty(poolKeys[keyIndex],"Timeout") gt 0 and
				     findnocase(arguments.keySnippet, poolKeys[keyIndex]) )
				{
					getObjectPool().setMetadataProperty(poolKeys[keyIndex],"Timeout", 1);
					getObjectPool().setMetadataProperty(poolKeys[keyIndex],"created", dateadd("n",-5,now()) );
				}
			}
		</cfscript>
	</cffunction>
	
	<!--- Get The Cache Item Types --->
	<cffunction name="getItemTypes" access="public" output="false" returntype="struct" hint="Get the item types of the cache.">
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
	<cffunction name="geteventURLFacade" access="public" returntype="coldbox.system.cache.util.eventURLFacade" output="false" hint="Get the event url facade object.">
		<cfreturn instance.eventURLFacade>
	</cffunction>

	<!--- The cache stats --->
	<cffunction name="getCacheStats" access="public" returntype="coldbox.system.cache.util.cacheStats" output="false" hint="Return the cache stats object.">
		<cfreturn instance.cacheStats>
	</cffunction>
	
	<!--- The cache Config Bean --->
	<cffunction name="setCacheConfigBean" access="public" returntype="void" output="false" hint="Set the cache configuration bean.">
		<cfargument name="CacheConfigBean" type="coldbox.system.beans.cacheConfigBean" required="true">
		<cfset instance.CacheConfigBean = arguments.CacheConfigBean>
	</cffunction>
	<cffunction name="getCacheConfigBean" access="public" returntype="coldbox.system.beans.cacheConfigBean" output="false" hint="Get the current cache configuration bean.">
		<cfreturn instance.CacheConfigBean >
	</cffunction>

	<!--- Java Runtime --->
	<cffunction name="getjavaRuntime" access="public" returntype="any" output="false" hint="Get the java runtime object.">
		<cfreturn instance.javaRuntime>
	</cffunction>
	
	<!--- Controller --->
	<cffunction name="getcontroller" access="public" output="false" returntype="any" hint="Get ColdBox controller">
		<cfreturn instance.controller/>
	</cffunction>
	<cffunction name="setcontroller" access="public" output="false" returntype="void" hint="Set ColdBox controller">
		<cfargument name="controller" type="any" required="true"/>
		<cfset instance.controller = arguments.controller/>
	</cffunction>
	
	<!--- Lock Name --->
	<cffunction name="getlockName" access="public" output="false" returntype="string" hint="Get the lockName used for cache operations">
		<cfreturn instance.lockName/>
	</cffunction>
	
	<!--- Get the internal object pool --->
	<cffunction name="getObjectPool" access="public" returntype="any" output="false" hint="Get the internal object pool: coldbox.system.cache.objectPool or MTobjectPool">
		<cfreturn instance.objectPool >
	</cffunction>

	<!--- Get the Pool Metadata --->
	<cffunction name="getpool_metadata" access="public" returntype="struct" output="false" hint="Get the pool's metadata structure">
		<cfreturn getObjectPool().getpool_metadata()>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->
	
	<!--- Get Set the set eviction Policy --->
	<cffunction name="getevictionPolicy" access="private" returntype="coldbox.system.cache.policies.abstractEvictionPolicy" output="false">
		<cfreturn instance.evictionPolicy>
	</cffunction>
	<cffunction name="setevictionPolicy" access="private" returntype="void" output="false">
		<cfargument name="evictionPolicy" type="coldbox.system.cache.policies.abstractEvictionPolicy" required="true">
		<cfset instance.evictionPolicy = arguments.evictionPolicy>
	</cffunction>
	
	<!--- Record a Hit --->
	<cffunction name="hit" access="private" output="false" returntype="void" hint="Record a hit">
		<cfscript>
			getCacheStats().setHits(getCacheStats().getHits()+1);
		</cfscript>
	</cffunction>

	<!--- Record a Miss --->
	<cffunction name="miss" access="private" output="false" returntype="void" hint="Record a miss">
		<cfscript>
			getCacheStats().setmisses(getCacheStats().getmisses()+1);
		</cfscript>
	</cffunction>

	<!--- Initialize our object cache pool --->
	<cffunction name="initPool" access="private" output="false" returntype="void" hint="Initialize and set the internal object Pool">
		<cfscript>
			instance.objectPool = CreateObject("component","coldbox.system.cache.objectPool").init();
		</cfscript>
	</cffunction>

	<!--- Threshold JVM Checks --->
	<cffunction name="ThresholdChecks" access="private" output="false" returntype="boolean" hint="JVM Threshold checks">
		<cfset var check = true>
		<cfset var jvmThreshold = 0>
		
		<cftry>
			<!--- Checks --->
			<cfif getCacheConfigBean().getCacheFreeMemoryPercentageThreshold() neq 0>
				<cfset jvmThreshold = ( (getJavaRuntime().getRuntime().freeMemory() / getJavaRuntime().getRuntime().totalMemory() ) * 100 )>
				<cfset check = getCacheConfigBean().getCacheFreeMemoryPercentageThreshold() lt jvmThreshold>				
			</cfif>
			<cfcatch type="any">
				<cfset check = true>
			</cfcatch>
		</cftry>
		
		<cfreturn check>
	</cffunction>

	<!--- ************************************************************* --->

</cfcomponent>