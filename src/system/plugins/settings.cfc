<!-----------------------------------------------------------------------
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

	<!--- ************************************************************* --->
	<cffunction name="init" access="public" returntype="any" output="false">
		<cfset super.Init() />
		<cfset variables.instance.pluginName = "Settings">
		<cfset variables.instance.pluginVersion = "1.0">
		<cfset variables.instance.pluginDescription = "This plugin is used to control several of the framework settings and aspects.">
		<cfreturn this>
	</cffunction>
	<!--- ************************************************************* --->

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- ************************************************************* --->
	<cffunction name="configLoader" returntype="void" access="Public" hint="I Load the configurations and init the framework variables. I have a facade to the application scope." output="false">
		<cfset var XMLParser = getPlugin("XMLParser")>
		<cfset var ConfigFileLocation = "">
		<cfset var ConfigTimeStamp = "">
		<cfset var HandlersDirectory = "">
		<!--- Load Coldbox Config Structure --->
		<cfset application.ColdBox_FWSettingsStruct = XMLParser.loadFramework()>
		<!--- Load Config from XML --->
		<cfset application.ColdBox_configStruct = XMLParser.parseConfig()>
		<!---Load i18N if needed --->
		<cfif getSetting("using_i18N")>
			<cfset getPlugin("i18n").initBundle(getSetting("DefaultResourceBundle"),getSetting("DefaultLocale"))>
		</cfif>
		<!--- Set Config DebugMode --->
		<cfset setDebugMode(getSetting("DebugMode"))>
		<!--- Test for Coldbox logging, if set init the log location --->
		<cfif getSetting("EnableColdboxLogging")>
			<cfset getPlugin("logger").initLogLocation()>
		</cfif>
		<!--- Flag the initiation --->
		<cfset application.ColdBox_fwInitiated = true>
		<cfset application.ColdBox_fwAppStartHandlerFired = false>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="registerHandlers" access="public" returntype="void" hint="I register your application's event handlers" output="false">
		<cfset setSetting("RegisteredHandlers",getHandlersMetaData())>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="getRegisteredHandler" access="public" hint="I get a registered handler and method according to passed event from the registeredHandlers setting." returntype="any"  output="false">
		<!--- ************************************************************* --->
		<cfargument name="event" hint="The event to check and get." type="string" required="true">
		<!--- ************************************************************* --->
		<cfset var handlerIndex = 0>
		<cfset var rtnStruct = "">
		<cfset var handlersList = arrayToList(getSetting("RegisteredHandlers"))>
		<!--- Syntax Check --->
		<cfset EventSyntaxCheck(arguments.event)>
		<!--- Check registration --->
		<cfset handlerIndex = listFindNoCase(handlersList, arguments.event) >
		<cfif handlerIndex>
			<cfreturn getPlugin("beanFactory").create("coldbox.system.beans.eventhandler").init(listgetAt(handlersList,handlerIndex))>
		<cfelse>
			<cfthrow type="Framework.plugins.settings.EventHandlerNotRegisteredException" message="The event handler: '#getSetting('AppMapping')#/#arguments.event#' is not valid registered event.</a>">
		</cfif>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="ExceptionHandler" access="public" hint="I handle a framework/application exception. I return a framework exception bean" returntype="any" output="false">
		<!--- ************************************************************* --->
		<cfargument name="Exception" 	 type="any"     required="true"  hint="The exception structure">
		<cfargument name="ErrorType" 	 type="any" 	required="false" default="application">
		<cfargument name="ExtraMessage"  type="string"  required="false" default="">
		<!--- ************************************************************* --->
		<cfset var BugReport = "">
		<cfset var ExceptionBean = getPlugin("beanFactory").create("coldbox.system.beans.exception").init(errorStruct=arguments.Exception,extramessage=arguments.extraMessage,errorType=arguments.ErrorType)>
		<!--- Test ErrorType --->
		<cfif not reFindnocase("(application|framework)",arguments.errorType)>
			<cfset arguments.errorType = "application">
		</cfif>
		<cfif arguments.ErrorType eq "application">
			<!--- Run custom Exception handler if Found, else run default --->
			<cfif getSetting("ExceptionHandler") neq "">
				<cftry>
					<cfset setValue("ExceptionBean",ExceptionBean)>
					<cfset runEvent(getSetting("Exceptionhandler"))>
					<cfcatch type="any">
						<cfset ExceptionBean = getPlugin("beanFactory").create("coldbox.system.beans.exception").init(errorStruct=cfcatch,extramessage="Error Running Custom Exception handler",errorType="application")>
						<cfset getPlugin("logger").logErrorWithBean(ExceptionBean)>
					</cfcatch>
				</cftry>
			<cfelse>
				<cfset getPlugin("logger").logErrorWithBean(ExceptionBean)>
			</cfif>
		</cfif>
		<cfreturn ExceptionBean>
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
			functions = xmlsearch(xmlparse(StringBuffer),"//cfc/cffunction");
			if ( arrayLen(functions) eq 0 )
				getPlugin("logger").logEntry("warning","Handler cfc: #name# does not have any methods defined.");
			else{
				for (x=1; x lt arrayLen(functions) ; x=x+1){
					if ( not StructKeyExists(functions[x].XMLAttributes,"access") ) 
						functions[x].XMLAttributes["access"] = "public";
					if ( functions[x].XMLAttributes["name"] neq "init" and functions[x].XMLAttributes["access"] eq "public" ){
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
	
	<!--- ************************************************************* --->
	<cffunction name="ripExtension" access="private" returntype="string" output="false">
		<cfargument name="filename" type="string" required="true">
		<cfreturn reReplace(arguments.filename,"\.[^.]*$","")>
	</cffunction>
	<!--- ************************************************************* --->
	
</cfcomponent>