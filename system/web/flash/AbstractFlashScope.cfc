/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * An abstract flash scope that can be used to build ColdBox Flash scopes.
 * In order to build scopes you must implement the following methods:
 *
 * - clearFlash() A method that will destroy the flash storage
 * - saveFlash() A method that will be called before relocating so the storage can be saved
 * - flashExists() A method that tells ColdBox if the storage exists and if it has content to inflate
 * - getFlash() A method that returns the flash storage
 *
 * All these methds can use any of the concrete methods below. The most important one is the getScope()
 * method which will most likely be called by the saveFlash() method in order to persist the flashed map.
 * @author Luis Majano <lmajano@ortussolutions.com>
 */
component accessors="true" {

	/**
	 * ColdBox Controller
	 */
	property name="controller";

	/**
	 * Flash Defaults
	 */
	property name="defaults";

	/**
	 * Flash Properties
	 */
	property name="properties";

	/**
	 * Constructor
	 * @controller ColdBox Controller
	 * @defaults Default flash data packet for the flash RAM object=[scope,properties,inflateToRC,inflateToPRC,autoPurge,autoSave]
	 */
	function init( required controller, required struct defaults = {} ){
		variables.controller = arguments.controller;
		variables.defaults   = arguments.defaults;

		// Defaults checks, just in case
		if ( !structKeyExists( variables.defaults, "inflateToRC" ) ) {
			variables.defaults.inflateToRC = true;
		}
		if ( !structKeyExists( variables.defaults, "inflateToPRC" ) ) {
			variables.defaults.inflateToPRC = false;
		}
		if ( !structKeyExists( variables.defaults, "autoPurge" ) ) {
			variables.defaults.autoPurge = true;
		}

		// check for properties
		if ( structKeyExists( arguments.defaults, "properties" ) ) {
			variables.properties = arguments.defaults.properties;
		} else {
			variables.properties = {};
		}

		return this;
	}

	/************************ TO IMPLEMENT ****************************************/

	/**
	 * Save the flash storage in preparing to go to the next request
	 * @return SessionFlash
	 */
	function saveFlash(){
	}

	/**
	 * Checks if the flash storage exists and IT HAS DATA to inflate.
	 */
	boolean function flashExists(){
	}

	/**
	 * Get the flash storage structure to inflate it.
	 */
	struct function getFlash(){
	}

	/**
	 * Remove the entire flash storage
	 *
	 * @return SessionFlash
	 */
	function removeFlash(){
	}

	/************************ CONCRETE METHODS ****************************************/

	/**
	 * Clear the flash storage
	 *
	 * @return AbstractFlashScope
	 */
	function clearFlash(){
		// Check if flash exists
		if ( flashExists() ) {
			var scope = getFlash();

			scope
				.filter( function( key, value ){
					if ( value.keyExists( "autoPurge" ) ) {
						return value.autoPurge;
					}
					return false;
				} )
				.keyArray()
				.each( function( item ){
					scope.delete( item );
				} );

			if ( scope.isEmpty() ) {
				removeFlash();
			}
		}

		return this;
	}


	/**
	 * Inflate flash items back into rc/prc
	 *
	 * @return AbstractFlashScope
	 */
	function inflateFlash(){
		var event = getController().getRequestService().getContext();

		// Lock for race-conditions
		lock name="inflate.flash.#getUtil().getSessionIdentifier()#" type="exclusive" throwontimeout="true" timeout="20" {
			// Process Inflations
			getFlash()
				// Process only keys that are marked as keep and content exists
				.filter( function( key, value ){
					return arguments.value.keep && !isNull( arguments.value.content );
				} )
				.each( function( key, value ){
					// Inflate into RC?
					if ( arguments.value.inflateToRC ) {
						event.setValue( name = arguments.key, value = arguments.value.content );
					}
					// Inflate into PRC?
					if ( arguments.value.inflateToPRC ) {
						event.setPrivateValue( name = arguments.key, value = arguments.value.content );
					}
					// Store it again
					put(
						name         = arguments.key,
						value        = arguments.value.content,
						keep         = ( arguments.value.autoPurge ? false : true ),
						autoPurge    = arguments.value.autoPurge,
						inflateToRC  = arguments.value.inflateToRC,
						inflateToPRC = arguments.value.inflateToPRC
					);
				} );

			// Clear Flash Storage
			clearFlash();
		}

		return this;
	}

	/**
	 * Get the flash temp request storage used throughout a request until flashed at the end of a request.
	 */
	struct function getScope(){
		if ( !structKeyExists( request, "cbox_flash_temp_storage" ) ) {
			request[ "cbox_flash_temp_storage" ] = structNew();
		}

		return request[ "cbox_flash_temp_storage" ];
	}

	/**
	 * Get a list of all the objects in the temp flash scope
	 */
	string function getKeys(){
		return structKeyList( getScope() );
	}

	/**
	 * Clear the temp flash scope and remove all data
	 *
	 * @return AbstractFlashScope
	 */
	function clear(){
		structClear( getScope() );
		return this;
	}

	/**
	 * Keep all or a single flash temp variable alive for another relocation
	 *
	 * @keys The keys in the flash RAM that you want to mark to be kept until the next request
	 *
	 * @return AbstractFlashScope
	 */
	function keep( string keys = "" ){
		statusMarks( arguments.keys, true );
		saveFlash();
		return this;
	}

	/**
	 * Keep all or a single flash temp variable alive for another relocation
	 *
	 * @keys The keys in the flash RAM that you want to mark to be kept until the next request
	 *
	 * @return AbstractFlashScope
	 */
	function discard( string keys = "" ){
		statusMarks( arguments.keys, false );
		return this;
	}

	/**
	 * Keep all or a single flash temp variable alive for another relocation
	 *
	 * @name The name of the value
	 * @value The value to store
	 * @saveNow Whether to send the contents for saving to flash ram or not. Default is to wait for a relocation
	 * @keep Whether to mark the entry to be kept after saving to the flash storage.
	 * @inflateToRC Whether this flash variable is inflated to the Request Collection or not
	 * @inflateToPRC Whether this flash variable is inflated to the Private Request Collection or not
	 * @autoPurge Flash memory auto purges variables for you. You can control this purging by saying false to autoPurge
	 *
	 * @return AbstractFlashScope
	 */
	function put(
		required string name,
		required value,
		boolean saveNow      = false,
		boolean keep         = true,
		boolean inflateToRC  = "#variables.defaults.inflateToRC#",
		boolean inflateToPRC = "#variables.defaults.inflateToPRC#",
		boolean autoPurge    = "#variables.defaults.autoPurge#"
	){
		var scope = getScope();
		var entry = structNew();

		// Create Flash Entry
		entry.content      = arguments.value;
		entry.keep         = arguments.keep;
		entry.inflateToRC  = arguments.inflateToRC;
		entry.inflateToPRC = arguments.inflateToPRC;
		entry.autoPurge    = arguments.autoPurge;

		// Save entry in temp storage
		scope[ arguments.name ] = entry;

		// Save to storage
		if ( arguments.saveNow ) {
			saveFlash();
		}

		return this;
	}

	/**
	 * Put a map of name-value pairs into the flash scope
	 *
	 * @map The map of data to flash
	 * @saveNow Whether to send the contents for saving to flash ram or not. Default is to wait for a relocation
	 * @keep Whether to mark the entry to be kept after saving to the flash storage.
	 * @inflateToRC Whether this flash variable is inflated to the Request Collection or not
	 * @inflateToPRC Whether this flash variable is inflated to the Private Request Collection or not
	 * @autoPurge Flash memory auto purges variables for you. You can control this purging by saying false to autoPurge
	 *
	 * @return AbstractFlashScope
	 */
	function putAll(
		required struct map,
		boolean saveNow      = false,
		boolean keep         = true,
		boolean inflateToRC  = "#variables.defaults.inflateToRC#",
		boolean inflateToPRC = "#variables.defaults.inflateToPRC#",
		boolean autoPurge    = "#variables.defaults.autoPurge#"
	){
		// Save all keys in map
		for ( var key in arguments.map ) {
			// Store value and key to pass
			arguments.name  = key;
			arguments.value = arguments.map[ key ];
			// place in put
			put( argumentCollection = arguments );
		}

		// Save to Storage
		if ( arguments.saveNow ) {
			saveFlash();
		}

		return this;
	}

	/**
	 * Remove an object from flash scope
	 *
	 * @name Whether to send the contents for saving to flash ram or not. Default is to wait for a relocation
	 * @saveNow
	 *
	 * @return AbstractFlashScope
	 */
	function remove( required name, boolean saveNow = false ){
		structDelete( getScope(), arguments.name );
		if ( arguments.saveNow ) {
			saveFlash();
		}
		return this;
	}

	/**
	 * Check if an object exists in flash scope
	 *
	 * @name The name of the value
	 */
	boolean function exists( required name ){
		return structKeyExists( getScope(), arguments.name );
	}

	/**
	 * Get the size of the items in flash scope
	 */
	numeric function size(){
		return structCount( getScope() );
	}

	/**
	 * Check if the flash scope is empty or not
	 */
	boolean function isEmpty(){
		return structIsEmpty( getScope() );
	}

	/**
	 * Returns a struct of all the flash content values. If the value is null, we will return an empty value.
	 */
	struct function getAll(){
		return getScope().map( function( key, value ){
			return value.content;
		} );
	}

	/**
	 * Get an object from flash scope
	 *
	 * @name The name of the value
	 * @defaultValue The default value if the scope does not have the object"
	 */
	function get( required name, defaultValue ){
		var scope = getScope();

		if ( exists( arguments.name ) ) {
			return scope[ arguments.name ].content;
		}

		if ( structKeyExists( arguments, "defaultValue" ) ) {
			return arguments.defaultValue;
		}

		throw(
			message = "#arguments.name# not found in flash scope. Valid keys are #getKeys()#.",
			type    = "#getMetadata( this ).name#.KeyNotFoundException"
		);
	}

	/**
	 * Persist keys from the coldbox request collection in flash scope. If using exclude, then it will try to persist the entire rc but excluding.  Including will only include the keys passed
	 *
	 * @include MUTEX: A list of request collection keys you want to persist
	 * @exclude MUTEX: A list of request collection keys you want to exclude from persisting. If sent, then we inspect all rc keys.
	 * @saveNow Whether to send the contents for saving to flash ram or not. Default is to wait for a relocation
	 *
	 * @return AbstractFlashScope
	 */
	function persistRC(
		include         = "",
		exclude         = "",
		boolean saveNow = false
	){
		var rc = getController()
			.getRequestService()
			.getContext()
			.getCollection();
		var somethingToSave = false;

		// Cleanup
		arguments.include = replace( arguments.include, " ", "", "all" );
		arguments.exclude = replace( arguments.exclude, " ", "", "all" );

		// Exclude?
		if ( len( trim( arguments.exclude ) ) ) {
			for ( var thisKey in rc ) {
				// Only persist keys that are not Excluded.
				if ( !listFindNoCase( arguments.exclude, thisKey ) ) {
					put( thisKey, rc[ thisKey ] );
					somethingToSave = true;
				}
			}
		}

		// Include?
		if ( len( trim( arguments.include ) ) ) {
			for ( var x = 1; x <= listLen( arguments.include ); x++ ) {
				var thisKey = listGetAt( arguments.include, x );
				// Check if key exists in RC
				if ( structKeyExists( rc, thisKey ) ) {
					put( thisKey, rc[ thisKey ] );
					somethingToSave = true;
				}
			}
		}

		// Save Now?
		if ( arguments.saveNow && somethingToSave ) {
			saveFlash();
		}

		return this;
	}


	/**
	 * Get a named property
	 *
	 * @property The property name
	 */
	function getProperty( required property ){
		return variables.properties[ arguments.property ];
	}

	/**
	 * Set a named property
	 *
	 * @property The property name
	 * @value The value
	 *
	 * @return AbstractFlashScope
	 */
	function setProperty( required property, required value ){
		variables.properties[ arguments.property ] = arguments.value;
		return this;
	}


	/**
	 * Check a named property
	 *
	 * @property The property name
	 */
	function propertyExists( required property ){
		return structKeyExists( variables.properties, arguments.property );
	}

	/**
	 * Change the status marks of the temp scope entries
	 */
	private function statusMarks( string keys = "", boolean keep = true ){
		var scope      = getScope();
		var targetKeys = structKeyArray( scope );

		// keys passed in?
		if ( len( trim( arguments.keys ) ) ) {
			targetKeys = listToArray( keys );
		}

		// Keep them if they exist
		for ( var thisKey in targetkeys ) {
			if ( structKeyExists( scope, thisKey ) ) {
				scope[ thisKey ].keep = arguments.keep;
			}
		}

		return this;
	}

	/**
	 * Get utility object
	 */
	private function getUtil(){
		return controller.getUtil();
	}

}
