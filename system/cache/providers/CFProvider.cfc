/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Author: Luis Majano
Description:
	
This CacheBox provider communicates with the built in caches in
the Adobe ColdFusion Engine.

*/
component serializable="false" implements="coldbox.system.cache.ICacheProvider"{

	/**
    * Constructor
    */
	CFProvider function init() output=false{
		// Setup Cache instance
		instance = {
			// cache name
			name 				= "",
			// enabled cache flag
			enabled 			= false,
			// reporting enabled flag
			reportingEnabled 	= false,
			// configuration structure
			configuration 		= {},
			// cache factory reference
			cacheFactory 		= "",
			// event manager reference
			eventManager		= "",
			// reference to underlying data store
			store				= "",
			// internal cache id
			cacheID				= createObject('java','java.lang.System').identityHashCode(this),
			// Element Cleaner Helper
			elementCleaner		= CreateObject("component","coldbox.system.cache.util.ElementCleaner").init(this),
			// Utilities
			utility				= createObject("component","coldbox.system.core.util.Util"),
			// uuid creation helper
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
    void function setConfiguration(required configuration) output=false{
		instance.configuration = arguments.configuration;
	}
	
	/**
    * get the associated cache factory
    */
    any function getCacheFactory() output=false{
		return instance.cacheFactory;
	}
	
	/**
	* Validate the configuration
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
		
		lock name="CFProvider.config.#instance.cacheID#" type="exclusive" throwontimeout="true" timeout="20"{
		
			// Prepare the logger
			instance.logger = getCacheFactory().getLogBox().getLogger( this );
			instance.logger.debug("Starting up CFProvider Cache: #getName()# with configuration: #config.toString()#");
			
			// Validate the configuration
			validateConfiguration();
			
			// Merge configurations
			props = cacheGetProperties();
			var key = "";
			for(key in props){
				config["ehcache_#key.objectType#"] = key;
			}
			
			// enabled cache
			instance.enabled = true;
			instance.reportingEnabled = true;
			instance.logger.info("Cache #getName()# started up successfully");
		}
		
	}
	
	/**
    * shutdown the cache
    */
    void function shutdown() output=false{
		instance.logger.info("CFProvider Cache: #getName()# has been shutdown.");
	}
	
	/*
	* Indicates if cache is ready for operation
	*/
	any function isEnabled() output=false{
		return instance.enabled;
	} 

	/*
	* Indicates if cache is ready for operation
	*/
	any function isReportingEnabled() output=false{
		return instance.reportingEnabled;
	}
	
	/*
	* Indicates if the cache is Terracota clustered
	*/
	any function isTerracotaClustered(){
		return getObjectStore().isTerracottaClustered();
	}
	
	/*
	* Indicates if the cache node is coherent
	*/
	any function isNodeCoherent(){
		return getObjectStore().isNodeCoherent();
	}
	
	/*
	* Returns true if the cache is in coherent mode cluster-wide.
	*/
	any function isClusterCoherent(){
		return getObjectStore().isClusterCoherent();
	}
	
	/*
	* Get the cache statistics object as coldbox.system.cache.util.ICacheStats
	* @colddoc:generic coldbox.system.cache.util.ICacheStats
	*/
	any function getStats() output=false{
		return CreateObject("component", "coldbox.system.cache.providers.cf-lib.CFStats").init( getObjectStore().getStatistics() );		
	}
	
	/**
    * clear the cache stats
    */
    void function clearStatistics() output=false{
		getObjectStore().clearStatistics();
	}
	
	/**
    * Returns the ehCache storage session according to configured cache name
    */
    any function getObjectStore() output=false{
		// get the cache session according to set name
		return cacheGetSession( getConfiguration().cacheName );
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
				created = "createdtime", lastAccesed = "lasthit"
			};
		return keymap;
	}
	
	/**
    * get all the keys in this provider
    */
    any function getKeys() output=false{
		var thisCacheName = getConfiguration().cacheName;
		if( thisCacheName eq "object" ){
			return cacheGetAllIds();
		}
		return cacheGetAllIds(thisCacheName);
	}
	
	/**
    * get an object's cached metadata
    */
    any function getCachedObjectMetadata(required any objectKey) output=false{
		return cacheGetMetadata( arguments.objectKey, getConfiguration().cacheName );
	}
	
	/**
    * get an item from cache
    */
    any function get(required any objectKey) output=false{
		return cacheGet( arguments.objectKey );
	}
	
	/**
    * get an item silently from cache, no stats advised
    */
    any function getQuiet(required any objectKey) output=false{
		var element = getObjectStore().getQuiet( ucase(arguments.objectKey) );
		if( NOT isNull(element) ){
			return element.getValue();
		}
	}
	
	/**
    * Not implemented by this cache
    */
    any function isExpired(required any objectKey) output=false{
		var element = getObjectStore().getQuiet( ucase(arguments.objectKey) );
		if( NOT isNull(element) ){
			return element.isExpired();
		}
		return true;
	}
	 
	/**
    * check if object in cache
    */
    any function lookup(required any objectKey) output=false{
		return lookupQuiet(arguments.objectKey);
	}
	
	/**
    * check if object in cache with no stats
    */
    any function lookupQuiet(required any objectKey) output=false{
		return getObjectStore().isKeyInCache( ucase(arguments.objectKey) );
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
    * set an object in cache with no stats
    */
    any function setQuiet(required any objectKey,
						  required any object,
						  any timeout="0",
						  any lastAccessTimeout="0",
						  any extra) output=false{
		
		// check if incoming timoeut is a timespan or minute to convert to timespan
		if( findnocase("string", arguments.timeout.getClass().getName() ) ){
			arguments.timeout = createTimeSpan(0,0,arguments.timeout,0);
		}
		if( findnocase("string", arguments.lastAccessTimeout.getClass().getName() ) ){
			arguments.lastAccessTimeout = createTimeSpan(0,0,arguments.lastAccessTimeout,0);
		}
		
		cachePut(arguments.objectKey,arguments.object,arguments.timeout,arguments.lastAccessTimeout);
		
		return true;
	}	
		
	/**
    * get cache size
    */
    any function getSize() output=false{
		return getObjectStore().getSize();
	}
	
	/**
    * Not implemented, let ehCache due its thang!
    */
    void function reap() output=false{
		// Not implemented, let ehCache due its thang!		
	}
	
	/**
    * clear all elements from cache
    */
    void function clearAll() output=false{
		var iData = {
			cache	= this
		};
		
		getObjectStore().removeAll();	
		
		// notify listeners		
		getEventManager().processState("afterCacheClearAll",iData);
	}
	
	/**
    * clear an element from cache
    */
    any function clear(required any objectKey) output=false{
		cacheRemove( arguments.objectKey );
		
		//ColdBox events
		var iData = { 
			cache				= this,
			cacheObjectKey 		= arguments.objectKey
		};		
		getEventManager().processState("afterCacheElementRemoved",iData);
		
		return true;
	}
	
	/**
    * clear with no stats
    */
    any function clearQuiet(required any objectKey) output=false{
		getObjectStore().removeQuiet( ucase(arguments.objectKey) );
		return true;
	}
	
	/**
	* Clear by key snippet
	*/
	void function clearByKeySnippet(required keySnippet,regex=false,async=false) output=false{
		var threadName = "clearByKeySnippet_#replace(instance.uuidHelper.randomUUID(),"-","","all")#";
		
		// Async? IF so, do checks
		if( arguments.async AND NOT instance.utility.inThread() ){
			thread name="#threadName#"{
				instance.elementCleaner.clearByKeySnippet(arguments.keySnippet,arguments.regex);
			}
		}
		else{
			instance.elementCleaner.clearByKeySnippet(arguments.keySnippet,arguments.regex);
		}
	}
	
	/**
    * not implemented by cache
    */
    void function expireAll() output=false{ 
		// Just try to evict stuff, not a way to expire all elements.
		getObjectStore().evictExpiredElements();
	}
	
	/**
    * not implemented by cache
    */
    void function expireObject(required any objectKey) output=false{
		//not implemented
	}
	
	/**
    * set the associated cache factory
    */
    void function setCacheFactory(required any cacheFactory) output=false{
		instance.cacheFactory = arguments.cacheFactory;
	}

}
			 
