/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * This service takes care of preparing and creating request contexts. Facades to FORM and URL
 */
component extends="coldbox.system.web.services.BaseService" {

	/**
	 * Constructor
	 *
	 * @controller The ColdBox Controller.
	 */
	function init( required controller ){
		setController( arguments.controller )

		variables.flashScope    = ""
		variables.flashData     = ""
		variables.flashDataHash = ""

		return this
	}

	/**
	 * Once configuration loads this method is fired by the service loader.
	 */
	function onConfigurationLoad(){
		// Local Configuration data and dependencies
		variables.eventName          = controller.getSetting( "eventName" )
		variables.eventCaching       = controller.getSetting( "eventCaching" )
		variables.jsonPayloadToRC    = controller.getSetting( "jsonPayloadToRC" )
		variables.defaultEvent       = controller.getSetting( "DefaultEvent" )
		variables.interceptorService = controller.getInterceptorService()
		variables.routingService     = controller.getRoutingService()
		variables.handlerService     = controller.getHandlerService()
		variables.cacheBox           = controller.getCacheBox()
		variables.cache              = controller.getCache()
		variables.templateCache      = controller.getCache( "template" )
		variables.flashData          = controller.getSetting( "flash" )
		variables.flashDataHash      = hash( variables.flashData.toString() )

		// build out Flash RAM
		buildFlashScope()
	}

	/**
	 * I capture an incoming request. Returns: coldbox.system.web.context.RequestContext
	 *
	 * @event     Override to instead use this as the main event instead of looking for it in form/url
	 * @proxyCall If true, we ignore routing, since this is a proxy remote call
	 *
	 * @return coldbox.system.web.context.RequestContext
	 */
	any function requestCapture( event, boolean proxyCall = false ){
		var context = getContext()
		var rc      = context.getCollection()
		var prc     = context.getCollection( private = true )

		// Capture FORM/URL or direct overrride
		if ( isDefined( "FORM" ) ) {
			structAppend( rc, FORM )
		}
		if ( isDefined( "URL" ) ) {
			structAppend( rc, URL )
		}

		// If the inbound content body is a JSON payload capture it
		if ( variables.jsonPayloadToRC ) {
			var httpContent = context.getHTTPContent()
			if ( len( httpContent ) && isJSON( httpContent ) ) {
				var payload = context.getHTTPContent( json = true )
				if ( isStruct( payload ) ) {
					structAppend( rc, payload )
				}
			}
		}

		// Configure decorator if available?
		if ( structKeyExists( context, "configure" ) ) {
			context.configure()
		}

		// First, process the request through the RoutingService
		if ( !arguments.proxyCall ) {
			variables.routingService.requestCapture( context )
		}

		// Do we have an override
		if ( !isNull( arguments.event ) && len( arguments.event ) ) {
			rc[ variables.eventName ] = arguments.event
		}

		// Remove FW reserved commands just in case before collection snapshot
		var fwCache = structKeyExists( rc, "fwCache" )
		structDelete( rc, "fwCache" )

		// Take snapshot of incoming collection
		prc[ "cbox_incomingContextHash" ] = hash( rc.toString() )

		// Do we have flash elements to inflate?
		if ( variables.flashScope.flashExists() ) {
			if ( getLogger().canDebug() ) {
				getLogger().debug( "Flash RAM detected, inflating flash." );
			}
			variables.flashScope.inflateFlash()
		}

		// Default Event Determination
		if ( NOT structKeyExists( rc, variables.eventName ) ) {
			rc[ variables.eventName ] = variables.defaultEvent
		}

		// Event More Than 1 Check, grab the first event instance, other's are discarded
		if ( listLen( rc[ variables.eventName ] ) GTE 2 ) {
			rc[ variables.eventName ] = getToken( rc[ variables.eventName ], 2, "," )
		}

		// Default Event Action Checks
		variables.handlerService.defaultActionCheck( context )

		// Execute onRequestCapture interceptionPoint
		variables.interceptorService.announce( "onRequestCapture" )

		// Are we using event caching?
		eventCachingTest( context, fwCache )

		return context
	}

	/**
	 * Tests if the incoming context is an event cache
	 *
	 * @context                The request context to test for event caching
	 * @context.docbox_generic coldbox.system.web.context.RequestContext
	 * @fwCache                Flag to hard purge the cache if needed
	 */
	RequestService function eventCachingTest( required context, boolean fwCache = false ){
		// Not using event caching? Bail early before doing any work. This is the common path.
		if ( !variables.eventCaching ) {
			return this;
		}

		var oEventURLFacade = variables.templateCache.getEventURLFacade()
		var currentEvent    = arguments.context.getCurrentEvent()
		var eventCache      = {}

		// Cleanup the cache key, just in case, maybe ses interceptor has been used.
		arguments.context.removeEventCacheableEntry()

		// Get metadata entry for event that's fired.
		var eventDictionary = variables.handlerService.getEventMetaDataEntry( currentEvent )

		// Verify that it is cacheable, else quit, no need for testing anymore.
		if ( NOT eventDictionary.cacheable ) {
			return this
		}

		// Incorporate metadata about event
		eventCache.append( eventDictionary, true )
		// Build the event cache key according to incoming request
		eventCache[ "cacheKey" ] = oEventURLFacade.buildEventKey(
			targetEvent     = currentEvent,
			targetContext   = arguments.context,
			eventDictionary = eventDictionary
		)

		// Check for Event Cache Purge
		if ( arguments.fwCache ) {
			// Clear the key from the cache
			variables.cacheBox.getCache( eventDictionary.provider ).clear( eventCache.cacheKey )

			// Return don't show cached version
			return this
		}

		// Event has been found, flag it so we can render it from cache if it still survives
		arguments.context.setEventCacheableEntry( eventCache )

		// debug logging
		if ( getLogger().canDebug() ) {
			getLogger().debug( "Event caching detected for : #eventCache.toString()#" )
		}

		return this
	}

	/**
	 * Get the Request context from request scope or create a new one.
	 * Creation will be thread safe so two threads sharing the request scope
	 * don't both create a new context and overwrite
	 *
	 * @return coldbox.system.web.context.RequestContext
	 */
	function getContext( string classPath = "coldbox.system.web.context.RequestContext" ){
		var thisContext = getContextFromScope()
		if ( !isNull( thisContext ) ) {
			return thisContext
		}

		lock scope="request" timeout="30" {
			// Double check once inside lock
			var thisContext = getContextFromScope()
			if ( !isNull( thisContext ) ) {
				return thisContext
			}

			return createContext( classPath )
		}
	}

	/**
	 * Get the Request context from request scope or return null if not exists
	 *
	 * @return coldbox.system.web.context.RequestContext or null if not found
	 */
	private function getContextFromScope(){
		return request[ "cb_requestContext" ] ?: javacast( "null", "" )
	}

	/**
	 * Set the request context into the request scope
	 *
	 * @context Request Context object
	 */
	RequestService function setContext( required context ){
		request.cb_requestContext = arguments.context
		return this
	}

	/**
	 * Remove the context from scope
	 */
	RequestService function removeContext(){
		structDelete( request, "cb_requestContext" )
		return this
	}

	/**
	 * Does the request context exist in request scope
	 */
	boolean function contextExists(){
		return structKeyExists( request, "cb_requestContext" )
	}

	/**
	 * Return the flash scope instance in use by the framework.
	 */
	any function getFlashScope(){
		return variables.flashScope
	}

	/**
	 * Rebuild's the Flash RAM Scope if the application spec has changed, else it ignores it
	 */
	RequestService function rebuildFlashScope(){
		if ( variables.flashDataHash neq hash( controller.getSetting( "flash" ).toString() ) ) {
			buildFlashScope()
		}
		return this
	}

	/**
	 * Build's the Flash RAM Scope as defined in the application spec.
	 */
	RequestService function buildFlashScope(){
		var flashPath = ""

		// Verify Flash decisions
		if ( variables.flashData.scope == "session" and !getApplicationMetadata().sessionManagement ) {
			getLogger().error(
				"Flash RAM was set to use session but session is undefined, changing it to cache for you so we don't blow up."
			)
			variables.flashData.scope = "cache"
		}
		if ( variables.flashData.scope == "client" and !getApplicationMetadata().clientManagement ) {
			getLogger().error(
				"Flash RAM was set to use client but client is undefined, changing it to cache for you so we don't blow up."
			)
			variables.flashData.scope = "cache"
		}

		// Shorthand Flash Types
		switch ( variables.flashData.scope ) {
			case "session": {
				flashpath = "coldbox.system.web.flash.SessionFlash"
				break;
			}
			case "client": {
				writeDump( "Client Flash Has Been Removed, Please use session or cache" )
				abort;
			}
			case "cache": {
				flashpath = "coldbox.system.web.flash.ColdboxCacheFlash"
				break;
			}
			case "mock": {
				flashpath = "coldbox.system.web.flash.MockFlash"
				break;
			}
			default: {
				flashPath = variables.flashData.scope
			}
		}

		// Create Flash RAM object
		variables.flashScope = createObject( "component", flashPath ).init( controller, variables.flashData )

		return this
	}

	/****************************************** PRIVATE ******************************************************/

	/**
	 * Creates a new request context object
	 *
	 * @return coldbox.system.web.context.RequestContext
	 */
	function createContext( string classPath = "coldbox.system.web.context.RequestContext" ){
		var oDecorator         = ""
		var decoratorClassPath = variables.controller.getSetting(
			name         = "RequestContextDecorator",
			defaultValue = ""
		)

		// Create the original request context
		var oContext = createObject( "component", arguments.classPath ).init(
			properties: variables.controller.getConfigSettings(),
			controller: variables.controller
		)

		// Determine if we have a decorator, if we do, then decorate it.
		if ( len( decoratorClassPath ) ) {
			// Create the decorator
			oDecorator = createObject( "component", decoratorClassPath ).init( oContext, variables.controller )
			// Set Request Context in storage
			setContext( oDecorator )
			// Return
			return oDecorator
		}

		// Set Request Context in storage
		setContext( oContext )

		// Return Context
		return oContext
	}

}
