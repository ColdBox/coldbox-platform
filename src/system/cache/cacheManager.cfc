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
<cfcomponent name="cacheManager" hint="Manages handler,plugin,custom plugin and object caching. It is thread safe and implements locking for you." output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	
	<cfscript>
		instance = structnew();
	</cfscript>

	<cffunction name="init" access="public" output="false" returntype="cacheManager" hint="Constructor">
		<cfargument name="controller" type="any" required="true">
		<cfscript>
			//Set Controller Injection
			instance.controller = arguments.controller;
			//Cache Configuration
			instance.CacheConfigBean = structnew();
			//Lock Name
			instance.lockName = getController().getAppHash() & "_OCM_OPERATION";
			//Runtime Java object
			instance.javaRuntime = CreateObject("java", "java.lang.Runtime");
			//Init the object Pool on instantiation
			initPool();
			//Event URL Facade Setup
			instance.eventURLFacade = CreateObject("component","eventURLFacade").init(arguments.controller);
			//Cache Stats
			instance.cacheStats = CreateObject("component","cacheStats").init(this);
			
			//return Cache Manager reference;
			return this;
		</cfscript>
	</cffunction>

	<!--- Configure the Cache for Operation --->
	<cffunction name="configure" access="public" output="false" returntype="void" hint="Configures the cache for operation.">
		<!--- ************************************************************* --->
		<cfargument name="cacheConfigBean" type="coldbox.system.beans.cacheConfigBean" required="true">
		<!--- ************************************************************* --->
		<cfscript>
		//set the config bean
		setCacheConfigBean(arguments.cacheConfigBean);
		//Reset the statistics.
		getCacheStats().clearStats();
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- ************************************************************* --->

	<cffunction name="lookup" access="public" output="false" returntype="boolean" hint="Check if an object is in cache, if not found it records a miss.">
		<!--- ************************************************************* --->
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object to lookup.">
		<!--- ************************************************************* --->
		<cfset var ObjectFound = false>

		<cflock type="readonly" name="#getLockName()#" timeout="30">
			<cfif getobjectPool().lookup(arguments.objectKey)>
				<cfset ObjectFound = true>
			<cfelse>
				<!--- Log miss --->
				<cfset miss()>
			</cfif>
		</cflock>

		<cfreturn ObjectFound>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="get" access="public" output="false" returntype="any" hint="Get an object from cache. If it doesn't exist it returns a blank structure.">
		<!--- ************************************************************* --->
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object to lookup.">
		<!--- ************************************************************* --->
		<cfset var ObjectFound = "">

		<cflock type="exclusive" name="#getLockName()#" timeout="30">
			<!--- Lookup First --->
			<cfif getobjectPool().lookup(arguments.objectKey)>
				<!--- Record a Hit --->
				<cfset hit()>
				<cfset ObjectFound = getobjectPool().get(arguments.objectKey)>
			<cfelse>
				<cfset miss()>
			</cfif>
		</cflock>
		
		<cfreturn ObjectFound>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="set" access="public" output="false" returntype="boolean" hint="sets an object in cache. Sets might be expensive">
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
		
		<!--- JVMThreshold Check --->
		<cfif ccBean.getCacheFreeMemoryPercentageThreshold() neq 0 and isJVMSafe eq false>
			<!--- Evict Using Policy --->
			<cfinvoke method="#ccBean.getCacheEvictionPolicy()#Eviction">
			<cfset isJVMSafe = ThresholdChecks()>
		</cfif>
		<!--- Check for max objects, no else to be sure. --->
		<cfif ccBean.getCacheMaxObjects() neq 0 and getSize() gte ccBean.getCacheMaxObjects()>
			<!--- Evict Using Policy --->
			<cfinvoke method="#ccBean.getCacheEvictionPolicy()#Eviction">
		</cfif>
		
		<!--- If not safe or too many objects is still reached, don't cache, its too dangerous --->
		<cfif (ccBean.getCacheFreeMemoryPercentageThreshold() eq 0 or isJVMSafe) and
			  (ccBean.getCacheMaxObjects() eq 0 or getSize() lt ccBean.getCacheMaxObjects())>
			
			<!--- Test Timeout Argument, if false, then inherit framework's timeout --->
			<cfif arguments.Timeout eq "" or not isNumeric(arguments.Timeout) or arguments.Timeout lt 0>
				<cfset arguments.Timeout = ccBean.getCacheObjectDefaultTimeout()>
			</cfif>
			
			<!--- Test the Last Access Timeout --->
			<cfif arguments.LastAccessTimeout eq "" or not isNumeric(arguments.LastAccessTimeout) or arguments.LastAccessTimeout lte 0>
				<cfset arguments.LastAccessTimeout = ccBean.getCacheObjectDefaultLastAccessTimeout()>
			</cfif>
			
			<!--- Set object in Cache --->
			<cflock type="exclusive" name="#getLockName()#" timeout="30">
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

	<!--- ************************************************************* --->

	<cffunction name="clearKey" access="public" output="false" returntype="boolean" hint="Clears a key from the cache.">
		<!--- ************************************************************* --->
		<cfargument name="objectKey" type="string" required="true">
		<!--- ************************************************************* --->
		<cfset var ClearCheck = false>
		<cfset var interceptMetadata = structnew()>
		
		<!--- Remove Object --->
		<cflock type="exclusive" name="#getLockName()#" timeout="30">
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
	
	<!--- ************************************************************* --->
	
	<cffunction name="clearEvent" access="public" output="false" returntype="void" hint="Clears all the event permuations from the cache.">
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

	<!--- ************************************************************* --->
	
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

	<!--- ************************************************************* --->
	
	<cffunction name="clearAllViews" access="public" output="false" returntype="void" hint="Clears all views from the cache.">
		<!--- ************************************************************* --->
		<cfargument name="async" 		type="boolean"  required="false" default="true" hint="Run asynchronously or not"/>
		<!--- ************************************************************* --->
		<cfscript>
			var poolKeys = listSort(structKeyList(getObjectPool().getpool_metadata()),"textnocase");
			var poolKeysLength = listlen(poolKeys);
			var x = 1;
			
			//Find all the event keys.
			for(x=1; x lte poolKeysLength; x=x+1){
				if ( findnocase( getController().getPlugin("renderer").VIEW_CACHEKEY_PREFIX, listGetAt(poolKeys,x) ) ){
					clearKey(listGetAt(poolKeys,x));
				}
			}
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="clear" access="public" output="false" returntype="void" hint="Clears the entire object cache. Call from a non-cached object or you will get 500 NULL errors, VERY VERY BAD!!.">
		<cflock type="exclusive" name="#getLockName()#" timeout="30">
			<cfset structDelete(variables,"objectPool")>
			<cfset initPool()>
			<cfset getCacheStats().clearStats()>
		</cflock>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getSize" access="public" output="false" returntype="numeric" hint="Get the cache's size in items">
		<cfscript>
		return getObjectPool().getSize();
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getpool_metadata" access="public" returntype="struct" output="false" hint="Get the pool's metadata structure">
		<cfreturn getObjectPool().getpool_metadata()>
	</cffunction>

	<!--- ************************************************************* --->

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

	<!--- ************************************************************* --->

	<cffunction name="reap" access="public" output="false" returntype="void" hint="Reap the cache.">
		<cfscript>
			var keyIndex = 1;
			var poolStruct = getObjectPool().getpool_metadata();
			var poolKeys = listToArray(structKeyList(poolStruct));
			var poolKeysLength = ArrayLen(poolKeys);
			var thisKey = "";
			var ccBean = getCacheConfigBean();
			
			//Check reaping frequency
			if ( dateDiff("n", getCacheStats().getlastReapDatetime(), now() ) gte ccBean.getCacheReapFrequency() ){

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
					
				}//end for loop
			}// end reaping frequency check
		</cfscript>
	</cffunction>
	
	<!--- ************************************************************* --->

	<cffunction name="LFUEviction" access="public" output="false" returntype="void" hint="Evict the least frequently used.">
		<cfscript>
			var objStruct = getObjectPool().getpool_metadata();
			var LFUhitIndex = structSort(objStruct,"numeric", "ASC", "hits");
			var indexLength = ArrayLen(LFUhitIndex);
			var x = 1;
		
			//Loop Through Metadata
			for (x=1; x lte indexLength; x=x+1){
				//Override Eternal Checks
				if ( objStruct[LFUhitIndex[x]].Timeout gt 0 ){
					//Evict it
					expireKey(LFUhitIndex[x]);
					break;
				}//end timeout gt 0
			}//end for loop
			
			//Record Eviction 
			getCacheStats().setEvictionCount(getCacheStats().getEvictionCount()+1);
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->
	
	<cffunction name="LRUEviction" access="public" output="false" returntype="void" hint="Evict the least frequently used.">
		<cfscript>
			var objStruct = getObjectPool().getpool_metadata();
			var LRUhitIndex = structSort(objStruct,"numeric", "ASC", "LastAccessTimeout");
			var indexLength = ArrayLen(LRUhitIndex);
			var x = 1;
			
			//Loop Through Metadata
			for (x=1; x lte indexLength; x=x+1){
				//Override Eternal Checks
				if ( objStruct[LRUhitIndex[x]].Timeout gt 0 ){
					//Evict it
					expireKey(LRUhitIndex[x]);
					break;
				}//end timeout gt 0
			}//end for loop
			
			//Record Eviction 
			getCacheStats().setEvictionCount(getCacheStats().getEvictionCount()+1);
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="expireAll" access="public" returntype="any" hint="Expire All Objects. Use this instead of clear() from within handlers or any cached object, this sets the metadata for the objects to expire in the next request. Note that this is not an inmmediate expiration. Clear should only be used from outside a cached object" output="false" >
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
	
	<!--- ************************************************************* --->
	
	<cffunction name="expireKey" access="public" returntype="any" hint="Expire an Object. Use this instead of clearKey() from within handlers or any cached object, this sets the metadata for the objects to expire in the next request. Note that this is not an inmmediate expiration. Clear should only be used from outside a cached object" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="objectKey" type="string" required="true">
		<!--- ************************************************************* --->
		<cfscript>
			//Expire the object
			getObjectPool().setMetadataProperty(arguments.objectKey,"Timeout", 1);
			getObjectPool().setMetadataProperty(arguments.objectKey,"Created", dateAdd("n",-5,now()));
		</cfscript>
	</cffunction>
	
	<!--- ************************************************************* --->
	
<!------------------------------------------- ACCESSOR/MUTATORS ------------------------------------------->

	<!--- get Event URL Facade --->
	<cffunction name="geteventURLFacade" access="public" returntype="any" output="false" hint="Get the event url facade object.">
		<cfreturn instance.eventURLFacade>
	</cffunction>

	<!--- The cache stats --->
	<cffunction name="getCacheStats" access="public" returntype="any" output="false" hint="Return the cache stats object.">
		<cfreturn instance.cacheStats>
	</cffunction>
	
	<!--- The cache Config Bean --->
	<cffunction name="setCacheConfigBean" access="public" returntype="void" output="false">
		<cfargument name="CacheConfigBean" type="coldbox.system.beans.cacheConfigBean" required="true">
		<cfset instance.CacheConfigBean = arguments.CacheConfigBean>
	</cffunction>
	<cffunction name="getCacheConfigBean" access="public" returntype="any" output="false">
		<cfreturn instance.CacheConfigBean >
	</cffunction>

	<!--- Java Runtime --->
	<cffunction name="getjavaRuntime" access="public" returntype="any" output="false" hint="Get the java runtime object.">
		<cfreturn instance.javaRuntime>
	</cffunction>
	
	<!--- Controller --->
	<cffunction name="getcontroller" access="public" output="false" returntype="any" hint="Get controller">
		<cfreturn instance.controller/>
	</cffunction>
	<cffunction name="setcontroller" access="public" output="false" returntype="void" hint="Set controller">
		<cfargument name="controller" type="any" required="true"/>
		<cfset instance.controller = arguments.controller/>
	</cffunction>
	
	<!--- Lock Name --->
	<cffunction name="getlockName" access="public" output="false" returntype="any" hint="Get lockName">
		<cfreturn instance.lockName/>
	</cffunction>
	<cffunction name="setlockName" access="public" output="false" returntype="void" hint="Set lockName">
		<cfargument name="lockName" type="string" required="true"/>
		<cfset instance.lockName = arguments.lockName/>
	</cffunction>
	
	<!--- Get the internal object pool --->
	<cffunction name="getObjectPool" access="public" returntype="any" output="false" hint="Get the internal object pool">
		<cfreturn instance.objectPool >
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------->

	<cffunction name="hit" access="private" output="false" returntype="void" hint="Record a hit">
		<cfscript>
			getCacheStats().setHits(getCacheStats().getHits()+1);
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="miss" access="private" output="false" returntype="void" hint="Record a miss">
		<cfscript>
			getCacheStats().setmisses(getCacheStats().getmisses()+1);
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="initPool" access="private" output="false" returntype="void" hint="Initialize and set the internal object Pool">
		<cfscript>
			instance.objectPool = CreateObject("component","objectPool").init();
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

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