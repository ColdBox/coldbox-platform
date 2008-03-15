<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
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
<cfcomponent name="requestService" output="false" hint="This service takes care of preparing and creating request contexts. Facades to FORM and URL" extends="baseService">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" output="false" returntype="requestService" hint="Constructor">
		<cfargument name="controller" type="any" required="true">
		<cfscript>
			setController(arguments.controller);
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Request Capture --->
	<cffunction name="requestCapture" access="public" returntype="any" output="false" hint="I capture a request.">
		<cfscript>
			var Context = createContext();
			var DebugPassword = controller.getSetting("debugPassword");
			var EventName = controller.getSetting("EventName");
			var oSessionStorage = controller.getPlugin("sessionStorage");
					
			//Object Caching Garbage Collector
			controller.getColdboxOCM().reap();
			
			//Flash Persistance Reconstruction
			if ( oSessionStorage.exists('_coldbox_persistStruct') ){
				//Append flash persistance structure and overwrite if needed.
				Context.collectionAppend(oSessionStorage.getVar('_coldbox_persistStruct'),true);
				//Remove Flash persistance
				oSessionStorage.deleteVar('_coldbox_persistStruct');
			}

			//Debug Mode Checks
			if ( Context.valueExists("debugMode") and isBoolean(Context.getValue("debugMode")) ){
				if ( DebugPassword eq "")
					controller.getDebuggerService().setDebugMode(Context.getValue("debugMode"));
				else if ( Context.valueExists("debugpass") and CompareNoCase(DebugPassword,Context.getValue("debugpass")) eq 0 )
					controller.getDebuggerService().setDebugMode(Context.getValue("debugMode"));
			}

			//Default Event Definition
			if ( not Context.valueExists(EventName))
				Context.setValue(EventName, controller.getSetting("DefaultEvent"));
			//Event More Than 1 Check, grab the first event instance, other's are discarded
			if ( listLen(Context.getValue(EventName)) gte 2 )
				Context.setValue(EventName, getToken(Context.getValue(EventName),2,","));
			
			/* Are we using event caching? */
			EventCachingTest(Context);
			
			//Set Request Context in storage
			setContext(Context);
			
			//Return Context
			return getContext();
		</cfscript>
	</cffunction>

	<cffunction name="EventCachingTest" access="public" output="false" returntype="void" hint="Tests if the incoming context is an event cache">
		<cfargument name="context" required="true" type="any" hint="">
		<cfscript>
			var eventCacheKey = "";
			/* Are we using event caching? */
			if ( controller.getSetting("EventCaching") ){	
				
				/* Check for Event Cache Purge */
				if ( Context.valueExists("fwCache") ){
					/* Clear the cache key. */
					eventCacheKey = controller.getHandlerService().EVENT_CACHEKEY_PREFIX & Context.getCurrentEvent() & "-" & controller.getColdboxOCM().getEventURLFacade().getUniqueHash(Context.getCurrentEvent());
					controller.getColdboxOCM().clearKey( eventCacheKey );
				}
				else{
					/* Setup the cache key */
					eventCacheKey = controller.getHandlerService().EVENT_CACHEKEY_PREFIX & Context.getCurrentEvent() & "-" & controller.getColdboxOCM().getEventURLFacade().getUniqueHash(Context.getCurrentEvent());
					/* Cleanup the cache key, just in case. */
					Context.removeValue('cbox_eventCacheableEntry');
					/* Determine if this event has been cached */
					if ( controller.getColdboxOCM().lookup(eventCacheKey) ){
						/* Event has been found, flag it so we can render it */
						Context.setEventCacheableEntry(eventCacheKey);
					}
				}//end else no purging
			}//If using event caching.
		</cfscript>
	</cffunction>
	
	<cffunction name="getContext" access="public" output="false" returntype="any" hint="Get the Request Context">
		<cfscript>
			if ( contextExists() )
				return request.cb_requestContext;
			else
				return createContext();
		</cfscript>
	</cffunction>

	<cffunction name="setContext" access="public" output="false" returntype="void" hint="Set the Request Context">
		<cfargument name="Context" type="coldbox.system.beans.requestContext" required="true">
		<cfscript>
			request.cb_requestContext = arguments.Context;
		</cfscript>
	</cffunction>

	<cffunction name="contextExists" access="public" output="false" returntype="boolean" hint="Does the request context exist">
		<cfscript>
			return structKeyExists(request,"cb_requestContext");
		</cfscript>
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------->

	<!--- Creates a new Context Object --->
	<cffunction name="createContext" access="private" output="false" returntype="any" hint="Creates a new request context object">
		<cfscript>
		var DefaultLayout = "";
		var DefaultView = "";
		var ViewLayouts = structNew();
		var FolderLayouts = structNew();
		var EventName = "";
		var oContext = "";
		var oDecorator = "";
		
		//EventName default
		if( controller.settingExists("EventName") ){
			EventName = controller.getSetting("EventName");
		}
		
		if ( controller.settingExists("DefaultLayout") ){
			DefaultLayout = controller.getSetting("DefaultLayout");
		}
		if ( controller.settingExists("DefaultView") ){
			DefaultView = controller.getSetting("DefaultView");
		}
		if ( controller.settingExists("ViewLayouts") ){
			ViewLayouts = controller.getSetting("ViewLayouts");
		}
		if ( controller.settingExists("FolderLayouts") ){
			FolderLayouts = controller.getSetting("FolderLayouts");
		}
		
		</cfscript>
		
		<!--- Param the structures --->
		<cfparam name="FORM" default="#structNew()#">
		<cfparam name="URL"  default="#structNew()#">		
		
		<cfscript>		
		//Create the original request context
		oContext = CreateObject("component","coldbox.system.beans.requestContext").init(FORM,URL,DefaultLayout,DefaultView,EventName,ViewLayouts,FolderLayouts);
		
		//Determine if we have a decorator, if we do, then decorate it.
		if ( controller.settingExists("RequestContextDecorator") and controller.getSetting("RequestContextDecorator") neq ""){
			//Create the decorator
			oDecorator = CreateObject("component",controller.getSetting("RequestContextDecorator")).init(oContext);
			//Return
			return oDecorator;
		}
		//Return Context
		return oContext;
		</cfscript>
	</cffunction>

</cfcomponent>