/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * @author Luis Majano
 *
 * I am a concurrent object store. In other words, I am fancy! This store is case-sensitive
 */
component implements="coldbox.system.cache.store.IObjectStore" accessors="true"{

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
	 * The metadata indexer object
	 */
	property name="indexer" doc_generic="coldbox.system.cache.store.indexers.MetadataIndexer";

	/**
	 * Constructor
	 *
	 * @cacheProvider The associated cache provider as coldbox.system.cache.providers.ICacheProvider
	 * @cacheprovider.doc_generic coldbox.system.cache.providers.ICacheProvider
	 */
	function init( required cacheProvider ){
		// Indexing Fields
		var fields = "hits,timeout,lastAccessTimeout,created,lastAccessed,isExpired";

		// Prepare instance
		variables.cacheProvider = arguments.cacheProvider;
		variables.storeID       = createObject( "java", "java.lang.System" ).identityHashCode( this );
		variables.pool          = createObject( "java","java.util.concurrent.ConcurrentHashMap" ).init();
		variables.indexer       = new coldbox.system.cache.store.indexers.MetadataIndexer( fields );
		variables.collections 	= createObject( "java", "java.util.Collections" );

		return this;
	}

	/**
     * Flush the store to a permanent storage
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
     * Get the store's pool metadata indexer structure
	 *
	 * @return coldbox.system.cache.store.indexers.MetadataIndexer
     */
    function getIndexer(){
        return variables.indexer;
    }

	/**
	 * Clear all the elements in the store
	 */
	void function clearAll(){
		variables.pool.clear();
		variables.indexer.clearAll();
	}

	/**
     * Get all the store's object keys array
	 *
	 * @return array
     */
    function getKeys(){
		return variables.collections.list( variables.pool.keys() );
    }

	/**
	 * Check if an object is in the store
	 *
	 * @objectKey The key to lookup
	 *
	 * @return boolean
	 */
	function lookup( required objectKey ){
		return (
			variables.pool.containsKey( arguments.objectKey ) AND
			variables.indexer.objectExists( arguments.objectKey ) AND NOT
			variables.indexer.getObjectMetadataProperty( arguments.objectKey, "isExpired" )
		);
	}

	/**
	 * Get an object from the store with metadata tracking, or null if not found
	 *
	 * @objectKey The key to retrieve
	 */
	function get( required objectKey ){
		// retrieve from map
		var results = variables.pool.get( arguments.objectKey );
		if( !isNull( local.results ) ){

			// Record Metadata Access
			variables.indexer.setObjectMetadataProperty(
				arguments.objectKey,
				"hits",
				variables.indexer.getObjectMetadataProperty( arguments.objectKey, "hits" ) + 1
			);
			variables.indexer.setObjectMetadataProperty(
				arguments.objectKey,
				"lastAccessed",
				now()
			);
			// Is resetTimeoutOnAccess enabled? If so, jump up the creation time to increase the timeout
			if( variables.cacheProvider.getConfiguration().resetTimeoutOnAccess ){
				variables.indexer.setObjectMetadataProperty(
					arguments.objectKey,
					"created",
					now()
				);
			}

			// return object
			return results;
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
		if( !isNull( local.results ) ){
			return results;
		}
	}

	/**
	 * Expire an object
	 *
	 * @objectKey The key to expire
	 */
	void function expireObject( required objectKey ){
		variables.indexer.setObjectMetadataProperty(
			arguments.objectKey,
			"isExpired",
			true
		);
    }

	/**
	 * Expire check
	 *
	 * @objectKey The key to check
	 *
	 * @return boolean
	 */
	function isExpired( required objectKey ){
		return variables.indexer.getObjectMetadataProperty( arguments.objectKey, "isExpired" );
	}

	/**
	 * Sets an object in the storage
	 *
	 * @objectKey The object key
	 * @object The object to save
	 * @timeout Timeout in minutes
	 * @lastAccessTimeout Idle Timeout in minutes
	 * @extras A map of extra name-value pairs to store alongside the object
	 */
	void function set(
		required objectKey,
		required object,
		timeout="",
		lastAccessTimeout="",
		extras={}
	){
		// Set new Object into cache pool
		variables.pool.put( arguments.objectKey, arguments.object );

		// Create object's metadata
		var metaData = {
			"hits"              = 1,
			"timeout"           = arguments.timeout,
			"lastAccessTimeout" = arguments.lastAccessTimeout,
			"created"           = now(),
			"lastAccessed"      = now(),
			"isExpired"         = false
		};

		// Save the object's metadata
		variables.indexer.setObjectMetadata( arguments.objectKey, metaData );
	}

	/**
	 * Clears an object from the storage
	 *
	 * @objectKey The object key to clear
	 */
	function clear( required objectKey ){
		// Check if it exists
		if( !variables.pool.containsKey( arguments.objectKey ) ) {
			return false;
		}

		// Remove it
		variables.pool.remove( arguments.objectKey );
		variables.indexer.clear( arguments.objectKey );

		// Removed
		return true;
    }

    /**
	 * Get the size of the store
	 */
	function getSize(){
        return variables.pool.size();
	}

}