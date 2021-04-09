/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * @author Luis Majano
 *
 * This CacheBox provider communicates with the built in caches in the Adobe ColdFusion Engines
 */
component
	accessors="true"
	serializable="false"
	implements="coldbox.system.cache.providers.ICacheProvider"
	extends="coldbox.system.cache.AbstractCacheBoxProvider"
{

	/**
	 * The global element cleaner utility object
	 */
	property name="elementCleaner";

	// Provider Property Defaults STATIC
	variables.DEFAULTS = {
		cacheName = "object"
	};

	/**
     * Constructor
     */
	function init(){
		super.init();

		// Element Cleaner Helper
		variables.elementCleaner = new coldbox.system.cache.util.ElementCleaner( this );

		return this;
	}

	/**
     * configure the cache for operation
	 *
	 * @return LuceeProvider
     */
    function configure(){
		var config 	= getConfiguration();
		var props	= [];

		lock name="CFProvider.config.#variables.cacheID#" type="exclusive" throwontimeout="true" timeout="30"{

			// Prepare the logger
			variables.logger = getCacheFactory().getLogBox().getLogger( this );

			if( variables.logger.canDebug() ){
				variables.logger.debug( "Starting up CFProvider Cache: #getName()# with configuration: #config.toString()#" );
			}

			// Validate the configuration
			validateConfiguration();

			// Merge configurations
			var thisCacheName = config.cacheName;
			if ( thisCacheName == "object") {
				props = cacheGetProperties();
			} else {

				// this force CF to create the user defined cache if it doesn't exist
				get("___invalid___");

				var cacheConfig = cacheGetSession( thisCacheName, true ).getCacheConfiguration();

				// apply parameter configurations
				if ( structKeyExists( config, "clearOnFlush") ) {
					cacheConfig.setClearOnFlush( config.clearOnFlush );
				}
				if ( structKeyExists( config, "diskExpiryThreadIntervalSeconds") ) {
					cacheConfig.setDiskExpiryThreadIntervalSeconds( config.diskExpiryThreadIntervalSeconds );
				}
				if ( structKeyExists( config, "diskPersistent") ) {
					cacheConfig.setDiskPersistent( config.diskPersistent );
				}
				if ( structKeyExists( config, "diskSpoolBufferSizeMB") ) {
					cacheConfig.setDiskSpoolBufferSizeMB( config.diskSpoolBufferSizeMB );
				}
				if ( structKeyExists( config, "eternal") ) {
					cacheConfig.setEternal( config.eternal );
				}
				if ( structKeyExists( config, "maxElementsInMemory") ) {
					cacheConfig.setMaxElementsInMemory( config.maxElementsInMemory );
				}
				if ( structKeyExists( config, "maxElementsOnDisk") ) {
					cacheConfig.setMaxElementsOnDisk( config.maxElementsOnDisk );
				}
				if ( structKeyExists( config, "memoryEvictionPolicy") ) {
					cacheConfig.setMemoryStoreEvictionPolicy( config.memoryEvictionPolicy );
				}
				if ( structKeyExists( config, "overflowToDisk") ) {
					cacheConfig.setOverflowToDisk( config.overflowToDisk );
				}
				if ( structKeyExists( config, "timeToIdleSeconds") ) {
					cacheConfig.setTimeToIdleSeconds( config.timeToIdleSeconds );
				}
				if ( structKeyExists( config, "timeToLiveSeconds") ) {
					cacheConfig.setTimeToLiveSeconds( config.timeToLiveSeconds );
				}

				props = [{
					"objectType" = config.cacheName
					, "clearOnFlush" = cacheConfig.isClearOnFlush()
					, "diskExpiryThreadIntervalSeconds" = cacheConfig.getDiskExpiryThreadIntervalSeconds()
					, "diskPersistent" = cacheConfig.isDiskPersistent()
					, "diskSpoolBufferSizeMB" = cacheConfig.getDiskSpoolBufferSizeMB()
					, "eternal" = cacheConfig.isEternal()
					, "maxElementsInMemory" = cacheConfig.getMaxElementsInMemory()
					, "maxElementsOnDisk" = cacheConfig.getMaxElementsOnDisk()
					, "memoryEvictionPolicy" = cacheConfig.getMemoryStoreEvictionPolicy().toString()
					, "overflowToDisk" = cacheConfig.isOverflowToDisk()
					, "timeToIdleSeconds" = cacheConfig.getTimeToIdleSeconds()
					, "timeToLiveSeconds" = cacheConfig.getTimeToLiveSeconds()
				}];
			}

			for( var key in props ){
				config[ "ehcache_#key.objectType#" ] = key;
			}

			// enabled cache
			variables.enabled = true;
			variables.reportingEnabled = true;

			if( variables.logger.canDebug() ){
				variables.logger.debug( "Cache #getName()# started up successfully" );
			}
		}

		return this;
	}

	/**
     * Shutdown command issued when CacheBox is going through shutdown phase
	 *
	 * @return LuceeProvider
     */
    function shutdown(){
		//nothing to shutdown
		if( variables.logger.canDebug() ){
			variables.logger.debug( "CFProvider Cache: #getName()# has been shutdown." );
		}
		return this;
	}

	/*
	 * Indicates if the cache is Terracota clustered
	 */
	boolean function isTerracotaClustered(){
		return getObjectStore().isTerracottaClustered();
	}

	/*
	 * Indicates if the cache node is coherent
	 */
	boolean function isNodeCoherent(){
		return getObjectStore().isNodeCoherent();
	}

	/*
	 * Returns true if the cache is in coherent mode cluster-wide.
	 */
	boolean function isClusterCoherent(){
		return getObjectStore().isClusterCoherent();
	}

	/**
	 * Get the cache statistics object as coldbox.system.cache.util.IStats
	 *
	 * @return coldbox.system.cache.util.IStats
	 */
	function getStats(){
		return new "coldbox.system.cache.providers.cf-lib.CFStats"( getObjectStore().getStatistics() );
	}

	/**
	 * Clear the cache statistics
	 * NOT IMPLEMENTED FOR ACF 2016+
	 *
	 * @return ICacheProvider
	 */
	function clearStatistics(){
		// New version of ehcache removed this feature.
		return this;
	}

	/**
	 * If the cache provider implements it, this returns the cache's object store.
	 *
	 * @return coldbox.system.cache.store.IObjectStore or any depending on the cache implementation
	 */
	function getObjectStore(){
		// get the cache session according to set name
		var thisCacheName = getConfiguration().cacheName;
		if( thisCacheName == "object"){
			return cacheGetSession( "object" );
		} else {
			return cacheGetSession( thisCacheName, true );
		}
	}

	/**
     * Get a structure of all the keys in the cache with their appropriate metadata structures. This is used to build the reporting.[keyX->[metadataStructure]]
     */
    struct function getStoreMetadataReport(){
		return getKeys()
			.reduce( function( result, item ){
				result[ item ] = getCachedObjectMetadata( item );
				return result;
			}, {} );
	}

	/**
	 * Get a key lookup structure where cachebox can build the report on. Ex: [timeout=timeout,lastAccessTimeout=idleTimeout].  It is a way for the visualizer to construct the columns correctly on the reports
	 */
	struct function getStoreMetadataKeyMap(){
		return {
			timeout           = "timespan",
			hits              = "hitcount",
			lastAccessTimeout = "idleTime",
			created           = "createdtime",
			lastAccessed      = "lasthit"
		};
	}

	/**
	 * Returns a list of all elements in the cache, whether or not they are expired
	 */
	array function getKeys(){
	   try{
	   	    var thisCacheName = getConfiguration().cacheName;
			if ( thisCacheName == "object") {
				return cacheGetAllIds();
			}
			return cacheGetAllIds( thisCacheName );
		} catch( Any e ) {
			variables.logger.error( "Error retrieving all keys from cache: #e.message# #e.detail#", e.stacktrace );
			return [ "Error retrieving keys from cache: #e.message#" ];
		}
	}

	/**
	 * Get a cache objects metadata about its performance. This value is a structure of name-value pairs of metadata.
	 *
	 * @objectKey The key to retrieve
	 */
    struct function getCachedObjectMetadata( required objectKey ){
		var thisCacheName = getConfiguration().cacheName;
   		if ( thisCacheName == "object") {
			return cacheGetMetadata( arguments.objectKey );
		} else {
			return cacheGetMetadata( arguments.objectName, thisCacheName );
		}
	}

	/**
	 * Get an object from the cache
	 *
	 * @objectKey The key to retrieve
	 */
    function get( required objectKey ){
		var thisCacheName = getConfiguration().cacheName;
	    if ( thisCacheName == "object") {
			return cacheGet( arguments.objectKey );
		} else {
			return cacheGet( arguments.objectKey, thisCacheName );
		}
	}

	/**
     * Tries to get an object from the cache, if not found, it calls the 'produce' closure to produce the data and cache it
	 *
	 * @objectKey The object cache key
	 * @produce The producer closure/lambda
	 * @timeout The timeout to use on the object (if any, provider specific)
	 * @lastAccessTimeout The idle timeout to use on the object (if any, provider specific)
	 * @extra A map of name-value pairs to use as extra arguments to pass to a providers set operation
	 *
	 * @return The cached or produced data/object
     */
    any function getOrSet(
    	required any objectKey,
		required any produce,
		any timeout="0",
		any lastAccessTimeout="0",
		any extra={}
	){
		return super.getOrSet( argumentCollection=arguments );
	}

	/**
     * get an item silently from cache, no stats advised: Stats not available on lucee
	 *
	 * @objectKey The key to retrieve
     */
    function getQuiet( required objectKey ){
		// Don't touch the casing on 2018+
		if( listFind( "2018,2021", server.coldfusion.productVersion.listFirst() ) ){
			var element = getObjectStore().getQuiet( arguments.objectKey );
		} else {
			var element = getObjectStore().getQuiet( ucase( arguments.objectKey ) );
		}

		if( !isNull( local.element ) ){
			return element.getValue();
		}
	}

	/**
	 * Has the object key expired in the cache: NOT IMPLEMENTED IN THIS CACHE
	 *
	 * @objectKey The key to retrieve
	 */
	boolean function isExpired( required objectKey ){
		return false;
	}

	/**
	 * Check if an object is in cache, if not found it records a miss.
	 *
	 * @objectKey The key to retrieve
	 */
	boolean function lookup( required objectKey ){
		return lookupQuiet( arguments.objectKey );
	}

	/**
	 * Check if an object is in cache, no stats updated or listeners
	 *
	 * @objectKey The key to retrieve
	 */
	boolean function lookupQuiet( required objectKey ){
		var thisCacheName = getConfiguration().cacheName;
	    if ( thisCacheName == "object") {
			return cacheIdExists( arguments.objectKey );
		} else {
			return cacheIdExists( arguments.objectKey, thisCacheName );
		}
	}

	/**
	 * Sets an object in the cache and returns an instance of itself
	 *
	 * @objectKey The object cache key
	 * @object The object to cache
	 * @timeout The timeout to use on the object (if any, provider specific)
	 * @lastAccessTimeout The idle timeout to use on the object (if any, provider specific)
	 * @extra A map of name-value pairs to use as extra arguments to pass to a providers set operation
	 *
	 * @return ICacheProvider
	 */
	function set(
		required objectKey,
		required object,
		timeout=0,
		lastAccessTimeout=0,
		struct extra
	){

		setQuiet( argumentCollection=arguments );

		//ColdBox events
		var iData = {
			cache				= this,
			cacheObject			= arguments.object,
			cacheObjectKey 		= arguments.objectKey,
			cacheObjectTimeout 	= arguments.timeout,
			cacheObjectLastAccessTimeout = arguments.lastAccessTimeout
		};
		getEventManager().announce( "afterCacheElementInsert", iData );

		return this;
	}

	/**
	 * Sets an object in the cache with no event calls and returns an instance of itself
	 *
	 * @objectKey The object cache key
	 * @object The object to cache
	 * @timeout The timeout to use on the object (if any, provider specific)
	 * @lastAccessTimeout The idle timeout to use on the object (if any, provider specific)
	 * @extra A map of name-value pairs to use as extra arguments to pass to a providers set operation
	 *
	 * @return ICacheProvider
	 */
	function setQuiet(
		required objectKey,
		required object,
		timeout=0,
		lastAccessTimeout=0,
		struct extra
	){

		// check if incoming timeout is a timespan or minute to convert to timespan, do also checks if empty strings
		if( findnocase("string", arguments.timeout.getClass().getName() ) ){
			if( len(arguments.timeout) ){ arguments.timeout = createTimeSpan(0,0,arguments.timeout,0); }
			else{ arguments.timeout = 0; }
		}
		if( findnocase("string", arguments.lastAccessTimeout.getClass().getName() ) ){
			if( len(arguments.lastAccessTimeout) ){ arguments.lastAccessTimeout = createTimeSpan(0,0,arguments.lastAccessTimeout,0); }
			else{ arguments.lastAccessTimeout = 0; }
		}

		var thisCacheName = getConfiguration().cacheName;
		if ( thisCacheName == "object" ) {
			// if we passed object to the cache put CF would use a user defined custom "object" cache rather than the default
			cachePut(
				arguments.objectKey,
				arguments.object,
				arguments.timeout,
				arguments.lastAccessTimeout
			);
		} else {
			cachePut(
				arguments.objectKey,
				arguments.object,
				arguments.timeout,
				arguments.lastAccessTimeout,
				thisCacheName
			);
		}

		return this;
	}

	/**
	 * Get the number of elements in the cache
	 */
	numeric function getSize(){
		return getObjectStore().getSize();
	}

	/**
	 * Send a reap or flush command to the cache: Not implemented by this provider
	 *
	 * @return ICacheProvider
	 */
	function reap(){
		return this;
	}

	/**
	 * Clear all the cache elements from the cache
	 *
	 * @return ICacheProvider
	 */
	function clearAll(){
		var thisCacheName = getConfiguration().cacheName;
   		if ( thisCacheName == "object") {
			cacheRemoveAll();
		} else {
			cacheRemoveAll( thisCacheName );
		}

		// notify listeners
		getEventManager().announce( "afterCacheClearAll", { cache = this } );
	}

	/**
	 * Clears an object from the cache by using its cache key. Returns false if object was not removed or did not exist anymore
	 *
	 * @objectKey The object cache key
	 */
	boolean function clear( required objectKey ){
		var thisCacheName = getConfiguration().cacheName;
   		if ( thisCacheName == "object") {
			cacheRemove( arguments.objectKey, false );
		} else {
			cacheRemove( arguments.objectKey, false, thisCacheName );
		}

		//ColdBox events
		getEventManager().announce( "afterCacheElementRemoved", {
			cache				= this,
			cacheObjectKey 		= arguments.objectKey
		} );

		return true;
	}

	/**
	 * Clears an object from the cache by using its cache key. Returns false if object was not removed or did not exist anymore without doing statistics or updating listeners
	 *
	 * @objectKey The object cache key
	 */
	boolean function clearQuiet( required objectKey ){
		if( listFind( "2018,2021", server.coldfusion.productVersion.listFirst() ) ){
			return getObjectStore().removeQuiet( arguments.objectKey );
		} else {
			return getObjectStore().removeQuiet( ucase( arguments.objectKey ) );
		}
	}

	/**
	 * Expire all the elements in the cache (if supported by the provider):  Not implemented by this cache
	 *
	 * @return ICacheProvider
	 */
	function expireAll(){
		// Just try to evict stuff, not a way to expire all elements.
		getObjectStore().evictExpiredElements();
		return this;
	}

	/**
	 * Expires an object from the cache by using its cache key. Returns false if object was not removed or did not exist anymore (if supported by the provider) Not implemented by this cache
	 *
	 * @objectKey The object cache key
	 *
	 * @return ICacheProvider
	 */
	function expireObject( required objectKey ){
		// not implemented
		return this;
	}

	/******************************** PRIVATE ********************************/

	/**
	 * Checks if the default cache is in use or another cache region
	 */
	private boolean function isDefaultCache(){
		return  ( getConfiguration().cacheName EQ variables.DEFAULTS.cacheName );
	}

	/**
	 * Validate the incoming configuration and make necessary defaults
	 *
	 * @return LuceeProvider
	 **/
	 private function validateConfiguration(){
		 // Add in settings not discovered
		structAppend( variables.configuration, variables.DEFAULTS, false );
		return this;
	}

}

