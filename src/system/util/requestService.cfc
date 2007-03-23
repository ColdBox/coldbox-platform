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
<cfcomponent name="requestService" output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cfscript>
		//Controller Reference
		variables.controller = "";
	</cfscript>

	<cffunction name="init" access="public" output="false" returntype="any" hint="Constructor">
		<cfargument name="controller" type="any" required="true">
		<cfscript>
			variables.controller = arguments.controller;
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<cffunction name="requestCapture" access="public" returntype="void" output="false" hint="I capture a request.">
		<cfscript>
			var Context = createContext();
			var DebugPassword = controller.getSetting("debugPassword");

			//Debug Mode Checks
			if ( Context.valueExists("debugMode") and isBoolean(Context.getValue("debugMode")) ){
				if ( DebugPassword eq "")
					controller.getDebuggerService().setDebugMode(Context.getValue("debugMode"));
				else if ( Context.valueExists("debugpass") and CompareNoCase(DebugPassword,Context.getValue("debugpass")) eq 0 )
					controller.getDebuggerService().setDebugMode(Context.getValue("debugMode"));
			}

			//Event Checks
			//Default Event Definition
			if ( not Context.valueExists("event"))
				Context.setValue("event", controller.getSetting("DefaultEvent"));
			//Event More Than 1 Check, grab the first event instance, other's are discarded
			if ( listLen(Context.getValue("event")) gte 2 )
				Context.setValue("event", getToken(Context.getValue("event"),2,","));

			//Set Request Context in storage
			setContext(Context);
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
		<cfargument name="Context" type="coldbox.system.beans.RequestContext" required="true">
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
		var ViewLayouts = structNew();

		if ( controller.settingExists("DefaultLayout") ){
			DefaultLayout = controller.getSetting("DefaultLayout");
		}
		if ( controller.settingExists("ViewLayouts") ){
			ViewLayouts = controller.getSetting("ViewLayouts");
		}
		return CreateObject("component","coldbox.system.beans.RequestContext").init(FORM, URL, DefaultLayout, ViewLayouts);
		</cfscript>
	</cffunction>

</cfcomponent>