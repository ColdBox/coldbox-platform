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
		<cfargument name="controller" required="yes" hint="The reference to the framework controller">
			<cfset super.Init(arguments.controller) />
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
		<!--- Test for myplugins location and init if necessary --->
		<cfif getSetting("MyPluginsLocation") neq "" and not directoryExists(expandPath(replace(getSetting("MyPluginsLocation"),".","/","all"))) >
			<!--- Directory not verified, throw error --->
			<cfthrow type="Framework.plugins.settings.MyPluginsLocationNotFound" message="The custom plugins location: #getSetting("MyPluginsLocation")# (Expanded:#expandPath(replace(getSetting("MyPluginsLocation"),".","/","all"))#) cannot be located or does not exist. Please verify your entry in your config.xml.cfm">
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
	<cffunction name="passwordCheck" access="public" hint="Checks wether the passed password is correct or not." returntype="boolean" output="false">
		<!--- ************************************************************* --->
		<cfargument name="passToCheck" required="yes" type="string" hint="The password to verify. Hashed already please.">
		<!--- ************************************************************* --->
		<cfif Compare(trim("#getPassword()#"),trim(arguments.passToCheck)) eq 0>
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="changePassword" access="public" hint="Changes the dashboard password." returntype="boolean" output="false">
		<!--- ************************************************************* --->
		<cfargument name="currentPassword" 	required="yes" type="string">
		<cfargument name="newPassword" 		required="yes" type="string">
		<!--- ************************************************************* --->
		<cfset var newPass = "">
		<cfset var passfile = "#getSetting("FrameworkPath",1)##getSetting("OSFileSeparator",1)#admin#getSetting("OSFileSeparator",1)#config#getSetting("OSFileSeparator",1)#.coldbox">
		<cfif CompareNocase(getSetting("AppName"),getSetting("DashboardName",1)) eq 0>
			<cfif passwordCheck(hash(arguments.currentPassword))>
				<!--- Create New File with Password --->
				<cfset newPass = "coldbox=#hash(arguments.newPassword)#">
				<cffile action="write" file="#passFile#" output="#newPass#">
				<cfreturn true>
			<cfelse>
				<cfreturn false>
			</cfif>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="getRegisteredHandler" access="public" hint="I get a registered handler and method according to passed event." returntype="any"  output="false">
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
			<cfthrow type="Framework.plugins.settings.EventHandlerNotRegisteredException" message="The event handler: '#getSetting('AppMapping')#/#arguments.event#' is not valid registered event. Please <a href= 'index.cfm?fwreinit=1'>click here to try again.</a>">
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
	<cffunction name="getPassword" access="private" hint="Gets the current dashboard password or creates one if necessary." returntype="any" output="false">
		<cfset var pass = "coldbox=9702D637FA3229EAFFC5A58FF7E06B6C">
		<cfset var passContent = "">
		<cfset var passfile = "#getSetting("FrameworkPath",1)##getSetting("OSFileSeparator",1)#admin#getSetting("OSFileSeparator",1)#config#getSetting("OSFileSeparator",1)#.coldbox">

		<!--- Check if file .coldbox exists --->
		<cfif fileExists( passfile )>
			<cffile action="read" file="#passfile#" variable="passContent">
			<!--- Veriy pass on File is Correct. --->
			<cfif not refindNocase("^coldbox=.*", passContent)>
				<cffile action="write" file="#passFile#" output="#pass#">
				<cfset passContent = pass>
			</cfif>
			<cfreturn getToken(passContent, 2,"=")>
		<cfelse>
			<!--- Create New File with Password --->
			<cffile action="write" file="#passfile#" output="#pass#">
			<cfset passContent = pass>
			<!--- Return password hash--->
			<cfreturn getToken(passContent, 2,"=")>
		</cfif>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="getHandlersMetaData" access="private" hint="Get the handler(s) meta data for registration." returntype="any">
		<cfset var oCFCViewer = getPlugin("cfcViewer")>
		<cfset var HandlersPath = getSetting("AppMapping")>
		<cfset var CFCPath = HandlersPath>
		<cfset var HandlersArray = ArrayNew(1)>
		<cfset var metaData = "">
		<cfset var registeredHandlers = ArrayNew(1)>
		<cfset var i = 0>
		<cfset var x = 0>

		<!--- setup Default location --->
		<cfif getSetting("AppMapping") neq "">
			<!--- Test for CFMX 6.X --->
			<cfif listfirst(server.coldfusion.productversion) lt 7>
				<cfset HandlersPath = replacenocase(cgi.SCRIPT_NAME, listlast(cgi.SCRIPT_NAME,"/"),"") & "handlers">
			<cfelse>
				<cfset HandlersPath = "/" & HandlersPath & "/handlers">
			</cfif>
			<cfset CFCPath = "/" & CFCPath & "/handlers">
		<cfelse>
			<cfset HandlersPath = "/handlers">
			<cfset CFCPath = HandlersPath>
		</cfif>
		
		<!--- Dashboard Exceptions --->
		<cfif CompareNocase(getSetting("AppName"),getSetting("DashboardName",1)) eq 0>
			<cfset HandlersPath = "." & "/handlers">
			<cfset CFCPath = getDirectoryFromPath(cgi.SCRIPT_NAME) & "handlers">
		</cfif>
		
		<!--- Check for Handlers Location --->
		<cfif not directoryExists(ExpandPath(HandlersPath))>
			<cfthrow type="Framework.plugins.settings.HandlersDirectoryNotFoundException" message="The handlers directory: #expandPath(handlerspath)# does not exist please check your application structure or your Application Mapping.">
		</cfif>
		
		<!--- Get Handlers --->
		<cfset oCFCViewer.setup(HandlersPath,CFCPath)>
		<!--- Get Array of Cfc's --->
		<cfset HandlersArray = oCFCViewer.getCFCs()>
		<cfloop from="1" to="#ArrayLen(HandlersArray)#" index="i">
			<cfset metaData = oCFCViewer.getCFCMetaData(HandlersArray[i])>
			<cfloop from="1" to="#ArrayLen(metaData.Functions)#" index="x">
				<cfif not structkeyExists(metadata.Functions[x],"access") or (metadata.Functions[x].access eq "PUBLIC" and metadata.Functions[x].name neq "init")>
					<cfset ArrayAppend(registeredHandlers,"#HandlersArray[i]#." & metaData.Functions[x].name)>
				</cfif>
			</cfloop>
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

</cfcomponent>