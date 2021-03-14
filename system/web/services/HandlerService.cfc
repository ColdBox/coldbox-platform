/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * This service takes care of all event handling in ColdBox
 */
component extends="coldbox.system.web.services.BaseService" accessors="true" {

	/**
	 * Handler cache metadata dictionary
	 */
	property name="handlerCacheDictionary" type="struct";

	/**
	 * Event caching metadata dictionary
	 */
	property name="eventCacheDictionary" type="struct";

	/**
	 * Flag to denote handler caching
	 */
	property name="handlerCaching" type="boolean";

	/**
	 * Flag to denote event caching
	 */
	property name="eventCaching" type="boolean";

	/**
	 * Handler bean cache dictionary
	 */
	property name="handlerBeanCacheDictionary" type="struct";

	/**
	 * Constructor
	 *
	 * @controller ColdBox Controller
	 */
	function init( required controller ){
		// controlle + wirebox references
		variables.controller = arguments.controller;

		// Setup the Event Handler Cache Dictionary
		variables.handlerCacheDictionary     = {};
		// Setup the Event Cache Dictionary
		variables.eventCacheDictionary       = {};
		// Setup the Handler Bean Cache Dictionary
		variables.handlerBeanCacheDictionary = {};

		return this;
	}

	/**
	 * Once configuration file loads setup the services with app specific variables
	 */
	function onConfigurationLoad(){
		// local logger
		variables.log = controller.getLogBox().getLogger( this );

		// execute the handler registrations after configurations loaded
		registerHandlers();

		// Configuration data and dependencies
		variables.eventAction                = controller.getColdBoxSetting( "EventAction" );
		variables.registeredHandlers         = controller.getSetting( "RegisteredHandlers" );
		variables.registeredExternalHandlers = controller.getSetting( "RegisteredExternalHandlers" );
		variables.eventName                  = controller.getSetting( "EventName" );
		variables.invalidEventHandler        = controller.getSetting( "invalidEventHandler" );
		variables.handlerCaching             = controller.getSetting( "HandlerCaching" );
		variables.eventCaching               = controller.getSetting( "EventCaching" );
		variables.handlersInvocationPath     = controller.getSetting( "HandlersInvocationPath" );
		variables.handlersExternalLocation   = controller.getSetting( "HandlersExternalLocation" );
		variables.templateCache              = controller.getCache( "template" );
		variables.modules                    = controller.getSetting( "modules" );
		variables.interceptorService         = controller.getInterceptorService();
		variables.wirebox                    = controller.getWireBox();
	}

	/**
	 * Asks wirebox for an instance of a handler.  It verifies that there is a mapping in Wirebox for the handler
	 * if it does not exist, it maps it first and then retrieves it.
	 *
	 * @invocationPath The handler invocation path
	 *
	 * @return Handler Instance
	 */
	function newHandler( required invocationPath ){
		// Check if handler already mapped?
		if ( NOT wirebox.getBinder().mappingExists( arguments.invocationPath ) ) {
			// lazy load checks for wirebox
			wireboxSetup();
			// feed this handler to wirebox with virtual inheritance just in case, use registerNewInstance so its thread safe
			var mapping = wirebox
				.registerNewInstance( name = arguments.invocationPath, instancePath = arguments.invocationPath )
				.setVirtualInheritance( "coldbox.system.EventHandler" )
				.addDIConstructorArgument( name = "controller", value = controller )
				.setThreadSafe( true )
				.setScope(
					variables.handlerCaching ? wirebox.getBinder().SCOPES.SINGLETON : wirebox.getBinder().SCOPES.NOSCOPE
				)
				.setCacheProperties( key = "handlers-#arguments.invocationPath#" )
				// extra attributes added to mapping so they are relayed by events
				.setExtraAttributes( {
					handlerPath : arguments.invocationPath,
					isHandler   : true
				} );
		}

		// retrieve, build and wire from wirebox
		var handler = wirebox.getInstance( arguments.invocationPath );

		// Is this a rest handler by annotation? If so, incorporate it's methods
		if (
			wirebox
				.getBinder()
				.getMapping( arguments.invocationPath )
				.getObjectMetadata()
				.keyExists( "restHandler" )
			&&
			!structKeyExists( handler, "restHandler" )
		) {
			structEach( wirebox.getInstance( "coldbox.system.RestHandler" ), function( functionName, functionTarget ){
				if ( !structKeyExists( handler, functionName ) ) {
					handler[ functionName ] = functionTarget;
				}
			} );
		}

		return handler;
	}

	/**
	 * Get a validated handler instance using an event handler bean and context. This is called
	 * once event execution is in progress.
	 * Before returning this method verifies method of execution, event caching, invalid events and stores metadata
	 *
	 * @ehBean The event handler bean representation
	 * @requestContext The request context object
	 *
	 * @return The event handler object represented by the ehBean
	 */
	function getHandler( required ehBean, required requestContext ){
		var oRequestContext = arguments.requestContext;
		var oEventURLFacade = variables.templateCache.getEventURLFacade();

		// Create Runnable Object via WireBox
		var oEventHandler = newHandler( arguments.ehBean.getRunnable() );

		/* ::::::::::::::::::::::::::::::::::::::::: EVENT METHOD TESTING :::::::::::::::::::::::::::::::::::::::::::: */

		// Does requested method/action of execution exist in handler?
		if ( NOT oEventHandler._actionExists( arguments.ehBean.getMethod() ) ) {
			// Check if the handler has an onMissingAction() method, virtual Events
			if ( oEventHandler._actionExists( "onMissingAction" ) ) {
				// Override the method of execution
				arguments.ehBean.setMissingAction( arguments.ehBean.getMethod() );
				// Let's go execute our missing action
				return oEventHandler;
			}

			// Test for Implicit View Dispatch
			if (
				controller.getSetting( "ImplicitViews" ) AND
				isViewDispatch( arguments.ehBean.getFullEvent(), arguments.ehBean )
			) {
				return oEventHandler;
			}

			// The handler exists but the action requested does not, let's go into invalid execution mode
			var targetInvalidEvent = invalidEvent( arguments.ehBean.getFullEvent(), arguments.ehBean );

			// If we get here, then the invalid event kicked in and exists, else an exception is thrown above
            // set the invalid event handler as the current event
            oRequestContext.overrideEvent( targetInvalidEvent );
			// Go retrieve the handler that will handle the invalid event so it can execute.
			return getHandler( getHandlerBean( targetInvalidEvent ), oRequestContext );
		}
		// method check finalized.

		// Store metadata in execution bean
		if ( !variables.handlerCaching || !arguments.ehBean.isMetadataLoaded() ) {
			arguments.ehBean
				.setActionMetadata( oEventHandler._actionMetadata( arguments.ehBean.getMethod() ) )
				.setHandlerMetadata( getMetadata( oEventHandler ) );
		}

		/* ::::::::::::::::::::::::::::::::::::::::: EVENT CACHING :::::::::::::::::::::::::::::::::::::::::::: */

		// Event Caching Routines, if using caching, NOT a private event and we are executing the main event
		if (
			variables.eventCaching AND
			!arguments.ehBean.getIsPrivate() AND
			arguments.ehBean.getFullEvent() EQ oRequestContext.getCurrentEvent()
		) {
			// Get event action caching metadata
			var eventDictionaryEntry = getEventCachingMetadata( arguments.ehBean, oEventHandler );

			// Do we need to cache this event's output after it executes??
			if ( eventDictionaryEntry.cacheable ) {
				// Create caching data structure according to MD, as the cache key can be dynamic by execution.
				var eventCachingData = {};
				structAppend(
					eventCachingData,
					eventDictionaryEntry,
					true
				);

				// Create the Cache Key to save
				eventCachingData.cacheKey = oEventURLFacade.buildEventKey(
					keySuffix     = eventDictionaryEntry.suffix,
					targetEvent   = arguments.ehBean.getFullEvent(),
					targetContext = oRequestContext
				);

				// Event is cacheable and we need to flag it so the Renderer caches it
				oRequestContext.setEventCacheableEntry( eventCachingData );
			}
			// end if md says that this event is cacheable
		}
		// end if event caching.

		// return the tested and validated event handler
		return oEventHandler;
	}

	/**
	 * Parse the incoming event string into an event handler bean that is used for the current execution context
	 *
	 * @event The full event string
	 *
	 * @return coldbox.system.web.context.EventHandlerBean
	 */
	function getHandlerBean( required string event ){
		// bean already in cache?
		if ( variables.handlerCaching && structKeyExists( variables.handlerBeanCacheDictionary, arguments.event ) ) {
			return variables.handlerBeanCacheDictionary[ arguments.event ];
		}

		// New event, prepare it
		var handlersList         = variables.registeredHandlers;
		var handlersExternalList = variables.registeredExternalHandlers;
		var oHandlerBean         = new coldbox.system.web.context.EventHandlerBean( variables.handlersInvocationPath );
		var moduleSettings       = variables.modules;

		// Rip the handler and method
		var handlerReceived = listLast( reReplace( arguments.event, "\.[^.]*$", "" ), ":" );
		var methodReceived  = listLast( arguments.event, "." );

		// Verify if this is a module call
		if ( find( ":", arguments.event ) ) {
			var moduleReceived = listFirst( arguments.event, ":" );
			// Does this module exist?
			if ( structKeyExists( moduleSettings, moduleReceived ) ) {
				// Verify handler in module handlers
				var handlerIndex = listFindNoCase(
					moduleSettings[ moduleReceived ].registeredHandlers,
					handlerReceived
				);
				if ( handlerIndex ) {
					// Prepare bean data
					oHandlerBean
						.setInvocationPath( moduleSettings[ moduleReceived ].handlerInvocationPath )
						.setHandler( listGetAt( moduleSettings[ moduleReceived ].registeredHandlers, handlerIndex ) )
						.setMethod( methodReceived )
						.setModule( moduleReceived );

					// put bean in cache if enabled
					if ( variables.handlerCaching ) {
						variables.handlerBeanCacheDictionary[ arguments.event ] = oHandlerBean;
					}

					return oHandlerBean;
				} else {
					variables.log.error(
						"Invalid Module (#moduleReceived#) Handler: #handlerReceived#. Valid handlers are #moduleSettings[ moduleReceived ].registeredHandlers#"
					);
				}
			}

			// Log Error
			variables.log.error(
				"Invalid Module Event Called: #arguments.event#. The module: #moduleReceived# is not valid. Valid Modules are: #structKeyList( moduleSettings )#"
			);
		} else {
			// Try to do list localization in the registry for full event string.
			var handlerIndex = listFindNoCase( handlersList, handlerReceived );
			// Check for conventions location
			if ( handlerIndex ) {
				// Prepare bean data
				oHandlerBean
					.setHandler( listGetAt( handlersList, handlerIndex ) )
					.setMethod( MethodReceived );

				// put bean in cache if enabled
				if ( variables.handlerCaching ) {
					variables.handlerBeanCacheDictionary[ arguments.event ] = oHandlerBean;
				}

				return oHandlerBean;
			}

			// Check for external location
			handlerIndex = listFindNoCase( handlersExternalList, handlerReceived );
			if ( handlerIndex ) {
				// Prepare bean data
				oHandlerBean
					.setInvocationPath( variables.handlersExternalLocation )
					.setHandler( listGetAt( handlersExternalList, handlerIndex ) )
					.setMethod( MethodReceived );

				// put bean in cache if enabled
				if ( variables.handlerCaching ) {
					variables.handlerBeanCacheDictionary[ arguments.event ] = oHandlerBean;
				}

				return oHandlerBean;
			}
		}
		// end else

		// Do View Dispatch Check Procedures
		if ( isViewDispatch( arguments.event, oHandlerBean ) ) {
			// put bean in cache if enabled
			if ( variables.handlerCaching ) {
				variables.handlerBeanCacheDictionary[ arguments.event ] = oHandlerBean;
			}
			return oHandlerBean;
		}

		// Run invalid event procedures, handler not found as a module or in all lists
		arguments.event = invalidEvent( arguments.event, oHandlerBean );

		// If we get here, then invalid event handler is active and we need to
		// return an event handler bean that matches it
		return getHandlerBean( arguments.event );
	}

	/**
	 * Do a default action checks on the incoming event string. This method matches it against
	 * the internal handlers list.  If found, then we append the default action to the event.
	 *
	 * @event The request context
	 *
	 * @return HandlerService
	 */
	function defaultActionCheck( required event ){
		var handlersList         = variables.registeredHandlers;
		var handlersExternalList = variables.registeredExternalHandlers;
		var currentEvent         = arguments.event.getCurrentEvent();
		var modulesConfig        = variables.modules;

		// Module Check?
		if ( find( ":", currentEvent ) ) {
			var module = listFirst( currentEvent, ":" );
			if (
				structKeyExists( modulesConfig, module ) AND
				listFindNoCase(
					modulesConfig[ module ].registeredHandlers,
					reReplaceNoCase( currentEvent, "^([^:.]*):", "" )
				)
			) {
				// Append the default event action
				currentEvent = currentEvent & "." & variables.eventAction;
				// Save it as the current Event
				event.setValue( variables.eventName, currentEvent );
			}
			return this;
		}

		// Do a Default Action Test First, if default action desired.
		if (
			listFindNoCase( handlersList, currentEvent ) OR
			listFindNoCase( handlersExternalList, currentEvent )
		) {
			// Append the default event action
			currentEvent = currentEvent & "." & variables.eventAction;
			// Save it as the current Event now with the default action
			event.setValue( variables.eventName, currentEvent );
		}

		return this;
	}
	/**
	 * Check if the incoming event has a matching implicit view to dispatch. This is usually called
	 * when there is no existing handler found.
	 *
	 * @event The event string
	 * @ehBean The event handler bean
	 */
	boolean function isViewDispatch( required string event, required ehBean ){
		// Cleanup for modules
		var cEvent       = reReplaceNoCase( arguments.event, "^([^:.]*):", "" );
		var renderer     = controller.getRenderer();
		var targetView   = "";
		var targetModule = getToken( arguments.event, 1, ":" );

		// Cleanup of . to / for lookups for path locating
		cEvent = lCase( replace( cEvent, ".", "/", "all" ) );

		// module?
		if ( find( ":", arguments.event ) ) {
			// Validate that it is a valid module, else it is an invalid view.
			if ( structKeyExists( variables.modules, targetModule ) ) {
				targetView = renderer.locateModuleView( cEvent, targetModule );
			} else {
				return false;
			}
		} else {
			targetView = renderer.locateView( cEvent );
		}

		// Validate Target View
		if ( fileExists( expandPath( targetView & ".cfm" ) ) ) {
			arguments.ehBean.setViewDispatch( true );
			return true;
		}

		return false;
	}

	/**
	 * Invalid Event procedures. An invalid event is detected, so this method
	 * will verify if the application has an invalidEventHandler or an interceptor
	 * listening to `onInvalidEvent` modifies the handler bean.  Then this method will
	 * either return the invalid event handler event, or set an exception to be captured.
	 *
	 * @event The event that was found to be invalid
	 * @ehBean The event handler bean representing the invalid event
	 *
	 * @throws EventHandlerNotRegisteredException,InvalidEventHandlerException
	 *
	 * @return The string event that should be executed as the invalid event handler or throws an EventHandlerNotRegisteredException
	 */
	string function invalidEvent( required string event, required ehBean ){
		// Announce it
		var iData = {
			"invalidEvent" : arguments.event,
			"ehBean"       : arguments.ehBean,
			"override"     : false
		};
		variables.interceptorService.announce( "onInvalidEvent", iData );

		// If the override was changed by the interceptors then they updated the ehBean of execution
		if ( iData.override ) {
			return ehBean.getFullEvent();
		}

		// Param our last invalid event just incase
		param request._lastInvalidEvent = "";

		// If invalidEventHandler is registered, use it
		if ( len( variables.invalidEventHandler ) ) {
			// Test for invalid Event Error as well so we don't go in an endless error loop
			if (
				compareNoCase( arguments.event, request._lastInvalidEvent ) eq 0
				&&
				!structKeyExists( controller, "mockController" ) // Verify this is a real and not a mock controller.
			) {
				var exceptionMessage = "The invalidEventHandler event (#variables.invalidEventHandler#) is also invalid: #arguments.event#";
				// Extra Debugging for illusive CI/Tests exceptions: Remove at one point if discovered.
				variables.log.error( exceptionMessage, {
					event              : arguments.event,
					registeredHandlers : variables.registeredHandlers,
					fullEvent          : ehBean.getFullEvent()
				} );
				// Now throw the exception
				throw(
					message : exceptionMessage,
					type    : "HandlerService.InvalidEventHandlerException"
				);
			}

			// we save off this event in case there is problem matching our invalidEventHandler.
			// This way we can catch infinite loops instead of having a Stack Overflow error.
			request._lastInvalidEvent = arguments.event;

			// Store Invalid Event in PRC
			controller
				.getRequestService()
				.getContext()
				.setPrivateValue( "invalidevent", arguments.event );

			// Override Event With On invalid handler event
			return variables.invalidEventHandler;
		} // end invalidEventHandler found

		// If we got here, we have an invalid event and no override, throw a 404 ERROR
		controller
			.getRequestService()
			.getContext()
			.setHTTPHeader( statusCode = 404, statusText = "Not Found" );

		// Invalid Event Detected, log it in the Application log, not a coldbox log but an app log
		variables.log.error(
			"Invalid Event detected: #arguments.event#. Path info: #CGI.PATH_INFO#, query string: #CGI.QUERY_STRING#"
		);

		// Throw Exception
		throw(
			message : "The event: #arguments.event# is not a valid registered event.",
			type    : "EventHandlerNotRegisteredException"
		);
	}

	/**
	 * Register's application event handlers according to convention and external paths
	 *
	 * @throws HandlersDirectoryNotFoundException
	 *
	 * @return HandlerService
	 */
	function registerHandlers(){
		var handlersPath                 = controller.getSetting( "handlersPath" );
		var handlersExternalLocationPath = controller.getSetting( "handlersExternalLocationPath" );
		var handlersExternalArray        = [];

		/* ::::::::::::::::::::::::::::::::::::::::: HANDLERS BY CONVENTION :::::::::::::::::::::::::::::::::::::::::::: */

		// Get recursive Array listing
		var handlerArray = getHandlerListing( handlersPath );

		// Set registered Handlers
		variables.registeredHandlers = arrayToList( handlerArray );
		controller.setSetting( name = "registeredHandlers", value = variables.registeredHandlers );

		/* ::::::::::::::::::::::::::::::::::::::::: EXTERNAL HANDLERS :::::::::::::::::::::::::::::::::::::::::::: */

		if ( len( handlersExternalLocationPath ) ) {
			// Check for handlers Directory Location
			if ( !directoryExists( handlersExternalLocationPath ) ) {
				throw(
					message = "The external handlers directory: #HandlersExternalLocationPath# does not exist please check your application structure.",
					type    = "HandlersDirectoryNotFoundException"
				);
			}

			// Get recursive Array listing
			handlersExternalArray = getHandlerListing( handlersExternalLocationPath );
		}

		// Set registered External Handlers
		variables.registeredExternalHandlers = arrayToList( handlersExternalArray );
		controller.setSetting( name = "registeredExternalHandlers", value = variables.registeredExternalHandlers );

		return this;
	}

	/**
	 * Clear the internal cache dictionaries
	 *
	 * @return HandlerService
	 */
	function clearDictionaries(){
		variables.eventCacheDictionary = {};
		return this;
	}

	/**
	 * Get an event string's metadata entry. If not found, then you will get a new metadata entry using the `getNewMDEntry()` method.
	 *
	 * @targetEvent The event to match for metadata.
	 */
	struct function getEventMetadataEntry( required targetEvent ){
		if ( NOT structKeyExists( variables.eventCacheDictionary, arguments.targetEvent ) ) {
			return getNewMDEntry();
		}

		return variables.eventCacheDictionary[ arguments.targetEvent ];
	}

	/**
	 * Retrieve handler listings from disk
	 *
	 * @directory The path to retrieve
	 */
	array function getHandlerListing( required directory ){
		// Convert windows \ to java /
		arguments.directory = replace( arguments.directory, "\", "/", "all" );

		return directoryList(
			arguments.directory,
			true,
			"array",
			"*.cfc"
		).map( function( item ){
			var thisAbsolutePath = replace( item, "\", "/", "all" );
			var cleanHandler     = replaceNoCase(
				thisAbsolutePath,
				directory,
				"",
				"all"
			);
			// Clean OS separators to dot notation.
			cleanHandler = removeChars(
				replaceNoCase( cleanHandler, "/", ".", "all" ),
				1,
				1
			);
			// Clean Extension
			return controller.getUtil().ripExtension( cleanhandler );
		} );
	}

	/************************************ PRIVATE ************************************/

	/**
	 * Verifies setup of base handler classes in WireBox
	 *
	 * @return HandlerService
	 */
	private function wireboxSetup(){
		if ( NOT wirebox.getBinder().mappingExists( "coldbox.system.EventHandler" ) ) {
			wirebox
				.registerNewInstance(
					name         = "coldbox.system.EventHandler",
					instancePath = "coldbox.system.EventHandler"
				)
				.addDIConstructorArgument( name = "controller", value = controller );
		}
		if ( NOT wirebox.getBinder().mappingExists( "coldbox.system.RestHandler" ) ) {
			wirebox
				.registerNewInstance(
					name         = "coldbox.system.RestHandler",
					instancePath = "coldbox.system.RestHandler"
				)
				.addDIConstructorArgument( name = "controller", value = controller );
		}
		return this;
	}

	/**
	 * Return a new metadata struct object
	 *
	 * @return { cacheable:boolean, timeout, lastAccessTimeout, cacheKey, suffix }
	 */
	private struct function getNewMDEntry(){
		return {
			"cacheable"         : false,
			"timeout"           : "",
			"lastAccessTimeout" : "",
			"cacheKey"          : "",
			"suffix"            : "",
			"provider"          : "template"
		};
	}

	/**
	 * Return the event caching metadata for an action execution context.
	 *
	 * @ehBean The event handler bean
	 * @oEventHandler The event handler to execute
	 *
	 * @return strc
	 */
	private struct function getEventCachingMetadata( required ehBean, required oEventHandler ){
		var cacheKey = arguments.ehBean.getFullEvent();

		// Double lock for race conditions
		if ( !structKeyExists( variables.eventCacheDictionary, cacheKey ) ) {
			lock
				name          ="handlerservice.#controller.getAppHash()#.eventcachingmd.#cacheKey#"
				type          ="exclusive"
				throwontimeout="true"
				timeout       ="10" {
				if ( !structKeyExists( variables.eventCacheDictionary, cacheKey ) ) {
					// Get New Default MD Entry
					var mdEntry = getNewMDEntry();

					// Cache Entries for timeout and last access timeout
					if ( arguments.ehBean.getActionMetadata( "cache", false ) ) {
						mdEntry.cacheable         = true;
						mdEntry.timeout           = arguments.ehBean.getActionMetadata( "cacheTimeout", "" );
						mdEntry.lastAccessTimeout = arguments.ehBean.getActionMetadata(
							"cacheLastAccessTimeout",
							""
						);
						mdEntry.provider = arguments.ehBean.getActionMetadata( "cacheProvider", "template" );

						// Handler Event Cache Key Suffix, this is global to the event
						if (
							isClosure( arguments.oEventHandler.EVENT_CACHE_SUFFIX ) || isCustomFunction(
								arguments.oEventHandler.EVENT_CACHE_SUFFIX
							)
						) {
							mdEntry.suffix = oEventHandler.EVENT_CACHE_SUFFIX( arguments.ehBean );
						} else {
							mdEntry.suffix = arguments.oEventHandler.EVENT_CACHE_SUFFIX;
						}
					}
					// end cache metadata is true

					// Save md Entry in dictionary
					variables.eventCacheDictionary[ cacheKey ] = mdEntry;
				}
				// end of md cache dictionary.
			}
			// end lock
		}
		// end if

		return variables.eventCacheDictionary[ cacheKey ];
	}

}
