/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 *
 * I am a disk store, I am not that fancy as I am slower.
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
	 * The metadata indexer object
	 */
	property name="indexer" doc_generic="coldbox.system.cache.store.indexers.MetadataIndexer";

	/**
	 * The object serializer and deserializer utility
	 */
	property name="converter" doc_generic="coldbox.system.core.conversion.ObjectMarshaller";

	/**
	 * The location of the disk cache
	 */
	property name="directoryPath";

	/**
	 * Constructor
	 *
	 * @cacheProvider             The associated cache provider as coldbox.system.cache.providers.ICacheProvider
	 * @cacheprovider.doc_generic coldbox.system.cache.providers.ICacheProvider
	 */
	function init( required cacheProvider ){
		// Store Fields
		var fields = "hits,timeout,lastAccessTimeout,created,LastAccessed,isExpired,isSimple";
		var config = arguments.cacheProvider.getConfiguration();

		// Prepare instance
		variables.cacheProvider = arguments.cacheProvider;
		variables.storeID       = createUUID();
		variables.indexer       = new coldbox.system.cache.store.indexers.MetadataIndexer( fields );
		variables.converter     = new coldbox.system.core.conversion.ObjectMarshaller();
		variables.directoryPath = "";

		// Get extra configuration details from cacheProvider's configuration for this diskstore
		// Auto Expand
		if ( isNull( config.autoExpandPath ) ) {
			config.autoExpandPath = true;
		}

		// Check directory path
		if ( isNull( config.directoryPath ) ) {
			throw(
				message = "The 'directoryPath' configuration property was not found in the cache configuration",
				detail  = "Please check the cache configuration and add the 'directoryPath' property. Current Configuration: #config.toString()#",
				type    = "DiskStore.InvalidConfigurationException"
			);
		}

		// AutoExpand
		variables.directoryPath = ( config.autoExpandPath ? expandPath( config.directoryPath ) : config.directoryPath );

		// Check if directory exists else create it
		if ( !directoryExists( variables.directoryPath ) ) {
			directoryCreate( variables.directoryPath );
		}

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
		directoryDelete( variables.directoryPath, true );
		variables.indexer.clearAll();
		directoryCreate( variables.directoryPath );
	}

	/**
	 * Get all the store's object keys array
	 *
	 * @return array
	 */
	function getKeys(){
		return variables.indexer.getKeys();
	}

	/**
	 * Check if an object is in the store
	 *
	 * @objectKey The key to lookup
	 *
	 * @return boolean
	 */
	function lookup( required objectKey ){
		lock
			name            ="DiskStore.#variables.storeID#.#arguments.objectKey#"
			type            ="readonly"
			timeout         ="10"
			throwonTimeout  ="true" {
			var isFileOnDisk= fileExists( getCacheFilePath( arguments.objectKey ) );

			// check if object is missing and in indexer
			if ( !isFileOnDisk AND variables.indexer.objectExists( arguments.objectKey ) ) {
				variables.indexer.clear( arguments.objectKey );
				return false;
			}

			// Check if object on disk, on indexer and NOT expired
			if (
				isFileOnDisk AND
				variables.indexer.objectExists( arguments.objectKey ) AND NOT variables.indexer.getObjectMetadataProperty(
					arguments.objectKey,
					"isExpired"
				)
			) {
				return true;
			}

			return false;
		}
	}

	/**
	 * Get an object from the store with metadata tracking, or null if not found
	 *
	 * @objectKey The key to retrieve
	 */
	function get( required objectKey ){
		lock
			name          ="DiskStore.#variables.storeID#.#arguments.objectKey#"
			type          ="exclusive"
			timeout       ="10"
			throwonTimeout="true" {
			if ( lookup( arguments.objectKey ) ) {
				// Record Metadata Access
				variables.indexer.setObjectMetadataProperty(
					arguments.objectKey,
					"hits",
					variables.indexer.getObjectMetadataProperty( arguments.objectKey, "hits" ) + 1
				);
				variables.indexer.setObjectMetadataProperty( arguments.objectKey, "LastAccessed", now() );
				// Is resetTimeoutOnAccess enabled? If so, jump up the creation time to increase the timeout
				if ( variables.cacheProvider.getConfiguration().resetTimeoutOnAccess ) {
					variables.indexer.setObjectMetadataProperty( arguments.objectKey, "created", now() );
				}

				return getQuiet( arguments.objectKey );
			}
		}
	}

	/**
	 * Get an object from cache with no metadata tracking
	 *
	 * @objectKey The key to retrieve
	 */
	function getQuiet( required objectKey ){
		lock
			name          ="DiskStore.#variables.storeID#.#arguments.objectKey#"
			type          ="exclusive"
			timeout       ="10"
			throwonTimeout="true" {
			if ( lookup( arguments.objectKey ) ) {
				var thisFilePath = getCacheFilePath( arguments.objectKey );

				// if simple value, just return it
				if ( variables.indexer.getObjectMetadataProperty( arguments.objectKey, "isSimple" ) ) {
					return trim( fileRead( thisFilePath ) );
				}

				// else we deserialize
				return variables.converter.deserializeObject( filePath = thisFilePath );
			}
		}
	}

	/**
	 * Expire an object
	 *
	 * @objectKey The key to expire
	 */
	void function expireObject( required objectKey ){
		variables.indexer.setObjectMetadataProperty( arguments.objectKey, "isExpired", true );
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
		var thisFilePath = getCacheFilePath( arguments.objectKey );
		var metaData     = {
			"hits"              : 1,
			"timeout"           : arguments.timeout,
			"lastAccessTimeout" : arguments.lastAccessTimeout,
			"created"           : now(),
			"lastAccessed"      : now(),
			"isExpired"         : false,
			"isSimple"          : true
		};

		lock
			name          ="DiskStore.#variables.storeID#.#arguments.objectKey#"
			type          ="exclusive"
			timeout       ="10"
			throwonTimeout="true" {
			// If simple value just write it out to disk
			if ( isSimpleValue( arguments.object ) ) {
				fileWrite( thisFilePath, trim( arguments.object ) );
			} else {
				// serialize it
				variables.converter.serializeObject( arguments.object, thisFilePath );
				metaData.isSimple = false;
			}
			// Save the object's metadata
			variables.indexer.setObjectMetadata( arguments.objectKey, metaData );
		}
	}

	/**
	 * Clears an object from the storage
	 *
	 * @objectKey The object key to clear
	 */
	function clear( required objectKey ){
		lock
			name            ="DiskStore.#variables.storeID#.#arguments.objectKey#"
			type            ="exclusive"
			timeout         ="10"
			throwonTimeout  ="true" {
			var thisFilePath= getCacheFilePath( arguments.objectKey );
			// check it
			if ( !fileExists( thisFilePath ) ) {
				return false;
			}
			// Remove it
			fileDelete( thisFilePath );
			variables.indexer.clear( arguments.objectKey );

			return true;
		}
	}

	/**
	 * Get the size of the store
	 */
	function getSize(){
		return variables.indexer.getSize();
	}

	// ********************************* PRIVATE ************************************//

	/**
	 * Get the cached file path according to our rules
	 *
	 * @objectKey The key to lookup
	 */
	function getCacheFilePath( required objectKey ){
		return variables.directoryPath & "/" & hash( arguments.objectKey ) & ".cachebox";
	}

}
