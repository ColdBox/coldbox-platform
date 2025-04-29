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
		var config = arguments.cacheProvider.getConfiguration();

		// Prepare instance
		variables.cacheProvider = arguments.cacheProvider;
		variables.storeID       = createUUID();
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
	 * Clear all the elements in the store
	 */
	void function clearAll(){
		directoryDelete( variables.directoryPath, true );
		directoryCreate( variables.directoryPath );
	}

	/**
	 * Get all the store's object keys array
	 *
	 * @return array
	 */
	function getKeys(){
		return directoryList(
			variables.directoryPath,
			false,
			"name",
			"*.cachebox",
			"asc",
			"file"
		).map( ( file ) => replace( file, ".cachebox", "", "all" ) );
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
			var thisFilePath= getCacheFilePath( arguments.objectKey );
			var isFileOnDisk= fileExists( thisFilePath );

			if ( !isFileOnDisk ) {
				return false;
			}

			var results = variables.converter.deserializeObject( filePath: thisFilePath );
			if ( isStruct( results ) && results.keyExists( "isExpired" ) && results.isExpired ) {
				return false;
			}

			return true;
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
				var thisFilePath = getCacheFilePath( arguments.objectKey );
				var results      = variables.converter.deserializeObject( filePath: thisFilePath );

				if ( isStruct( results ) && results.keyExists( "object" ) ) {
					results.hits         = results.hits++;
					results.lastAccessed = now();
					if ( variables.cacheProvider.getConfiguration().resetTimeoutOnAccess ) {
						results.created = now();
					}
					variables.converter.serializeObject( results, thisFilePath );
					return results.object;
				}
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
				// else we deserialize
				var results      = variables.converter.deserializeObject( filePath = thisFilePath );
				if ( isStruct( results ) && results.keyExists( "object" ) ) {
					return results.object;
				}
			}
		}
	}

	/**
	 * Expire an object
	 *
	 * @objectKey The key to expire
	 */
	void function expireObject( required objectKey ){
		lock
			name          ="DiskStore.#variables.storeID#.#arguments.objectKey#"
			type          ="exclusive"
			timeout       ="10"
			throwonTimeout="true" {
			if ( lookup( arguments.objectKey ) ) {
				var thisFilePath = getCacheFilePath( arguments.objectKey );
				// else we deserialize
				var results      = variables.converter.deserializeObject( filePath = thisFilePath );
				if ( isStruct( results ) && results.keyExists( "isExpired" ) ) {
					results.isExpired = true;
					variables.converter.serializeObject( results, thisFilePath );
				}
			}
		}
	}

	/**
	 * Expire check
	 *
	 * @objectKey The key to check
	 *
	 * @return boolean
	 */
	function isExpired( required objectKey ){
		var thisFilePath = getCacheFilePath( arguments.objectKey );
		lock
			name          ="DiskStore.#variables.storeID#.#arguments.objectKey#"
			type          ="exclusive"
			timeout       ="10"
			throwonTimeout="true" {
			if ( fileExists( thisFilePath ) ) {
				// else we deserialize
				var results = variables.converter.deserializeObject( filePath: thisFilePath );
				if ( isStruct( results ) && results.keyExists( "isExpired" ) ) {
					return results.isExpired;
				}
			}
		}

		// If we are here, then it is expired, it does not exist
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
		var thisFilePath = getCacheFilePath( arguments.objectKey );
		var data         = {
			"object"            : arguments.object,
			"hits"              : 1,
			"timeout"           : arguments.timeout,
			"lastAccessTimeout" : arguments.lastAccessTimeout,
			"created"           : now(),
			"lastAccessed"      : now(),
			"isExpired"         : false
		};

		lock
			name          ="DiskStore.#variables.storeID#.#arguments.objectKey#"
			type          ="exclusive"
			timeout       ="10"
			throwonTimeout="true" {
			variables.converter.serializeObject( data, thisFilePath );
		}
	}

	/**
	 * Clears an object from the storage
	 *
	 * @objectKey The object key to clear
	 */
	function clear( required objectKey ){
		var thisFilePath = getCacheFilePath( arguments.objectKey );

		if ( fileExists( thisFilePath ) ) {
			lock
				name          ="DiskStore.#variables.storeID#.#arguments.objectKey#"
				type          ="exclusive"
				timeout       ="10"
				throwonTimeout="true" {
				if ( fileExists( thisFilePath ) ) {
					fileDelete( thisFilePath );
					return true;
				}
			}
		}

		return false;
	}

	/**
	 * Get the size of the store
	 */
	function getSize(){
		return directoryList(
			variables.directoryPath,
			false,
			"name",
			"*.cachebox",
			"asc",
			"file"
		).len();
	}

	/**
	 * This method sorts the pool keys by a property in the metadata. However,
	 * for the DiskStore, we will just use the DateLastModified property or natural order
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
		var sorting = "DateLastModified #arguments.sortOrder#";

		return directoryList(
			variables.directoryPath,
			false,
			"name",
			"*.cachebox",
			sorting,
			"file"
		).map( ( file ) => replace( file, ".cachebox", "", "all" ) );
	}

	/**
	 * Get the metadata of an object
	 *
	 * @objectKey The key to retrieve
	 */
	struct function getCachedObjectMetadata( required objectKey ){
		var thisFilePath = getCacheFilePath( arguments.objectKey );

		lock
			name          ="DiskStore.#variables.storeID#.#arguments.objectKey#"
			type          ="exclusive"
			timeout       ="10"
			throwonTimeout="true" {
			if ( fileExists( thisFilePath ) ) {
				// else we deserialize
				var results = variables.converter.deserializeObject( filePath = thisFilePath );
				if ( isStruct( results ) ) {
					return {
						"hits"              : results.hits,
						"timeout"           : results.timeout,
						"lastAccessTimeout" : results.lastAccessTimeout,
						"created"           : results.created,
						"lastAccessed"      : results.lastAccessed,
						"isExpired"         : results.isExpired
					}
				}
			}
		}

		return {};
	}

	// ********************************* PRIVATE ************************************//

	/**
	 * Get the cache file path for an object key
	 *
	 * @objectKey The key to compose the file path
	 */
	function getCacheFilePath( required objectKey ){
		arguments.objectKey = replace( arguments.objectKey, ".", "_", "all" );
		return "#variables.directoryPath#/#arguments.objectKey#.cachebox";
	}

}
