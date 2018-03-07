/**
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
* ---
* This service takes care of all event handling in ColdBox
*/
component extends="coldbox.system.web.services.BaseService" accessors="true"{

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
	 * Constructor
	 *
	 * @controller ColdBox Controller
	 */
	function init( required controller ){
		// controlle + wirebox references
		variables.controller 	= arguments.controller;

		// Setup the Event Handler Cache Dictionary
		variables.handlerCacheDictionary = {};
		// Setup the Event Cache Dictionary
		variables.eventCacheDictionary = {};
		// Static base class
		variables.HANDLER_BASE_CLASS = "coldbox.system.EventHandler";

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
		variables.registeredHandlers			= controller.getSetting( "RegisteredHandlers" );
		variables.registeredExternalHandlers 	= controller.getSetting( "RegisteredExternalHandlers" );
		variables.eventAction					= controller.getSetting( "EventAction", 1 );
		variables.eventName						= controller.getSetting( "EventName" );
		variables.invalidEventHandler			= controller.getSetting( "invalidEventHandler" );
		variables.handlerCaching				= controller.getSetting( "HandlerCaching" );
		variables.eventCaching					= controller.getSetting( "EventCaching" );
		variables.handlersInvocationPath		= controller.getSetting( "HandlersInvocationPath" );
		variables.handlersExternalLocation		= controller.getSetting( "HandlersExternalLocation" );
		variables.templateCache					= controller.getCache( "template" );
		variables.modules						= controller.getSetting( "modules" );
		variables.interceptorService			= controller.getInterceptorService();
		variables.wirebox 						= controller.getWireBox();
	}

	/**
	* Called by wirebox once instances are autowired to re-fire to `afterHandlerCreation`
	*/
	function afterInstanceAutowire( event, interceptData ){
		var attribs = interceptData.mapping.getExtraAttributes();
		var iData 	= {};

		// listen to handlers only
		if( structKeyExists( attribs, "isHandler" ) ){
			// Fill-up Intercepted metadata
			iData.handlerPath 	= attribs.handlerPath;
			iData.oHandler 		= interceptData.target;

			// Re-Fire Interception
			variables.interceptorService.processState( "afterHandlerCreation", iData );
		}
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
		var oHandler 	= "";
		var binder		= "";
		var attribs		= "";
		var mapping		= "";

		// Check if handler already mapped?
		if( NOT wirebox.getBinder().mappingExists( arguments.invocationPath ) ){
			// lazy load checks for wirebox
			wireboxSetup();
			// extra attributes added to mapping so they are relayed by events
			var attribs = {
				handlerPath = arguments.invocationPath,
				isHandler	= true
			};
			// feed this handler to wirebox with virtual inheritance just in case, use registerNewInstance so its thread safe
			var mapping = wirebox.registerNewInstance( name=arguments.invocationPath, instancePath=arguments.invocationPath )
				.setVirtualInheritance( "coldbox.system.EventHandler" )
				.addDIConstructorArgument( name="controller", value=controller )
				.setThreadSafe( true )
				.setScope(
					variables.handlerCaching ? wirebox.getBinder().SCOPES.SINGLETON : wirebox.getBinder().SCOPES.NOSCOPE
				)
				.setCacheProperties( key="handlers-#arguments.invocationPath#" )
				.setExtraAttributes( attribs );
		}

		// retrieve, build and wire from wirebox
		return wirebox.getInstance( arguments.invocationPath );
	}

	/**
	 * Get a validated handler instance using an event handler bean and context. This is called
	 * once event execution is in progress.
	 * Before returning this method verifies method of execution, event caching, invalid events and stores metadata
	 *
	 * @ehBean The event handler bean representation
	 * @requestContext The request context object
	 */
	function getHandler( required ehBean, required requestContext ){
		var oRequestContext 		= arguments.requestContext;
		var oEventURLFacade 		= variables.templateCache.getEventURLFacade();

		// Create Runnable Object via WireBox
		var oEventHandler = newHandler( arguments.ehBean.getRunnable() );

		/* ::::::::::::::::::::::::::::::::::::::::: EVENT METHOD TESTING :::::::::::::::::::::::::::::::::::::::::::: */

		// Does requested method/action of execution exist in handler?
		if( NOT oEventHandler._actionExists( arguments.ehBean.getMethod() ) ){

			// Check if the handler has an onMissingAction() method, virtual Events
			if( oEventHandler._actionExists( "onMissingAction" ) ){
				// Override the method of execution
				arguments.ehBean.setMissingAction( arguments.ehBean.getMethod() );
				// Let's go execute our missing action
				return oEventHandler;
			}

			// Test for Implicit View Dispatch
			if( controller.getSetting( "ImplicitViews" ) AND
				isViewDispatch( arguments.ehBean.getFullEvent(), arguments.ehBean )
			){
				return oEventHandler;
			}

			// Invalid Event procedures
			invalidEvent( arguments.ehBean.getFullEvent(), arguments.ehBean );

			// If we get here, then the invalid event kicked in and exists, else an exception is thrown
			// Go retrieve the handler that will handle the invalid event so it can execute.
			return getHandler(
				getHandlerBean( arguments.ehBean.getFullEvent() ),
				oRequestContext
			);

		} //method check finalized.

		// Store metadata in execution bean
		arguments.ehBean
			.setActionMetadata( oEventHandler._actionMetadata( arguments.ehBean.getMethod() ) )
			.setHandlerMetadata( getMetadata( oEventHandler ) );

		/* ::::::::::::::::::::::::::::::::::::::::: EVENT CACHING :::::::::::::::::::::::::::::::::::::::::::: */

		// Event Caching Routines, if using caching, NOT a private event and we are executing the main event
		if (
			variables.eventCaching AND
			!arguments.ehBean.getIsPrivate() AND
			arguments.ehBean.getFullEvent() EQ oRequestContext.getCurrentEvent()
		){

			// Get event action caching metadata
			var eventDictionaryEntry = getEventCachingMetadata( arguments.ehBean, oEventHandler );

			// Do we need to cache this event's output after it executes??
			if ( eventDictionaryEntry.cacheable ){
				// Create caching data structure according to MD, as the cache key can be dynamic by execution.
				var eventCachingData = {};
				structAppend( eventCachingData, eventDictionaryEntry, true );

				// Create the Cache Key to save
				eventCachingData.cacheKey = oEventURLFacade.buildEventKey(
					keySuffix 		= eventDictionaryEntry.suffix,
					targetEvent 	= arguments.ehBean.getFullEvent(),
					targetContext 	= oRequestContext
				);

				// Event is cacheable and we need to flag it so the Renderer caches it
				oRequestContext.setEventCacheableEntry( eventCachingData );

			} //end if md says that this event is cacheable

		} //end if event caching.

		//return the tested and validated event handler
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
		var handlersList 			= variables.registeredHandlers;
		var handlersExternalList 	= variables.registeredExternalHandlers;
		var oHandlerBean 			= new coldbox.system.web.context.EventHandlerBean( variables.handlersInvocationPath );
		var moduleSettings 			= variables.modules;

		// Rip the handler and method
		var handlerReceived = listLast( reReplace( arguments.event, "\.[^.]*$", "" ), ":" );
		var methodReceived 	= listLast( arguments.event, "." );

		// Verify if this is a module call
		if( find( ":", arguments.event ) ){
			var moduleReceived = listFirst( arguments.event, ":" );
			// Does this module exist?
			if( structKeyExists( moduleSettings, moduleReceived ) ){
				// Verify handler in module handlers
				var handlerIndex = listFindNoCase( moduleSettings[ moduleReceived ].registeredHandlers, handlerReceived );
				if( handlerIndex ){
					return oHandlerBean
						.setInvocationPath( moduleSettings[ moduleReceived ].handlerInvocationPath )
						.setHandler( listgetAt(moduleSettings[ moduleReceived ].registeredHandlers, handlerIndex ) )
						.setMethod( methodReceived )
						.setModule( moduleReceived );
				} else {
					variables.log.error( "Invalid Module (#moduleReceived#) Handler: #handlerReceived#. Valid handlers are #moduleSettings[ moduleReceived ].registeredHandlers#" );
				}
			}

			// Log Error
			variables.log.error( "Invalid Module Event Called: #arguments.event#. The module: #moduleReceived# is not valid. Valid Modules are: #structKeyList( moduleSettings )#" );
		} else {
			// Try to do list localization in the registry for full event string.
			var handlerIndex = listFindNoCase( handlersList, HandlerReceived );
			// Check for conventions location
			if ( handlerIndex ){
				return oHandlerBean
					.setHandler( listgetAt( handlersList, handlerIndex ) )
					.setMethod( MethodReceived );
			}

			// Check for external location
			handlerIndex = listFindNoCase( handlersExternalList, HandlerReceived );
			if( handlerIndex ){
				return oHandlerBean
					.setInvocationPath( variables.handlersExternalLocation )
					.setHandler( listgetAt( handlersExternalList, handlerIndex ) )
					.setMethod( MethodReceived );
			}
		} //end else

		// Do View Dispatch Check Procedures
		if( isViewDispatch( arguments.event, oHandlerBean ) ){
			return oHandlerBean;
		}

		// Run invalid event procedures, handler not found as a module or in all lists
		invalidEvent( arguments.event, oHandlerBean );

		// If we get here, then invalid event handler is active and we need to
		// return an event handler bean that matches it
		return getHandlerBean( oHandlerBean.getFullEvent() );
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
		var handlersList 			= variables.registeredHandlers;
		var handlersExternalList 	= variables.registeredExternalHandlers;
		var currentEvent 			= arguments.event.getCurrentEvent();
		var modulesConfig 			= variables.modules;

		// Module Check?
		if( find( ":", currentEvent ) ){
			var module = listFirst( currentEvent, ":" );
			if(
				structKeyExists( modulesConfig, module ) AND
				listFindNoCase( modulesConfig[ module ].registeredHandlers, reReplaceNoCase( currentEvent, "^([^:.]*):", "" ) )
			){
				// Append the default event action
				currentEvent = currentEvent & "." & variables.eventAction;
				// Save it as the current Event
				event.setValue( variables.eventName, currentEvent );
			}
			return this;
		}

		// Do a Default Action Test First, if default action desired.
		if(
			listFindNoCase( handlersList, currentEvent ) OR
			listFindNoCase( handlersExternalList, currentEvent )
		){
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
		var cEvent     		= reReplaceNoCase( arguments.event, "^([^:.]*):", "" );
		var renderer 		= controller.getRenderer();
		var targetView		= "";
		var targetModule	= getToken( arguments.event, 1, ":" );

		// Cleanup of . to / for lookups for path locating
		cEvent = lcase( replace( cEvent, ".", "/", "all" ) );

		// module?
		if( find( ":", arguments.event ) and structKeyExists( variables.modules, targetModule ) ){
			targetView = renderer.locateModuleView( cEvent, targetModule );
		} else {
			targetView = renderer.locateView( cEvent );
		}

		// Validate Target View
		if( fileExists( expandPath( targetView & ".cfm" ) ) ){
			arguments.ehBean.setViewDispatch( true );
			return true;
		}

		return false;
	}

	/**
	 * Invalid Event procedures
	 *
	 * @event The event that was found to be invalid
	 * @ehBean The event handler bean
	 *
	 * @throws EventHandlerNotRegisteredException,InvalidEventHandlerException
	 *
	 * @return HandlerService
	 */
	function invalidEvent( required string event, required ehBean ){
        controller.getRequestService().getContext().setHTTPHeader(
            statusCode = 404,
            statusText = "Not Found"
        );

		var iData = {
			"invalidEvent" 	= arguments.event,
			"ehBean"		= arguments.ehBean,
			"override"		= false
		};
        variables.interceptorService.processState( "onInvalidEvent", iData );

		// If the override was changed by the interceptors then they updated the ehBean of execution
		if( iData.override ){
			return this;
		}

		// If invalidEventHandler is registered, use it
		if ( len( trim( variables.invalidEventHandler ) ) ){

			// Test for invalid Event Error as well so we don't go in an endless error loop
			if ( compareNoCase( variables.invalidEventHandler, arguments.event ) eq 0 ){
				throw(
					message = "The invalidEventHandler event is also invalid",
					detail  = "The invalidEventHandler setting is also invalid: #variables.invalidEventHandler#. Please check your settings",
					type    = "HandlerService.InvalidEventHandlerException"
				);
			}

			// Store Invalid Event in PRC
			controller.getRequestService().getContext().setPrivateValue( "invalidevent", arguments.event );

			// Override Event With On Invalid Event
			arguments.ehBean.setHandler( reReplace( variables.invalidEventHandler, "\.[^.]*$", "" ) )
				.setMethod( listLast( variables.invalidEventHandler, ".") )
				.setModule( '' );
			// If module found in invalid event, set it for discovery
			if( find( ":", variables.invalidEventHandler ) ){
				arguments.ehBean.setModule( getToken( variables.invalidEventHandler, 1 ) );
            }

			return this;
		}

		// Invalid Event Detected, log it in the Application log, not a coldbox log but an app log
		variables.log.error( "Invalid Event detected: #arguments.event#. Path info: #cgi.path_info#, query string: #cgi.query_string#" );

		// Throw Exception
		throw(
			message = "The event: #arguments.event# is not a valid registered event.",
			type    = "EventHandlerNotRegisteredException"
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
		controller.setSetting( name="registeredHandlers", value=variables.registeredHandlers );

		/* ::::::::::::::::::::::::::::::::::::::::: EXTERNAL HANDLERS :::::::::::::::::::::::::::::::::::::::::::: */

		if( len( handlersExternalLocationPath ) ){

			// Check for handlers Directory Location
			if ( !directoryExists( handlersExternalLocationPath ) ){
				throw(
					message = "The external handlers directory: #HandlersExternalLocationPath# does not exist please check your application structure.",
					type 	= "HandlersDirectoryNotFoundException"
				);
			}

			// Get recursive Array listing
			handlersExternalArray = getHandlerListing( handlersExternalLocationPath );
		}

		// Set registered External Handlers
		variables.registeredExternalHandlers = arrayToList( handlersExternalArray );
		controller.setSetting( name="registeredExternalHandlers", value=variables.registeredExternalHandlers );

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
	 * Get an event string's metdata entry. If not found, then you will get a new metadata entry using the `getNewMDEntry()` method.
	 *
	 * @targetEvent The event to match for metadata.
	 */
	struct function getEventMetadataEntry( required targetEvent ){
		if( NOT structKeyExists( variables.eventCacheDictionary, arguments.targetEvent ) ){
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
		// Get listings
		var files = directoryList( arguments.directory, true, "array", "*.cfc" );
		// Convert windows \ to java /
		arguments.directory = replace( arguments.directory, "\","/", "all" );

		// Iterate, clean and register
		var fileArray = [];
		for( var file in files ){

			var thisAbsolutePath = replace( file, "\", "/", "all" );
			var cleanHandler = replacenocase( thisAbsolutePath, arguments.directory, "", "all" );

			// Clean OS separators to dot notation.
			cleanHandler = removeChars( replacenocase( cleanHandler, "/", ".", "all" ), 1, 1 );

			//Clean Extension
			cleanHandler = controller.getUtil().ripExtension( cleanhandler );

			//Add data to array
			ArrayAppend( fileArray, cleanHandler );
		}

		return fileArray;
	}

	/************************************ PRIVATE ************************************/

	/**
	 * Verifies setup of base handler class in WireBox
	 *
	 * @return HandlerService
	 */
	private function wireboxSetup(){
		// Check if handler mapped?
		if( NOT wirebox.getBinder().mappingExists( variables.HANDLER_BASE_CLASS ) ){
			// feed the base class
			wirebox.registerNewInstance( name=variables.HANDLER_BASE_CLASS, instancePath=variables.HANDLER_BASE_CLASS )
				.addDIConstructorArgument( name="controller", value=controller );
			// register ourselves to listen for autowirings
			variables.interceptorService.registerInterceptionPoint( "HandlerService", "afterInstanceAutowire", this );
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
			"cacheable" 		    = false,
			"timeout" 		        = "",
			"lastAccessTimeout" 	= "",
			"cacheKey"  		    = "",
			"suffix" 			    = "",
			"provider"				= "template"
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
		if( !structKeyExists( variables.eventCacheDictionary, cacheKey ) ){
			lock 	name="handlerservice.#controller.getAppHash()#.eventcachingmd.#cacheKey#"
					type="exclusive"
					throwontimeout="true"
					timeout="10"
			{
				if ( !structKeyExists( variables.eventCacheDictionary, cacheKey) ){
					// Get New Default MD Entry
					var mdEntry = getNewMDEntry();

					// Cache Entries for timeout and last access timeout
					if( arguments.ehBean.getActionMetadata( "cache", false ) ){
						mdEntry.cacheable 			= true;
						mdEntry.timeout 			= arguments.ehBean.getActionMetadata( "cacheTimeout", "" );
						mdEntry.lastAccessTimeout 	= arguments.ehBean.getActionMetadata( "cacheLastAccessTimeout", "" );
						mdEntry.provider 		 	= arguments.ehBean.getActionMetadata( "cacheProvider", "template" );

						// Handler Event Cache Key Suffix, this is global to the event
						if( isClosure( arguments.oEventHandler.EVENT_CACHE_SUFFIX ) || isCustomFunction( arguments.oEventHandler.EVENT_CACHE_SUFFIX ) ){
							mdEntry.suffix = oEventHandler.EVENT_CACHE_SUFFIX( arguments.ehBean );
						} else {
							mdEntry.suffix = arguments.oEventHandler.EVENT_CACHE_SUFFIX;
						}

					} //end cache metadata is true

					// Save md Entry in dictionary
					variables.eventCacheDictionary[ cacheKey ] = mdEntry;
				}//end of md cache dictionary.
			} // end lock
		} // end if

		return variables.eventCacheDictionary[ cacheKey ];
	}

}