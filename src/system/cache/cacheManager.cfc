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
			//Object Pool
			instance.objectPool = structnew();
			
			//Cache Performance
			instance.cachePerformance = structNew();
			instance.cachePerformance.Hits = 0;
			instance.cachePerformance.Misses = 0;
			
			//Reaping Control
			instance.lastReapDatetime = now();
			
			//Runtime Java object
			instance.javaRuntime = CreateObject("java", "java.lang.Runtime");
			
			//Lock Name
			instance.lockName = getController().getAppHash() & "_OCM_OPERATION";
			
			//Init the object Pool on instantiation
			initPool();
			
			//return Cache Manager reference;
			return this;
		</cfscript>
	</cffunction>

	<!--- Configure the Cache for Operation --->
	<cffunction name="configure" access="public" output="false" returntype="void" hint="Configures the cache for operation.">
		<cfargument name="cacheConfigBean" type="coldbox.system.beans.cacheConfigBean" required="true">
		<cfscript>
		//set the config bean
		setCacheConfigBean(arguments.cacheConfigBean);
		//Reset the statistics.
		resetStatistics();
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- ************************************************************* --->

	<cffunction name="lookup" access="public" output="false" returntype="boolean" hint="Check if an object is in cache, if not found it records a miss.">
		<!--- ************************************************************* --->
		<cfargument name="objectKey" type="string" required="true" hint="The key of the object to lookup.">
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
		<cfargument name="objectKey" type="string" required="true" hint="The key of the object to lookup.">
		<!--- ************************************************************* --->
		<cfset var ObjectFound = StructNew()>

		<cflock type="exclusive" name="#getLockName()#" timeout="30">
			<!--- Lookup First --->
			<cfif getobjectPool().lookup(arguments.objectKey)>
				<!--- Record a Hit --->
				<cfset hit()>
				<cfset ObjectFound = getobjectPool().get(arguments.objectKey)>
			</cfif>
		</cflock>
		
		<cfreturn ObjectFound>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="set" access="public" output="false" returntype="void" hint="sets an object in cache.">
		<!--- ************************************************************* --->
		<cfargument name="objectKey" 			type="string"  required="true" hint="The object cache key">
		<cfargument name="MyObject"				type="any" 	   required="true" hint="The object to cache">
		<cfargument name="Timeout"				type="string"  required="false" default="" hint="Timeout in minutes. If timeout = 0 then object never times out. If timeout is blank, then timeout will be inherited from framework.">
		<cfargument name="LastAccessTimeout"	type="string"  required="false" default="" hint="Last Access Timeout in minutes. If timeout is blank, then timeout will be inherited from framework.">
		<!--- ************************************************************* --->
		<!---JVM Threshold Checks --->
		<cfset var isBelowThreshold = ThresholdChecks()>
		<cfset var ccBean = getCacheConfigBean()>
		<cfset var interceptMetadata = structnew()>
		
		<!--- Reap Cache to make space, just in case. --->
		<cfset reap()>
		
		<!--- Clean Arguments --->
		<cfset arguments.objectKey = trim(arguments.objectKey)>
		<cfset arguments.Timeout = trim(arguments.Timeout)>
		<cfset arguments.LastAccessTimeout = trim(arguments.LastAccessTimeout)>
	
		<!--- Max Objects in Cache Check --->
		<cfif (ccBean.getCacheMaxObjects() eq 0 or getSize() lt ccBean.getCacheMaxObjects()) and
			  (ccBean.getCacheFreeMemoryPercentageThreshold() eq 0 or isBelowThreshold)>

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
		</cfif>
		
		<!--- Only execute once the framework has been initialized --->
		<cfif getController().getColdboxInitiated()>
			<!--- InterceptMetadata --->
			<cfset interceptMetadata.cacheObjectKey = arguments.objectKey>
			<cfset interceptMetadata.cacheObjectTimeout = arguments.Timeout>
			<cfset interceptMetadata.cacheObjectLastAccessTimeout = arguments.LastAccessTimeout>
			<!--- Execute afterCacheElementInsert Interception --->
			<cfset getController().getInterceptorService().processState("afterCacheElementInsert",interceptMetadata)>
		</cfif>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="clearKey" access="public" output="false" returntype="boolean" hint="Clears a key from the cache.">
		<!--- ************************************************************* --->
		<cfargument name="objectKey" type="string" required="true">
		<!--- ************************************************************* --->
		<cfset var Results = false>
		<cfset var interceptMetadata = structnew()>
		
		<!--- Remove Object --->
		<cfif getobjectPool().lookup(arguments.objectKey) >
			<cflock type="exclusive" name="#getLockName()#" timeout="30">
				<cfset Results = getobjectPool().clearKey(arguments.objectKey)>
			</cflock>
		</cfif>
		
		<!--- InterceptMetadata --->
		<cfset interceptMetadata.cacheObjectKey = arguments.objectKey>
		
		<!--- Execute afterCacheElementInsert Interception --->
		<cfset getController().getInterceptorService().processState("afterCacheElementInsert",interceptMetadata)>
		
		<cfreturn Results>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="clear" access="public" output="false" returntype="void" hint="Clears the entire object cache. Call from a non-cached object or you will get 500 NULL errors, VERY VERY BAD!!.">
		<cflock type="exclusive" name="#getLockName()#" timeout="30">
			<cfset structDelete(variables,"objectPool")>
			<cfset initPool()>
			<cfset resetStatistics()>
		</cflock>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="resetStatistics" access="public" output="false" returntype="void" hint="Resets the cache statistics.">
		<cfscript>
		getcachePerformance().Hits = 0;
		getcachePerformance().Misses = 0;
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getCachePerformanceRatio" access="public" output="false" returntype="numeric" hint="Get the cache's performance ratio">
		<cfscript>
	 	var requests = getcachePerformance().hits + getcachePerformance().misses;
	 	if ( requests eq 0)
	 		return 0;
		else
			return (getcachePerformance().Hits/requests) * 100;
		</cfscript>
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
			else
				itemTypes.other = itemTypes.other + 1;
		}
		return itemTypes;
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="reap" access="public" output="false" returntype="void" hint="Reap the cache.">
		<cfscript>
			var key = "";
			var objStruct = getObjectPool().getpool_metadata();
			var ccBean = getCacheConfigBean();

			//Check if no data in pool
			if (not structisEmpty(objStruct)){

				//Check reaping frequency
				if ( dateDiff("n", getlastReapDatetime(), now() ) gte ccBean.getCacheReapFrequency() ){

					//Reaping about to start, set new reaping date.
					setlastReapDatetime( now() );

					//Loop Through Metadata
					for (key in objStruct){
						//Override Timeout Check
						if ( objStruct[key].Timeout gt 0 ){
							//Check for creation timeouts and clear
							if ( dateDiff("n", objStruct[key].created, now() ) gte  objStruct[key].Timeout ){
								clearKey(key);
								continue;
							}
							//Check for last accessed timeout. If object has not been accessed in the default span
							if ( dateDiff("n", objStruct[key].lastAccesed, now() ) gte  ccBean.getCacheObjectDefaultLastAccessTimeout() ){
								clearKey(key);
								continue;
							}
						}//end timeout gt 0
					}//end for loop
				}// end reaping frequency check
			}//end if objects in pool
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="expireAll" access="public" returntype="any" hint="Expire All Objects. Use this instead of clear() from within handlers or any cached object, this sets the metadata for the objects to expire in the next request. Note that this is not an inmmediate expiration. Clear should only be used from outside a cached object" output="false" >
		<cfscript>
			var key = "";
			var objStruct = getObjectPool().getpool_metadata();
			
			//Check if no data in pool
			if (not structisEmpty(objStruct)){
				//Loop Through Metadata and set expiration timeouts.
				for (key in objStruct){
					objStruct[key].Timeout = 1;
					objStruct[key].created = dateadd("n",-5,now());
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

	<!--- ************************************************************* --->
	
	<cffunction name="getlastReapDatetime" access="public" output="false" returntype="string" hint="Get the lastReapDatetime">
		<cfscript>
		return instance.lastReapDatetime;
		</cfscript>
	</cffunction>
	<cffunction name="setlastReapDatetime" access="public" returntype="void" output="false" hint="Set the lastReapDatetime">
		<cfargument name="lastReapDatetime" type="string" required="true">
		<cfset instance.lastReapDatetime = arguments.lastReapDatetime>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getcachePerformance" access="public" output="false" returntype="struct" hint="Get the cachePerformance structure">
		<cfscript>
		return instance.cachePerformance;
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="setCacheConfigBean" access="public" returntype="void" output="false">
		<cfargument name="CacheConfigBean" type="coldbox.system.beans.cacheConfigBean" required="true">
		<cfset instance.CacheConfigBean = arguments.CacheConfigBean>
	</cffunction>
	<cffunction name="getCacheConfigBean" access="public" returntype="coldbox.system.beans.cacheConfigBean" output="false">
		<cfreturn instance.CacheConfigBean >
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getjavaRuntime" access="public" returntype="any" output="false" hint="Get the java runtime object.">
		<cfreturn instance.javaRuntime>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="getcontroller" access="public" output="false" returntype="any" hint="Get controller">
		<cfreturn instance.controller/>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="setcontroller" access="public" output="false" returntype="void" hint="Set controller">
		<cfargument name="controller" type="any" required="true"/>
		<cfset instance.controller = arguments.controller/>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="getlockName" access="public" output="false" returntype="string" hint="Get lockName">
		<cfreturn instance.lockName/>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="setlockName" access="public" output="false" returntype="void" hint="Set lockName">
		<cfargument name="lockName" type="string" required="true"/>
		<cfset instance.lockName = arguments.lockName/>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="getObjectPool" access="public" returntype="any" output="false" hint="Get the internal object pool">
		<cfreturn instance.objectPool >
	</cffunction>
	
	<!--- ************************************************************* --->
	
<!------------------------------------------- PRIVATE ------------------------------------------->

	<cffunction name="hit" access="private" output="false" returntype="void" hint="Record a hit">
		<cfscript>
		getcachePerformance().Hits = getcachePerformance().Hits + 1;
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="miss" access="private" output="false" returntype="void" hint="Record a miss">
		<cfscript>
		getcachePerformance().misses = getcachePerformance().misses + 1;
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