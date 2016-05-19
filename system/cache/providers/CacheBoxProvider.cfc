<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
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
			 extends="coldbox.system.cache.AbstractCacheBoxProvider"
			 implements="coldbox.system.cache.ICacheProvider"
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
			// Element Cleaner Helper
			instance.elementCleaner		= CreateObject("component","coldbox.system.cache.util.ElementCleaner").init(this);
			// Utilities
			instance.utility			= createObject("component","coldbox.system.core.util.Util");
			// UUID Helper
			instance.uuidHelper			= createobject("java", "java.util.UUID");

			// CacheBox Provider Property Defaults
			instance.DEFAULTS = {
				objectDefaultTimeout = 60,
				objectDefaultLastAccessTimeout = 30,
				useLastAccessTimeouts = true,
				reapFrequency = 2,
				freeMemoryPercentageThreshold = 0,
				evictionPolicy = "LRU",
				evictCount = 1,
				maxObjects = 200,
				objectStore = "ConcurrentStore",
				coldboxEnabled = false
			};

			return this;
		</cfscript>
	</cffunction>

	<!--- validateConfiguration --->
    <cffunction name="validateConfiguration" output="false" access="private" returntype="void" hint="Validate incoming set configuration data">
    	<cfscript>
    		var cacheConfig = getConfiguration();
			var key			= "";

			// Validate configuration values, if they don't exist, then default them to DEFAULTS
			for(key in instance.DEFAULTS){
				if( NOT structKeyExists(cacheConfig, key) OR NOT len(cacheConfig[key]) ){
					cacheConfig[key] = instance.DEFAULTS[key];
				}
			}
		</cfscript>
    </cffunction>

	<!--- Configure the Cache for Operation --->
	<cffunction name="configure" access="public" output="false" returntype="void" hint="Configures the cache for operation, sets the configuration object, sets and creates the eviction policy and clears the stats. If this method is not called, the cache is useless.">

		<cfset var cacheConfig     	= getConfiguration()>
		<cfset var evictionPolicy  	= "">
		<cfset var objectStore		= "">

		<cflock name="CacheBoxProvider.configure.#instance.cacheID#" type="exclusive" timeout="20" throwontimeout="true">
		<cfscript>

			// Prepare the logger
			instance.logger = getCacheFactory().getLogBox().getLogger( this );

			if( instance.logger.canDebug() ){
				instance.logger.debug("Starting up CacheBox Cache: #getName()# with configuration: #cacheConfig.toString()#");
			}

			// Validate the configuration
			validateConfiguration();

			// Prepare Statistics
			instance.stats = CreateObject("component","coldbox.system.cache.util.CacheStats").init(this);

			// Setup the eviction Policy to use
			evictionPolicy 			= locateEvictionPolicy( cacheConfig.evictionPolicy );
			instance.evictionPolicy = CreateObject("component", evictionPolicy).init(this);

			// Create the object store the configuration mandated
			objectStore 			= locateObjectStore( cacheConfig.objectStore );
			instance.objectStore 	= CreateObject("component", objectStore).init(this);

			// Enable cache
			instance.enabled = true;
			// Enable reporting
			instance.reportingEnabled = true;

			// startup message
			if( instance.logger.canDebug() ){
				instance.logger.debug( "CacheBox Cache: #getName()# has been initialized successfully for operation" );
			}
		</cfscript>
		</cflock>

	</cffunction>

	<!--- shutdown --->
    <cffunction name="shutdown" output="false" access="public" returntype="void" hint="Shutdown command issued when CacheBox is going through shutdown phase">
   		<cfscript>
		   	if( instance.logger.canDebug() )
   				instance.logger.debug("CacheBox Cache: #getName()# has been shutdown.");
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
	<cffunction name="lookupMulti" access="public" output="false" returntype="any" hint="The returned value is a structure of name-value pairs of all the keys that where found or not." colddoc:generic="struct">
		<cfargument name="keys" 	type="any" 	required="true" hint="The comma delimited list or an array of keys to lookup in the cache.">
		<cfargument name="prefix" 	type="any" 	required="false" default="" hint="A prefix to prepend to the keys">
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
	<cffunction name="lookup" access="public" output="false" returntype="any" hint="Check if an object is in cache, if not found it records a miss." colddoc:generic="boolean">
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
	<cffunction name="lookupQuiet" access="public" output="false" returntype="any" hint="Check if an object is in cache quietly, advising nobody!" colddoc:generic="boolean">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object to lookup.">
		<cfscript>
			// cleanup the key
			arguments.objectKey = lcase(arguments.objectKey);

			return instance.objectStore.lookup( arguments.objectKey );
		</cfscript>
	</cffunction>

	<!--- Get an object from the cache --->
	<cffunction name="get" access="public" output="false" returntype="any" hint="Get an object from cache. If object does not exist it returns null">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object to lookup.">
		<cfscript>
			var refLocal = {};
			// cleanup the key
			arguments.objectKey = lcase( arguments.objectKey );

			// get quietly
			refLocal.results = instance.objectStore.get( arguments.objectKey );
			if( structKeyExists( refLocal, "results" ) ){
				getStats().hit();
				return refLocal.results;
			}
			getStats().miss();
			// don't return anything = null
		</cfscript>
	</cffunction>


	<!--- Get an object from the cache --->
	<cffunction name="getQuiet" access="public" output="false" returntype="any" hint="Get an object from cache. If object does not exist it returns null">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object to lookup.">
		<cfscript>
			var refLocal = {};

			// cleanup the key
			arguments.objectKey = lcase( arguments.objectKey );

			// get object from store
			refLocal.results = instance.objectStore.getQuiet( arguments.objectKey );
			if( structKeyExists(refLocal, "results") ){
				return refLocal.results;
			}

			// don't return anything = null
		</cfscript>
	</cffunction>

	<!--- Get multiple objects from the cache --->
	<cffunction name="getMulti" access="public" output="false" returntype="any" hint="The returned value is a structure of name-value pairs of all the keys that where found. Not found values will not be returned" colddoc:generic="struct">
		<!--- ************************************************************* --->
		<cfargument name="keys" 		type="any" 		required="true" hint="The comma delimited list or array of keys to retrieve from the cache.">
		<cfargument name="prefix"		type="any" 	required="false" default="" hint="A prefix to prepend to the keys">
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
	<cffunction name="getCachedObjectMetadata" output="false" access="public" returntype="any" hint="Get the cached object's metadata structure. If the object does not exist, it returns an empty structure." colddoc:generic="struct">
		<!--- ************************************************************* --->
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object to lookup its metadata">
		<!--- ************************************************************* --->
		<cfscript>
			// Cleanup the key
			arguments.objectKey = lcase(trim(arguments.objectKey));

			// Check if in the pool first
			if( instance.objectStore.getIndexer().objectExists(arguments.objectKey) ){
				return instance.objectStore.getIndexer().getObjectMetadata(arguments.objectKey);
			}

			return structnew();
		</cfscript>
	</cffunction>

	<!--- getCachedObjectMetadata --->
	<cffunction name="getCachedObjectMetadataMulti" output="false" access="public" returntype="any" hint="Get the cached object's metadata structure. If the object does not exist, it returns an empty structure." colddoc:generic="struct">
		<!--- ************************************************************* --->
		<cfargument name="keys" 	type="any" required="true" hint="The comma delimited list or array of keys to retrieve from the cache.">
		<cfargument name="prefix" 	type="any" required="false" default="" hint="A prefix to prepend to the keys">
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

			// Loop on Keys
			for(x=1;x lte listLen(arguments.keys);x=x+1){
				thisKey = arguments.prefix & listGetAt(arguments.keys,x);
				returnStruct[thiskey] = getCachedObjectMetadata(thisKey);
			}

			return returnStruct;
		</cfscript>
	</cffunction>

	<!--- Set Multi Object in the cache --->
	<cffunction name="setMulti" access="public" output="false" returntype="void" hint="Sets Multiple Ojects in the cache. Sets might be expensive. If the JVM threshold is used and it has been reached, the object won't be cached. If the pool is at maximum it will expire using its eviction policy and still cache the object. Cleanup will be done later.">
		<!--- ************************************************************* --->
		<cfargument name="mapping" 				type="any" 	required="true" hint="The structure of name value pairs to cache" colddoc:generic="struct">
		<cfargument name="timeout"				type="any" 	required="false" default="" hint="The timeout to use on the object (if any, provider specific)">
		<cfargument name="lastAccessTimeout"	type="any" 	required="false" default="" hint="The idle timeout to use on the object (if any, provider specific)">
		<cfargument name="prefix" 				type="any" 	required="false" default="" hint="A prefix to prepend to the keys">
		<!--- ************************************************************* --->
		<cfscript>
			var key = 0;
			// Clear Prefix
			arguments.prefix = trim(arguments.prefix);
			// Loop Over mappings
			for(key in arguments.mapping){
				// Cache theses puppies
				set(objectKey=arguments.prefix & key,object=arguments.mapping[key],timeout=arguments.timeout,lastAccessTimeout=arguments.lastAccessTimeout);
			}
		</cfscript>
	</cffunction>

	<!--- getOrSet --->
	<cffunction name="getOrSet" access="public" output="false" returntype="any" hint="Tries to get an object from the cache, if not found, it calls the 'produce' closure to produce the data and cache it.">
		<!--- ************************************************************* --->
		<cfargument name="objectKey" 			type="any"  	required="true" hint="The object cache key">
		<cfargument name="produce"				type="any" 		required="true" hint="The closure/udf to produce the data if not found">
		<cfargument name="timeout"				type="any"  	required="false" default="" hint="The timeout to use on the object (if any, provider specific)">
		<cfargument name="lastAccessTimeout"	type="any" 	 	required="false" default="" hint="The idle timeout to use on the object (if any, provider specific)">
		<cfargument name="extra" 				type="any" 		required="false" default="#structNew()#" hint="A map of name-value pairs to use as extra arguments to pass to a providers set operation" colddoc:generic="struct"/>
		<!--- ************************************************************* --->
		<cfscript>
			var refLocal = {
				object = get( arguments.objectKey )
			};
			// Verify if it exists? if so, return it.
			if( structKeyExists( refLocal, "object" ) ){ return refLocal.object; }
			// else, produce it
		</cfscript>
		<cflock name="CacheBoxProvider.GetOrSet.#instance.cacheID#.#arguments.objectKey#" type="exclusive" timeout="#instance.lockTimeout#" throwonTimeout="true">
			<cfscript>
				// double lock
				refLocal.object = get( arguments.objectKey );
				if( not structKeyExists( refLocal, "object" ) ){
					// produce it
					refLocal.object = arguments.produce();
					// store it
					set( objectKey=arguments.objectKey,
						 object=refLocal.object,
						 timeout=arguments.timeout,
						 lastAccessTimeout=arguments.lastAccessTimeout,
						 extra=arguments.extra );
				}
			</cfscript>
		</cflock>

		<cfreturn refLocal.object>
	</cffunction>

	<!--- Set an Object in the cache --->
	<cffunction name="set" access="public" output="false" returntype="any" hint="sets an object in cache. Sets might be expensive. If the JVM threshold is used and it has been reached, the object won't be cached. If the pool is at maximum it will expire using its eviction policy and still cache the object. Cleanup will be done later." colddoc:generic="boolean">
		<!--- ************************************************************* --->
		<cfargument name="objectKey" 			type="any"  	required="true" hint="The object cache key">
		<cfargument name="object"				type="any" 		required="true" hint="The object to cache">
		<cfargument name="timeout"				type="any"  	required="false" default="" hint="The timeout to use on the object (if any, provider specific)">
		<cfargument name="lastAccessTimeout"	type="any" 	 	required="false" default="" hint="The idle timeout to use on the object (if any, provider specific)">
		<cfargument name="extra" 				type="any" 		required="false" hint="A map of name-value pairs to use as extra arguments to pass to a providers set operation" colddoc:generic="struct"/>
		<!--- ************************************************************* --->
		<cfscript>
			var iData = "";
			// Check if updating or not
			var refLocal = {
				oldObject = getQuiet( arguments.objectKey )
			};

			// save object
			setQuiet(arguments.objectKey,arguments.object,arguments.timeout,arguments.lastAccessTimeout);

			// Announce update if it exists?
			if( structKeyExists(refLocal,"oldObject") ){
				// interception Data
				iData = {
					cache = this,
					cacheObjectKey = arguments.objectKey,
					cacheNewObject = arguments.object,
					cacheOldObject = refLocal.oldObject
				};

				// announce it
				getEventManager().processState("afterCacheElementUpdated", iData);
			}

			// interception Data
			iData = {
				cache = this,
				cacheObject = arguments.object,
				cacheObjectKey = arguments.objectKey,
				cacheObjectTimeout = arguments.timeout,
				cacheObjectLastAccessTimeout = arguments.lastAccessTimeout
			};

			// announce it
			getEventManager().processState("afterCacheElementInsert", iData);

			return true;
		</cfscript>
	</cffunction>

	<!--- Set an Object in the cache --->
	<cffunction name="setQuiet" access="public" output="false" returntype="any" hint="sets an object in cache. Sets might be expensive. If the JVM threshold is used and it has been reached, the object won't be cached. If the pool is at maximum it will expire using its eviction policy and still cache the object. Cleanup will be done later." colddoc:generic="boolean">
		<!--- ************************************************************* --->
		<cfargument name="objectKey" 			type="any"  	required="true" hint="The object cache key">
		<cfargument name="object"				type="any" 		required="true" hint="The object to cache">
		<cfargument name="timeout"				type="any"  	required="false" default="" hint="The timeout to use on the object (if any, provider specific)">
		<cfargument name="lastAccessTimeout"	type="any" 	 	required="false" default="" hint="The idle timeout to use on the object (if any, provider specific)">
		<cfargument name="extra" 				type="any" 		required="false" hint="A map of name-value pairs to use as extra arguments to pass to a providers set operation"  colddoc:generic="struct">
		<!--- ************************************************************* --->
		<cfscript>
			var isJVMSafe 		= true;
			var config 			= getConfiguration();
			var iData 			= {};

			// cleanup the key
			arguments.objectKey = lcase(arguments.objectKey);

			// JVM Checks
			if( config.freeMemoryPercentageThreshold NEQ 0 AND thresholdChecks(config.freeMemoryPercentageThreshold) EQ false){
				// evict some stuff
				instance.evictionPolicy.execute();
			}

			// Max objects check
			if( config.maxObjects NEQ 0 AND getSize() GTE config.maxObjects ){
				// evict some stuff
				instance.evictionPolicy.execute();
			}

			// Provider Default Timeout checks
			if( NOT len(arguments.timeout) OR NOT isNumeric(arguments.timeout) ){
				arguments.timeout = config.objectDefaultTimeout;
			}
			if( NOT len(arguments.lastAccessTimeout) OR NOT isNumeric(arguments.lastAccessTimeout) ){
				arguments.lastAccessTimeout = config.objectDefaultLastAccessTimeout;
			}

			// save object
			instance.objectStore.set(arguments.objectKey,arguments.object,arguments.timeout,arguments.lastAccessTimeout);

			return true;
		</cfscript>
	</cffunction>

	<!--- Clear an object from the cache --->
	<cffunction name="clearMulti" access="public" output="false" returntype="any" hint="Clears objects from the cache by using its cache key. The returned value is a structure of name-value pairs of all the keys that where removed from the operation." colddoc:generic="struct">
		<!--- ************************************************************* --->
		<cfargument name="keys" 		type="any" 	required="true" hint="The comma-delimmitted list or array of keys to remove.">
		<cfargument name="prefix" 		type="any" 	required="false" default="" hint="A prefix to prepend to the keys">
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
		<cfargument name="keySnippet"  	type="any" required="true"  hint="the cache key snippet to use">
		<cfargument name="regex" 		type="any" default="false" hint="Use regex or not" colddoc:generic="boolean">
		<cfargument name="async" 		type="any" default="false" hint="Run command asynchronously or not" colddoc:generic="boolean"/>

		<cfset var threadName = "clearByKeySnippet_#replace(instance.uuidHelper.randomUUID(),"-","","all")#">

		<!--- Async? --->
		<cfif arguments.async AND NOT instance.utility.inThread()>
			<cfthread name="#threadName#" keySnippet="#arguments.keySnippet#" regex="#arguments.regex#">
				<cfset instance.elementCleaner.clearByKeySnippet(attributes.keySnippet,attributes.regex)>
			</cfthread>
		<cfelse>
			<cfset instance.elementCleaner.clearByKeySnippet(arguments.keySnippet,arguments.regex)>
		</cfif>
	</cffunction>

	<!--- clearQuiet --->
	<cffunction name="clearQuiet" access="public" output="false" returntype="any" hint="Clears an object from the cache by using its cache key. Returns false if object was not removed or did not exist anymore" colddoc:generic="boolean">
		<cfargument name="objectKey" type="any"  	required="true" hint="The object cache key">
		<cfscript>
			// clean key
			arguments.objectKey = lcase(trim(arguments.objectKey));

			// clear key
			return instance.objectStore.clear( arguments.objectKey );
		</cfscript>
	</cffunction>

	<!--- clear --->
	<cffunction name="clear" access="public" output="false" returntype="any" hint="Clears an object from the cache by using its cache key. Returns false if object was not removed or did not exist anymore" colddoc:generic="boolean">
		<cfargument name="objectKey" type="any" required="true" hint="The object cache key">
		<cfscript>
			var clearCheck = clearQuiet( arguments.objectKey );
			var iData = {
				cache = this,
				cacheObjectKey 	= arguments.objectKey
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
				cache	= this
			};

			instance.objectStore.clearAll();

			// notify listeners
			getEventManager().processState("afterCacheClearAll",iData);
		</cfscript>
    </cffunction>

	<!--- Clear an object from the cache --->
	<cffunction name="clearKey" access="public" output="false" returntype="any" hint="Deprecated, please use clear()" colddoc:generic="boolean">
		<cfargument name="objectKey" type="any"  	required="true" hint="The object cache key">
		<cfreturn clear( arguments.objectKey )>
	</cffunction>

	<!--- Get the Cache Size --->
	<cffunction name="getSize" access="public" output="false" returntype="any" hint="Get the cache's size in items" colddoc:generic="numeric">
		<cfreturn instance.objectStore.getSize()>
	</cffunction>

	<!--- reap --->
	<cffunction name="reap" access="public" output="false" returntype="void" hint="Reap the cache, clear out everything that is dead.">
		<cfset var threadName = "CacheBoxProvider.reap_#replace(instance.uuidHelper.randomUUID(),"-","","all")#">

		<!--- Reap only if in frequency --->
		<cfif dateDiff("n", getStats().getLastReapDatetime(), now() ) GTE getConfiguration().reapFrequency>

			<!--- check if in thread already --->
			<cfif NOT instance.utility.inThread()>

				<cfthread name="#threadName#">
					<cfset variables._reap()>
				</cfthread>

			<cfelse>
				<cfset _reap()>
			</cfif>

		</cfif>

	</cffunction>

	<!--- _reap --->
	<cffunction name="_reap" access="public" output="false" returntype="void" hint="Reap the cache, clear out everything that is dead.">
		<cfscript>
			var keyIndex 		= 1;
			var cacheKeys 		= "";
			var cacheKeysLen 	= 0;
			var thisKey 		= "";
			var thisMD 			= "";
			var config 			= getConfiguration();
			var sTime			= getTickCount();
		</cfscript>

		<!--- Lock Reaping, so only one can be ran even if called manually, for concurrency protection --->
		<cflock type="exclusive" name="CacheBoxProvider.reap.#instance.cacheID#" timeout="#instance.lockTimeout#">
		<cfscript>

			// log it
			if( instance.logger.canDebug() )
				instance.logger.debug( "Starting to reap CacheBoxProvider: #getName()#, id: #instance.cacheID#" );

			// Run Storage reaping first, before our local algorithm
			instance.objectStore.reap();

			// Let's Get our reaping vars ready, get a duplicate of the pool metadata so we can work on a good copy
			cacheKeys 		= getKeys();
			cacheKeysLen 	= ArrayLen(cacheKeys);

			//Loop through keys
			for (keyIndex=1; keyIndex LTE cacheKeysLen; keyIndex++){

				//The Key to check
				thisKey = cacheKeys[keyIndex];

				//Get the key's metadata thread safe.
				thisMD = getCachedObjectMetadata(thisKey);

				// Check if found, else continue, already reaped.
				if( structIsEmpty(thisMD) ){ continue; }

				//Reap only non-eternal objects
				if ( thisMD.timeout GT 0 ){

					// Check if expired already
					if( thisMD.isExpired ){
						// Clear the object from cache
						if( clear( thisKey ) ){
							// Announce Expiration only if removed, else maybe another thread cleaned it
							announceExpiration(thisKey);
						}
						continue;
					}

					//Check for creation timeouts and clear
					if ( dateDiff("n", thisMD.created, now() ) GTE thisMD.timeout ){

						// Clear the object from cache
						if( clear( thisKey ) ){
							// Announce Expiration only if removed, else maybe another thread cleaned it
							announceExpiration(thisKey);
						}
						continue;
					}

					//Check for last accessed timeouts. If object has not been accessed in the default span
					if ( config.useLastAccessTimeouts AND
					     dateDiff("n", thisMD.LastAccessed, now() ) gte thisMD.LastAccessTimeout ){

						// Clear the object from cache
						if( clear( thisKey ) ){
							// Announce Expiration only if removed, else maybe another thread cleaned it
							announceExpiration(thisKey);
						}
						continue;
					}
				}//end timeout gt 0

			}//end looping over keys

			//Reaping about to end, set new reaping date.
			getStats().setLastReapDatetime( now() );

			// log it
			if( instance.logger.canDebug() )
				instance.logger.debug( "Finished reap in #getTickCount()-sTime#ms for CacheBoxProvider: #getName()#, id: #instance.cacheID#" );
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
	<cffunction name="expireObject" access="public" returntype="void" hint="Expire an Object. Use this instead of clearKey() from within handlers or any cached object, this sets the metadata for the objects to expire in the next request. Note that this is not an inmmediate expiration. Clear should only be used from outside a cached object" output="false" >
		<cfargument name="objectKey" type="any"	required="true" hint="The object cache key">
		<cfscript>
			instance.objectStore.expireObject( lcase(trim(arguments.objectKey)) );
		</cfscript>
	</cffunction>

	<!--- Expire an Object --->
	<cffunction name="expireByKeySnippet" access="public" returntype="void" hint="Same as expireKey but can touch multiple objects depending on the keysnippet that is sent in." output="false" >
		<!--- ************************************************************* --->
		<cfargument name="keySnippet" type="any"  required="true" hint="The key snippet to use">
		<cfargument name="regex" 	  type="any" required="false" default="false" hint="Use regex or not" colddoc:generic="boolean">
		<!--- ************************************************************* --->
		<cfscript>
			var keyIndex 		= 1;
			var cacheKeys 		= getKeys();
			var cacheKeysLen 	= arrayLen(cacheKeys);
			var tester = 0;

			// Loop Through Metadata
			for (keyIndex=1; keyIndex LTE cacheKeysLen; keyIndex++){

				// Using Regex?
				if( arguments.regex ){
					tester = reFindnocase(arguments.keySnippet, cacheKeys[keyIndex]);
				}
				else{
					tester = findnocase(arguments.keySnippet, cacheKeys[keyIndex]);
				}

				// Check if object still exists
				if( tester
				    AND instance.objectStore.lookup( cacheKeys[keyIndex] )
					AND getCachedObjectMetadata(cacheKeys[keyIndex]).timeout GT 0){

					expireObject( cacheKeys[keyIndex] );

				}
			}//end key loops
		</cfscript>
	</cffunction>

	<!--- isExpired --->
    <cffunction name="isExpired" output="false" access="public" returntype="any" hint="Has the object key expired in the cache" colddoc:generic="boolean">
   		<cfargument name="objectKey" type="any" required="true" hint="The object key"/>
		<cfreturn instance.objectStore.isExpired( lcase(trim(arguments.objectKey)) )>
   	</cffunction>

	<!--- getObjectStore --->
	<cffunction name="getObjectStore" output="false" access="public" returntype="any" hint="If the cache provider implements it, this returns the cache's object store as type: coldbox.system.cache.store.IObjectStore" colddoc:generic="coldbox.system.cache.store.IObjectStore">
    	<cfreturn instance.objectStore>
	</cffunction>

	<!--- getStoreMetadataReport --->
	<cffunction name="getStoreMetadataReport" output="false" access="public" returntype="any" hint="Get a structure of all the keys in the cache with their appropriate metadata structures. This is used to build the reporting.[keyX->[metadataStructure]]" colddoc:generic="struct">
		<cfscript>
			var target = instance.objectStore.getIndexer().getPoolMetadata();

			return target;
		</cfscript>
	</cffunction>

	<!--- getStoreMetadataKeyMap --->
	<cffunction name="getStoreMetadataKeyMap" output="false" access="public" returntype="any" hint="Get a key lookup structure where cachebox can build the report on. Ex: [timeout=timeout,lastAccessTimeout=idleTimeout].  It is a way for the visualizer to construct the columns correctly on the reports" colddoc:generic="struct">
		<cfscript>
			var keyMap = {
				timeout = "timeout", hits = "hits", lastAccessTimeout = "lastAccessTimeout",
				created = "created", LastAccessed = "LastAccessed", isExpired="isExpired"
			};
			return keymap;
		</cfscript>
	</cffunction>

	<!--- get Keys --->
	<cffunction name="getKeys" access="public" returntype="any" output="false" hint="Get a listing of all the keys of the objects in the cache" colddoc:generic="array">
		<cfreturn instance.objectStore.getKeys()>
	</cffunction>

	<!--- Get the Java Runtime --->
	<cffunction name="getJavaRuntime" access="public" returntype="any" output="false" hint="Get the java runtime object for reporting purposes.">
		<cfreturn instance.javaRuntime>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->

	<!--- announceExpiration --->
	<cffunction name="announceExpiration" output="false" access="private" returntype="void" hint="Announce an Expiration">
		<cfargument name="objectKey" type="any"	required="true" hint="The object cache key">
		<cfscript>
			var iData = {
				cache = this,
				cacheObjectKey = arguments.objectKey
			};
			// Execute afterCacheElementExpired Interception
			getEventManager().processState("afterCacheElementExpired",iData);
		</cfscript>
	</cffunction>

	<!--- Threshold JVM Checks --->
	<cffunction name="thresholdChecks" access="private" output="false" returntype="boolean" hint="JVM Threshold checks">
		<cfargument name="threshold" type="any" required="true" default="" hint="The threshold to check"/>
		<cfscript>
			var check		 = true;
			var jvmThreshold = 0;

			try{
				jvmThreshold = ( (instance.javaRuntime.getRuntime().freeMemory() / instance.javaRuntime.getRuntime().maxMemory() ) * 100 );
				check = arguments.threshold LT jvmThreshold;
			}
			catch(any e){
				check = true;
			}

			return check;
		</cfscript>
	</cffunction>

</cfcomponent>