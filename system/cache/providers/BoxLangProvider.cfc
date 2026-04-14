/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * <h2>BoxLang Cache Provider</h2>
 * <p>
 * A CacheBox provider that integrates with BoxLang's native caching engine. This provider acts as
 * a bridge between CacheBox's abstraction layer and BoxLang's built-in cache functionality, allowing
 * you to leverage the high-performance native caching capabilities of the BoxLang runtime while
 * maintaining compatibility with the CacheBox API.
 * </p>
 *
 * <h3>Key Features</h3>
 * <ul>
 *   <li><strong>Native Performance</strong> - Direct integration with BoxLang's optimized caching engine</li>
 *   <li><strong>Zero Configuration</strong> - Works out of the box with BoxLang's default cache settings</li>
 *   <li><strong>Event Integration</strong> - Fires CacheBox interception events for cache operations</li>
 *   <li><strong>Full CacheBox API</strong> - Implements the complete ICacheProvider interface</li>
 *   <li><strong>Automatic Management</strong> - BoxLang runtime handles memory management and reaping</li>
 *   <li><strong>Thread-Safe</strong> - Leverages BoxLang's concurrent cache implementation</li>
 * </ul>
 *
 * <h3>Configuration</h3>
 * <p>
 * This provider requires minimal configuration. The only required setting is:
 * </p>
 * <ul>
 *   <li><strong>cacheName</strong> (default: "default") - The name of the BoxLang cache region to use</li>
 * </ul>
 *
 * <h3>Usage Example</h3>
 * <pre>
 * // Configure in CacheBox.cfc
 * caches = {
 *     boxlang = {
 *         provider   = "coldbox.system.cache.providers.BoxLangProvider",
 *         properties = {
 *             cacheName = "default"  // Or any BoxLang cache region name
 *         }
 *     }
 * };
 *
 * // Use the cache
 * cache = cacheFactory.getCache( "boxlang" );
 * cache.set( "myKey", myObject, 60 );
 * var data = cache.get( "myKey" );
 * </pre>
 *
 * <h3>BoxLang Native Cache</h3>
 * <p>
 * BoxLang provides a highly optimized native caching engine that handles:
 * </p>
 * <ul>
 *   <li>Automatic memory management based on JVM heap availability</li>
 *   <li>Concurrent access with minimal locking overhead</li>
 *   <li>Intelligent eviction strategies</li>
 *   <li>Built-in statistics and monitoring</li>
 *   <li>Distributed caching support (when configured)</li>
 * </ul>
 *
 * <h3>Cache Regions</h3>
 * <p>
 * BoxLang supports multiple named cache regions. You can configure different providers to
 * target different regions:
 * </p>
 * <pre>
 * caches = {
 *     sessions = {
 *         provider   = "coldbox.system.cache.providers.BoxLangProvider",
 *         properties = { cacheName = "sessions" }
 *     },
 *     queries = {
 *         provider   = "coldbox.system.cache.providers.BoxLangProvider",
 *         properties = { cacheName = "queries" }
 *     }
 * };
 * </pre>
 *
 * <h3>Events</h3>
 * <p>
 * The provider fires the following CacheBox interception events:
 * </p>
 * <ul>
 *   <li><strong>afterCacheElementInsert</strong> - Fired after an object is inserted or updated</li>
 *   <li><strong>afterCacheElementRemoved</strong> - Fired after an object is manually removed</li>
 *   <li><strong>afterCacheClearAll</strong> - Fired after the entire cache is cleared</li>
 * </ul>
 *
 * <h3>Limitations</h3>
 * <p>
 * Some CacheBox features are delegated to BoxLang's native implementation:
 * </p>
 * <ul>
 *   <li><strong>expireAll()</strong> - Not implemented, BoxLang manages expiration automatically</li>
 *   <li><strong>expireObject()</strong> - Not implemented, use clear() instead</li>
 *   <li><strong>isExpired()</strong> - Always returns false, BoxLang auto-removes expired objects</li>
 * </ul>
 *
 * <h3>Performance Benefits</h3>
 * <p>
 * Using the BoxLang provider offers several performance advantages:
 * </p>
 * <ul>
 *   <li>Native JVM-level optimizations in BoxLang's caching engine</li>
 *   <li>Reduced overhead compared to pure CFML implementations</li>
 *   <li>Direct memory management by the BoxLang runtime</li>
 *   <li>Optimized serialization for BoxLang objects</li>
 * </ul>
 *
 * <h3>When to Use</h3>
 * <p>
 * Choose BoxLangProvider when:
 * </p>
 * <ul>
 *   <li>Running on the BoxLang runtime</li>
 *   <li>You want maximum performance with minimal configuration</li>
 *   <li>You need integration with BoxLang's cache management tools</li>
 *   <li>You want to leverage BoxLang-specific caching features</li>
 * </ul>
 *
 * @author Luis Majano
 * @see    coldbox.system.cache.AbstractCacheBoxProvider
 * @see    coldbox.system.cache.providers.ICacheProvider
 * @see    coldbox.system.cache.providers.stats.BoxLangStats
 */
component
	accessors   ="true"
	serializable="false"
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
	 * Configure the cache provider with the given configuration structure
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
		return new coldbox.system.cache.providers.stats.BoxLangStats( this );
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
		timeout           = "",
		lastAccessTimeout = "",
		struct extra      = {}
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
		timeout           = "",
		lastAccessTimeout = "",
		struct extra      = {}
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
