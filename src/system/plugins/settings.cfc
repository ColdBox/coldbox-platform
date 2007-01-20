<!-----------------------------------------------------------------------
Copyright 2005 - 2006 ColdBox Framework by Luis Majano
www.coldboxframework.com | www.coldboxframework.org
-------------------------------------------------------------------------

Author 	 :	Luis Majano
Date     :	September 23, 2005
Description :
	The ColdBox settings plugin. Handles most of the framwork's internal settings
	and handlers

Modification History:
07/10/2006 - Updated the custom exception handler to retrieve an exception bean
			 from the request collection.
08/01/2006 - Coldbox Logs support.
01/18/2007 - New registration methods. Getting ready for the event chaining.
----------------------------------------------------------------------->
<cfcomponent name="settings" hint="Coldbox settings object." extends="coldbox.system.plugin">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="any" output="false">
		<cfset super.Init() />
		<cfset variables.instance.pluginName = "Settings">
		<cfset variables.instance.pluginVersion = "1.0">
		<cfset variables.instance.pluginDescription = "This plugin is used to control several of the framework settings and aspects.">
		<cfreturn this>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- ************************************************************* --->
	
	<cffunction name="configLoader" returntype="void" access="Public" hint="I Load the configurations and init the framework variables. I have a facade to the application scope." output="false">
		<cfscript>
		var XMLParser = getPlugin("XMLParser");
		var ConfigFileLocation = "";
		var ConfigTimeStamp = "";
		var HandlersDirectory = "";
		
		//<!--- Load Coldbox Config Structure --->
		application.ColdBox_FWSettingsStruct = XMLParser.loadFramework();
		//<!--- Load Config from XML --->
		application.ColdBox_configStruct = XMLParser.parseConfig();
		//<!---Load i18N if needed --->
		if ( getSetting("using_i18N") )
			getPlugin("i18n").init_i18N(getSetting("DefaultResourceBundle"),getSetting("DefaultLocale"));
		
		//<!--- Test for Coldbox logging, if set init the log location --->
		if ( getSetting("EnableColdboxLogging") )
			getPlugin("logger").initLogLocation();
		
		//<!--- Flag the initiation --->
		application.ColdBox_fwInitiated = true;
		application.ColdBox_fwAppStartHandlerFired = false;
		</cfscript>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="registerHandlers" access="public" returntype="void" hint="I register your application's event handlers" output="false">
		<cfset var HandlersPath = getSetting("HandlersPath")>
		<cfset var Handlers = ArrayNew(1)>
		<cfset var HandlerListing = "">
		
		<!--- Check for Handlers Directory Location --->
		<cfif not directoryExists(HandlersPath)>
			<cfthrow type="Framework.plugins.settings.HandlersDirectoryNotFoundException" message="The handlers directory: #handlerspath# does not exist please check your application structure or your Application Mapping.">
		</cfif>
		
		<!--- Get Handlers to register --->
		<cfdirectory action="list" recurse="true" directory="#HandlersPath#" name="HandlerListing" filter="*.cfc">
		
		<!--- Verify handler's found, else, why continue --->
		<cfif not HandlerListing.recordcount>
			<cfthrow type="Framework.plugins.settings.NoHandlersFoundException" message="No handlers were found in: #HandlerPath#. So I have no clue how you are going to run this application.">
		</cfif>
		
		<!--- Register Handlers --->
		<cfloop query="HandlerListing">
			<cfset HandlerListing.directory = replacenocase(HandlerListing.directory,HandlersPath,"","all")>
			<cfset HandlerListing.directory = removeChars(replacenocase(HandlerListing.directory,"/",".","all") & ".",1,1)>
			<cfset HandlerListing.name = ripExtension(HandlerListing.name)>
			<cfset arrayappend(Handlers, HandlerListing.directory & HandlerListing.name)>
		</cfloop>

		<!--- Sort The Array --->
		<cfset ArraySort(Handlers,"text")>
		
		<!--- Set registered Handlers --->
		<cfset setSetting("RegisteredHandlers",arrayToList(Handlers))>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="getRegisteredHandler" access="public" hint="I get a registered handler and method according to passed event from the registeredHandlers setting." returntype="any"  output="false">
		<!--- ************************************************************* --->
		<cfargument name="event" hint="The event to check and get." type="string" required="true">
		<!--- ************************************************************* --->
		<cfscript>
		var handlerIndex = 0;
		var HandlerReceived = "";
		var MethodReceived = "";
		var handlersList = getSetting("RegisteredHandlers");
		var onInvalidEvent = getSetting("onInvalidEvent");
		var HandlerBean = getPlugin("beanFactory").create("coldbox.system.beans.eventhandlerBean").init(getSetting("HandlersInvocationPath"));
		
		//Rip the method
		HandlerReceived = ripExtension(arguments.event);
		MethodReceived = listLast(arguments.event,".");
		
		//Check Registration
		handlerIndex = listFindNoCase(handlersList, HandlerReceived);
		
		//Check for registration results
		if ( handlerIndex ){
			HandlerBean.setHandler(listgetAt(handlersList,handlerIndex));
			HandlerBean.setMethod(MethodReceived);
		}
		else if ( onInvalidEvent neq "" ){
				//Check if the invalid event is the same as the current event
				if ( CompareNoCase(onInvalidEvent,arguments.event) eq 0){
					throw("The invalid event handler: #onInvalidEvent# is also invalid. Please check your settings","","Framework.plugins.settings.InvalidEventHandlerException");
				}
				else{
					HandlerBean.setHandler(ripExtension(onInvalidEvent));
					HandlerBean.setMethod(listLast(onInvalidEvent,"."));
				}
			}
		else{
			throw("The event handler: #arguments.event# is not valid registered event.","","Framework.plugins.settings.EventHandlerNotRegisteredException");
		}
		return HandlerBean;
		</cfscript>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="ExceptionHandler" access="public" hint="I handle a framework/application exception. I return a framework exception bean" returntype="any" output="false">
		<!--- ************************************************************* --->
		<cfargument name="Exception" 	 type="any"     required="true"  hint="The exception structure">
		<cfargument name="ErrorType" 	 type="any" 	required="false" default="application">
		<cfargument name="ExtraMessage"  type="string"  required="false" default="">
		<!--- ************************************************************* --->
		<cfscript>
		var BugReport = "";
		var ExceptionBean = getPlugin("beanFactory").create("coldbox.system.beans.exceptionBean").init(errorStruct=arguments.Exception,extramessage=arguments.extraMessage,errorType=arguments.ErrorType);
		
		// Test Error Type
		if ( not reFindnocase("(application|framework)",arguments.errorType) )
			arguments.errorType = "application";
			
		if ( arguments.ErrorType eq "application" ){
			//Run custom Exception handler if Found, else run default
			if ( getSetting("ExceptionHandler") neq "" ){
				try{
					setValue("ExceptionBean",ExceptionBean);
					runEvent(getSetting("Exceptionhandler"));
				}
				catch(Any e){
					ExceptionBean = getPlugin("beanFactory").create("coldbox.system.beans.exceptionBean").init(errorStruct=e,extramessage="Error Running Custom Exception handler",errorType="application");
					getPlugin("logger").logErrorWithBean(ExceptionBean);
				}
			}
			else{
				getPlugin("logger").logErrorWithBean(ExceptionBean);
			}
		}
		//return
		return ExceptionBean;	
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

<!------------------------------------------- PRIVATE ------------------------------------------->
	
	<!--- ************************************************************* --->

	<cffunction name="ripExtension" access="private" returntype="string" output="false">
		<cfargument name="filename" type="string" required="true">
		<cfreturn reReplace(arguments.filename,"\.[^.]*$","")>
	</cffunction>

	<!--- ************************************************************* --->
	
</cfcomponent>