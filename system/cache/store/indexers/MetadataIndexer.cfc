/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * @author Luis Majano
 *
 * This is a utility object that helps object stores keep their elements indexed and stored nicely.
 * It is also a nice way to give back metadata results.
 */
component accessors="true"{

	/**
	 * The metadata pool
	 */
	property name="poolMetadata" doc_generic="java.util.concurrent.ConcurrentHashMap";

	/**
	 * The human id of this indexer
	 */
	property name="indexID";

	/**
	 * The fields this indexer is tracking
	 */
	property name="fields";

	/**
	 * Constructor
	 *
	 * @fields The list or array of fields to bind this index on
	 *
	 */
	function init( required fields ){
		// Create metadata pool
		variables.poolMetadata 	= createObject( "java","java.util.concurrent.ConcurrentHashMap" ).init();
		// Index ID
		variables.indexID 		= createObject( "java", "java.lang.System").identityHashCode( this );
		// Collections (for static .list() method)
		variables.collections 	= createObject( "java", "java.util.Collections" );

		setFields( arguments.fields );

		return this;
	}

	/**
	 * Fancy setter for fields
	 *
	 * @fields The fields list or array
	 */
	MetadataIndexer function setFields( required fields ){
		if( isArray( arguments.fields ) ){
			arguments.fields = arrayToList( arguments.fields );
		}
		variables.fields = arguments.fields;

		return this;
	}

	/**
	 * Clear all the elements in the store
	 */
	MetadataIndexer function clearAll(){
		variables.poolMetadata.clear();
		return this;
	}

	/**
	 * Clears an object from the storage
	 *
	 * @objectKey The object key to clear
	 */
	MetadataIndexer function clear( required objectKey ){
		variables.poolMetadata.remove( arguments.objectKey );
		return this;
	}

	/**
     * Get all the store's object keys array
	 *
	 * @return array
     */
    array function getKeys(){
		return variables.collections.list( variables.poolMetadata.keys() );
	}

	/**
	 * Get a metadata entry for a specific entry. Exception if key not found
	 *
	 * @objectKey The key to get
	 */
	struct function getObjectMetadata( required objectKey ){
		return variables.poolMetadata.get( arguments.objectKey );
	}

	/**
	 * Set the metadata entry for a specific entry
	 *
	 * @objectKey The key to get
	 * @metadata The metadata struct to store
	 */
	MetadataIndexer function setObjectMetadata( required objectKey, required struct metadata ){
		variables.poolMetadata.put( arguments.objectKey, arguments.metadata );
		return this;
	}

	/**
	 * Check if the metadata entry exists for an object
	 *
	 * @objectKey The key to get
	 */
	boolean function objectExists( required objectKey ){
		return variables.poolMetadata.containsKey( arguments.objectKey );
	}

	/**
	 * Get a metadata entry for a specific entry. Exception if key not found
	 *
	 * @objectKey The key to get
	 * @property The metadata property to get
	 * @defaultValue The default value if property doesn't exist
	 */
	function getObjectMetadataProperty( required objectKey, required property, defaultValue ){
		var metadata = getObjectMetadata( arguments.objectKey );

		if( metadata.keyExists( arguments.property ) ){
			return metadata[ arguments.property ];
		}

		if( !isNull( arguments.defaultValue ) ){
			return arguments.defaultValue;
		}

		throw(
			type 		= "InvalidProperty",
			message 	= "Invalid property requested: #arguments.property#",
			detail 		= "Valid properties are: #structKeyList( metadata )#"
		);
	}

	/**
	 * Set a metadata property for a specific entry
	 *
	 * @objectKey The key to set
	 * @property The metadata property to set
	 * @value The value to set
	 */
	MetadataIndexer function setObjectMetadataProperty( required objectKey, required property, required value ){
		getObjectMetadata( arguments.objectKey )
			.insert( arguments.property, arguments.value, true );
		return this;
	}

	/**
	 * Get the size of the store
	 */
	numeric function getSize(){
		return variables.poolMetadata.size();
	}

	/**
	 * Get an array of sorted keys for this indexer according to parameters
	 *
	 * @objectKey
	 * @property
	 * @value
	 */
	array function getSortedKeys( required property, sortType="text", sortOrder="asc" ){
		return structSort(
			variables.poolMetadata,
			arguments.sortType,
			arguments.sortOrder,
			arguments.property
		);
	}

}