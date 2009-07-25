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
----------------------------------------------------------------------->
<cfcomponent name="XMLParser"
			 hint="This is the XML Parser plugin for the framework. It takes care of any XML parsing for the framework's usage."
			 extends="coldbox.system.Plugin"
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
				
			//ColdBox Properties
			instance.FileSeparator = createObject("java","java.lang.System").getProperty("file.separator");
			instance.FrameworkConfigFile = ExpandPath("/coldbox/system/config/settings.xml");
			instance.FrameworkConfigXSDFile = ExpandPath("/coldbox/system/config/config.xsd");
			
			// Regex for JSON
			instance.jsonRegex = "^(\{|\[)(.)*(\}|\])$";
			
			//Return
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<cffunction name="loadFramework" access="public" hint="Load the framework's configuration xml." output="false" returntype="struct">
		<!--- ************************************************************* --->
		<cfargument name="overrideConfigFile" required="false" type="string" default="" hint="Only used for unit testing or reparsing of a specific coldbox config file.">
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
				$throw("Error finding settings.xml configuration file. The file #instance.FrameworkConfigFile# cannot be found.","","XMLParser.ColdBoxSettingsNotFoundException");
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
			SettingNodes = XMLSearch(fwXML,"//Settings/Setting");
			//Insert Settings to Config Struct
			for (i=1; i lte ArrayLen(SettingNodes); i=i+1)
				StructInsert( settingsStruct, SettingNodes[i].XMLAttributes["name"], trim(SettingNodes[i].XMLAttributes["value"]));

			//OS File Separator
			StructInsert(settingsStruct, "OSFileSeparator", instance.FileSeparator );

			//Conventions Parsing
			conventions = XMLSearch(fwXML,"//Conventions");
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
					$throw("ColdBox Application Configuration File can't be found.","The accepted files are: #ConfigXMLFilePath#","XMLParser.ConfigXMLFileNotFoundException");
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
		}
		catch( Any Exception ){
			$throw("Error Loading Framework Configuration.","#Exception.Message# #Exception.Detail#","XMLParser.ColdboxSettingsParsingException");
		}
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="parseConfig" access="public" returntype="struct" output="false" hint="Parse the application configuration file.">
		<!--- ************************************************************* --->
		<cfargument name="overrideAppMapping" type="string" required="false" default="" hint="Only used for unit testing or reparsing of a specific coldbox config file."/>
		<!--- ************************************************************* --->
		<cfscript>
		//Create Config Structure
		var ConfigStruct = StructNew();
		var fwSettingsStruct = getController().getColdboxSettings();
		var ConfigFileLocation = fwSettingsStruct["ConfigFileLocation"];
		var configXML = "";
		//Appmapping Variables
		var webPath = "";
		var localPath = "";
		var PathLocation = "";
		//helper
		var oUtilities = getPlugin("Utilities");
		//Testers
		var xmlvalidation = "";
		var errorDetails = "";
		var i = 1;
		
		try{
			/* ::::::::::::::::::::::::::::::::::::::::: CONFIG FILE PARSING & VALIDATION :::::::::::::::::::::::::::::::::::::::::::: */
			//Validate File, just in case.
			if ( not fileExists(ConfigFileLocation) ){
				$throw("The Config File: #ConfigFileLocation# can't be found.","","XMLParser.ConfigXMLFileNotFoundException");
			}			
			//Determine Parse Type AND Parse Configuration File
			if ( not fwSettingsStruct["xmlParseActive"] ){
				configXML = xmlParse(readFile(ConfigFileLocation,false,"utf-8"));
			}
			else{
				configXML = xmlParse(ConfigFileLocation);
			}
			//Validate the config element
			if ( not structKeyExists(configXML, "config")  )
				$throw("No Config element found in the configuration file","","XMLParser.ConfigXMLParsingException");

			/* ::::::::::::::::::::::::::::::::::::::::: APP LOCATION CALCULATIONS :::::::::::::::::::::::::::::::::::::::::::: */
			
			//Setup the Application Path with an Override
			if( arguments.overrideAppMapping neq "" ){
				ConfigStruct.ApplicationPath = ExpandPath(arguments.overrideAppMapping);
				if( right(ConfigStruct.ApplicationPath,1) neq "/"){
					ConfigStruct.ApplicationPath = ConfigStruct.ApplicationPath & "/";
				}
			}
			else{
				// Setup Default App Path from main controller
				ConfigStruct.ApplicationPath = controller.getAppRootPath();
			}
			
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
			
			/* ::::::::::::::::::::::::::::::::::::::::: GET COLDBOX SETTINGS  :::::::::::::::::::::::::::::::::::::::::::: */
			parseColdboxSettings(configXML,configStruct,oUtilities,arguments.overrideAppMapping);
			
			/* ::::::::::::::::::::::::::::::::::::::::: YOUR SETTINGS LOADING :::::::::::::::::::::::::::::::::::::::::::: */
			parseYourSettings(configXML,configStruct,oUtilities);	
			
			/* ::::::::::::::::::::::::::::::::::::::::: YOUR CONVENTIONS LOADING :::::::::::::::::::::::::::::::::::::::::::: */
			parseConventions(configXML,configStruct,oUtilities);
			
			/* ::::::::::::::::::::::::::::::::::::::::: MODEL SETTINGS  :::::::::::::::::::::::::::::::::::::::::::: */
			parseModels(configXML,configStruct,oUtilities);
			
			/* ::::::::::::::::::::::::::::::::::::::::: IOC SETTINGS  :::::::::::::::::::::::::::::::::::::::::::: */
			parseIOC(configXML,configStruct,oUtilities);
			
			/* ::::::::::::::::::::::::::::::::::::::::: HANDLER-MODELS-PLUGIN INVOCATION PATHS :::::::::::::::::::::::::::::::::::::::::::: */
			parseInvocationPaths(configXML,configStruct,oUtilities);
			
			/* ::::::::::::::::::::::::::::::::::::::::: EXTERNAL LAYOUTS/VIEWS LOCATION :::::::::::::::::::::::::::::::::::::::::::: */
			parseExternalLocations(configXML,configStruct,oUtilities);
			
			/* ::::::::::::::::::::::::::::::::::::::::: MAIL SETTINGS :::::::::::::::::::::::::::::::::::::::::::: */
			parseMailSettings(configXML,configStruct,oUtilities);	
			
			/* ::::::::::::::::::::::::::::::::::::::::: I18N SETTINGS :::::::::::::::::::::::::::::::::::::::::::: */
			parseLocalization(configXML,configStruct,oUtilities);			
			
			/* ::::::::::::::::::::::::::::::::::::::::: BUG MAIL SETTINGS :::::::::::::::::::::::::::::::::::::::::::: */
			parseBugTracers(configXML,configStruct,oUtilities);			
			
			/* ::::::::::::::::::::::::::::::::::::::::: ENVIRONMENT SETTING :::::::::::::::::::::::::::::::::::::::::::: */
			ConfigStruct.Environment = "PRODUCTION";
			
			/* ::::::::::::::::::::::::::::::::::::::::: WS SETTINGS :::::::::::::::::::::::::::::::::::::::::::: */
			parseWebservices(configXML,configStruct,oUtilities);			

			/* ::::::::::::::::::::::::::::::::::::::::: DATASOURCES SETTINGS :::::::::::::::::::::::::::::::::::::::::::: */
			parseDatasources(configXML,configStruct,oUtilities);
			
			/* ::::::::::::::::::::::::::::::::::::::::: LAYOUT VIEW FOLDER SETTINGS :::::::::::::::::::::::::::::::::::::::::::: */
			parseLayoutsViews(configXML,configStruct,oUtilities);			
			
			/* :::::::::::::::::::::::::::::::::::::::::  CACHE SETTINGS :::::::::::::::::::::::::::::::::::::::::::: */
			parseCacheSettings(configXML,configStruct,oUtilities);
						
			/* ::::::::::::::::::::::::::::::::::::::::: DEBUGGER SETTINGS :::::::::::::::::::::::::::::::::::::::::::: */
			parseDebuggerSettings(configXML,configStruct,oUtilities);			
						
			/* ::::::::::::::::::::::::::::::::::::::::: INTERCEPTOR SETTINGS :::::::::::::::::::::::::::::::::::::::::::: */
			parseInterceptors(configXML,configStruct,oUtilities);
			
			/* ::::::::::::::::::::::::::::::::::::::::: LOGBOX Configuration :::::::::::::::::::::::::::::::::::::::::::: */
			parseLogBox(configXML,configStruct,oUtilities);
			
			/* ::::::::::::::::::::::::::::::::::::::::: CONFIG FILE LAST MODIFIED SETTING :::::::::::::::::::::::::::::::::::::::::::: */
			ConfigStruct.ConfigTimeStamp = oUtilities.FileLastModified(ConfigFileLocation);
			
			/* ::::::::::::::::::::::::::::::::::::::::: XSD VALIDATION :::::::::::::::::::::::::::::::::::::::::::: */
		
		}
		catch( Any Exception ){
			$throw("#Exception.Message# & #Exception.Detail#",Exception.tagContext.toString(), "XMLParser.ConfigXMLParsingException");
		}
			
		//Determine which CF version for XML Parsing method
		if ( fwSettingsStruct["xmlValidateActive"] ){
			//Finally Validate With XSD
			xmlvalidation = XMLValidate(configXML, fwSettingsStruct["ConfigFileSchemaLocation"]);
			//Validate Errors
			if(NOT xmlvalidation.status){
				for(i = 1; i lte ArrayLen(xmlvalidation.errors); i = i + 1){
					errorDetails = errorDetails & xmlvalidation.errors[i] & chr(10) & chr(13);
				}
				//Throw the error.
				$throw("<br>The config.xml file does not validate with the framework's schema.","The error details are:<br/> #errorDetails#","XMLParser.ConfigXMLParsingException");
			}// if invalid status
		}//if xml validation is on
			
		
		//finish
		return ConfigStruct;
		</cfscript>
	</cffunction>
	
	<!--- parseColdboxSettings --->
	<cffunction name="parseColdboxSettings" output="false" access="public" returntype="void" hint="Parse ColdBox Settings">
		<cfargument name="xml" 		type="any" required="true" hint="The xml object"/>
		<cfargument name="config" 	type="struct" required="true" hint="The config struct"/>
		<cfargument name="utility"  type="any" required="true" hint="The utility object"/>
		<cfargument name="overrideAppMapping" type="string" required="false" default="" hint="Only used for unit testing or reparsing of a specific coldbox config file."/>
		<cfscript>
			var ConfigStruct = arguments.config;
			var fwSettingsStruct = controller.getColdBoxSettings();
			var SettingNodes = XMLSearch(arguments.xml,"//Settings/Setting");
			var i=1;
			
			if ( ArrayLen(SettingNodes) eq 0 )
				$throw("No Setting elements could be found in the configuration file.","","XMLParser.ConfigXMLParsingException");
			//Insert  ColdBox Settings to Config Struct
			for (i=1; i lte ArrayLen(SettingNodes); i=i+1){
				ConfigStruct[trim(SettingNodes[i].XMLAttributes["name"])] = arguments.utility.placeHolderReplacer(trim(SettingNodes[i].XMLAttributes["value"]),ConfigStruct);
			}
			//overrideAppMapping if passed in.
			if ( arguments.overrideAppMapping neq "" ){
				ConfigStruct["AppMapping"] = arguments.overrideAppMapping;
			}
			// Clean the first / if found
			if( len(ConfigStruct.AppMapping) eq 1 ){
				ConfigStruct["AppMapping"] = "";
			}
			
			/* ::::::::::::::::::::::::::::::::::::::::: COLDBOX SETTINGS VALIDATION :::::::::::::::::::::::::::::::::::::::::::: */
			//Check for AppName or throw
			if ( not StructKeyExists(ConfigStruct, "AppName") )
				$throw("There was no 'AppName' setting defined. This is required by the framework.","","XMLParser.ConfigXMLParsingException");
			//Check for Default Event
			if ( not StructKeyExists(ConfigStruct, "DefaultEvent") )
				$throw("There was no 'DefaultEvent' setting defined. This is required by the framework.","","XMLParser.ConfigXMLParsingException");
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
			//Check for PluginsExternalLocation if found
			if ( not structkeyExists(ConfigStruct, "PluginsExternalLocation") )
				ConfigStruct["PluginsExternalLocation"] = "";
			//Check for Handler Caching
			if ( not structKeyExists(ConfigStruct, "HandlerCaching") or not isBoolean(ConfigStruct.HandlerCaching) )
				ConfigStruct["HandlerCaching"] = true;
			//Check for Event Caching
			if ( not structKeyExists(ConfigStruct, "EventCaching") or not isBoolean(ConfigStruct.EventCaching) )
				ConfigStruct["EventCaching"] = true;
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
			// Flash URL Persist Scope Override
			if( structKeyExists(ConfigStruct,"FlashURLPersistScope") and reFindnocase("^(session|client)$",ConfigStruct["FlashURLPersistScope"]) ){
				fwSettingsStruct["FlashURLPersistScope"] = ConfigStruct["FlashURLPersistScope"];
			}
		</cfscript>
	</cffunction>
	
	<!--- parseInvocationPaths --->
	<cffunction name="parseInvocationPaths" output="false" access="public" returntype="void" hint="Parse Invocation paths">
		<cfargument name="xml" 		type="any" required="true" hint="The xml object"/>
		<cfargument name="config" 	type="struct" required="true" hint="The config struct"/>
		<cfargument name="utility"  type="any" required="true" hint="The utility object"/>
		<cfscript>
			var ConfigStruct = arguments.config;
			var fwSettingsStruct = controller.getColdBoxSettings();
			
			//Set the Handlers External Configuration Paths
			if( configStruct["HandlersExternalLocation"] neq "" ){
				//Expand the external location to get a registration path
				configStruct["HandlersExternalLocationPath"] = ExpandPath("/" & replace(ConfigStruct["HandlersExternalLocation"],".","/","all"));
			}
			else{
				configStruct["HandlersExternalLocationPath"] = "";
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
		</cfscript>
	</cffunction>
	
	<!--- parseExternalLocations --->
	<cffunction name="parseExternalLocations" output="false" access="public" returntype="void" hint="Parse External locations">
		<cfargument name="xml" 		type="any" required="true" hint="The xml object"/>
		<cfargument name="config" 	type="struct" required="true" hint="The config struct"/>
		<cfargument name="utility"  type="any" required="true" hint="The utility object"/>
		<cfscript>
			var ConfigStruct = arguments.config;
			
			// check for ViewsExternalLocation 
			if( structKeyExists(configStruct,"ViewsExternalLocation") and configStruct["ViewsExternalLocation"] neq "" ){
				// Verify the locations, do relative to the app mapping first 
				if( directoryExists(controller.getAppRootPath() & configStruct["ViewsExternalLocation"]) ){
					configStruct["ViewsExternalLocation"] = "/" & ConfigStruct["AppMapping"] & "/" & configStruct["ViewsExternalLocation"];
				}
				else if( not directoryExists(expandPath(configStruct["ViewsExternalLocation"])) ){
					$throw("ViewsExternalLocation could not be found.","The directories tested was relative and expanded using #configStruct['ViewsExternalLocation']#. Please verify your setting.","XMLParser.ConfigXMLParsingException");
				}
				// Cleanup 
				if ( right(configStruct["ViewsExternalLocation"],1) eq "/" ){
					 configStruct["ViewsExternalLocation"] = left(configStruct["ViewsExternalLocation"],len(configStruct["ViewsExternalLocation"])-1);
				}
			}else{
				configStruct["ViewsExternalLocation"] = "";
			}
			
			// check for LayoutsExternalLocation
			if( structKeyExists(configStruct,"LayoutsExternalLocation") and configStruct["LayoutsExternalLocation"] neq "" ){
				// Verify the locations, do relative to the app mapping first
				if( directoryExists(controller.getAppRootPath() & configStruct["LayoutsExternalLocation"]) ){
					configStruct["LayoutsExternalLocation"] = "/" & ConfigStruct["AppMapping"] & "/" & configStruct["LayoutsExternalLocation"];
				}
				else if( not directoryExists(expandPath(configStruct["LayoutsExternalLocation"])) ){
					$throw("LayoutsExternalLocation could not be found.","The directories tested was relative and expanded using #configStruct['LayoutsExternalLocation']#. Please verify your setting.","XMLParser.ConfigXMLParsingException");
				}
				// Cleanup
				if ( right(configStruct["LayoutsExternalLocation"],1) eq "/" ){
					 configStruct["LayoutsExternalLocation"] = left(configStruct["LayoutsExternalLocation"],len(configStruct["LayoutsExternalLocation"])-1);
				}
			}else{
				configStruct["LayoutsExternalLocation"] = "";
			}
		</cfscript>
	</cffunction>
	
	<!--- parseConventions --->
	<cffunction name="parseConventions" output="false" access="public" returntype="void" hint="Parse Conventions">
		<cfargument name="xml" 		type="any" required="true" hint="The xml object"/>
		<cfargument name="config" 	type="struct" required="true" hint="The config struct"/>
		<cfargument name="utility"  type="any" required="true" hint="The utility object"/>
		<cfscript>
			var ConfigStruct = arguments.config;
			var conventions = XMLSearch(arguments.xml,"//Conventions");
			var fwSettingsStruct = controller.getColdboxSettings();
			
			if( ArrayLen(conventions) ){
				/* Override conventions on a per found basis. */
				if( structKeyExists(conventions[1],"handlersLocation") ){ fwSettingsStruct["handlersConvention"] = trim(conventions[1].handlersLocation.xmltext); }
				if( structKeyExists(conventions[1],"pluginsLocation") ){ fwSettingsStruct["pluginsConvention"] = trim(conventions[1].pluginsLocation.xmltext); }
				if( structKeyExists(conventions[1],"layoutsLocation") ){ fwSettingsStruct["LayoutsConvention"] = trim(conventions[1].layoutsLocation.xmltext); }
				if( structKeyExists(conventions[1],"viewsLocation") ){ fwSettingsStruct["ViewsConvention"] = trim(conventions[1].viewsLocation.xmltext); }
				if( structKeyExists(conventions[1],"eventAction") ){ fwSettingsStruct["eventAction"] = trim(conventions[1].eventAction.xmltext); }
				if( structKeyExists(conventions[1],"modelsLocation") ){ fwSettingsStruct["ModelsConvention"] = trim(conventions[1].modelsLocation.xmltext); }
			}
		</cfscript>
	</cffunction>

	<!--- parseYourSettings --->
	<cffunction name="parseYourSettings" output="false" access="public" returntype="void" hint="Parse Your Settings">
		<cfargument name="xml" 		type="any" required="true" hint="The xml object"/>
		<cfargument name="config" 	type="struct" required="true" hint="The config struct"/>
		<cfargument name="utility"  type="any" required="true" hint="The utility object"/>
		<cfscript>
			var ConfigStruct = arguments.config;
			//Your Settings To Load
			var YourSettingNodes = XMLSearch(arguments.xml, "//YourSettings/Setting");
			var i=1;
			var tester = "";
			
			if ( ArrayLen(YourSettingNodes) ){
				//Insert Your Settings to Config Struct
				for (i=1; i lte ArrayLen(YourSettingNodes); i=i+1){
					/* Get Setting with PlaceHolding */
					tester = arguments.utility.placeHolderReplacer(trim(YourSettingNodes[i].XMLAttributes["value"]),ConfigStruct);
					//Test for JSON
					if( reFindNocase(instance.jsonRegex,tester) ){
						ConfigStruct[YourSettingNodes[i].XMLAttributes["name"]] = getPlugin("JSON").decode(replace(tester,"'","""","all"));
					}
					else
						ConfigStruct[YourSettingNodes[i].XMLAttributes["name"]] = tester;
				}
			}
		</cfscript>
	</cffunction>

	<!--- parseLocalization --->
	<cffunction name="parseMailSettings" output="false" access="public" returntype="void" hint="Parse Mail Settings">
		<cfargument name="xml" 		type="any" required="true" hint="The xml object"/>
		<cfargument name="config" 	type="struct" required="true" hint="The config struct"/>
		<cfargument name="utility"  type="any" required="true" hint="The utility object"/>
		<cfargument name="isOverride" type="boolean" required="false" default="false" hint="Flag to denote if overriding or first time runner."/>
		<cfscript>
			var ConfigStruct = arguments.config;
			//Mail Settings
			var MailSettingsNodes = XMLSearch(arguments.xml,"//MailServerSettings");
			
			// Overrides?
			if (NOT arguments.isOverride){
				ConfigStruct.MailServer = "";
				ConfigStruct.MailUsername = "";
				ConfigStruct.MailPassword = "";
				ConfigStruct.MailPort = 25;
			}
			
			//Check if empty
			if ( ArrayLen(MailSettingsNodes) gt 0 and ArrayLen(MailSettingsNodes[1].XMLChildren) gt 0){
				//Checks
				if ( structKeyExists(MailSettingsNodes[1], "MailServer") )
					ConfigStruct.MailServer = trim(MailSettingsNodes[1].MailServer.xmlText);
				
				//Mail username
				if ( structKeyExists(MailSettingsNodes[1], "MailUsername") )
					ConfigStruct.MailUsername = trim(MailSettingsNodes[1].MailUsername.xmlText);
				
				//Mail password
				if ( structKeyExists(MailSettingsNodes[1], "MailPassword") )
					ConfigStruct.MailPassword = trim(MailSettingsNodes[1].MailPassword.xmlText);
				
				//Mail Port
				if ( structKeyExists(MailSettingsNodes[1], "MailPort") AND isNumeric(MailSettingsNodes[1].MailPort.xmlText) ){
					ConfigStruct.MailPort = trim(MailSettingsNodes[1].MailPort.xmlText);
				}				
			}
		</cfscript>
	</cffunction>
	
	<!--- parseIOC --->
	<cffunction name="parseIOC" output="false" access="public" returntype="void" hint="Parse IOC Integration">
		<cfargument name="xml" 		type="any" required="true" hint="The xml object"/>
		<cfargument name="config" 	type="struct" required="true" hint="The config struct"/>
		<cfargument name="utility"  type="any" required="true" hint="The utility object"/>
		<cfargument name="isOverride" type="boolean" required="false" default="false" hint="Flag to denote if overriding or first time runner."/>
		<cfscript>
			var ConfigStruct = arguments.config;
			var iocNodes = XMLSearch(arguments.xml,"//IOC");
			var fwSettingsStruct = controller.getColdBoxSettings();
			
			// Defaults
			if (NOT arguments.isOverride){
				ConfigStruct.IOCFramework = "";
				ConfigStruct.IOCFrameworkReload = false;
				ConfigStruct.IOCDefinitionFile = "";
				ConfigStruct.IOCDebugLevel = "OFF";
				ConfigStruct.IOCObjectCaching = false;
				ConfigStruct.IOCParentFactory = "";
				ConfigStruct.IOCParentFactoryDefinitionFile = "";
			}
			
			//Check if empty
			if ( ArrayLen(iocNodes) gt 0 and ArrayLen(iocNodes[1].XMLChildren) gt 0){
				//Check for IOC Framework
				if ( structKeyExists(iocNodes[1], "Framework") ){
					if( structKeyExists(iocNodes[1].Framework.xmlAttributes,"type") ){
						ConfigStruct["IOCFramework"] = iocNodes[1].Framework.xmlAttributes.type;
					}
					if( structKeyExists(iocNodes[1].Framework.xmlAttributes,"reload") ){
						ConfigStruct["IOCFrameworkReload"] = iocNodes[1].Framework.xmlAttributes.reload;
					}
					if( structKeyExists(iocNodes[1].Framework.xmlAttributes,"objectCaching") ){
						ConfigStruct["IOCObjectCaching"] = iocNodes[1].Framework.xmlAttributes.objectCaching;
					}
					ConfigStruct["IOCDefinitionFile"] = iocNodes[1].Framework.xmltext;
				}
				//Debug Level
				if ( structKeyExists(iocNodes[1], "DebugLevel") ){
					ConfigStruct["IOCDebugLevel"] = iocNodes[1].DebugLevel.xmltext;
				}	
				// Parent Factory
				if ( structKeyExists(iocNodes[1], "ParentFactory") ){
					ConfigStruct["IOCParentFactoryDefinitionFile"] = iocNodes[1].ParentFactory.xmltext;
					if( structKeyExists(iocNodes[1].Framework.xmlAttributes,"type") ){
						ConfigStruct["IOCParentFactory"] = iocNodes[1].Framework.xmlAttributes.type;
					}
				}	
			} 
		</cfscript>
	</cffunction>
	
	<!--- parseModels --->
	<cffunction name="parseModels" output="false" access="public" returntype="void" hint="Parse Models">
		<cfargument name="xml" 		type="any" required="true" hint="The xml object"/>
		<cfargument name="config" 	type="struct" required="true" hint="The config struct"/>
		<cfargument name="utility"  type="any" required="true" hint="The utility object"/>
		<cfargument name="isOverride" type="boolean" required="false" default="false" hint="Flag to denote if overriding or first time runner."/>
		<cfscript>
			var ConfigStruct = arguments.config;
			var ModelNodes = XMLSearch(arguments.xml,"//Models");
			var fwSettingsStruct = controller.getColdBoxSettings();
			
			// Defaults
			if (NOT arguments.isOverride){
				ConfigStruct.ModelsExternalLocation = "";
				ConfigStruct.ModelsObjectCaching = fwSettingsStruct["ModelsObjectCaching"];
				ConfigStruct.ModelsDebugMode = fwSettingsStruct["ModelsDebugMode"];
				ConfigStruct.ModelsSetterInjection = fwSettingsStruct["ModelsSetterInjection"];
				ConfigStruct.ModelsDICompleteUDF = fwSettingsStruct["ModelsDICompleteUDF"];
				ConfigStruct.ModelsStopRecursion = fwSettingsStruct["ModelsStopRecursion"];
				ConfigStruct.ModelsDefinitionFile = fwSettingsStruct["ModelsDefinitionFile"];
				ConfigStruct.ModelsDebugLevel = fwSettingsStruct["ModelsDebugLevel"];
			}
			
			//Check if empty
			if ( ArrayLen(ModelNodes) gt 0 and ArrayLen(ModelNodes[1].XMLChildren) gt 0){
				//Check for Models External Location
				if ( structKeyExists(ModelNodes[1], "ExternalLocation") AND len(ModelNodes[1].ExternalLocation.xmltext)){
					ConfigStruct["ModelsExternalLocation"] = ModelNodes[1].ExternalLocation.xmltext;
				}		
							
				//Check for Models ObjectCaching
				if ( structKeyExists(ModelNodes[1], "ObjectCaching") AND isBoolean(ModelNodes[1].ObjectCaching.xmltext) ){
					ConfigStruct["ModelsObjectCaching"] = ModelNodes[1].ObjectCaching.xmltext;
				}
				
				//Check for ModelsDebugMode
				if ( structKeyExists(ModelNodes[1], "DebugMode") AND isBoolean(ModelNodes[1].DebugMode.xmltext) ){
					ConfigStruct["ModelsDebugMode"] = ModelNodes[1].DebugMode.xmltext;
				}
				
				//Check for ModelsSetterInjection
				if ( structKeyExists(ModelNodes[1], "SetterInjection") AND isBoolean(ModelNodes[1].SetterInjection.xmltext) ){
					ConfigStruct["ModelsSetterInjection"] = ModelNodes[1].SetterInjection.xmltext;
				}
				
				//Check for ModelsDICompleteUDF
				if ( structKeyExists(ModelNodes[1], "DICompleteUDF") AND len(ModelNodes[1].DICompleteUDF.xmltext) ){
					ConfigStruct["ModelsDICompleteUDF"] =ModelNodes[1].DICompleteUDF.xmltext;
				}
				
				//Check for ModelsStopRecursion
				if ( structKeyExists(ModelNodes[1], "StopRecursion") AND len(ModelNodes[1].StopRecursion.xmltext) ){
					ConfigStruct["ModelsStopRecursion"] = ModelNodes[1].StopRecursion.xmltext;
				}
				
				//Check for ModelsDefinitionFile
				if ( structKeyExists(ModelNodes[1], "DefinitionFile") AND len(ModelNodes[1].DefinitionFile.xmltext) ){
					ConfigStruct["ModelsDefinitionFile"] = ModelNodes[1].DefinitionFile.xmltext;
				}
				
				//Check for ModelsDebugLevel
				if ( structKeyExists(ModelNodes[1], "DebugLevel") AND len(ModelNodes[1].DebugLevel.xmltext) ){
					ConfigStruct["ModelsDebugLevel"] = ModelNodes[1].DebugLevel.xmltext;
				}
			} 
		</cfscript>
	</cffunction>

	<!--- parseLocalization --->
	<cffunction name="parseLocalization" output="false" access="public" returntype="void" hint="Parse localization">
		<cfargument name="xml" 		type="any" required="true" hint="The xml object"/>
		<cfargument name="config" 	type="struct" required="true" hint="The config struct"/>
		<cfargument name="utility"  type="any" required="true" hint="The utility object"/>
		<cfargument name="isOverride" type="boolean" required="false" default="false" hint="Flag to denote if overriding or first time runner."/>
		<cfscript>
			var ConfigStruct = arguments.config;
			//i18N Settings
			var i18NSettingNodes = XMLSearch(arguments.xml,"//i18N");
			var i=1;
			var DefaultLocale = "";
			
			if (NOT arguments.isOverride){
				ConfigStruct.DefaultResourceBundle = "";
				ConfigStruct.DefaultLocale = "";
				ConfigStruct.LocaleStorage = "";
				ConfigStruct.UknownTranslation = "";
				ConfigStruct["using_i18N"] = false;
			}
			
			//Check if empty
			if ( ArrayLen(i18NSettingNodes) gt 0 and ArrayLen(i18NSettingNodes[1].XMLChildren) gt 0){
				
				//Check for DefaultResourceBundle
				if ( structKeyExists(i18NSettingNodes[1], "DefaultResourceBundle") AND len(i18NSettingNodes[1].DefaultResourceBundle.xmltext) ){
					ConfigStruct["DefaultResourceBundle"] = i18NSettingNodes[1].DefaultResourceBundle.xmltext;
				}
				
				//Check for DefaultResourceBundle
				if ( structKeyExists(i18NSettingNodes[1], "DefaultLocale") AND len(i18NSettingNodes[1].DefaultLocale.xmltext) ){
					defaultLocale = i18NSettingNodes[1].DefaultLocale.xmltext;
					ConfigStruct["DefaultLocale"] = lcase(listFirst(DefaultLocale,"_")) & "_" & ucase(listLast(DefaultLocale,"_"));
				}
				
				//Check for LocaleStorage
				if ( structKeyExists(i18NSettingNodes[1], "LocaleStorage") AND len(i18NSettingNodes[1].LocaleStorage.xmltext) ){
					ConfigStruct["LocaleStorage"] = i18NSettingNodes[1].LocaleStorage.xmltext;
					if( NOT reFindNoCase("^(session|cookie|client)$",configStruct["LocaleStorage"]) ){
						$throw(message="Invalid local storage scope: #configStruct["localeStorage"]#",
							   detail="Valid scopes are session,client, cookie",
							   type="XMLParser.InvalidLocaleStorage");
					}
				}
				
				//Check for DefaultResourceBundle
				if ( structKeyExists(i18NSettingNodes[1], "UknownTranslation") AND len(i18NSettingNodes[1].UknownTranslation.xmltext) ){
					ConfigStruct["UknownTranslation"] = i18NSettingNodes[1].UknownTranslation.xmltext;
				}
				
				//set i18n
				ConfigStruct["using_i18N"] = true;
			}
		</cfscript>
	</cffunction>

	<!--- parseBugTracers --->
	<cffunction name="parseBugTracers" output="false" access="public" returntype="void" hint="Parse bug emails">
		<cfargument name="xml" 		type="any" required="true" hint="The xml object"/>
		<cfargument name="config" 	type="struct" required="true" hint="The config struct"/>
		<cfargument name="utility"  type="any" required="true" hint="The utility object"/>
		<cfargument name="isOverride" type="boolean" required="false" default="false" hint="Flag to denote if overriding or first time runner."/>
		<cfscript>
			var ConfigStruct = arguments.config;
			var BugEmailNodes = XMLSearch(arguments.xml,"//BugTracerReports/BugEmail");
			var i=1;
			var BugEmails = "";
			
			if( arrayLen(BugEmailNodes) ){
				for (i=1; i lte ArrayLen(BugEmailNodes); i=i+1){
					BugEmails = BugEmails & trim(BugEmailNodes[i].XMLText);
					if ( i neq ArrayLen(BugEmailNodes) )
						BugEmails = BugEmails & ",";
				}
				//Insert Into Config
				ConfigStruct.BugEmails = BugEmails;
			}
			else if( NOT arguments.isOverride ){
				ConfigStruct.BugEmails = "";
			}
		</cfscript>
	</cffunction>

	<!--- parseWebservices --->
	<cffunction name="parseWebservices" output="false" access="public" returntype="void" hint="Parse webservices">
		<cfargument name="xml" 		type="any" required="true" hint="The xml object"/>
		<cfargument name="config" 	type="struct" required="true" hint="The config struct"/>
		<cfargument name="utility"  type="any" required="true" hint="The utility object"/>
		<cfargument name="isOverride" type="boolean" required="false" default="false" hint="Flag to denote if overriding or first time runner."/>
		<cfscript>
			var ConfigStruct = arguments.config;
			var WebServiceNodes = "";
			var i=1;
			
			//Get Web Services From Config.
			WebServiceNodes = XMLSearch(arguments.xml,"//WebServices/WebService");
			if ( ArrayLen(WebServiceNodes) ){
				// Init webservices holder structure
				configStruct.webservices = structnew();
				for (i=1; i lte ArrayLen(WebServiceNodes); i=i+1){
					configStruct.webservices[WebServiceNodes[i].XMLAttributes["name"]] = trim(WebServiceNodes[i].XMLAttributes["URL"]);
				}				
			}
			else if( NOT arguments.isOverride ){
				configStruct.webservices = structnew();
			}
		</cfscript>
	</cffunction>

	<!--- parseDatasources --->
	<cffunction name="parseDatasources" output="false" access="public" returntype="void" hint="Parse Datsources">
		<cfargument name="xml" 		type="any" required="true" hint="The xml object"/>
		<cfargument name="config" 	type="struct" required="true" hint="The config struct"/>
		<cfargument name="utility"  type="any" required="true" hint="The utility object"/>
		<cfargument name="isOverride" type="boolean" required="false" default="false" hint="Flag to denote if overriding or first time runner."/>
		<cfscript>
			var ConfigStruct = arguments.config;
			var DatasourcesNodes = "";
			var i=1;
			var DSNStruct = "";
			
			//Datasources Support
			DatasourcesNodes = XMLSearch(arguments.xml,"//Datasources/Datasource");
			if ( ArrayLen(DatasourcesNodes) ){
				//Create Structures
				ConfigStruct.Datasources = structnew();
				for(i=1;i lte ArrayLen(DatasourcesNodes); i=i+1){
					DSNStruct = structNew();

					if ( not structKeyExists(DatasourcesNodes[i].XMLAttributes, "Alias") or len(Trim(DatasourcesNodes[i].XMLAttributes["Alias"])) eq 0 )
						$throw("This datasource entry's alias cannot be blank","","XMLParser.ConfigXMLParsingException");
					else
						DSNStruct.Alias = Trim(DatasourcesNodes[i].XMLAttributes["Alias"]);
					
					if ( not structKeyExists(DatasourcesNodes[i].XMLAttributes, "Name") or len(Trim(DatasourcesNodes[i].XMLAttributes["Name"])) eq 0 )
						$throw("This datasource entry's name cannot be blank","","XMLParser.ConfigXMLParsingException");
					else
						DSNStruct.Name = Trim(DatasourcesNodes[i].XMLAttributes["Name"]);

					//Optional Entries.
					if ( structKeyExists(DatasourcesNodes[i].XMLAttributes, "dbtype") )
						DSNStruct.DBType = Trim(DatasourcesNodes[i].XMLAttributes["dbtype"]);
					else
						DSNStruct.DBType = "";
						
					if ( structKeyExists(DatasourcesNodes[i].XMLAttributes, "Username") )
						DSNStruct.Username = Trim(DatasourcesNodes[i].XMLAttributes["username"]);
					else
						DSNStruct.Username = "";
						
					if ( structKeyExists(DatasourcesNodes[i].XMLAttributes, "password") )
						DSNStruct.Password = Trim(DatasourcesNodes[i].XMLAttributes["password"]);
					else
						DSNStruct.Password  = "";

					//Insert to structure with Alias as key
					ConfigStruct.Datasources[DSNStruct.Alias] = DSNStruct;
				}
			}
			else if( NOT arguments.isOverride ){
				ConfigStruct.Datasources = structnew();
			}				
		</cfscript>
	</cffunction>

	<!--- parseLayoutsViews --->
	<cffunction name="parseLayoutsViews" output="false" access="public" returntype="void" hint="Parse Layouts And Views">
		<cfargument name="xml" 		type="any" required="true" hint="The xml object"/>
		<cfargument name="config" 	type="struct" required="true" hint="The config struct"/>
		<cfargument name="utility"  type="any" required="true" hint="The utility object"/>
		<cfscript>
			var ConfigStruct = arguments.config;
			var DefaultLayout = "";
			var DefaultView = "";
			var LayoutNodes = "";
			var Layout = "";
			var i=1;
			var j=1;
			var Collections = createObject("java", "java.util.Collections"); 
			var	LayoutViewStruct = Collections.synchronizedMap(CreateObject("java","java.util.LinkedHashMap").init());
			var	LayoutFolderStruct = Collections.synchronizedMap(CreateObject("java","java.util.LinkedHashMap").init());
		
			//Layout into Config
			DefaultLayout = XMLSearch(arguments.xml,"//Layouts/DefaultLayout");
			//validate Default Layout.
			if ( ArrayLen(DefaultLayout) eq 0 )
				$throw("There was no default layout element found.","","XMLParser.ConfigXMLParsingException");
			if ( ArrayLen(DefaultLayout) gt 1 )
				$throw("There were more than 1 DefaultLayout elements found. There can only be one.","","XMLParser.ConfigXMLParsingException");
			//Insert Default Layout
			ConfigStruct.DefaultLayout = Trim(DefaultLayout[1].XMLText);
			
			//Default View into Config
			DefaultView = XMLSearch(arguments.xml,"//Layouts/DefaultView");
			//validate Default Layout.
			if ( ArrayLen(DefaultView) eq 0 ){
				ConfigStruct["DefaultView"] = "";
			}
			else if ( ArrayLen(DefaultView) gt 1 ){
				$throw("There were more than 1 DefaultView elements found. There can only be one.","","XMLParser.ConfigXMLParsingException");
			}
			else{
				//Set the Default View.
				ConfigStruct["DefaultView"] = Trim(DefaultView[1].XMLText);
			}
			
			//Get View Layouts
			LayoutNodes = XMLSearch(arguments.xml,"//Layouts/Layout");
			for (i=1; i lte ArrayLen(LayoutNodes); i=i+1){
				//Get Layout for the views
				Layout = Trim(LayoutNodes[i].XMLAttributes["file"]);
				for(j=1; j lte ArrayLen(LayoutNodes[i].XMLChildren); j=j+1){
					//Check for View
					if( LayoutNodes[i].XMLChildren[j].XMLName eq "View" ){
						//Check for Key, if it doesn't exist then create
						if ( not StructKeyExists(LayoutViewStruct, lcase(Trim(LayoutNodes[i].XMLChildren[j].XMLText))) )
							LayoutViewStruct[lcase(Trim(LayoutNodes[i].XMLChildren[j].XMLText))] = Layout;
					}
					//Check for Folder
					else if( LayoutNodes[i].XMLChildren[j].XMLName eq "Folder" ){
						//Check for Key, if it doesn't exist then create
						if ( not StructKeyExists(LayoutFolderStruct, lcase(Trim(LayoutNodes[i].XMLChildren[j].XMLText))) )
							LayoutFolderStruct[lcase(Trim(LayoutNodes[i].XMLChildren[j].XMLText))] = Layout;
					}
					
				}//end for loop for the layout children
			}//end for loop of all layout nodes
			
			ConfigStruct.ViewLayouts = LayoutViewStruct;
			ConfigStruct.FolderLayouts = LayoutFolderStruct;
		</cfscript>
	</cffunction>

	<!--- parseCacheSettings --->
	<cffunction name="parseCacheSettings" output="false" access="public" returntype="void" hint="Parse Cache Settings">
		<cfargument name="xml" 		type="any" required="true" hint="The xml object"/>
		<cfargument name="config" 	type="struct" required="true" hint="The config struct"/>
		<cfargument name="utility"  type="any" required="true" hint="The utility object"/>
		<cfscript>
			var ConfigStruct = arguments.config;
			var CacheSettingNodes  = "";
			var fwSettingsStruct = controller.getColdboxSettings();
			
			//Cache Override Settings
			CacheSettingNodes = XMLSearch(arguments.xml,"//Cache");
			ConfigStruct.CacheSettings = structnew();
			
			//Check if empty
			if ( ArrayLen(CacheSettingNodes) gt 0 and ArrayLen(CacheSettingNodes[1].XMLChildren) gt 0){
				//Checks For Default Timeout
				if ( structKeyExists(CacheSettingNodes[1], "ObjectDefaultTimeout") and isNumeric(CacheSettingNodes[1].ObjectDefaultTimeout.xmlText) ){
					ConfigStruct.CacheSettings.ObjectDefaultTimeout = trim(CacheSettingNodes[1].ObjectDefaultTimeout.xmlText);
				}
				else{
					ConfigStruct.CacheSettings.ObjectDefaultTimeout = fwSettingsStruct.CacheObjectDefaultTimeout;
				}
							

				//Check ObjectDefaultLastAccessTimeout
				if ( structKeyExists(CacheSettingNodes[1], "ObjectDefaultLastAccessTimeout") and isNumeric(CacheSettingNodes[1].ObjectDefaultLastAccessTimeout.xmlText)){
					ConfigStruct.CacheSettings.ObjectDefaultLastAccessTimeout = trim(CacheSettingNodes[1].ObjectDefaultLastAccessTimeout.xmlText);
				}
				else{
					ConfigStruct.CacheSettings.ObjectDefaultLastAccessTimeout = fwSettingsStruct.CacheObjectDefaultLastAccessTimeout;
				}
				
				//Check ReapFrequency
				if ( structKeyExists(CacheSettingNodes[1], "ReapFrequency") and isNumeric(CacheSettingNodes[1].ReapFrequency.xmlText)){
					ConfigStruct.CacheSettings.ReapFrequency = trim(CacheSettingNodes[1].ReapFrequency.xmlText);
				}
				else{
					ConfigStruct.CacheSettings.ReapFrequency = fwSettingsStruct.CacheReapFrequency;
				}
				
				//Check MaxObjects
				if ( structKeyExists(CacheSettingNodes[1], "MaxObjects") and isNumeric(CacheSettingNodes[1].MaxObjects.xmlText)){
					ConfigStruct.CacheSettings.MaxObjects = trim(CacheSettingNodes[1].MaxObjects.xmlText);
				}
				else{
					ConfigStruct.CacheSettings.MaxObjects = fwSettingsStruct.CacheMaxObjects;
				}
				
				//Check FreeMemoryPercentageThreshold
				if ( structKeyExists(CacheSettingNodes[1], "FreeMemoryPercentageThreshold") and isNumeric(CacheSettingNodes[1].FreeMemoryPercentageThreshold.xmlText)){
					ConfigStruct.CacheSettings.FreeMemoryPercentageThreshold = trim(CacheSettingNodes[1].FreeMemoryPercentageThreshold.xmlText);
				}
				else{
					ConfigStruct.CacheSettings.FreeMemoryPercentageThreshold = fwSettingsStruct.CacheFreeMemoryPercentageThreshold;
				}
				
				//Check for CacheUseLastAccessTimeouts
				if ( structKeyExists(CacheSettingNodes[1], "UseLastAccessTimeouts") and isBoolean(CacheSettingNodes[1].UseLastAccessTimeouts.xmlText) ){
					ConfigStruct.CacheSettings.UseLastAccessTimeouts = trim(CacheSettingNodes[1].UseLastAccessTimeouts.xmlText);
				}
				else{
					ConfigStruct.CacheSettings.UseLastAccessTimeouts = fwSettingsStruct.CacheUseLastAccessTimeouts;
				}	
				
				//Check for CacheEvictionPolicy
				if ( structKeyExists(CacheSettingNodes[1], "EvictionPolicy") ){
					ConfigStruct.CacheSettings.EvictionPolicy = trim(CacheSettingNodes[1].EvictionPolicy.xmlText);
				}
				else{
					ConfigStruct.CacheSettings.EvictionPolicy = fwSettingsStruct.CacheEvictionPolicy;
				}			
				//Set Override to true.
				ConfigStruct.CacheSettings.Override = true;
			}
			else{
				ConfigStruct.CacheSettings.Override = false;
			}
		</cfscript>
	</cffunction>	

	<!--- parseDebuggerSettings --->
	<cffunction name="parseDebuggerSettings" output="false" access="public" returntype="void" hint="Parse Debugger Settings">
		<cfargument name="xml" 		type="any" required="true" hint="The xml object"/>
		<cfargument name="config" 	type="struct" required="true" hint="The config struct"/>
		<cfargument name="utility"  type="any" required="true" hint="The utility object"/>
		<cfargument name="isOverride" type="boolean" required="false" default="false" hint="Flag to denote if overriding or first time runner."/>
		<cfscript>
			var ConfigStruct = arguments.config;
			var DebuggerSettingNodes = "";
			
			DebuggerSettingNodes = XMLSearch(arguments.xml,"//DebuggerSettings");
			
			//Check if empty
			if ( ArrayLen(DebuggerSettingNodes) ){
				// PersistentRequestProfiler
				if ( structKeyExists(DebuggerSettingNodes[1], "PersistentRequestProfiler") and isBoolean(DebuggerSettingNodes[1].PersistentRequestProfiler.xmlText) ){
					ConfigStruct.DebuggerSettings.PersistentRequestProfiler = trim(DebuggerSettingNodes[1].PersistentRequestProfiler.xmlText);
				}
				// maxPersistentRequestProfilers
				if ( structKeyExists(DebuggerSettingNodes[1], "maxPersistentRequestProfilers") and isNumeric(DebuggerSettingNodes[1].maxPersistentRequestProfilers.xmlText) ){
					ConfigStruct.DebuggerSettings.maxPersistentRequestProfilers = trim(DebuggerSettingNodes[1].maxPersistentRequestProfilers.xmlText);
				}
				// maxRCPanelQueryRows */
				if ( structKeyExists(DebuggerSettingNodes[1], "maxRCPanelQueryRows") and isNumeric(DebuggerSettingNodes[1].maxRCPanelQueryRows.xmlText) ){
					ConfigStruct.DebuggerSettings.maxRCPanelQueryRows = trim(DebuggerSettingNodes[1].maxRCPanelQueryRows.xmlText);
				}
				// TracerPanel
				if ( structKeyExists(DebuggerSettingNodes[1], "TracerPanel") ){
					debugPanelAttributeInsert(ConfigStruct.DebuggerSettings,"TracerPanel",DebuggerSettingNodes[1].TracerPanel.xmlAttributes);
				}
				// InfoPanel
				if ( structKeyExists(DebuggerSettingNodes[1], "InfoPanel") ){
					debugPanelAttributeInsert(ConfigStruct.DebuggerSettings,"InfoPanel",DebuggerSettingNodes[1].InfoPanel.xmlAttributes);
				}
				// CachePanel
				if ( structKeyExists(DebuggerSettingNodes[1], "CachePanel") ){
					debugPanelAttributeInsert(ConfigStruct.DebuggerSettings,"CachePanel",DebuggerSettingNodes[1].CachePanel.xmlAttributes);
				}
				// RCPanel
				if ( structKeyExists(DebuggerSettingNodes[1], "RCPanel") ){
					debugPanelAttributeInsert(ConfigStruct.DebuggerSettings,"RCPanel",DebuggerSettingNodes[1].RCPanel.xmlAttributes);
				}					
				//Set Override to true.
				ConfigStruct.DebuggerSettings.Override = true;			
			}
			else if (NOT arguments.isOverride){
				ConfigStruct.DebuggerSettings = structnew();
				ConfigStruct.DebuggerSettings.Override = false;			
			}
		</cfscript>
	</cffunction>		
	
	<!--- parseInterceptors --->
	<cffunction name="parseInterceptors" output="false" access="public" returntype="void" hint="Parse Interceptors">
		<cfargument name="xml" 		type="any" required="true" hint="The xml object"/>
		<cfargument name="config" 	type="struct" required="true" hint="The config struct"/>
		<cfargument name="utility"  type="any" required="true" hint="The utility object"/>
		<cfargument name="isOverride" type="boolean" required="false" default="false" hint="Flag to denote if overriding or first time runner."/>
		<cfscript>
			var ConfigStruct = arguments.config;
			var InterceptorBase = "";
			var CustomInterceptionPoints = "";
			var InterceptorNodes = "";
			var i=1;
			var j=1;
			var InterceptorStruct = "";
			var tempProperty = "";
			
			//Search for Interceptors
			InterceptorBase = XMLSearch(arguments.xml,"//Interceptors");
			if( arrayLen(InterceptorBase) ){
				// Interceptor Preparation.
				ConfigStruct.InterceptorConfig = structnew();
				ConfigStruct.InterceptorConfig.Interceptors = arrayNew(1);
				ConfigStruct.InterceptorConfig.throwOnInvalidStates = true;
				ConfigStruct.InterceptorConfig.CustomInterceptionPoints = "";
				
				// Invalid States
				if ( structKeyExists(InterceptorBase[1].XMLAttributes, "throwOnInvalidStates") ){
					ConfigStruct.InterceptorConfig['throwOnInvalidStates'] = InterceptorBase[1].XMLAttributes.throwOnInvalidStates;
				}
				
				// Custom Interception Points
				CustomInterceptionPoints = XMLSearch(arguments.xml,"//Interceptors/CustomInterceptionPoints");
				if ( ArrayLen(CustomInterceptionPoints) gt 1 ){
					$throw("There were more than 1 CustomInterceptionPoints elements found. There can only be one.","","XMLParser.ConfigXMLParsingException");
				}
				else if( arraylen(CustomInterceptionPoints) ){
					ConfigStruct.InterceptorConfig.CustomInterceptionPoints = arguments.utility.placeHolderReplacer(Trim(CustomInterceptionPoints[1].XMLText),ConfigStruct);
				}
				
				//Parse all Interceptor Nodes now.
				InterceptorNodes = XMLSearch(arguments.xml,"//Interceptors/Interceptor");
				for (i=1; i lte ArrayLen(InterceptorNodes); i=i+1){
					//Interceptor Struct
					InterceptorStruct = structnew();
					//get Class
					InterceptorStruct.class = arguments.utility.placeHolderReplacer(Trim(InterceptorNodes[i].XMLAttributes["class"]),ConfigStruct);
					//Prepare Properties
					InterceptorStruct.properties = structnew();
					//Parse Interceptor Properties
					if ( ArrayLen(InterceptorNodes[i].XMLChildren) ){
						for(j=1; j lte ArrayLen(InterceptorNodes[i].XMLChildren); j=j+1){
							//Property Complex Check
							tempProperty = arguments.utility.placeHolderReplacer(Trim( InterceptorNodes[i].XMLChildren[j].XMLText ),ConfigStruct);
							//Check for Complex Setup
							if( reFindNocase(instance.jsonRegex,tempProperty) ){
								StructInsert( InterceptorStruct.properties, Trim(InterceptorNodes[i].XMLChildren[j].XMLAttributes["name"]), getPlugin('JSON').decode(replace(tempProperty,"'","""","all")) );
							}
							else{
								StructInsert( InterceptorStruct.properties, Trim(InterceptorNodes[i].XMLChildren[j].XMLAttributes["name"]), tempProperty );
							}
						}//end loop of properties
					}//end if no properties					
					//Add to Array
					ArrayAppend( ConfigStruct.InterceptorConfig.Interceptors, InterceptorStruct );
				}//end interceptor nodes
				
			}// end if interceptors found
			else if (NOT arguments.isOverride){
				// Interceptor Defaults.
				ConfigStruct.InterceptorConfig = structnew();
				ConfigStruct.InterceptorConfig.Interceptors = arrayNew(1);
				ConfigStruct.InterceptorConfig.throwOnInvalidStates = true;
				ConfigStruct.InterceptorConfig.CustomInterceptionPoints = "";				
			}
		</cfscript>
	</cffunction>
	
	<!--- parseLogBox --->
	<cffunction name="parseLogBox" output="false" access="public" returntype="void" hint="Parse LogBox">
		<cfargument name="xml" 		type="any" required="true" hint="The xml object"/>
		<cfargument name="config" 	type="struct" required="true" hint="The config struct"/>
		<cfargument name="utility"  type="any" required="true" hint="The utility object"/>
		<cfargument name="isOverride" type="boolean" required="false" default="false" hint="Flag to denote if overriding or first time runner."/>
		<cfscript>
			var logboxXML = xmlSearch(arguments.xml,"//LogBox");
			var logBoxConfig = "";
			var memento = "";
			var prop = "";
			
			if( arrayLen(logboxXML) ){
				// Get config object From controller's logbox
				logBoxConfig = controller.getLogBox().getConfig();
				// Reset the configuration
				logBoxConfig.reset();
				// Parse and load new configuration data
				logBoxConfig.parseAndLoad(logboxXML[1]);
				// Get reference to do ${} replacements
				memento = logBoxConfig.getMemento();
				
				// Appender Replacements
				for( key in memento.appenders ){
					memento.appenders[key].class = arguments.utility.placeHolderReplacer(memento.appenders[key].class,arguments.config);
					//Appender properties
					for(prop in memento.appenders[key].properties){
						// ${} replacement
						memento.appenders[key].properties[prop] = arguments.utility.placeHolderReplacer(memento.appenders[key].properties[prop],arguments.config);
					}
				}
				
				//Store LogBox Configuration on settings
				arguments.config["LogBoxConfig"] = memento;
			}
			else if( NOT arguments.isOverride){
				arguments.config["LogBoxConfig"] = structnew();
			}
		</cfscript>
	</cffunction>		
					
<!------------------------------------------- PRIVATE ------------------------------------------>

	<!--- Debug Panel attribute insert --->
	<cffunction name="debugPanelAttributeInsert" access="private" returntype="void" hint="Insert a key into a panel attribute" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="Config"			required="true" type="struct" hint="">
		<cfargument name="Panel" 			required="true" type="string" hint="">
		<cfargument name="PanelXML" 		required="true" type="any" hint="">
		<!--- ************************************************************* --->
		<cfscript>
			// Show Key
			if( structKeyExists(arguments.panelXML,"show") ){
				arguments.config["show#arguments.Panel#"] = trim(arguments.panelXML.show);
			}	
			// Expanded Key
			if( structKeyExists(arguments.panelXML,"expanded") ){
				arguments.config["expanded#arguments.Panel#"] = trim(arguments.panelXML.expanded);
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