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
	 * The default event action
	 */
	property name="eventAction" type="string";

	/**
	 * Handler bean cache dictionary
	 */
	property name="handlerBeanCacheDictionary" type="struct";

	/**
	 * The registered event handlers
	 */
	property name="registeredHandlers" type="struct";

	/**
	 * The external registered event handlers
	 */
	property name="registeredExternalHandlers" type="struct";

	/**
	 * Constructor
	 *
	 * @controller ColdBox Controller
	 */
	function init( required controller ){
		// controller reference
		variables.controller                 = arguments.controller
		// Setup the Event Handler Cache Dictionary
		variables.handlerCacheDictionary     = {}
		// Setup the Event Cache Dictionary
		variables.eventCacheDictionary       = {}
		// Setup the Handler Bean Cache Dictionary
		variables.handlerBeanCacheDictionary = {}
		// Default registries
		variables.registeredHandlers         = {}
		variables.registeredExternalHandlers = {}

		return this
	}

	/**
	 * Once configuration file loads setup the services with app specific variables
	 */
	function onConfigurationLoad(){
		// Configuration data and dependencies
		variables.eventAction                  = variables.controller.getColdBoxSetting( "EventAction" )
		variables.eventCaching                 = variables.controller.getSetting( "EventCaching" )
		variables.eventName                    = variables.controller.getSetting( "EventName" )
		variables.handlerCaching               = variables.controller.getSetting( "HandlerCaching" )
		variables.handlersExternalLocation     = variables.controller.getSetting( "HandlersExternalLocation" )
		variables.handlersExternalLocationPath = variables.controller.getSetting( "handlersExternalLocationPath" )
		variables.handlersInvocationPath       = variables.controller.getSetting( "HandlersInvocationPath" )
		variables.handlersPath                 = variables.controller.getSetting( "handlersPath" )
		variables.interceptorService           = variables.controller.getInterceptorService()
		variables.invalidEventHandler          = variables.controller.getSetting( "invalidEventHandler" )
		variables.modules                      = variables.controller.getSetting( "modules" )
		variables.templateCache                = variables.controller.getCache( "template" )
		variables.wirebox                      = variables.controller.getWireBox()

		// execute the handler registrations after configurations loaded
		registerHandlers()
	}

	/**
	 * Builds a handler according to the passed handler bean modeling data via WireBox.
	 *
	 * @ehBean The handler bean that simulates the executions
	 *
	 * @return EventHandler - A handler Instance matching the ehBean signature
	 */
	function newHandler( required ehBean ){
		// If it's a module, then use the module's injector, else the root injector
		var injector    = arguments.ehBean.isModule() ? variables.modules[ arguments.ehBean.getModule() ].injector : variables.wirebox;
		var handlerPath = arguments.ehBean.getRunnable();

		// Check if handler already mapped in the injector
		if ( NOT injector.getBinder().mappingExists( handlerPath ) ) {
			// lazy load checks for wirebox
			injectorSeedBaseClasses( injector );
			// feed this handler to wirebox with virtual inheritance just in case, use registerNewInstance so its thread safe
			injector
				.registerNewInstance( name = handlerPath, instancePath = handlerPath )
				.setVirtualInheritance( "coldbox.system.EventHandler" )
				.setThreadSafe( true )
				.setScope( variables.handlerCaching ? "singleton" : "NoScope" )
				.setCacheProperties( key = "handlers-#handlerPath#" )
				// extra attributes added to mapping so they are relayed by events
				.setExtraAttributes( { handlerPath : handlerPath, isHandler : true } );
		}

		configureRestHandlerMapping( injector.getBinder().getMapping( handlerPath ), injector );

		// retrieve, build and wire from wirebox
		var handler = injector.getInstance( handlerPath );

		return handler;
	}

	/**
	 * Get a validated handler instance using an event handler bean and context. This is called
	 * once event execution is in progress.
	 * Before returning this method verifies method of execution, event caching, invalid events and stores metadata
	 *
	 * @ehBean         The event handler bean representation
	 * @requestContext The request context object
	 *
	 * @return The event handler object represented by the ehBean
	 */
	function getHandler( required ehBean, required requestContext ){
		var oRequestContext = arguments.requestContext;

		// Create Runnable Object via WireBox
		var oEventHandler = newHandler( arguments.ehBean );

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
			// Invalid Event processing
			return processInvalidEvent( arguments.ehBean, oRequestContext );
		}
		// method check finalized.

		// Store metadata in execution bean
		if ( !variables.handlerCaching || !arguments.ehBean.isMetadataLoaded() ) {
			arguments.ehBean
				.setActionMetadata( oEventHandler._actionMetadata( arguments.ehBean.getMethod() ) )
				.setHandlerMetadata( getMetadata( oEventHandler ) );
		}

		// Are they trying to execute an internal ColdBox method?
		if ( arguments.ehBean.actionMetadataExists( "cbMethod" ) ) {
			// Invalid Event processing
			return processInvalidEvent( arguments.ehBean, oRequestContext );
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
				structAppend( eventCachingData, eventDictionaryEntry, true );

				// Create the Cache Key to save
				eventCachingData.cacheKey = variables.templateCache
					.getEventURLFacade()
					.buildEventKey(
						targetEvent     = arguments.ehBean.getFullEvent(),
						targetContext   = oRequestContext,
						eventDictionary = eventDictionaryEntry
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
		var oHandlerBean   = new coldbox.system.web.context.EventHandlerBean( variables.handlersInvocationPath );
		var moduleSettings = variables.modules;

		// Rip the handler and method using string functions (no regex)
		var lastDotPos      = arguments.event.lastIndexOf( "." );
		var handlerPortion  = lastDotPos > 0 ? arguments.event.substring( 0, lastDotPos ) : arguments.event;
		var handlerReceived = listLast( handlerPortion, ":" );
		var methodReceived  = lastDotPos > 0 ? arguments.event.substring( lastDotPos + 1 ) : arguments.event;

		// Verify if this is a module call
		if ( find( ":", arguments.event ) ) {
			var moduleReceived = listFirst( arguments.event, ":" );
			// Does this module exist?
			if ( structKeyExists( moduleSettings, moduleReceived ) ) {
				// Get module's handler struct for O(1) lookup
				var moduleHandlers = moduleSettings[ moduleReceived ].registeredHandlers ?: {};
				// Verify handler in module handlers using O(1) struct lookup
				if ( structKeyExists( moduleHandlers, handlerReceived ) ) {
					// Prepare bean data
					prepareHandlerBean(
						ehBean        = oHandlerBean,
						handlerRecord = moduleHandlers[ handlerReceived ],
						method        = methodReceived,
						fullEvent     = arguments.event,
						module        = moduleReceived
					)

					// put bean in cache if enabled
					if ( variables.handlerCaching ) {
						variables.handlerBeanCacheDictionary[ arguments.event ] = oHandlerBean;
					}

					return oHandlerBean;
				} else {
					getLogger().error(
						"Invalid Module (#moduleReceived#) Handler: #handlerReceived#. Valid handlers are #structKeyList( moduleHandlers )#"
					);
				}
			}

			// Log Error
			getLogger().error(
				"Invalid Module Event Called: #arguments.event#. The module: #moduleReceived# is not valid. Valid Modules are: #structKeyList( moduleSettings )#"
			);
		} else {
			// O(1) struct lookup for handler in conventions location
			if ( structKeyExists( variables.registeredHandlers, handlerReceived ) ) {
				// Prepare bean data
				prepareHandlerBean(
					ehBean        = oHandlerBean,
					handlerRecord = variables.registeredHandlers[ handlerReceived ],
					method        = methodReceived,
					fullEvent     = arguments.event
				)

				// put bean in cache if enabled
				if ( variables.handlerCaching ) {
					variables.handlerBeanCacheDictionary[ arguments.event ] = oHandlerBean;
				}

				return oHandlerBean;
			}

			// O(1) struct lookup for handler in external location
			if ( structKeyExists( variables.registeredExternalHandlers, handlerReceived ) ) {
				// Prepare bean data
				prepareHandlerBean(
					ehBean        = oHandlerBean,
					handlerRecord = variables.registeredExternalHandlers[ handlerReceived ],
					method        = methodReceived,
					fullEvent     = arguments.event
				)

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
		var currentEvent  = arguments.event.getCurrentEvent();
		var modulesConfig = variables.modules;

		// Module Check?
		if ( find( ":", currentEvent ) ) {
			var separatorIndex = find( ":", currentEvent );
			var module         = left( currentEvent, separatorIndex - 1 );
			if ( structKeyExists( modulesConfig, module ) ) {
				// Get module's handler struct for O(1) lookup
				var moduleHandlers = modulesConfig[ module ].registeredHandlers ?: {};
				var handlerKey     = mid(
					currentEvent,
					separatorIndex + 1,
					len( currentEvent )
				);
				if ( structKeyExists( moduleHandlers, handlerKey ) ) {
					// Save it as the current Event
					event.setValue( variables.eventName, moduleHandlers[ handlerKey ].defaultEvent );
				}
			}
			return this;
		}

		// O(1) struct lookup for default action test
		if ( structKeyExists( variables.registeredHandlers, currentEvent ) ) {
			// Save it as the current Event now with the default action
			event.setValue( variables.eventName, variables.registeredHandlers[ currentEvent ].defaultEvent );
		} else if ( structKeyExists( variables.registeredExternalHandlers, currentEvent ) ) {
			// Save it as the current Event now with the default action
			event.setValue(
				variables.eventName,
				variables.registeredExternalHandlers[ currentEvent ].defaultEvent
			);
		}

		return this;
	}
	/**
	 * Check if the incoming event has a matching implicit view to dispatch. This is usually called
	 * when there is no existing handler found.
	 *
	 * @event  The event string
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

		// CFML View
		if ( fileExists( expandPath( targetView ) ) ) {
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
	 * @event  The event that was found to be invalid
	 * @ehBean The event handler bean representing the invalid event
	 *
	 * @return The string event that should be executed as the invalid event handler or throws an EventHandlerNotRegisteredException
	 *
	 * @throws EventHandlerNotRegisteredException ,InvalidEventHandlerException
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
			return arguments.ehBean.getFullEvent();
		}

		// Param our last invalid event just incase
		param request._lastInvalidEvent = "";

		// If invalidEventHandler is registered, use it
		if ( len( variables.invalidEventHandler ) ) {
			// Test for invalid Event Error as well so we don't go in an endless error loop
			if (
				compareNoCase( arguments.event, request._lastInvalidEvent ) eq 0
				&&
				!structKeyExists( variables.controller, "mockController" ) // Verify this is a real and not a mock controller.
			) {
				var exceptionMessage = "The invalidEventHandler event (#variables.invalidEventHandler#) is also invalid: #arguments.event#";
				// Extra Debugging for illusive CI/Tests exceptions: Remove at one point if discovered.
				getLogger().error(
					exceptionMessage,
					{
						event              : arguments.event,
						requestEvent       : request._lastInvalidEvent ?: "NONE",
						registeredHandlers : variables.registeredHandlers,
						fullEvent          : ehBean.getFullEvent(),
						callStack          : callStackGet(),
						routedURL          : variables.controller
							.getRequestService()
							.getContext()
							.getCurrentRoutedURL(),
						route : variables.controller
							.getRequestService()
							.getContext()
							.getCurrentRoute()
					}
				);
				// Now throw the exception
				throw( message: exceptionMessage, type: "HandlerService.InvalidEventHandlerException" );
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
		}
		// end invalidEventHandler found

		// If we got here, we have an invalid event and no override, throw a 404 ERROR
		controller
			.getRequestService()
			.getContext()
			.setHTTPHeader( statusCode = 404 );

		// Invalid Event Detected, log it in the Application log, not a coldbox log but an app log
		getLogger().error(
			"Invalid Event detected: #arguments.event#. Path info: #CGI.PATH_INFO#, query string: #CGI.QUERY_STRING#"
		);

		// Throw Exception
		throw(
			message: "The event: #arguments.event# is not a valid registered event.",
			type   : "EventHandlerNotRegisteredException"
		);
	}

	/**
	 * Register's application event handlers according to convention and external paths
	 *
	 * @return HandlerService
	 *
	 * @throws HandlersDirectoryNotFoundException
	 */
	function registerHandlers(){
		/* ::::::::::::::::::::::::::::::::::::::::: HANDLERS BY CONVENTION :::::::::::::::::::::::::::::::::::::::::::: */

		// Register handlers by convention, this will throw an error if the directory does not exist, which is good because it is a convention and should be there.
		variables.registeredHandlers = getHandlerListing(
			directory     : variables.handlersPath,
			invocationPath: variables.handlersInvocationPath,
			source        : "conventions"
		)
		// Store the registered handlers in the controller for global access, this is used for things like the handler list in the admin and other places.
		variables.controller.setSetting( name = "registeredHandlers", value = variables.registeredHandlers )

		/* ::::::::::::::::::::::::::::::::::::::::: EXTERNAL HANDLERS :::::::::::::::::::::::::::::::::::::::::::: */

		if ( len( variables.handlersExternalLocationPath ) ) {
			// Check for handlers Directory Location
			if ( !directoryExists( variables.handlersExternalLocationPath ) ) {
				throw(
					message = "The external handlers directory: #variables.handlersExternalLocationPath# does not exist please check your application structure.",
					type    = "HandlersDirectoryNotFoundException"
				)
			}

			// Get struct listing for O(1) lookups with enrichment metadata
			variables.registeredExternalHandlers = getHandlerListing(
				directory     : variables.handlersExternalLocationPath,
				invocationPath: variables.handlersExternalLocation,
				source        : "external"
			)
		}

		variables.controller.setSetting(
			name  = "registeredExternalHandlers",
			value = variables.registeredExternalHandlers
		)

		return this
	}

	/**
	 * Clear the internal cache dictionaries
	 *
	 * @return HandlerService
	 */
	function clearDictionaries(){
		variables.eventCacheDictionary.clear()
		return this;
	}

	/**
	 * Get an event string's metadata entry. If not found, then you will get a new metadata entry using the `getNewMDEntry()` method.
	 *
	 * @targetEvent The event to match for metadata.
	 */
	struct function getEventMetadataEntry( required targetEvent ){
		if ( NOT structKeyExists( variables.eventCacheDictionary, arguments.targetEvent ) ) {
			return getNewMDEntry()
		}

		return variables.eventCacheDictionary[ arguments.targetEvent ]
	}

	/**
	 * Retrieve handler listings from disk as a struct for O(1) lookups.
	 * Keys are handler names (case-insensitive), values are structs with handler metadata.
	 *
	 * @directory      The path to retrieve
	 * @invocationPath The dot-notation invocation path for this handler directory
	 * @source         The source type: "conventions", "external", or "module"
	 * @moduleName     The module name (empty string for non-module handlers)
	 *
	 * @return struct with handler names as keys and metadata structs as values
	 */
	struct function getHandlerListing(
		required directory,
		string invocationPath = "",
		string source         = "",
		string moduleName     = ""
	){
		// Convert windows \ to java /
		arguments.directory = replace( arguments.directory, "\", "/", "all" )

		var util        = variables.controller.getUtil()
		var handlerList = {}
		var files       = directoryList(
			arguments.directory,
			true,
			"array",
			"*.cfc|*.bx"
		)

		for ( var item in files ) {
			var thisAbsolutePath = replace( item, "\", "/", "all" )
			var cleanHandler     = replaceNoCase(
				thisAbsolutePath,
				arguments.directory,
				"",
				"all"
			)
			// Clean OS separators to dot notation.
			cleanHandler = removeChars(
				replaceNoCase( cleanHandler, "/", ".", "all" ),
				1,
				1
			)
			// Rip extension first to get handler name
			var handlerName            = util.ripExtension( cleanHandler )
			// Get file extension
			var extension              = listLast( cleanHandler, "." )
			// Build runnable path if invocationPath provided
			var runnable               = len( invocationPath ) ? invocationPath & "." & handlerName : ""
			var defaultEvent           = len( moduleName ) ? moduleName & ":" & handlerName & "." & variables.eventAction : handlerName & "." & variables.eventAction
			// Store in struct with metadata
			handlerList[ handlerName ] = {
				handler        : handlerName,
				path           : thisAbsolutePath,
				extension      : extension,
				invocationPath : invocationPath,
				runnable       : runnable,
				defaultEvent   : defaultEvent,
				source         : source,
				moduleName     : moduleName
			}
		}

		return handlerList
	}

	/************************************ PRIVATE ************************************/

	/**
	 * Prepare a handler bean from registered handler metadata.
	 *
	 * @ehBean        The event handler bean to prepare
	 * @handlerRecord The registered handler metadata
	 * @method        The method to execute
	 * @fullEvent     The full event string
	 * @module        The module assignment, if any
	 *
	 * @return EventHandlerBean
	 */
	private function prepareHandlerBean(
		required ehBean,
		required struct handlerRecord,
		required string method,
		required string fullEvent,
		string module = ""
	){
		return arguments.ehBean
			.setHandlerRecord( arguments.handlerRecord )
			.setMethod( arguments.method )
			.setModule( arguments.module )
			.setFullEvent( arguments.fullEvent )
	}

	/**
	 * Configure REST handler virtual inheritance from the handler metadata once per mapping.
	 *
	 * @mapping  The handler WireBox mapping
	 * @injector The injector that owns the mapping
	 *
	 * @return HandlerService
	 */
	private function configureRestHandlerMapping( required mapping, required injector ){
		var extraAttributes = arguments.mapping.getExtraAttributes()

		if ( structKeyExists( extraAttributes, "restHandlerVirtualInheritanceConfigured" ) ) {
			return this
		}

		if ( !arguments.mapping.isDiscovered() ) {
			arguments.mapping.process( binder = arguments.injector.getBinder(), injector = arguments.injector )
		}

		if (
			arguments.mapping.getObjectMetadata().keyExists( "restHandler" ) &&
			(
				!len( arguments.mapping.getVirtualInheritance() ) ||
				arguments.mapping.getVirtualInheritance() == "coldbox.system.EventHandler"
			)
		) {
			injectorSeedBaseClasses( arguments.injector )
			arguments.mapping.setVirtualInheritance( "coldbox.system.RestHandler" )
		}

		extraAttributes.restHandlerVirtualInheritanceConfigured = true

		return this
	}

	/**
	 * Process an invalid event by resolving the configured invalid event handler.
	 *
	 * @ehBean         The event handler bean representing the invalid event
	 * @requestContext The current request context
	 *
	 * @return The handler that should process the invalid event
	 */
	private function processInvalidEvent( required ehBean, required requestContext ){
		// The handler exists but the action requested does not, let's go into invalid execution mode
		var targetInvalidEvent = invalidEvent( arguments.ehBean.getFullEvent(), arguments.ehBean );

		// If we get here, then the invalid event kicked in and exists, else an exception is thrown above
		// set the invalid event handler as the current event
		arguments.requestContext.overrideEvent( targetInvalidEvent );

		// Go retrieve the handler that will handle the invalid event so it can execute.
		return getHandler( getHandlerBean( targetInvalidEvent ), arguments.requestContext );
	}

	/**
	 * Verifies setup of base handler classes in WireBox
	 *
	 * @injector The injector to seed and verify
	 *
	 * @return HandlerService
	 */
	private function injectorSeedBaseClasses( required injector ){
		if ( NOT arguments.injector.getBinder().mappingExists( "coldbox.system.EventHandler" ) ) {
			arguments.injector
				.registerNewInstance(
					name        : "coldbox.system.EventHandler",
					instancePath: "coldbox.system.EventHandler"
				)
				.setScope( "singleton" )
		}
		if ( NOT arguments.injector.getBinder().mappingExists( "coldbox.system.RestHandler" ) ) {
			arguments.injector
				.registerNewInstance(
					name        : "coldbox.system.RestHandler",
					instancePath: "coldbox.system.RestHandler"
				)
				.setScope( "singleton" )
		}

		return this
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
			"provider"          : "template",
			"cacheInclude"      : "*",
			"cacheExclude"      : "",
			"cacheFilter"       : ""
		}
	}

	/**
	 * Return the event caching metadata for an action execution context.
	 *
	 * @ehBean        The event handler bean
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
						mdEntry.provider     = arguments.ehBean.getActionMetadata( "cacheProvider", "template" );
						mdEntry.cacheInclude = arguments.ehBean.getActionMetadata( "cacheInclude", "*" );
						mdEntry.cacheExclude = arguments.ehBean.getActionMetadata( "cacheExclude", "" );
						mdEntry.cacheFilter  = arguments.ehBean.getActionMetadata( "cacheFilter", "" );

						// Handler Event Cache Key Suffix, this is global to the event
						if (
							isClosure( arguments.oEventHandler.EVENT_CACHE_SUFFIX ) ||
							isCustomFunction( arguments.oEventHandler.EVENT_CACHE_SUFFIX )
						) {
							mdEntry.suffix = oEventHandler.EVENT_CACHE_SUFFIX( arguments.ehBean );
						} else {
							mdEntry.suffix = arguments.oEventHandler.EVENT_CACHE_SUFFIX;
						}

						// if the cacheFilter has a length and is a method, then we need to verify and store the resulting closure
						if ( len( mdEntry.cacheFilter ) ) {
							// if the method doesn't exist, then throw an exception
							if ( !arguments.oEventHandler._actionExists( mdEntry.cacheFilter ) ) {
								throw(
									message = "CacheFilter expected a private method '#mdEntry.cacheFilter#'",
									type    = "HandlerInvalidCacheFilterException",
									detail  = "CacheFilter method '#mdEntry.cacheFilter#' does not exist in handler '#getMetadata( oEventHandler ).name#'. Please verify your cacheFilter annotation."
								);
							}

							mdEntry.cacheFilter = arguments.oEventHandler._privateInvoker(
								mdEntry.cacheFilter,
								{}
							);

							// if the cacheFilter isn't a closure, throw an exception
							// We check for isClosure and isCustomFunction for ACF/Lucee compatibility
							if (
								!isClosure( mdEntry.cacheFilter ) &&
								!isCustomFunction( mdEntry.cacheFilter )
							) {
								throw(
									message = "CacheFilter expected a closure.",
									type    = "HandlerInvalidCacheFilterException",
									detail  = "Please verify your cacheFilter annotation in handler '#getMetadata( oEventHandler ).name# to ensure it returns a closure."
								);
							}
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
