/**
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
* ---
* Base class for all things Box
* @author Luis Majano <lmajano@ortussolutions.com>
*/
component serializable="false" accessors="true"{

	// Controller Reference
	property name="controller";

	/**
	* Get a model object
	* @name The mapping name or CFC path to retrieve
	* @dsl The DSL string to use to retrieve an instance
	* @initArguments The constructor structure of arguments to passthrough when initializing the instance
	*/
	function getModel( name, dsl, initArguments={} ){
		return getInstance( argumentCollection=arguments );
	}

	/**
	* Get a instance object from WireBox
	* @name The mapping name or CFC path to retrieve
	* @dsl The DSL string to use to retrieve an instance
	* @initArguments The constructor structure of arguments to passthrough when initializing the instance
	*/
	function getInstance( name, dsl, initArguments={} ){
		return controller.getWirebox().getInstance( argumentCollection=arguments );
	}

	/**
	* Populate a model object from the request Collection or a passed in memento structure
	* @model The name of the model to get and populate or the acutal model object. If you already have an instance of a model, then use the populateBean() method
	* @scope Use scope injection instead of setters population. Ex: scope=variables.instance.
	* @trustedSetter If set to true, the setter method will be called even if it does not exist in the object
	* @include A list of keys to include in the population
	* @exclude A list of keys to exclude in the population
	* @ignoreEmpty Ignore empty values on populations, great for ORM population
	* @nullEmptyInclude A list of keys to NULL when empty
	* @nullEmptyExclude A list of keys to NOT NULL when empty
	* @composeRelationships Automatically attempt to compose relationships from memento
	* @memento A structure to populate the model, if not passed it defaults to the request collection
	* @jsonstring If you pass a json string, we will populate your model with it
	* @xml If you pass an xml string, we will populate your model with it
	* @qry If you pass a query, we will populate your model with it
	* @rowNumber The row of the qry parameter to populate your model with
	*/
	function populateModel(
		required model,
		scope="",
		boolean trustedSetter=false,
		include="",
		exclude="",
		boolean ignoreEmpty=false,
		nullEmptyInclude="",
		nullEmptyExclude="",
		boolean composeRelationships=false,
		struct memento=getRequestCollection(),
		string jsonstring,
		string xml,
		query qry
	){
		// Do we have a model or name
		if( isSimpleValue( arguments.model ) ){
			arguments.target = getModel( model );
		} else {
			arguments.target = arguments.model;
		}

		// json?
		if( structKeyExists( arguments, "jsonstring" ) ){
			return wirebox.getObjectPopulator().populateFromJSON( argumentCollection=arguments );
		}
		// XML
		else if( structKeyExists( arguments, "xml" ) ){
			return wirebox.getObjectPopulator().populateFromXML( argumentCollection=arguments );
		}
		// Query
		else if( structKeyExists( arguments, "qry" ) ){
			return wirebox.getObjectPopulator().populateFromQuery( argumentCollection=arguments );
		}
		// Mementos
		else {
			// populate
			return wirebox.getObjectPopulator().populateFromStruct( argumentCollection=arguments );
		}
	}

	/**
	* Retrieve the system web renderer
	* @return coldbox.system.web.Renderer
	*/
	function getRenderer(){
		return controller.getRenderer();
	}

	/**
	* Retrieve the request context object
	* @return coldbox.system.web.context.RequestContext
	*/
	function getRequestContext(){
		return controller.getRequestService().getContext();
	}

	/**
	* Get the RC or PRC collection reference
	* @private The boolean bit that says give me the RC by default or true for the private collection (PRC)
	*/
	struct function getRequestCollection( boolean private=false ){
		return getRequestContext().getCollection( private=arguments.private );
	}

	/**
	* Render out a view
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
	*/
	function renderView(
		view="",
		struct args={},
		module="",
		boolean cache=false,
		cacheTimeout="",
		cacheLastAccessTimeout="",
		cacheSuffix="",
		cacheProvider="template",
		collection,
		collectionAs="",
		numeric collectionStartRow="1",
		numeric collectionMaxRows=0,
		collectionDelim="",
		boolean prePostExempt=false,
		name
	){
		return controller.getRenderer().renderView( argumentCollection=arguments );
	}

	/**
    * Renders an external view anywhere that cfinclude works.
    * @view The the view to render
	* @args A struct of arguments to pass into the view for rendering, will be available as 'args' in the view.
	* @cache Cached the view output or not, defaults to false
	* @cacheTimeout The time in minutes to cache the view
	* @cacheLastAccessTimeout The time in minutes the view will be removed from cache if idle or requested
	* @cacheSuffix The suffix to add into the cache entry for this view rendering
	* @cacheProvider The provider to cache this view in, defaults to 'template'
	*/
    function renderExternalView(
    	required view,
    	struct args={},
    	boolean cache=false,
    	cacheTimeout="",
    	cacheLastAccessTimeout="",
    	cacheSuffix="",
    	cacheProvider="template"
    ){
		return controller.getRenderer().renderExternalView( argumentCollection=arguments );
	}

	/**
	* Render a layout or a layout + view combo
	* @layout The layout to render out
	* @module The module to explicitly render this layout from
	* @view The view to render within this layout
	* @args An optional set of arguments that will be available to this layouts/view rendering ONLY
	* @viewModule The module to explicitly render the view from
	* @prePostExempt If true, pre/post layout interceptors will not be fired. By default they do fire
	*/
	function renderLayout(
		layout,
		module="",
		view="",
		struct args={},
		viewModule="",
		boolean prePostExempt=false
	){
		return controller.getRenderer().renderLayout( argumentCollection=arguments );
	}

	/**
	* Get an interceptor reference
	* @interceptorName The name of the interceptor to retrieve
	*
	* @return Interceptor
	*/
	function getInterceptor( required interceptorName ){
		return controller.getInterceptorService().getInterceptor( argumentCollection=arguments );
	}

	/**
	* Announce an interception to the system. If you use the asynchronous facilities, you will get a thread structure report as a result.
	* @state The event to announce
	* @interceptData A data structure used to pass intercepted information.
	* @async If true, the entire interception chain will be ran in a separate thread.
	* @asyncAll If true, each interceptor in the interception chain will be ran in a separate thread and then joined together at the end.
	* @asyncAllJoin If true, each interceptor in the interception chain will be ran in a separate thread and joined together at the end by default.  If you set this flag to false then there will be no joining and waiting for the threads to finalize.
	* @asyncPriority The thread priority to be used. Either LOW, NORMAL or HIGH. The default value is NORMAL
	* @asyncJoinTimeout The timeout in milliseconds for the join thread to wait for interceptor threads to finish.  By default there is no timeout.
	*
	* @return struct of thread information or void
	*/
	any function announceInterception(
		required state,
		struct interceptData={},
		boolean async=false,
		boolean asyncAll=false,
		boolean asyncAllJoin=true,
		asyncPriority="NORMAL",
		numeric asyncJoinTimeout=0
	){
		return controller.getInterceptorService().processState( argumentCollection=arguments );
	}

	/**
	* Get a named CacheBox Cache
	* @name The name of the cache to retrieve, if not passed, it used the 'default' cache.
	*
	* @return coldbox.system.cache.providers.IColdBoxProvider
	*/
	function getCache( name = "default" ){
		return controller.getCache( arguments.name );
	}

	/**
	* DEPRECATED: Get all the settings structure
	* @fwsetting Retrieve from the config or fw settings, defaults to config
	* @deepCopy Do a deep or shallow copy, shallow is default
	*/
	function getSettingStructure( boolean fwSetting=false, boolean deepCopy=false ){
		return controller.getSettingStructure( argumentCollection=arguments );
	}

	/**
	* Get a setting from the system
	* @name The key of the setting
	* @fwSetting Retrieve from the config or fw settings, defaults to config
	* @defaultValue If not found in config, default return value
	*/
	function getSetting( required name, boolean fwSetting=false, defaultValue ){
		return controller.getSetting( argumentCollection=arguments );
	}

	/**
	* Verify a setting from the system
	* @name The key of the setting
	* @fwSetting Retrieve from the config or fw settings, defaults to config
	*/
	boolean function settingExists( required name, boolean fwSetting=false ){
		return controller.settingExists( argumentCollection=arguments );
	}

	/**
	* Set a new setting in the system
	* @name The key of the setting
	* @value The value of the setting
	*
	* @return FrameworkSuperType
	*/
	any function setSetting( required name, required value ){
		controller.setSetting( argumentCollection=arguments );
		return this;
	}

	/**
	* Get a module's settings structure or a specific setting if the setting key is passed
	* @module The module to retrieve the configuration settings from
	* @setting The setting to retrieve if passed
	* @defaultValue The default value to return if setting does not exist
	*
	* @return struct or any
	*/
	any function getModuleSettings( required module, setting, defaultValue ){
		var moduleSettings = getModuleConfig( arguments.module ).settings;
		// return specific setting?
		if( structKeyExists( arguments, "setting" ) ){
			return ( structKeyExists( moduleSettings, arguments.setting ) ? moduleSettings[ arguments.setting ] : arguments.defaultValue );
		}
		return moduleSettings;
	}

	/**
	* Get a module's configuration structure
	* @module The module to retrieve the configuration structure from
	*/
	struct function getModuleConfig( required module ){
		var mConfig = controller.getSetting( "modules" );
		if( structKeyExists( mConfig, arguments.module ) ){
			return mConfig[ arguments.module ];
		}
		throw( message="The module you passed #arguments.module# is invalid.",
			   detail="The loaded modules are #structKeyList( mConfig )#",
			   type="FrameworkSuperType.InvalidModuleException");
	}

	/**
	* DEPRECATED! PLEASE USE `relocate()` method instead
	*
	* @event The name of the event to run, if not passed, then it will use the default event found in your configuration file
	* @URL The full URL you would like to relocate to instead of an event: ex: URL='http://www.google.com'
	* @URI The relative URI you would like to relocate to instead of an event: ex: URI='/mypath/awesome/here'
	* @queryString The query string to append, if needed. If in SES mode it will be translated to convention name value pairs
	* @persist What request collection keys to persist in flash ram
	* @persistStruct A structure key-value pairs to persist in flash ram
	* @addToken Wether to add the tokens or not. Default is false
	* @ssl Whether to relocate in SSL or not
	* @baseURL Use this baseURL instead of the index.cfm that is used by default. You can use this for ssl or any full base url you would like to use. Ex: https://mysite.com/index.cfm
	* @postProcessExempt Do not fire the postProcess interceptors
	* @statusCode The status code to use in the relocation
	*/
	void function setNextEvent(
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
	){
		controller.relocate( argumentCollection=arguments );
	}

	/**
	* Relocate user browser requests to other events, URLs, or URIs.
	*
	* @event The name of the event to run, if not passed, then it will use the default event found in your configuration file
	* @URL The full URL you would like to relocate to instead of an event: ex: URL='http://www.google.com'
	* @URI The relative URI you would like to relocate to instead of an event: ex: URI='/mypath/awesome/here'
	* @queryString The query string to append, if needed. If in SES mode it will be translated to convention name value pairs
	* @persist What request collection keys to persist in flash ram
	* @persistStruct A structure key-value pairs to persist in flash ram
	* @addToken Wether to add the tokens or not. Default is false
	* @ssl Whether to relocate in SSL or not
	* @baseURL Use this baseURL instead of the index.cfm that is used by default. You can use this for ssl or any full base url you would like to use. Ex: https://mysite.com/index.cfm
	* @postProcessExempt Do not fire the postProcess interceptors
	* @statusCode The status code to use in the relocation
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
	){
		controller.relocate( argumentCollection=arguments );
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
	 */
	any function runRoute(
		required name,
		struct params={},
		boolean cache=false,
		cacheTimeout="",
		cacheLastAccessTimeout="",
		cacheSuffix="",
		cacheProvider="template",
		boolean prePostExempt=false
	){
		return controller.runRoute( argumentCollection=arguments );
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
	 * @return null or any
	 */
	function runEvent(
		event="",
		boolean prePostExempt=false,
		boolean private=false,
		boolean defaultEvent=false,
		struct eventArguments={},
		boolean cache=false,
		cacheTimeout="",
		cacheLastAccessTimeout="",
		cacheSuffix="",
		cacheProvider="template"
	){
		return controller.runEvent( argumentCollection=arguments );
	}

	/**
	* Persist variables into the Flash RAM
	* @persist A list of request collection keys to persist
	* @persistStruct A struct of key-value pairs to persist
	* @return FrameworkSuperType
	*/
	function persistVariables( persist="", struct persistStruct={} ){
		controller.persistVariables( argumentCollection=arguments );
		return this;
	}

	/****************************************** UTILITY METHODS ******************************************/

	/**
	 * Retrieve a Java System property or env value by name. It looks at properties first then environment variables
	 *
	 * @key The name of the setting to look up.
	 * @defaultValue The default value to use if the key does not exist in the system properties or the env
	 */
	function getSystemSetting( required key, defaultValue ){
		return controller.getUtil().getSystemSetting( argumentCollection=arguments );
	}

	/**
	 * Retrieve a Java System property only!
	 *
	 * @key The name of the setting to look up.
	 * @defaultValue The default value to use if the key does not exist in the system properties or the env
	 */
	function getSystemProperty( required key, defaultValue ){
		return controller.getUtil().getSystemProperty( argumentCollection=arguments );
	}

	/**
	 * Retrieve a environment variable only
	 *
	 * @key The name of the setting to look up.
	 * @defaultValue The default value to use if the key does not exist in the system properties or the env
	 */
	function getEnv( required key, defaultValue ){
		return controller.getUtil().getEnv( argumentCollection=arguments );
	}

	/**
	* Resolve a file to be either relative or absolute in your application
	* @pathToCheck The file path to check
	*/
	string function locateFilePath( required pathToCheck ){
		return controller.locateFilePath( argumentCollection=arguments );
	}

	/**
	* Resolve a directory to be either relative or absolute in your application
	* @pathToCheck The file path to check
	*/
	string function locateDirectoryPath( required pathToCheck ){
		return controller.locateDirectoryPath( argumentCollection=arguments );
	}

	/**
	* Add a js/css asset(s) to the html head section. You can also pass in a list of assets. This method
	* keeps track of the loaded assets so they are only loaded once
	* @asset The asset(s) to load, only js or css files. This can also be a comma delimmited list.
	*/
	string function addAsset( required asset ){
		return getInstance( "@HTMLHelper" ).addAsset( argumentCollection=arguments );
	}

	/**
	* Injects a UDF Library (*.cfc or *.cfm) into the target object.  It does not however, put the mixins on any of the cfc scopes. Therefore they can only be called internally
	* @udflibrary The UDF library to inject
	* @return FrameworkSuperType
	*/
	any function includeUDF( required udflibrary ){
		var appMapping		= controller.getSetting( "AppMapping" );
		var UDFFullPath 	= expandPath( arguments.udflibrary );
		var UDFRelativePath = expandPath( "/" & appMapping & "/" & arguments.udflibrary );

		var targetLocation = "";

		// Relative Checks First
		if( fileExists( UDFRelativePath ) ){
			targetLocation = "/" & appMapping & "/" & arguments.udflibrary;
		}
		// checks if no .cfc or .cfm where sent
		else if ( fileExists(UDFRelativePath & ".cfc") ){
			targetLocation = "/" & appMapping & "/" & arguments.udflibrary & ".cfc";
		} else if ( fileExists(UDFRelativePath & ".cfm") ){
			targetLocation = "/" & appMapping & "/" & arguments.udflibrary & ".cfm";
		} else if ( fileExists( UDFFullPath ) ){
			targetLocation = "#udflibrary#";
		} else if ( fileExists( UDFFullPath & ".cfc" ) ){
			targetLocation = "#udflibrary#.cfc";
		} else if ( fileExists( UDFFullPath & ".cfm" ) ){
			targetLocation = "#udflibrary#.cfm";
		} else {
			throw(
				message = "Error loading UDF library: #arguments.udflibrary#",
				detail 	= "The UDF library was not found.  Please make sure you verify the file location.",
				type 	= "FrameworkSupertype.UDFLibraryNotFoundException");
		}

		// Include the UDF
		include targetLocation;

		return this;
	}

	/**
	* Load the global application helper libraries defined in the applicationHelper Setting of your application.
	* This is called by the framework ONLY! Use at your own risk
	* @return FrameworkSuperType
	*/
	any function loadApplicationHelpers(){
		// Skip if we've already mixed in a super class
		if( structKeyExists( this, '$super' ) ) {
			return this;
		}

		// Inject global helpers
		var helpers	= controller.getSetting( "applicationHelper" );

		for( var thisHelper in helpers ){
			includeUDF( thisHelper );
		}

		return this;
	}

	/**** REMOVE THE FOLLOWING: JUST LEFT UNTIL COMPLETELY REMOVED ****/
	function getPlugin(){
		throw( "This method has been deprecated, please use getInstance() instead" );
	}
	function getMyPlugin(){
		throw( "This method has been deprecated, please use getInstance() instead" );
	}

}