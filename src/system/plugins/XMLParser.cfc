<!-----------------------------------------------------------------------
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
----------------------------------------------------------------------->
<cfcomponent name="XMLParser"
			 hint="This is the XML Parser plugin for the framework. It takes care of any XML parsing for the framework's usage."
			 extends="coldbox.system.plugin">

	<!--- ************************************************************* --->
	<cffunction name="init" access="public" returntype="any" output="false">
		<cfargument name="controller" required="yes" hint="The reference to the framework controller">
		<!---- Constructor --->
		<cfscript>
		super.init(arguments.controller);
		//Search Patterns for Config.xml
		variables.searchSettings = "//Settings/Setting";
		variables.searchYourSettings = "//YourSettings/Setting";
		variables.searchBugTracer = "//BugTracerReports/BugEmail";
		variables.searchDevURLS = "//DevEnvironments/url";
		variables.searchWS = "//WebServices/WebService";
		variables.searchDatasources = "//Datasources/Datasource";
		variables.searchLayouts = "//Layouts/Layout";
		variables.searchDefaultLayout = "//Layouts/DefaultLayout";
		variables.searchMailSettings = "//MailServerSettings";
		variables.searchi18NSettings = "//i18N";
		//Search patterns for fw xml
		variables.searchConfigXML_Path = "//ConfigXMLFile/FilePath";
		//Properties
		variables.FileSeparator = CreateObject("component","fileUtilities").getOSFileSeparator();
		variables.FrameworkConfigFile = "#getDirectoryFromPath(controller.getCurrentPath())#config#variables.FileSeparator#settings.xml";
		variables.FrameworkConfigXSDFile = "#getDirectoryFromPath(controller.getCurrentPath())#config#variables.FileSeparator#config.xsd";
		//Return
		return this;
		</cfscript>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="loadFramework" access="public" hint="Load the framework's configuration xml." output="false" returntype="any">
		<cfscript>
		var settingsStruct = StructNew();
		var FrameworkParent = "";
		var childApp = false;
		var distanceToParent = 0;
		var distanceString = "";
		var fwXML = "";
		var SettingNodes = "";
		var ConfigXMLFilePath = "";
		var ParentAppPath = "";
		try{
			//verify File
			if ( not fileExists(variables.FrameworkConfigFile) ){
				throw("Error finding settings.xml configuration file. The file #variables.FrameworkConfigFile# cannot be found.","","Framework.plugins.XMLParser.ColdBoxSettingsNotFoundException");
			}
			//Determine which CF version for XML Parsing method
			if (listfirst(server.coldfusion.productversion) lt 7){
				fwXML = xmlParse(getPlugin("fileutilities").readFile(variables.FrameworkCOnfigFile));
			}
			else{
				//get XML
				fwXML = xmlParse(variables.FrameworkConfigFile);
			}
			//Get SettingNodes
			SettingNodes = XMLSearch(fwXML, variables.searchSettings);
			//Insert Settings to Config Struct
			for (i=1; i lte ArrayLen(SettingNodes); i=i+1)
				StructInsert( settingsStruct, SettingNodes[i].XMLAttributes["name"], trim(SettingNodes[i].XMLAttributes["value"]));
			//OS File Separator
			StructInsert(settingsStruct, "OSFileSeparator", variables.FileSeparator );
			//Get Config XML File Settings
			ConfigXMLFilePath = XMLSearch(fwXML, variables.searchConfigXML_Path);
			ConfigXMLFilePath = ExpandPath(replace(ConfigXMLFilePath[1].XMLText, "{sep}", variables.FileSeparator,"all"));
			StructInsert(settingsStruct, "ConfigFileLocation", ConfigXMLFilePath);
			//Schema Path
			StructInsert(settingsStruct, "ConfigFileSchemaLocation", variables.FrameworkConfigXSDFile);
			//Parent Application Path
			StructInsert(settingsStruct, "ApplicationPath", ExpandPath("."));
			//Load Framework Path too
			StructInsert(settingsStruct, "FrameworkPath", getDirectoryFromPath(controller.getCurrentPath()) );
			//Load Plugins Path
			StructInsert(settingsStruct, "FrameworkPluginsPath", settingsStruct.FrameworkPath & variables.FileSeparator & "plugins");
			//Verify if Child app or not
			FrameworkParent = getDirectoryFromPath(controller.getCurrentPath());
			FrameworkParent = ListDeleteAt(FrameworkParent, ListLen(FrameworkParent,variables.FileSeparator), variables.FileSeparator);
			if ( FrameworkParent neq settingsStruct.ApplicationPath)
				childApp = true;
			//Insert into Structure.
			StructInsert(settingsStruct, "ChildApp", childApp);
			//Calculate the distance to the parent
			distanceToParent = listlen(replacenocase(settingsStruct.ApplicationPath, FrameworkParent,""), variables.FileSeparator);
			//Get Distance String
			for (i = 1; i lte distanceToParent; i=i+1)
				distanceString = distanceString & "../";
			//Insert into Structure.
			StructInsert(settingsStruct, "DistanceToParent", distanceToParent);
			StructInsert(settingsStruct, "DistanceString", distanceString);
			//Get Directory of Parent Application
			ParentAppPath = ExpandPath(distanceString);
			StructInsert(settingsStruct, "ParentAppPath", ParentAppPath);
			//Set the complete modifylog path
			settingsStruct.ModifyLogLocation = "#getDirectoryFromPath(controller.getCurrentPath())#config#variables.FileSeparator#readme.txt";
			return settingsStruct;
		}//end of try
		catch( Any Exception ){
			throw("Error Loading Framework Configuration.<br>#Exception.Message# & #Exception.Detail#","","Framework.plugins.XMLParser.ColdboxSettingsParsingException");
		}
		</cfscript>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="parseConfig" access="public" returntype="struct" output="false">
		<cfscript>
		//Create Config Structure
		var ConfigStruct = StructNew();
		var ConfigFileLocation = getSetting("ConfigFileLocation", true);
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
		var LayoutNodes = "";
		var DefaultLayout = "";
		var	LayoutViewStruct = StructNew();
		//DevEnvironments
		var DevEnvironmentNodes = "";
		var DevEnvironmentArray = ArrayNew(1);
		//Datasources.
		var DatasourcesNodes = "";
		var DSNStruct = StructNew();
		var DatasourcesStruct = Structnew();
		//loopers
		var i = 0;
		var j = 0;
		try{
			//Validate File
			if ( not fileExists(ConfigFileLocation) ){
				throw("The Config File: #ConfigFileLocation# can't be found.","","Framework.plugins.XMLParser.ConfigXMLFileNotFoundException");
			}
			//Determine which CF version for XML Parsing method
			if (listfirst(server.coldfusion.productversion) lt 7){
				configXML = xmlParse(getPlugin("fileutilities").readFile(ConfigFileLocation));
			}
			else{
				//Parse XML and validate with XSD
				configXML = xmlParse(ConfigFileLocation);
			}
			//validate
			if ( not structKeyExists(configXML, "config")  )
				throw("No Config element found in the configuration file","","Framework.plugins.XMLParser.ConfigXMLParsingException");
			//Get SettingNodes
			SettingNodes = XMLSearch(configXML, variables.searchSettings);
			if ( ArrayLen(SettingNodes) eq 0 )
				throw("No Setting elements could be found in the configuration file.","","Framework.plugins.XMLParser.ConfigXMLParsingException");
			//Insert Settings to Config Struct
			for (i=1; i lte ArrayLen(SettingNodes); i=i+1)
				StructInsert( ConfigStruct, SettingNodes[i].XMLAttributes["name"], trim(SettingNodes[i].XMLAttributes["value"]));
			//Check for AppName or throw
			if ( not StructKeyExists(ConfigStruct, "AppName") )
				throw("There was no 'AppName' setting defined. This is required by the framework.","","Framework.plugins.XMLParser.ConfigXMLParsingException");
			//Check For CFMapping or Throw
			if ( not StructKeyExists(ConfigStruct, "AppCFMXMapping") )
				throw("There was no 'AppCFMXMapping' setting defined. This is required by the framework.","","Framework.plugins.XMLParser.ConfigXMLParsingException");
			//Conver . to / in the CFMX Mapping
			ConfigStruct["AppCFMXMapping"] = replace(ConfigStruct["AppCFMXMapping"],".","/","all");
			//Check for Default Event
			if ( not StructKeyExists(ConfigStruct, "DefaultEvent") )
				throw("There was no 'DefaultEvent' setting defined. This is required by the framework.","","Framework.plugins.XMLParser.ConfigXMLParsingException");
			//Check for Request Start Handler
			if ( not StructKeyExists(ConfigStruct, "ApplicationStartHandler") )
				ConfigStruct["ApplicationStartHandler"] = "";
			//Check for Request End Handler
			if ( not StructKeyExists(ConfigStruct, "RequestStartHandler") )
				ConfigStruct["RequestStartHandler"] = "";
			//Check for Application Start Handler
			if ( not StructKeyExists(ConfigStruct, "RequestEndHandler") )
				ConfigStruct["RequestEndHandler"] = "";
			//Check For DebugMode in settings
			if ( not structKeyExists(ConfigStruct, "DebugMode") or not isBoolean(ConfigStruct.DebugMode) )
				ConfigStruct["DebugMode"] = "false";
			//Check for DebugPassword in settings, else leave blank.
			if ( not structKeyExists(ConfigStruct, "DebugPassword"))
				ConfigStruct["DebugPassword"] = "";
			//Check For Coldfusion Logging
			if ( not structKeyExists(ConfigStruct, "ColdfusionLogging") or not isBoolean(ConfigStruct.ColdfusionLogging) )
				ConfigStruct["ColdfusionLogging"] = "true";
			//Check For Coldbox Log Location
			if ( not structKeyExists(ConfigStruct, "ColdboxLogsLocation"))
				ConfigStruct["ColdboxLogsLocation"] = "";				
			//Check For Owner Email or Throw
			if ( not StructKeyExists(ConfigStruct, "OwnerEmail") )
				throw("There was no 'OwnerEmail' setting defined. This is required by the framework.","","Framework.plugins.XMLParser.ConfigXMLParsingException");
			//Check For Dumpvar Active or set to true
			if ( not StructKeyExists(ConfigStruct, "DumpVarActive") or not isBoolean(ConfigStruct.DumpVarActive))
				ConfigStruct["DumpVarActive"] = "true";
			//Check For EnableBugReports Active or set to true
			if ( not StructKeyExists(ConfigStruct, "EnableBugReports") or not isBoolean(ConfigStruct.EnableBugReports))
				ConfigStruct["EnableBugReports"] = "true";
			//Check For UDFLibraryFile
			if ( not StructKeyExists(ConfigStruct, "UDFLibraryFile") )
				ConfigStruct["UDFLibraryFile"] = "";
			//Check For CustomErrorTemplate Active or set to true
			if ( not StructKeyExists(ConfigStruct, "CustomErrorTemplate") )
				ConfigStruct["CustomErrorTemplate"] = "";
			//Check for MessageboxStyleClass if found
			if ( not structkeyExists(ConfigStruct, "MessageboxStyleClass") )
				ConfigStruct["MessageboxStyleClass"] = "";
			//Check for HandlersIndexAutoReload, default = false
			if ( not structkeyExists(ConfigStruct, "HandlersIndexAutoReload") or not isBoolean(ConfigStruct.HandlersIndexAutoReload) )
				ConfigStruct["HandlersIndexAutoReload"] = false;
			//Check for ConfigAutoReload
			if ( not structKeyExists(ConfigStruct, "ConfigAutoReload") or not isBoolean(ConfigStruct.ConfigAutoReload) )
				ConfigStruct["ConfigAutoReload"] = false;
			//Check for MessageboxStyleClass if found
			if ( not structkeyExists(ConfigStruct, "ExceptionHandler") )
				ConfigStruct["ExceptionHandler"] = "";

			//Your Settings To Load
			YourSettingNodes = XMLSearch(configXML, variables.searchYourSettings);
			if ( ArrayLen(YourSettingNodes) gt 0 ){
				//Insert Your Settings to Config Struct
				for (i=1; i lte ArrayLen(YourSettingNodes); i=i+1)
				StructInsert( ConfigStruct, YourSettingNodes[i].XMLAttributes["name"], trim(YourSettingNodes[i].XMLAttributes["value"]));
			}

			//Mail Settings
			MailSettingsNodes = XMLSearch(configXML, variables.searchMailSettings);
			//Check if empty
			if ( ArrayLen(MailSettingsNodes) gt 0 and ArrayLen(MailSettingsNodes[1].XMLChildren) gt 0){
				//Parse Mail Settings
				for (i=1; i lte ArrayLen(MailSettingsNodes[1].XMLChildren); i=i+1){
					StructInsert(ConfigStruct, trim(MailSettingsNodes[1].XMLChildren[i].XMLName),trim(MailSettingsNodes[1].XMLChildren[i].XMLText));
				}
			}
			else{
				StructInsert(ConfigStruct,"MailServer","");
				StructInsert(ConfigStruct,"MailUsername","");
				StructInsert(ConfigStruct,"MailPassword","");
			}

			//i18N Settings
			i18NSettingNodes = XMLSearch(configXML, variables.searchi18NSettings);
			//Check if empty
			if ( ArrayLen(i18NSettingNodes) gt 0 and ArrayLen(i18NSettingNodes[1].XMLChildren) gt 0){
				//Parse i18N Settings
				for (i=1; i lte ArrayLen(i18NSettingNodes[1].XMLChildren); i=i+1){
					if ( len(trim(i18NSettingNodes[1].XMLChildren[i].XMLText)) eq 0 ){
						throw("The i18N setting: #i18NSettingNodes[1].XMLChildren[i].XMLName# cannot be left blank.","","Framework.plugins.XMLParser.ConfigXMLParsingException");
					}
					if ( i18NSettingNodes[1].XMLChildren[i].XMLName eq "DefaultResourceBundle" ){
						i18NSettingNodes[1].XMLChildren[i].XMLText = expandPath(trim(i18NSettingNodes[1].XMLChildren[i].XMLText));
					}
					//Check Local Syntax.
					if ( i18NSettingNodes[1].XMLChildren[i].XMLName eq "DefaultLocale" ){
						DefaultLocale = trim(i18NSettingNodes[1].XMLChildren[i].XMLText);
						if ( not listlen( DefaultLocale, "_") is 2 or
							 not len(listFirst(DefaultLocale,"_")) is 2 or
				 			 not len(listLast(DefaultLocale,"_")) is 2 ){
				 			 throw("Invalid Locale Syntax found. Please re-check your config.xml DefaultLocale i18N Setting: #defaultLocale# is an invalid locale syntax. ex: en_US","","Framework.plugins.XMLParser.ConfigXMLParsingException");
				 		}
				 		//set the right syntax just in case.
				 		i18NSettingNodes[1].XMLChildren[i].XMLText = lcase(listFirst(DefaultLocale,"_")) & "_" & ucase(listLast(DefaultLocale,"_"));
					}
					//Insert to structure.
					StructInsert(ConfigStruct, trim(i18NSettingNodes[1].XMLChildren[i].XMLName),trim(i18NSettingNodes[1].XMLChildren[i].XMLText));
				}
				//set i18n
				StructInsert(ConfigStruct,"using_i18N",true);
			}
			else{
				StructInsert(ConfigStruct,"DefaultResourceBundle","");
				StructInsert(ConfigStruct,"DefaultLocale","");
				StructInsert(ConfigStruct,"LocaleStorage","");
				StructInsert(ConfigStruct,"using_i18N",false);
			}

			//Bug Tracer Reports
			BugEmailNodes = XMLSearch(configXML, variables.searchBugTracer);
			for (i=1; i lte ArrayLen(BugEmailNodes); i=i+1){
				BugEmails = BugEmails & trim(BugEmailNodes[i].XMLText);
				if ( i neq ArrayLen(BugEmailNodes) )
					BugEmails = BugEmails & ",";
			}
			//Insert Into Config
			StructInsert(ConfigStruct, "BugEmails", BugEmails);

			//Get Dev Environments
			DevEnvironmentNodes = XMLSearch(configXML, variables.searchDevURLS);
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

			//Get Web Services From Config.
			WebServiceNodes = XMLSearch(configXML, variables.searchWS);
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
			
			//Datasources Support
			DatasourcesNodes = XMLSearch(configXML, variables.searchDatasources);
			if ( ArrayLen(DatasourcesNodes) ){
				//Create Structures
				for(i=1;i lte ArrayLen(DatasourcesNodes); i=i+1){
					DSNStruct = structNew();
					StructInsert(DSNStruct,"Name", Trim(DatasourcesNodes[i].XMLAttributes["name"]));
					StructInsert(DSNStruct,"DBType", Trim(DatasourcesNodes[i].XMLAttributes["dbtype"]));
					StructInsert(DSNStruct,"Username", Trim(DatasourcesNodes[i].XMLAttributes["username"]));
					StructInsert(DSNStruct,"Password", Trim(DatasourcesNodes[i].XMLAttributes["password"]));
					//Insert to structure
					if ( not structKeyExists(DatasourcesStruct,DSNStruct.name) )
						StructInsert(DatasourcesStruct, DSNStruct.name , DSNStruct);
					else
						throw("The datasource name: #dsnStruct.name# has already been declared.","","Framework.plugins.XMLParser.ConfigXMLParsingException");
				}
			}
			StructInsert(ConfigStruct, "Datasources", DatasourcesStruct);
			
			//Layout into Config
			DefaultLayout = XMLSearch(configXML,variables.searchDefaultLayout);
			//validate Default Layout.
			if ( ArrayLen(DefaultLayout) eq 0 )
				throw("There was no default layout element found.","","Framework.plugins.XMLParser.ConfigXMLParsingException");
			if ( ArrayLen(DefaultLayout) gt 1 )
				throw("There were more than 1 DefaultLayout elements found. There can only be one.","","Framework.plugins.XMLParser.ConfigXMLParsingException");
			StructInsert(ConfigStruct,"DefaultLayout",Trim(DefaultLayout[1].XMLText));
			//Get View Layouts
			LayoutNodes = XMLSearch(configXML, variables.searchLayouts);
			for (i=1; i lte ArrayLen(LayoutNodes); i=i+1){
				//Get Layout for the views
				Layout = Trim(LayoutNodes[i].XMLAttributes["file"]);
				for(j=1; j lte ArrayLen(LayoutNodes[i].XMLChildren); j=j+1){
					//Check for Key
					if ( not StructKeyExists(LayoutViewStruct, Trim(LayoutNodes[i].XMLChildren[j].XMLText)) )
						StructInsert(LayoutViewStruct, Trim(LayoutNodes[i].XMLChildren[j].XMLText),Layout);
				}
			}
			StructInsert(ConfigStruct,"ViewLayouts",LayoutViewStruct);
			StructInsert(ConfigStruct, "ConfigTimeStamp", getPlugin("fileUtilities").FileLastModified(ConfigFileLocation));

			//Determine which CF version for XML Parsing method
			if (listfirst(server.coldfusion.productversion) gte 7){
				//Finally Validate With XSD
				if ( not XMLValidate(configXML, getSetting("ConfigFileSchemaLocation", true)).status )
					throw("<br>The config.xml file does not validate with the framework's schema.<br>You can find the config schema <a href='/coldbox/system/config/#GetFileFromPath(getSetting("ConfigFileSchemaLocation", 1))#'>here</a>","","Framework.plugins.XMLParser.ConfigXMLParsingException");
			}
		}//end of try
		catch( Any Exception ){
			throw("#Exception.Message# & #Exception.Detail#","","Framework.plugins.XMLParser.ConfigXMLParsingException");
		}
		//finish
		return ConfigStruct;
		</cfscript>
	</cffunction>
	<!--- ************************************************************* --->

</cfcomponent>