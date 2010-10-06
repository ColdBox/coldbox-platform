/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
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
	string function getName() output=false{
		return instance.name;
	}
	
	/**
    * set the cache name
    */    
	void function setName(required string name) output=false{
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
    struct function getConfiguration() output=false{
		return instance.configuration;
	}
	
	/**
    * set the cache configuration structure
    */
    void function setConfiguration(required struct configuration) output=false{
		instance.configuration = arguments.configuration;
	}
	
	/**
    * get the associated cache factory
    */
    coldbox.system.cache.CacheFactory function getCacheFactory() output=false{
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
		
		lock name="Railoprovider.config.#instance.cacheID#" type="exclusive" throwontimeout="true" timeout="20"{
		
			// Prepare the logger
			instance.logger = getCacheFactory().getLogBox().getLogger( this );
			instance.logger.debug("Starting up Railoprovider Cache: #getName()# with configuration: #config.toString()#");
			
			// Validate the configuration
			validateConfiguration();
			
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
	boolean function isEnabled() output=false{
		return instance.enabled;
	} 

	/*
	* Indicates if cache is ready for operation
	*/
	boolean function isReportingEnabled() output=false{
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
    * clear the cache stats
    */
    void function clearStatistics() output=false{
		// not yet posible with railo
	}
	
	/**
    * Returns the ehCache storage session according to configured cache name
    */
    any function getObjectStore() output=false{
		// not yet possible with railo
		//return cacheGetSession( getConfiguration().cacheName );
	}
	
	/**
    * get the cache's metadata report
    */
    struct function getStoreMetadataReport() output=false{ 
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
	struct function getStoreMetadataKeyMap() output="false"{
		var keyMap = {
				timeout = "timespan", hits = "hitcount", lastAccessTimeout = "idleTime",
				created = "createdtime", lastAccesed = "lasthit"
			};
		return keymap;
	}
	
	/**
    * get all the keys in this provider
    */
    array function getKeys() output=false{
		
		if( isDefaultCache() ){
			return cacheGetAllIds();
		}
		
		return cacheGetAllIds("",getConfiguration().cacheName);
	}
	
	/**
    * get an object's cached metadata
    */
    struct function getCachedObjectMetadata(required any objectKey) output=false{
		if( isDefaultCache() ){
			return cacheGetMetadata( arguments.objectKey );
		}
		
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
		// not implemented by railo yet
		return get(arguments.objectKey);
	}
	
	/**
    * Not implemented by this cache
    */
    boolean function isExpired(required any objectKey) output=false{
		return false;
	}
	 
	/**
    * check if object in cache
    */
    boolean function lookup(required any objectKey) output=false{
		if( isDefaultCache() ){
			return cachekeyexists(arguments.objectKey );
		}
		return cachekeyexists(arguments.objectKey, getConfiguration().cacheName );
	}
	
	/**
    * check if object in cache with no stats
    */
    boolean function lookupQuiet(required any objectKey) output=false{
		// not possible yet on railo
		return lookup(arguments.objectKey);
	}
	
	/**
    * set an object in cache
    */
    boolean function set(required any objectKey,
						 required any object,
						 any timeout="0",
						 any lastAccessTimeout="0",
						 struct extra) output=false{
		
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
    boolean function setQuiet(required any objectKey,
						 	   required any object,
						 	   any timeout="0",
						 	   any lastAccessTimeout="0",
						  	   struct extra) output=false{
		
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
    numeric function getSize() output=false{
		if( isDefaultCache() ){
			return cacheCount();
		}
		return cacheCount( getConfiguration().cacheName );
	}
	
	/**
    * Not implemented, let ehCache due its thang!
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
    boolean function clear(required any objectKey) output=false{
		
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
    * clear with no stats
    */
    boolean function clearQuiet(required any objectKey) output=false{
		// normal clear, not implemented by railo
		clear(arguments.objectKey);
		return true;
	}
	
	/**
	* Clear by key snippet
	*/
	void function clearByKeySnippet(required string keySnippet, boolean regex=false, boolean async=false) output=false{
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
	private boolean function isDefaultCache(){
		return  ( getConfiguration().cacheName EQ instance.DEFAULTS.cacheName );
	}
	
	/**
    * set the associated cache factory
    */
    void function setCacheFactory(required coldbox.system.cache.CacheFactory cacheFactory) output=false{
		instance.cacheFactory = arguments.cacheFactory;
	}

}