/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 *
 * The main interface for CacheBox object storages.
 * A store is a physical counterpart to a cache, in which objects are kept, indexed and monitored.
 *
 * @author Luis Majano
 */
interface {

	/**
	 * Flush the store to a permanent storage
	 */
	void function flush();

	/**
	 * Reap the storage
	 */
	void function reap();

	/**
	 * Clear all the elements in the store
	 */
	void function clearAll();

	/**
	 * Get all the store's object keys array
	 *
	 * @return array
	 */
	function getKeys();

	/**
	 * Check if an object is in the store
	 *
	 * @objectKey The key to lookup
	 *
	 * @return boolean
	 */
	function lookup( required objectKey );

	/**
	 * Get an object from the store with metadata tracking
	 *
	 * @objectKey The key to retrieve
	 */
	function get( required objectKey );

	/**
	 * Get an object from cache with no metadata tracking
	 *
	 * @objectKey The key to retrieve
	 */
	function getQuiet( required objectKey );

	/**
	 * Expire an object
	 *
	 * @objectKey The key to expire
	 */
	void function expireObject( required objectKey );

	/**
	 * Expire check
	 *
	 * @objectKey The key to check
	 *
	 * @return boolean
	 */
	function isExpired( required objectKey );

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
		timeout,
		lastAccessTimeout,
		extras
	);

	/**
	 * Clears an object from the storage
	 *
	 * @objectKey The object key to clear
	 */
	function clear( required objectKey );

	/**
	 * Get the size of the store
	 */
	function getSize();

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
	);

	/**
	 * Get the metadata of an object
	 *
	 * @objectKey The key to retrieve
	 */
	struct function getCachedObjectMetadata( required objectKey );

}
