/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 *
 * This CacheBox provider communicates with the built in caches in the BoxLang Runtime
 *
 * @author Luis Majano
 */
component
	accessors   ="true"
	serializable="false"
	implements  ="coldbox.system.cache.providers.ICacheProvider"
	extends     ="coldbox.system.cache.AbstractCacheBoxProvider"
{

	/**
	 * The global element cleaner utility object
	 */
	property name="elementCleaner";

	// Provider Property Defaults STATIC
	variables.DEFAULTS = { cacheName : "default" };

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
	 * @return BoxLangProvider
	 */
	function configure(){
		lock name="BoxLangProvider.config.#variables.cacheID#" type="exclusive" throwontimeout="true" timeout="30" {
			// Prepare the logger
			variables.logger = getCacheFactory().getLogBox().getLogger( this );

			if ( variables.logger.canDebug() ) {
				variables.logger.debug(
					"Starting up BoxLangProvider Cache: #getName()# with configuration: #variables.configuration.toString()#"
				);
			}

			// Validate the configuration
			validateConfiguration();

			// enabled cache
			variables.enabled          = true;
			variables.reportingEnabled = true;

			if ( variables.logger.canDebug() ) {
				variables.logger.debug( "Cache #getName()# started up successfully" );
			}
		}

		return this;
	}

	/**
	 * Shutdown command issued when CacheBox is going through shutdown phase
	 *
	 * @return BoxLangProvider
	 */
	function shutdown(){
		// nothing to shutdown, the runtime takes care of it.
		if ( variables.logger.canDebug() ) {
			variables.logger.debug( "BoxLangProvider Cache: #getName()# has been shutdown." );
		}
		return this;
	}

	/**
	 * Get the cache statistics object as coldbox.system.cache.util.IStats
	 *
	 * @return coldbox.system.cache.util.IStats
	 */
	function getStats(){
		return new "coldbox.system.cache.providers.stats.BoxLangStats"( this );
	}

	/**
	 * Clear the cache statistics
	 * THIS FUNCTION IS NOT IMPLEMENTED IN THIS PROVIDER
	 *
	 * @return ICacheProvider
	 */
	function clearStatistics(){
		return cache( getConfiguration().cacheName ).clearStats();
	}

	/**
	 * If the cache provider implements it, this returns the cache's object store.
	 *
	 * @return coldbox.system.cache.store.IObjectStore or any depending on the cache implementation
	 */
	function getObjectStore(){
		return cache( getConfiguration().cacheName ).getObjectStore();
	}

	/**
	 * Get a structure of all the keys in the cache with their appropriate metadata structures. This is used to build the reporting.[keyX->[metadataStructure]]
	 */
	struct function getStoreMetadataReport(){
		return cache( getConfiguration().cacheName ).getStoreMetadataReport();
	}

	/**
	 * Get a key lookup structure where cachebox can build the report on. Ex: [timeout=timeout,lastAccessTimeout=idleTimeout].  It is a way for the visualizer to construct the columns correctly on the reports
	 */
	struct function getStoreMetadataKeyMap(){
		return {
			cacheName         : "cacheName",
			hits              : "hits",
			timeout           : "timeout",
			lastAccessTimeout : "lastAccessTimeout",
			created           : "created",
			lastAccessed      : "lastAccessed",
			metadata          : "metadata",
			key               : "key",
			isEternal         : "isEternal"
		};
	}

	/**
	 * Returns a list of all elements in the cache, whether or not they are expired
	 */
	array function getKeys(){
		return cache( getConfiguration().cacheName ).getKeys();
	}

	/**
	 * Get a cache objects metadata about its performance. This value is a structure of name-value pairs of metadata.
	 *
	 * @objectKey The key to retrieve
	 */
	struct function getCachedObjectMetadata( required objectKey ){
		return cache( getConfiguration().cacheName ).getCachedObjectMetadata( arguments.objectKey );
	}

	/**
	 * Get an object from the cache
	 *
	 * @objectKey The key to retrieve
	 */
	function get( required objectKey ){
		return cache( getConfiguration().cacheName ).get( arguments.objectKey ).getOrDefault( nullValue() );
	}

	/**
	 * get an item silently from cache, no stats advised: Stats not available on lucee
	 *
	 * @objectKey The key to retrieve
	 */
	function getQuiet( required objectKey ){
		return cache( getConfiguration().cacheName ).getQuiet( arguments.objectKey ).getOrDefault( nullValue() );
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
		return cache( getConfiguration().cacheName ).lookup( arguments.objectKey );
	}

	/**
	 * Check if an object is in cache, no stats updated or listeners
	 *
	 * @objectKey The key to retrieve
	 */
	boolean function lookupQuiet( required objectKey ){
		return cache( getConfiguration().cacheName ).lookupQuiet( arguments.objectKey );
	}

	/**
	 * Tries to get an object from the cache, if not found, it calls the 'produce' closure to produce the data and cache it
	 *
	 * @objectKey         The object cache key
	 * @produce           The producer closure/lambda
	 * @timeout           The timeout to use on the object (if any, provider specific)
	 * @lastAccessTimeout The idle timeout to use on the object (if any, provider specific)
	 * @extra             A map of name-value pairs to use as extra arguments to pass to a providers set operation
	 *
	 * @return The cached or produced data/object
	 */
	any function getOrSet(
		required any objectKey,
		required any produce,
		any timeout           = "0",
		any lastAccessTimeout = "0",
		any extra             = {}
	){
		return cache( getConfiguration().cacheName ).getOrSet(
			arguments.objectKey,
			arguments.produce,
			arguments.timeout,
			arguments.lastAccessTimeout,
			arguments.extra
		);
	}

	/**
	 * Sets an object in the cache and returns an instance of itself
	 *
	 * @objectKey         The object cache key
	 * @object            The object to cache
	 * @timeout           The timeout to use on the object (if any, provider specific)
	 * @lastAccessTimeout The idle timeout to use on the object (if any, provider specific)
	 * @extra             A map of name-value pairs to use as extra arguments to pass to a providers set operation
	 *
	 * @return ICacheProvider
	 */
	function set(
		required objectKey,
		required object,
		timeout           = 0,
		lastAccessTimeout = 0,
		struct extra
	){
		cache( getConfiguration().cacheName ).set(
			arguments.objectKey,
			arguments.object,
			arguments.timeout,
			arguments.lastAccessTimeout,
			arguments.extra
		);

		// ColdBox events
		var iData = {
			cache                        : this,
			cacheObject                  : arguments.object,
			cacheObjectKey               : arguments.objectKey,
			cacheObjectTimeout           : arguments.timeout,
			cacheObjectLastAccessTimeout : arguments.lastAccessTimeout
		};
		getEventManager().announce( "afterCacheElementInsert", iData );

		return this;
	}

	/**
	 * Sets an object in the cache with no event calls and returns an instance of itself
	 *
	 * @objectKey         The object cache key
	 * @object            The object to cache
	 * @timeout           The timeout to use on the object (if any, provider specific)
	 * @lastAccessTimeout The idle timeout to use on the object (if any, provider specific)
	 * @extra             A map of name-value pairs to use as extra arguments to pass to a providers set operation
	 *
	 * @return ICacheProvider
	 */
	function setQuiet(
		required objectKey,
		required object,
		timeout           = 0,
		lastAccessTimeout = 0,
		struct extra
	){
		cache( getConfiguration().cacheName ).set(
			arguments.objectKey,
			arguments.object,
			arguments.timeout,
			arguments.lastAccessTimeout,
			arguments.extra
		);

		return this;
	}

	/**
	 * Get the number of elements in the cache
	 */
	numeric function getSize(){
		return cache( getConfiguration().cacheName ).getSize();
	}

	/**
	 * Send a reap or flush command to the cache: Not implemented by this provider
	 *
	 * @return ICacheProvider
	 */
	function reap(){
		cache( getConfiguration().cacheName ).reap();
		return this;
	}

	/**
	 * Clear all the cache elements from the cache
	 *
	 * @return ICacheProvider
	 */
	function clearAll(){
		cache( getConfiguration().cacheName ).clearAll();
		// notify listeners
		getEventManager().announce( "afterCacheClearAll", { cache : this } );
		return this;
	}

	/**
	 * Clears an object from the cache by using its cache key. Returns false if object was not removed or did not exist anymore
	 *
	 * @objectKey The object cache key
	 */
	boolean function clear( required objectKey ){
		var results = cache( getConfiguration().cacheName ).clear( arguments.objectKey );

		// ColdBox events
		getEventManager().announce(
			"afterCacheElementRemoved",
			{ cache : this, cacheObjectKey : arguments.objectKey }
		);

		return results;
	}

	/**
	 * Clears an object from the cache by using its cache key. Returns false if object was not removed or did not exist anymore without doing statistics or updating listeners
	 *
	 * @objectKey The object cache key
	 */
	boolean function clearQuiet( required objectKey ){
		// normal clear, not implemented by lucee
		return cache( getConfiguration().cacheName ).clearQuiet( arguments.objectKey );
	}

	/**
	 * Expire all the elements in the cache (if supported by the provider)
	 * THIS FUNCTION IS NOT IMPLEMENTED IN THIS PROVIDER
	 *
	 * @return ICacheProvider
	 */
	function expireAll(){
		return this;
	}

	/**
	 * Expires an object from the cache by using its cache key. Returns false if object was not removed or did not exist anymore (if supported by the provider)
	 * THIS FUNCTION IS NOT IMPLEMENTED IN THIS PROVIDER
	 *
	 * @objectKey The object cache key
	 *
	 * @return ICacheProvider
	 */
	function expireObject( required objectKey ){
		return this;
	}

	/**
	 * Get the underlying BoxLang cache object
	 */
	function getCache(){
		return getCache( getConfiguration().cacheName );
	}

	/******************************** PRIVATE ********************************/

	/**
	 * Validate the incoming configuration and make necessary defaults
	 *
	 * @return BoxLangProvider
	 **/
	private function validateConfiguration(){
		// Add in settings not discovered
		structAppend(
			variables.configuration,
			variables.DEFAULTS,
			false
		);
		return this;
	}

}
