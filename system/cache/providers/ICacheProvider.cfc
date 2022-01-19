/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 *
 * The main interface for a CacheBox cache provider.  You need to implement all the methods in order for CacheBox to work correctly for the implementing cache provider.
 * Many of the methods return itself, so they are documented in the <pre>@return</pre> annotation since interfaces are very janky in acf11 and 2016
 *
 * @author Luis Majano
 */
interface {

	/**
	 * Get the name of this cache
	 */
	function getName();

	/**
	 * Set the cache name
	 *
	 * @name The name to set
	 *
	 * @return ICacheProvider
	 */
	function setName( required name );

	/**
	 * Returns a flag indicating if the cache is ready for operation
	 */
	boolean function isEnabled();

	/**
	 * Returns a flag indicating if the cache has reporting enabled
	 */
	boolean function isReportingEnabled();

	/**
	 * Get the cache statistics object as coldbox.system.cache.util.IStats
	 *
	 * @return coldbox.system.cache.util.IStats
	 */
	function getStats();

	/**
	 * Clear the cache statistics
	 *
	 * @return ICacheProvider
	 */
	function clearStatistics();

	/**
	 * Get the structure of configuration parameters for the cache
	 */
	struct function getConfiguration();

	/**
	 * Set the entire configuration structure for this cache
	 *
	 * @configuration The cache configuration
	 *
	 * @return ICacheProvider
	 */
	function setConfiguration( required struct configuration );

	/**
	 * Get the cache factory reference this cache provider belongs to
	 */
	coldbox.system.cache.CacheFactory function getCacheFactory();

	/**
	 * Set the cache factory reference for this cache
	 *
	 * @cacheFactory             The cache factory
	 * @cacheFactory.doc_generic coldbox.system.cache.CacheFactory
	 *
	 * @return ICacheProvider
	 */
	function setCacheFactory( required cacheFactory );

	/**
	 * Get this cache managers event listener manager
	 */
	function getEventManager();

	/**
	 * Set the event manager for this cache
	 *
	 * @eventManager The event manager to set
	 *
	 * @return ICacheProvider
	 */
	function setEventManager( required eventManager );

	/**
	 * This method makes the cache ready to accept elements and run.  Usually a cache is first created (init), then wired and then the factory calls configure() on it
	 *
	 * @return ICacheProvider
	 */
	function configure();

	/**
	 * Shutdown command issued when CacheBox is going through shutdown phase
	 *
	 * @return ICacheProvider
	 */
	function shutdown();

	/**
	 * If the cache provider implements it, this returns the cache's object store.
	 *
	 * @return coldbox.system.cache.store.IObjectStore or any depending on the cache implementation
	 */
	function getObjectStore();

	/**
	 * Get a structure of all the keys in the cache with their appropriate metadata structures. This is used to build the reporting.[keyX->[metadataStructure]]
	 */
	struct function getStoreMetadataReport();

	/**
	 * Get a key lookup structure where cachebox can build the report on. Ex: [timeout=timeout,lastAccessTimeout=idleTimeout].  It is a way for the visualizer to construct the columns correctly on the reports
	 */
	struct function getStoreMetadataKeyMap();

	/**
	 * Returns a list of all elements in the cache, whether or not they are expired
	 */
	array function getKeys();

	/**
	 * Get a cache objects metadata about its performance. This value is a structure of name-value pairs of metadata.
	 *
	 * @objectKey The key to retrieve
	 */
	struct function getCachedObjectMetadata( required objectKey );

	/**
	 * Get an object from the cache and updates stats
	 *
	 * @objectKey The key to retrieve
	 */
	function get( required objectKey );

	/**
	 * Get an object from the cache without updating stats or listeners
	 *
	 * @objectKey The key to retrieve
	 */
	function getQuiet( required objectKey );

	/**
	 * Has the object key expired in the cache
	 *
	 * @objectKey The key to retrieve
	 */
	boolean function isExpired( required objectKey );

	/**
	 * Check if an object is in cache, if not found it records a miss.
	 *
	 * @objectKey The key to retrieve
	 */
	boolean function lookup( required objectKey );

	/**
	 * Check if an object is in cache, no stats updated or listeners
	 *
	 * @objectKey The key to retrieve
	 */
	boolean function lookupQuiet( required objectKey );

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
		timeout,
		lastAccessTimeout,
		struct extra
	);

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
		timeout,
		lastAccessTimeout,
		struct extra
	);

	/**
	 * Get the number of elements in the cache
	 */
	numeric function getSize();

	/**
	 * Send a reap or flush command to the cache
	 *
	 * @return ICacheProvider
	 */
	function reap();

	/**
	 * Clear all the cache elements from the cache
	 *
	 * @return ICacheProvider
	 */
	function clearAll();

	/**
	 * Clears an object from the cache by using its cache key. Returns false if object was not removed or did not exist anymore
	 *
	 * @objectKey The object cache key
	 */
	boolean function clear( required objectKey );

	/**
	 * Clears an object from the cache by using its cache key. Returns false if object was not removed or did not exist anymore without doing statistics or updating listeners
	 *
	 * @objectKey The object cache key
	 */
	boolean function clearQuiet( required objectKey );

	/**
	 * Expire all the elements in the cache (if supported by the provider)
	 *
	 * @return ICacheProvider
	 */
	function expireAll();

	/**
	 * Expires an object from the cache by using its cache key. Returns false if object was not removed or did not exist anymore (if supported by the provider)
	 *
	 * @objectKey The object cache key
	 *
	 * @return ICacheProvider
	 */
	function expireObject( required objectKey );

}
