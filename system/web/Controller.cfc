/**
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
* ---
* Manages a ColdBox application, dispatches events and acts as an overall front controller.
*/
component serializable="false" accessors="true"{

	/**
	* The CFML engine helper
	*/
	property name="CFMLEngine";
	/**
	* The system utility object
	*/
	property name="util";
	/**
	* ColdBox initiation flag
	*/
	property name="coldboxInitiated" type="boolean";
	/**
	* ColdBox application key
	*/
	property name="appKey";
	/**
	* ColdBox application root path
	*/
	property name="appRootPath";
	/**
	* ColdBox application unique hash key
	*/
	property name="appHash";
	/**
	* Container for all internal services (LinkedHashMap)
	*/
	property name="services";
	/**
	* The application configuration settings structure
	*/
	property name="configSettings" type="struct";
	/**
	* The internal ColdBox settings structure
	*/
	property name="coldboxSettings" type="struct";
	/**
	* The reference to CacheBox
	*/
	property name="cachebox";
	/**
	* The reference to WireBox
	*/
	property name="wirebox";
	/**
	* The reference to LogBox
	*/
	property name="logbox";
	/**
	* The controller logger object
	*/
	property name="log";

	/**
	* Constructor
	* @appRootPath The application root path
	* @appKey The application registered application key
	*/
	function init( required appRootPath, appKey="cbController" ){
		// Create Utility
		variables.util 			= new coldbox.system.core.util.Util();
		// services scope
		variables.services 		= createObject( "java", "java.util.LinkedHashMap" ).init( 6 );
		// CFML Engine Utility
		variables.CFMLEngine 	= new coldbox.system.core.util.CFMLEngine();

		// Set Main Application Properties
		variables.coldboxInitiated 		= false;
		variables.appKey				= arguments.appKey;
		// Fix Application Path to last / standard.
		if( NOT reFind( "(/|\\)$", arguments.appRootPath ) ){
			arguments.appRootPath = appRootPath & "/";
		}
		variables.appHash				= hash( arguments.appRootPath );
		variables.appRootPath			= arguments.appRootPath;
		variables.configSettings 		= structNew();
		variables.coldboxSettings		= structNew();

		// LogBox Default Configuration & Creation
		services.loaderService 		= new coldbox.system.web.services.LoaderService( this );
		variables.logBox 			= services.loaderService.createDefaultLogBox();
		variables.log 				= variables.logBox.getLogger( this );

		// Setup the ColdBox Services
		services.requestService 	= new coldbox.system.web.services.RequestService( this );
		services.interceptorService = new coldbox.system.web.services.InterceptorService( this );
		services.handlerService 	= new coldbox.system.web.services.HandlerService( this );
		services.routingService		= new coldbox.system.web.services.RoutingService( this );
		services.moduleService 		= new coldbox.system.web.services.ModuleService( this );

		// CacheBox Instance
		variables.cacheBox 	= createObject( "component", "coldbox.system.cache.CacheFactory" );
		// WireBox Instance
		variables.wireBox	= createObject( "component", "coldbox.system.ioc.Injector" );

		// Load up default ColdBox Settings
		loadColdBoxSettings();

		return this;
	}

	/****************************************** GLOBAL GETTERS *************************************************/

	/**
	* Get controller memento, used only by decorator only.
	*/
	function getMemento(){
		return {
			variables = variables
		};
	}

	/**
	* Get the system web renderer, you can also retreive it from wirebox via renderer@coldbox
	*/
	function getRenderer(){
		return variables.wireBox.getInstance( "Renderer@coldbox" );
	}

	/**
	*  Get the system data marshaller, you can also retreive it from wirebox via dataMarshaller@coldbox
	*/
	function getDataMarshaller(){
		return variables.wireBox.getInstance( "DataMarshaller@coldbox" );
	}

	/**
	* Get a Cache provider from CacheBox
	* @cacheName The name of the cache to retrieve, or it defaults to the 'default' cache.
	*
	* @return coldbox.system.cache.providers.IColdBoxProvider
	*/
	function getCache( required cacheName='default' ){
		return variables.cacheBox.getCache( arguments.cacheName );
	}

	/**
	* Get the loader service
	*/
	function getLoaderService(){
		return services.loaderService;
	}

	/**
	* Get the module service
	*/
	function getModuleService(){
		return services.moduleService;
	}

	/**
	* Get the interceptor service
	*/
	function getInterceptorService(){
		return services.interceptorService;
	}

	/**
	* Get the handler service
	*/
	function getHandlerService(){
		return services.handlerService;
	}

	/**
	* Get the request service
	*/
	function getRequestService(){
		return services.requestService;
	}

	/**
	* Get the routing service
	*/
	function getRoutingService(){
		return services.routingService;
	}

	/****************************************** SETTING METHODS *************************************************/

	/**
	* Get a setting from a configuration structure
	* @name The name of the setting
	* @fwSetting Switch to get the coldbox or config settings, defaults to config settings
	* @defaultValue The default value to use if setting does not exist
	*/
	function getSetting( required name, boolean fwSetting=false, defaultValue ){
		var target = variables.configSettings;

		if( arguments.FWSetting ){ target = variables.coldboxSettings; }

		if ( settingExists( arguments.name, arguments.FWSetting ) ){
			return target[ arguments.name ];
		}

		// Default value
		if( structKeyExists( arguments, "defaultValue" ) ){
			return arguments.defaultValue;
		}

		throw( message="The setting #arguments.name# does not exist.",
			   detail="FWSetting flag is #arguments.FWSetting#",
			   type="Controller.SettingNotFoundException");
	}

	/**
	* Check if a value exists in a configuration structure
	* @name The name of the setting
	* @fwSetting Switch to get the coldbox or config settings, defaults to config settings
	*/
	boolean function settingExists( required name, boolean fwSetting=false ){
		return ( arguments.fwSetting ? structKeyExists( variables.coldboxSettings, arguments.name ) : structKeyExists( variables.configSettings, arguments.name ) );
	}

	/**
	* Set a value in the application configuration settings
	* @name The name of the setting
	* @value The value to set
	*
	* @return Controller
	*/
	function setSetting( required name, required value ){
		variables.configSettings[ arguments.name ] = arguments.value;
		return this;
	}

	/****************************************** DEPRECATED METHODS *************************************************/

	/**
	* DEPRECATED: Convenience method to retrieve the config or coldbox settings.
	* @fwSetting Switch to get the coldbox or config settings, defaults to config settings
	* @deepCopyFlag Do a deep or reference return
	*/
	struct function getSettingStructure( boolean fwSetting=false, boolean deepCopyFlag=false ){
		if ( arguments.FWSetting ){
			if ( arguments.deepCopyFlag ){
				return duplicate( variables.coldboxSettings );
			}
			return variables.coldboxSettings;
		} else {
			if ( arguments.deepCopyFlag ){
				return duplicate( variables.configSettings );
			}
			return variables.configSettings;
		}
	}

	/**
	* DEPRECATED
	*/
	function getPlugin(){
		throw( message="This method has been deprecated, please use getInstance() instead" );
	}

	/****************************************** RELOCATION HELPERS *************************************************/

	/**
	* Relocate user browser requests to other events, URLs, or URIs.
	*
	* @event The name of the event to relocate to, if not passed, then it will use the default event found in your configuration file.
	* @queryString The query string to append, if needed. If in SES mode it will be translated to convention name value pairs
	* @addToken Wether to add the tokens or not to the relocation. Default is false
	* @persist What request collection keys to persist in flash RAM automatically for you
	* @persistStruct A structure of key-value pairs to persist in flash RAM automatically for you
	* @ssl Whether to relocate in SSL or not. You need to explicitly say TRUE or FALSE if going out from SSL. If none passed, we look at the even's SES base URL (if in SES mode)
	* @baseURL Use this baseURL instead of the index.cfm that is used by default. You can use this for SSL or any full base url you would like to use. Ex: https://mysite.com/index.cfm
	* @postProcessExempt Do not fire the postProcess interceptors, by default it does
	* @URL The full URL you would like to relocate to instead of an event: ex: URL='http://www.google.com'
	* @URI The relative URI you would like to relocate to instead of an event: ex: URI='/mypath/awesome/here'
	* @statusCode The status code to use in the relocation
	*
	* @return Controller
	*/
	function relocate(
		event=getSetting( "DefaultEvent" ),
		queryString="",
		boolean addToken=false,
		persist="",
		struct persistStruct=structnew()
		boolean ssl,
		baseURL="",
		boolean postProcessExempt=false,
		URL,
		URI,
		numeric statusCode=0
	){
		// Determine the type of relocation
		var relocationType  = "EVENT";
		var relocationURL   = "";
		var eventName	    = variables.configSettings[ "EventName" ];
		var frontController = listlast( cgi.script_name, "/" );
		var oRequestContext = services.requestService.getContext();
		var routeString     = 0;

		// Determine relocation type
		if( oRequestContext.isSES() ){
			relocationType = "SES";
		}
		if( structKeyExists( arguments, "URL" ) ){
			relocationType = "URL";
		}
		if( structKeyExists( arguments, "URI" ) ){
			relocationType = "URI";
		}

		// Cleanup event string to default if not sent in
		if( len( trim( arguments.event ) ) eq 0 ){
			arguments.event = getSetting( "DefaultEvent" );
		}
		// Overriding Front Controller via baseURL argument
		if( len( trim( arguments.baseURL ) ) ){
			frontController = arguments.baseURL;
		}

		// Relocation Types
		switch( relocationType ){
			// FULL URL relocations
			case "URL" : {
				relocationURL = arguments.URL;
				// Check SSL?
				if( structKeyExists(arguments, "ssl") ){
					relocationURL = updateSSL(relocationURL,arguments.ssl);
				}
				// Query String?
				if( len( trim( arguments.queryString ) ) ){ relocationURL = relocationURL & "?#arguments.queryString#"; }
				break;
			}

			// URI relative relocations
			case "URI" : {
				relocationURL = arguments.URI;
				// Query String?
				if( len( trim( arguments.queryString ) ) ){ relocationURL = relocationURL & "?#arguments.queryString#"; }
				break;
			}

			// Default event relocations
			case "SES" : {
				// Convert module into proper entry point
				if( listLen( arguments.event, ":" ) > 1 ) {
					var mConfig = getSetting( "modules" );
					var module = listFirst( arguments.event, ":" );
					if( structKeyExists( mConfig, module ) ){
						arguments.event = mConfig[ module ].inheritedEntryPoint & "/" & listRest( arguments.event, ":" );
					}
				}
				// Route String start by converting event syntax to / syntax
				routeString = replace( arguments.event, ".", "/", "all" );
				// Convert Query String to convention name value-pairs
				if( len( trim( arguments.queryString ) ) ){
					// If the routestring ends with '/' we do not want to
					// double append '/'
					if (right(routeString,1) NEQ "/")
					{
						routeString = routeString & "/" & replace( arguments.queryString, "&", "/", "all" );
					} else {
						routeString = routeString & replace( arguments.queryString, "&", "/", "all" );
					}
					routeString = replace(routeString,"=","/","all");
				}

				// Get Base relocation URL from context
				relocationURL = oRequestContext.getSESBaseURL();
				//if the sesBaseURL is nothing, set it to the setting
				if( !len( relocationURL ) ){
					relocationURL = getSetting( 'sesBaseURL' );
				}
				//add the trailing slash if there isnt one
				if( right( relocationURL, 1 ) neq "/" ){
					relocationURL = relocationURL & "/";
				}
				// Check SSL?
				if( structKeyExists( arguments, "ssl" ) ){
					relocationURL = updateSSL( relocationURL, arguments.ssl );
				}

				// Finalize the URL
				relocationURL = relocationURL & routeString;

				break;
			}
			default :{
				// Basic URL Relocation
				relocationURL = "#frontController#?#eventName#=#arguments.event#";
				// Check SSL?
				if( structKeyExists( arguments, "ssl" ) ){
					relocationURL = updateSSL( relocationURL, arguments.ssl );
				}
				// Query String?
				if( len( trim( arguments.queryString ) ) ){
					relocationURL = relocationURL & "&#arguments.queryString#";
				}
			}
		}

		// persist Flash RAM
		persistVariables( argumentCollection=arguments );

		// Post Processors
		if( NOT arguments.postProcessExempt ){
			services.interceptorService.processState("postProcess");
		}

		// Save Flash RAM
		if( variables.configSettings.flash.autoSave ){
			services.requestService.getFlashScope().saveFlash();
		}

		// Send Relocation
		sendRelocation( URL=relocationURL, addToken=arguments.addToken, statusCode=arguments.statusCode );

		return this;
	}

	/****************************************** RUNNERS *************************************************/

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
		// Get routing service and default routes
		var router 			= getWirebox().getInstance( "router@coldbox" );
		var targetRoutes 	= router.getRoutes();
		var targetModule 	= "";

		// Module Route?
		if( find( "@", arguments.name ) ){
			targetModule 	= getToken( arguments.name, 2, "@" );
			targetRoutes 	= router.getModuleRoutes( targetModule );
			arguments.name 	= getToken( arguments.name, 1, "@" );
		}
		if( find( ":", arguments.name ) ){
			targetModule 	= getToken( arguments.name, 1, ":" );
			targetRoutes 	= router.getModuleRoutes( targetModule );
			arguments.name 	= getToken( arguments.name, 2, ":" );
		}

		// Find the named route
		var foundRoute = targetRoutes
			.filter( function( item ){
				return ( arguments.item.name == name ? true : false );
			} ).reduce( function( results, item ){
				return item;
			}, {} );

		// Did we find it?
		if( !foundRoute.isEmpty() ){
			var event = services.requestService.getContext();

			// Do we have a response closure
			if( isClosure( foundRoute.response ) || isCustomFunction( foundRoute.response ) ){
				return foundRoute.response( event, event.getCollection(), event.getPrivateCollection(), arguments.params );
			}

			// Prepare the event if it has a module + event arguments
			arguments.event = ( len( targetModule ) ? "#targetModule#:" : "" );
			arguments.eventArguments = arguments.params;

			// Do we have an event to execute?
			if( len( foundRoute.event ) ){
				arguments.event &= foundRoute.event;
				return runEvent( argumentCollection=arguments );
			}

			// If not, do we have a handler + action combo?
			if( len( foundRoute.handler ) ){
				arguments.event &= foundRoute.handler & "." & ( len( foundRoute.action ) ? foundRoute.action : "index" );
				return runEvent( argumentCollection=arguments );
			}

			throw(
				type 		= "InvalidArgumentException",
				message  	= "The named route '#arguments.name#' has not executable"
			);
		}

		throw(
			type 		= "InvalidArgumentException",
			message  	= "The named route '#arguments.name#' does not exist"
		);

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
		// Determine if we need to cache handler response
		var isCachingOn = getSetting( "eventCaching" ) && arguments.cache;

		// Check if event empty, if empty then use default event
		if( NOT len( trim( arguments.event ) ) ){
			arguments.event = services.requestService.getContext().getCurrentEvent();
		}

		if( isCachingOn ){
			// Build cache references
			var oCache 			= variables.cachebox.getCache( arguments.cacheProvider );
			var oEventURLFacade = oCache.getEventURLFacade();
			var cacheKey 		= oEventURLFacade.buildBasicCacheKey(
				keySuffix 	= arguments.cacheSuffix,
				targetEvent = arguments.event
			) & hash( arguments.eventArguments.toString() );

			// Test if entry found in cache, and return if found.
			var data = oCache.get( cacheKey );
			if( !isNull( local.data ) ){
				return data;
			}
		}

		// Execute our event
		var results = _runEvent( argumentCollection=arguments );

		// Do we have an object coming back?
		if(
			!isNull( results.data ) &&
			isObject( results.data  )
		){
			// Ignore, if request context
			if( isInstanceOf( results.data, "coldbox.system.web.context.RequestContext" )){
				results.delete( "data" );
			}
			else if( structKeyExists( results.data, "$renderdata" ) ){
				results.data = results.data.$renderdata();
			}
		}

		// Do we need to do action renderings?
		if( !isNull( results.data ) &&
			results.ehBean.getActionMetadata( "renderdata", "html" ) neq "html"
		){
			// Do action Rendering
			services.requestService.getContext()
				.renderdata(
					type = results.ehBean.getActionMetadata( "renderdata" ),
					data = results.data
				);
		}

		// Are we caching
		if( isCachingOn && !isNull( results.data ) ){
			oCache.set(
				objectKey			= cacheKey,
				object 				= results.data,
				timeout 			= arguments.cacheTimeout,
				lastAccessTimeout 	= arguments.cacheLastAccessTimeout
			);
		}

		// Are we returning data?
		if( !isNull( results.data ) ){
			return results.data;
		}
	}

	/**
	* Executes events with full life-cycle methods and returns the event results if any were returned
	*
	* @event The event string to execute, if nothing is passed we will execute the application's default event.
	* @prePostExempt If true, pre/post handlers will not be fired. Defaults to false
	* @private Execute a private event if set, else defaults to public events
	* @defaultEvent The flag that let's this service now if it is the default event running or not. USED BY THE FRAMEWORK ONLY
	* @eventArguments A collection of arguments to passthrough to the calling event handler method
	*
	* @throws InvalidHTTPMethod
	*
	* @return struct { data:event handler returned data (null), ehBean:event handler bean representation that was fired }
	*/
	private function _runEvent(
		event="",
		boolean prePostExempt=false,
		boolean private=false,
		boolean defaultEvent=false,
		struct eventArguments={}
	){
		var oRequestContext = services.requestService.getContext();
		var results 		= {
			"data" 		= javaCast( "null", "" ),
			"ehBean" 	= ""
		};

		// Setup Invoker args
		var args = {
			event 			= oRequestContext,
			rc 				= oRequestContext.getCollection(),
			prc 			= oRequestContext.getPrivateCollection(),
			eventArguments  = arguments.eventArguments
		};

		// Setup Main Invoker Args with event arguments
		var argsMain = {
			event 			= oRequestContext,
			rc 				= args.rc,
			prc 			= args.prc
		};
		structAppend( argsMain, arguments.eventArguments );

		// Setup interception data
		var iData = {
			"processedEvent" = arguments.event,
			"eventArguments" = arguments.eventArguments
		};

		// Validate the incoming event and get a handler bean to continue execution
		results.ehBean = services.handlerService
			.getHandlerBean( arguments.event )
			.setIsPrivate( arguments.private );

		// Validate this is not a view dispatch, else return for rendering
		if( results.ehBean.getViewDispatch() ){
			return results;
		}

		// Now get the correct handler to execute
		var oHandler = services.handlerService.getHandler( results.ehBean, oRequestContext );

		// Validate again this is not a view dispatch as the handler might exist but not the action
		if( results.ehBean.getViewDispatch() ){	return results;	}

		try{
			// Determine allowed methods in action metadata
			if( structKeyExists( results.ehBean.getActionMetadata() , "allowedMethods" ) ){
				// incorporate it to the handler
				oHandler.allowedMethods[ results.ehBean.getMethod() ] = results.ehBean.getActionMetadata( "allowedMethods" );
			}

			// Determine if it is An allowed HTTP method to execute, else throw error
			if(
				arguments.defaultEvent AND
				NOT structIsEmpty( oHandler.allowedMethods ) AND
				structKeyExists( oHandler.allowedMethods, results.ehBean.getMethod() ) AND
				NOT listFindNoCase( oHandler.allowedMethods[ results.ehBean.getMethod() ], oRequestContext.getHTTPMethod() )
			){
                oRequestContext.setHTTPHeader(
					statusCode = 405,
					statusText = "Invalid HTTP Method: '#oRequestContext.getHTTPMethod()#'"
				);
				// set Invalid HTTP method in context
				oRequestContext.setIsInvalidHTTPMethod();
				// Do we have a local handler for this exception, if so, call it
				if( oHandler._actionExists( "onInvalidHTTPMethod" ) ){
					results.data = oHandler.onInvalidHTTPMethod(
						event			= oRequestContext,
						rc				= args.rc,
						prc				= args.prc,
						faultAction		= results.ehBean.getmethod(),
						eventArguments	= arguments.eventArguments
					);
					return results;
				}

				// Do we have the invalidHTTPMethodHandler setting? If so, call it.
				if( len( getSetting( "invalidHTTPMethodHandler" ) ) ){
					return _runEvent( event = getSetting( "invalidHTTPMethodHandler" ) );
				}

				// Throw Exception, no handlers defined
				throw(
					message		= "Invalid HTTP Method: '#oRequestContext.getHTTPMethod()#'",
					detail		= "The requested event: #arguments.event# cannot be executed using the incoming HTTP request method '#oRequestContext.getHTTPMethod()#'",
					type		= "InvalidHTTPMethod"
				);
			}

			// SES Invalid HTTP Routing
			if( arguments.defaultEvent && oRequestContext.isInvalidHTTPMethod() ){
				// Do we have a local handler for this exception, if so, call it
				if( oHandler._actionExists( "onInvalidHTTPMethod" ) ){
					results.data = oHandler.onInvalidHTTPMethod(
						event			= oRequestContext,
						rc				= args.rc,
						prc				= args.prc,
						faultAction		= results.ehBean.getmethod(),
						eventArguments	= arguments.eventArguments
					);
					return results;
				}

				// Do we have the invalidHTTPMethodHandler setting? If so, call it.
				if( len( getSetting( "invalidHTTPMethodHandler" ) ) ){
					return _runEvent( event = getSetting( "invalidHTTPMethodHandler" ) );
				}

				// Throw Exception, no handlers defined
				oRequestContext.setHTTPHeader(
					statusCode = 405,
					statusText = "Invalid HTTP Method: '#oRequestContext.getHTTPMethod()#'"
				);
				throw(
					message		= "Invalid HTTP Method: '#oRequestContext.getHTTPMethod()#'",
					detail		= "The requested URL: #oRequestContext.getCurrentRoutedURL()# cannot be executed using the incoming HTTP request method '#oRequestContext.getHTTPMethod()#'",
					type		= "InvalidHTTPMethod"
				);
			}

			// PRE ACTIONS
			if( NOT arguments.prePostExempt ){

				// PREEVENT Interceptor
				services.interceptorService.processState( "preEvent", iData );

				// Verify if event was overriden
				if( arguments.event NEQ iData.processedEvent ){
					// Validate the overriden event
					results.ehBean = services.handlerService.getHandlerBean( iData.processedEvent );
					// Get new handler to follow execution
					oHandler = services.handlerService.getHandler( results.ehBean, oRequestContext );
				}

				// Execute Pre Handler if it exists and valid?
				if( oHandler._actionExists( "preHandler" ) AND
					validateAction( results.ehBean.getMethod(), oHandler.PREHANDLER_ONLY, oHandler.PREHANDLER_EXCEPT )
				){
					oHandler.preHandler(
						event          = oRequestContext,
						rc             = args.rc,
						prc            = args.prc,
						action         = results.ehBean.getMethod(),
						eventArguments = arguments.eventArguments
					);
				}

				// Execute pre{Action}? if it exists and valid?
				if( oHandler._actionExists( "pre#results.ehBean.getMethod()#" ) ){
					invoker( target=oHandler, method="pre#results.ehBean.getMethod()#", argCollection=args );
				}
			}

			// Verify if event was overriden
			if( arguments.defaultEvent and arguments.event NEQ oRequestContext.getCurrentEvent() ){
				// Validate the overriden event
				results.ehBean = services.handlerService.getHandlerBean( oRequestContext.getCurrentEvent() );
				// Get new handler to follow execution
				oHandler = services.handlerService.getHandler( results.ehBean, oRequestContext );
			}

			// Invoke onMissingAction event
			if( results.ehBean.isMissingAction() ){
				results.data	= oHandler.onMissingAction(
					event          = oRequestContext,
					rc             = args.rc,
					prc            = args.prc,
					missingAction  = results.ehBean.getMissingAction(),
					eventArguments = arguments.eventArguments
				);
			}
			// Invoke main event
			else{

				// Around {Action} Advice Check?
				if( oHandler._actionExists( "around#results.ehBean.getMethod()#" ) ){
					// Add target Action
					args.targetAction = oHandler[ results.ehBean.getMethod() ];
					results.data = invoker(
						target        = oHandler,
						method        = "around#results.ehBean.getMethod()#",
						argCollection = args
					);
					// Cleanup: Remove target action from args for post events
					structDelete( args, "targetAction" );
				}
				// Around Handler Advice Check?
				else if(
					!arguments.prePostExempt
					&&
					oHandler._actionExists( "aroundHandler" )
					&&
					validateAction( results.ehBean.getMethod(), oHandler.aroundHandler_only, oHandler.aroundHandler_except )
				){
					results.data = oHandler.aroundHandler(
						event          = oRequestContext,
						rc             = args.rc,
						prc            = args.prc,
						targetAction   = oHandler[ results.ehBean.getMethod() ],
						eventArguments = arguments.eventArguments
					);
				} else {
					// Normal execution
					results.data = invoker(
						target        = oHandler,
						method        = results.ehBean.getMethod(),
						argCollection = argsMain,
						private       = arguments.private
					);
				}
			}

			// POST ACTIONS
			if( NOT arguments.prePostExempt ){

				// Execute post{Action}?
				if( oHandler._actionExists( "post#results.ehBean.getMethod()#" ) ){
					invoker(
						target        = oHandler,
						method        = "post#results.ehBean.getMethod()#",
						argCollection = args
					);
				}

				// Execute postHandler()?
				if(
					oHandler._actionExists( "postHandler" ) AND
					validateAction( results.ehBean.getMethod(), oHandler.POSTHANDLER_ONLY, oHandler.POSTHANDLER_EXCEPT )
				){
					oHandler.postHandler(
						event          = oRequestContext,
						rc             = args.rc,
						prc            = args.prc,
						action         = results.ehBean.getMethod(),
						eventArguments = arguments.eventArguments);
				}

				// Execute postEvent interceptor
				services.interceptorService.processState( "postEvent", iData );

			}// end if prePostExempt
		} catch( any e ){
			// onError convention
			if( oHandler._actionExists( "onError" ) ){
				results.data = oHandler.onError(
					event          = oRequestContext,
					rc             = args.rc,
					prc            = args.prc,
					faultAction    = results.ehBean.getmethod(),
					exception      = e,
					eventArguments = arguments.eventArguments);
			} else {
				// Bubble up the error
				rethrow;
			}
		}

		return results;
	}

	/****************************************** APPLICATION LOCATORS *************************************************/

	/**
	* Locate the real path location of a file in a coldbox application. 3 checks: 1) inside of coldbox app, 2) expand the path, 3) Absolute location. If path not found, it returns an empty path
	* @pathToCheck The relative or absolute file path to verify and locate
	*/
	function locateFilePath( required pathToCheck ){
		var foundPath 	= "";

		//Check 1: Inside of App Root
		if ( fileExists( variables.appRootPath & arguments.pathToCheck) ){
			foundPath = variables.appRootPath & arguments.pathToCheck;
		}
		//Check 2: Expand the Path
		else if( fileExists( expandPath( arguments.pathToCheck ) ) ){
			foundPath = expandPath( arguments.pathToCheck );
		}
		//Check 3: Absolute Path
		else if( fileExists( arguments.pathToCheck ) ){
			foundPath = arguments.pathToCheck;
		}

		//Return
		return foundPath;
	}

	/**
	* Locate the real path location of a directory in a coldbox application. 3 checks: 1) inside of coldbox app, 2) expand the path, 3) Absolute location. If path not found, it returns an empty path
	* @pathToCheck The relative or absolute directory path to verify and locate
	*/
	function locateDirectoryPath( required pathToCheck ){
		var foundPath = "";

		//Check 1: Inside of App Root
		if ( directoryExists( variables.appRootPath & arguments.pathToCheck) ){
			foundPath = variables.appRootPath & arguments.pathToCheck;
		}
		//Check 2: Expand the Path
		else if( directoryExists( expandPath(arguments.pathToCheck) ) ){
			foundPath = expandPath( arguments.pathToCheck );
		}
		//Check 3: Absolute Path
		else if( directoryExists( arguments.pathToCheck ) ){
			foundPath = arguments.pathToCheck;
		}

		//Return
		return foundPath;
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
		this.relocate( argumentCollection=arguments );
	}

/****************************************** PRIVATE HELPERS *************************************************/

	/**
	* Load the internal ColdBox settings
	*/
	private function loadColdBoxSettings(){
		// Setup metadata paths
		variables.coldboxSettings[ "ApplicationPath" ] 		= getAppRootPath();
		variables.coldboxSettings[ "FrameworkPath" ] 		= expandPath( "/coldbox/system" ) & "/";
		variables.coldboxSettings[ "ConfigFileLocation" ] 	= "";

		// Update settings with default values
		structAppend( variables.coldboxSettings, new coldbox.system.web.config.Settings(), true );
	}

	/**
	* Internal helper to flash persist elements
	* @return Controller
	*/
	private function persistVariables( persist="", struct persistStruct={} ){
		var flash = getRequestService().getFlashScope();

		// persist persistStruct if passed
		if( structKeyExists( arguments, "persistStruct") ){
			flash.putAll( map=arguments.persistStruct, saveNow=true );
		}

		// Persist RC keys if passed.
		if( len( trim( arguments.persist ) ) ){
			flash.persistRC( include=arguments.persist, saveNow=true);
		}

		return this;
	}

	/**
	* Checks if an action can be executed according to inclusion/exclusion lists
	* @action The action to validate
	* @inclusion The list of inclusions
	* @exclusion The list of exclusions
	*/
	private boolean function validateAction( required action, inclusion="", exclusion="" ){
		if( (
				( len( arguments.inclusion ) AND listfindnocase( arguments.inclusion, arguments.action ) )
			     OR
			    ( NOT len( arguments.inclusion ) )
			 )
			 AND
			 ( listFindNoCase( arguments.exclusion, arguments.action ) EQ 0 )
		){
			return true;
		}
		return false;
	}

	/**
	* Invoke private/public event handler methods
	*/
	private function invoker(
		required any target,
		required method,
		struct argCollection={},
		boolean private=false
	){
		if( arguments.private ){
			return arguments.target._privateInvoker( method=arguments.method, argCollection=arguments.argCollection );
		}
		return invoke( arguments.target, arguments.method, arguments.argCollection );
	}

	/**
	* Send a CF relocation
	*/
	private function sendRelocation( required URL, boolean addToken=false, statusCode=0 ){
		if( arguments.statusCode neq 0 ){
			location( url="#arguments.url#", addtoken="#addtoken#", statuscode="#arguments.statusCode#" );
		} else {
			location( url="#arguments.url#", addtoken="#addtoken#" );
		}
		return this;
	}

	/**
	* Update SSL or not on a request string
	*/
	private string function updateSSL( required inURL, required ssl ){
		// Check SSL?
		return ( arguments.ssl ? replacenocase( arguments.inURL, "http:", "https:" ) : replacenocase( arguments.inURL, "https:", "http:" ) );
	}

}
