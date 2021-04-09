/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ----
 * This is a CacheBox configuration object.  You can use it to configure a CacheBox variables.
 **/
component accessors="true"{

	/**
	 * Get the static default configuration struct
	 */
	property name="DEFAULTS" type="struct";

	/**
	 * The logbox config dsl this config object represents
	 */
	property name="logBoxConfig";

	/**
	 * The default cache config
	 */
	property name="defaultCache" type="struct";

	/**
	 * The caches configuration
	 */
	property name="caches" type="struct";

	/**
	 * The scope configuration settings
	 */
	property name="scopeRegistration" type="struct";

	/**
	 * The scope configuration settings
	 */
	property name="listeners" type="array";

	// Utility class
	variables.utility  = new coldbox.system.core.util.Util();
	// CacheBox Provider Defaults STATIC
	variables.DEFAULTS = {
		logBoxConfig       = "coldbox.system.cache.config.LogBox",
		cacheBoxProvider   = "coldbox.system.cache.providers.CacheBoxProvider",
		coldboxAppProvider = "coldbox.system.cache.providers.CacheBoxColdBoxProvider",
		scopeRegistration  = {
			enabled = true,
			scope   = "application",
			key     = "cachebox"
		}
	};
	// Startup the configuration
	reset();

	/**
	 * Constructor
	 *
	 * @CFCConfig The cacheBox Data Configuration CFC instance
	 * @CFCConfigPath The cacheBox Data Configuration CFC path to use
	 */
	function init( CFCConfig, string CFCConfigPath ){
		// Test and load via Data CFC Path
		if( !isNull( arguments.CFCConfigPath ) ){
			arguments.CFCConfig = createObject( "component", arguments.CFCConfigPath );
		}

		// Test and load via Data CFC
		if( !isNull( arguments.CFCConfig ) and isObject( arguments.CFCConfig ) ){
			// Decorate our data CFC
			arguments.CFCConfig.getPropertyMixin = utility.getMixerUtil().getPropertyMixin;
			// Execute the configuration
			arguments.CFCConfig.configure();
			// Load the DSL
			loadDataDSL(
				arguments.CFCConfig.getPropertyMixin( "cacheBox", "variables", {} )
			);
		}

		// Just return, most likely programmatic config
		return this;
	}

	/**
	 * Set the logBox Configuration to use
	 * @config The configuration file to use
	 */
	CacheBoxConfig function logBoxConfig( required string config ){
		variables.logBoxConfig = arguments.config;
		return this;
	}

	/**
	 * Load a data configuration CFC data DSL
	 */
	CacheBoxConfig function loadDataDSL( required struct rawDSL ){
		var cacheBoxDSL  = arguments.rawDSL;

		// Is default configuration defined
		if( isNull( cacheBoxDSL.defaultCache ) ){
			throw(
				"No default cache defined",
				"Please define the 'defaultCache'",
				"CacheBoxConfig.NoDefaultCacheFound"
			);
		}

		// Register Default Cache
		this.defaultCache( argumentCollection=cacheBoxDSL.defaultCache );

		// Register LogBox Configuration
		this.logBoxConfig( variables.DEFAULTS.logBoxConfig );
		if( !isNull( cacheBoxDSL.logBoxConfig ) ){
			this.logBoxConfig( cacheBoxDSL.logBoxConfig );
		}

		// Register Server Scope Registration
		if( !isNull( cacheBoxDSL.scopeRegistration ) ){
			this.scopeRegistration( argumentCollection=cacheBoxDSL.scopeRegistration );
		}

		// Register Caches
		if( !isNull( cacheBoxDSL.caches ) ){
			for( var key in cacheBoxDSL.caches ){
				cacheBoxDSL.caches[ key ].name = key;
				this.cache( argumentCollection=cacheBoxDSL.caches[ key ] );
			}
		}

		// Register listeners
		if( !isNull( cacheBoxDSL.listeners ) ){
			for( var key in cacheBoxDSL.listeners ){
				this.listener( argumentCollection=key );
			}
		}

		return this;
	}

	/**
	 * Reset the configuration
	 */
	CacheBoxConfig function reset(){
		// default cache
		variables.defaultCache = {};
		// logBox File
		variables.logBoxConfig = "";
		// Named Caches
		variables.caches = {};
		// Listeners
		variables.listeners = [];
		// Scope Registration
		variables.scopeRegistration = {
			enabled = false,
			scope 	= "server",
			key		= "cachebox"
		};

		return this;
	}

	/**
	 * Reset the default cache configurations
	 */
	CacheBoxConfig function resetDefaultCache(){
		variables.defaultCache = {};
		return this;
	}

	/**
	 * Reset the set caches
	 */
	CacheBoxConfig function resetCaches(){
		variables.caches = {};
		return this;
	}

	/**
	 * Reset the set listeners
	 */
	CacheBoxConfig function resetListeners(){
		variables.listeners = [];
		return this;
	}

	/**
	 * A quick snapshot of the state
	 */
	struct function getMemento(){
		return variables.filter( function( k, v ){
			return ( !isCustomFunction( v ) && !isObject( v ) );
		} );
	}

	/**
	 * Validates the configuration. If not valid, it will throw an appropriate exception.
	 *
	 * @throws CacheBoxConfig.NoDefaultCacheFound
	 */
	CacheBoxConfig function validate(){
		// Is the default cache defined
		if( structIsEmpty( variables.defaultCache ) ){
			throw(
				message = "Invalid Configuration. No default cache defined",
				type 	= "CacheBoxConfig.NoDefaultCacheFound"
			);
		}
		return this;
	}

	/**
	 * Define the cachebox factory scope registration
	 * @enabled Enable registration
	 * @scope The scope to register on, defaults to application scope
	 * @key The key to use in the scope, defaults to cachebox

	 */
	function scopeRegistration(
		boolean enabled=variables.DEFAULTS.scopeRegistration.enabled,
		string scope=variables.DEFAULTS.scopeRegistration.scope,
		string key=variables.DEFAULTS.scopeRegistration.key
	){
		variables.scopeRegistration.enabled 	= arguments.enabled;
		variables.scopeRegistration.key 		= arguments.key;
		variables.scopeRegistration.scope 		= arguments.scope;

		return this;
	}

	/**
	 * Setup the default cache
	 *
	 * @objectDefaultTimeout The default object timeout in minutes
	 * @objectDefaultLastAccessTimeout The last access or idle timeout in minutes
	 * @reapFrequency The reaping frequency in minutes
	 * @maxObjects The max objects to store
	 * @freeMemoryPercentageThreshold Activate free ram thresholds
	 * @useLastAccessTimeouts use idle timeouts
	 * @evictionPolicy The eviction policy to use
	 * @evictCount How many objects to evict
	 * @objectStore The storage provider
	 * @coldboxEnabled Is this ColdBox enabled or standalone
	 */
	CacheBoxConfig function defaultCache(
		numeric objectDefaultTimeout,
	    numeric objectDefaultLastAccessTimeout,
	    numeric reapFrequency,
	    numeric maxObjects,
	    numeric freeMemoryPercentageThreshold,
	    boolean useLastAccessTimeouts,
	    string evictionPolicy,
	    numeric evictCount,
	    string objectStore,
	    boolean coldboxEnabled
	){
		// Append all incoming arguments to configuration, just in case using non-default arguments, maybe for stores
		var cacheConfig = getDefaultCache();
		structAppend( cacheConfig, arguments );

		// coldbox enabled context
		if( !isNull( arguments.coldboxEnabled ) AND arguments.coldboxEnabled ){
			cacheConfig.provider = variables.DEFAULTS.coldboxAppProvider;
		} else {
			cacheConfig.provider = variables.DEFAULTS.cacheboxProvider;
		}

		return this;
	}

	/**
	 * Add a new cache config
	 *
	 * @name The cache name
	 * @provider The cache provider class, defaults to: coldbox.system.cache.providers.CacheBoxProvider
	 * @properties The structure of properties for the cache
	 */
	function cache(
		required name,
		string provider=variables.DEFAULTS.cacheBoxProvider,
		struct properties={}
	){
		variables.caches[ arguments.name ] = {
			provider 	= arguments.provider,
			properties 	= arguments.properties
		};
		return this;
	}

	/**
	 * Get a specified cache definition
	 *
	 * @name The cache name
	 */
	struct function getCache( required name ){
		return variables.caches[ arguments.name ];
	}

	/**
	 * Check if a cache definition exists
	 *
	 * @name The cache name
	 */
	boolean function cacheExists( required name ){
		return variables.caches.keyExists( arguments.name );
	}

	/**
	 * Add a new listener configuration
	 *
	 * @class The class of the listener
	 * @properties The struct of properties for the listener
	 * @name The unique name of the listener
	 */
	CacheBoxConfig function listener( required class, struct properties={}, name="" ){
		// Name check?
		if( NOT len( arguments.name ) ){
			arguments.name = listLast( arguments.class, "." );
		}
		// add listener
		arrayAppend( variables.listeners, arguments );

		return this;
	}

}