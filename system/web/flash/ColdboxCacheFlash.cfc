/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * This flash uses CacheBox
 *
 * @author Luis Majano <lmajano@ortussolutions.com>
 */
component extends="coldbox.system.web.flash.AbstractFlashScope" accessors="true" {

	// The cahe name used
	property name="cacheName";
	// The cache provider
	property name="cache";

	/**
	 * Constructor
	 *
	 * @controller.hint ColdBox Controller
	 * @defaults.hint   Default flash data packet for the flash RAM object=[scope,properties,inflateToRC,inflateToPRC,autoPurge,autoSave]
	 */
	function init( required controller, required struct defaults = {} ){
		// default cache name
		variables.cacheName = "default";
		variables.appName   = application.applicationname;

		// super init
		super.init( argumentCollection = arguments );

		// Check if name exists in property
		if ( propertyExists( "cacheName" ) ) {
			variables.cacheName = getProperty( "cacheName" );
		}

		// Setup the cache
		variables.cache = arguments.controller.getCache( variables.cacheName );

		return this;
	}

	/**
	 * Build Flash Key according to our user tracking identifiers
	 */
	function getFlashKey(){
		return "cbFlash:#getController().getUserSessionIdentifier()#";
	}

	/**
	 * Save the flash storage in preparing to go to the next request
	 *
	 * @return SessionFlash
	 */
	function saveFlash(){
		variables.cache.set( getFlashKey(), getScope(), 2 );
		return this;
	}

	/**
	 * Checks if the flash storage exists and IT HAS DATA to inflate.
	 */
	boolean function flashExists(){
		return variables.cache.lookup( getFlashKey() );
	}

	/**
	 * Get the flash storage structure to inflate it.
	 */
	struct function getFlash(){
		var results = variables.cache.get( getFlashKey() );

		return isNull( local.results ) ? {} : results;
	}

	/**
	 * Remove the entire flash storage
	 *
	 * @return SessionFlash
	 */
	function removeFlash(){
		variables.cache.clear( getFlashKey() );
		return this;
	}

}
