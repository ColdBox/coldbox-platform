<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	 :	Luis Majano
Date     :	September 23, 2005
Description :
	This is a utility function for the framework. It includes any methods
	that will be called from the framework for XML parsing.

Modification History:
10/05/2005 - Fix for Dev URL beign blank
10/06/2005 - Added support for XSD Validation, added this.ConfigFileLocation to be localized.
10/10/2005 - Added Fix for xsd url in error message for validation.
12/16/2005 - Changed to variables scope.
12/18/2006 - Updated MailSettings, owneremail, controller reload.
01/16/2006 - Added coding to use in child apps, added ApplicationPath,
			 FrameworkPath, ChildApp, ParentAppPath, DistanceToParent to fwsetttings.
02/07/2006 - FrameworkPluginsPath added.
02/16/2006-  Added DebugPassword code.
06/08/2006 - Updated for Coldbox - Added support for writing the CFMX mapping with . or with /, MessageboxStyleClass
06/21/2006 - Finished i18N support, file based.
07/28/2006 - Datasources support, var scope additions.
08/10/2006 - Child References Eliminated. No longer in use.
08/20/2006 - i18n Support completed for new plugins.
10/10/2006 - Mail server settings setup.
12/20/2006 - new settings: ReinitPassword, InvalidEventHandler
01/17/2007 - fixed Bug #83, failure to set handler invocation path if / as first char
01/18/2007 - Preparing for new event registration system.
01/26/2007 - Datasource Alias and error checking Ticket #88, #89
----------------------------------------------------------------------->
<cfcomponent name="XMLParser"
			 hint="This is the XML Parser plugin for the framework. It takes care of any XML parsing for the framework's usage."
			 extends="coldbox.system.plugin"
			 output="false"
			 cache="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="XMLParser" output="false" hint="Constructor">
		<!--- ************************************************************* --->
		<cfargument name="controller" type="any" required="true">
		<!--- ************************************************************* --->
		<cfscript>
			//Call Super
			super.init(arguments.controller);
		
			//Local Plugin Definition
			setpluginName("XMLParser");
			setpluginVersion("2.0");
			setpluginDescription("I am the framework's XML parser");
	
			//Search Patterns for Config file
			instance.searchSettings = "//Settings/Setting";
			instance.searchYourSettings = "//YourSettings/Setting";
			instance.searchBugTracer = "//BugTracerReports/BugEmail";
			instance.searchDevURLS = "//DevEnvironments/url";
			instance.searchWS = "//WebServices/WebService";
			instance.searchLayouts = "//Layouts/Layout";
			instance.searchDefaultLayout = "//Layouts/DefaultLayout";
			instance.searchDefaultView = "//Layouts/DefaultView";
			instance.searchMailSettings = "//MailServerSettings";
			instance.searchi18NSettings = "//i18N";
			instance.searchDatasources = "//Datasources/Datasource";
			instance.searchCache = "//Cache";
			instance.searchInterceptorCustomPoints = "//Interceptors/CustomInterceptionPoints";
			instance.searchInterceptors = "//Interceptors/Interceptor";
			instance.searchInterceptorBase = "//Interceptors";
			instance.searchDebuggerSettings = "//DebuggerSettings";
			
			//Search patterns for fw xml
			instance.searchConventions = "//Conventions";
	
			//ColdBox Properties
			instance.FileSeparator = createObject("java","java.lang.System").getProperty("file.separator");
			instance.FrameworkConfigFile = ExpandPath("/coldbox/system/config/settings.xml");
			instance.FrameworkConfigXSDFile = ExpandPath("/coldbox/system/config/config.xsd");
			
			/* Regex for JSON */
			instance.jsonRegex = "^(\{|\[)(.)*(\}|\])$";
			
			//Return
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<cffunction name="loadFramework" access="public" hint="Load the framework's configuration xml." output="false" returntype="struct">
		<!--- ************************************************************* --->
		<cfargument name="overrideConfigFile" required="false" type="string" default="" 
					hint="Only used for unit testing or reparsing of a specific coldbox config file.">
		<!--- ************************************************************* --->
		<cfscript>
		var settingsStruct = StructNew();
		var FrameworkParent = "";
		var distanceToParent = 0;
		var distanceString = "";
		var fwXML = "";
		var SettingNodes = "";
		var ParentAppPath = "";
		var Conventions = "";
		var ConfigXMLFilePath = "";
		var tempFilePath = "";
		var configFileFound = false;
		var CFMLEngine = controller.oCFMLENGINE.getEngine();
		var CFMLVersion = controller.oCFMLENGINE.getVersion();
		var i = 1;

		try{
			//verify Framework settings File
			if ( not fileExists(instance.FrameworkConfigFile) ){
				$throw("Error finding settings.xml configuration file. The file #instance.FrameworkConfigFile# cannot be found.","","ColdBox.plugins.XMLParser.ColdBoxSettingsNotFoundException");
			}			
			//Setup the ColdBox CFML Engine Info
			settingsStruct["CFMLEngine"] = CFMLEngine;
			settingsStruct["CFMLVersion"] = CFMLVersion;			
			//Set Internal Parsing And Charting Properties
			if ( CFMLEngine eq controller.oCFMLENGINE.BLUEDRAGON ){
				settingsStruct["xmlParseActive"] = true;
				settingsStruct["chartingActive"] = true;
				settingsStruct["xmlValidateActive"] = true;	
			}//end if bluedragon
			else if ( CFMLEngine eq controller.oCFMLENGINE.RAILO ){
				settingsStruct["xmlParseActive"] = true;
				if( CFMLVersion gte 8 ){ settingsStruct["chartingActive"] = true; }
				else{ settingsStruct["chartingActive"] = false; }
				settingsStruct["xmlValidateActive"] = true;
			}//end if railo
			else{
				settingsStruct["chartingActive"] = true;
				//Adobe CF
				settingsStruct["xmlParseActive"] = true;
				settingsStruct["xmlValidateActive"] = true;
			}//end if adobe.
			
			//Determine Parsing Method.
			if ( not settingsStruct["xmlParseActive"] ){
				fwXML = xmlParse(readFile(instance.FrameworkConfigFile,false,"utf-8"));
			}
			else{
				fwXML = xmlParse(instance.FrameworkConfigFile);
			}
		
			//Get SettingNodes From Config
			SettingNodes = XMLSearch(fwXML, instance.searchSettings);
			//Insert Settings to Config Struct
			for (i=1; i lte ArrayLen(SettingNodes); i=i+1)
				StructInsert( settingsStruct, SettingNodes[i].XMLAttributes["name"], trim(SettingNodes[i].XMLAttributes["value"]));

			//OS File Separator
			StructInsert(settingsStruct, "OSFileSeparator", instance.FileSeparator );

			//Conventions Parsing
			conventions = XMLSearch(fwXML,instance.searchConventions);
			StructInsert(settingsStruct, "HandlersConvention", conventions[1].handlerLocation.xmltext);
			StructInsert(settingsStruct, "pluginsConvention", conventions[1].pluginsLocation.xmltext);
			StructInsert(settingsStruct, "LayoutsConvention", conventions[1].layoutsLocation.xmltext);
			StructInsert(settingsStruct, "ViewsConvention", conventions[1].viewsLocation.xmltext);
			StructInsert(settingsStruct, "EventAction", conventions[1].eventAction.xmltext);
			StructInsert(settingsStruct, "ModelsConvention", conventions[1].modelsLocation.xmltext);

			//Get ColdBox Config XML File Settings or Override using arguments
			if ( arguments.overrideConfigFile eq ""){
				//Get the Config XML FIle paths
				ConfigXMLFilePath = replace(conventions[1].configLocation.xmltext, "{sep}", instance.FileSeparator,"all");
				//Check and validate the list.
				for (i=1; i lte listlen(ConfigXMLFilePath); i=i+1){
					tempFilePath = controller.GetAppRootPath() & instance.FileSeparator & listgetAt(ConfigXMLFilePath,i);
					if ( fileExists(tempFilePath) ){
						ConfigXMLFilePath = tempFilePath;
						configFileFound = true;
						break;
					}
				}
				//Validate the findings
				if( not configFileFound )
					$throw("ColdBox Application Configuration File can't be found.","The accepted files are: #ConfigXMLFilePath#","ColdBox.plugins.XMLParser.ConfigXMLFileNotFoundException");
				//Insert the correct config file location.
				StructInsert(settingsStruct, "ConfigFileLocation", ConfigXMLFilePath);
			}
			else{
				StructInsert(settingsStruct, "ConfigFileLocation", getAbsolutePath(arguments.overrideConfigFile) );
			}

			//Schema Path
			StructInsert(settingsStruct, "ConfigFileSchemaLocation", instance.FrameworkConfigXSDFile);
			
			//Fix Application Path to last / standard.
			if( right(controller.getAppRootPath(),1) neq  instance.FileSeparator){
				controller.setAppRootPath( controller.getAppRootPath() & instance.FileSeparator );
			}
			
			//Now set the correct path.
			StructInsert(settingsStruct, "ApplicationPath", controller.getAppRootPath() );
			
			//Load Framework Path too
			StructInsert(settingsStruct, "FrameworkPath", ExpandPath("/coldbox/system") & instance.FileSeparator );
			//Load Plugins Path
			StructInsert(settingsStruct, "FrameworkPluginsPath", settingsStruct.FrameworkPath & "plugins");
			//Set the complete modifylog path
			settingsStruct.ModifyLogLocation = "#settingsStruct.FrameworkPath#config#instance.FileSeparator#readme.txt";
			
			//return settings
			return settingsStruct;
		}//end of try
		catch( Any Exception ){
			$throw("Error Loading Framework Configuration.","#Exception.Message# #Exception.Detail#","ColdBox.plugins.XMLParser.ColdboxSettingsParsingException");
		}
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="parseConfig" access="public" returntype="struct" output="false" hint="Parse the application configuration file.">
		<!--- ************************************************************* --->
		<cfargument name="overrideAppMapping" type="string" required="false" default="" hint="Only used for unit testing or reparsing of a specific coldbox config file."/>
		<!--- ************************************************************* --->
		<cfscript>
		var Collections = createObject("java", "java.util.Collections"); 
		//Create Config Structure
		var ConfigStruct = StructNew();
		var fwSettingsStruct = getController().getColdboxSettings();
		var ConfigFileLocation = fwSettingsStruct["ConfigFileLocation"];
		var configXML = "";
		//Nodes
		var SettingNodes = "";
		var YourSettingNodes = "";
		var MailSettingsNodes = "";
		//i18n
		var i18NSettingNodes = "";
		var DefaultLocale = "";
		//BugEmail
		var BugEmailNodes = "";
		var BugEmails = "";
		//WebServices
		var WebServiceNodes = "";
		var WebServicesStruct = StructNew();
		var DevWS = StructNew();
		var ProWS = StructNew();
		//Layouts
		var DefaultView = "";
		var LayoutNodes = "";
		var DefaultLayout = "";
		var	LayoutViewStruct = Collections.synchronizedMap(CreateObject("java","java.util.LinkedHashMap").init());
		var	LayoutFolderStruct = Collections.synchronizedMap(CreateObject("java","java.util.LinkedHashMap").init());
		//DevEnvironments
		var DevEnvironmentNodes = "";
		var DevEnvironmentArray = ArrayNew(1);
		//Datasources.
		var DatasourcesNodes = "";
		var DSNStruct = StructNew();
		var DatasourcesStruct = Structnew();
		//Cache
		var CacheSettingNodes = "";
		var DebuggerSettingNodes = "";
		//Interceptors
		var InterceptorBase = "";
		var InterceptorNodes = "";
		var CustomInterceptionPoints = "";
		var InterceptorStruct = structnew();
		var InterceptorProperties = "";
		var tempProperty = "";
		//Conventions
		var Conventions = "";
		//loopers
		var i = 0;
		var j = 0;
		//Appmapping Variables
		var webPath = "";
		var localPath = "";
		var PathLocation = "";
		//helper
		var oUtilities = getPlugin("Utilities");
		//Testers
		var tester = "";
		var xmlvalidation = "";
		var errorDetails = "";
		
		try{
			
			/* ::::::::::::::::::::::::::::::::::::::::: CONFIG FILE PARSING & VALIDATION :::::::::::::::::::::::::::::::::::::::::::: */
			
			//Validate File, just in case.
			if ( not fileExists(ConfigFileLocation) ){
				$throw("The Config File: #ConfigFileLocation# can't be found.","","ColdBox.plugins.XMLParser.ConfigXMLFileNotFoundException");
			}
			
			//Determine Parse Type
			if ( not fwSettingsStruct["xmlParseActive"] ){
				configXML = xmlParse(readFile(ConfigFileLocation,false,"utf-8"));
			}
			else{
				configXML = xmlParse(ConfigFileLocation);
			}

			//Validate the config
			if ( not structKeyExists(configXML, "config")  )
				$throw("No Config element found in the configuration file","","ColdBox.plugins.XMLParser.ConfigXMLParsingException");

			/* ::::::::::::::::::::::::::::::::::::::::: APP MAPPING CALCULATIONS :::::::::::::::::::::::::::::::::::::::::::: */
			
			//Setup the Application Path
			if( arguments.overrideAppMapping neq "" ){
				StructInsert(ConfigStruct, "ApplicationPath", ExpandPath(arguments.overrideAppMapping));
			}
			else{
				StructInsert(ConfigStruct, "ApplicationPath", controller.getAppRootPath());
			}
			
			/* ::::::::::::::::::::::::::::::::::::::::: APP MAPPING CALCULATIONS :::::::::::::::::::::::::::::::::::::::::::: */
			
			//Calculate AppMapping if not set in the config, else auto-calculate
			if ( not structKeyExists(ConfigStruct, "AppMapping") ){
				webPath = replacenocase(cgi.script_name,getFileFromPath(cgi.script_name),"");
				localPath = getDirectoryFromPath(replacenocase(getTemplatePath(),"\","/","all"));
				PathLocation = findnocase(webPath, localPath);
				if ( PathLocation neq 0)
					ConfigStruct.AppMapping = mid(localPath,PathLocation,len(webPath));
				else
					ConfigStruct.AppMapping = webPath;

				//Clean last /
				if ( right(ConfigStruct.AppMapping,1) eq "/" ){
					if ( len(ConfigStruct.AppMapping) -1 gt 0)
						ConfigStruct.AppMapping = left(ConfigStruct.AppMapping,len(ConfigStruct.AppMapping)-1);
					else
						ConfigStruct.AppMapping = "";
				}
				
				//Clean j2ee context
				if( len(getContextRoot()) )
					ConfigStruct.AppMapping = replacenocase(ConfigStruct.AppMapping,getContextRoot(),"");
			}
			
			/* ::::::::::::::::::::::::::::::::::::::::: GET SETTINGS  :::::::::::::::::::::::::::::::::::::::::::: */
			
			//Get SettingNodes
			SettingNodes = XMLSearch(configXML, instance.searchSettings);
			if ( ArrayLen(SettingNodes) eq 0 )
				$throw("No Setting elements could be found in the configuration file.","","ColdBox.plugins.XMLParser.ConfigXMLParsingException");
			//Insert  ColdBox Settings to Config Struct
			for (i=1; i lte ArrayLen(SettingNodes); i=i+1){
				ConfigStruct[trim(SettingNodes[i].XMLAttributes["name"])] = oUtilities.placeHolderReplacer(trim(SettingNodes[i].XMLAttributes["value"]),ConfigStruct);
			}
			//Check for AppName or throw
			if ( not StructKeyExists(ConfigStruct, "AppName") )
				$throw("There was no 'AppName' setting defined. This is required by the framework.","","ColdBox.plugins.XMLParser.ConfigXMLParsingException");
			//overrideAppMapping if passed in.
			if ( arguments.overrideAppMapping neq "" ){
				ConfigStruct["AppMapping"] = arguments.overrideAppMapping;
			}
			/* Clean the first / if found */
			if( len(ConfigStruct.AppMapping) eq 1 ){
				ConfigStruct.AppMapping = "";
			}
			
			/* ::::::::::::::::::::::::::::::::::::::::: COLDBOX SETTINGS VALIDATION :::::::::::::::::::::::::::::::::::::::::::: */
			
			//Check for Default Event
			if ( not StructKeyExists(ConfigStruct, "DefaultEvent") )
				$throw("There was no 'DefaultEvent' setting defined. This is required by the framework.","","ColdBox.plugins.XMLParser.ConfigXMLParsingException");
		
			//Check for Event Name
			if ( not StructKeyExists(ConfigStruct, "EventName") )
				ConfigStruct["EventName"] = fwSettingsStruct["EventName"] ;
			
			//Check for Request Start Handler
			if ( not StructKeyExists(ConfigStruct, "ApplicationStartHandler") )
				ConfigStruct["ApplicationStartHandler"] = "";
			
			//Check for Request End Handler
			if ( not StructKeyExists(ConfigStruct, "RequestStartHandler") )
				ConfigStruct["RequestStartHandler"] = "";
			
			//Check for Application Start Handler
			if ( not StructKeyExists(ConfigStruct, "RequestEndHandler") )
				ConfigStruct["RequestEndHandler"] = "";
				
			//Check for Session Start Handler
			if ( not StructKeyExists(ConfigStruct, "SessionStartHandler") )
				ConfigStruct["SessionStartHandler"] = "";
				
			//Check for Session End Handler
			if ( not StructKeyExists(ConfigStruct, "SessionEndHandler") )
				ConfigStruct["SessionEndHandler"] = "";
		
			//Check for InvalidEventHandler
			if ( not StructKeyExists(ConfigStruct, "onInvalidEvent") )
				ConfigStruct["onInvalidEvent"] = "";

			//Check For DebugMode in settings
			if ( not structKeyExists(ConfigStruct, "DebugMode") or not isBoolean(ConfigStruct.DebugMode) )
				ConfigStruct["DebugMode"] = "false";
		
			//Check for DebugPassword in settings, else leave blank.
			if ( not structKeyExists(ConfigStruct, "DebugPassword") )
				ConfigStruct["DebugPassword"] = "";
		
			//Check for ReinitPassword
			if ( not structKeyExists(ConfigStruct, "ReinitPassword") )
				ConfigStruct["ReinitPassword"] = "";

			//Check For Coldfusion Logging
			if ( not structKeyExists(ConfigStruct, "EnableColdfusionLogging") or not isBoolean(ConfigStruct.EnableColdfusionLogging) )
				ConfigStruct["EnableColdfusionLogging"] = "false";
			
			//Check For Coldbox Logging
			if ( not structKeyExists(ConfigStruct, "EnableColdboxLogging") or not isBoolean(ConfigStruct.EnableColdboxLogging) )
				ConfigStruct["EnableColdboxLogging"] = "false";
			
			//Check For Coldbox Log Location if it is defined.
			if ( not structKeyExists(ConfigStruct, "ColdboxLogsLocation") or trim(ConfigStruct["ColdboxLogsLocation"]) eq "")
				ConfigStruct["ColdboxLogsLocation"] = "";
			//Setup the ExpandedColdboxLogsLocation setting
			ConfigStruct["ExpandedColdboxLogsLocation"] = "";
			
			//Default Log Level
			if ( NOT structKeyExists(ConfigStruct, "DefaultLogLevel") OR NOT isNumeric(ConfigStruct["DefaultLogLevel"]))
				ConfigStruct["DefaultLogLevel"] = fwSettingsStruct["DefaultLogLevel"];
			
			//Check For Owner Email or Throw
			if ( not StructKeyExists(ConfigStruct, "OwnerEmail") )
				ConfigStruct["OwnerEmail"] = "";
		
			//Check For EnableDumpvar or set to true
			if ( not StructKeyExists(ConfigStruct, "EnableDumpVar") or not isBoolean(ConfigStruct.EnableDumpVar))
				ConfigStruct["EnableDumpVar"] = "true";
		
			//Check For EnableBugReports Active or set to true
			if ( not StructKeyExists(ConfigStruct, "EnableBugReports") or not isBoolean(ConfigStruct.EnableBugReports))
				ConfigStruct["EnableBugReports"] = "true";

			//Check For UDFLibraryFile
			if ( not StructKeyExists(ConfigStruct, "UDFLibraryFile") )
				ConfigStruct["UDFLibraryFile"] = "";
		
			//Check For CustomErrorTemplate
			if ( not StructKeyExists(ConfigStruct, "CustomErrorTemplate") )
				ConfigStruct["CustomErrorTemplate"] = "";
			
			//Check for CustomEmailBugReport
			if ( not StructKeyExists(ConfigStruct, "CustomEmailBugReport") )
				ConfigStruct["CustomEmailBugReport"] = "";	
			
			//Check for MessageboxStyleOverride if found, default = false
			if ( not structkeyExists(ConfigStruct, "MessageboxStyleOverride") or not isBoolean(ConfigStruct.MessageboxStyleOverride) )
				ConfigStruct["MessageboxStyleOverride"] = "false";

			//Check for HandlersIndexAutoReload, default = false
			if ( not structkeyExists(ConfigStruct, "HandlersIndexAutoReload") or not isBoolean(ConfigStruct.HandlersIndexAutoReload) )
				ConfigStruct["HandlersIndexAutoReload"] = false;
			
			//Check for ConfigAutoReload
			if ( not structKeyExists(ConfigStruct, "ConfigAutoReload") or not isBoolean(ConfigStruct.ConfigAutoReload) )
				ConfigStruct["ConfigAutoReload"] = false;

			//Check for ExceptionHandler if found
			if ( not structkeyExists(ConfigStruct, "ExceptionHandler") )
				ConfigStruct["ExceptionHandler"] = "";

			//Check for MyPluginsLocation if found
			if ( not structkeyExists(ConfigStruct, "MyPluginsLocation") )
				ConfigStruct["MyPluginsLocation"] = "";

			//Check for Handler Caching
			if ( not structKeyExists(ConfigStruct, "HandlerCaching") or not isBoolean(ConfigStruct.HandlerCaching) )
				ConfigStruct["HandlerCaching"] = true;
			
			//Check for Event Caching
			if ( not structKeyExists(ConfigStruct, "EventCaching") or not isBoolean(ConfigStruct.EventCaching) )
				ConfigStruct["EventCaching"] = true;

			//Check for IOC Framework & Settings
			if ( not structKeyExists(ConfigStruct, "IOCFramework") )
				ConfigStruct["IOCFramework"] = "";
			if ( not structKeyExists(ConfigStruct, "IOCFrameworkReload") or not isBoolean(ConfigStruct.IOCFrameworkReload) )
				ConfigStruct["IOCFrameworkReload"] = false;
			if ( not structKeyExists(ConfigStruct, "IOCDefinitionFile") )
				ConfigStruct["IOCDefinitionFile"] = "";
			if ( not structKeyExists(ConfigStruct, "IOCObjectCaching") or not isBoolean(ConfigStruct.IOCObjectCaching) )
				ConfigStruct["IOCObjectCaching"] = false;
				
			//RequestContextDecorator
			if ( not structKeyExists(ConfigStruct, "RequestContextDecorator") or len(ConfigStruct["RequestContextDecorator"]) eq 0 ){
				ConfigStruct["RequestContextDecorator"] = "";
			}
			
			//Check for ProxyReturnCollection
			if ( not structKeyExists(ConfigStruct, "ProxyReturnCollection") or not isBoolean(ConfigStruct.ProxyReturnCollection) )
				ConfigStruct["ProxyReturnCollection"] = false;
			
			//Check for External Handlers Location
			if ( not structKeyExists(ConfigStruct, "HandlersExternalLocation") or len(ConfigStruct["HandlersExternalLocation"]) eq 0 )
				ConfigStruct["HandlersExternalLocation"] = "";
			
			//Check for Models External Location
			if ( not structKeyExists(ConfigStruct, "ModelsExternalLocation") or len(ConfigStruct["ModelsExternalLocation"]) eq 0 )
				ConfigStruct["ModelsExternalLocation"] = "";
			//Check for Models ObjectCaching
			if ( not structKeyExists(ConfigStruct, "ModelsObjectCaching") or not isBoolean(ConfigStruct["ModelsObjectCaching"]) )
				ConfigStruct["ModelsObjectCaching"] = true;
			//Check for ModelsDebugMode
			if ( not structKeyExists(ConfigStruct, "ModelsDebugMode") or not isBoolean(ConfigStruct["ModelsDebugMode"]) )
				ConfigStruct["ModelsDebugMode"] = fwSettingsStruct["ModelsDebugMode"];
			//Check for ModelsSetterInjection
			if ( not structKeyExists(ConfigStruct, "ModelsSetterInjection") or not isBoolean(ConfigStruct["ModelsSetterInjection"]) )
				ConfigStruct["ModelsSetterInjection"] = fwSettingsStruct["ModelsSetterInjection"];
			//Check for ModelsDICompleteUDF
			if ( not structKeyExists(ConfigStruct, "ModelsDICompleteUDF") or len(ConfigStruct["ModelsDICompleteUDF"]) eq 0 )
				ConfigStruct["ModelsDICompleteUDF"] = fwSettingsStruct["ModelsDICompleteUDF"];
			//Check for ModelsStopRecursion
			if ( not structKeyExists(ConfigStruct, "ModelsStopRecursion") or len(ConfigStruct["ModelsStopRecursion"]) eq 0 )
				ConfigStruct["ModelsStopRecursion"] = fwSettingsStruct["ModelsStopRecursion"];
			
			/* Flash URL Persist Scope Override */
			if( structKeyExists(ConfigStruct,"FlashURLPersistScope") and reFindnocase("^(session|client)$",ConfigStruct["FlashURLPersistScope"]) ){
				fwSettingsStruct["FlashURLPersistScope"] = ConfigStruct["FlashURLPersistScope"];
			}
			
			
			/* ::::::::::::::::::::::::::::::::::::::::: YOUR SETTINGS LOADING :::::::::::::::::::::::::::::::::::::::::::: */
			
			//Your Settings To Load
			YourSettingNodes = XMLSearch(configXML, instance.searchYourSettings);
			if ( ArrayLen(YourSettingNodes) ){
				//Insert Your Settings to Config Struct
				for (i=1; i lte ArrayLen(YourSettingNodes); i=i+1){
					/* Get Setting with PlaceHolding */
					tester = oUtilities.placeHolderReplacer(trim(YourSettingNodes[i].XMLAttributes["value"]),ConfigStruct);
					//Test for JSON
					if( reFindNocase(instance.jsonRegex,tester) ){
						StructInsert(ConfigStruct, YourSettingNodes[i].XMLAttributes["name"], getPlugin("json").decode(replace(tester,"'","""","all")) );
					}
					else
						StructInsert( ConfigStruct, YourSettingNodes[i].XMLAttributes["name"], tester);
				}
			}
			
			/* ::::::::::::::::::::::::::::::::::::::::: YOUR CONVENTIONS LOADING :::::::::::::::::::::::::::::::::::::::::::: */
			
			conventions = XMLSearch(configXML,instance.searchConventions);
			if( ArrayLen(conventions) ){
				/* Override conventions on a per found basis. */
				if( structKeyExists(conventions[1],"handlersLocation") ){ fwSettingsStruct["handlersConvention"] = trim(conventions[1].handlersLocation.xmltext); }
				if( structKeyExists(conventions[1],"pluginsLocation") ){ fwSettingsStruct["pluginsConvention"] = trim(conventions[1].pluginsLocation.xmltext); }
				if( structKeyExists(conventions[1],"layoutsLocation") ){ fwSettingsStruct["LayoutsConvention"] = trim(conventions[1].layoutsLocation.xmltext); }
				if( structKeyExists(conventions[1],"viewsLocation") ){ fwSettingsStruct["ViewsConvention"] = trim(conventions[1].viewsLocation.xmltext); }
				if( structKeyExists(conventions[1],"eventAction") ){ fwSettingsStruct["eventAction"] = trim(conventions[1].eventAction.xmltext); }
				if( structKeyExists(conventions[1],"modelsLocation") ){ fwSettingsStruct["ModelsConvention"] = trim(conventions[1].modelsLocation.xmltext); }
			}
			
			/* ::::::::::::::::::::::::::::::::::::::::: HANDLER-MODELS-PLUGIN INVOCATION PATHS :::::::::::::::::::::::::::::::::::::::::::: */
			
			//Set the Handlers External Configuration Paths
			if( configStruct["HandlersExternalLocation"] neq "" ){
				//Expand the external location to get a registration path
				configStruct["HandlersExternalLocationPath"] = ExpandPath("/" & replace(ConfigStruct["HandlersExternalLocation"],".","/","all"));
			}
			else{
				configStruct["HandlersExternalLocationPath"] = "";
			}
			//Set the Models External Configuration Paths
			if( configStruct["ModelsExternalLocation"] neq "" ){
				//Expand the external location to get a registration path
				configStruct["ModelsExternalLocationPath"] = ExpandPath("/" & replace(ConfigStruct["ModelsExternalLocation"],".","/","all"));
			}
			else{
				configStruct["ModelsExternalLocationPath"] = "";
			}
			
			//Set the Handlers,Models, & Custom Plugin Invocation & Physical Path for this Application
			if( ConfigStruct["AppMapping"] neq ""){
				
				//Parse out the first / to create invocation Path
				if ( left(ConfigStruct["AppMapping"],1) eq "/" ){
					ConfigStruct["AppMapping"] = removeChars(ConfigStruct["AppMapping"],1,1);
				}
				
				//Set the Invocation Path
				ConfigStruct["HandlersInvocationPath"] = replace(ConfigStruct["AppMapping"],"/",".","all") & ".#fwSettingsStruct.handlersConvention#";
				ConfigStruct["MyPluginsInvocationPath"] = replace(ConfigStruct["AppMapping"],"/",".","all") & ".#fwSettingsStruct.pluginsConvention#";
				ConfigStruct["ModelsInvocationPath"] = replace(ConfigStruct["AppMapping"],"/",".","all") & ".#fwSettingsStruct.ModelsConvention#";
				
				//Set the Location Path
				ConfigStruct["HandlersPath"] = ConfigStruct["AppMapping"];
				ConfigStruct["MyPluginsPath"] = ConfigStruct["AppMapping"];
				ConfigStruct["ModelsPath"] = ConfigStruct["AppMapping"];
				
				//Set the physical path according to system.
				ConfigStruct["HandlersPath"] = "/" & ConfigStruct["HandlersPath"] & "/#fwSettingsStruct.handlersConvention#";
				ConfigStruct["MyPluginsPath"] = "/" & ConfigStruct["MyPluginsPath"] & "/#fwSettingsStruct.pluginsConvention#";
				ConfigStruct["ModelsPath"] = "/" & ConfigStruct["ModelsPath"] & "/#fwSettingsStruct.ModelsConvention#";
				
				//Set the Handlerspath expanded.
				ConfigStruct["HandlersPath"] = ExpandPath(ConfigStruct["HandlersPath"]);
				ConfigStruct["MyPluginsPath"] = ExpandPath(ConfigStruct["MyPluginsPath"]);
				ConfigStruct["ModelsPath"] = ExpandPath(ConfigStruct["ModelsPath"]);
					
			}
			else{
				//Parse out the first / to create the invocation Path
				if ( left(ConfigStruct["AppMapping"],1) eq "/" ){
					ConfigStruct["AppMapping"] = removeChars(ConfigStruct["AppMapping"],1,1);
				}
				
				/* Handler Registration */
				ConfigStruct["HandlersInvocationPath"] = "#fwSettingsStruct.handlersConvention#";
				ConfigStruct["HandlersPath"] = controller.getAppRootPath() & "#fwSettingsStruct.handlersConvention#";

				/* Custom Plugins Registration */
				ConfigStruct["MyPluginsInvocationPath"] = "#fwSettingsStruct.pluginsConvention#";
				ConfigStruct["MyPluginsPath"] = controller.getAppRootPath() & "#fwSettingsStruct.pluginsConvention#";
				
				/* Models Registration */
				ConfigStruct["ModelsInvocationPath"] = "#fwSettingsStruct.ModelsConvention#";
				ConfigStruct["ModelsPath"] = controller.getAppRootPath() & "#fwSettingsStruct.ModelsConvention#";
			}
			
			/* ::::::::::::::::::::::::::::::::::::::::: EXTERNAL VIEWS LOCATION :::::::::::::::::::::::::::::::::::::::::::: */
			
			/* check for ViewsExternalLocation */
			if( structKeyExists(configStruct,"ViewsExternalLocation") and configStruct["ViewsExternalLocation"] neq "" ){
				/* Verify the locations, do relative to the app mapping first */
				if( directoryExists(controller.getAppRootPath() & configStruct["ViewsExternalLocation"]) ){
					configStruct["ViewsExternalLocation"] = "/" & ConfigStruct["AppMapping"] & "/" & configStruct["ViewsExternalLocation"];
				}
				else if( not directoryExists(expandPath(configStruct["ViewsExternalLocation"])) ){
					$throw("ViewsExternalLocation could not be found.","The directories tested was relative and expanded using #configStruct['ViewsExternalLocation']#. Please verify your setting.","ColdBox.plugins.XMLParser.ConfigXMLParsingException");
				}
				/* Cleanup */
				if ( right(configStruct["ViewsExternalLocation"],1) eq "/" ){
					 configStruct["ViewsExternalLocation"] = left(configStruct["ViewsExternalLocation"],len(configStruct["ViewsExternalLocation"])-1);
				}
			}else{
				configStruct["ViewsExternalLocation"] = "";
			}
			
			/* ::::::::::::::::::::::::::::::::::::::::: MAIL SETTINGS :::::::::::::::::::::::::::::::::::::::::::: */
			
			//Mail Settings
			MailSettingsNodes = XMLSearch(configXML, instance.searchMailSettings);
			//Check if empty
			if ( ArrayLen(MailSettingsNodes) gt 0 and ArrayLen(MailSettingsNodes[1].XMLChildren) gt 0){

				//Checks
				if ( structKeyExists(MailSettingsNodes[1], "MailServer") )
					StructInsert(ConfigStruct, "MailServer", trim(MailSettingsNodes[1].MailServer.xmlText) );
				else
					StructInsert(ConfigStruct,"MailServer","");

				//Mail username
				if ( structKeyExists(MailSettingsNodes[1], "MailUsername") )
					StructInsert(ConfigStruct, "MailUsername", trim(MailSettingsNodes[1].MailUsername.xmlText) );
				else
					StructInsert(ConfigStruct,"MailUsername","");

				//Mail password
				if ( structKeyExists(MailSettingsNodes[1], "MailPassword") )
					StructInsert(ConfigStruct, "MailPassword", trim(MailSettingsNodes[1].MailPassword.xmlText) );
				else
					StructInsert(ConfigStruct,"MailPassword","");

				//Mail Port
				if ( structKeyExists(MailSettingsNodes[1], "MailPort") ){
					if (trim(MailSettingsNodes[1].MailPort.xmlText) neq "")
						StructInsert(ConfigStruct, "MailPort", trim(MailSettingsNodes[1].MailPort.xmlText) );
					else
						StructInsert(ConfigStruct, "MailPort", 25 );
				}
				else
					StructInsert(ConfigStruct, "MailPort", 25 );
			}
			else{
				StructInsert(ConfigStruct,"MailServer","");
				StructInsert(ConfigStruct,"MailUsername","");
				StructInsert(ConfigStruct,"MailPassword","");
				StructInsert(ConfigStruct,"MailPort",25);
			}

			/* ::::::::::::::::::::::::::::::::::::::::: I18N SETTINGS :::::::::::::::::::::::::::::::::::::::::::: */
			
			//i18N Settings
			i18NSettingNodes = XMLSearch(configXML, instance.searchi18NSettings);
			//Check if empty
			if ( ArrayLen(i18NSettingNodes) gt 0 and ArrayLen(i18NSettingNodes[1].XMLChildren) gt 0){
				//Parse i18N Settings
				for (i=1; i lte ArrayLen(i18NSettingNodes[1].XMLChildren); i=i+1){
					
					//Set the Resource Bundle if Using it.
					if ( i18NSettingNodes[1].XMLChildren[i].XMLName eq "DefaultResourceBundle" and len(trim(i18NSettingNodes[1].XMLChildren[i].XMLText)) neq 0 ){
						i18NSettingNodes[1].XMLChildren[i].XMLText = trim(i18NSettingNodes[1].XMLChildren[i].XMLText);
					}
					//Check if locale is valid.
					if ( i18NSettingNodes[1].XMLChildren[i].XMLName eq "DefaultLocale" ){
						DefaultLocale = trim(i18NSettingNodes[1].XMLChildren[i].XMLText);
				 		//set the right syntax just in case.
				 		i18NSettingNodes[1].XMLChildren[i].XMLText = lcase(listFirst(DefaultLocale,"_")) & "_" & ucase(listLast(DefaultLocale,"_"));
					}
					//Insert to structure.
					StructInsert(ConfigStruct, trim(i18NSettingNodes[1].XMLChildren[i].XMLName),trim(i18NSettingNodes[1].XMLChildren[i].XMLText));
				}
				
				//set i18n
				StructInsert(ConfigStruct,"using_i18N",true);
				
				/* Empty Checks */
				if ( not structKeyExists(ConfigStruct, "DefaultResourceBundle") ){
					StructInsert(ConfigStruct,"DefaultResourceBundle","");
				}
				if ( not structKeyExists(ConfigStruct, "UknownTranslation") ){
					StructInsert(ConfigStruct,"UknownTranslation","");
				}
			}
			else{
				StructInsert(ConfigStruct,"DefaultResourceBundle","");
				StructInsert(ConfigStruct,"DefaultLocale","");
				StructInsert(ConfigStruct,"LocaleStorage","");
				StructInsert(ConfigStruct,"UknownTranslation","");
				StructInsert(ConfigStruct,"using_i18N",false);
			}
			
			/* ::::::::::::::::::::::::::::::::::::::::: BUG MAIL SETTINGS :::::::::::::::::::::::::::::::::::::::::::: */
			
			//Bug Tracer Reports
			BugEmailNodes = XMLSearch(configXML, instance.searchBugTracer);
			for (i=1; i lte ArrayLen(BugEmailNodes); i=i+1){
				BugEmails = BugEmails & trim(BugEmailNodes[i].XMLText);
				if ( i neq ArrayLen(BugEmailNodes) )
					BugEmails = BugEmails & ",";
			}
			//Insert Into Config
			StructInsert(ConfigStruct, "BugEmails", BugEmails);

			/* ::::::::::::::::::::::::::::::::::::::::: DEV ENV SETTINGS :::::::::::::::::::::::::::::::::::::::::::: */
			
			//Get Dev Environments
			DevEnvironmentNodes = XMLSearch(configXML, instance.searchDevURLS);
			//Insert DevEnvironments
			for (i=1; i lte ArrayLen(DevEnvironmentNodes); i=i+1){
				DevEnvironmentArray[i] = Trim(DevEnvironmentNodes[i].XMLText);
			}
			StructInsert(ConfigStruct,"DevEnvironments",DevEnvironmentArray);

			// Set Development or Production Environment\
			if (ArrayLen(ConfigStruct.DevEnvironments) gt 0){
				StructInsert(ConfigStruct,"Environment","PRODUCTION");
				for(i=1; i lte ArrayLen(ConfigStruct.DevEnvironments); i=i+1)
					if ( findnocase(ConfigStruct.DevEnvironments[i], CGI.HTTP_HOST) ){
						ConfigStruct.Environment = "DEVELOPMENT";
						break;
					}
			}
			else
				StructInsert(ConfigStruct,"Environment","PRODUCTION");
			
			/* ::::::::::::::::::::::::::::::::::::::::: WS SETTINGS :::::::::::::::::::::::::::::::::::::::::::: */
			
			//Get Web Services From Config.
			WebServiceNodes = XMLSearch(configXML, instance.searchWS);
			if ( ArrayLen(WebServiceNodes) ){
				//New Web Service Array
				for (i=1; i lte ArrayLen(WebServiceNodes); i=i+1){
					if ( not StructKeyExists(ProWS, trim(WebServiceNodes[i].XMLAttributes["name"])) ){
						//Production Web Services
						StructInsert(ProWS, WebServiceNodes[i].XMLAttributes["name"], Trim(WebServiceNodes[i].XMLAttributes["URL"]));
						//Check for Dev URL and the ws name is not in the DevWS struct and DevURL is not empty
						if ( StructKeyExists(WebServiceNodes[i].XMLAttributes, "DevURL") and
							 not StructKeyExists(DevWS, Trim(WebServiceNodes[i].XMLAttributes["name"])) and
							 WebServiceNodes[i].XMLAttributes["DevURL"] neq "")
							StructInsert(DevWS, WebServiceNodes[i].XMLAttributes["name"], Trim(WebServiceNodes[i].XMLAttributes["DevURL"]));
						else
							StructInsert(DevWS, WebServiceNodes[i].XMLAttributes["name"], Trim(WebServiceNodes[i].XMLAttributes["URL"]));
					} //end ProWS Key Exists
				} //end for WebService Nodes
				StructInsert(WebServicesStruct,"DEV",DevWS);
				StructInsert(WebServicesStruct,"PRO",ProWS);
			}// end ArrayLen( WebServiceNodes)
			StructInsert(ConfigStruct,"WebServices",WebServicesStruct);

			/* ::::::::::::::::::::::::::::::::::::::::: DATASOURCES SETTINGS :::::::::::::::::::::::::::::::::::::::::::: */
			
			//Datasources Support
			DatasourcesNodes = XMLSearch(configXML, instance.searchDatasources);
			if ( ArrayLen(DatasourcesNodes) ){
				//Create Structures
				for(i=1;i lte ArrayLen(DatasourcesNodes); i=i+1){
					DSNStruct = structNew();

					//Required Entries
					if ( not structKeyExists(DatasourcesNodes[i].XMLAttributes, "Alias") or len(Trim(DatasourcesNodes[i].XMLAttributes["Alias"])) eq 0 )
						$throw("This datasource entry's alias cannot be blank","","ColdBox.plugins.XMLParser.ConfigXMLParsingException");
					else
						StructInsert(DSNStruct,"Alias", Trim(DatasourcesNodes[i].XMLAttributes["Alias"]));
					if ( not structKeyExists(DatasourcesNodes[i].XMLAttributes, "Name") or len(Trim(DatasourcesNodes[i].XMLAttributes["Name"])) eq 0 )
						$throw("This datasource entry's name cannot be blank","","ColdBox.plugins.XMLParser.ConfigXMLParsingException");
					else
						StructInsert(DSNStruct,"Name", Trim(DatasourcesNodes[i].XMLAttributes["Name"]));

					//Optional Entries.
					if ( structKeyExists(DatasourcesNodes[i].XMLAttributes, "dbtype") )
						StructInsert(DSNStruct,"DBType", Trim(DatasourcesNodes[i].XMLAttributes["dbtype"]));
					else
						StructInsert(DSNStruct,"DBType","");
					if ( structKeyExists(DatasourcesNodes[i].XMLAttributes, "Username") )
						StructInsert(DSNStruct,"Username", Trim(DatasourcesNodes[i].XMLAttributes["username"]));
					else
						StructInsert(DSNStruct,"Username","");
					if ( structKeyExists(DatasourcesNodes[i].XMLAttributes, "password") )
						StructInsert(DSNStruct,"Password", Trim(DatasourcesNodes[i].XMLAttributes["password"]));
					else
						StructInsert(DSNStruct,"Password","");

					//Insert to structure
					if ( not structKeyExists(DatasourcesStruct,DSNStruct.Alias) )
						StructInsert(DatasourcesStruct, DSNStruct.Alias , DSNStruct);
					else
						$throw("The datasource alias: #dsnStruct.Alias# has already been declared.","","ColdBox.plugins.XMLParser.ConfigXMLParsingException");
				}
			}
			StructInsert(ConfigStruct, "Datasources", DatasourcesStruct);
			
			/* ::::::::::::::::::::::::::::::::::::::::: LAYOUT VIEW FOLDER SETTINGS :::::::::::::::::::::::::::::::::::::::::::: */
			
			//Layout into Config
			DefaultLayout = XMLSearch(configXML,instance.searchDefaultLayout);
			//validate Default Layout.
			if ( ArrayLen(DefaultLayout) eq 0 )
				$throw("There was no default layout element found.","","ColdBox.plugins.XMLParser.ConfigXMLParsingException");
			if ( ArrayLen(DefaultLayout) gt 1 )
				$throw("There were more than 1 DefaultLayout elements found. There can only be one.","","ColdBox.plugins.XMLParser.ConfigXMLParsingException");
			//Insert Default Layout
			StructInsert(ConfigStruct,"DefaultLayout",Trim(DefaultLayout[1].XMLText));
			
			//Default View into Config
			DefaultView = XMLSearch(configXML,instance.searchDefaultView);
			//validate Default Layout.
			if ( ArrayLen(DefaultView) eq 0 ){
				ConfigStruct["DefaultView"] = "";
			}
			else if ( ArrayLen(DefaultView) gt 1 ){
				$throw("There were more than 1 DefaultView elements found. There can only be one.","","ColdBox.plugins.XMLParser.ConfigXMLParsingException");
			}
			else{
				//Set the Default View.
				ConfigStruct["DefaultView"] = Trim(DefaultView[1].XMLText);
			}
			
			//Get View Layouts
			LayoutNodes = XMLSearch(configXML, instance.searchLayouts);
			for (i=1; i lte ArrayLen(LayoutNodes); i=i+1){
				//Get Layout for the views
				Layout = Trim(LayoutNodes[i].XMLAttributes["file"]);
				for(j=1; j lte ArrayLen(LayoutNodes[i].XMLChildren); j=j+1){
					
					//Check for View
					if( LayoutNodes[i].XMLChildren[j].XMLName eq "View" ){
						//Check for Key, if it doesn't exist then create
						if ( not StructKeyExists(LayoutViewStruct, lcase(Trim(LayoutNodes[i].XMLChildren[j].XMLText))) )
							StructInsert(LayoutViewStruct, lcase(Trim(LayoutNodes[i].XMLChildren[j].XMLText)), Layout);
					}
					//Check for Folder
					else if( LayoutNodes[i].XMLChildren[j].XMLName eq "Folder" ){
						//Check for Key, if it doesn't exist then create
						if ( not StructKeyExists(LayoutFolderStruct, lcase(Trim(LayoutNodes[i].XMLChildren[j].XMLText))) )
							StructInsert(LayoutFolderStruct, lcase(Trim(LayoutNodes[i].XMLChildren[j].XMLText)), Layout);
					}
					
				}//end for loop for the layout children
			}//end for loop of all layout nodes
			StructInsert(ConfigStruct,"ViewLayouts",LayoutViewStruct);
			StructInsert(ConfigStruct,"FolderLayouts",LayoutFolderStruct);
			
			/* :::::::::::::::::::::::::::::::::::::::::  OVERRIDE SETTINGS :::::::::::::::::::::::::::::::::::::::::::: */
			
			//Cache Override Settings
			CacheSettingNodes = XMLSearch(configXML, instance.searchCache);
			//Create CacheSettings Structure
			structInsert(ConfigStruct,"CacheSettings",structNew());
			//Check if empty
			if ( ArrayLen(CacheSettingNodes) gt 0 and ArrayLen(CacheSettingNodes[1].XMLChildren) gt 0){

				//Checks For Default Timeout
				if ( structKeyExists(CacheSettingNodes[1], "ObjectDefaultTimeout") and isNumeric(CacheSettingNodes[1].ObjectDefaultTimeout.xmlText) )
					StructInsert(ConfigStruct.CacheSettings, "ObjectDefaultTimeout", trim(CacheSettingNodes[1].ObjectDefaultTimeout.xmlText) );
				else
					$throw("Invalid object timeout. Please see schema.","Value=#CacheSettingNodes[1].ObjectDefaultTimeout.xmlText#","ColdBox.plugins.XMLParser.InvalidCacheObjectDefaultTimeout");

				//Check ObjectDefaultLastAccessTimeout
				if ( structKeyExists(CacheSettingNodes[1], "ObjectDefaultLastAccessTimeout") and isNumeric(CacheSettingNodes[1].ObjectDefaultLastAccessTimeout.xmlText))
					StructInsert(ConfigStruct.CacheSettings, "ObjectDefaultLastAccessTimeout", trim(CacheSettingNodes[1].ObjectDefaultLastAccessTimeout.xmlText) );
				else
					$throw("Invalid object last access timeout. Please see schema.","Value=#CacheSettingNodes[1].ObjectDefaultLastAccessTimeout.xmlText#","ColdBox.plugins.XMLParser.InvalidObjectDefaultLastAccessTimeout");

				//Check ReapFrequency
				if ( structKeyExists(CacheSettingNodes[1], "ReapFrequency") and isNumeric(CacheSettingNodes[1].ReapFrequency.xmlText))
					StructInsert(ConfigStruct.CacheSettings, "ReapFrequency", trim(CacheSettingNodes[1].ReapFrequency.xmlText) );
				else
					$throw("Invalid reaping frequency. Please see schema.","Value=#CacheSettingNodes[1].ReapFrequency.xmlText#","ColdBox.plugins.XMLParser.InvalidReapFrequency");

				//Check MaxObjects
				if ( structKeyExists(CacheSettingNodes[1], "MaxObjects") and isNumeric(CacheSettingNodes[1].MaxObjects.xmlText)){
					StructInsert(ConfigStruct.CacheSettings, "MaxObjects", trim(CacheSettingNodes[1].MaxObjects.xmlText) );
				}
				else
					$throw("Invalid Max Objects. Please see schema.","Value=#CacheSettingNodes[1].MaxObjects.xmlText#","ColdBox.plugins.XMLParser.InvalidMaxObjects");

				//Check FreeMemoryPercentageThreshold
				if ( structKeyExists(CacheSettingNodes[1], "FreeMemoryPercentageThreshold") and isNumeric(CacheSettingNodes[1].FreeMemoryPercentageThreshold.xmlText)){
					StructInsert(ConfigStruct.CacheSettings, "FreeMemoryPercentageThreshold", trim(CacheSettingNodes[1].FreeMemoryPercentageThreshold.xmlText) );
				}
				else
					$throw("Invalid Free Memory Percentage Threshold. Please see schema.","Value=#CacheSettingNodes[1].FreeMemoryPercentageThreshold.xmlText#","ColdBox.plugins.XMLParser.InvalidFreeMemoryPercentageThreshold");

				//Check for CacheUseLastAccessTimeouts
				if ( structKeyExists(CacheSettingNodes[1], "UseLastAccessTimeouts") and isBoolean(CacheSettingNodes[1].UseLastAccessTimeouts.xmlText) ){
					StructInsert(ConfigStruct.CacheSettings, "UseLastAccessTimeouts", trim(CacheSettingNodes[1].UseLastAccessTimeouts.xmlText) );
				}
				else{
					StructInsert(ConfigStruct.CacheSettings, "UseLastAccessTimeouts", fwSettingsStruct.CacheUseLastAccessTimeouts );
				}	
				
				//Check for CacheEvictionPolicy
				if ( structKeyExists(CacheSettingNodes[1], "EvictionPolicy") ){
					StructInsert(ConfigStruct.CacheSettings, "EvictionPolicy", trim(CacheSettingNodes[1].EvictionPolicy.xmlText) );
				}
				else{
					StructInsert(ConfigStruct.CacheSettings, "EvictionPolicy", fwSettingsStruct.CacheEvictionPolicy );
				}			
				//Set Override to true.
				ConfigStruct.CacheSettings.Override = true;
			}
			else{
				ConfigStruct.CacheSettings.Override = false;
			}
			
			/* ::::::::::::::::::::::::::::::::::::::::: DEBUGGER SETTINGS :::::::::::::::::::::::::::::::::::::::::::: */
			
			/* DEBUGGER SETTING NODES */
			DebuggerSettingNodes = XMLSearch(configXML, instance.searchDebuggerSettings);
			//Create debugger settings Structure
			structInsert(ConfigStruct,"DebuggerSettings",structNew());
			//Check if empty
			if ( ArrayLen(DebuggerSettingNodes) gt 0 and ArrayLen(DebuggerSettingNodes[1].XMLChildren) gt 0){
				/* PersistentRequestProfiler */
				if ( structKeyExists(DebuggerSettingNodes[1], "PersistentRequestProfiler") and isBoolean(DebuggerSettingNodes[1].PersistentRequestProfiler.xmlText) )
					StructInsert(ConfigStruct.DebuggerSettings, "PersistentRequestProfiler", trim(DebuggerSettingNodes[1].PersistentRequestProfiler.xmlText) );
				/* maxPersistentRequestProfilers */
				if ( structKeyExists(DebuggerSettingNodes[1], "maxPersistentRequestProfilers") and isNumeric(DebuggerSettingNodes[1].maxPersistentRequestProfilers.xmlText) )
					StructInsert(ConfigStruct.DebuggerSettings, "maxPersistentRequestProfilers", trim(DebuggerSettingNodes[1].maxPersistentRequestProfilers.xmlText) );
				/* maxRCPanelQueryRows */
				if ( structKeyExists(DebuggerSettingNodes[1], "maxRCPanelQueryRows") and isNumeric(DebuggerSettingNodes[1].maxRCPanelQueryRows.xmlText) )
					StructInsert(ConfigStruct.DebuggerSettings, "maxRCPanelQueryRows", trim(DebuggerSettingNodes[1].maxRCPanelQueryRows.xmlText) );
				
				/* TracerPanel */
				if ( structKeyExists(DebuggerSettingNodes[1], "TracerPanel") ){
					debugPanelAttributeInsert(ConfigStruct.DebuggerSettings,"TracerPanel",DebuggerSettingNodes[1].TracerPanel.xmlAttributes);
				}
				/* InfoPanel */
				if ( structKeyExists(DebuggerSettingNodes[1], "InfoPanel") ){
					debugPanelAttributeInsert(ConfigStruct.DebuggerSettings,"InfoPanel",DebuggerSettingNodes[1].InfoPanel.xmlAttributes);
				}
				/* CachePanel */
				if ( structKeyExists(DebuggerSettingNodes[1], "CachePanel") ){
					debugPanelAttributeInsert(ConfigStruct.DebuggerSettings,"CachePanel",DebuggerSettingNodes[1].CachePanel.xmlAttributes);
				}
				/* RCPanel */
				if ( structKeyExists(DebuggerSettingNodes[1], "RCPanel") ){
					debugPanelAttributeInsert(ConfigStruct.DebuggerSettings,"RCPanel",DebuggerSettingNodes[1].RCPanel.xmlAttributes);
				}	
				
				//Set Override to true.
				ConfigStruct.DebuggerSettings.Override = true;			
			}
			else{
				ConfigStruct.DebuggerSettings.Override = false;
			}
						
			/* ::::::::::::::::::::::::::::::::::::::::: INTERCEPTOR SETTINGS :::::::::::::::::::::::::::::::::::::::::::: */
			
			/* Interceptor Preparation. */
			StructInsert( ConfigStruct, "InterceptorConfig", structnew() );
			StructInsert( ConfigStruct.InterceptorConfig, "Interceptors", arraynew(1) );
			
			/* Start by throwOnInvalidStates */
			StructInsert( ConfigStruct.InterceptorConfig, "throwOnInvalidStates", true );
			//Search for the override
			InterceptorBase = XMLSearch(configXML,instance.searchInterceptorBase);
			if ( ArrayLen(InterceptorBase) neq 0 and structKeyExists(InterceptorBase[1].XMLAttributes, "throwOnInvalidStates") ){
				ConfigStruct.InterceptorConfig['throwOnInvalidStates'] = InterceptorBase[1].XMLAttributes.throwOnInvalidStates;
			}
			
				
			/* Start by Custom Interception Point */
			CustomInterceptionPoints = XMLSearch(configXML,instance.searchInterceptorCustomPoints);
			//validate Custom Interception Point
			if ( ArrayLen(CustomInterceptionPoints) eq 0 )
				StructInsert(ConfigStruct.InterceptorConfig,"CustomInterceptionPoints","");
			else if ( ArrayLen(CustomInterceptionPoints) gt 1 )
				$throw("There were more than 1 CustomInterceptionPoints elements found. There can only be one.","","ColdBox.plugins.XMLParser.ConfigXMLParsingException");
			else
				StructInsert(ConfigStruct.InterceptorConfig,"CustomInterceptionPoints",oUtilities.placeHolderReplacer(Trim(CustomInterceptionPoints[1].XMLText),ConfigStruct));
			
			/* Parse all Interceptor Nodes now. */
			InterceptorNodes = XMLSearch(configXML, instance.searchInterceptors);
			for (i=1; i lte ArrayLen(InterceptorNodes); i=i+1){
				//Interceptor Struct
				InterceptorStruct = structnew();
				//get Class
				InterceptorStruct.class = oUtilities.placeHolderReplacer(Trim(InterceptorNodes[i].XMLAttributes["class"]),ConfigStruct);
				//Prepare Properties
				InterceptorStruct.properties = structnew();
			
				//Parse Interceptor Properties
				if ( ArrayLen(InterceptorNodes[i].XMLChildren) ){
					for(j=1; j lte ArrayLen(InterceptorNodes[i].XMLChildren); j=j+1){
						//Property Complex Check
						tempProperty = oUtilities.placeHolderReplacer(Trim( InterceptorNodes[i].XMLChildren[j].XMLText ),ConfigStruct);
						//Check for Complex Setup
						if( reFindNocase(instance.jsonRegex,tempProperty) ){
							StructInsert( InterceptorStruct.properties, Trim(InterceptorNodes[i].XMLChildren[j].XMLAttributes["name"]), getPlugin('json').decode(replace(tempProperty,"'","""","all")) );
						}
						else{
							StructInsert( InterceptorStruct.properties, Trim(InterceptorNodes[i].XMLChildren[j].XMLAttributes["name"]), tempProperty );
						}
					}//end loop of properties
				}//end if no properties
				
				//Add to Array
				ArrayAppend( ConfigStruct.InterceptorConfig.Interceptors, InterceptorStruct );
				
			}//end interceptor nodes
			
			/* ::::::::::::::::::::::::::::::::::::::::: CONFIG FILE LAST MODIFIED SETTING :::::::::::::::::::::::::::::::::::::::::::: */
			StructInsert(ConfigStruct, "ConfigTimeStamp", oUtilities.FileLastModified(ConfigFileLocation));
			/* ::::::::::::::::::::::::::::::::::::::::: XSD VALIDATION :::::::::::::::::::::::::::::::::::::::::::: */
						
			//Determine which CF version for XML Parsing method
			if ( fwSettingsStruct["xmlValidateActive"] ){
				//Finally Validate With XSD
				xmlvalidation = XMLValidate(configXML, getController().getSetting("ConfigFileSchemaLocation", true));
				//Validate Errors
				if(NOT xmlvalidation.status){
					for(i = 1; i lte ArrayLen(xmlvalidation.errors); i = i + 1){
						errorDetails = errorDetails & xmlvalidation.errors[i] & chr(10) & chr(13);
					}
					//Throw the error.
					$throw("<br>The config.xml file does not validate with the framework's schema.","The error details are:<br/> #errorDetails#","ColdBox.plugins.XMLParser.ConfigXMLParsingException");
				}// if invalid status
			}//if xml validation is on
			
		}//end of try
		catch( Any Exception ){
			$throw("#Exception.Message# & #Exception.Detail#",Exception.tagContext.toString(), "ColdBox.plugins.XMLParser.ConfigXMLParsingException");
		}
		
		//finish
		return ConfigStruct;
		</cfscript>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->
					
	<!--- Debug Panel attribute insert --->
	<cffunction name="debugPanelAttributeInsert" access="private" returntype="void" hint="Insert a key into a panel attribute" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="Config"			required="true" type="struct" hint="">
		<cfargument name="Panel" 			required="true" type="string" hint="">
		<cfargument name="PanelXML" 		required="true" type="any" hint="">
		<!--- ************************************************************* --->
		<cfscript>
			/* Show Key */
			if( structKeyExists(arguments.panelXML,"show") ){
				StructInsert(arguments.config, "show#arguments.Panel#", trim(arguments.panelXML.show) );
			}	
			/* Expanded Key */
			if( structKeyExists(arguments.panelXML,"expanded") ){
				StructInsert(arguments.config, "expanded#arguments.Panel#", trim(arguments.panelXML.expanded) );
			}		
		</cfscript>
	</cffunction>

	<!--- read file --->
	<cffunction name="readFile" access="private" output="false" returntype="string"  hint="Facade to Read a file's content">
		<!--- ************************************************************* --->
		<cfargument name="FileToRead"	 		type="String"  required="yes" 	 hint="The absolute path to the file.">
		<!--- ************************************************************* --->
		<cfset var FileContents = "">
		<cffile action="read" file="#arguments.FileToRead#" variable="FileContents">
		<cfreturn FileContents>
	</cffunction>

	<!--- Get Absolute Path --->
	<cffunction name="getAbsolutePath" access="private" output="false" returntype="string" hint="Turn any system path, either relative or absolute, into a fully qualified one">
		<!--- ************************************************************* --->
		<cfargument name="path" type="string" required="true" hint="Abstract pathname">
		<!--- ************************************************************* --->
		<cfscript>
		var FileObj = CreateObject("java","java.io.File").init(JavaCast("String",arguments.path));
		if(FileObj.isAbsolute()){
			return arguments.path;
		}
		else{
			return ExpandPath(arguments.path);
		}
		</cfscript>
	</cffunction>
	
</cfcomponent>