/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 *
 * I am a concurrent object store. In other words, I am fancy! This store is case-sensitive
 *
 * @author Luis Majano
 */
component implements="coldbox.system.cache.store.IObjectStore" accessors="true" {

	/**
	 * The cache provider reference
	 */
	property name="cacheProvider" doc_generic="coldbox.system.cache.providers.ICacheProvider";

	/**
	 * The human store name
	 */
	property name="storeID";

	/**
	 * The storage pool
	 */
	property name="pool" doc_generic="java.util.concurrent.ConcurrentHashMap";

	/**
	 * Constructor
	 *
	 * @cacheProvider             The associated cache provider as coldbox.system.cache.providers.ICacheProvider
	 * @cacheprovider.doc_generic coldbox.system.cache.providers.ICacheProvider
	 */
	function init( required cacheProvider ){
		// Prepare instance
		variables.cacheProvider = arguments.cacheProvider;
		variables.storeID       = createUUID();
		variables.pool          = createObject( "java", "java.util.concurrent.ConcurrentHashMap" ).init();
		return this;
	}

	/**
	 * Flush the store to a permanent storage
	 * Not supported in this store
	 */
	void function flush(){
		return;
	}

	/**
	 * Reap the storage
	 */
	void function reap(){
		return;
	}

	/**
	 * Clear all the elements in the store
	 */
	void function clearAll(){
		variables.pool.clear();
	}

	/**
	 * Get all the store's object keys array
	 *
	 * @return array
	 */
	function getKeys(){
		return getJavaCollections().list( variables.pool.keys() );
	}

	/**
	 * Check if an object is in the store
	 *
	 * @objectKey The key to lookup
	 *
	 * @return boolean
	 */
	function lookup( required objectKey ){
		var target = variables.pool.get( arguments.objectKey );
		if ( isNull( local.target ) ) {
			return false;
		}

		// Check for expired
		if ( local.target.isExpired ) {
			clear( arguments.objectKey );
			return false;
		}

		return true;
	}

	/**
	 * Get an object from the store with metadata tracking, or null if not found
	 *
	 * @objectKey The key to retrieve
	 */
	function get( required objectKey ){
		// retrieve from map
		var results = variables.pool.get( arguments.objectKey );
		if ( !isNull( local.results ) ) {
			// Record Metadata Access
			results.hits         = results.hits + 1;
			results.lastAccessed = now();
			// Is resetTimeoutOnAccess enabled? If so, jump up the creation time to increase the timeout
			if ( variables.cacheProvider.getConfiguration().resetTimeoutOnAccess ) {
				results.created = now();
			}
			// return object
			return results.object;
		}
	}

	/**
	 * Get an object from cache with no metadata tracking
	 *
	 * @objectKey The key to retrieve
	 */
	function getQuiet( required objectKey ){
		// retrieve from map
		var results = variables.pool.get( arguments.objectKey );
		if ( !isNull( results ) ) {
			return results.object;
		}
	}

	/**
	 * Expire an object
	 *
	 * @objectKey The key to expire
	 */
	void function expireObject( required objectKey ){
		var results = variables.pool.get( arguments.objectKey );
		if ( !isNull( local.results ) ) {
			// Expire it
			results.isExpired = true;
		}
	}

	/**
	 * Expire check.  If the object does not exist, it is considered expired
	 *
	 * @objectKey The key to check
	 *
	 * @return boolean
	 */
	function isExpired( required objectKey ){
		var results = variables.pool.get( objectKey );
		if ( !isNull( local.results ) && isStruct( results ) ) {
			return results.isExpired;
		}
		return true;
	}

	/**
	 * Sets an object in the storage
	 *
	 * @objectKey         The object key
	 * @object            The object to save
	 * @timeout           Timeout in minutes
	 * @lastAccessTimeout Idle Timeout in minutes
	 * @extras            A map of extra name-value pairs to store alongside the object
	 */
	void function set(
		required objectKey,
		required object,
		timeout           = "",
		lastAccessTimeout = "",
		extras            = {}
	){
		var data = {
			"object"            : arguments.object,
			"hits"              : 1,
			"timeout"           : arguments.timeout,
			"lastAccessTimeout" : arguments.lastAccessTimeout,
			"created"           : now(),
			"lastAccessed"      : now(),
			"isExpired"         : false
		};
		variables.pool.put( arguments.objectKey, data );
	}

	/**
	 * Clears an object from the storage
	 *
	 * @objectKey The object key to clear
	 */
	function clear( required objectKey ){
		// Check if it exists
		if ( !variables.pool.containsKey( arguments.objectKey ) ) {
			return false;
		}

		// Remove it
		variables.pool.remove( arguments.objectKey );

		// Removed
		return true;
	}

	/**
	 * Get the size of the store
	 */
	function getSize(){
		return variables.pool.size();
	}

	/**
	 * This method sorts the pool keys by a property in the metadata, for example: hits, created, lastAccessed
	 *
	 * @property  The property to sort by: hits, created, lastAccessed
	 * @sortType  The sort type: text, numeric, date
	 * @sortOrder The sort order: asc, desc
	 */
	array function getSortedKeys(
		required property,
		sortType  = "text",
		sortOrder = "asc"
	){
		return structSort(
			variables.pool,
			arguments.sortType,
			arguments.sortOrder,
			arguments.property
		);
	}

	/**
	 * Get the metadata of an object
	 *
	 * @objectKey The key to retrieve
	 */
	struct function getCachedObjectMetadata( required objectKey ){
		var results = variables.pool.get( arguments.objectKey );
		if ( isNull( local.results ) ) {
			return {};
		}
		return {
			"hits"              : results.hits,
			"timeout"           : results.timeout,
			"lastAccessTimeout" : results.lastAccessTimeout,
			"created"           : results.created,
			"lastAccessed"      : results.lastAccessed,
			"isExpired"         : results.isExpired
		}
	}

	/**
	 * ------------------------------------------------------------
	 * Private Methods
	 * ------------------------------------------------------------
	 */

	/**
	 * Get the java Collections utility
	 *
	 * @return java.util.Collections
	 */
	private function getJavaCollections(){
		if ( isNull( variables.collections ) ) {
			variables.collections = createObject( "java", "java.util.Collections" );
		}
		return variables.collections;
	}

}
