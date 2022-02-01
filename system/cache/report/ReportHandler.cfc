/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 *
 * The ColdBox CacheBox Report Handler
 *
 * @author Luis Majano
 */
component accessors="true" serializable="false" {

	/**
	 * Constructor
	 *
	 * @cacheBox   The cache factory binded to
	 * @baseUrl    The baseURL used for reporting
	 * @skin       The skin to use for reporting
	 * @attributes The incoming attributes
	 * @caller     Access to the caller tag
	 */
	function init(
		required coldbox.system.cache.CacheFactory cacheBox,
		required baseUrl,
		required skin,
		required struct attributes,
		required caller
	){
		variables.cacheBox   = arguments.cacheBox;
		variables.baseURL    = arguments.baseURL;
		variables.runtime    = createObject( "java", "java.lang.Runtime" );
		variables.skin       = arguments.skin;
		variables.skinPath   = "/coldbox/system/cache/report/skins/#arguments.skin#";
		// Store tag attributes so they are available on skin templates.
		variables.attributes = arguments.attributes;
		// Caller references
		variables.caller     = arguments.caller;

		return this;
	}

	/**
	 * Process CacheBox Commands
	 *
	 * @command    The command to process
	 * @cacheName  The cache name, defaults to `default`
	 * @cacheEntry The cache entry to act upon
	 */
	boolean function processCommands(
		command    = "",
		cacheName  = "default",
		cacheEntry = ""
	){
		// Commands
		switch ( arguments.command ) {
			// Cache Commands
			case "expirecache": {
				cacheBox.getCache( arguments.cacheName ).expireAll();
				break;
			}
			case "clearcache": {
				cacheBox.getCache( arguments.cacheName ).clearAll();
				break;
			}
			case "reapcache": {
				cacheBox.getCache( arguments.cacheName ).reap();
				break;
			}
			case "delcacheentry": {
				cacheBox.getCache( arguments.cacheName ).clear( arguments.cacheEntry );
				break;
			}
			case "expirecacheentry": {
				cacheBox.getCache( arguments.cacheName ).expireObject( arguments.cacheEntry );
				break;
			}
			case "clearallevents": {
				cacheBox.getCache( arguments.cacheName ).clearAllEvents();
				break;
			}
			case "clearallviews": {
				cacheBox.getCache( arguments.cacheName ).clearAllViews();
				break;
			}
			case "cacheBoxReapAll": {
				cacheBox.reapAll();
				break;
			}
			case "cacheBoxExpireAll": {
				cacheBox.expireAll();
				break;
			}
			case "gc": {
				runtime.getRuntime().gc();
				break;
			}

			default:
				return false;
		}

		return true;
	}

	/**
	 * Renders the caching panel.
	 */
	function renderCachePanel(){
		var cacheNames = variables.cacheBox.getCacheNames();
		var UrlBase    = variables.baseURL;

		savecontent variable="local.content" {
			include "#skinPath#/CachePanel.cfm";
		}

		return local.content;
	}

	/**
	 * Render a cache report for a specific cache
	 *
	 * @cacheName The cache name
	 */
	function renderCacheReport( cacheName = "default" ){
		// Cache info
		var cacheProvider = variables.cacheBox.getCache( arguments.cacheName );
		var cacheConfig   = "";
		var cacheStats    = "";
		var cacheSize     = cacheProvider.getSize();
		var isCacheBox    = true;

		// JVM Data
		var JVMRuntime     = variables.runtime.getRuntime();
		var JVMFreeMemory  = JVMRuntime.freeMemory() / 1024;
		var JVMTotalMemory = JVMRuntime.totalMemory() / 1024;
		var JVMMaxMemory   = JVMRuntime.maxMemory() / 1024;

		// URL Base
		var URLBase = variables.baseURL;

		// Prepare cache report for cachebox
		cacheConfig = cacheProvider.getConfiguration();
		cacheStats  = cacheProvider.getStats();

		savecontent variable="local.content" {
			include "#skinPath#/CacheReport.cfm";
		}

		return local.content;
	}

	/**
	 * Render a cache's content report
	 *
	 * @cacheName The cache name
	 */
	function renderCacheContentReport( cacheName = "default" ){
		var thisKey       = "";
		var x             = "";
		var cacheProvider = variables.cacheBox.getCache( arguments.cacheName );

		// URL Base
		var URLBase = variables.baseURL;

		// Cache Data
		var cacheMetadata    = cacheProvider.getStoreMetadataReport();
		var cacheMDKeyLookup = cacheProvider.getStoreMetadataKeyMap();
		var cacheKeys        = cacheProvider.getKeys();
		var cacheKeysLen     = arrayLen( cacheKeys );

		// Sort Keys
		arraySort( cacheKeys, "textnocase" );

		savecontent variable="local.content" {
			include "#skinPath#/CacheContentReport.cfm";
		}

		return local.content;
	}

	/**
	 * Renders the caching key value dumper.
	 *
	 * @cacheName  The cache name
	 * @cacheEntry The cache entry to dump
	 */
	function renderCacheDumper( cacheName = "default", required cacheEntry ){
		var cachekey       = urlDecode( arguments.cacheEntry );
		var dumperContents = "NOT_FOUND";
		var cache          = variables.cacheBox.getCache( arguments.cacheName );

		//  check key
		if ( !len( cacheKey ) || !cache.lookup( cacheKey ) ) {
			return dumperContents;
		}

		//  Get Data
		var cacheValue = cache.get( cacheKey );

		//  Dump it out
		if ( isSimpleValue( cacheValue ) ) {
			savecontent variable="dumperContents" {
				writeOutput( "<strong>#cachekey#</strong> = #cacheValue#" );
			}
		} else {
			savecontent variable="dumperContents" {
				writeDump( var = cacheValue, top = 5, label = cachekey );
			}
		}

		return dumperContents;
	}

	/**
	 * Get utility object
	 */
	private function getUtil(){
		return new coldbox.system.core.util.Util();
	}

}
