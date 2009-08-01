<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date        :	January 18, 2007
Description :
	This cfc takes care of request context operations such as
	creating new contexts, retrieving, clearing, etc.

Modification History:
01/18/2007 - Created
----------------------------------------------------------------------->
<cfcomponent name="RequestService" output="false" hint="This service takes care of preparing and creating request contexts. Facades to FORM and URL" extends="coldbox.system.services.BaseService">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" output="false" returntype="RequestService" hint="Constructor">
		<cfargument name="controller" type="any" required="true" hint="Coldbox controller">
		<cfscript>
			setController(arguments.controller);			
			
			instance.contextProperties = structnew();
		
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Request Capture --->
	<cffunction name="requestCapture" access="public" returntype="any" output="false" hint="I capture an incoming request. Returns: coldbox.system.beans.RequestContext">
		<cfscript>
			var Context = getContext();
			var DebugPassword = controller.getSetting("debugPassword");
			var EventName = controller.getSetting("EventName");
			var oFlashStorage = "";
			
			// Get Flash Persistance Storage
			if( controller.getSetting("FlashURLPersistScope",1) eq "session" ){
				oFlashStorage = controller.getPlugin("SessionStorage");
			}
			else{
				// Get Client Storage
				oFlashStorage = controller.getPlugin("ClientStorage");				
			}
			
			// Flash Persistance Contruction	
			if ( oFlashStorage.exists('_coldbox_persistStruct') ){
				// Append flash persistance structure and overwrite if needed.
				Context.collectionAppend(oFlashStorage.getVar('_coldbox_persistStruct'),true);
				// Remove Flash persistance
				oFlashStorage.deleteVar('_coldbox_persistStruct');
			}	
					
			// Object Caching Garbage Collector
			controller.getColdboxOCM().reap();
				
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
			var eventCacheKey = "";
			var oEventURLFacade = controller.getColdboxOCM().getEventURLFacade();
			var eventDictionary = 0;
			var oOCM = controller.getColdboxOCM();
			var currentEvent = arguments.context.getCurrentEvent();
			
			// Are we using event caching?
			if ( controller.getSetting("EventCaching") ){
				// Cleanup the cache key, just in case, maybe ses interceptor has been used.
				arguments.context.removeEventCacheableEntry();
					
				// Get Entry
				eventDictionary = controller.getHandlerService().getEventMetaDataEntry(currentEvent);	
				
				// Verify that it is cacheable, else quit, no need for testing anymore.
				if( not eventDictionary.cacheable ){
					return;	
				}
				
				// setup the cache key.
				eventCacheKey = oEventURLFacade.buildEventKey(keySuffix=eventDictionary.suffix,
															  targetEvent=currentEvent,
															  targetContext=arguments.context);
				// Check for Event Cache Purge
				if ( Context.valueExists("fwCache") ){
					/* Clear the key from the cache */
					oOCM.clearKey( eventCacheKey );
				}
				// Determine if this event has been cached
				else if ( oOCM.lookup(eventCacheKey) ){
					// Event has been found, flag it so we can render it
					arguments.context.setEventCacheableEntry(eventCacheKey);
				}//end else no purging
				
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
			request.cb_requestContext = arguments.Context;
		</cfscript>
	</cffunction>

	<!--- Check if context exists --->
	<cffunction name="contextExists" access="public" output="false" returntype="boolean" hint="Does the request context exist">
		<cfscript>
			return structKeyExists(request,"cb_requestContext");
		</cfscript>
	</cffunction>
	
	<!--- Get / Set context properties --->
	<cffunction name="getContextProperties" access="public" output="false" returntype="struct" hint="Get ContextProperties">
		<cfreturn instance.ContextProperties/>
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
		
		// Param FORM/URL
		initFORMURL();
		loadProperties();
		//Create the original request context
		oContext = CreateObject("component","coldbox.system.beans.RequestContext").init(FORM,URL,instance.ContextProperties);
		
		//Determine if we have a decorator, if we do, then decorate it.
		if ( instance.ContextProperties.isUsingDecorator ){
			//Create the decorator
			oDecorator = CreateObject("component",instance.ContextProperties.decorator).init(oContext,controller);
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
	
	<!--- Lazy Load Context Properties --->
	<cffunction name="loadProperties" access="private" returntype="void" hint="Load the context properties" output="false" >
		<cfscript>
			var properties = structnew();
			
			if( structIsEmpty(instance.contextProperties) ){
				properties.DefaultLayout = "";
				properties.DefaultView = "";
				properties.ViewLayouts = structNew();
				properties.FolderLayouts = structNew();
				properties.EventName = "";
				properties.isSES = false;
				properties.sesbaseURL = "";
				properties.decorator = "";
				properties.isUsingDecorator = false;
				
				if( controller.settingExists("EventName") ){
					Properties.EventName = controller.getSetting("EventName");
				}		
				if ( controller.settingExists("DefaultLayout") ){
					Properties.DefaultLayout = controller.getSetting("DefaultLayout");
				}
				if ( controller.settingExists("DefaultView") ){
					Properties.DefaultView = controller.getSetting("DefaultView");
				}
				if ( controller.settingExists("ViewLayouts") ){
					Properties.ViewLayouts = controller.getSetting("ViewLayouts");
				}
				if ( controller.settingExists("FolderLayouts") ){
					Properties.FolderLayouts = controller.getSetting("FolderLayouts");
				}
				if( controller.settingExists("sesbaseURL") ){
					Properties.sesbaseurl = controller.getSetting('sesBaseURL');
				}
				if ( controller.settingExists("RequestContextDecorator") and controller.getSetting("RequestContextDecorator") neq ""){
					Properties.isUsingDecorator = true;
					Properties.decorator = controller.getSetting("RequestContextDecorator");
				}
				
				instance.contextProperties = Properties;	
			}
		</cfscript>
	</cffunction>

</cfcomponent>