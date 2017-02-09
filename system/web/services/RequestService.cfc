/**
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
* ---
* This service takes care of preparing and creating request contexts. Facades to FORM and URL
*/
component extends="coldbox.system.web.services.BaseService"{

	/**
	 * Constructor
	 */
	function init( required controller ){
		setController( arguments.controller );

		variables.flashScope 	= "";
		variables.flashData 	= "";
		variables.flashDataHash = "";

		return this;
	}

	/**
	 * Once configuration loads
	 */
	function onConfigurationLoad(){
		// Local Configuration data and dependencies
		variables.log 					= controller.getLogBox().getLogger( this );
		variables.eventName				= controller.getSetting( "eventName" );
		variables.eventCaching			= controller.getSetting( "eventCaching" );
		variables.interceptorService 	= controller.getInterceptorService();
		variables.handlerService		= controller.getHandlerService();
		variables.cacheBox				= controller.getCacheBox();
		variables.cache					= controller.getCache();
		variables.templateCache			= controller.getCache( "template" );
		variables.flashData 			= controller.getSetting( "flash" );
		variables.flashDataHash			= hash( variables.flashData.toString() );
		
		// build out Flash RAM
		buildFlashScope();
	}

	/**
	 * I capture an incoming request. Returns: coldbox.system.web.context.RequestContext
	 * @return coldbox.system.web.context.RequestContext
	 */
	any function requestCapture(){
		var context 	= getContext();
		var rc			= context.getCollection();
		var prc 		= context.getCollection( private=true );
		var fwCache		= false;

		// Capture FORM/URL
		if( isDefined( "FORM" ) ){ structAppend( rc, FORM ); }
		if( isDefined( "URL" )  ){ structAppend( rc, URL ); }

		// Configure decorator if available?
		if ( structKeyExists( context, "configure" ) ){ context.configure(); }

		// Execute onRequestCapture interceptionPoint
		variables.interceptorService.processState( "onRequestCapture" );

		// Remove FW reserved commands just in case before collection snapshot
		fwCache = structKeyExists( rc,"fwCache" );
		structDelete( rc, "fwCache" );

		// Take snapshot of incoming collection
		prc[ "cbox_incomingContextHash" ] = hash( rc.toString() );

		// Do we have flash elements to inflate?
		if( variables.flashScope.flashExists() ){
			if( variables.log.canDebug() ){
				variables.log.debug("Flash RAM detected, inflating flash...");
			}
			variables.flashScope.inflateFlash();
		}

		// Object Caching Garbage Collector
		variables.cacheBox.reapAll();

		// Default Event Determination
		if ( NOT structKeyExists( rc, variables.eventName ) ){
			rc[ variables.eventName ] = controller.getSetting( "DefaultEvent" );
		}

		// Event More Than 1 Check, grab the first event instance, other's are discarded
		if ( listLen( rc[ variables.eventName ] ) GTE 2 ){
			rc[ variables.eventName ] = getToken( rc[ variables.eventName ], 2, ",");
		}

		// Default Event Action Checks
		variables.handlerService.defaultEventCheck( context );

		// Are we using event caching?
		eventCachingTest( context, fwCache );

		return context;
	}

	/**
	 * Tests if the incoming context is an event cache
	 * @context The request context to test for event caching
	 * @context.docbox_generic coldbox.system.web.context.RequestContext
	 * @fwCache
	 */
	function eventCachingTest( required context, boolean fwCache=false ){
		var eventCache   	= structnew();
		var oEventURLFacade = variables.templateCache.getEventURLFacade();
		var eventDictionary = 0;
		var currentEvent    = arguments.context.getCurrentEvent();

		// Are we using event caching?
		if ( variables.eventCaching ){
			// Cleanup the cache key, just in case, maybe ses interceptor has been used.
			arguments.context.removeEventCacheableEntry();

			// Get metadata entry for event that's fired.
			eventDictionary = variables.handlerService.getEventMetaDataEntry(currentEvent);

			// Verify that it is cacheable, else quit, no need for testing anymore.
			if( NOT eventDictionary.cacheable ){
				return;
			}

			// Build the event cache key according to incoming request
			eventCache.cacheKey = oEventURLFacade.buildEventKey(keySuffix=eventDictionary.suffix,
														  targetEvent=currentEvent,
														  targetContext=arguments.context);
			// Check for Event Cache Purge
			if ( arguments.fwCache ){
				// Clear the key from the cache
				variables.templateCache.clear( eventCache.cacheKey );
				return;
			}

			// Event has been found, flag it so we can render it from cache if it still survives
			arguments.context.setEventCacheableEntry( eventCache );

			// debug logging
			if( variables.log.canDebug() ){
				variables.log.debug("Event caching detected for : #eventCache.toString()#");
			}

		}//end if using event caching.
	}

	/**
	 * Get the Request context from request scope or create a new one.
	 */
	function getContext(){
		if ( structKeyExists(request,"cb_requestContext") ){ return request.cb_requestContext; }
		return createContext();
	}

	/**
	 * Set the request context into the request scope
	 */
	RequestService function setContext( required context ){
		request.cb_requestContext = arguments.context;
		return this;
	}

	/**
	 * Remove the context from scope
	 */
	RequestService function removeContext(){
		structDelete( request, "cb_requestContext" );
		return this;
	}

	/**
	 * Does the request context exist in request scope
	 */
	boolean function contextExists(){
		return structKeyExists( request, "cb_requestContext" );
	}

	/**
	 * Does the request context exist in request scope
	 */
	any function getFlashScope(){
		return variables.flashScope;
	}

	/**
	 * Rebuild's the Flash RAM Scope if the application spec has changed, else it ignores it
	 */
	RequestService function rebuildFlashScope(){
		if( variables.flashDataHash neq hash( controller.getSetting( "flash" ).toString() ) ){
			buildFlashScope();
   		}
   		return this;
	}

	/**
	 * Build's the Flash RAM Scope as defined in the application spec.
	 */
	RequestService function buildFlashScope(){
			var flashPath 	= "";

		// Shorthand Flash Types
		switch( variables.flashData.scope ){
			case "session" : {
				flashpath = "coldbox.system.web.flash.SessionFlash";
				break;
			}
			case "client" : {
				flashpath = "coldbox.system.web.flash.ClientFlash";
				break;
			}
			case "cluster" : {
				flashpath = "coldbox.system.web.flash.ClusterFlash";
				break;
			}
			case "cache" : {
				flashpath = "coldbox.system.web.flash.ColdboxCacheFlash";
				break;
			}
			case "mock" : {
				flashpath = "coldbox.system.web.flash.MockFlash";
				break;
			}
			default : {
				flashPath = variables.flashData.scope;
			}
		}

		// Create Flash RAM object
		variables.flashScope = createObject( "component", flashPath ).init( controller, variables.flashData );

		return this;
	}

	/****************************************** PRIVATE ******************************************************/

	/**
	 * Creates a new request context object
	 * @return coldbox.system.web.context.RequestContext
	 */
	function createContext(){
		var oDecorator = "";

		// Create the original request context
		var oContext = new coldbox.system.web.context.RequestContext( properties=controller.getConfigSettings(), controller=controller );

		// Determine if we have a decorator, if we do, then decorate it.
		if ( len( controller.getSetting( name="RequestContextDecorator", defaultValue="" ) ) ){
			//Create the decorator
			oDecorator = CreateObject( "component", controller.getSetting(name="RequestContextDecorator") ).init( oContext, controller );
			//Set Request Context in storage
			setContext( oDecorator );
			//Return
			return oDecorator;
		}

		// Set Request Context in storage
		setContext( oContext );

		// Return Context
		return oContext;
	}

}