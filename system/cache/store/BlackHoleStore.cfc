/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * @author Luis Majano
 *
 * I am the fastest way to cache objects. I am so fast because I don't do anything. I'm really a tool to use when working on caching strategies. When I am in use nothing is cached. It just vanishes.
 */
component implements="coldbox.system.cache.store.IObjectStore" accessors=true{

	/**
	 * The cache provider reference
	 */
	property name="cacheProvider" doc_generic="coldbox.system.cache.providers.ICacheProvider";

	/**
	 * The human store name
	 */
	property name="storeID";

	/**
	 * Constructor
	 *
	 * @cacheProvider The associated cache provider as coldbox.system.cache.providers.ICacheProvider
	 * @cacheprovider.doc_generic coldbox.system.cache.providers.ICacheProvider
	 */
	function init( required cacheProvider ){
		// Store Fields
        var fields = "hits,timeout,lastAccessTimeout,created,LastAccessed,isExpired,isSimple";
        var config = arguments.cacheProvider.getConfiguration();

        // Prepare instance
        variables.cacheProvider     = arguments.cacheProvider;
        variables.storeID 		    = 'blackhole';

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
	 * Clear all the elements in the store
	 */
	void function clearAll(){
        return;
	}

    /**
     * Get the store's pool metadata indexer structure
	 *
	 * @return coldbox.system.cache.store.indexers.MetadataIndexer
     */
    function getIndexer(){
        return;
    }

     /**
     * Get all the store's object keys array
	 *
	 * @return array
     */
    function getKeys(){
        return;
    }

	/**
	 * Check if an object is in the store
	 *
	 * @objectKey The key to lookup
	 *
	 * @return boolean
	 */
	function lookup( required objectKey ){
		return false;
	}

	/**
	 * Get an object from the store with metadata tracking
	 *
	 * @objectKey The key to retrieve
	 */
	function get( required objectKey ){
		return;
	}

	/**
	 * Get an object from cache with no metadata tracking
	 *
	 * @objectKey The key to retrieve
	 */
	function getQuiet( required objectKey ){
		return;
    }

    /**
	 * Expire an object
	 *
	 * @objectKey The key to expire
	 */
	void function expireObject( required objectKey ){
		return;
    }

    /**
	 * Expire check
	 *
	 * @objectKey The key to check
	 *
	 * @return boolean
	 */
	function isExpired( required objectKey ){
		return;
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
		timeout=0,
		lastAccessTimeout=0,
		extras={}
	){
		return;
	}

	/**
	 * Clears an object from the storage
	 *
	 * @objectKey The object key to clear
	 */
	function clear( required objectKey ){
        return;
    }

    /**
	 * Get the size of the store
	 */
	function getSize(){
        return 0;
	}

}