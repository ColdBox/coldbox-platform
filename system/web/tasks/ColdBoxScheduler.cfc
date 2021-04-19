/**
 * The Async Scheduler is in charge of registering scheduled tasks, starting them, monitoring them and shutting them down if needed.
 *
 * Each scheduler is bound to an scheduled executor class. You can override the executor using the `setExecutor()` method if you so desire.
 * The scheduled executor will be named <code>{name}-scheduler</code>
 *
 * In a ColdBox context, you might have the global scheduler in charge of the global tasks and also 1 per module as well in HMVC fashion.
 * In a ColdBox context, this object will inherit from the ColdBox super type as well dynamically at runtime.
 *
 */
component
	extends  ="coldbox.system.async.tasks.Scheduler"
	accessors="true"
	singleton
{

	/**
	 * --------------------------------------------------------------------------
	 * Properties
	 * --------------------------------------------------------------------------
	 */

	/**
	 * ColdBox controller
	 */
	property name="controller";

	/**
	 * CacheBox
	 */
	property name="cachebox";

	/**
	 * WireBox
	 */
	property name="wirebox";

	/**
	 * Logger
	 */
	property name="log";

	/**
	 * The cache name to use for server fixation and more. By default we use the <code>template</code> region
	 */
	property name="cacheName";

	/**
	 * The bit that can be used to set all tasks created by this scheduler to always run on one server
	 */
	property name="serverFixation" type="boolean";

	/**
	 * Constructor
	 *
	 * @name The name of this scheduler
	 * @asyncManager The async manager we are linked to
	 * @asyncManager.inject coldbox:asyncManager
	 * @controller The coldBox controller
	 * @controller.inject coldbox
	 */
	function init(
		required name,
		required asyncManager,
		required controller
	){
		// Super init
		super.init( arguments.name, arguments.asyncManager );
		// Controller
		variables.controller     = arguments.controller;
		// Register Log object
		variables.log            = variables.controller.getLogBox().getLogger( this );
		// Register CacheBox
		variables.cacheBox       = arguments.controller.getCacheBox();
		// Register WireBox
		variables.wireBox        = arguments.controller.getWireBox();
		// CacheBox Region
		variables.cacheName      = "template";
		// Server fixation
		variables.serverFixation = false;
		return this;
	}

	/**
	 * --------------------------------------------------------------------------
	 * Overidden Methods
	 * --------------------------------------------------------------------------
	 */

	/**
	 * Register a new task in this scheduler that will be executed once the `startup()` is fired or manually
	 * via the run() method of the task.
	 *
	 * @return a ScheduledTask object so you can work on the registration of the task
	 */
	ColdBoxScheduledTask function task( required name ){
		// Create task with custom name
		var oColdBoxTask = variables.wirebox
			.getInstance(
				"coldbox.system.web.tasks.ColdBoxScheduledTask",
				{ name : arguments.name, executor : variables.executor }
			)
			// Set ourselves into the task
			.setScheduler( this )
			// Set the default cachename into the task
			.setCacheName( getCacheName() )
			// Server fixation
			.setServerFixation( getServerFixation() )
			// Set default timezone into the task
			.setTimezone( getTimezone().getId() );

		// Register the task by name
		variables.tasks[ arguments.name ] = {
			// task name
			"name"         : arguments.name,
			// task object
			"task"         : oColdBoxTask,
			// task scheduled future object
			"future"       : "",
			// when it registers
			"registeredAt" : now(),
			// when it's scheduled
			"scheduledAt"  : "",
			// Tracks if the task has been disabled for startup purposes
			"disabled"     : false,
			// If there is an error scheduling the task
			"error"        : false,
			// Any error messages when scheduling
			"errorMessage" : "",
			// The exception stacktrace if something went wrong scheduling the task
			"stacktrace"   : "",
			// Server Host
			"inetHost"     : variables.util.discoverInetHost(),
			// Server IP
			"localIp"      : variables.util.getServerIp()
		};

		return oColdBoxTask;
	}


	/**
	 * --------------------------------------------------------------------------
	 * ColdBox Methods
	 * --------------------------------------------------------------------------
	 */

	/**
	 * Get a instance object from WireBox
	 *
	 * @name The mapping name or CFC path or DSL to retrieve
	 * @initArguments The constructor structure of arguments to passthrough when initializing the instance
	 * @dsl The DSL string to use to retrieve an instance
	 *
	 * @return The requested instance
	 */
	function getInstance( name, initArguments = {}, dsl ){
		return variables.controller.getWirebox().getInstance( argumentCollection = arguments );
	}

	/**
	 * Retrieve the system web renderer
	 *
	 * @return coldbox.system.web.Renderer
	 */
	function getRenderer(){
		return variables.controller.getRenderer();
	}

	/**
	 * Render out a view
	 *
	 * @view The the view to render, if not passed, then we look in the request context for the current set view.
	 * @args A struct of arguments to pass into the view for rendering, will be available as 'args' in the view.
	 * @module The module to render the view from explicitly
	 * @cache Cached the view output or not, defaults to false
	 * @cacheTimeout The time in minutes to cache the view
	 * @cacheLastAccessTimeout The time in minutes the view will be removed from cache if idle or requested
	 * @cacheSuffix The suffix to add into the cache entry for this view rendering
	 * @cacheProvider The provider to cache this view in, defaults to 'template'
	 * @collection A collection to use by this Renderer to render the view as many times as the items in the collection (Array or Query)
	 * @collectionAs The name of the collection variable in the partial rendering.  If not passed, we will use the name of the view by convention
	 * @collectionStartRow The start row to limit the collection rendering with
	 * @collectionMaxRows The max rows to iterate over the collection rendering with
	 * @collectionDelim  A string to delimit the collection renderings by
	 * @prePostExempt If true, pre/post view interceptors will not be fired. By default they do fire
	 * @name The name of the rendering region to render out, Usually all arguments are coming from the stored region but you override them using this function's arguments.
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
		name
	){
		return variables.controller.getRenderer().renderView( argumentCollection = arguments );
	}

	/**
	 * Renders an external view anywhere that cfinclude works.
	 *
	 * @view The the view to render
	 * @args A struct of arguments to pass into the view for rendering, will be available as 'args' in the view.
	 * @cache Cached the view output or not, defaults to false
	 * @cacheTimeout The time in minutes to cache the view
	 * @cacheLastAccessTimeout The time in minutes the view will be removed from cache if idle or requested
	 * @cacheSuffix The suffix to add into the cache entry for this view rendering
	 * @cacheProvider The provider to cache this view in, defaults to 'template'
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
		cacheProvider          = "template"
	){
		return variables.controller.getRenderer().renderExternalView( argumentCollection = arguments );
	}

	/**
	 * Render a layout or a layout + view combo
	 *
	 * @layout The layout to render out
	 * @module The module to explicitly render this layout from
	 * @view The view to render within this layout
	 * @args An optional set of arguments that will be available to this layouts/view rendering ONLY
	 * @viewModule The module to explicitly render the view from
	 * @prePostExempt If true, pre/post layout interceptors will not be fired. By default they do fire
	 *
	 * @return The rendered layout
	 */
	function layout(
		layout,
		module                = "",
		view                  = "",
		struct args           = {},
		viewModule            = "",
		boolean prePostExempt = false
	){
		return variables.controller.getRenderer().renderLayout( argumentCollection = arguments );
	}

	/**
	 * Announce an interception
	 *
	 * @state The interception state to announce
	 * @data A data structure used to pass intercepted information.
	 * @async If true, the entire interception chain will be ran in a separate thread.
	 * @asyncAll If true, each interceptor in the interception chain will be ran in a separate thread and then joined together at the end.
	 * @asyncAllJoin If true, each interceptor in the interception chain will be ran in a separate thread and joined together at the end by default.  If you set this flag to false then there will be no joining and waiting for the threads to finalize.
	 * @asyncPriority The thread priority to be used. Either LOW, NORMAL or HIGH. The default value is NORMAL
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
	){
		// Backwards Compat: Remove by ColdBox 7
		if ( !isNull( arguments.interceptData ) ) {
			arguments.data = arguments.interceptData;
		}
		return variables.controller.getInterceptorService().announce( argumentCollection = arguments );
	}

	/**
	 * Executes events with full life-cycle methods and returns the event results if any were returned.
	 *
	 * @event The event string to execute, if nothing is passed we will execute the application's default event.
	 * @prePostExempt If true, pre/post handlers will not be fired. Defaults to false
	 * @private Execute a private event if set, else defaults to public events
	 * @defaultEvent The flag that let's this service now if it is the default event running or not. USED BY THE FRAMEWORK ONLY
	 * @eventArguments A collection of arguments to passthrough to the calling event handler method
	 * @cache Cached the output of the runnable execution, defaults to false. A unique key will be created according to event string + arguments.
	 * @cacheTimeout The time in minutes to cache the results
	 * @cacheLastAccessTimeout The time in minutes the results will be removed from cache if idle or requested
	 * @cacheSuffix The suffix to add into the cache entry for this event rendering
	 * @cacheProvider The provider to cache this event rendering in, defaults to 'template'
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
	){
		return variables.controller.runEvent( argumentCollection = arguments );
	}

	/**
	 * Executes internal named routes with or without parameters. If the named route is not found or the route has no event to execute then this method will throw an `InvalidArgumentException`.
	 * If you need a route from a module then append the module address: `@moduleName` or prefix it like in run event calls `moduleName:routeName` in order to find the right route.
	 * The route params will be passed to events as action arguments much how eventArguments work.
	 *
	 * @name The name of the route
	 * @params The parameters of the route to replace
	 * @cache Cached the output of the runnable execution, defaults to false. A unique key will be created according to event string + arguments.
	 * @cacheTimeout The time in minutes to cache the results
	 * @cacheLastAccessTimeout The time in minutes the results will be removed from cache if idle or requested
	 * @cacheSuffix The suffix to add into the cache entry for this event rendering
	 * @cacheProvider The provider to cache this event rendering in, defaults to 'template'
	 * @prePostExempt If true, pre/post handlers will not be fired. Defaults to false
	 *
	 * @throws InvalidArgumentException
	 *
	 * @return null or anything produced from the route
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
	){
		return variables.controller.runRoute( argumentCollection = arguments );
	}

	/**
	 * Get a named CacheBox Cache
	 *
	 * @name The name of the cache to retrieve, if not passed, it used the 'default' cache.
	 *
	 * @return coldbox.system.cache.providers.IColdBoxProvider
	 */
	function getCache( name = "default" ){
		return variables.controller.getCache( arguments.name );
	}

	/**
	 * Get a setting from the system
	 *
	 * @name The key of the setting
	 * @defaultValue If not found in config, default return value
	 *
	 * @throws SettingNotFoundException
	 *
	 * @return The requested setting
	 */
	function getSetting( required name, defaultValue ){
		return variables.controller.getSetting( argumentCollection = arguments );
	}

	/**
	 * Get a ColdBox setting
	 *
	 * @name The key to get
	 * @defaultValue The default value if it doesn't exist
	 *
	 * @throws SettingNotFoundException
	 *
	 * @return The framework setting value
	 */
	function getColdBoxSetting( required name, defaultValue ){
		return variables.controller.getColdBoxSetting( argumentCollection = arguments );
	}

	/**
	 * Check if the setting exists in the application
	 *
	 * @name The key of the setting
	 */
	boolean function settingExists( required name ){
		return variables.controller.settingExists( argumentCollection = arguments );
	}

	/**
	 * Set a new setting in the system
	 *
	 * @name The key of the setting
	 * @value The value of the setting
	 *
	 * @return FrameworkSuperType
	 */
	any function setSetting( required name, required value ){
		controller.setSetting( argumentCollection = arguments );
		return this;
	}

	/**
	 * Get a module's settings structure or a specific setting if the setting key is passed
	 *
	 * @module The module to retrieve the configuration settings from
	 * @setting The setting to retrieve if passed
	 * @defaultValue The default value to return if setting does not exist
	 *
	 * @return struct or any
	 */
	any function getModuleSettings( required module, setting, defaultValue ){
		var moduleSettings = getModuleConfig( arguments.module ).settings;
		// return specific setting?
		if ( structKeyExists( arguments, "setting" ) ) {
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
	 * @throws InvalidModuleException - The module passed is invalid
	 *
	 * @return The struct requested
	 */
	struct function getModuleConfig( required module ){
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
	 * Resolve a file to be either relative or absolute in your application
	 *
	 * @pathToCheck The file path to check
	 */
	string function locateFilePath( required pathToCheck ){
		return variables.controller.locateFilePath( argumentCollection = arguments );
	}

	/**
	 * Resolve a directory to be either relative or absolute in your application
	 *
	 * @pathToCheck The file path to check
	 */
	string function locateDirectoryPath( required pathToCheck ){
		return variables.controller.locateDirectoryPath( argumentCollection = arguments );
	}

	/**
	 * Retrieve a Java System property or env value by name. It looks at properties first then environment variables
	 *
	 * @key The name of the setting to look up.
	 * @defaultValue The default value to use if the key does not exist in the system properties or the env
	 */
	function getSystemSetting( required key, defaultValue ){
		return variables.controller.getUtil().getSystemSetting( argumentCollection = arguments );
	}

	/**
	 * Retrieve a Java System property only!
	 *
	 * @key The name of the setting to look up.
	 * @defaultValue The default value to use if the key does not exist in the system properties or the env
	 */
	function getSystemProperty( required key, defaultValue ){
		return variables.controller.getUtil().getSystemProperty( argumentCollection = arguments );
	}

	/**
	 * Retrieve a environment variable only
	 *
	 * @key The name of the setting to look up.
	 * @defaultValue The default value to use if the key does not exist in the system properties or the env
	 */
	function getEnv( required key, defaultValue ){
		return variables.controller.getUtil().getEnv( argumentCollection = arguments );
	}

}
