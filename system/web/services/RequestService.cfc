<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date        :	January 18, 2007
Description :
	This cfc takes care of request context operations such as
	creating new contexts, retrieving, clearing, etc.

Modification History:
01/18/2007 - Created
----------------------------------------------------------------------->
<cfcomponent name="RequestService" output="false" hint="This service takes care of preparing and creating request contexts. Facades to FORM and URL" extends="coldbox.system.web.services.BaseService">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" output="false" returntype="RequestService" hint="Constructor">
		<cfargument name="controller" type="any" required="true" hint="Coldbox controller">
		<cfscript>
			setController( arguments.controller );

			instance.flashScope 	= "";
			instance.flashData 		= "";
			instance.flashDataHash 	= "";

			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- INTERNAL COLDBOX EVENTS ------------------------------------------->

	<cffunction name="onConfigurationLoad" access="public" output="false" returntype="void">
		<cfscript>
			// Local Configuration data and dependencies
			instance.log 				= controller.getLogBox().getLogger( this );
			instance.eventName			= controller.getSetting( "eventName" );
			instance.eventCaching		= controller.getSetting( "eventCaching" );
			instance.interceptorService = controller.getInterceptorService();
			instance.handlerService		= controller.getHandlerService();
			instance.cacheBox			= controller.getCacheBox();
			instance.cache				= controller.getCache();
			instance.templateCache		= controller.getCache( "template" );
			instance.flashData 			= controller.getSetting( "flash" );
			instance.flashDataHash		= hash( instance.flashData.toString() );
			
			// build out Flash RAM
			buildFlashScope();
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Request Capture --->
	<cffunction name="requestCapture" access="public" returntype="any" output="false" hint="I capture an incoming request. Returns: coldbox.system.web.context.RequestContext" colddoc:generic="coldbox.system.web.context.RequestContext">
		<cfscript>
			var context 	= getContext();
			var rc			= context.getCollection();
			var prc 		= context.getCollection(private=true);
			var fwCache		= false;

			// Capture FORM/URL
			if( isDefined( "FORM" ) ){ structAppend( rc, FORM ); }
			if( isDefined( "URL" )  ){ structAppend( rc, URL ); }

			// Configure decorator if available?
			if ( structKeyExists( context, "configure" ) ){ context.configure(); }

			// Execute onRequestCapture interceptionPoint
			instance.interceptorService.processState( "onRequestCapture" );

			// Remove FW reserved commands just in case before collection snapshot
			fwCache = structKeyExists( rc,"fwCache" );
			structDelete( rc, "fwCache" );

			// Take snapshot of incoming collection
			prc[ "cbox_incomingContextHash" ] = hash( rc.toString() );

			// Do we have flash elements to inflate?
			if( instance.flashScope.flashExists() ){
				if( instance.log.canDebug() ){
					instance.log.debug("Flash RAM detected, inflating flash...");
				}
				instance.flashScope.inflateFlash();
			}

			// Object Caching Garbage Collector
			instance.cacheBox.reapAll();

			// Default Event Determination
			if ( NOT structKeyExists( rc, instance.eventName ) ){
				rc[ instance.eventName ] = controller.getSetting( "DefaultEvent" );
			}

			// Event More Than 1 Check, grab the first event instance, other's are discarded
			if ( listLen( rc[ instance.eventName ] ) GTE 2 ){
				rc[ instance.eventName ] = getToken( rc[ instance.eventName ], 2, ",");
			}

			// Default Event Action Checks
			instance.handlerService.defaultEventCheck( context );

			// Are we using event caching?
			eventCachingTest( context, fwCache );

			return context;
		</cfscript>
	</cffunction>

	<!--- Event caching test --->
	<cffunction name="eventCachingTest" access="public" output="false" returntype="void" hint="Tests if the incoming context is an event cache">
		<cfargument name="context" 	required="true"  type="any" hint="The request context to test for event caching." colddoc:generic="coldbox.system.web.context.RequestContext">
		<cfargument name="fwCache"  required="false" type="any" default="false" hint="If the fwCache command was detected" colddoc:generic="boolean"/>
		<cfscript>
			var eventCache   	= structnew();
			var oEventURLFacade = instance.templateCache.getEventURLFacade();
			var eventDictionary = 0;
			var currentEvent    = arguments.context.getCurrentEvent();

			// Are we using event caching?
			if ( instance.eventCaching ){
				// Cleanup the cache key, just in case, maybe ses interceptor has been used.
				arguments.context.removeEventCacheableEntry();

				// Get metadata entry for event that's fired.
				eventDictionary = instance.handlerService.getEventMetaDataEntry(currentEvent);

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
					instance.templateCache.clear( eventCache.cacheKey );
					return;
				}

				// Event has been found, flag it so we can render it from cache if it still survives
				arguments.context.setEventCacheableEntry( eventCache );

				// debug logging
				if( instance.log.canDebug() ){
					instance.log.debug("Event caching detected for : #eventCache.toString()#");
				}

			}//end if using event caching.
		</cfscript>
	</cffunction>

	<!--- Get the context --->
	<cffunction name="getContext" access="public" output="false" returntype="any" hint="Get the Request context from request scope or create a new one.">
		<cfscript>
			if ( structKeyExists(request,"cb_requestContext") ){ return request.cb_requestContext; }
			return createContext();
		</cfscript>
	</cffunction>

	<!--- Set the context --->
	<cffunction name="setContext" access="public" output="false" returntype="any" hint="Set the Request context">
		<cfargument name="context" type="any" required="true">
		<cfscript>
			request.cb_requestContext = arguments.context;
			return this;
		</cfscript>
	</cffunction>

	<!--- removeContext --->
    <cffunction name="removeContext" output="false" access="public" returntype="any" hint="Remove the context from scope and return yourself">
    	<cfscript>
			structDelete(request, "cb_requestContext");
			return this;
    	</cfscript>
    </cffunction>

	<!--- Check if context exists --->
	<cffunction name="contextExists" access="public" output="false" returntype="boolean" hint="Does the request context exist">
		<cfscript>
			return structKeyExists(request,"cb_requestContext");
		</cfscript>
	</cffunction>

	<!--- getFlashScope --->
    <cffunction name="getFlashScope" output="false" access="public" returntype="any" hint="Get the current running Flash Ram Scope of base type:coldbox.system.web.flash.AbstractFlashScope">
   		<cfreturn instance.flashScope >
    </cffunction>

    <!--- rebuildFlashScope --->
    <cffunction name="rebuildFlashScope" output="false" access="public" returntype="any" hint="Rebuild's the Flash RAM Scope if the application spec has changed, else it ignores it.">
   		<cfscript>
   			if( instance.flashDataHash neq hash( controller.getSetting( "flash" ).toString() ) ){
   				buildFlashScope();
	   		}
   		</cfscript>
   	</cffunction>

    <!--- buildFlashScope --->
    <cffunction name="buildFlashScope" output="false" access="public" returntype="any" hint="Build's the Flash RAM Scope as defined in the application spec.">
   		<cfscript>
   			var flashPath 	= "";

			// Shorthand Flash Types
			switch( instance.flashData.scope ){
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
					flashPath = instance.flashData.scope;
				}
			}

			// Create Flash RAM object
			instance.flashScope = createObject( "component", flashPath ).init( controller, instance.flashData );
   		</cfscript>
    </cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->

	<!--- Creates a new Context Object --->
	<cffunction name="createContext" access="private" output="false" returntype="any" hint="Creates a new request context object">
		<cfscript>
		var oContext = "";
		var oDecorator = "";

		// Create the original request context
		oContext = CreateObject("component","coldbox.system.web.context.RequestContext").init( properties=controller.getConfigSettings(), controller=controller );

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
		</cfscript>
	</cffunction>

</cfcomponent>