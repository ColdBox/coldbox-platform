<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
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
			setController(arguments.controller);			
			
			instance.flashScope 		= 0;
			instance.decorator			= "";
			
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- INTERNAL COLDBOX EVENTS ------------------------------------------->
	
	<cffunction name="onConfigurationLoad" access="public" output="false" returntype="void">
		<cfscript>
			// Let's determine the flash type and create our flash ram object
			var flashType = controller.getSetting("FlashURLPersistScope");
			var flashPath = flashType;
			
			// Shorthand Flash Types
			switch(flashType){
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
			}
			
			// Create Flash RAM object
			instance.flashScope = createObject("component",flashPath).init(controller);
			
			// Request Context Decorator?
			if ( controller.settingExists("RequestContextDecorator") and len(controller.getSetting("RequestContextDecorator")) ){
				instance.decorator = controller.getSetting("RequestContextDecorator");
			}
			
			//Get Local Logger Configured
			instance.log = controller.getLogBox().getLogger(this);
			// Local Configuration data and dependencies
			instance.debugPassword  	= controller.getSetting("debugPassword");
			instance.eventName			= controller.getSetting("eventName");
			instance.eventCaching		= controller.getSetting("EventCaching");
			instance.interceptorService = controller.getInterceptorService();
			instance.handlerService		= controller.getHandlerService();
			instance.cacheBox			= controller.getCacheBox();
			instance.cache				= controller.getColdBoxOCM();
			instance.templateCache		= controller.getColdBoxOCM("template");
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Request Capture --->
	<cffunction name="requestCapture" access="public" returntype="any" output="false" hint="I capture an incoming request. Returns: coldbox.system.web.context.RequestContext" colddoc:generic="coldbox.system.web.context.RequestContext">
		<cfscript>
			var context 	= getContext();
			var rc			= context.getCollection();
			var prc 		= context.getCollection(private=true);
			
			// Capture FORM/URL
			if( isDefined("FORM") ){ structAppend(rc, FORM); }
			if( isDefined("URL")  ){ structAppend(rc, URL); }
			
			// Execute onRequestCapture interceptionPoint
			instance.interceptorService.processState("onRequestCapture");
			
			// Take snapshot of incoming collection
			prc["cbox_incomingContextHash"] = hash(rc.toString());
			
			// Do we have flash elements to inflate?
			if( instance.flashScope.flashExists() ){
				if( instance.log.canDebug() ){
					instance.log.debug("Flash RAM detected, inflating flash...");
				}
				instance.flashScope.inflateFlash();
			}
					
			// Object Caching Garbage Collector, check if using cachebox first
			if( isObject( instance.cacheBox ) ){
				instance.cacheBox.reapAll();
			}
			else{
				// Compat mode, remove this at release
				instance.cache.reap();
			}
			
			// Debug Mode Checks
			if ( structKeyExists(rc,"debugMode") AND isBoolean(rc.debugMode) ){
				if ( NOT len(instance.debugPassword) ){
					controller.getDebuggerService().setDebugMode( rc.debugMode );
				}
				else if ( structKeyExists(rc,"debugpass") AND CompareNoCase(instance.debugPassword, hash(rc.debugpass) ) eq 0 ){
					controller.getDebuggerService().setDebugMode( rc.debugMode );
				}
			}

			// Default Event Determination
			if ( NOT structKeyExists(rc, instance.eventName)){
				rc[instance.eventName] = controller.getSetting("DefaultEvent");
			}
			
			// Event More Than 1 Check, grab the first event instance, other's are discarded
			if ( listLen( rc[instance.eventName] ) GTE 2 ){
				rc[instance.eventName] = getToken( rc[instance.eventName], 2, ",");
			}
			
			// Default Event Action Checks
			instance.handlerService.defaultEventCheck(context);
			
			// Are we using event caching?
			eventCachingTest(context);
			
			return context;
		</cfscript>
	</cffunction>

	<!--- Event caching test --->
	<cffunction name="eventCachingTest" access="public" output="false" returntype="void" hint="Tests if the incoming context is an event cache">
		<cfargument name="context" 	required="true"  type="any" hint="The request context to test for event caching." colddoc:generic="coldbox.system.web.context.RequestContext">
		<cfscript>
			var eventCacheKey   = "";
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
				eventCacheKey = oEventURLFacade.buildEventKey(keySuffix=eventDictionary.suffix,
															  targetEvent=currentEvent,
															  targetContext=arguments.context);
				// Check for Event Cache Purge
				if ( context.valueExists("fwCache") ){
					// Clear the key from the cache
					instance.templateCache.clearKey( eventCacheKey );
					return;
				}
				
				// Event has been found, flag it so we can render it from cache if it still survives
				arguments.context.setEventCacheableEntry(eventCacheKey);
				
				// debug logging
				if( instance.log.canDebug() ){
					instance.log.debug("Event caching detected for : #eventCacheKey.toString()#");
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
	<cffunction name="setContext" access="public" output="false" returntype="void" hint="Set the Request context">
		<cfargument name="context" type="any" required="true">
		<cfscript>
			request.cb_requestContext = arguments.context;
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
	
<!------------------------------------------- PRIVATE ------------------------------------------->
	
	<!--- Creates a new Context Object --->
	<cffunction name="createContext" access="private" output="false" returntype="any" hint="Creates a new request context object">
		<cfscript>
		var oContext = "";
		var oDecorator = "";
		
		//Create the original request context
		oContext = CreateObject("component","coldbox.system.web.context.RequestContext").init(controller.getConfigSettings());
		
		//Determine if we have a decorator, if we do, then decorate it.
		if ( len(instance.decorator) ){
			//Create the decorator
			oDecorator = CreateObject("component",instance.decorator).init(oContext,controller);
			//Set Request Context in storage
			setContext(oDecorator);
			//Return
			return oDecorator;
		}
		
		//Set Request Context in storage
		setContext(oContext);
		
		//Return Context
		return oContext;
		</cfscript>
	</cffunction>

</cfcomponent>