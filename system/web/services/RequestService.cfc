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
			instance.logger = controller.getLogBox().getLogger(this);
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Request Capture --->
	<cffunction name="requestCapture" access="public" returntype="any" output="false" hint="I capture an incoming request. Returns: coldbox.system.web.context.RequestContext">
		<cfscript>
			var context 		= getContext();
			var debugPassword 	= controller.getSetting("debugPassword");
			var eventName 		= controller.getSetting("EventName");
			
			// Capture FORM/URL
			initFORMURL();
			context.collectionAppend(FORM);
			context.collectionAppend(URL);
			
			// Do we have flash elements to inflate?
			if( getFlashScope().flashExists() ){
				instance.logger.debug("Flash RAM detected, inflating flash...");
				getFlashScope().inflateFlash();
			}
					
			// Object Caching Garbage Collector, check if using cachebox first
			if( isObject(controller.getCacheBox()) ){
				controller.getCacheBox().reapAll();
			}
			else{
				// Compat mode, remove this at release
				controller.getColdboxOCM().reap();
			}
			
			// Debug Mode Checks
			if ( Context.valueExists("debugMode") and isBoolean(Context.getValue("debugMode")) ){
				if ( DebugPassword eq ""){
					controller.getDebuggerService().setDebugMode(Context.getValue("debugMode"));
				}
				else if ( Context.valueExists("debugpass") and CompareNoCase(DebugPassword,Context.getValue("debugpass")) eq 0 ){
					controller.getDebuggerService().setDebugMode(Context.getValue("debugMode"));
				}
			}

			// Default Event Definition
			if ( not Context.valueExists(EventName))
				Context.setValue(EventName, controller.getSetting("DefaultEvent"));
			// Event More Than 1 Check, grab the first event instance, other's are discarded
			if ( listLen(Context.getValue(EventName)) gte 2 )
				Context.setValue(EventName, getToken(Context.getValue(EventName),2,","));
			
			// Default Event Action Checks
			controller.getHandlerService().defaultEventCheck(Context);
			
			// Are we using event caching?
			eventCachingTest(Context);
			
			return Context;
		</cfscript>
	</cffunction>

	<!--- Event caching test --->
	<cffunction name="eventCachingTest" access="public" output="false" returntype="void" hint="Tests if the incoming context is an event cache">
		<!--- ************************************************************* --->
		<cfargument name="context" 			required="true"  type="any" hint="The request context to test for event caching.">
		<!--- ************************************************************* --->
		<cfscript>
			var eventCacheKey   = "";
			var oEventURLFacade = controller.getColdboxOCM("template").getEventURLFacade();
			var eventDictionary = 0;
			var oOCM 		    = controller.getColdboxOCM("template");
			var currentEvent    = arguments.context.getCurrentEvent();
			
			// Are we using event caching?
			if ( controller.getSetting("EventCaching") ){
				// Cleanup the cache key, just in case, maybe ses interceptor has been used.
				arguments.context.removeEventCacheableEntry();
					
				// Get Entry
				eventDictionary = controller.getHandlerService().getEventMetaDataEntry(currentEvent);	
				
				// Verify that it is cacheable, else quit, no need for testing anymore.
				if( NOT eventDictionary.cacheable ){
					return;	
				}
				
				// setup the cache key.
				eventCacheKey = oEventURLFacade.buildEventKey(keySuffix=eventDictionary.suffix,
															  targetEvent=currentEvent,
															  targetContext=arguments.context);
				// Check for Event Cache Purge
				if ( Context.valueExists("fwCache") ){
					// Clear the key from the cache
					oOCM.clearKey( eventCacheKey );
					return;
				}
				
				// Event has been found, flag it so we can render it from cache if it still survives
				arguments.context.setEventCacheableEntry(eventCacheKey);
				
				instance.logger.debug("Event caching detected: #eventCacheKey.toString()#");
				
			}//If using event caching.
		</cfscript>
	</cffunction>
	
	<!--- Get the Context --->
	<cffunction name="getContext" access="public" output="false" returntype="any" hint="Get the Request Context from request scope or create a new one.">
		<cfscript>
			if ( structKeyExists(request,"cb_requestContext") )
				return request.cb_requestContext;
			else
				return createContext();
		</cfscript>
	</cffunction>

	<!--- Set the context --->
	<cffunction name="setContext" access="public" output="false" returntype="void" hint="Set the Request Context">
		<cfargument name="Context" type="any" required="true">
		<cfscript>
			instance.logger.debug("Request Context set on request scope");
			request.cb_requestContext = arguments.Context;
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
	
	<cffunction name="initFORMURL" access="private" returntype="void" hint="param form/url" output="false" >
		<cfparam name="FORM" default="#structNew()#">
		<cfparam name="URL"  default="#structNew()#">		
	</cffunction>
	
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