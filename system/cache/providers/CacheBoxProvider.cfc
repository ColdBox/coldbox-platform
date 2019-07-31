﻿/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * @author Luis Majano
 *
 * This CacheBox provider is our own enterprise cache implementation with many options and storage providers.
 *
 * Properties
 * - name : The cache name
 * - enabled : Boolean flag if cache is enabled
 * - reportingEnabled: Boolean falg if cache can report
 * - stats : The statistics object
 * - configuration : The configuration structure
 * - cacheFactory : The linkage to the cachebox factory
 * - eventManager : The linkage to the event manager
 * - cacheID : The unique identity code of this CFC
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

	/**
	 * The default lock timeout for reap operations: Defaults to 15 seconds
	 */
	property name="lockTimeout" type="numeric";

	/**
	 * The eviction policy to use on the cache storage: Defaults to LRU
	 * @doc_generic coldbox.system.cache.policies.IEvictionPolicy
	 */
	property name="evictionPolicy";

	/**
	 * The object storage object
	 * @doc_generic coldbox.system.cache.store.IObjectStore
	 */
	property name="objectStore";

	/**
	 * The cache stats object
	 * @doc_generic coldbox.system.cache.util.CacheStats
	 */
	property name="stats";

	// CacheBox Provider Property Defaults
	variables.DEFAULTS = {
		objectDefaultTimeout           	= 60,
		objectDefaultLastAccessTimeout 	= 30,
		useLastAccessTimeouts          	= true,
		reapFrequency                  	= 2,
		freeMemoryPercentageThreshold  	= 0,
		evictionPolicy                 	= "LRU",
		evictCount                     	= 1,
		maxObjects                     	= 200,
		objectStore                    	= "ConcurrentStore",
		coldboxEnabled                 	= false,
		resetTimeoutOnAccess 			= false
	};

	/**
     * Constructor
     */
	function init(){
		// super size me
		super.init();
		// Element Cleaner Helper
		variables.elementCleaner = new coldbox.system.cache.util.ElementCleaner( this );
		// Runtime Java object
		variables.javaRuntime = createObject( "java", "java.lang.Runtime" );
		// Logger object
		variables.logger = "";
		// Locking Timeout
		variables.lockTimeout = "15";
		// Eviction Policy
		variables.evictionPolicy = "";
		// Stats
		variables.stats = "";
		// Object Store
		variables.objectStore = "";

		return this;
	}

	/**
     * configure the cache for operation
	 *
	 * @return CacheBoxProvider
     */
    function configure(){
		var cacheConfig	= getConfiguration();

		lock name="CacheBoxProvider.configure.#variables.cacheId#" type="exclusive" timeout="30" throwontimeout="true"{
			// Prepare the logger
			variables.logger = getCacheFactory().getLogBox().getLogger( this );

			if( variables.logger.canDebug() ){
				variables.logger.debug( "Starting up CacheBox Cache: #getName()# with configuration: #cacheConfig.toString()#" );
			}

			// Validate the configuration
			validateConfiguration();

			// Prepare Statistics
			variables.stats = new coldbox.system.cache.util.CacheStats( this );

			// Setup the eviction Policy to use
			variables.evictionPolicy = createObject( "component", locateEvictionPolicy( cacheConfig.evictionPolicy ) ).init( this );

			// Create the object store the configuration mandated
			variables.objectStore 	= createObject("component",  locateObjectStore( cacheConfig.objectStore ) ).init( this );

			// Enable cache
			variables.enabled = true;
			// Enable reporting
			variables.reportingEnabled = true;

			// startup message
			if( variables.logger.canDebug() ){
				variables.logger.debug( "CacheBox Cache: #getName()# has been initialized successfully for operation" );
			}
		}

		return this;
	}

	/**
	 * If the cache provider implements it, this returns the cache's object store.
	 *
	 * @return coldbox.system.cache.store.IObjectStore
	 */
	function getObjectStore(){
		return variables.objectStore;
	}

	/**
     * Shutdown command issued when CacheBox is going through shutdown phase
	 *
	 * @return LuceeProvider
     */
    function shutdown(){
		//nothing to shutdown
		if( variables.logger.canDebug() ){
			variables.logger.debug( "CacheBox Cache: #getName()# has been shutdown." );
		}
		return this;
	}

	/**
	 * Check if an object is in cache, if not found it records a miss.
	 *
	 * @objectKey The key to retrieve
	 */
	boolean function lookup( required objectKey ){
		if( lookupQuiet( arguments.objectKey ) ){
			// record a hit
			getStats().hit();
			return true;
		}

		// record a miss
		getStats().miss();

		return false;
	}

	/**
	 * Check if an object is in cache, no stats updated or listeners
	 *
	 * @objectKey The key to retrieve
	 */
	boolean function lookupQuiet( required objectKey ){
		// cleanup the key
		arguments.objectKey = lcase( arguments.objectKey );

		return variables.objectStore.lookup( arguments.objectKey );
	}

	/**
	 * Get an object from the cache
	 *
	 * @objectKey The key to retrieve
	 */
    function get( required objectKey ){
		// cleanup the key
		arguments.objectKey = lcase( arguments.objectKey );

		// get quietly
		var results = variables.objectStore.get( arguments.objectKey );
		if( !isNull( local.results ) ){
			getStats().hit();
			return results;
		}
		getStats().miss();
		// don't return anything = null
	}

	/**
     * get an item silently from cache, no stats advised: Stats not available on lucee
	 *
	 * @objectKey The key to retrieve
     */
    function getQuiet( required objectKey ){
		// cleanup the key
		arguments.objectKey = lcase( arguments.objectKey );

		// get object from store
		var results = variables.objectStore.getQuiet( arguments.objectKey );
		if( !isNull( local.results ) ){
			return results;
		}
		// don't return anything = null
	}

	/**
	 * Get a cache objects metadata about its performance. This value is a structure of name-value pairs of metadata.
	 *
	 * @objectKey The key to retrieve
	 */
    struct function getCachedObjectMetadata( required objectKey ){
		// Cleanup the key
		arguments.objectKey = lcase( arguments.objectKey );

		// Check if in the pool first
		if( variables.objectStore.getIndexer().objectExists( arguments.objectKey ) ){
			return variables.objectStore.getIndexer().getObjectMetadata( arguments.objectKey );
		}

		return {};
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
		timeout="",
		lastAccessTimeout="",
		struct extra={}
	){
		// Check if updating or not
		var oldObject = getQuiet( arguments.objectKey );

		// save object
		setQuiet(
			arguments.objectKey,
			arguments.object,
			arguments.timeout,
			arguments.lastAccessTimeout,
			arguments.extra
		);

		// Announce update if it exists?
		if( !isNull( local.oldObject ) ){
			// announce it
			getEventManager().processState( "afterCacheElementUpdated", {
				cache          = this,
				cacheObjectKey = arguments.objectKey,
				cacheNewObject = arguments.object,
				cacheOldObject = oldObject
			} );
		}

		// announce it
		getEventManager().processState( "afterCacheElementInsert", {
			cache                        = this,
			cacheObject                  = arguments.object,
			cacheObjectKey               = arguments.objectKey,
			cacheObjectTimeout           = arguments.timeout,
			cacheObjectLastAccessTimeout = arguments.lastAccessTimeout
		} );

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
		timeout="",
		lastAccessTimeout="",
		struct extra={}
	){

		var isJVMSafe 		= true;
		var config 			= getConfiguration();
		var iData 			= {};

		// cleanup the key
		arguments.objectKey = lcase( arguments.objectKey );

		// JVM Checks
		if( config.freeMemoryPercentageThreshold NEQ 0
			AND
			thresholdChecks( config.freeMemoryPercentageThreshold ) EQ false
		){
			// evict some stuff
			variables.evictionPolicy.execute();
		}

		// Max objects check
		if( config.maxObjects NEQ 0 AND getSize() GTE config.maxObjects ){
			// evict some stuff
			variables.evictionPolicy.execute();
		}

		// Provider Default Timeout checks
		if( NOT len( arguments.timeout ) OR NOT isNumeric( arguments.timeout ) ){
			arguments.timeout = config.objectDefaultTimeout;
		}
		if( NOT len( arguments.lastAccessTimeout ) OR NOT isNumeric( arguments.lastAccessTimeout ) ){
			arguments.lastAccessTimeout = config.objectDefaultLastAccessTimeout;
		}

		// save object
		variables.objectStore.set(
			arguments.objectKey,
			arguments.object,
			arguments.timeout,
			arguments.lastAccessTimeout,
			arguments.extra
		);

		return this;
	}

	/**
	 * Clears an object from the cache by using its cache key. Returns false if object was not removed or did not exist anymore without doing statistics or updating listeners
	 *
	 * @objectKey The object cache key
	 */
	boolean function clearQuiet( required objectKey ){
		// clean key
		arguments.objectKey = lcase( arguments.objectKey );

		// clear key
		return variables.objectStore.clear( arguments.objectKey );
	}

	/**
	 * Clears an object from the cache by using its cache key. Returns false if object was not removed or did not exist anymore
	 *
	 * @objectKey The object cache key
	 */
	boolean function clear( required objectKey ){
		var clearCheck = clearQuiet( arguments.objectKey );

		// If cleared notify listeners
		if( clearCheck ){
			getEventManager().processState( "afterCacheElementRemoved", {
				cache = this,
				cacheObjectKey 	= arguments.objectKey
			} );
		}

		return clearCheck;
	}

	/**
	 * Clear all the cache elements from the cache
	 *
	 * @return ICacheProvider
	 */
	function clearAll(){
		variables.objectStore.clearAll();

		// notify listeners
		getEventManager().processState( "afterCacheClearAll", { cache = this } );

		return this;
	}

	/**
	 * Get the number of elements in the cache
	 */
	numeric function getSize(){
		return variables.objectStore.getSize();
	}

	/**
	 * Send a reap or flush command to the cache: Not implemented by this provider
	 *
	 * @return ICacheProvider
	 */
	function reap(){
		var threadName = "CacheBoxProvider.reap_#replace( randomUUID(), "-", "", "all" )#";

		// Reap only if in frequency
		if( dateDiff( "n", getStats().getLastReapDatetime(), now() ) GTE getConfiguration().reapFrequency ){
			if( !inThread() ){
				thread name="#threadName#"{
					variables._reap();
				}
			} else {
				variables._reap();
			}
		}

		return this;
	}

	/**
	 * Expire all the elments in the cache (if supported by the provider):  Not implemented by this cache
	 *
	 * @return ICacheProvider
	 */
	function expireAll(){
		return expireByKeySnippet( keySnippet=".*",regex=true );
	}

	/**
	 * Expires an object from the cache by using its cache key. Returns false if object was not removed or did not exist anymore (if supported by the provider) Not implemented by this cache
	 *
	 * @objectKey The object cache key
	 *
	 * @return ICacheProvider
	 */
	function expireObject( required objectKey ){
		variables.objectStore.expireObject( lcase( arguments.objectKey ) );
		return this;
	}

	/**
	 * Expires an object from the cache by using its cache key. Returns false if object was not removed or did not exist anymore (if supported by the provider) Not implemented by this cache
	 *
	 * @objectKey The object cache key
	 *
	 * @return ICacheProvider
	 */
	function expireByKeySnippet( required keySnippet, boolean regex=false, boolean async=false ){
		arrayFilter( getKeys(), function( item ){
				// Using Regex?
				if( regex ){
					return reFindnocase( keySnippet, item );
				} else {
					return findNoCase( keySnippet, item );
				}
			} )
			.each( function( item ){
				if(
					variables.objectStore.lookup( item )
					AND
					getCachedObjectMetadata( item ).timeout GT 0
				){
					expireObject( item );
				}
			} );

		return this;
	}

	/**
	 * Has the object key expired in the cache: NOT IMPLEMENTED IN THIS CACHE
	 *
	 * @objectKey The key to retrieve
	 */
	boolean function isExpired( required objectKey ){
		return variables.objectStore.isExpired( lcase( arguments.objectKey ) );
	}

	/**
     * Get a structure of all the keys in the cache with their appropriate metadata structures. This is used to build the reporting.[keyX->[metadataStructure]]
     */
    struct function getStoreMetadataReport(){
		return variables.objectStore.getIndexer().getPoolMetadata();
	}

	/**
	 * Get a key lookup structure where cachebox can build the report on. Ex: [timeout=timeout,lastAccessTimeout=idleTimeout].  It is a way for the visualizer to construct the columns correctly on the reports
	 */
	struct function getStoreMetadataKeyMap(){
		return {
			timeout           = "timeout",
			hits              = "hits",
			lastAccessTimeout = "lastAccessTimeout",
			created           = "created",
			lastAccessed      = "LastAccessed",
			isExpired 		  = "isExpired"
		};
	}

	/**
	 * Returns a list of all elements in the cache, whether or not they are expired
	 */
	array function getKeys(){
		return variables.objectStore.getKeys();
	}

	/*************************************** NON-INTERFACE METHODS ****************************************************/

	/**
	 * Locate the eviction policy on disk
	 *
	 * @policy The policy on disk
	 *
	 * @return coldbox.system.cache.policies.IEvictionPolicy
	 */
	function locateEvictionPolicy( required policy ){
		if( fileExists( expandPath( "/coldbox/system/cache/policies/#arguments.policy#.cfc" ) ) ){
			return "coldbox.system.cache.policies.#arguments.policy#";
		}
		return arguments.policy;
	}

	/**
	 * Locate the object storage
	 *
	 * @store The store to use
	 *
	 * @return coldbox.system.cache.store.IObjectStore
	 */
	function locateObjectStore( required store ){
		if( fileExists( expandPath( "/coldbox/system/cache/store/#arguments.store#.cfc" ) ) ){
			return "coldbox.system.cache.store.#arguments.store#";
		}
		return arguments.store;
	}

	/**
	 * Reap the cache, clear out everything that is dead.
	 */
	private function _reap(){
		var keyIndex 		= 1;
		var cacheKeys 		= "";
		var cacheKeysLen 	= 0;
		var thisKey 		= "";
		var thisMD 			= "";
		var config 			= getConfiguration();
		var sTime			= getTickCount();

		lock type="exclusive" name="CacheBoxProvider.reap.#variables.cacheId#" timeout="#variables.lockTimeout#"{
			// log it
			if( variables.logger.canDebug() ){
				variables.logger.debug( "Starting to reap CacheBoxProvider: #getName()#, id: #variables.cacheId#" );
			}

			// Run Storage reaping first, before our local algorithm
			variables.objectStore.reap();

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
							announceExpiration( thisKey );
						}
						continue;
					}

					// Check for creation timeouts and clear
					if ( dateDiff( "n", thisMD.created, now() ) GTE thisMD.timeout ){

						// Clear the object from cache
						if( clear( thisKey ) ){
							// Announce Expiration only if removed, else maybe another thread cleaned it
							announceExpiration( thisKey );
						}
						continue;
					}

					// Check for last accessed timeouts. If object has not been accessed in the default span
					if ( config.useLastAccessTimeouts AND
					     dateDiff( "n", thisMD.lastAccessed, now() ) gte thisMD.lastAccessTimeout ){

						// Clear the object from cache
						if( clear( thisKey ) ){
							// Announce Expiration only if removed, else maybe another thread cleaned it
							announceExpiration( thisKey );
						}
						continue;
					}
				}//end timeout gt 0

			}//end looping over keys

			//Reaping about to end, set new reaping date.
			getStats().setLastReapDatetime( now() );

			// log it
			if( variables.logger.canDebug() )
				variables.logger.debug( "Finished reap in #getTickCount()-sTime#ms for CacheBoxProvider: #getName()#, id: #variables.cacheId#" );
		}
	}

	/******************************** PRIVATE ********************************/

	/**
	 * Announce a key expiration
	 *
	 * @objectKey The key target
	 *
	 * @result CacheBoxProvider
	 */
	private function announceExpiration( required objectKey ){
		// Execute afterCacheElementExpired Interception
		getEventManager().processState( "afterCacheElementExpired", {
			cache = this,
			cacheObjectKey = arguments.objectKey
		} );

		return this;
	}

	/**
	 * JVM Threshold checks
	 *
	 * @threshold The threshold to check
	 */
	private boolean function thresholdChecks( required threshold ){
		try{
			var jvmThreshold = ( ( variables.javaRuntime.getRuntime().freeMemory() / variables.javaRuntime.getRuntime().maxMemory() ) * 100 );
			var check = ( arguments.threshold LT jvmThreshold );
		} catch( any e ) {
			var check = true;
		}

		return check;
	}

}