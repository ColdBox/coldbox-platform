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

	<cffunction name="requestCapture" access="public" returntype="any" output="false" hint="I capture a request.">
		<cfscript>
			var Context = createContext();
			var DebugPassword = controller.getSetting("debugPassword");
			var EventName = controller.getSetting("EventName");
			var oSessionStorage = controller.getPlugin("sessionstorage");
					
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

			//Event Checks
			//Default Event Definition
			if ( not Context.valueExists(EventName))
				Context.setValue(EventName, controller.getSetting("DefaultEvent"));
			//Event More Than 1 Check, grab the first event instance, other's are discarded
			if ( listLen(Context.getValue(EventName)) gte 2 )
				Context.setValue(EventName, getToken(Context.getValue(EventName),2,","));

			//Set Request Context in storage
			setContext(Context);
			
			//Return Context
			return getContext();
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

	<cffunction name="createContext" access="private" output="false" returntype="any" hint="Creates a new request context object">
		<cfscript>
		var DefaultLayout = "";
		var DefaultView = "";
		var ViewLayouts = structNew();
		var EventName = controller.getSetting("EventName");
		
		if ( controller.settingExists("DefaultLayout") ){
			DefaultLayout = controller.getSetting("DefaultLayout");
		}
		if ( controller.settingExists("DefaultView") ){
			DefaultView = controller.getSetting("DefaultView");
		}
		if ( controller.settingExists("ViewLayouts") ){
			ViewLayouts = controller.getSetting("ViewLayouts");
		}
		//Return context.
		return CreateObject("component","coldbox.system.beans.requestContext").init(FORM,URL,DefaultLayout,DefaultView,ViewLayouts,EventName);
		</cfscript>
	</cffunction>
			
</cfcomponent>