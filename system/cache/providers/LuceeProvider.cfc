/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 *
 * This CacheBox provider communicates with the built in caches in the Lucee Engine
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
	variables.DEFAULTS = { cacheName : "object" };

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
		lock name="LuceeProvider.config.#variables.cacheID#" type="exclusive" throwontimeout="true" timeout="30" {
			// Prepare the logger
			variables.logger = getCacheFactory().getLogBox().getLogger( this );

			if ( variables.logger.canDebug() ) {
				variables.logger.debug(
					"Starting up LuceeProvider Cache: #getName()# with configuration: #variables.configuration.toString()#"
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
	 * @return LuceeProvider
	 */
	function shutdown(){
		// nothing to shutdown
		if ( variables.logger.canDebug() ) {
			variables.logger.debug( "LuceeProvider Cache: #getName()# has been shutdown." );
		}
		return this;
	}

	/**
	 * Get the cache statistics object as coldbox.system.cache.util.IStats
	 *
	 * @return coldbox.system.cache.util.IStats
	 */
	function getStats(){
		return new "coldbox.system.cache.providers.lucee-lib.LuceeStats"( this );
	}

	/**
	 * Clear the cache statistics
	 * THIS FUNCTION IS NOT IMPLEMENTED IN THIS PROVIDER
	 *
	 * @return ICacheProvider
	 */
	function clearStatistics(){
		// not yet posible with lucee
	}

	/**
	 * If the cache provider implements it, this returns the cache's object store.
	 *
	 * @return coldbox.system.cache.store.IObjectStore or any depending on the cache implementation
	 */
	function getObjectStore(){
		// not yet possible with lucee
		// return cacheGetSession( getConfiguration().cacheName );
	}

	/**
	 * Get a structure of all the keys in the cache with their appropriate metadata structures. This is used to build the reporting.[keyX->[metadataStructure]]
	 */
	struct function getStoreMetadataReport(){
		return getKeys().reduce( function( result, item ){
			result[ item ] = getCachedObjectMetadata( item );
			return result;
		}, {} );
	}

	/**
	 * Get a key lookup structure where cachebox can build the report on. Ex: [timeout=timeout,lastAccessTimeout=idleTimeout].  It is a way for the visualizer to construct the columns correctly on the reports
	 */
	struct function getStoreMetadataKeyMap(){
		return {
			timeout           : "timespan",
			hits              : "hitcount",
			lastAccessTimeout : "idleTime",
			created           : "createdtime",
			lastAccessed      : "lasthit"
		};
	}

	/**
	 * Returns a list of all elements in the cache, whether or not they are expired
	 */
	array function getKeys(){
		try {
			if ( isDefaultCache() ) {
				return cacheGetAllIds();
			}

			return cacheGetAllIds( "", getConfiguration().cacheName );
		} catch ( Any e ) {
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
		if ( isDefaultCache() ) {
			return cacheGetMetadata( arguments.objectKey );
		}

		return cacheGetMetadata( arguments.objectKey, getConfiguration().cacheName );
	}

	/**
	 * Get an object from the cache
	 *
	 * @objectKey The key to retrieve
	 */
	function get( required objectKey ){
		if ( isDefaultCache() ) {
			return cacheGet( arguments.objectKey );
		}
		return cacheGet(
			arguments.objectKey,
			false,
			getConfiguration().cacheName
		);
	}

	/**
	 * get an item silently from cache, no stats advised: Stats not available on lucee
	 *
	 * @objectKey The key to retrieve
	 */
	function getQuiet( required objectKey ){
		return get( arguments.objectKey );
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
		if ( isDefaultCache() ) {
			return cacheKeyExists( arguments.objectKey );
		}
		return cacheKeyExists( arguments.objectKey, getConfiguration().cacheName );
	}

	/**
	 * Check if an object is in cache, no stats updated or listeners
	 *
	 * @objectKey The key to retrieve
	 */
	boolean function lookupQuiet( required objectKey ){
		// not possible yet on lucee
		return lookup( arguments.objectKey );
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
		return super.getOrSet( argumentCollection = arguments );
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
		setQuiet( argumentCollection = arguments );

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
		// check if incoming timoeut is a timespan or minute to convert to timespan
		if ( !findNoCase( "timespan", arguments.timeout.getClass().getName() ) ) {
			if ( !isNumeric( arguments.timeout ) ) {
				arguments.timeout = 0;
			}
			arguments.timeout = createTimespan( 0, 0, arguments.timeout, 0 );
		}
		if ( !findNoCase( "timespan", arguments.lastAccessTimeout.getClass().getName() ) ) {
			if ( !isNumeric( arguments.lastAccessTimeout ) ) {
				arguments.lastAccessTimeout = 0;
			}
			arguments.lastAccessTimeout = createTimespan( 0, 0, arguments.lastAccessTimeout, 0 );
		}
		// Cache it
		if ( isDefaultCache() ) {
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
				getConfiguration().cacheName
			);
		}

		return this;
	}

	/**
	 * Get the number of elements in the cache
	 */
	numeric function getSize(){
		if ( isDefaultCache() ) {
			return cacheCount();
		}
		return cacheCount( getConfiguration().cacheName );
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
		if ( isDefaultCache() ) {
			cacheClear();
		} else {
			cacheClear( "", getConfiguration().cacheName );
		}

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
		if ( isDefaultCache() ) {
			cacheRemove( arguments.objectKey );
		} else {
			cacheRemove(
				arguments.objectKey,
				false,
				getConfiguration().cacheName
			);
		}

		// ColdBox events
		getEventManager().announce(
			"afterCacheElementRemoved",
			{ cache : this, cacheObjectKey : arguments.objectKey }
		);

		return true;
	}

	/**
	 * Clears an object from the cache by using its cache key. Returns false if object was not removed or did not exist anymore without doing statistics or updating listeners
	 *
	 * @objectKey The object cache key
	 */
	boolean function clearQuiet( required objectKey ){
		// normal clear, not implemented by lucee
		return clear( arguments.objectKey );
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

	/******************************** PRIVATE ********************************/

	/**
	 * Checks if the default cache is in use or another cache region
	 */
	private boolean function isDefaultCache(){
		return ( getConfiguration().cacheName EQ variables.DEFAULTS.cacheName );
	}

	/**
	 * Validate the incoming configuration and make necessary defaults
	 *
	 * @return LuceeProvider
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
