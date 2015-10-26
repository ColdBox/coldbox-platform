/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************
Author: Luis Majano
Description:
	
This CacheBox provider communicates with the built in caches in
the Railo Engine

*/
component serializable="false" implements="coldbox.system.cache.ICacheProvider"{

	/**
    * Constructor
    */
	RailoProvider function init() output=false{
		// prepare instance data
		instance = {
			// provider name
			name 				= "",
			// provider enable flag
			enabled 			= false,
			// reporting enabled flag
			reportingEnabled 	= false,
			// configuration structure
			configuration 		= {},
			// cacheFactory composition
			cacheFactory 		= "",
			// event manager composition
			eventManager		= "",
			// storage composition, even if it does not exist, depends on cache
			store				= "",
			// the cache identifier for this provider
			cacheID				= createObject('java','java.lang.System').identityHashCode(this),
			// Element Cleaner Helper
			elementCleaner		= CreateObject("component","coldbox.system.cache.util.ElementCleaner").init(this),
			// Utilities
			utility				= createObject("component","coldbox.system.core.util.Util"),
			// our UUID creation helper
			uuidHelper			= createobject("java", "java.util.UUID")
		};
		
		// Provider Property Defaults
		instance.DEFAULTS = {
			cacheName = "object"
		};		
		
		return this;
	}
	
	/**
    * get the cache name
    */    
	any function getName() output=false{
		return instance.name;
	}
	
	/**
    * set the cache name
    */    
	void function setName(required name) output=false{
		instance.name = arguments.name;
	}
	
	/**
    * set the event manager
    */
    void function setEventManager(required any EventManager) output=false{
    	instance.eventManager = arguments.eventManager;
    }
	
    /**
    * get the event manager
    */
    any function getEventManager() output=false{
    	return instance.eventManager;
    }
    
	/**
    * get the cache configuration structure
    */
    any function getConfiguration() output=false{
		return instance.configuration;
	}
	
	/**
    * set the cache configuration structure
    */
    void function setConfiguration(required any configuration) output=false{
		instance.configuration = arguments.configuration;
	}
	
	/**
    * get the associated cache factory
    */
    any function getCacheFactory() output=false{
		return instance.cacheFactory;
	}
	
	/**
	* Validate the incoming configuration and make necessary defaults
	**/
	private void function validateConfiguration(){
		var cacheConfig = getConfiguration();
		var key			= "";
		
		// Validate configuration values, if they don't exist, then default them to DEFAULTS
		for(key in instance.DEFAULTS){
			if( NOT structKeyExists(cacheConfig, key) OR NOT len(cacheConfig[key]) ){
				cacheConfig[key] = instance.DEFAULTS[key];
			}
		}
	}
	
	/**
    * configure the cache for operation
    */
    void function configure() output=false{
		var config 	= getConfiguration();
		var props	= [];
		
		lock name="Railoprovider.config.#instance.cacheID#" type="exclusive" throwontimeout="true" timeout="20"{
		
			// Prepare the logger
			instance.logger = getCacheFactory().getLogBox().getLogger( this );
			
			if( instance.logger.canDebug() )
				instance.logger.debug( "Starting up Railoprovider Cache: #getName()# with configuration: #config.toString()#" );
			
			// Validate the configuration
			validateConfiguration();
			
			// enabled cache
			instance.enabled = true;
			instance.reportingEnabled = true;
			
			if( instance.logger.canDebug() )
				instance.logger.debug( "Cache #getName()# started up successfully" );
		}
		
	}
	
	/**
    * shutdown the cache
    */
    void function shutdown() output=false{
		//nothing to shutdown
		if( instance.logger.canDebug() )
			instance.logger.debug( "RailoProvider Cache: #getName()# has been shutdown." );
	}
	
	/*
	* Indicates if cache is ready for operation
	*/
	any function isEnabled() output=false{
		return instance.enabled;
	} 

	/*
	* Indicates if cache is ready for reporting
	*/
	any function isReportingEnabled() output=false{
		return instance.reportingEnabled;
	}
	
	/*
	* Get the cache statistics object as coldbox.system.cache.util.ICacheStats
	* @colddoc:generic coldbox.system.cache.util.ICacheStats
	*/
	any function getStats() output=false{
		return createObject("component", "coldbox.system.cache.providers.railo-lib.RailoStats").init( this );		
	}
	
	/**
    * clear the cache stats: Not enabled in this provider
    */
    void function clearStatistics() output=false{
		// not yet posible with railo
	}
	
	/**
    * Returns the underlying cache engine: Not enabled in this provider
    */
    any function getObjectStore() output=false{
		// not yet possible with railo
		//return cacheGetSession( getConfiguration().cacheName );
	}
	
	/**
    * get the cache's metadata report
    */
    any function getStoreMetadataReport() output=false{ 
		var md 		= {};
		var keys 	= getKeys();
		var item	= "";
		
		for(item in keys){
			md[item] = getCachedObjectMetadata(item);
		}
		
		return md;
	}
	
	/**
	* Get a key lookup structure where cachebox can build the report on. Ex: [timeout=timeout,lastAccessTimeout=idleTimeout].  It is a way for the visualizer to construct the columns correctly on the reports
	*/
	any function getStoreMetadataKeyMap() output="false"{
		var keyMap = {
				timeout = "timespan", hits = "hitcount", lastAccessTimeout = "idleTime",
				created = "createdtime", LastAccessed = "lasthit"
			};
		return keymap;
	}
	
	/**
    * get all the keys in this provider
    */
    any function getKeys() output=false{
		try{
			if( isDefaultCache() ){
				return cacheGetAllIds();
			}
			
			return cacheGetAllIds( "", getConfiguration().cacheName );
		}
		catch(Any e){
			instance.logger.error( "Error retrieving all keys from cache: #e.message# #e.detail#", e.stacktrace );
			return [ "Error retrieving keys from cache: #e.message#" ];
		}
	}
	
	/**
    * get an object's cached metadata
    */
    any function getCachedObjectMetadata(required any objectKey) output=false{
		if( isDefaultCache() ){
			return cacheGetMetadata( arguments.objectKey );
		}
		
		return cacheGetMetadata( arguments.objectKey, getConfiguration().cacheName );
	}
	
	/**
    * get an item from cache
    */
    any function get(required any objectKey) output=false{
	
		if( isDefaultCache() ){
			return cacheGet( arguments.objectKey );
		}
		else{
			return cacheGet( arguments.objectKey, false, getConfiguration().cacheName );
		}
	}
	
	/**
    * get an item silently from cache, no stats advised: Stats not available on railo
    */
    any function getQuiet(required any objectKey) output=false{
		// not implemented by railo yet
		return get(arguments.objectKey);
	}
	
	/**
    * Not implemented by this cache
    */
    any function isExpired(required any objectKey) output=false{
		return false;
	}
	 
	/**
    * check if object in cache
    */
    any function lookup(required any objectKey) output=false{
		if( isDefaultCache() ){
			return cachekeyexists(arguments.objectKey );
		}
		return cachekeyexists(arguments.objectKey, getConfiguration().cacheName );
	}
	
	/**
    * check if object in cache with no stats: Stats not available on railo
    */
    any function lookupQuiet(required any objectKey) output=false{
		// not possible yet on railo
		return lookup(arguments.objectKey);
	}
	
	/**
    * Tries to get an object from the cache, if not found, it calls the 'produce' closure to produce the data and cache it
    */
    any function getOrSet(
    	required any objectKey,
		required any produce,
		any timeout="0",
		any lastAccessTimeout="0",
		any extra={}
	){
		
		var refLocal = {
			object = get( arguments.objectKey )
		};
		
		// Verify if it exists? if so, return it.
		if( structKeyExists( refLocal, "object" ) ){ return refLocal.object; }
		
		// else, produce it
		lock name="CacheBoxProvider.GetOrSet.#instance.cacheID#.#arguments.objectKey#" type="exclusive" timeout="10" throwonTimeout="true"{
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
		}
		
		return refLocal.object;
	}
	
	/**
    * set an object in cache
    */
    any function set(required any objectKey,
					 required any object,
					 any timeout="0",
					 any lastAccessTimeout="0",
					 any extra) output=false{
		
		setQuiet(argumentCollection=arguments);
		
		//ColdBox events
		var iData = { 
			cache				= this,
			cacheObject			= arguments.object,
			cacheObjectKey 		= arguments.objectKey,
			cacheObjectTimeout 	= arguments.timeout,
			cacheObjectLastAccessTimeout = arguments.lastAccessTimeout
		};		
		getEventManager().processState("afterCacheElementInsert",iData);
		
		return true;
	}	
	
	/**
    * set an object in cache with no advising to events
    */
    any function setQuiet(required any objectKey,
						  required any object,
						  any timeout="0",
						  any lastAccessTimeout="0",
						  any extra) output=false{
		
		// check if incoming timoeut is a timespan or minute to convert to timespan
		if( !findnocase("timespan", arguments.timeout.getClass().getName() ) ){
			if( !isNumeric( arguments.timeout ) ){ arguments.timeout = 0; }
			arguments.timeout = createTimeSpan(0,0,arguments.timeout,0);
		}
		if( !findnocase("timespan", arguments.lastAccessTimeout.getClass().getName() ) ){
			if( !isNumeric( arguments.lastAccessTimeout ) ){ arguments.lastAccessTimeout = 0; }
			arguments.lastAccessTimeout = createTimeSpan(0,0,arguments.lastAccessTimeout,0);
		}
		// Cache it
		if( isDefaultCache() ){
			cachePut(arguments.objectKey,arguments.object,arguments.timeout,arguments.lastAccessTimeout);
		}
		else{
			cachePut(arguments.objectKey,arguments.object,arguments.timeout,arguments.lastAccessTimeout, getConfiguration().cacheName);
		}
		
		return true;
	}	
		
	/**
    * get cache size
    */
    any function getSize() output=false{
		if( isDefaultCache() ){
			return cacheCount();
		}
		return cacheCount( getConfiguration().cacheName );
	}
	
	/**
    * Not implemented by this cache
    */
    void function reap() output=false{
		// Not implemented by this provider
	}
	
	/**
    * clear all elements from cache
    */
    void function clearAll() output=false{
		var iData = {
			cache	= this
		};
		
		if( isDefaultCache() ){
			cacheClear();
		}
		else{
			cacheClear("",getConfiguration().cacheName);
		}
		
		// notify listeners		
		getEventManager().processState("afterCacheClearAll",iData);
	}
	
	/**
    * clear an element from cache
    */
    any function clear(required any objectKey) output=false{
		
		if( isDefaultCache() ){
			cacheRemove( arguments.objectKey );
		}
		else{
			cacheRemove( arguments.objectKey ,false, getConfiguration().cacheName );
		}
		
		//ColdBox events
		var iData = { 
			cache				= this,
			cacheObjectKey 		= arguments.objectKey
		};		
		getEventManager().processState("afterCacheElementRemoved",iData);
		
		return true;
	}
	
	/**
    * clear with no advising to events
    */
    any function clearQuiet(required any objectKey) output=false{
		// normal clear, not implemented by railo
		clear(arguments.objectKey);
		return true;
	}
	
	/**
	* Clear by key snippet
	*/
	void function clearByKeySnippet(required keySnippet, regex=false, async=false) output=false{
		var threadName = "clearByKeySnippet_#replace(instance.uuidHelper.randomUUID(),"-","","all")#";
		
		// Async? IF so, do checks
		if( arguments.async AND NOT instance.utility.inThread() ){
			thread name="#threadName#" keySnippet="#arguments.keySnippet#" regex="#arguments.regex#"{
				instance.elementCleaner.clearByKeySnippet( attribues.keySnippet, attribues.regex );
			}
		}
		else{
			instance.elementCleaner.clearByKeySnippet( arguments.keySnippet, arguments.regex );
		}
	}
	
	/**
    * not implemented by cache
    */
    void function expireAll() output=false{ 
		// Not implemented by this cache
	}
	
	/**
    * not implemented by cache
    */
    void function expireObject(required any objectKey) output=false{
		//not implemented
	}
	
	/**
	* Checks if the default cache is in use
	*/
	private any function isDefaultCache(){
		return  ( getConfiguration().cacheName EQ instance.DEFAULTS.cacheName );
	}
	
	/**
    * set the associated cache factory
    */
    void function setCacheFactory(required any cacheFactory) output=false{
		instance.cacheFactory = arguments.cacheFactory;
	}

}