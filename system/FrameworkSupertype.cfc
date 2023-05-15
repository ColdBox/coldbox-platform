/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * Base class for all things Box
 * The Majority of contributions comes from its delegations
 *
 * @author Luis Majano <lmajano@ortussolutions.com>
 */
component serializable="false" accessors="true" {

	/****************************************************************
	 * DI *
	 ****************************************************************/

	property name="controller" inject="coldbox";
	property name="cachebox"   inject="cachebox";
	property name="flash"      inject="coldbox:flash";
	property name="logBox"     inject="logbox";
	property name="log"        inject="logbox:logger:{this}";
	property name="wirebox"    inject="wirebox";
	property name="env"        inject="env@coreDelegates";
	property name="jsonUtil"   inject="JsonUtil@coreDelegates";
	property name="flow"       inject="Flow@coreDelegates";

	/**
	 * Constructor
	 */
	function init(){
		variables.cbInjectedHelpers = {};
		return this;
	}

	/****************************************************************
	 * Deprecated/Removed Methods *
	 ****************************************************************/

	function renderview() cbMethod{
		getRenderer().renderView( argumentCollection = arguments );
	}
	function renderLayout() cbMethod{
		getRenderer().renderLayout( argumentCollection = arguments );
	}
	function renderExternalView() cbMethod{
		getRenderer().renderExternalView( argumentCollection = arguments );
	}
	function announceInterception() cbMethod{
		variables.log.warn(
			"announceInterception() has been deprecated, please update your code to announce()",
			callStackGet()
		);
		variables.controller.getInterceptorService().announce( argumentCollection = arguments );
	}
	function populateModel() cbMethod{
		// TODO: Change to warn() by version 8 release
		variables.log.debug(
			"populateModel() has been deprecated, please update your code to populate()",
			callStackGet()
		);
		return populate( argumentCollection = arguments );
	}

	/****************************************************************
	 * WireBox + Population Methods *
	 ****************************************************************/

	/**
	 * Get The root wirebox instance
	 */
	function getRootWireBox() cbMethod{
		return variables.controller.getWireBox();
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
		return variables.wirebox.getInstance( argumentCollection = arguments );
	}

	/**
	 * Populate an object from the incoming request collection
	 *
	 * @model                The name of the model to get and populate or the acutal model object. If you already have an instance of a model, then use the populateBean() method
	 * @scope                Use scope injection instead of setters population. Ex: scope=variables.instance.
	 * @trustedSetter        If set to true, the setter method will be called even if it does not exist in the object
	 * @include              A list of keys to include in the population
	 * @exclude              A list of keys to exclude in the population
	 * @ignoreEmpty          Ignore empty values on populations, great for ORM population
	 * @nullEmptyInclude     A list of keys to NULL when empty
	 * @nullEmptyExclude     A list of keys to NOT NULL when empty
	 * @composeRelationships Automatically attempt to compose relationships from memento
	 * @memento              A structure to populate the model, if not passed it defaults to the request collection
	 * @jsonstring           If you pass a json string, we will populate your model with it
	 * @xml                  If you pass an xml string, we will populate your model with it
	 * @qry                  If you pass a query, we will populate your model with it
	 * @rowNumber            The row of the qry parameter to populate your model with
	 * @ignoreTargetLists    If this is true, then the populator will ignore the target's population include/exclude metadata lists. By default this is false.
	 *
	 * @return The instance populated
	 */
	function populate(
		required model,
		scope                        = "",
		boolean trustedSetter        = false,
		include                      = "",
		exclude                      = "",
		boolean ignoreEmpty          = false,
		nullEmptyInclude             = "",
		nullEmptyExclude             = "",
		boolean composeRelationships = false,
		struct memento               = getRequestCollection(),
		string jsonstring,
		string xml,
		query qry,
		boolean ignoreTargetLists = false
	) cbMethod{
		return variables.wirebox.getInstance( "Population@cbDelegates" ).populate( argumentCollection = arguments );
	}

	/****************************************************************
	 * Rendering Methods *
	 ****************************************************************/

	/**
	 * Retrieve the system web renderer
	 *
	 * @return coldbox.system.web.Renderer
	 */
	function getRenderer() cbMethod{
		return variables.controller.getRenderer();
	}

	/**
	 * Render out a view
	 *
	 * @view                   The the view to render, if not passed, then we look in the request context for the current set view.
	 * @args                   A struct of arguments to pass into the view for rendering, will be available as 'args' in the view.
	 * @module                 The module to render the view from explicitly
	 * @cache                  Cached the view output or not, defaults to false
	 * @cacheTimeout           The time in minutes to cache the view
	 * @cacheLastAccessTimeout The time in minutes the view will be removed from cache if idle or requested
	 * @cacheSuffix            The suffix to add into the cache entry for this view rendering
	 * @cacheProvider          The provider to cache this view in, defaults to 'template'
	 * @collection             A collection to use by this Renderer to render the view as many times as the items in the collection (Array or Query)
	 * @collectionAs           The name of the collection variable in the partial rendering.  If not passed, we will use the name of the view by convention
	 * @collectionStartRow     The start row to limit the collection rendering with
	 * @collectionMaxRows      The max rows to iterate over the collection rendering with
	 * @collectionDelim        A string to delimit the collection renderings by
	 * @prePostExempt          If true, pre/post view interceptors will not be fired. By default they do fire
	 * @name                   The name of the rendering region to render out, Usually all arguments are coming from the stored region but you override them using this function's arguments.
	 * @viewVariables          A struct of variables to incorporate into the view's variables scope.
	 *
	 * @return The rendered view
	 */
	function view(
		view                   = "",
		struct args            = {},
		module                 = "",
		boolean cache          = false,
		cacheTimeout           = "",
		cacheLastAccessTimeout = "",
		cacheSuffix            = "",
		cacheProvider          = "template",
		collection,
		collectionAs               = "",
		numeric collectionStartRow = "1",
		numeric collectionMaxRows  = 0,
		collectionDelim            = "",
		boolean prePostExempt      = false,
		name,
		viewVariables = {}
	) cbMethod{
		return variables.controller.getRenderer().view( argumentCollection = arguments );
	}

	/**
	 * Renders an external view anywhere that cfinclude works.
	 *
	 * @view                   The the view to render
	 * @args                   A struct of arguments to pass into the view for rendering, will be available as 'args' in the view.
	 * @cache                  Cached the view output or not, defaults to false
	 * @cacheTimeout           The time in minutes to cache the view
	 * @cacheLastAccessTimeout The time in minutes the view will be removed from cache if idle or requested
	 * @cacheSuffix            The suffix to add into the cache entry for this view rendering
	 * @cacheProvider          The provider to cache this view in, defaults to 'template'
	 * @viewVariables          A struct of variables to incorporate into the view's variables scope.
	 *
	 * @return The rendered view
	 */
	function externalView(
		required view,
		struct args            = {},
		boolean cache          = false,
		cacheTimeout           = "",
		cacheLastAccessTimeout = "",
		cacheSuffix            = "",
		cacheProvider          = "template",
		viewVariables          = {}
	) cbMethod{
		return variables.controller.getRenderer().externalView( argumentCollection = arguments );
	}

	/**
	 * Render a layout or a layout + view combo
	 *
	 * @layout        The layout to render out
	 * @module        The module to explicitly render this layout from
	 * @view          The view to render within this layout
	 * @args          An optional set of arguments that will be available to this layouts/view rendering ONLY
	 * @viewModule    The module to explicitly render the view from
	 * @prePostExempt If true, pre/post layout interceptors will not be fired. By default they do fire
	 * @viewVariables A struct of variables to incorporate into the view's variables scope.
	 *
	 * @return The rendered layout
	 */
	function layout(
		layout,
		module                = "",
		view                  = "",
		struct args           = {},
		viewModule            = "",
		boolean prePostExempt = false,
		viewVariables         = {}
	) cbMethod{
		return variables.controller.getRenderer().layout( argumentCollection = arguments );
	}

	/****************************************************************
	 * Interception Methods *
	 ****************************************************************/

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
		return variables.controller.getInterceptorService().announce( argumentCollection = arguments );
	}

	/****************************************************************
	 * Caching Methods *
	 ****************************************************************/

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

	/****************************************************************
	 * Setting Methods *
	 ****************************************************************/

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
		return variables.controller.getModuleSettings( argumentCollection = arguments );
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
		return variables.controller.getModuleConfig( argumentCollection = arguments );
	}

	/**
	 * This method will return the unique user's request tracking identifier according to our discovery algoritm:
	 *
	 * 1. If we have an identifierProvider closure/lambda/udf, then call it and use it
	 * 2. If we have session enabled, use the jessionId or session URL Token
	 * 3. If we have cookies enabled, use the cfid/cftoken
	 * 4. If we have in the URL the cfid/cftoken
	 * 5. Create a request based tracking identifier: cbUserTrackingId
	 */
	function getUserSessionIdentifier(){
		return variables.controller.getUserSessionIdentifier();
	}

	/****************************************************************
	 * Relocation Methods *
	 ****************************************************************/

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
	 * @fallback      The fallback event or uri if the referrer is empty, defaults to `/`
	 * @persist       What request collection keys to persist in flash ram
	 * @persistStruct A structure key-value pairs to persist in flash ram
	 */
	function back( fallback = "/", persist, struct persistStruct ) cbMethod{
		var event     = getRequestContext();
		arguments.URL = event.getHTTPHeader( "referer", event.buildLink( arguments.fallback ) );
		relocate( argumentCollection = arguments );
	}

	/****************************************************************
	 * Runnables Methods *
	 ****************************************************************/

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

	/****************************************************************
	 * Env Methods *
	 ****************************************************************/

	/**
	 * Retrieve a Java System property or env value by name. It looks at properties first then environment variables
	 *
	 * @key          The name of the setting to look up.
	 * @defaultValue The default value to use if the key does not exist in the system properties or the env
	 */
	function getSystemSetting( required key, defaultValue ) cbMethod{
		return variables.env.getSystemSetting( argumentCollection = arguments );
	}

	/**
	 * Retrieve a Java System property only!
	 *
	 * @key          The name of the setting to look up.
	 * @defaultValue The default value to use if the key does not exist in the system properties or the env
	 */
	function getSystemProperty( required key, defaultValue ) cbMethod{
		return variables.env.getSystemProperty( argumentCollection = arguments );
	}

	/**
	 * Retrieve a environment variable only
	 *
	 * @key          The name of the setting to look up.
	 * @defaultValue The default value to use if the key does not exist in the system properties or the env
	 */
	function getEnv( required key, defaultValue ) cbMethod{
		return variables.env.getEnv( argumentCollection = arguments );
	}

	/****************************************************************
	 * Application Environment *
	 ****************************************************************/

	/**
	 * Determine if the application is in the `debugMode` or not
	 */
	boolean function inDebugMode(){
		return variables.controller.inDebugMode();
	}

	/**
	 * Determine if the application is in the `development|local` environment
	 */
	boolean function isDevelopment(){
		return variables.controller.isDevelopment();
	}

	/**
	 * Determine if the application is in the `production` environment
	 */
	boolean function isProduction(){
		return variables.controller.isProduction();
	}

	/**
	 * Determine if the application is in the `testing` environment
	 */
	boolean function isTesting(){
		return variables.controller.isTesting();
	}

	/****************************************************************
	 * Location Methods *
	 ****************************************************************/

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

	/****************************************************************
	 * Async Methods *
	 ****************************************************************/

	/**
	 * Return the ColdBox Async Manager instance so you can do some async or parallel programming
	 *
	 * @return coldbox.system.async.AsyncManager
	 */
	any function async() cbMethod{
		if ( isNull( variables.asyncManager ) ) {
			variables.asyncManager = variables.wirebox.getInstance( "asyncManager@coldbox" );
		}
		return variables.asyncManager;
	}

	/****************************************************************
	 * Flow Methods *
	 ****************************************************************/

	/**
	 * This function evaluates the target boolean expression and if `true` it will execute the `success` closure
	 * else, if the `failure` closure is passed, it will execute it.
	 *
	 * @target  The boolean evaluator, this can be a boolean value
	 * @success The closure/lambda to execute if the boolean value is true
	 * @failure The closure/lambda to execute if the boolean value is false
	 *
	 * @return Returns itself
	 */
	function when(
		required boolean target,
		required success,
		failure
	) cbmethod{
		return variables.flow.when( argumentCollection = arguments );
	}

	/**
	 * This function evaluates the target boolean expression and if `false` it will execute the `success` closure
	 * else, if the `failure` closure is passed, it will execute it.
	 *
	 * @target  The boolean evaluator, this can be a boolean value
	 * @success The closure/lambda to execute if the boolean value is true
	 * @failure The closure/lambda to execute if the boolean value is false
	 *
	 * @return Returns itself
	 */
	function unless(
		required boolean target,
		required success,
		failure
	) cbmethod{
		return variables.flow.unless( argumentCollection = arguments );
	}

	/**
	 * This function evaluates the target boolean expression and if `true` it will throw the controlled exception
	 *
	 * @target  The boolean evaluator, this can be a boolean value
	 * @type    The exception type
	 * @message The exception message
	 * @detail  The exception detail
	 *
	 * @return Returns itself
	 */
	function throwIf(
		required boolean target,
		required type,
		message = "",
		detail  = ""
	) cbmethod{
		return variables.flow.throwIf( argumentCollection = arguments );
	}

	/**
	 * This function evaluates the target boolean expression and if `false` it will throw the controlled exception
	 *
	 * @target  The boolean evaluator, this can be a boolean value
	 * @type    The exception type
	 * @message The exception message
	 * @detail  The exception detail
	 *
	 * @return Returns itself
	 */
	function throwUnless(
		required boolean target,
		required type,
		message = "",
		detail  = ""
	) cbmethod{
		return variables.flow.throwUnless( argumentCollection = arguments );
	}

	/**
	 * Verify if the target argument is `null` and if it is, then execute the `success` closure, else if passed
	 * execute the `failure` closure.
	 */
	function ifNull( target, required success, failure ) cbmethod{
		return variables.flow.ifNull( argumentCollection = arguments );
	}

	/**
	 * Verify if the target argument is not `null` and if it is, then execute the `success` closure, else if passed
	 * execute the `failure` closure.
	 */
	function ifPresent( target, required success, failure ) cbmethod{
		return variables.flow.ifPresent( argumentCollection = arguments );
	}

	/****************************************************************
	 * Data Integration Methods *
	 ****************************************************************/

	/**
	 * This function allows you to serialize simple or complex data so it can be used within HTML Attributes.
	 *
	 * @data The simple or complex data to bind to an HTML Attribute
	 */
	function forAttribute( required data ) cbMethod{
		return variables.jsonUtil.forAttribute( argumentCollection = arguments );
	}

	/**
	 * Opinionated method that serializes json in a more digetstible way:
	 * - queries as array of structs
	 * - no dumb secure prefixes
	 *
	 * @obj The object to be serialized
	 */
	string function toJson( any obj ){
		return variables.jsonUtil.toJson( argumentCollection = arguments );
	}

	/****************************************************************
	 * Date Time Methods *
	 ****************************************************************/

	/**
	 * Get the ColdBox date/time helper class
	 *
	 * @return coldbox.system.async.time.DateTimeHelper
	 */
	DateTimeHelper function getDateTimeHelper(){
		if ( isNull( variables.cbDateTimeHelper ) ) {
			variables.cbDateTimeHelper = variables.wirebox.getInstance(
				"coldbox.system.async.time.DateTimeHelper"
			);
		}
		return cbDateTimeHelper;
	}

	/**
	 * Generate an iso8601 formatted string from an incoming date/time object or none for the current time in ISO time
	 *
	 * @dateTime The input datetime or if not passed, the current date/time
	 * @toUTC    By default, we convert all times to UTC for standardization
	 */
	string function getIsoTime( dateTime = now(), boolean toUTC = true ){
		return getDateTimeHelper().getIsoTime( argumentCollection = arguments );
	}

	/****************************************************************
	 * Request Context Methods *
	 ****************************************************************/

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

	/****************************************************************
	 * Mixin and Helper Methods *
	 ****************************************************************/

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
		var mixinLocationKey = hash( variables.controller.getAppHash() & arguments.udfLibrary );
		var targetLocation   = getCache( "default" ).getOrSet(
			// Key
			"includeUDFLocation-#mixinLocationKey#",
			// Producer
			function(){
				var appMapping      = variables.controller.getSetting( "AppMapping" );
				var UDFFullPath     = expandPath( udflibrary );
				var UDFRelativePath = expandPath( "/" & appMapping & "/" & udflibrary );
				var locatedPath     = "";

				// Relative Checks First
				if ( fileExists( UDFRelativePath ) ) {
					locatedPath = "/" & appMapping & "/" & udflibrary;
				}
				// checks if no .cfc or .cfm where sent
				else if ( fileExists( UDFRelativePath & ".cfc" ) ) {
					locatedPath = "/" & appMapping & "/" & udflibrary & ".cfc";
				} else if ( fileExists( UDFRelativePath & ".cfm" ) ) {
					locatedPath = "/" & appMapping & "/" & udflibrary & ".cfm";
				} else if ( fileExists( UDFFullPath ) ) {
					locatedPath = "#udflibrary#";
				} else if ( fileExists( UDFFullPath & ".cfc" ) ) {
					locatedPath = "#udflibrary#.cfc";
				} else if ( fileExists( UDFFullPath & ".cfm" ) ) {
					locatedPath = "#udflibrary#.cfm";
				} else {
					throw(
						message = "Error loading UDF library: #udflibrary#",
						detail  = "The UDF library was not found.  Please make sure you verify the file location.",
						type    = "UDFLibraryNotFoundException"
					);
				}
				return locatedPath;
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
			if ( !variables.cbInjectedHelpers.keyExists( thisHelper ) ) {
				includeUDF( thisHelper );
				variables.cbInjectedHelpers[ thisHelper ] = true;
			}
		}

		return this;
	}

}
