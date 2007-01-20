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
		<cfset setSetting("RegisteredHandlers",getHandlersMetaData())>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="getRegisteredHandler" access="public" hint="I get a registered handler and method according to passed event from the registeredHandlers setting." returntype="any"  output="false">
		<!--- ************************************************************* --->
		<cfargument name="event" hint="The event to check and get." type="string" required="true">
		<!--- ************************************************************* --->
		<cfscript>
		var handlerIndex = 0;
		var rtnStruct = "";
		var handlersList = arrayToList(getSetting("RegisteredHandlers"));
		var onInvalidEvent = getSetting("onInvalidEvent");
		var oBeanFactory = getPlugin("beanFactory");
		
		//Check Registration
		handlerIndex = listFindNoCase(handlersList, arguments.event);
		if ( handlerIndex ){
			return oBeanFactory.create("coldbox.system.beans.eventhandlerBean").init(listgetAt(handlersList,handlerIndex));
		}
		else if ( onInvalidEvent neq "" and EventSyntaxCheck(onInvalidEvent) ){
			return oBeanFactory.create("coldbox.system.beans.eventhandlerBean").init(onInvalidEvent);
			}
		else{
			throw("The event handler: '#getSetting('AppMapping')#/#arguments.event#' is not valid registered event.</a>","","Framework.plugins.settings.EventHandlerNotRegisteredException");
		}
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

	<cffunction name="getHandlersMetaData" access="private" hint="Get the handler(s) meta data for registration." returntype="any">
		<cfset var HandlersPath = getSetting("AppMapping")>
		<cfset var HandlersArray = ArrayNew(1)>
		<cfset var metaData = "">
		<cfset var registeredHandlers = ArrayNew(1)>
		<cfset var x = 0>
		<cfset var qryCFC = "">
		<cfset var StringBuffer = "<cfc>">
		<cfset var parseString = "">
		<cfset var fileContent = "">
		<cfset var functions = "">
		
		<!--- setup handler's location, I use / because I use relative paths --->
		<cfif getSetting("AppMapping") neq "">
			<!--- Test for CF 6.X --->
			<cfif listfirst(server.coldfusion.productversion) lt 7>
				<cfset HandlersPath = replacenocase(cgi.SCRIPT_NAME, listlast(cgi.SCRIPT_NAME,"/"),"") & "handlers/">
			<cfelse>
				<cfset HandlersPath = "/" & HandlersPath & "/handlers/">
			</cfif>
		<cfelse>
			<cfset HandlersPath = "/handlers/">
		</cfif>
		<!--- Expand Path --->
		<cfset HandlersPath = Expandpath(HandlersPath)>
		<!--- Check for Handlers Directory Location --->
		<cfif not directoryExists(HandlersPath)>
			<cfthrow type="Framework.plugins.settings.HandlersDirectoryNotFoundException" message="The handlers directory: #handlerspath# does not exist please check your application structure or your Application Mapping.">
		</cfif>
		<!--- Get CFC's to parse --->
		<cfdirectory action="list" directory="#HandlersPath#" name="qryCFC" sort="name" filter="*.cfc">
		<!--- Verify handler's found, else, why continue --->
		<cfif not qryCFC.recordcount>
			<cfthrow type="Framework.plugins.settings.NoHandlersFoundException" message="No handlers were found in: #handlerspath#. So I have no clue how you are going to run this application.">
		</cfif>
		<!--- Loop and parse --->
		<cfloop query="qryCFC">
			<cffile action="read" file="#HandlersPath##name#" variable="fileContent">
			<cfscript>
		 	parseString = reFindnocase("<cffunction[^>/]*>",fileContent,1,true);
			while ( parseString.len[1] neq 0 ) {
				StringBuffer = StringBuffer &  Mid(fileContent,parseString.pos[1],parseString.len[1]) & "</cffunction>";
				fileContent = removeChars(fileContent,1,parseString.pos[1]+parseString.len[1]);
				parseString = reFindnocase("<cffunction[^>/]*>",fileContent,1,true);
			}
			StringBuffer = StringBuffer & "</cfc>";
			//Try to parse
			try{
				functions = xmlsearch(xmlparse(StringBuffer),"//cfc/cffunction");
			}
			catch(any e){
				throw("Error registering and parsing your event handlers. There are syntax errors in your event handlers. please verify them.","#e.message# #e.detail#","Framework.plugins.settings.InvalidEventHandlersException");
			}
			
			//Parse the methods.
			if ( arrayLen(functions) eq 0 )
				getPlugin("logger").logEntry("warning","Handler cfc: #name# does not have any methods defined.");
			else{
				for (x=1; x lte arrayLen(functions) ; x=x+1){
					if ( not StructKeyExists(functions[x].XMLAttributes,"access") ) 
						functions[x].XMLAttributes["access"] = "public";
					if ( trim(functions[x].XMLAttributes["name"]) neq "init" and trim(functions[x].XMLAttributes["access"]) eq "public" ){
						arrayAppend(registeredHandlers, ripExtension(name) & "." & trim(functions[x].XMLAttributes["name"]));
					}
				}
			}
			StringBuffer = "<cfc>";
			</cfscript>
		</cfloop>
		<cfreturn registeredHandlers>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="EventSyntaxCheck" access="private" hint="I test the event syntax and throw errors." returntype="boolean"  output="false">
		<!--- ************************************************************* --->
		<cfargument name="event" hint="The event to check" type="string" required="true">
		<!--- ************************************************************* --->
		<cfif refindnocase("^eh[a-zA-Z]+\.(dsp|do|on)[a-zA-Z]+", arguments.event)>
			<cfreturn true>
		<cfelse>
			<cfthrow type="Framework.plugins.settings.EventSyntaxInvalidException" message="The event syntax: #request.reqCollection.event# is invalid. Please check the documentation for valid syntax.">
		</cfif>
	</cffunction>
	
	<!--- ************************************************************* --->

	<cffunction name="ripExtension" access="private" returntype="string" output="false">
		<cfargument name="filename" type="string" required="true">
		<cfreturn reReplace(arguments.filename,"\.[^.]*$","")>
	</cffunction>

	<!--- ************************************************************* --->
	
</cfcomponent>