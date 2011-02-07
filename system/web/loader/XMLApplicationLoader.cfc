<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	 		: Luis Majano
Date     		: September 23, 2005
Description		: 

Loads a coldbox xml configuration file

----------------------------------------------------------------------->
<cfcomponent hint="Loads a coldbox xml configuration file" output="false" extends="coldbox.system.web.loader.AbstractApplicationLoader">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------>
	
	<cfscript>
		instance = structnew();
	</cfscript>

	<!--- init --->
	<cffunction name="init" output="false" access="public" returntype="any" hint="constructor">
		<cfargument name="controller" type="any" required="true" default="" hint="The coldbox application to load the settings into"/>
		<cfscript>
			super.init(arguments.controller);
			
			// Regex for JSON
			instance.jsonRegex = "^(\{|\[)(.)*(\}|\])$";
			instance.jsonUtil = createObject("component","coldbox.system.core.conversion.JSON").init();
			
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------>
	
	<cffunction name="loadConfiguration" access="public" returntype="void" output="false" hint="Parse the application configuration file.">
		<!--- ************************************************************* --->
		<cfargument name="overrideAppMapping" type="any" required="false" default="" hint="Only used for unit testing or reparsing of a specific coldbox config file."/>
		<!--- ************************************************************* --->
		<cfscript>
		//Create Config Structure
		var configStruct = structNew();
		var coldboxSettings = getColdboxSettings();
		var configFileLocation = coldboxSettings["ConfigFileLocation"];
		var configXML = "";
		
		//Testers
		var xmlvalidation = "";
		var errorDetails = "";
		var i = 1;
		
		
		/* ::::::::::::::::::::::::::::::::::::::::: CONFIG FILE PARSING & VALIDATION :::::::::::::::::::::::::::::::::::::::::::: */
		// Validate File
		if ( not fileExists(configFileLocation) ){
			getUtil().throwit(message="The Config File: #ConfigFileLocation# can't be found.",
							  type="XMLApplicationLoader.ConfigXMLFileNotFoundException");
		}			
		
		// Parse configuration file
		configXML = xmlParse(ConfigFileLocation);
		
		/* ::::::::::::::::::::::::::::::::::::::::: APP LOCATION CALCULATIONS :::::::::::::::::::::::::::::::::::::::::::: */
		
		// load default application paths
		loadApplicationPaths(configStruct,arguments.overrideAppMapping);
		
		/* ::::::::::::::::::::::::::::::::::::::::: GET COLDBOX SETTINGS  :::::::::::::::::::::::::::::::::::::::::::: */
		parseColdboxSettings(configXML,configStruct,arguments.overrideAppMapping);
		
		/* ::::::::::::::::::::::::::::::::::::::::: YOUR SETTINGS LOADING :::::::::::::::::::::::::::::::::::::::::::: */
		parseYourSettings(configXML,configStruct);	
		
		/* ::::::::::::::::::::::::::::::::::::::::: YOUR CONVENTIONS LOADING :::::::::::::::::::::::::::::::::::::::::::: */
		parseConventions(configXML,configStruct);
		
		/* ::::::::::::::::::::::::::::::::::::::::: MODEL SETTINGS  :::::::::::::::::::::::::::::::::::::::::::: */
		parseModels(configXML,configStruct);
		
		/* ::::::::::::::::::::::::::::::::::::::::: MODULE SETTINGS  :::::::::::::::::::::::::::::::::::::::::::: */
		parseModules(configXML,configStruct);
		
		/* ::::::::::::::::::::::::::::::::::::::::: IOC SETTINGS  :::::::::::::::::::::::::::::::::::::::::::: */
		parseIOC(configXML,configStruct);
		
		/* ::::::::::::::::::::::::::::::::::::::::: HANDLER-MODELS-PLUGIN INVOCATION PATHS :::::::::::::::::::::::::::::::::::::::::::: */
		parseInvocationPaths(configXML,configStruct);
		
		/* ::::::::::::::::::::::::::::::::::::::::: EXTERNAL LAYOUTS/VIEWS LOCATION :::::::::::::::::::::::::::::::::::::::::::: */
		parseExternalLocations(configXML,configStruct);
		
		/* ::::::::::::::::::::::::::::::::::::::::: MAIL SETTINGS :::::::::::::::::::::::::::::::::::::::::::: */
		parseMailSettings(configXML,configStruct);	
		
		/* ::::::::::::::::::::::::::::::::::::::::: I18N SETTINGS :::::::::::::::::::::::::::::::::::::::::::: */
		parseLocalization(configXML,configStruct);			
		
		/* ::::::::::::::::::::::::::::::::::::::::: BUG MAIL SETTINGS :::::::::::::::::::::::::::::::::::::::::::: */
		parseBugTracers(configXML,configStruct);			
		
		/* ::::::::::::::::::::::::::::::::::::::::: WS SETTINGS :::::::::::::::::::::::::::::::::::::::::::: */
		parseWebservices(configXML,configStruct);			

		/* ::::::::::::::::::::::::::::::::::::::::: DATASOURCES SETTINGS :::::::::::::::::::::::::::::::::::::::::::: */
		parseDatasources(configXML,configStruct);
		
		/* ::::::::::::::::::::::::::::::::::::::::: LAYOUT VIEW FOLDER SETTINGS :::::::::::::::::::::::::::::::::::::::::::: */
		parseLayoutsViews(configXML,configStruct);			
		
		/* :::::::::::::::::::::::::::::::::::::::::  CACHE SETTINGS :::::::::::::::::::::::::::::::::::::::::::: */
		parseCacheSettings(configXML,configStruct);
					
		/* ::::::::::::::::::::::::::::::::::::::::: DEBUGGER SETTINGS :::::::::::::::::::::::::::::::::::::::::::: */
		parsedebuggerSettings(configXML,configStruct);			
					
		/* ::::::::::::::::::::::::::::::::::::::::: INTERCEPTOR SETTINGS :::::::::::::::::::::::::::::::::::::::::::: */
		parseInterceptors(configXML,configStruct);
		
		/* ::::::::::::::::::::::::::::::::::::::::: LOGBOX Configuration :::::::::::::::::::::::::::::::::::::::::::: */
		parseLogBox(configXML,configStruct);
		
		/* ::::::::::::::::::::::::::::::::::::::::: WIREBOX Configuration :::::::::::::::::::::::::::::::::::::::::::: */
		parseWireBox(configXML,configStruct);
		
		/* ::::::::::::::::::::::::::::::::::::::::: CONFIG FILE LAST MODIFIED SETTING :::::::::::::::::::::::::::::::::::::::::::: */
		configStruct.configTimeStamp = getUtil().fileLastModified(ConfigFileLocation);
		
		/* ::::::::::::::::::::::::::::::::::::::::: XSD VALIDATION :::::::::::::::::::::::::::::::::::::::::::: */
		
		xmlvalidation = XMLValidate(configXML, coldboxSettings["ConfigFileSchemaLocation"]);
		
		//Validate Errors
		if(NOT xmlvalidation.status){
			for(i = 1; i lte ArrayLen(xmlvalidation.errors); i = i + 1){
				errorDetails = errorDetails & xmlvalidation.errors[i] & chr(10) & chr(13);
			}
			//Throw the error.
			getUtil().throwit("The config.xml file does not validate with the framework's schema.",
							  "The error details are: #errorDetails#",
							  "XMLApplicationLoader.ConfigXMLParsingException");
		}// if invalid status
			
		
		//finish by loading configuration
		instance.controller.setConfigSettings(configStruct);
		</cfscript>
	</cffunction>
	
	<!--- parseColdboxSettings --->
	<cffunction name="parseColdboxSettings" output="false" access="public" returntype="void" hint="Parse ColdBox Settings">
		<cfargument name="xml" 		type="any" required="true" hint="The xml object"/>
		<cfargument name="config" 	type="struct" required="true" hint="The config struct"/>
		<cfargument name="overrideAppMapping" type="string" required="false" default="" hint="Only used for unit testing or reparsing of a specific coldbox config file."/>
		<cfscript>
			var configStruct = arguments.config;
			var fwSettingsStruct = getColdboxSettings();
			var SettingNodes = XMLSearch(arguments.xml,"//Settings/Setting");
			var i=1;
			
			if ( ArrayLen(SettingNodes) eq 0 ){
				getUtil().throwit(message="No Setting elements could be found in the configuration file.",
								  type="XMLApplicationLoader.ConfigXMLParsingException");
			}
			
			//Insert application settings to Config Struct
			for (i=1; i lte arrayLen(SettingNodes); i=i+1){
				configStruct[trim(SettingNodes[i].XMLAttributes["name"])] = getUtil().placeHolderReplacer(trim(SettingNodes[i].XMLAttributes["value"]),configStruct);
			}
			
			// override AppMapping from what user set if passed in via the creation. Mostly for unit testing this is done. 
			if ( len(trim(arguments.overrideAppMapping)) ){
				configStruct["AppMapping"] = arguments.overrideAppMapping;
			}
			
			// Clean the first / if found
			if(structKeyExists(configStruct,"AppMapping") AND len(configStruct.AppMapping) eq 1 ){
				configStruct["AppMapping"] = "";
			}
			
			//Common structures
			configStruct.layoutsRefMap 	= structnew();
			configStruct.viewsRefMap	= structnew();
			
			/* ::::::::::::::::::::::::::::::::::::::::: COLDBOX SETTINGS VALIDATION :::::::::::::::::::::::::::::::::::::::::::: */
			
			// Default environment setting.
			configStruct.Environment = "PRODUCTION";
			
			//Check for AppName or throw
			if ( not StructKeyExists(configStruct, "AppName") )
				getUtil().throwit("There was no 'AppName' setting defined. This is required by the framework.","","XMLApplicationLoader.ConfigXMLParsingException");
			//Check for Default Event
			if ( not StructKeyExists(configStruct, "DefaultEvent") )
				getUtil().throwit("There was no 'DefaultEvent' setting defined. This is required by the framework.","","XMLApplicationLoader.ConfigXMLParsingException");
			//Check for Event Name
			if ( not StructKeyExists(configStruct, "EventName") )
				configStruct["EventName"] = fwSettingsStruct["EventName"] ;
			//Check for Application Start Handler
			if ( not StructKeyExists(configStruct, "ApplicationStartHandler") )
				configStruct["ApplicationStartHandler"] = "";
			//Check for Application End Handler
			if ( not StructKeyExists(configStruct, "applicationEndHandler") )
				configStruct["applicationEndHandler"] = "";
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
			if ( not structKeyExists(configStruct, "DebugPassword") ){ configStruct["DebugPassword"] = ""; }
			else if( len(configStruct["DebugPassword"]) ){ configStruct["DebugPassword"] = hash(configStruct["DebugPassword"]); }
			
			//Check for ReinitPassword
			if ( not structKeyExists(configStruct, "ReinitPassword") ){ configStruct["ReinitPassword"] = ""; }
			else if( len(configStruct["ReinitPassword"]) ){ configStruct["ReinitPassword"] = hash(configStruct["ReinitPassword"]); }
			
			//Check For UDFLibraryFile
			if ( not StructKeyExists(configStruct, "UDFLibraryFile") )
				configStruct["UDFLibraryFile"] = "";
			//Check For CustomErrorTemplate
			if ( not StructKeyExists(configStruct, "CustomErrorTemplate") )
				configStruct["CustomErrorTemplate"] = "";
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
			if( not structKeyExists(configStruct,"FlashURLPersistScope") ){
				configStruct["FlashURLPersistScope"] = fwSettingsStruct["FlashURLPersistScope"];
			}
			//Check for Missing Template Handler
			if ( not StructKeyExists(configStruct, "MissingTemplateHandler") )
				configStruct["MissingTemplateHandler"] = "";
			
			// Check for ColdBox Extensions Location
			if( not structKeyExists(configStruct, "ColdBoxExtensionsLocation") OR not len(configStruct.ColdBoxExtensionsLocation) ){
				configStruct["ColdBoxExtensionsLocation"] = "";
			}
			
			// calculate AppMapping if not found in the user configuration file
			if ( NOT structKeyExists(configStruct, "AppMapping") ){
				calculateAppMapping(configStruct);
			}
			
			// Modules Configuration
			if( not structKeyExists(configStruct,"ModulesExternalLocation") ){
				configStruct.ModulesExternalLocation = arrayNew(1);
			}
			if( isSimpleValue(configStruct.ModulesExternalLocation) ){
				configStruct.ModulesExternalLocation = listToArray( configStruct.ModulesExternalLocation );
			}
		</cfscript>
	</cffunction>
	
	<!--- parseYourSettings --->
	<cffunction name="parseYourSettings" output="false" access="public" returntype="void" hint="Parse Your Settings">
		<cfargument name="xml" 		type="any" required="true" hint="The xml object"/>
		<cfargument name="config" 	type="struct" required="true" hint="The config struct"/>
		<cfscript>
			var configStruct = arguments.config;
			var yourSettingNodes = XMLSearch(arguments.xml, "//YourSettings/Setting");
			var i=1;
			var tester = "";
			var oUtil = getUtil();
			var oJSONUtil = getJSONUtil();
			var jsonREGEX = getjsonREGEX();
			
			//Insert Your Settings to Config Struct
			for (i=1; i lte ArrayLen(yourSettingNodes); i=i+1){
				
				// Check if value attribute exists, else check text.
				if( structKeyExists(yourSettingNodes[i].XMLAttributes,"value") ){
					tester = oUtil.placeHolderReplacer(trim(yourSettingNodes[i].XMLAttributes["value"]),configStruct);
				}
				// Check for the xml text
				if( len(yourSettingNodes[i].XMLText) ){
					tester = oUtil.placeHolderReplacer(trim(yourSettingNodes[i].XMLText),configStruct);
				}
				
				//Test for JSON
				if( reFindNocase(jsonREGEX,tester) ){
					configStruct[yourSettingNodes[i].XMLAttributes["name"]] = oJSONUtil.decode(replace(tester,"'","""","all"));
				}
				else{
					configStruct[yourSettingNodes[i].XMLAttributes["name"]] = tester;
				}
			}
		</cfscript>
	</cffunction>
	
	<!--- parseConventions --->
	<cffunction name="parseConventions" output="false" access="public" returntype="void" hint="Parse Conventions">
		<cfargument name="xml" 		type="any" required="true" hint="The xml object"/>
		<cfargument name="config" 	type="struct" required="true" hint="The config struct"/>
		<cfscript>
			var configStruct = arguments.config;
			var conventions = XMLSearch(arguments.xml,"//Conventions");
			var fwSettingsStruct = getColdboxSettings();
			
			if( ArrayLen(conventions) ){
				// Override conventions on a per found basis.
				if( structKeyExists(conventions[1],"handlersLocation") ){ fwSettingsStruct["handlersConvention"] = trim(conventions[1].handlersLocation.xmltext); }
				if( structKeyExists(conventions[1],"pluginsLocation") ){ fwSettingsStruct["pluginsConvention"] = trim(conventions[1].pluginsLocation.xmltext); }
				if( structKeyExists(conventions[1],"layoutsLocation") ){ fwSettingsStruct["LayoutsConvention"] = trim(conventions[1].layoutsLocation.xmltext); }
				if( structKeyExists(conventions[1],"viewsLocation") ){ fwSettingsStruct["ViewsConvention"] = trim(conventions[1].viewsLocation.xmltext); }
				if( structKeyExists(conventions[1],"eventAction") ){ fwSettingsStruct["eventAction"] = trim(conventions[1].eventAction.xmltext); }
				if( structKeyExists(conventions[1],"modelsLocation") ){ fwSettingsStruct["ModelsConvention"] = trim(conventions[1].modelsLocation.xmltext); }
				if( structKeyExists(conventions[1],"modulesLocation") ){ fwSettingsStruct["ModulesConvention"] = trim(conventions[1].modulesLocation.xmltext); }
			}
		</cfscript>
	</cffunction>

	<!--- parseModels --->
	<cffunction name="parseModels" output="false" access="public" returntype="void" hint="Parse Models">
		<cfargument name="xml" 		  type="any"     required="true" hint="The xml object"/>
		<cfargument name="config" 	  type="struct"  required="true" hint="The config struct"/>
		<cfargument name="isOverride" type="boolean" required="false" default="false" hint="Flag to denote if overriding or first time runner."/>
		<cfscript>
			var configStruct = arguments.config;
			var ModelNodes = XMLSearch(arguments.xml,"//Models");
			var fwSettingsStruct = getColdBoxSettings();
			
			// Defaults if not overriding
			if (NOT arguments.isOverride){
				configStruct.ModelsExternalLocation = "";
				configStruct.ModelsObjectCaching = fwSettingsStruct["ModelsObjectCaching"];
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
	
	<!--- parseIOC --->
	<cffunction name="parseIOC" output="false" access="public" returntype="void" hint="Parse IOC Integration">
		<cfargument name="xml" 		  type="any"     required="true" hint="The xml object"/>
		<cfargument name="config" 	  type="struct"  required="true" hint="The config struct"/>
		<cfargument name="isOverride" type="boolean" required="false" default="false" hint="Flag to denote if overriding or first time runner."/>
		<cfscript>
			var configStruct = arguments.config;
			var iocNodes = XMLSearch(arguments.xml,"//IOC");
			var fwSettingsStruct = getColdBoxSettings();
			
			// Defaults if not overriding
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
	
	<!--- parseInvocationPaths --->
	<cffunction name="parseInvocationPaths" output="false" access="public" returntype="void" hint="Parse Invocation paths">
		<cfargument name="xml" 		type="any"    required="true" hint="The xml object"/>
		<cfargument name="config" 	type="struct" required="true" hint="The config struct"/>
		<cfscript>
			var configStruct = arguments.config;
			var fwSettingsStruct = getColdBoxSettings();
			var appMappingAsDots = "";
			
			// Default Locations for ROOT based apps, which is the default
			//Parse out the first / to create the invocation Path
			if ( left(configStruct["AppMapping"],1) eq "/" ){
				configStruct["AppMapping"] = removeChars(configStruct["AppMapping"],1,1);
			}
			
			// Handler Registration
			configStruct["HandlersInvocationPath"] = reReplace(fwSettingsStruct.handlersConvention,"(/|\\)",".","all");
			configStruct["HandlersPath"] = fwSettingsStruct.ApplicationPath & fwSettingsStruct.handlersConvention;
			// Custom Plugins Registration
			configStruct["MyPluginsInvocationPath"] = reReplace(fwSettingsStruct.pluginsConvention,"(/|\\)",".","all");
			configStruct["MyPluginsPath"] = fwSettingsStruct.ApplicationPath & fwSettingsStruct.pluginsConvention;
			// Models Registration
			configStruct["ModelsInvocationPath"] = reReplace(fwSettingsStruct.ModelsConvention,"(/|\\)",".","all");
			configStruct["ModelsPath"] = fwSettingsStruct.ApplicationPath & fwSettingsStruct.ModelsConvention;
			
			//App Mapping Invocation Path
			appMappingAsDots = reReplace(configStruct["AppMapping"],"(/|\\)",".","all");
			
			//Set the Handlers,Models, & Custom Plugin Invocation & Physical Path for this Application
			if( len(configStruct["AppMapping"]) ){
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
			
			//Configure the modules locations in the application
			if( len(configStruct.AppMapping) ){
				configStruct.ModulesLocation 		= "/#configStruct.AppMapping#/#fwSettingsStruct.ModulesConvention#";
				configStruct.ModulesInvocationPath	= appMappingAsDots & ".#reReplace(fwSettingsStruct.ModulesConvention,"(/|\\)",".","all")#";
			}
			else{
				configStruct.ModulesLocation 		= "/#fwSettingsStruct.ModulesConvention#";
				configStruct.ModulesInvocationPath 	= reReplace(fwSettingsStruct.ModulesConvention,"(/|\\)",".","all");
			}
			configStruct.ModulesPath = fwSettingsStruct.ApplicationPath & fwSettingsStruct.ModulesConvention;
		
		</cfscript>
	</cffunction>

	<!--- parseExternalLocations --->
	<cffunction name="parseExternalLocations" output="false" access="public" returntype="void" hint="Parse External locations">
		<cfargument name="xml" 		type="any" required="true" hint="The xml object"/>
		<cfargument name="config" 	type="struct" required="true" hint="The config struct"/>
		<cfscript>
			var configStruct = arguments.config;
			var fwSettingsStruct = getColdBoxSettings();
			
			// ViewsExternalLocation Setup 
			if( structKeyExists(configStruct,"ViewsExternalLocation") and len(configStruct["ViewsExternalLocation"]) ){
				// Verify the locations, do relative to the app mapping first 
				if( directoryExists(fwSettingsStruct.ApplicationPath & configStruct["ViewsExternalLocation"]) ){
					configStruct["ViewsExternalLocation"] = "/" & configStruct["AppMapping"] & "/" & configStruct["ViewsExternalLocation"];
				}
				else if( not directoryExists(expandPath(configStruct["ViewsExternalLocation"])) ){
					getUtil().throwIt("ViewsExternalLocation could not be found.","The directories tested was relative and expanded using #configStruct['ViewsExternalLocation']#. Please verify your setting.","XMLApplicationLoader.ConfigXMLParsingException");
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
				if( directoryExists(fwSettingsStruct.ApplicationPath & configStruct["LayoutsExternalLocation"]) ){
					configStruct["LayoutsExternalLocation"] = "/" & configStruct["AppMapping"] & "/" & configStruct["LayoutsExternalLocation"];
				}
				else if( not directoryExists(expandPath(configStruct["LayoutsExternalLocation"])) ){
					getUtil().throwIt("LayoutsExternalLocation could not be found.","The directories tested was relative and expanded using #configStruct['LayoutsExternalLocation']#. Please verify your setting.","XMLApplicationLoader.ConfigXMLParsingException");
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

	<!--- parseLocalization --->
	<cffunction name="parseMailSettings" output="false" access="public" returntype="void" hint="Parse Mail Settings">
		<cfargument name="xml" 		  type="any" required="true" hint="The xml object"/>
		<cfargument name="config" 	  type="struct" required="true" hint="The config struct"/>
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

	<!--- parseLocalization --->
	<cffunction name="parseLocalization" output="false" access="public" returntype="void" hint="Parse localization">
		<cfargument name="xml" 		type="any" required="true" hint="The xml object"/>
		<cfargument name="config" 	type="struct" required="true" hint="The config struct"/>
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
				configStruct.UnknownTranslation = "";
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
						getUtil().throwit(message="Invalid local storage scope: #configStruct["localeStorage"]#",
							   			  detail="Valid scopes are session,client, cookie",
							   			  type="XMLApplicationLoader.InvalidLocaleStorage");
					}
				}
				
				//Check for DefaultResourceBundle
				if ( structKeyExists(i18NSettingNodes[1], "UnknownTranslation") AND len(i18NSettingNodes[1].UnknownTranslation.xmltext) ){
					configStruct["UnknownTranslation"] = i18NSettingNodes[1].UnknownTranslation.xmltext;
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
		<cfargument name="isOverride" type="boolean" required="false" default="false" hint="Flag to denote if overriding or first time runner."/>
		<cfscript>
			var configStruct = arguments.config;
			var WebServiceNodes = "";
			var i=1;
			
			//Get Web Services From Config.
			WebServiceNodes = XMLSearch(arguments.xml,"//WebServices/WebService");
			
			// Defaults unless override
			if( NOT arguments.isOverride ){
				configStruct.webservices = structnew();
			}
			
			// Init webservices holder structure
			for (i=1; i lte ArrayLen(WebServiceNodes); i=i+1){
				configStruct.webservices[WebServiceNodes[i].XMLAttributes["name"]] = trim(WebServiceNodes[i].XMLAttributes["URL"]);
			}	
		</cfscript>
	</cffunction>

	<!--- parseDatasources --->
	<cffunction name="parseDatasources" output="false" access="public" returntype="void" hint="Parse Datsources">
		<cfargument name="xml" 		type="any" required="true" hint="The xml object"/>
		<cfargument name="config" 	type="struct" required="true" hint="The config struct"/>
		<cfargument name="isOverride" type="boolean" required="false" default="false" hint="Flag to denote if overriding or first time runner."/>
		<cfscript>
			var configStruct = arguments.config;
			var DatasourcesNodes = "";
			var i=1;
			var DSNStruct = "";
			
			//Datasources Support
			DatasourcesNodes = XMLSearch(arguments.xml,"//Datasources/Datasource");
			
			// Default if not overriding
			if( NOT arguments.isOverride ){
				configStruct.Datasources = structnew();
			}	
			
			//Create Structures
			for(i=1;i lte ArrayLen(DatasourcesNodes); i=i+1){
				DSNStruct = structNew();
				DSNStruct.DBType = "";
				DSNStruct.Username = "";
				DSNStruct.Password = "";

				if ( not structKeyExists(DatasourcesNodes[i].XMLAttributes, "Alias") or len(Trim(DatasourcesNodes[i].XMLAttributes["Alias"])) eq 0 )
					getUtil().throwit("This datasource entry's alias cannot be blank","","XMLApplicationLoader.ConfigXMLParsingException");
				else
					DSNStruct.Alias = Trim(DatasourcesNodes[i].XMLAttributes["Alias"]);
				
				if ( not structKeyExists(DatasourcesNodes[i].XMLAttributes, "Name") or len(Trim(DatasourcesNodes[i].XMLAttributes["Name"])) eq 0 )
					getUtil().throwit("This datasource entry's name cannot be blank","","XMLApplicationLoader.ConfigXMLParsingException");
				else
					DSNStruct.Name = Trim(DatasourcesNodes[i].XMLAttributes["Name"]);

				//Optional Entries.
				if ( structKeyExists(DatasourcesNodes[i].XMLAttributes, "dbtype") )
					DSNStruct.DBType = Trim(DatasourcesNodes[i].XMLAttributes["dbtype"]);
					
				if ( structKeyExists(DatasourcesNodes[i].XMLAttributes, "Username") )
					DSNStruct.Username = Trim(DatasourcesNodes[i].XMLAttributes["username"]);
					
				if ( structKeyExists(DatasourcesNodes[i].XMLAttributes, "password") )
					DSNStruct.Password = Trim(DatasourcesNodes[i].XMLAttributes["password"]);
				
				//Insert to structure with Alias as key
				configStruct.Datasources[DSNStruct.Alias] = DSNStruct;
			}	
		</cfscript>
	</cffunction>

	<!--- parseLayoutsViews --->
	<cffunction name="parseLayoutsViews" output="false" access="public" returntype="void" hint="Parse Layouts And Views">
		<cfargument name="xml" 		type="any" required="true" hint="The xml object"/>
		<cfargument name="config" 	type="struct" required="true" hint="The config struct"/>
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
				getUtil().throwit("There was no default layout element found.","","XMLApplicationLoader.ConfigXMLParsingException");
			if ( ArrayLen(DefaultLayout) gt 1 )
				getUtil().throwit("There were more than 1 DefaultLayout elements found. There can only be one.","","XMLApplicationLoader.ConfigXMLParsingException");
			
			//Insert Default Layout
			configStruct.DefaultLayout = trim(DefaultLayout[1].XMLText);
			
			//Default View into Config
			DefaultView = XMLSearch(arguments.xml,"//Layouts/DefaultView");
			// Default view
			configStruct["DefaultView"] = "";
			// Setup view if found
			if( arrayLen(defaultView) ){
				configStruct["DefaultView"] = trim(DefaultView[1].XMLText);
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
		<cfargument name="xml" 		  type="any" 		required="true" hint="The xml object"/>
		<cfargument name="config" 	  type="struct" 	required="true" hint="The config struct"/>
		<cfargument name="isOverride" type="boolean" 	required="false" default="false" hint="Flag to denote if overriding or first time runner."/>
		<cfscript>
			var configStruct 		= arguments.config;
			var fwSettingsStruct 	= getColdboxSettings();
			var cacheSettingNodes  	= "";
			var cboxSettingNodes	= "";
			
			//Cache Override Settings
			cacheSettingNodes = XMLSearch(arguments.xml,"//Config/Cache");
			cboxSettingNodes  = XMLSearch(arguments.xml,"//CacheBox");
			
			// CacheBox Defaults if not Overriding
			if (NOT arguments.isOverride){
				
				// setup the cache configs
				configStruct.cacheBox				= structnew();
				configStruct.cacheBox.dsl			= structnew();
				configStruct.cacheBox.xml  			= cboxSettingNodes;
				configStruct.cacheBox.configFile 	= "";
								
				// Cache Compat Defaults
				configStruct.cacheSettings 								  = structnew();
				configStruct.cacheSettings.objectDefaultTimeout 		  = fwSettingsStruct.cacheObjectDefaultTimeout;
				configStruct.cacheSettings.objectDefaultLastAccessTimeout = fwSettingsStruct.cacheObjectDefaultLastAccessTimeout;
				configStruct.cacheSettings.reapFrequency 				  = fwSettingsStruct.cacheObjectDefaultTimeout;
				configStruct.cacheSettings.freeMemoryPercentageThreshold  = fwSettingsStruct.cacheFreeMemoryPercentageThreshold;
				configStruct.cacheSettings.useLastAccessTimeouts 		  = fwSettingsStruct.cacheUseLastAccessTimeouts;
				configStruct.cacheSettings.evictionPolicy 				  = fwSettingsStruct.cacheEvictionPolicy;
				configStruct.cacheSettings.evictCount					  = fwSettingsStruct.cacheEvictCount;
				configStruct.cacheSettings.maxObjects					  = fwSettingsStruct.cacheMaxObjects;	
				configStruct.cacheSettings.compatMode					  = false;
			}
			
			// cacheSettingNodes in COMPAT MODE
			if( arrayLen(cacheSettingNodes) ){
				
				//Check if empty
				if ( ArrayLen(cacheSettingNodes[1].XMLChildren) gt 0){
					
					// Mark the Compat Mode
					configStruct.cacheSettings.compatMode = true;
					
					//Checks For Default Timeout
					if ( structKeyExists(cacheSettingNodes[1], "ObjectDefaultTimeout") and isNumeric(cacheSettingNodes[1].ObjectDefaultTimeout.xmlText) ){
						configStruct.cacheSettings.objectDefaultTimeout = trim(cacheSettingNodes[1].ObjectDefaultTimeout.xmlText);
					}
					
					//Check ObjectDefaultLastAccessTimeout
					if ( structKeyExists(cacheSettingNodes[1], "ObjectDefaultLastAccessTimeout") and isNumeric(cacheSettingNodes[1].ObjectDefaultLastAccessTimeout.xmlText)){
						configStruct.cacheSettings.objectDefaultLastAccessTimeout = trim(cacheSettingNodes[1].ObjectDefaultLastAccessTimeout.xmlText);
					}
					
					//Check ReapFrequency
					if ( structKeyExists(cacheSettingNodes[1], "ReapFrequency") and isNumeric(cacheSettingNodes[1].ReapFrequency.xmlText)){
						configStruct.cacheSettings.reapFrequency = trim(cacheSettingNodes[1].ReapFrequency.xmlText);
					}
					
					//Check MaxObjects
					if ( structKeyExists(cacheSettingNodes[1], "MaxObjects") and isNumeric(cacheSettingNodes[1].MaxObjects.xmlText)){
						configStruct.cacheSettings.maxObjects = trim(cacheSettingNodes[1].MaxObjects.xmlText);
					}
					
					//Check FreeMemoryPercentageThreshold
					if ( structKeyExists(cacheSettingNodes[1], "FreeMemoryPercentageThreshold") and isNumeric(cacheSettingNodes[1].FreeMemoryPercentageThreshold.xmlText)){
						configStruct.cacheSettings.freeMemoryPercentageThreshold = trim(cacheSettingNodes[1].FreeMemoryPercentageThreshold.xmlText);
					}
					
					//Check for CacheUseLastAccessTimeouts
					if ( structKeyExists(cacheSettingNodes[1], "UseLastAccessTimeouts") and isBoolean(cacheSettingNodes[1].UseLastAccessTimeouts.xmlText) ){
						configStruct.cacheSettings.useLastAccessTimeouts = trim(cacheSettingNodes[1].UseLastAccessTimeouts.xmlText);
					}
					
					//Check for CacheEvictionPolicy
					if ( structKeyExists(cacheSettingNodes[1], "EvictionPolicy") ){
						configStruct.cacheSettings.evictionPolicy = trim(cacheSettingNodes[1].EvictionPolicy.xmlText);
					}
					
					//Check for CacheEvictCount
					if ( structKeyExists(cacheSettingNodes[1], "EvictCount") and 
						 isNumeric(trim(cacheSettingNodes[1].evictCount.xmlText)) and
						 trim(cacheSettingNodes[1].evictCount.xmlText) gt 0 ){
						configStruct.cacheSettings.evictCount = trim(cacheSettingNodes[1].evictCount.xmlText);
					}
				}// if cachesettings had children
				
				return;
			} // if in compat cache settings mode
			
			
			//CacheBox loading here
			
			// Check if we have defined DSL first in application config
			if( arrayLen(cboxSettingNodes) ){
				
				// Do we have a configFile key for external loading?
				if( structKeyExists(cboxSettingNodes[1], "ConfigFile") ){
					configStruct.cacheBox.configFile = cboxSettingNodes[1].ConfigFile.XMLText;
				}
				else{
					// else just save the xml for parsing
					configStruct.cacheBox.xml = cboxSettingNodes;
				}
			
			}
			// Check if LogBoxConfig.cfc exists in the config conventions
			else if( fileExists( instance.controller.getAppRootPath() & "config/CacheBox.cfc") ){
				configStruct.cacheBox.configFile = loadCacheBoxByConvention(configStruct);
			}
			// else, load the default coldbox cachebox config
			else{
				configStruct.cacheBox.configFile = "coldbox.system.web.config.CacheBox";
			}
		</cfscript>
	</cffunction>	

	<!--- parsedebuggerSettings --->
	<cffunction name="parseDebuggerSettings" output="false" access="public" returntype="void" hint="Parse Debugger Settings">
		<cfargument name="xml" 		type="any" required="true" hint="The xml object"/>
		<cfargument name="config" 	type="struct" required="true" hint="The config struct"/>
		<cfargument name="isOverride" type="boolean" required="false" default="false" hint="Flag to denote if overriding or first time runner."/>
		<cfscript>
			var configStruct = arguments.config;
			var debuggerSettingNodes = "";
			var fwSettings = getColdBoxSettings();
			
			debuggerSettingNodes = XMLSearch(arguments.xml,"//DebuggerSettings");
			
			if (NOT arguments.isOverride){
				configStruct.debuggerSettings = structnew();
				configStruct.debuggerSettings.enableDumpVar 				= fwSettings.enableDumpVar;
				configStruct.debuggerSettings.persistentRequestProfiler 	= fwSettings.PersistentRequestProfiler;
				configStruct.debuggerSettings.maxPersistentRequestProfilers = fwSettings.maxPersistentRequestProfilers;
				configStruct.debuggerSettings.maxRCPanelQueryRows			= fwSettings.maxRCPanelQueryRows;
				configStruct.debuggerSettings.showTracerPanel 				= fwSettings.showTracerPanel;
				configStruct.debuggerSettings.expandedTracerPanel 			= fwSettings.expandedTracerPanel;
				configStruct.debuggerSettings.showInfoPanel 				= fwSettings.showInfoPanel;
				configStruct.debuggerSettings.expandedInfoPanel 			= fwSettings.expandedInfoPanel;
				configStruct.debuggerSettings.showCachePanel 				= fwSettings.showCachePanel;
				configStruct.debuggerSettings.expandedCachePanel 			= fwSettings.expandedCachePanel;
				configStruct.debuggerSettings.showRCPanel 					= fwSettings.showRCPanel;
				configStruct.debuggerSettings.expandedRCPanel				= fwSettings.expandedRCPanel;
				configStruct.debuggerSettings.showModulesPanel 				= fwSettings.showModulesPanel;
				configStruct.debuggerSettings.expandedModulesPanel			= fwSettings.expandedModulesPanel;
			}
			
			//Check if empty
			if ( ArrayLen(DebuggerSettingNodes) ){
				// EnableDumpVar
				if ( structKeyExists(DebuggerSettingNodes[1], "EnableDumpVar") and isBoolean(DebuggerSettingNodes[1].EnableDumpVar.xmlText) ){
					configStruct.debuggerSettings.EnableDumpVar = trim(DebuggerSettingNodes[1].EnableDumpVar.xmlText);
				}
				// PersistentRequestProfiler
				if ( structKeyExists(DebuggerSettingNodes[1], "PersistentRequestProfiler") and isBoolean(DebuggerSettingNodes[1].PersistentRequestProfiler.xmlText) ){
					configStruct.debuggerSettings.PersistentRequestProfiler = trim(DebuggerSettingNodes[1].PersistentRequestProfiler.xmlText);
				}
				// maxPersistentRequestProfilers
				if ( structKeyExists(DebuggerSettingNodes[1], "maxPersistentRequestProfilers") and isNumeric(DebuggerSettingNodes[1].maxPersistentRequestProfilers.xmlText) ){
					configStruct.debuggerSettings.maxPersistentRequestProfilers = trim(DebuggerSettingNodes[1].maxPersistentRequestProfilers.xmlText);
				}
				// maxRCPanelQueryRows */
				if ( structKeyExists(DebuggerSettingNodes[1], "maxRCPanelQueryRows") and isNumeric(DebuggerSettingNodes[1].maxRCPanelQueryRows.xmlText) ){
					configStruct.debuggerSettings.maxRCPanelQueryRows = trim(DebuggerSettingNodes[1].maxRCPanelQueryRows.xmlText);
				}
				// TracerPanel
				if ( structKeyExists(DebuggerSettingNodes[1], "TracerPanel") ){
					debugPanelAttributeInsert(configStruct.debuggerSettings,"TracerPanel",DebuggerSettingNodes[1].TracerPanel.xmlAttributes);
				}
				// InfoPanel
				if ( structKeyExists(DebuggerSettingNodes[1], "InfoPanel") ){
					debugPanelAttributeInsert(configStruct.debuggerSettings,"InfoPanel",DebuggerSettingNodes[1].InfoPanel.xmlAttributes);
				}
				// CachePanel
				if ( structKeyExists(DebuggerSettingNodes[1], "CachePanel") ){
					debugPanelAttributeInsert(configStruct.debuggerSettings,"CachePanel",DebuggerSettingNodes[1].CachePanel.xmlAttributes);
				}
				// RCPanel
				if ( structKeyExists(DebuggerSettingNodes[1], "RCPanel") ){
					debugPanelAttributeInsert(configStruct.debuggerSettings,"RCPanel",DebuggerSettingNodes[1].RCPanel.xmlAttributes);
				}
				// ModulesPanel
				if ( structKeyExists(DebuggerSettingNodes[1], "ModulesPanel") ){
					debugPanelAttributeInsert(configStruct.debuggerSettings,"ModulesPanel",DebuggerSettingNodes[1].ModulesPanel.xmlAttributes);
				}							
			}
		</cfscript>
	</cffunction>		
	
	<!--- parseInterceptors --->
	<cffunction name="parseInterceptors" output="false" access="public" returntype="void" hint="Parse Interceptors">
		<cfargument name="xml" 		type="any" required="true" hint="The xml object"/>
		<cfargument name="config" 	type="struct" required="true" hint="The config struct"/>
		<cfargument name="isOverride" type="boolean" required="false" default="false" hint="Flag to denote if overriding or first time runner."/>
		<cfscript>
			var configStruct = arguments.config;
			var interceptorBase = "";
			var customInterceptionPoints = "";
			var interceptorNodes = "";
			var i=1;
			var j=1;
			var interceptorStruct = "";
			var tempProperty = "";
			var oUtil = getUtil();
			var oJSONUtil = getJSONUtil();
			
			//Search for Interceptors
			interceptorBase = XMLSearch(arguments.xml,"//Interceptors");
			
			if (NOT arguments.isOverride){
				// Interceptor Defaults.
				configStruct.interceptorConfig = structnew();
				configStruct.interceptorConfig.interceptors = arrayNew(1);
				configStruct.interceptorConfig.throwOnInvalidStates = false;
				configStruct.interceptorConfig.customInterceptionPoints = "";				
			}
			
			if( arrayLen(interceptorBase) ){
				// Invalid States
				if ( structKeyExists(interceptorBase[1].XMLAttributes, "throwOnInvalidStates") ){
					configStruct.interceptorConfig['throwOnInvalidStates'] = interceptorBase[1].XMLAttributes.throwOnInvalidStates;
				}
				
				// Custom Interception Points
				customInterceptionPoints = XMLSearch(arguments.xml,"//Interceptors/CustomInterceptionPoints");
				if( arraylen(customInterceptionPoints) ){
					configStruct.interceptorConfig.customInterceptionPoints = oUtil.placeHolderReplacer(Trim(customInterceptionPoints[1].XMLText),configStruct);
				}
				
				//Parse all Interceptor Nodes now.
				interceptorNodes = XMLSearch(arguments.xml,"//Interceptors/Interceptor");
				for (i=1; i lte ArrayLen(interceptorNodes); i=i+1){
					interceptorStruct = structnew();
					// get Class
					interceptorStruct.class = oUtil.placeHolderReplacer(Trim(interceptorNodes[i].XMLAttributes["class"]),configStruct);
					// get Name if found?
					interceptorStruct.name = listLast(interceptorStruct.class,".");
					if( structKeyExists(interceptorNodes[i].XMLAttributes,"name") ){
						interceptorStruct.name = interceptorNodes[i].XMLAttributes.name;
					}
					//Prepare Properties
					interceptorStruct.properties = structnew();
					//Parse Interceptor Properties
					if ( ArrayLen(interceptorNodes[i].XMLChildren) ){
						for(j=1; j lte ArrayLen(interceptorNodes[i].XMLChildren); j=j+1){
							//Property Complex Check
							tempProperty = oUtil.placeHolderReplacer(Trim( interceptorNodes[i].XMLChildren[j].XMLText ),configStruct);
							//Check for Complex Setup
							if( reFindNocase(instance.jsonRegex,tempProperty) ){
								interceptorStruct.properties[Trim(interceptorNodes[i].XMLChildren[j].XMLAttributes["name"])] = oJSONUtil.decode(replace(tempProperty,"'","""","all"));
							}
							else{
								interceptorStruct.properties[Trim(interceptorNodes[i].XMLChildren[j].XMLAttributes["name"])] = tempProperty;
							}
						}//end loop of properties
					}//end if no properties					
					//Add to Array
					ArrayAppend( configStruct.interceptorConfig.interceptors, interceptorStruct );
				}//end interceptor nodes				
			}
		</cfscript>
	</cffunction>
	
	<!--- parseLogBox --->
	<cffunction name="parseLogBox" output="false" access="public" returntype="void" hint="Parse LogBox">
		<cfargument name="xml" 		type="any" required="true" hint="The xml object"/>
		<cfargument name="config" 	type="struct" required="true" hint="The config struct"/>
		<cfargument name="isOverride" type="boolean" required="false" default="false" hint="Flag to denote if overriding or first time runner."/>
		<cfscript>
			var logboxXML 		 = xmlSearch(arguments.xml,"//LogBox");
			var logBoxConfig 	 = instance.controller.getLogBox().getConfig();
			var memento 		 = "";
			var prop 			 = "";
			var oUtil 		 	 = getUtil();
			var appRootPath 	 = instance.controller.getAppRootPath();
			var appMappingAsDots = "";
			var configCreatePath  = "config.LogBox";
			
			// Default
			if( NOT arguments.isOverride){
				arguments.config["LogBoxConfig"] = structnew();
			}
			
			if( arrayLen(logboxXML) ){
				// Reset the configuration
				logBoxConfig.reset();
				
				// Does configFile exists
				if( structKeyExists(logboxXML[1], "ConfigFile") ){
					// Load by file
					loadLogBoxByFile( logBoxConfig, oUtil.placeHolderReplacer(logBoxXML[1].configFile.xmlText,arguments.config));
				}
				else{
					// Parse and load new configuration data
					logBoxConfig.parseAndLoad(logboxXML[1]);
					// Get reference to do ${} replacements
					memento = logBoxConfig.getMemento();
					
					// Appender Replacements
					for( key in memento.appenders ){
						memento.appenders[key].class = oUtil.placeHolderReplacer(memento.appenders[key].class,arguments.config);
						//Appender properties
						for(prop in memento.appenders[key].properties){
							// ${} replacement
							memento.appenders[key].properties[prop] = oUtil.placeHolderReplacer(memento.appenders[key].properties[prop],arguments.config);
						}
					}
				}			
				
				//Store LogBox Configuration on settings
				arguments.config["LogBoxConfig"] = logBoxConfig.getMemento();		
			}
			// Check if LogBox.cfc exists in the config conventions and load it.
			else if( fileExists( appRootPath & "config/LogBox.cfc") ){
				loadLogBoxByConvention(logBoxConfig,arguments.config);
			}
		</cfscript>
	</cffunction>
	
	<!--- parseWireBox --->
	<cffunction name="parseWireBox" output="false" access="public" returntype="void" hint="Parse WireBox">
		<cfargument name="xml" 			type="any" 		required="true" hint="The xml object"/>
		<cfargument name="config" 		type="struct"	required="true" hint="The config struct"/>
		<cfargument name="isOverride" 	type="boolean" 	required="false" default="false" hint="Flag to denote if overriding or first time runner."/>
		<cfscript>
			var wireboxXML 		 = xmlSearch(arguments.xml,"//WireBox");
			
			// Default Config Structure
			if( NOT arguments.isOverride){
				arguments.config.wirebox 			= structnew();
				arguments.config.wirebox.enabled	= false;
				arguments.config.wirebox.binder		= "";
				arguments.config.wirebox.binderPath	= "";
				arguments.config.wirebox.singletonReload = false;
			}
			
			// XML Found
			if( arrayLen(wireboxXML) ){
				
				// Check if enabled is set else return
				if( NOT structKeyExists(wireboxXML[1],"Enabled") OR NOT wireboxXML[1].enabled ){
					return;
				}
				
				// Set wirebox enabled
				arguments.config.wirebox.enabled = true;
			
				// Binder Path exists?
				if( structKeyExists(wireboxXML[1], "Binder") ){
					arguments.config.wirebox.binderPath = wireboxXML[1].Binder;
				}
				// Check if WireBox.cfc exists in the config conventions, if so create binder
				else if( fileExists( instance.controller.getAppRootPath() & "config/WireBox.cfc") ){
					arguments.config.wirebox.binderPath = "config.WireBox";
					if( len(arguments.config.appMapping) ){
						arguments.config.wirebox.binderPath = arguments.config.appMapping & ".#arguments.config.wirebox.binderPath#";
					}
				} 
				
				// Singleton reload
				if( structKeyExists(wireboxXML[1],"SingletonReload") ){ 
					arguments.config.wirebox.singletonReload = wireboxXML[1].singletonReload;
				}	
			}
		</cfscript>
	</cffunction>
	
	<!--- parseModules --->
	<cffunction name="parseModules" output="false" access="public" returntype="void" hint="Parse Module Settings">
		<cfargument name="xml" 		  type="any"     required="true" hint="The xml object"/>
		<cfargument name="config" 	  type="struct"  required="true" hint="The config struct"/>
		<cfargument name="isOverride" type="boolean" required="false" default="false" hint="Flag to denote if overriding or first time runner."/>
		<cfscript>
			var configStruct  = arguments.config;
			// Module Settings
			var moduleSettingsNodes = XMLSearch(arguments.xml,"//Modules");
			
			// Defaults if not overriding from global framework settings
			if (NOT arguments.isOverride){
				// Defaults
				configStruct.ModulesAutoReload  = false;
				configStruct.ModulesInclude		= arrayNew(1);
				configStruct.ModulesExclude		= arrayNew(1);
				configStruct.Modules 			= structNew();
			}
			
			//Check if empty
			if ( ArrayLen(moduleSettingsNodes) gt 0 and ArrayLen(moduleSettingsNodes[1].XMLChildren) gt 0){
				//Checks For AutoReload
				if ( structKeyExists(moduleSettingsNodes[1], "AutoReload") ){
					configStruct.modulesAutoReload = trim(moduleSettingsNodes[1].AutoReload.xmlText);
				}
				//Checks For Include
				if ( structKeyExists(moduleSettingsNodes[1], "Include") ){
					configStruct.modulesInclude = trim(moduleSettingsNodes[1].Include.xmlText);
					if( isSimpleValue(configStruct.modulesInclude) ){
						configStruct.modulesInclude = listToArray( configStruct.modulesInclude );
					}
				}
				//Checks For Exclude
				if ( structKeyExists(moduleSettingsNodes[1], "Exclude") ){
					configStruct.modulesExclude = trim(moduleSettingsNodes[1].Exclude.xmlText);
					if( isSimpleValue(configStruct.modulesExclude) ){
						configStruct.modulesExclude = listToArray( configStruct.modulesExclude );
					}
				}
			}						
		</cfscript>
	</cffunction>	
	
	<!--- JSON REGEX --->
	<cffunction name="getJSONRegex" access="public" returntype="string" output="false" hint="Get the json regex string">
		<cfreturn instance.jsonRegex>
	</cffunction>
	
	<!--- getJSONUtil --->
	<cffunction name="getJSONUtil" access="public" output="false" returntype="coldbox.system.core.conversion.JSON" hint="Create and return a util object for JSON">
		<cfreturn instance.jsonUtil/>
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

</cfcomponent>