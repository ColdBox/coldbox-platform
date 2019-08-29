/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ----
 * @author Luis Majano
 *
 * The main CacheBox factory and configuration of caches. From this factory
 * is where you will get all the caches you need to work with or register more caches.
 **/
component accessors=true serializable=false {

    /**
     * The unique factory id
     */
    property name="factoryId";
    /**
     * The factory version
     */
    property name="version";
    /**
     * The CacheBox Configuration object linkage
     */
    property name="config";
    /**
     * The ColdBox object linkage
     */
    property name="coldbox";
    /**
     * The LogBox object linkage
     */
    property name="logbox";
    /**
     * A configured log class
     */
    property name="log";
    /**
     * The Event Manager object linkage
     */
    property name="eventManager";
    /**
     * The array of events this factory registers
     */
    property name="eventStates" type="array";
    /**
     * The registered caches this factory keeps track of
     */
    property name="caches" type="struct";

    /**
     * Constructor
     *
     * @config The CacheBoxConfig object or path to use to configure this instance of CacheBox. If not passed then CacheBox will instantiate the default configuration.
     * @config.doc_generic coldbox.system.cache.config.CacheBoxConfig
     * @coldbox A coldbox application that this instance of CacheBox can be linked to, if not using it, just ignore it.
     * @coldbox.doc_generic coldbox.system.web.Controller
     * @factoryID A unique ID or name for this factory. If not passed I will make one up for you.
     */
    function init( config, coldbox, factoryId = "" ){
        var defaultConfigPath = "coldbox.system.cache.config.DefaultConfiguration";

        // CacheBox Factory UniqueID
        variables.factoryId = createObject( "java", "java.lang.System" ).identityHashCode( this );
        // Version
        variables.version = "@build.version@+@build.number@";
        // Configuration object
        variables.config = "";
        // ColdBox Application Link
        variables.coldbox = "";
        // Event Manager Link
        variables.eventManager = "";
        // Configured Event States
        variables.eventStates = [
            "afterCacheElementInsert",
            "afterCacheElementRemoved",
            "afterCacheElementExpired",
            "afterCacheElementUpdated",
            "afterCacheClearAll",
            "afterCacheRegistration",
            "afterCacheRemoval",
            "beforeCacheRemoval",
            "beforeCacheReplacement",
            "afterCacheFactoryConfiguration",
            "beforeCacheFactoryShutdown",
            "afterCacheFactoryShutdown",
            "beforeCacheShutdown",
            "afterCacheShutdown"
        ];
        // LogBox Links
        variables.logBox = "";
        variables.log = "";
        // Caches
        variables.caches = {};

        // Did we send a factoryID in?
        if( len( arguments.factoryID ) ){
            variables.factoryID = arguments.factoryID;
        }

        // Prepare Lock Info
        variables.lockName = "CacheFactory.#variables.factoryID#";

        // Passed in configuration?
        if( isNull( arguments.config ) ){
            // Create default configuration
            arguments.config = new coldbox.system.cache.config.CacheBoxConfig( CFCConfigPath = defaultConfigPath );
        }else if( isSimpleValue( arguments.config ) ){
            arguments.config = new coldbox.system.cache.config.CacheBoxConfig( CFCConfigPath = arguments.config );
        }

        // Check if linking ColdBox
        if( !isNull( arguments.coldbox ) ){
            // Link ColdBox
            variables.coldbox = arguments.coldbox;
            // link LogBox
            variables.logBox = variables.coldbox.getLogBox();
            // Link Event Manager
            variables.eventManager = variables.coldbox.getInterceptorService();
            // Link Interception States
            variables.coldbox
                .getInterceptorService()
                .appendInterceptionPoints( variables.eventStates );
        }else{
            // Running standalone, so create our own logging first
            configureLogBox( arguments.config.getLogBoxConfig() );
            // Running standalone, so create our own event manager
            configureEventManager();
        }

        // Configure Logging for the Cache Factory
        variables.log = variables.logBox.getLogger( this );

        // Configure the Cache Factory
        configure( arguments.config );

        return this;
    }

    /**
     * Register all the configured listeners in the configuration file
     *
     * @throws CacheBox.ListenerCreationException
     */
    CacheFactory function registerListeners(){
        variables.config
            .getListeners()
            .each( function(item){
                // try to create it
                try{
                    // create it
                    var thisListener = createObject( "component", item.class );
                    // configure it
                    thisListener.configure( this, item.properties );
                }catch( Any e ){
                    throw(
                        message = "Error creating listener: #item.toString()#",
                        detail = "#e.message# #e.detail# #e.stackTrace#",
                        type = "CacheBox.ListenerCreationException"
                    );
                }
                // Now register listener with the event manager
                variables.eventManager.register( thisListener, item.name );
            } );

        return this;
    }

    /**
     * Configure the cache factory for operation, called by the init(). You can also re-configure CacheBox programmatically.
     *
     * @config The CacheBox config object
     * @config.doc_generic coldbox.system.cache.config.CacheBoxConfig
     */
    function configure( required config ){
        lock name="#variables.lockName#" type="exclusive" timeout="30" throwontimeout="true" {
            // Store config object
            variables.config = arguments.config;
            // Validate configuration
            variables.config.validate();
            // Reset Registries
            variables.caches = {};

            // Register Listeners if not using ColdBox
            if( not isObject( variables.coldbox ) ){
                registerListeners();
            }

            // Register default cache first
            var defaultCacheConfig = variables.config.getDefaultCache();
            createCache( name = "default", provider = defaultCacheConfig.provider, properties = defaultCacheConfig );

            // Register named caches
            variables.config
                .getCaches()
                .each( function(key, def){
                    createCache( name = key, provider = def.provider, properties = def.properties );
                } );

            // Scope registrations
            if( variables.config.getScopeRegistration().enabled ){
                doScopeRegistration();
            }

            // Announce To Listeners
            variables.eventManager.processState(
                "afterCacheFactoryConfiguration",
                { cacheFactory: this }
            );
        }
    }

    /********************************* PUBLIC CACHE FACTORY OPERATIONS *********************************/

    /**
     * Get a reference to a registered cache in this factory.  If the cache does not exist it will return an exception. Type: coldbox.system.cache.providers.ICacheProvider
     *
     * @name The cache name to get
     *
     * @throws CacheFactory.CacheNotFoundException
     * @return coldbox.system.cache.providers.ICacheProvider
     */
    function getCache( required name ){
        lock name="#variables.lockName#" type="readonly" timeout="20" throwontimeout="true" {
            if( variables.caches.keyExists( arguments.name ) ){
                return variables.caches[ arguments.name ];
            }
            throw(
                message = "Cache #arguments.name# is not registered.",
                detail = "Valid cache names are #structKeyList( variables.caches )#",
                type = "CacheFactory.CacheNotFoundException"
            );
        }
    }

    /**
     * Register a new instantiated cache with this cache factory
     *
     * @cache The cache to register
     * @cache.doc_generic coldbox.system.cache.providers.ICacheProvider
     */
    CacheFactory function addCache( required cache ){
        registerCache( arguments.cache );
        return this;
    }

    /**
     * Add a default named cache to our registry, create it, config it, register it and return it of type: coldbox.system.cache.providers.ICacheProvider
     *
     * @name The name of the default cache to create
     *
     * @throw CacheFactory.InvalidNameException,CacheFactory.CacheExistsException
     * @return coldbox.system.cache.providers.ICacheProvider
     */
    function addDefaultCache( required name ){
        var defaultCacheConfig = variables.config.getDefaultCache();

        // Check length
        if( len( arguments.name ) eq 0 ){
            throw(
                message = "Invalid Cache Name",
                detail = "The name you sent in is invalid as it was blank, please send in a name",
                type = "CacheFactory.InvalidNameException"
            );
        }

        // Check it does not exist already
        if( cacheExists( arguments.name ) ){
            throw(
                message = "Cache #arguments.name# already exists",
                detail = "Cannot register named cache as it already exists in the registry",
                type = "CacheFactory.CacheExistsException"
            );
        }

        // Create default cache instance
        return createCache(
            name = arguments.name,
            provider = defaultCacheConfig.provider,
            properties = defaultCacheConfig
        );
    }

    /**
     * Recursively sends shutdown commands to al registered caches and cleans up in preparation for shutdown
     */
    CacheFactory function shutdown(){
        // Log startup
        if( variables.log.canDebug() ){
            variables.log.debug( "Shutdown of cache factory: #getFactoryID()# requested and started." );
        }

        // Notify Listeners
        variables.eventManager.processState( "beforeCacheFactoryShutdown", { cacheFactory: this } );

        // safely iterate and shutdown caches
        getCacheNames().each( function(item){
            // Get cache to shutdown
            var cache = getCache( item );

            // Log it
            if( variables.log.canDebug() ){
                variables.log.debug( "Shutting down cache: #item# on factoryID: #getFactoryID()#." );
            }

            // process listners
            variables.eventManager.processState( "beforeCacheShutdown", { cache: cache } );

            // Shutdown each cache
            cache.shutdown();

            // process listeners
            variables.eventManager.processState( "afterCacheShutdown", { cache: cache } );

            // log
            if( variables.log.canDebug() ){
                variables.log.debug( "Cache: #item# was shut down on factoryID: #getFactoryID()#." );
            }
        } );

        // Remove all caches
        removeAll();

        // remove scope registration
        removeFromScope();

        // Notify Listeners
        variables.eventManager.processState( "afterCacheFactoryShutdown", { cacheFactory: this } );

        // Log shutdown complete
        if( variables.log.canDebug() ){
            variables.log.debug( "Shutdown of cache factory: #getFactoryID()# completed." );
        }

        return this;
    }

    /**
     * Send a shutdown command to a specific cache provider to bring down gracefully. It also removes it from the cache factory
     *
     * @name The name of the cache to shutdown
     */
    CacheFactory function shutdownCache( required name ){
        var iData = {};
        var cache = "";
        var i = 1;

        // Check if cache exists, else exit out
        if( NOT cacheExists( arguments.name ) ){
            if( variables.log.canWarn() ){
                variables.log.warn(
                    "Trying to shutdown #arguments.name#, but that cache does not exist, skipping."
                );
            }
            return this;
        }

        // get Cache
        var cache = getCache( arguments.name );

        // log it
        if( variables.log.canDebug() ){
            variables.log.debug(
                "Shutdown of cache: #arguments.name# requested and started on factoryID: #getFactoryID()#"
            );
        }

        // Notify Listeners
        variables.eventManager.processState( "beforeCacheShutdown", { cache: cache } );

        // Shutdown the cache
        cache.shutdown();

        // process listeners
        variables.eventManager.processState( "afterCacheShutdown", { cache: cache } );

        // remove cache
        removeCache( arguments.name );

        // Log it
        if( variables.log.canDebug() ){
            variables.log.debug(
                "Cache: #arguments.name# was shut down and removed on factoryID: #getFactoryID()#."
            );
        }

        return this;
    }

    /**
     * Remove the cache factory from scope registration if enabled, else does nothing
     */
    CacheFactory function removeFromScope(){
        var scopeInfo = variables.config.getScopeRegistration();
        if( scopeInfo.enabled ){
            new coldbox.system.core.collections.ScopeStorage().delete( scopeInfo.key, scopeInfo.scope );
        }
        return this;
    }

    /**
     * Try to remove a named cache from this factory, returns Boolean if successfull or not
     *
     * @name The name of the cache to remove
     */
    boolean function removeCache( required name ){
        if( cacheExists( arguments.name ) ){
            lock name="#variables.lockName#" type="exclusive" timeout="20" throwontimeout="true" {
                if( cacheExists( arguments.name ) ){
                    // Log
                    if( variables.log.canDebug() ){
                        variables.log.debug(
                            "Cache: #arguments.name# asked to be removed from factory: #getFactoryID()#"
                        );
                    }

                    // Retrieve it
                    var cache = variables.caches[ arguments.name ];

                    // Notify listeners here
                    variables.eventManager.processState( "beforeCacheRemoval", { cache: cache } );

                    // process shutdown
                    cache.shutdown();

                    // Remove it
                    structDelete( variables.caches, arguments.name );

                    // Announce it
                    variables.eventManager.processState( "afterCacheRemoval", { cache: arguments.name } );

                    // Log it
                    if( variables.log.canDebug() ){
                        variables.log.debug( "Cache: #arguments.name# removed from factory: #getFactoryID()#" );
                    }

                    return true;
                }
            }
        }

        if( variables.log.canDebug() ){
            variables.log.debug(
                "Cache: #arguments.name# not removed because it does not exist in registered caches: #arrayToList( getCacheNames() )#. FactoryID: #getFactoryID()#"
            );
        }

        return false;
    }

    /**
     * Remove all the registered caches in this factory, this triggers individual cache shutdowns
     */
    CacheFactory function removeAll(){
        if( variables.log.canDebug() ){
            variables.log.debug( "Removal of all caches requested on factoryID: #getFactoryID()#" );
        }

        getCacheNames().each( function(item){
            removeCache( item );
        } );


        if( variables.log.canDebug() ){
            variables.log.debug( "All caches removed." );
        }

        return this;
    }

    /**
     * A nice way to call reap on all registered caches
     */
    CacheFactory function reapAll(){
        if( variables.log.canDebug() ){
            variables.log.debug( "Executing reap on factoryID: #getFactoryID()#" );
        }

        getCacheNames().each( function(item){
            getCache( item ).reap();
        } );

        return this;
    }

    /**
     * Check if the passed in named cache is already registered in this factory or not
     */
    boolean function cacheExists( required name ){
        lock name="#variables.lockName#" type="readonly" timeout="20" throwontimeout="true" {
            return structKeyExists( variables.caches, arguments.name );
        }
    }

    /**
     * Replace a registered named cache with a new decorated cache of the same name.
     *
     * @cache The name of the cache to replace or the actual instance of the cache to replace
     * @cache.doc_generic coldbox.system.cache.providers.ICacheProvider or string
     * @decoratedCache The decorated cache manager instance to replace with of type coldbox.system.cache.providers.ICacheProvider
     * @decoratedCache.doc_generic coldbox.system.cache.providers.ICacheProvider
     */
    CacheFactory function replaceCache( required cache, required decoratedCache ){
        // determine cache name
        if( isObject( arguments.cache ) ){
            var name = arguments.cache.getName();
        }else{
            var name = arguments.cache;
        }

        lock name="#variables.lockName#" type="exclusive" timeout="20" throwontimeout="true" {
            // Announce to listeners
            var iData = { oldCache: variables.caches[ name ], newCache: arguments.decoratedCache };

            variables.eventManager.processState( "beforeCacheReplacement", iData );

            // remove old Cache
            structDelete( variables.caches, name );

            // Replace it
            variables.caches[ name ] = arguments.decoratedCache;

            // debugging
            if( variables.log.canDebug() ){
                variables.log.debug(
                    "Cache #name# replaced with decorated cache: #getMetadata( arguments.decoratedCache ).name# on factoryID: #getFactoryID()#"
                );
            }
        }

        return this;
    }

    /**
     * Clears all the elements in all the registered caches without de-registrations
     */
    CacheFactory function clearAll(){
        if( variables.log.canDebug() ){
            variables.log.debug( "Clearing all registered caches of their content on factoryID: #getFactoryID()#" );
        }

        getCacheNames().each( function(item){
            getCache( item ).clearAll();
        } );

        return this;
    }

    /**
     * Expires all the elements in all the registered caches without de-registrations
     */
    CacheFactory function expireAll(){
        if( variables.log.canDebug() ){
            variables.log.debug( "Expiring all registered caches of their content on factoryID: #getFactoryID()#" );
        }

        getCacheNames().each( function(item){
            getCache( item ).expireAll();
        } );

        return this;
    }

    /**
     * Get the array of caches registered with this factory
     */
    array function getCacheNames(){
        lock name="#variables.lockName#" type="readonly" timeout="20" throwontimeout="true" {
            return structKeyArray( variables.caches );
        }
    }

    /**
     * Checks if Coldbox application controller is linked
     */
    boolean function isColdBoxLinked(){
        return isObject( variables.coldbox );
    }

    /**
     * Get the default cache provider of type coldbox.system.cache.providers.ICacheProvider"
     *
     * @return coldbox.system.cache.providers.ICacheProvider
     */
    function getDefaultCache(){
        return getCache( "default" );
    }

    /**
     * Get the scope registration information
     */
    struct function getScopeRegistration(){
        return variables.config.getScopeRegistration();
    }

    /**
     * Create a new cache according the the arguments, register it and return it of type: coldbox.system.cache.providers.ICacheProvider
     *
     * @name The name of the cache to create
     * @provider The provider class path of the cache to add
     * @properties The configuration properties of the cache
     *
     * @return coldbox.system.cache.providers.ICacheProvider
     */
    function createCache( required name, required provider, struct properties = {} ){
        // Create Cache
        var oCache = createObject( "component", arguments.provider ).init();
        // Register Name
        oCache.setName( arguments.name );
        // Link Properties
        oCache.setConfiguration( arguments.properties );
        // Register Cache
        registerCache( oCache );

        return oCache;
    }

    /*************************** PRIVATE METHODS ******************************/

    /**
     * Register this cachefactory on a user specified scope
     */
    private CacheFactory function doScopeRegistration(){
        var scopeInfo = variables.config.getScopeRegistration();
        new coldbox.system.core.collections.ScopeStorage().put( scopeInfo.key, this, scopeInfo.scope );
        return this;
    }

    /**
     * Register a new cache on this cache factory
     *
     * @cache The cache instance to register with this factory of type: coldbox.system.cache.providers.ICacheProvider
     * @cache.doc_generic coldbox.system.cache.providers.ICacheProvider
     *
     * @throws CacheFactory.CacheExistsException
     */
    private CacheFactory function registerCache( required cache ){
        var name = arguments.cache.getName();
        var oCache = arguments.cache;

        if( variables.caches.keyExists( name ) ){
            throw( message = "Cache #name# already exists!", type = "CacheFactory.CacheExistsException" );
        }

        // Verify Registration
        if( !variables.caches.keyExists( name ) ){
            lock name="#variables.lockName#" type="exclusive" timeout="20" throwontimeout="true" {
                if( !variables.caches.keyExists( name ) ){
                    // Link to this CacheFactory
                    oCache.setCacheFactory( this );
                    // Link ColdBox if using it
                    if( isObject( variables.coldbox ) AND structKeyExists( oCache, "setColdBox" ) ){
                        oCache.setColdBox( variables.coldbox );
                    }
                    // Link Event Manager
                    oCache.setEventManager( variables.eventManager );
                    // Call Configure it to start the cache up
                    oCache.configure();
                    // Store it
                    variables.caches[ name ] = oCache;
                    // Announce new cache registration now
                    variables.eventManager.processState( "afterCacheRegistration", { cache: oCache } );
                }
            }
        }

        return this;
    }

    /**
     * Configure a standalone version of logBox for logging
     *
     * @configPath The LogBox configuration CFC path
     */
    private CacheFactory function configureLogBox( required configPath ){
        // Create config object
        var oConfig = new coldbox.system.logging.config.LogBoxConfig( CFCConfigPath = arguments.configPath );
        // Create LogBox standalone and store it
        variables.logBox = new coldbox.system.logging.LogBox( oConfig );
        return this;
    }

    /**
     * Configure a standalone version of a ColdBox Event Manager
     */
    private CacheFactory function configureEventManager(){
        // create event manager
        variables.eventManager = new coldbox.system.core.events.EventPoolManager( variables.eventStates );
        // register the points to listen to
        variables.eventManager.appendInterceptionPoints( variables.eventStates );
        return this;
    }

    /**
     * Get a new utility object
     */
    function getUtil(){
        return new coldbox.system.core.util.Util();
    }

}
