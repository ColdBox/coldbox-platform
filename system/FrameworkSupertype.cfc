/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * Base class for all things Box
 *
 * @author Luis Majano <lmajano@ortussolutions.com>
 */
component
	serializable="false"
	accessors   ="true"
	delegates   ="Flow@coreDelegates,Env@coreDelegates,JsonUtil@coreDelegates,Population@cbDelegates,Rendering@cbDelegates"
{

	// DI
	property name="controller";

	// Removed Deprecated Methods
	function renderview() cbMethod{
		throw(
			type    = "DeprecatedMethod",
			message = "This method has been deprecated, please use 'view()` instead"
		);
	}
	function renderLayout() cbMethod{
		throw(
			type    = "DeprecatedMethod",
			message = "This method has been deprecated, please use 'layout()` instead"
		);
	}
	function renderExternalView() cbMethod{
		throw(
			type    = "DeprecatedMethod",
			message = "This method has been deprecated, please use 'externalView()` instead"
		);
	}
	function announceInterception() cbMethod{
		throw(
			type    = "DeprecatedMethod",
			message = "This method has been deprecated, please use 'announce()` instead"
		);
	}

	/**
	 * Locates, Creates, Injects and Configures an object model instance
	 *
	 * @name          The mapping name or CFC instance path to try to build up
	 * @initArguments The constructor structure of arguments to passthrough when initializing the instance
	 * @dsl           The dsl string to use to retrieve the instance model object, mutually exclusive with 'name
	 * @targetObject  The object requesting the dependency, usually only used by DSL lookups
	 * @injector      The child injector to use when retrieving the instance
	 *
	 * @return The requested instance
	 *
	 * @throws InstanceNotFoundException - When the requested instance cannot be found
	 * @throws InvalidChildInjector      - When you request an instance from an invalid child injector name
	 **/
	function getInstance(
		name,
		struct initArguments = {},
		dsl,
		targetObject = "",
		injector
	) cbMethod{
		return variables.controller.getWirebox().getInstance( argumentCollection = arguments );
	}

	/**
	 * Retrieve the request context object
	 *
	 * @return coldbox.system.web.context.RequestContext
	 */
	function getRequestContext() cbMethod{
		return variables.controller.getRequestService().getContext();
	}

	/**
	 * Get the RC or PRC collection reference
	 *
	 * @private The boolean bit that says give me the RC by default or true for the private collection (PRC)
	 *
	 * @return The requeted collection
	 */
	struct function getRequestCollection( boolean private = false ) cbMethod{
		return getRequestContext().getCollection( private = arguments.private );
	}

	/**
	 * Get an interceptor reference
	 *
	 * @interceptorName The name of the interceptor to retrieve
	 *
	 * @return Interceptor
	 */
	function getInterceptor( required interceptorName ) cbMethod{
		return variables.controller.getInterceptorService().getInterceptor( argumentCollection = arguments );
	}

	/**
	 * Register a closure listener as an interceptor on a specific point
	 *
	 * @target The closure/lambda to register
	 * @point  The interception point to register the listener to
	 *
	 * @return FrameworkSuperType
	 */
	function listen( required target, required point ) cbMethod{
		variables.controller.getInterceptorService().listen( argumentCollection = arguments );
		return this;
	}

	/**
	 * Announce an interception
	 *
	 * @state            The interception state to announce
	 * @data             A data structure used to pass intercepted information.
	 * @async            If true, the entire interception chain will be ran in a separate thread.
	 * @asyncAll         If true, each interceptor in the interception chain will be ran in a separate thread and then joined together at the end.
	 * @asyncAllJoin     If true, each interceptor in the interception chain will be ran in a separate thread and joined together at the end by default.  If you set this flag to false then there will be no joining and waiting for the threads to finalize.
	 * @asyncPriority    The thread priority to be used. Either LOW, NORMAL or HIGH. The default value is NORMAL
	 * @asyncJoinTimeout The timeout in milliseconds for the join thread to wait for interceptor threads to finish.  By default there is no timeout.
	 *
	 * @return struct of thread information or void
	 */
	any function announce(
		required state,
		struct data              = {},
		boolean async            = false,
		boolean asyncAll         = false,
		boolean asyncAllJoin     = true,
		asyncPriority            = "NORMAL",
		numeric asyncJoinTimeout = 0
	) cbMethod{
		// Backwards Compat: Remove by ColdBox 7
		if ( !isNull( arguments.interceptData ) ) {
			arguments.data = arguments.interceptData;
		}
		return variables.controller.getInterceptorService().announce( argumentCollection = arguments );
	}

	/**
	 * Get a named CacheBox Cache
	 *
	 * @name The name of the cache to retrieve, if not passed, it used the 'default' cache.
	 *
	 * @return coldbox.system.cache.providers.IColdBoxProvider
	 */
	function getCache( name = "default" ) cbMethod{
		return variables.controller.getCache( arguments.name );
	}

	/**
	 * Get a setting from the system
	 *
	 * @name         The key of the setting
	 * @defaultValue If not found in config, default return value
	 *
	 * @return The requested setting
	 *
	 * @throws SettingNotFoundException
	 */
	function getSetting( required name, defaultValue ) cbMethod{
		return variables.controller.getSetting( argumentCollection = arguments );
	}

	/**
	 * Get a ColdBox setting
	 *
	 * @name         The key to get
	 * @defaultValue The default value if it doesn't exist
	 *
	 * @return The framework setting value
	 *
	 * @throws SettingNotFoundException
	 */
	function getColdBoxSetting( required name, defaultValue ) cbMethod{
		return variables.controller.getColdBoxSetting( argumentCollection = arguments );
	}

	/**
	 * Check if the setting exists in the application
	 *
	 * @name The key of the setting
	 */
	boolean function settingExists( required name ) cbMethod{
		return variables.controller.settingExists( argumentCollection = arguments );
	}

	/**
	 * Set a new setting in the system
	 *
	 * @name  The key of the setting
	 * @value The value of the setting
	 *
	 * @return FrameworkSuperType
	 */
	any function setSetting( required name, required value ) cbMethod{
		controller.setSetting( argumentCollection = arguments );
		return this;
	}

	/**
	 * Get a module's settings structure or a specific setting if the setting key is passed
	 *
	 * @module       The module to retrieve the configuration settings from
	 * @setting      The setting to retrieve if passed
	 * @defaultValue The default value to return if setting does not exist
	 *
	 * @return struct or any
	 */
	any function getModuleSettings( required module, setting, defaultValue ) cbMethod{
		var moduleSettings = getModuleConfig( arguments.module ).settings;
		// return specific setting?
		if ( !isNull( arguments.setting ) ) {
			return (
				structKeyExists( moduleSettings, arguments.setting ) ? moduleSettings[ arguments.setting ] : arguments.defaultValue
			);
		}
		return moduleSettings;
	}

	/**
	 * Get a module's configuration structure
	 *
	 * @module The module to retrieve the configuration structure from
	 *
	 * @return The struct requested
	 *
	 * @throws InvalidModuleException - The module passed is invalid
	 */
	struct function getModuleConfig( required module ) cbMethod{
		var mConfig = variables.controller.getSetting( "modules" );
		if ( structKeyExists( mConfig, arguments.module ) ) {
			return mConfig[ arguments.module ];
		}
		throw(
			message = "The module you passed #arguments.module# is invalid.",
			detail  = "The loaded modules are #structKeyList( mConfig )#",
			type    = "InvalidModuleException"
		);
	}

	/**
	 * Relocate user browser requests to other events, URLs, or URIs.
	 *
	 * @event             The name of the event to run, if not passed, then it will use the default event found in your configuration file
	 * @URL               The full URL you would like to relocate to instead of an event: ex: URL='http://www.google.com'
	 * @URI               The relative URI you would like to relocate to instead of an event: ex: URI='/mypath/awesome/here'
	 * @queryString       The query string or struct to append, if needed. If in SES mode it will be translated to convention name value pairs
	 * @persist           What request collection keys to persist in flash ram
	 * @persistStruct     A structure key-value pairs to persist in flash ram
	 * @addToken          Wether to add the tokens or not. Default is false
	 * @ssl               Whether to relocate in SSL or not
	 * @baseURL           Use this baseURL instead of the index.cfm that is used by default. You can use this for ssl or any full base url you would like to use. Ex: https://mysite.com/index.cfm
	 * @postProcessExempt Do not fire the postProcess interceptors
	 * @statusCode        The status code to use in the relocation
	 */
	void function relocate(
		event,
		URL,
		URI,
		queryString,
		persist,
		struct persistStruct,
		boolean addToken,
		boolean ssl,
		baseURL,
		boolean postProcessExempt,
		numeric statusCode
	) cbMethod{
		variables.controller.relocate( argumentCollection = arguments );
	}

	/**
	 * Redirect back to the previous URL via the referrer header, else use the fallback
	 *
	 * @fallback The fallback event or uri if the referrer is empty, defaults to `/`
	 */
	function back( fallback = "/" ) cbMethod{
		var event = getRequestContext();
		relocate( URL = event.getHTTPHeader( "referer", event.buildLink( arguments.fallback ) ) );
	}

	/**
	 * Executes internal named routes with or without parameters. If the named route is not found or the route has no event to execute then this method will throw an `InvalidArgumentException`.
	 * If you need a route from a module then append the module address: `@moduleName` or prefix it like in run event calls `moduleName:routeName` in order to find the right route.
	 * The route params will be passed to events as action arguments much how eventArguments work.
	 *
	 * @name                   The name of the route
	 * @params                 The parameters of the route to replace
	 * @cache                  Cached the output of the runnable execution, defaults to false. A unique key will be created according to event string + arguments.
	 * @cacheTimeout           The time in minutes to cache the results
	 * @cacheLastAccessTimeout The time in minutes the results will be removed from cache if idle or requested
	 * @cacheSuffix            The suffix to add into the cache entry for this event rendering
	 * @cacheProvider          The provider to cache this event rendering in, defaults to 'template'
	 * @prePostExempt          If true, pre/post handlers will not be fired. Defaults to false
	 *
	 * @return null or anything produced from the route
	 *
	 * @throws InvalidArgumentException
	 */
	any function runRoute(
		required name,
		struct params          = {},
		boolean cache          = false,
		cacheTimeout           = "",
		cacheLastAccessTimeout = "",
		cacheSuffix            = "",
		cacheProvider          = "template",
		boolean prePostExempt  = false
	) cbMethod{
		return variables.controller.runRoute( argumentCollection = arguments );
	}

	/**
	 * Executes events with full life-cycle methods and returns the event results if any were returned.
	 *
	 * @event                  The event string to execute, if nothing is passed we will execute the application's default event.
	 * @prePostExempt          If true, pre/post handlers will not be fired. Defaults to false
	 * @private                Execute a private event if set, else defaults to public events
	 * @defaultEvent           The flag that let's this service now if it is the default event running or not. USED BY THE FRAMEWORK ONLY
	 * @eventArguments         A collection of arguments to passthrough to the calling event handler method
	 * @cache                  Cached the output of the runnable execution, defaults to false. A unique key will be created according to event string + arguments.
	 * @cacheTimeout           The time in minutes to cache the results
	 * @cacheLastAccessTimeout The time in minutes the results will be removed from cache if idle or requested
	 * @cacheSuffix            The suffix to add into the cache entry for this event rendering
	 * @cacheProvider          The provider to cache this event rendering in, defaults to 'template'
	 *
	 * @return null or anything produced from the event
	 */
	function runEvent(
		event                  = "",
		boolean prePostExempt  = false,
		boolean private        = false,
		boolean defaultEvent   = false,
		struct eventArguments  = {},
		boolean cache          = false,
		cacheTimeout           = "",
		cacheLastAccessTimeout = "",
		cacheSuffix            = "",
		cacheProvider          = "template"
	) cbMethod{
		return variables.controller.runEvent( argumentCollection = arguments );
	}

	/**
	 * Persist variables into the Flash RAM
	 *
	 * @persist       A list of request collection keys to persist
	 * @persistStruct A struct of key-value pairs to persist
	 *
	 * @return FrameworkSuperType
	 */
	function persistVariables( persist = "", struct persistStruct = {} ) cbMethod{
		variables.controller.persistVariables( argumentCollection = arguments );
		return this;
	}

	/****************************************** UTILITY METHODS ******************************************/

	/**
	 * Resolve a file to be either relative or absolute in your application
	 *
	 * @pathToCheck The file path to check
	 */
	string function locateFilePath( required pathToCheck ) cbMethod{
		return variables.controller.locateFilePath( argumentCollection = arguments );
	}

	/**
	 * Resolve a directory to be either relative or absolute in your application
	 *
	 * @pathToCheck The file path to check
	 */
	string function locateDirectoryPath( required pathToCheck ) cbMethod{
		return variables.controller.locateDirectoryPath( argumentCollection = arguments );
	}

	/**
	 * Add a js/css asset(s) to the html head section. You can also pass in a list of assets. This method
	 * keeps track of the loaded assets so they are only loaded once
	 *
	 * @asset The asset(s) to load, only js or css files. This can also be a comma delimited list.
	 */
	string function addAsset( required asset ) cbMethod{
		return getInstance( "@HTMLHelper" ).addAsset( argumentCollection = arguments );
	}

	/**
	 * Injects a UDF Library (*.cfc or *.cfm) into the target object.  It does not however, put the mixins on any of the cfc scopes. Therefore they can only be called internally
	 *
	 * @udflibrary The UDF library to inject
	 *
	 * @return FrameworkSuperType
	 *
	 * @throws UDFLibraryNotFoundException - When the requested library cannot be found
	 */
	any function includeUDF( required udflibrary ) cbMethod{
		// Init the mixin location and caches reference
		var defaultCache     = getCache( "default" );
		var mixinLocationKey = hash( variables.controller.getAppHash() & arguments.udfLibrary );

		var targetLocation = defaultCache.getOrSet(
			// Key
			"includeUDFLocation-#mixinLocationKey#",
			// Producer
			function(){
				var appMapping      = variables.controller.getSetting( "AppMapping" );
				var UDFFullPath     = expandPath( udflibrary );
				var UDFRelativePath = expandPath( "/" & appMapping & "/" & udflibrary );

				// Relative Checks First
				if ( fileExists( UDFRelativePath ) ) {
					targetLocation = "/" & appMapping & "/" & udflibrary;
				}
				// checks if no .cfc or .cfm where sent
				else if ( fileExists( UDFRelativePath & ".cfc" ) ) {
					targetLocation = "/" & appMapping & "/" & udflibrary & ".cfc";
				} else if ( fileExists( UDFRelativePath & ".cfm" ) ) {
					targetLocation = "/" & appMapping & "/" & udflibrary & ".cfm";
				} else if ( fileExists( UDFFullPath ) ) {
					targetLocation = "#udflibrary#";
				} else if ( fileExists( UDFFullPath & ".cfc" ) ) {
					targetLocation = "#udflibrary#.cfc";
				} else if ( fileExists( UDFFullPath & ".cfm" ) ) {
					targetLocation = "#udflibrary#.cfm";
				} else {
					throw(
						message = "Error loading UDF library: #udflibrary#",
						detail  = "The UDF library was not found.  Please make sure you verify the file location.",
						type    = "UDFLibraryNotFoundException"
					);
				}
				return targetLocation;
			},
			// Timeout: 1 week
			10080
		);

		// Include the UDF
		include targetLocation;

		return this;
	}

	/**
	 * Load the global application helper libraries defined in the applicationHelper Setting of your application.
	 * This is called by the framework ONLY! Use at your own risk
	 *
	 * @force Used when called by a known virtual inheritance family tree.
	 *
	 * @return FrameworkSuperType
	 */
	any function loadApplicationHelpers( boolean force = false ) cbMethod{
		if ( structKeyExists( this, "$super" ) && !arguments.force ) {
			return this;
		}

		// Inject global helpers
		var helpers = variables.controller.getSetting( "applicationHelper" );

		for ( var thisHelper in helpers ) {
			includeUDF( thisHelper );
		}

		return this;
	}

	/**
	 * Return the ColdBox Async Manager instance so you can do some async or parallel programming
	 *
	 * @return coldbox.system.async.AsyncManager
	 */
	any function async() cbMethod{
		if ( isNull( variables.asyncManager ) ) {
			variables.asyncManager = variables.controller.getWireBox().getInstance( "asyncManager@coldbox" );
		}
		return variables.asyncManager;
	}

}
