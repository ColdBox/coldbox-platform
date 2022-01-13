/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ----
 *
 * A mock cache provider that keeps cache data in a simple map for testing and assertions
 *
 * @luis Majano
 **/
component
	accessors   =true
	serializable=false
	implements  ="coldbox.system.cache.providers.IColdBoxProvider"
	extends     ="coldbox.system.cache.AbstractCacheBoxProvider"
{

	/**
	 * The in memory mocking cache
	 */
	property name="cache" type="struct";

	// CacheBox Provider Property Defaults
	variables.DEFAULTS = {
		objectDefaultTimeout           : 60,
		objectDefaultLastAccessTimeout : 30,
		useLastAccessTimeouts          : true,
		reapFrequency                  : 2,
		freeMemoryPercentageThreshold  : 0,
		evictionPolicy                 : "LRU",
		evictCount                     : 1,
		maxObjects                     : 200,
		objectStore                    : "ConcurrentStore",
		coldboxEnabled                 : false,
		resetTimeoutOnAccess           : false
	};

	/**
	 * Constructor
	 *
	 * @return MockProvider
	 */
	function init(){
		super.init();

		variables.cache = {};
		return this;
	}

	/**
	 * This method makes the cache ready to accept elements and run.  Usually a cache is first created (init), then wired and then the factory calls configure() on it
	 *
	 * @return MockProvider
	 */
	function configure(){
		variables.cache            = {};
		variables.enabled          = true;
		variables.reportingEnabled = true;

		validateConfiguration();

		return this;
	}

	/**
	 * Shutdown command issued when CacheBox is going through shutdown phase
	 *
	 * @return MockProvider
	 */
	function shutdown(){
		return this;
	}

	/**
	 * If the cache provider implements it, this returns the cache's object store as type: coldbox.system.cache.store.IObjectStore
	 *
	 * @return coldbox.system.cache.store.IObjectStore
	 */
	function getObjectStore(){
		return variables.cache;
	}

	/**
	 * Get a structure of all the keys in the cache with their appropriate metadata structures. This is used to build the reporting.[keyX->[metadataStructure]]
	 */
	struct function getStoreMetadataReport(){
		return {};
	}

	/**
	 * Get a key lookup structure where cachebox can build the report on. Ex: [timeout=timeout,lastAccessTimeout=idleTimeout].  It is a way for the visualizer to construct the columns correctly on the reports
	 */
	struct function getStoreMetadataKeyMap(){
		return {
			timeout           : "timeout",
			hits              : "hits",
			lastAccessTimeout : "lastAccessTimeout",
			created           : "created",
			lastAccessed      : "lastAccessed",
			isExpire          : "isExpired"
		};
	}

	/**
	 * Returns a list of all elements in the cache, whether or not they are expired
	 */
	array function getKeys(){
		return variables.cache.keyList();
	}

	/**
	 * Get a cache objects metadata about its performance. This value is a structure of name-value pairs of metadata.
	 *
	 * @objectKey The key to retrieve
	 */
	struct function getCachedObjectMetadata( required objectKey ){
		return {};
	}

	/**
	 * Get an object from the cache and updates stats
	 *
	 * @objectKey The key to retrieve
	 */
	function get( required objectKey ){
		return variables.cache[ arguments.objectKey ];
	}

	/**
	 * Get an object from the cache without updating stats or listeners
	 *
	 * @objectKey The key to retrieve
	 */
	function getQuiet( required objectKey ){
		return variables.cache[ arguments.objectKey ];
	}

	/**
	 * Has the object key expired in the cache
	 *
	 * @objectKey The key to retrieve
	 */
	boolean function isExpired( required objectKey ){
		return lookup( arguments.objectKey );
	}

	/**
	 * Check if an object is in cache, if not found it records a miss.
	 *
	 * @objectKey The key to retrieve
	 */
	boolean function lookup( required objectKey ){
		return structKeyExists( variables.cache, arguments.objectKey );
	}

	/**
	 * Check if an object is in cache, no stats updated or listeners
	 *
	 * @objectKey The key to retrieve
	 */
	boolean function lookupQuiet( required objectKey ){
		return structKeyExists( variables.cache, arguments.objectKey );
	}

	/**
	 * Check if an object is in cache, if not found it records a miss.
	 *
	 * @objectValue The value to retrieve
	 */
	boolean function lookupValue( required objectValue ){
		return variables.cache.containsValue( arguments.objectValue );
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
	 * @return MockProvider
	 */
	function set(
		required objectKey,
		required object,
		timeout,
		lastAccessTimeout,
		struct extra
	){
		variables.cache[ arguments.objectKey ] = arguments.object;
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
	 * @return MockProvider
	 */
	function setQuiet(
		required objectKey,
		required object,
		timeout,
		lastAccessTimeout,
		struct extra
	){
		variables.cache[ arguments.objectKey ] = arguments.object;
		return this;
	}

	/**
	 * Get the number of elements in the cache
	 */
	numeric function getSize(){
		return structCount( variables.cache );
	}

	/**
	 * Send a reap or flush command to the cache
	 *
	 * @return MockProvider
	 */
	function reap(){
		return this;
	}

	/**
	 * Clear all the cache elements from the cache
	 *
	 * @return MockProvider
	 */
	function clearAll(){
		variables.cache = {};
		return this;
	}

	/**
	 * Clears an object from the cache by using its cache key. Returns false if object was not removed or did not exist anymore
	 *
	 * @objectKey The object cache key
	 */
	boolean function clear( required objectKey ){
		return structDelete( variables.cache, arguments.objectKey, true );
	}

	/**
	 * Clears an object from the cache by using its cache key. Returns false if object was not removed or did not exist anymore without doing statistics or updating listeners
	 *
	 * @objectKey The object cache key
	 */
	boolean function clearQuiet( required objectKey ){
		return structDelete( variables.cache, arguments.objectKey, true );
	}

	/**
	 * Expire all the elements in the cache (if supported by the provider)
	 */
	function expireAll(){
		return this;
	}

	/**
	 * Expires an object from the cache by using its cache key. Returns false if object was not removed or did not exist anymore (if supported by the provider)
	 *
	 * @objectKey The object cache key
	 *
	 * @return MockProvider
	 */
	function expireObject( required objectKey ){
		return this;
	}


	/*************************************** ColdBox Application Cache Methods ***************************************/

	/**
	 * Get the cached view key prefix which is necessary for view caching
	 */
	function getViewCacheKeyPrefix(){
		return "mock";
	}

	/**
	 * Get the event cache key prefix which is necessary for event caching
	 */
	function getEventCacheKeyPrefix(){
		return "mock";
	}

	/**
	 * Get the coldbox application reference as coldbox.system.web.Controller
	 *
	 * @return coldbox.system.web.Controller
	 */
	function getColdbox(){
		return variables.coldbox;
	}

	/**
	 * Set the ColdBox linkage into the provider
	 *
	 * @coldbox             The ColdBox controller
	 * @coldbox.doc_generic coldbox.system.web.Controller
	 *
	 * @return MockProvider
	 */
	function setColdBox( required coldbox ){
		variables.coldbox = arguments.coldbox;
		return this;
	}

	/**
	 * Get the event caching URL facade utility that determines event caching
	 *
	 * @return coldbox.system.cache.util.EventURLFacade
	 */
	function getEventURLFacade(){
		return variables.eventURLFacade;
	}

	/**
	 * Clears all events from the cache.
	 *
	 * @async If implemented, determines async or sync clearing.
	 *
	 * @return MockProvider
	 */
	function clearAllEvents( boolean async = false ){
		return this;
	}

	/**
	 * Clears all the event permutations from the cache according to snippet and querystring. Be careful when using incomplete event name with query strings as partial event names are not guaranteed to match with query string permutations
	 *
	 * @eventSnippet The event snippet to clear on. Can be partial or full
	 * @queryString  If passed in, it will create a unique hash out of it. For purging purposes
	 *
	 * @return MockProvider
	 */
	function clearEvent( required eventSnippet, queryString = "" ){
		return this;
	}

	/**
	 * Clears all the event permutations from the cache according to the list of snippets and querystrings. Be careful when using incomplete event name with query strings as partial event names are not guaranteed to match with query string permutations
	 *
	 * @eventSnippet The comma-delimited list event snippet to clear on. Can be partial or full
	 * @queryString  The comma-delimited list of queryStrings passed in. If passed in, it will create a unique hash out of it. For purging purposes.  If passed in the list length must be equal to the list length of the event snippets passed in
	 *
	 * @return MockProvider
	 */
	function clearEventMulti( required eventsnippets, queryString = "" ){
		return this;
	}

	/**
	 * Clears all view name permutations from the cache according to the view name
	 *
	 * @viewSnippet The view name snippet to purge from the cache
	 *
	 * @return MockProvider
	 */
	function clearView( required viewSnippet ){
		return this;
	}

	/**
	 * Clears all view name permutations from the cache according to the view name.
	 *
	 * @viewSnippets The comma-delimited list or array of view snippet to clear on. Can be partial or full
	 */
	function clearViewMulti( required viewSnippets ){
		return this;
	}

	/**
	 * Clears all views from the cache.
	 *
	 * @async Run command asynchronously or not
	 *
	 * @return MockProvider
	 */
	function clearAllViews( boolean async = false ){
		return this;
	}

}
