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
<cfcomponent hint="This is the XML Parser plugin for the framework. It takes care of any XML parsing for the framework's usage."
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
		var configStruct = StructNew();
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
			
			// Setup Default Application Path from main controller
			configStruct.ApplicationPath = controller.getAppRootPath();
			// Check for Override of AppMapping
			if( len(trim(arguments.overrideAppMapping)) ){
				configStruct.ApplicationPath = ExpandPath(arguments.overrideAppMapping);
				if( right(configStruct.ApplicationPath,1) neq "/"){
					configStruct.ApplicationPath = configStruct.ApplicationPath & "/";
				}
			}
			
			//Calculate AppMapping if not set in the config
			if ( NOT structKeyExists(configStruct, "AppMapping") ){
				calculateAppMapping(configStruct);
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
			configStruct.Environment = "PRODUCTION";
			
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
			configStruct.ConfigTimeStamp = oUtilities.FileLastModified(ConfigFileLocation);
			
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
		return configStruct;
		</cfscript>
	</cffunction>
	
	<!--- calculateAppMapping --->
    <cffunction name="calculateAppMapping" output="false" access="public" returntype="void" hint="Calculate the AppMapping">
    	<cfargument name="config" 	type="struct" required="true" hint="The config struct"/>
		<cfscript>
			var configStruct = arguments.config;
			// Get the web path from CGI.
			var	 webPath = replacenocase(cgi.script_name,getFileFromPath(cgi.script_name),"");
			// Cleanup the template path
			var localPath = getDirectoryFromPath(replacenocase(getTemplatePath(),"\","/","all"));
			// Verify Path Location
			var pathLocation = findnocase(webPath, localPath);
			
			if ( pathLocation )
				configStruct.AppMapping = mid(localPath,pathLocation,len(webPath));
			else
				configStruct.AppMapping = webPath;

			//Clean last /
			if ( right(configStruct.AppMapping,1) eq "/" ){
				if ( len(configStruct.AppMapping) -1 gt 0)
					configStruct.AppMapping = left(configStruct.AppMapping,len(configStruct.AppMapping)-1);
				else
					configStruct.AppMapping = "";
			}
			
			//Clean j2ee context
			if( len(getContextRoot()) ){
				configStruct.AppMapping = replacenocase(configStruct.AppMapping,getContextRoot(),"");
			}
    	</cfscript>
    </cffunction>
	
	<!--- parseColdboxSettings --->
	<cffunction name="parseColdboxSettings" output="false" access="public" returntype="void" hint="Parse ColdBox Settings">
		<cfargument name="xml" 		type="any" required="true" hint="The xml object"/>
		<cfargument name="config" 	type="struct" required="true" hint="The config struct"/>
		<cfargument name="utility"  type="any" required="true" hint="The utility object"/>
		<cfargument name="overrideAppMapping" type="string" required="false" default="" hint="Only used for unit testing or reparsing of a specific coldbox config file."/>
		<cfscript>
			var configStruct = arguments.config;
			var fwSettingsStruct = controller.getColdBoxSettings();
			var SettingNodes = XMLSearch(arguments.xml,"//Settings/Setting");
			var i=1;
			
			if ( ArrayLen(SettingNodes) eq 0 ){
				$throw("No Setting elements could be found in the configuration file.","","XMLParser.ConfigXMLParsingException");
			}
			
			//Insert  ColdBox Settings to Config Struct
			for (i=1; i lte ArrayLen(SettingNodes); i=i+1){
				configStruct[trim(SettingNodes[i].XMLAttributes["name"])] = arguments.utility.placeHolderReplacer(trim(SettingNodes[i].XMLAttributes["value"]),configStruct);
			}
			// override AppMapping from what user set if passed in via the creation. Mostly for unit testing this is done. 
			if ( len(trim(arguments.overrideAppMapping)) ){
				configStruct["AppMapping"] = arguments.overrideAppMapping;
			}
			// Clean the first / if found
			if( len(configStruct.AppMapping) eq 1 ){
				configStruct["AppMapping"] = "";
			}
			
			/* ::::::::::::::::::::::::::::::::::::::::: COLDBOX SETTINGS VALIDATION :::::::::::::::::::::::::::::::::::::::::::: */
			//Check for AppName or throw
			if ( not StructKeyExists(configStruct, "AppName") )
				$throw("There was no 'AppName' setting defined. This is required by the framework.","","XMLParser.ConfigXMLParsingException");
			//Check for Default Event
			if ( not StructKeyExists(configStruct, "DefaultEvent") )
				$throw("There was no 'DefaultEvent' setting defined. This is required by the framework.","","XMLParser.ConfigXMLParsingException");
			//Check for Event Name
			if ( not StructKeyExists(configStruct, "EventName") )
				configStruct["EventName"] = fwSettingsStruct["EventName"] ;
			//Check for Request Start Handler
			if ( not StructKeyExists(configStruct, "ApplicationStartHandler") )
				configStruct["ApplicationStartHandler"] = "";
			//Check for Request End Handler
			if ( not StructKeyExists(configStruct, "RequestStartHandler") )
				configStruct["RequestStartHandler"] = "";
			//Check for Application Start Handler
			if ( not StructKeyExists(configStruct, "RequestEndHandler") )
				configStruct["RequestEndHandler"] = "";
			//Check for Session Start Handler
			if ( not StructKeyExists(configStruct, "SessionStartHandler") )
				configStruct["SessionStartHandler"] = "";
			//Check for Session End Handler
			if ( not StructKeyExists(configStruct, "SessionEndHandler") )
				configStruct["SessionEndHandler"] = "";
			//Check for InvalidEventHandler
			if ( not StructKeyExists(configStruct, "onInvalidEvent") )
				configStruct["onInvalidEvent"] = "";
			//Check For DebugMode in settings
			if ( not structKeyExists(configStruct, "DebugMode") or not isBoolean(configStruct.DebugMode) )
				configStruct["DebugMode"] = "false";
			//Check for DebugPassword in settings, else leave blank.
			if ( not structKeyExists(configStruct, "DebugPassword") )
				configStruct["DebugPassword"] = "";
			//Check for ReinitPassword
			if ( not structKeyExists(configStruct, "ReinitPassword") )
				configStruct["ReinitPassword"] = "";
			//Check For UDFLibraryFile
			if ( not StructKeyExists(configStruct, "UDFLibraryFile") )
				configStruct["UDFLibraryFile"] = "";
			//Check For CustomErrorTemplate
			if ( not StructKeyExists(configStruct, "CustomErrorTemplate") )
				configStruct["CustomErrorTemplate"] = "";
			//Check for MessageboxStyleOverride if found, default = false
			if ( not structkeyExists(configStruct, "MessageboxStyleOverride") or not isBoolean(configStruct.MessageboxStyleOverride) )
				configStruct["MessageboxStyleOverride"] = "false";
			//Check for HandlersIndexAutoReload, default = false
			if ( not structkeyExists(configStruct, "HandlersIndexAutoReload") or not isBoolean(configStruct.HandlersIndexAutoReload) )
				configStruct["HandlersIndexAutoReload"] = false;
			//Check for ConfigAutoReload
			if ( not structKeyExists(configStruct, "ConfigAutoReload") or not isBoolean(configStruct.ConfigAutoReload) )
				configStruct["ConfigAutoReload"] = false;
			//Check for ExceptionHandler if found
			if ( not structkeyExists(configStruct, "ExceptionHandler") )
				configStruct["ExceptionHandler"] = "";
			//Check for PluginsExternalLocation if found
			if ( not structkeyExists(configStruct, "PluginsExternalLocation") )
				configStruct["PluginsExternalLocation"] = "";
			//Check for Handler Caching
			if ( not structKeyExists(configStruct, "HandlerCaching") or not isBoolean(configStruct.HandlerCaching) )
				configStruct["HandlerCaching"] = true;
			//Check for Event Caching
			if ( not structKeyExists(configStruct, "EventCaching") or not isBoolean(configStruct.EventCaching) )
				configStruct["EventCaching"] = true;
			//RequestContextDecorator
			if ( not structKeyExists(configStruct, "RequestContextDecorator") or len(configStruct["RequestContextDecorator"]) eq 0 ){
				configStruct["RequestContextDecorator"] = "";
			}
			//Check for ProxyReturnCollection
			if ( not structKeyExists(configStruct, "ProxyReturnCollection") or not isBoolean(configStruct.ProxyReturnCollection) )
				configStruct["ProxyReturnCollection"] = false;
			//Check for External Handlers Location
			if ( not structKeyExists(configStruct, "HandlersExternalLocation") or len(configStruct["HandlersExternalLocation"]) eq 0 )
				configStruct["HandlersExternalLocation"] = "";
			// Flash URL Persist Scope Override
			if( structKeyExists(configStruct,"FlashURLPersistScope") ){
				fwSettingsStruct["FlashURLPersistScope"] = configStruct["FlashURLPersistScope"];
			}
			//Check for Missing Template Handler
			if ( not StructKeyExists(configStruct, "MissingTemplateHandler") )
				configStruct["MissingTemplateHandler"] = "";
			
		</cfscript>
	</cffunction>
	
	<!--- parseInvocationPaths --->
	<cffunction name="parseInvocationPaths" output="false" access="public" returntype="void" hint="Parse Invocation paths">
		<cfargument name="xml" 		type="any" required="true" hint="The xml object"/>
		<cfargument name="config" 	type="struct" required="true" hint="The config struct"/>
		<cfargument name="utility"  type="any" required="true" hint="The utility object"/>
		<cfscript>
			var configStruct = arguments.config;
			var fwSettingsStruct = controller.getColdBoxSettings();
			var appMappingAsDots = "";
			
			// Default Locations for ROOT based apps, which is the default
			//Parse out the first / to create the invocation Path
			if ( left(configStruct["AppMapping"],1) eq "/" ){
				configStruct["AppMapping"] = removeChars(configStruct["AppMapping"],1,1);
			}
			// Handler Registration
			configStruct["HandlersInvocationPath"] = reReplace(fwSettingsStruct.handlersConvention,"(/|\\)",".","all");
			configStruct["HandlersPath"] = controller.getAppRootPath() & fwSettingsStruct.handlersConvention;
			// Custom Plugins Registration
			configStruct["MyPluginsInvocationPath"] = reReplace(fwSettingsStruct.pluginsConvention,"(/|\\)",".","all");
			configStruct["MyPluginsPath"] = controller.getAppRootPath() & fwSettingsStruct.pluginsConvention;
			// Models Registration
			configStruct["ModelsInvocationPath"] = reReplace(fwSettingsStruct.ModelsConvention,"(/|\\)",".","all");
			configStruct["ModelsPath"] = controller.getAppRootPath() & fwSettingsStruct.ModelsConvention;
			
			//Set the Handlers,Models, & Custom Plugin Invocation & Physical Path for this Application
			if( len(configStruct["AppMapping"]) ){
				appMappingAsDots = reReplace(configStruct["AppMapping"],"(/|\\)",".","all");
				// Handler Path Registrations
				configStruct["HandlersInvocationPath"] = appMappingAsDots & ".#reReplace(fwSettingsStruct.handlersConvention,"(/|\\)",".","all")#";
				configStruct["HandlersPath"] = "/" & configStruct.AppMapping & "/#fwSettingsStruct.handlersConvention#";
				configStruct["HandlersPath"] = expandPath(configStruct["HandlersPath"]);
				// Custom Plugins Registrations
				configStruct["MyPluginsInvocationPath"] = appMappingAsDots & ".#reReplace(fwSettingsStruct.pluginsConvention,"(/|\\)",".","all")#";
				configStruct["MyPluginsPath"] = "/" & configStruct.AppMapping & "/#fwSettingsStruct.pluginsConvention#";
				configStruct["MyPluginsPath"] = expandPath(configStruct["MyPluginsPath"]);
				// Model Registrations
				configStruct["ModelsInvocationPath"] = appMappingAsDots & ".#reReplace(fwSettingsStruct.ModelsConvention,"(/|\\)",".","all")#";
				configStruct["ModelsPath"] = "/" & configStruct.AppMapping & "/#fwSettingsStruct.ModelsConvention#";
				configStruct["ModelsPath"] = expandPath(configStruct["ModelsPath"]);
			}
			
			//Set the Handlers External Configuration Paths
			configStruct["HandlersExternalLocationPath"] = "";
			if( len(configStruct["HandlersExternalLocation"]) ){
				//Expand the external location to get a registration path
				configStruct["HandlersExternalLocationPath"] = ExpandPath("/" & replace(configStruct["HandlersExternalLocation"],".","/","all"));
			}
		</cfscript>
	</cffunction>
	
	<!--- parseExternalLocations --->
	<cffunction name="parseExternalLocations" output="false" access="public" returntype="void" hint="Parse External locations">
		<cfargument name="xml" 		type="any" required="true" hint="The xml object"/>
		<cfargument name="config" 	type="struct" required="true" hint="The config struct"/>
		<cfargument name="utility"  type="any" required="true" hint="The utility object"/>
		<cfscript>
			var configStruct = arguments.config;
			
			// ViewsExternalLocation Setup 
			if( structKeyExists(configStruct,"ViewsExternalLocation") and len(configStruct["ViewsExternalLocation"]) ){
				// Verify the locations, do relative to the app mapping first 
				if( directoryExists(controller.getAppRootPath() & configStruct["ViewsExternalLocation"]) ){
					configStruct["ViewsExternalLocation"] = "/" & configStruct["AppMapping"] & "/" & configStruct["ViewsExternalLocation"];
				}
				else if( not directoryExists(expandPath(configStruct["ViewsExternalLocation"])) ){
					$throw("ViewsExternalLocation could not be found.","The directories tested was relative and expanded using #configStruct['ViewsExternalLocation']#. Please verify your setting.","XMLParser.ConfigXMLParsingException");
				}
				// Cleanup 
				if ( right(configStruct["ViewsExternalLocation"],1) eq "/" ){
					 configStruct["ViewsExternalLocation"] = left(configStruct["ViewsExternalLocation"],len(configStruct["ViewsExternalLocation"])-1);
				}
			}
			else{
				configStruct["ViewsExternalLocation"] = "";
			}
			
			// LayoutsExternalLocation Setup
			if( structKeyExists(configStruct,"LayoutsExternalLocation") and configStruct["LayoutsExternalLocation"] neq "" ){
				// Verify the locations, do relative to the app mapping first
				if( directoryExists(controller.getAppRootPath() & configStruct["LayoutsExternalLocation"]) ){
					configStruct["LayoutsExternalLocation"] = "/" & configStruct["AppMapping"] & "/" & configStruct["LayoutsExternalLocation"];
				}
				else if( not directoryExists(expandPath(configStruct["LayoutsExternalLocation"])) ){
					$throw("LayoutsExternalLocation could not be found.","The directories tested was relative and expanded using #configStruct['LayoutsExternalLocation']#. Please verify your setting.","XMLParser.ConfigXMLParsingException");
				}
				// Cleanup
				if ( right(configStruct["LayoutsExternalLocation"],1) eq "/" ){
					 configStruct["LayoutsExternalLocation"] = left(configStruct["LayoutsExternalLocation"],len(configStruct["LayoutsExternalLocation"])-1);
				}
			}
			else{
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
			var configStruct = arguments.config;
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
			var configStruct = arguments.config;
			//Your Settings To Load
			var YourSettingNodes = XMLSearch(arguments.xml, "//YourSettings/Setting");
			var i=1;
			var tester = "";
			
			if ( ArrayLen(YourSettingNodes) ){
				//Insert Your Settings to Config Struct
				for (i=1; i lte ArrayLen(YourSettingNodes); i=i+1){
					/* Get Setting with PlaceHolding */
					tester = arguments.utility.placeHolderReplacer(trim(YourSettingNodes[i].XMLAttributes["value"]),configStruct);
					//Test for JSON
					if( reFindNocase(instance.jsonRegex,tester) ){
						configStruct[YourSettingNodes[i].XMLAttributes["name"]] = getPlugin("JSON").decode(replace(tester,"'","""","all"));
					}
					else
						configStruct[YourSettingNodes[i].XMLAttributes["name"]] = tester;
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
			var configStruct = arguments.config;
			//Mail Settings
			var MailSettingsNodes = XMLSearch(arguments.xml,"//MailServerSettings");
			
			// Overrides?
			if (NOT arguments.isOverride){
				configStruct.MailServer = "";
				configStruct.MailUsername = "";
				configStruct.MailPassword = "";
				configStruct.MailPort = 25;
			}
			
			//Check if empty
			if ( ArrayLen(MailSettingsNodes) gt 0 and ArrayLen(MailSettingsNodes[1].XMLChildren) gt 0){
				//Checks
				if ( structKeyExists(MailSettingsNodes[1], "MailServer") )
					configStruct.MailServer = trim(MailSettingsNodes[1].MailServer.xmlText);
				
				//Mail username
				if ( structKeyExists(MailSettingsNodes[1], "MailUsername") )
					configStruct.MailUsername = trim(MailSettingsNodes[1].MailUsername.xmlText);
				
				//Mail password
				if ( structKeyExists(MailSettingsNodes[1], "MailPassword") )
					configStruct.MailPassword = trim(MailSettingsNodes[1].MailPassword.xmlText);
				
				//Mail Port
				if ( structKeyExists(MailSettingsNodes[1], "MailPort") AND isNumeric(MailSettingsNodes[1].MailPort.xmlText) ){
					configStruct.MailPort = trim(MailSettingsNodes[1].MailPort.xmlText);
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
			var configStruct = arguments.config;
			var iocNodes = XMLSearch(arguments.xml,"//IOC");
			var fwSettingsStruct = controller.getColdBoxSettings();
			
			// Defaults
			if (NOT arguments.isOverride){
				configStruct.IOCFramework = "";
				configStruct.IOCFrameworkReload = false;
				configStruct.IOCDefinitionFile = "";
				configStruct.IOCObjectCaching = false;
				configStruct.IOCParentFactory = "";
				configStruct.IOCParentFactoryDefinitionFile = "";
			}
			
			//Check if empty
			if ( ArrayLen(iocNodes) gt 0 and ArrayLen(iocNodes[1].XMLChildren) gt 0){
				//Check for IOC Framework
				if ( structKeyExists(iocNodes[1], "Framework") ){
					if( structKeyExists(iocNodes[1].Framework.xmlAttributes,"type") ){
						configStruct["IOCFramework"] = iocNodes[1].Framework.xmlAttributes.type;
					}
					if( structKeyExists(iocNodes[1].Framework.xmlAttributes,"reload") ){
						configStruct["IOCFrameworkReload"] = iocNodes[1].Framework.xmlAttributes.reload;
					}
					if( structKeyExists(iocNodes[1].Framework.xmlAttributes,"objectCaching") ){
						configStruct["IOCObjectCaching"] = iocNodes[1].Framework.xmlAttributes.objectCaching;
					}
					configStruct["IOCDefinitionFile"] = iocNodes[1].Framework.xmltext;
				}
				// Parent Factory
				if ( structKeyExists(iocNodes[1], "ParentFactory") ){
					configStruct["IOCParentFactoryDefinitionFile"] = iocNodes[1].ParentFactory.xmltext;
					if( structKeyExists(iocNodes[1].Framework.xmlAttributes,"type") ){
						configStruct["IOCParentFactory"] = iocNodes[1].Framework.xmlAttributes.type;
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
			var configStruct = arguments.config;
			var ModelNodes = XMLSearch(arguments.xml,"//Models");
			var fwSettingsStruct = controller.getColdBoxSettings();
			
			// Defaults
			if (NOT arguments.isOverride){
				configStruct.ModelsExternalLocation = "";
				configStruct.ModelsObjectCaching = fwSettingsStruct["ModelsObjectCaching"];
				configStruct.ModelsDebugMode = fwSettingsStruct["ModelsDebugMode"];
				configStruct.ModelsSetterInjection = fwSettingsStruct["ModelsSetterInjection"];
				configStruct.ModelsDICompleteUDF = fwSettingsStruct["ModelsDICompleteUDF"];
				configStruct.ModelsStopRecursion = fwSettingsStruct["ModelsStopRecursion"];
				configStruct.ModelsDefinitionFile = fwSettingsStruct["ModelsDefinitionFile"];
			}
			
			//Check if empty
			if ( ArrayLen(ModelNodes) gt 0 and ArrayLen(ModelNodes[1].XMLChildren) gt 0){
				//Check for Models External Location
				if ( structKeyExists(ModelNodes[1], "ExternalLocation") AND len(ModelNodes[1].ExternalLocation.xmltext)){
					configStruct["ModelsExternalLocation"] = ModelNodes[1].ExternalLocation.xmltext;
				}		
							
				//Check for Models ObjectCaching
				if ( structKeyExists(ModelNodes[1], "ObjectCaching") AND isBoolean(ModelNodes[1].ObjectCaching.xmltext) ){
					configStruct["ModelsObjectCaching"] = ModelNodes[1].ObjectCaching.xmltext;
				}
				
				//Check for ModelsDebugMode
				if ( structKeyExists(ModelNodes[1], "DebugMode") AND isBoolean(ModelNodes[1].DebugMode.xmltext) ){
					configStruct["ModelsDebugMode"] = ModelNodes[1].DebugMode.xmltext;
				}
				
				//Check for ModelsSetterInjection
				if ( structKeyExists(ModelNodes[1], "SetterInjection") AND isBoolean(ModelNodes[1].SetterInjection.xmltext) ){
					configStruct["ModelsSetterInjection"] = ModelNodes[1].SetterInjection.xmltext;
				}
				
				//Check for ModelsDICompleteUDF
				if ( structKeyExists(ModelNodes[1], "DICompleteUDF") AND len(ModelNodes[1].DICompleteUDF.xmltext) ){
					configStruct["ModelsDICompleteUDF"] =ModelNodes[1].DICompleteUDF.xmltext;
				}
				
				//Check for ModelsStopRecursion
				if ( structKeyExists(ModelNodes[1], "StopRecursion") AND len(ModelNodes[1].StopRecursion.xmltext) ){
					configStruct["ModelsStopRecursion"] = ModelNodes[1].StopRecursion.xmltext;
				}
				
				//Check for ModelsDefinitionFile
				if ( structKeyExists(ModelNodes[1], "DefinitionFile") AND len(ModelNodes[1].DefinitionFile.xmltext) ){
					configStruct["ModelsDefinitionFile"] = ModelNodes[1].DefinitionFile.xmltext;
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
			var configStruct = arguments.config;
			//i18N Settings
			var i18NSettingNodes = XMLSearch(arguments.xml,"//i18N");
			var i=1;
			var DefaultLocale = "";
			
			if (NOT arguments.isOverride){
				configStruct.DefaultResourceBundle = "";
				configStruct.DefaultLocale = "";
				configStruct.LocaleStorage = "";
				configStruct.UknownTranslation = "";
				configStruct["using_i18N"] = false;
			}
			
			//Check if empty
			if ( ArrayLen(i18NSettingNodes) gt 0 and ArrayLen(i18NSettingNodes[1].XMLChildren) gt 0){
				
				//Check for DefaultResourceBundle
				if ( structKeyExists(i18NSettingNodes[1], "DefaultResourceBundle") AND len(i18NSettingNodes[1].DefaultResourceBundle.xmltext) ){
					configStruct["DefaultResourceBundle"] = i18NSettingNodes[1].DefaultResourceBundle.xmltext;
				}
				
				//Check for DefaultResourceBundle
				if ( structKeyExists(i18NSettingNodes[1], "DefaultLocale") AND len(i18NSettingNodes[1].DefaultLocale.xmltext) ){
					defaultLocale = i18NSettingNodes[1].DefaultLocale.xmltext;
					configStruct["DefaultLocale"] = lcase(listFirst(DefaultLocale,"_")) & "_" & ucase(listLast(DefaultLocale,"_"));
				}
				
				//Check for LocaleStorage
				if ( structKeyExists(i18NSettingNodes[1], "LocaleStorage") AND len(i18NSettingNodes[1].LocaleStorage.xmltext) ){
					configStruct["LocaleStorage"] = i18NSettingNodes[1].LocaleStorage.xmltext;
					if( NOT reFindNoCase("^(session|cookie|client)$",configStruct["LocaleStorage"]) ){
						$throw(message="Invalid local storage scope: #configStruct["localeStorage"]#",
							   detail="Valid scopes are session,client, cookie",
							   type="XMLParser.InvalidLocaleStorage");
					}
				}
				
				//Check for DefaultResourceBundle
				if ( structKeyExists(i18NSettingNodes[1], "UknownTranslation") AND len(i18NSettingNodes[1].UknownTranslation.xmltext) ){
					configStruct["UknownTranslation"] = i18NSettingNodes[1].UknownTranslation.xmltext;
				}
				
				//set i18n
				configStruct["using_i18N"] = true;
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
			var configStruct = arguments.config;
			var BugEmailNodes = XMLSearch(arguments.xml,"//BugTracerReports/BugEmail");
			var bugNodes = XMLSearch(arguments.xml,"//BugTracerReports");
			var i=1;
			var BugEmails = "";
			
			if( NOT arguments.isOverride ){
				configStruct.BugEmails = "";
				configStruct.EnableBugReports = false;
				configStruct.MailFrom = "";
				configStruct.CustomEmailBugReport = "";
			}
			
			if( arrayLen(bugNodes) gt 0 and ArrayLen(bugNodes[1].XMLChildren) gt 0) {
				// Mail From
				if( structKeyExists(bugNodes[1],"MailFrom") and len(bugNodes[1].MailFrom.xmlText) ){
					configStruct.mailFrom = bugNodes[1].mailfrom.xmltext;
				}
				// Custom Bug Reports
				if( structKeyExists(bugNodes[1],"CustomEmailBugReport") and len(bugNodes[1].CustomEmailBugReport.xmlText) ){
					configStruct.CustomEmailBugReport = bugNodes[1].CustomEmailBugReport.xmltext;
				}
				// Enabled Bug Reports
				if( structKeyExists(bugNodes[1].xmlAttributes,"enabled") ){
					configStruct["EnableBugReports"] = bugNodes[1].xmlAttributes.enabled;
				}
				// Bug Emails
				if( arrayLen(BugEmailNodes) ){
					for (i=1; i lte ArrayLen(BugEmailNodes); i=i+1){
						BugEmails = BugEmails & trim(BugEmailNodes[i].XMLText);
						if ( i neq ArrayLen(BugEmailNodes) )
							BugEmails = BugEmails & ",";
					}
					//Insert Into Config
					configStruct.BugEmails = BugEmails;
				}
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
			var configStruct = arguments.config;
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
			var configStruct = arguments.config;
			var DatasourcesNodes = "";
			var i=1;
			var DSNStruct = "";
			
			//Datasources Support
			DatasourcesNodes = XMLSearch(arguments.xml,"//Datasources/Datasource");
			if ( ArrayLen(DatasourcesNodes) ){
				//Create Structures
				configStruct.Datasources = structnew();
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
					configStruct.Datasources[DSNStruct.Alias] = DSNStruct;
				}
			}
			else if( NOT arguments.isOverride ){
				configStruct.Datasources = structnew();
			}				
		</cfscript>
	</cffunction>

	<!--- parseLayoutsViews --->
	<cffunction name="parseLayoutsViews" output="false" access="public" returntype="void" hint="Parse Layouts And Views">
		<cfargument name="xml" 		type="any" required="true" hint="The xml object"/>
		<cfargument name="config" 	type="struct" required="true" hint="The config struct"/>
		<cfargument name="utility"  type="any" required="true" hint="The utility object"/>
		<cfscript>
			var configStruct = arguments.config;
			var DefaultLayout = "";
			var DefaultView = "";
			var LayoutNodes = "";
			var Layout = "";
			var i=1;
			var j=1;
			var Collections = createObject("java", "java.util.Collections"); 
			var	LayoutViewStruct = Collections.synchronizedMap(CreateObject("java","java.util.LinkedHashMap").init());
			var	LayoutFolderStruct = Collections.synchronizedMap(CreateObject("java","java.util.LinkedHashMap").init());
			
			// Registered Layouts
			configStruct.registeredLayouts = structnew();
			
			//Layout into Config
			DefaultLayout = XMLSearch(arguments.xml,"//Layouts/DefaultLayout");
			//validate Default Layout.
			if ( ArrayLen(DefaultLayout) eq 0 )
				$throw("There was no default layout element found.","","XMLParser.ConfigXMLParsingException");
			if ( ArrayLen(DefaultLayout) gt 1 )
				$throw("There were more than 1 DefaultLayout elements found. There can only be one.","","XMLParser.ConfigXMLParsingException");
			//Insert Default Layout
			configStruct.DefaultLayout = Trim(DefaultLayout[1].XMLText);
			
			//Default View into Config
			DefaultView = XMLSearch(arguments.xml,"//Layouts/DefaultView");
			//validate Default Layout.
			if ( ArrayLen(DefaultView) eq 0 ){
				configStruct["DefaultView"] = "";
			}
			else if ( ArrayLen(DefaultView) gt 1 ){
				$throw("There were more than 1 DefaultView elements found. There can only be one.","","XMLParser.ConfigXMLParsingException");
			}
			else{
				//Set the Default View.
				configStruct["DefaultView"] = Trim(DefaultView[1].XMLText);
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
				
				// Register Layout Aliases
				configStruct.registeredLayouts[Trim(LayoutNodes[i].XMLAttributes["name"])] = Trim(LayoutNodes[i].XMLAttributes["file"]);
			}//end for loop of all layout nodes
			
			configStruct.ViewLayouts = LayoutViewStruct;
			configStruct.FolderLayouts = LayoutFolderStruct;
		</cfscript>
	</cffunction>

	<!--- parseCacheSettings --->
	<cffunction name="parseCacheSettings" output="false" access="public" returntype="void" hint="Parse Cache Settings">
		<cfargument name="xml" 		type="any" required="true" hint="The xml object"/>
		<cfargument name="config" 	type="struct" required="true" hint="The config struct"/>
		<cfargument name="utility"  type="any" required="true" hint="The utility object"/>
		<cfscript>
			var configStruct = arguments.config;
			var CacheSettingNodes  = "";
			var fwSettingsStruct = controller.getColdboxSettings();
			
			//Cache Override Settings
			CacheSettingNodes = XMLSearch(arguments.xml,"//Cache");
			configStruct.CacheSettings = structnew();
			
			//Check if empty
			if ( ArrayLen(CacheSettingNodes) gt 0 and ArrayLen(CacheSettingNodes[1].XMLChildren) gt 0){
				//Checks For Default Timeout
				if ( structKeyExists(CacheSettingNodes[1], "ObjectDefaultTimeout") and isNumeric(CacheSettingNodes[1].ObjectDefaultTimeout.xmlText) ){
					configStruct.CacheSettings.ObjectDefaultTimeout = trim(CacheSettingNodes[1].ObjectDefaultTimeout.xmlText);
				}
				else{
					configStruct.CacheSettings.ObjectDefaultTimeout = fwSettingsStruct.CacheObjectDefaultTimeout;
				}
							

				//Check ObjectDefaultLastAccessTimeout
				if ( structKeyExists(CacheSettingNodes[1], "ObjectDefaultLastAccessTimeout") and isNumeric(CacheSettingNodes[1].ObjectDefaultLastAccessTimeout.xmlText)){
					configStruct.CacheSettings.ObjectDefaultLastAccessTimeout = trim(CacheSettingNodes[1].ObjectDefaultLastAccessTimeout.xmlText);
				}
				else{
					configStruct.CacheSettings.ObjectDefaultLastAccessTimeout = fwSettingsStruct.CacheObjectDefaultLastAccessTimeout;
				}
				
				//Check ReapFrequency
				if ( structKeyExists(CacheSettingNodes[1], "ReapFrequency") and isNumeric(CacheSettingNodes[1].ReapFrequency.xmlText)){
					configStruct.CacheSettings.ReapFrequency = trim(CacheSettingNodes[1].ReapFrequency.xmlText);
				}
				else{
					configStruct.CacheSettings.ReapFrequency = fwSettingsStruct.CacheReapFrequency;
				}
				
				//Check MaxObjects
				if ( structKeyExists(CacheSettingNodes[1], "MaxObjects") and isNumeric(CacheSettingNodes[1].MaxObjects.xmlText)){
					configStruct.CacheSettings.MaxObjects = trim(CacheSettingNodes[1].MaxObjects.xmlText);
				}
				else{
					configStruct.CacheSettings.MaxObjects = fwSettingsStruct.CacheMaxObjects;
				}
				
				//Check FreeMemoryPercentageThreshold
				if ( structKeyExists(CacheSettingNodes[1], "FreeMemoryPercentageThreshold") and isNumeric(CacheSettingNodes[1].FreeMemoryPercentageThreshold.xmlText)){
					configStruct.CacheSettings.FreeMemoryPercentageThreshold = trim(CacheSettingNodes[1].FreeMemoryPercentageThreshold.xmlText);
				}
				else{
					configStruct.CacheSettings.FreeMemoryPercentageThreshold = fwSettingsStruct.CacheFreeMemoryPercentageThreshold;
				}
				
				//Check for CacheUseLastAccessTimeouts
				if ( structKeyExists(CacheSettingNodes[1], "UseLastAccessTimeouts") and isBoolean(CacheSettingNodes[1].UseLastAccessTimeouts.xmlText) ){
					configStruct.CacheSettings.UseLastAccessTimeouts = trim(CacheSettingNodes[1].UseLastAccessTimeouts.xmlText);
				}
				else{
					configStruct.CacheSettings.UseLastAccessTimeouts = fwSettingsStruct.CacheUseLastAccessTimeouts;
				}	
				
				//Check for CacheEvictionPolicy
				if ( structKeyExists(CacheSettingNodes[1], "EvictionPolicy") ){
					configStruct.CacheSettings.EvictionPolicy = trim(CacheSettingNodes[1].EvictionPolicy.xmlText);
				}
				else{
					configStruct.CacheSettings.EvictionPolicy = fwSettingsStruct.CacheEvictionPolicy;
				}			
				//Set Override to true.
				configStruct.CacheSettings.Override = true;
			}
			else{
				configStruct.CacheSettings.Override = false;
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
			var configStruct = arguments.config;
			var DebuggerSettingNodes = "";
			var fwSettings = controller.getColdBoxSettings();
			
			DebuggerSettingNodes = XMLSearch(arguments.xml,"//DebuggerSettings");
			
			if (NOT arguments.isOverride){
				configStruct.DebuggerSettings = structnew();
				configStruct.DebuggerSettings.EnableDumpVar = fwSettings.enableDumpVar;
				configStruct.DebuggerSettings.PersistentRequestProfiler = fwSettings.PersistentRequestProfiler;
				configStruct.DebuggerSettings.maxPersistentRequestProfilers = fwSettings.maxPersistentRequestProfilers;
				configStruct.DebuggerSettings.maxRCPanelQueryRows = fwSettings.maxRCPanelQueryRows;
				configStruct.DebuggerSettings.showTracerPanel = fwSettings.showTracerPanel;
				configStruct.DebuggerSettings.expandedTracerPanel = fwSettings.expandedTracerPanel;
				configStruct.DebuggerSettings.showInfoPanel = fwSettings.showInfoPanel;
				configStruct.DebuggerSettings.expandedInfoPanel = fwSettings.expandedInfoPanel;
				configStruct.DebuggerSettings.showCachePanel = fwSettings.showCachePanel;
				configStruct.DebuggerSettings.expandedCachePanel = fwSettings.expandedCachePanel;
				configStruct.DebuggerSettings.showRCPanel = fwSettings.showRCPanel;
				configStruct.DebuggerSettings.expandedRCPanel = fwSettings.expandedRCPanel;
			}
			
			//Check if empty
			if ( ArrayLen(DebuggerSettingNodes) ){
				// EnableDumpVar
				if ( structKeyExists(DebuggerSettingNodes[1], "EnableDumpVar") and isBoolean(DebuggerSettingNodes[1].EnableDumpVar.xmlText) ){
					configStruct.DebuggerSettings.EnableDumpVar = trim(DebuggerSettingNodes[1].EnableDumpVar.xmlText);
				}
				// PersistentRequestProfiler
				if ( structKeyExists(DebuggerSettingNodes[1], "PersistentRequestProfiler") and isBoolean(DebuggerSettingNodes[1].PersistentRequestProfiler.xmlText) ){
					configStruct.DebuggerSettings.PersistentRequestProfiler = trim(DebuggerSettingNodes[1].PersistentRequestProfiler.xmlText);
				}
				// maxPersistentRequestProfilers
				if ( structKeyExists(DebuggerSettingNodes[1], "maxPersistentRequestProfilers") and isNumeric(DebuggerSettingNodes[1].maxPersistentRequestProfilers.xmlText) ){
					configStruct.DebuggerSettings.maxPersistentRequestProfilers = trim(DebuggerSettingNodes[1].maxPersistentRequestProfilers.xmlText);
				}
				// maxRCPanelQueryRows */
				if ( structKeyExists(DebuggerSettingNodes[1], "maxRCPanelQueryRows") and isNumeric(DebuggerSettingNodes[1].maxRCPanelQueryRows.xmlText) ){
					configStruct.DebuggerSettings.maxRCPanelQueryRows = trim(DebuggerSettingNodes[1].maxRCPanelQueryRows.xmlText);
				}
				// TracerPanel
				if ( structKeyExists(DebuggerSettingNodes[1], "TracerPanel") ){
					debugPanelAttributeInsert(configStruct.DebuggerSettings,"TracerPanel",DebuggerSettingNodes[1].TracerPanel.xmlAttributes);
				}
				// InfoPanel
				if ( structKeyExists(DebuggerSettingNodes[1], "InfoPanel") ){
					debugPanelAttributeInsert(configStruct.DebuggerSettings,"InfoPanel",DebuggerSettingNodes[1].InfoPanel.xmlAttributes);
				}
				// CachePanel
				if ( structKeyExists(DebuggerSettingNodes[1], "CachePanel") ){
					debugPanelAttributeInsert(configStruct.DebuggerSettings,"CachePanel",DebuggerSettingNodes[1].CachePanel.xmlAttributes);
				}
				// RCPanel
				if ( structKeyExists(DebuggerSettingNodes[1], "RCPanel") ){
					debugPanelAttributeInsert(configStruct.DebuggerSettings,"RCPanel",DebuggerSettingNodes[1].RCPanel.xmlAttributes);
				}							
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
			var configStruct = arguments.config;
			var InterceptorBase = "";
			var CustomInterceptionPoints = "";
			var InterceptorNodes = "";
			var i=1;
			var j=1;
			var interceptorStruct = "";
			var tempProperty = "";
			
			//Search for Interceptors
			InterceptorBase = XMLSearch(arguments.xml,"//Interceptors");
			
			if (NOT arguments.isOverride){
				// Interceptor Defaults.
				configStruct.InterceptorConfig = structnew();
				configStruct.InterceptorConfig.Interceptors = arrayNew(1);
				configStruct.InterceptorConfig.throwOnInvalidStates = true;
				configStruct.InterceptorConfig.CustomInterceptionPoints = "";				
			}
			
			if( arrayLen(InterceptorBase) ){
				// Invalid States
				if ( structKeyExists(InterceptorBase[1].XMLAttributes, "throwOnInvalidStates") ){
					configStruct.InterceptorConfig['throwOnInvalidStates'] = InterceptorBase[1].XMLAttributes.throwOnInvalidStates;
				}
				
				// Custom Interception Points
				CustomInterceptionPoints = XMLSearch(arguments.xml,"//Interceptors/CustomInterceptionPoints");
				if ( ArrayLen(CustomInterceptionPoints) gt 1 ){
					$throw("There were more than 1 CustomInterceptionPoints elements found. There can only be one.","","XMLParser.ConfigXMLParsingException");
				}
				if( arraylen(CustomInterceptionPoints) ){
					configStruct.InterceptorConfig.CustomInterceptionPoints = arguments.utility.placeHolderReplacer(Trim(CustomInterceptionPoints[1].XMLText),configStruct);
				}
				
				//Parse all Interceptor Nodes now.
				InterceptorNodes = XMLSearch(arguments.xml,"//Interceptors/Interceptor");
				for (i=1; i lte ArrayLen(InterceptorNodes); i=i+1){
					interceptorStruct = structnew();
					// get Class
					interceptorStruct.class = arguments.utility.placeHolderReplacer(Trim(InterceptorNodes[i].XMLAttributes["class"]),configStruct);
					// get Name if found?
					interceptorStruct.name = listLast(interceptorStruct.class,".");
					if( structKeyExists(InterceptorNodes[i].XMLAttributes,"name") ){
						interceptorStruct.name = InterceptorNodes[i].XMLAttributes.name;
					}
					//Prepare Properties
					interceptorStruct.properties = structnew();
					//Parse Interceptor Properties
					if ( ArrayLen(InterceptorNodes[i].XMLChildren) ){
						for(j=1; j lte ArrayLen(InterceptorNodes[i].XMLChildren); j=j+1){
							//Property Complex Check
							tempProperty = arguments.utility.placeHolderReplacer(Trim( InterceptorNodes[i].XMLChildren[j].XMLText ),configStruct);
							//Check for Complex Setup
							if( reFindNocase(instance.jsonRegex,tempProperty) ){
								StructInsert( interceptorStruct.properties, Trim(InterceptorNodes[i].XMLChildren[j].XMLAttributes["name"]), getPlugin('JSON').decode(replace(tempProperty,"'","""","all")) );
							}
							else{
								StructInsert( interceptorStruct.properties, Trim(InterceptorNodes[i].XMLChildren[j].XMLAttributes["name"]), tempProperty );
							}
						}//end loop of properties
					}//end if no properties					
					//Add to Array
					ArrayAppend( configStruct.InterceptorConfig.Interceptors, interceptorStruct );
				}//end interceptor nodes				
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