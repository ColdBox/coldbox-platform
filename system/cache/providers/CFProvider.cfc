/**
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Author: Luis Majano
Description:
	
This CacheBox provider communicates with the built in caches in
the Adobe ColdFusion Engine.

TODO:
 Add user registered cache names

*/
component serializable="false" implements="coldbox.system.cache.ICacheProvider"{

	/**
    * Constructor
    */
	CFProvider function init() output=false{
		instance = {
			name 				= "",
			enabled 			= false,
			reportingEnabled 	= false,
			configuration 		= {},
			cacheFactory 		= "",
			eventManager		= "",
			store				= "",
			cacheID				= createObject('java','java.lang.System').identityHashCode(this),
			defaultCacheName	= "object"
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
    * configure the cache for operation
    */
    void function configure() output=false{
		var config = getConfiguration();
		
		// Prepare the logger
		instance.logger = getCacheFactory().getLogBox().getLogger( this );
		instance.logger.debug("Starting up CFProvider Cache: #getName()# with configuration: #config.toString()#");
		
		// link cacheName according to property if defined, else use default
		if( NOT structKeyExists(config,"cacheName") ){
			config.cacheName = instance.defaultCacheName;
		}
		
		// enabled cache
		instance.enabled = true;
		instance.logger.info("Cache #getName()# started up successfully");
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
    struct function getStoreMetadataReport() output=false{ 
		//TODO: implement this
	}
	
	/**
    * get all the keys in this provider
    */
    array function getKeys() output=false{
		return cacheGetAllIds();
	}
	
	/**
    * get an object's cached metadata
    */
    struct function getCachedObjectMetadata(required any objectKey) output=false{
		return cacheGetMetadata( arguments.objectKey );
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
    boolean function isExpired(required any objectKey) output=false{
		var target = cacheGet(arguments.objectKey);
		return (isNull(target));
	}
	 
	/**
    * check if object in cache
    */
    boolean function lookup(required any objectKey) output=false{
		return lookupQuiet(arguments.objectKey);
	}
	
	/**
    * check if object in cache with no stats
    */
    boolean function lookupQuiet(required any objectKey) output=false{
		return getObjectStore().isKeyInCache( ucase(arguments.objectKey) );
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
		
		cachePut(arguments.objectKey,arguments.object,arguments.timeout,arguments.lastAccessTimeout);
		
		return true;
	}	
		
	/**
    * get cache size
    */
    numeric function getSize() output=false{
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
		getObjectStore().removeAll();
	}
	
	/**
    * clear an element from cache
    */
    boolean function clear(required any objectKey) output=false{
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
    boolean function clearQuiet(required any objectKey) output=false{
		getObjectStore().removeQuiet( ucase(arguments.objectKey) );
		return true;
	}
	
	/**
    * not implemented by cache
    */
    void function expireAll() output=false{ 
		//not implemented 
	}
	
	/**
    * not implemented by cache
    */
    void function expireKey(required any objectKey) output=false{
		//not implemented
	}
	
	/**
    * set the associated cache factory
    */
    void function setCacheFactory(required coldbox.system.cache.CacheFactory cacheFactory) output=false{
		instance.cacheFactory = arguments.cacheFactory;
	}

}
			 
