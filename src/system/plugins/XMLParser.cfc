<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
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

	<cffunction name="init" access="public" returntype="coldbox.system.plugin" output="false">
		<cfargument name="controller" type="any" required="true">
		<cfset super.Init(arguments.controller) />
		<cfscript>
		//Local Plugin Definition
		setpluginName("XMLParser");
		setpluginVersion("2.0");
		setpluginDescription("I am the framework's XML parser");

		//Search Patterns for Config.xml
		variables.instance.searchSettings = "//Settings/Setting";
		variables.instance.searchYourSettings = "//YourSettings/Setting";
		variables.instance.searchBugTracer = "//BugTracerReports/BugEmail";
		variables.instance.searchDevURLS = "//DevEnvironments/url";
		variables.instance.searchWS = "//WebServices/WebService";
		variables.instance.searchLayouts = "//Layouts/Layout";
		variables.instance.searchDefaultLayout = "//Layouts/DefaultLayout";
		variables.instance.searchMailSettings = "//MailServerSettings";
		variables.instance.searchi18NSettings = "//i18N";
		variables.instance.searchDatasources = "//Datasources/Datasource";
		variables.instance.searchCache = "//Cache";

		//Search patterns for fw xml
		variables.instance.searchConfigXML_Path = "//ConfigXMLFile/FilePath";

		//Properties
		variables.instance.FileSeparator = createObject("java","java.lang.System").getProperty("file.separator");
		variables.instance.FrameworkConfigFile = ExpandPath("/coldbox/system/config/settings.xml");
		variables.instance.FrameworkConfigXSDFile = ExpandPath("/coldbox/system/config/config.xsd");
		//Return
		return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<cffunction name="loadFramework" access="public" hint="Load the framework's configuration xml." output="false" returntype="any">
		<cfscript>
		var settingsStruct = StructNew();
		var FrameworkParent = "";
		var distanceToParent = 0;
		var distanceString = "";
		var fwXML = "";
		var SettingNodes = "";
		var ConfigXMLFilePath = "";
		var ParentAppPath = "";
		try{
			//verify Framework settings File
			if ( not fileExists(instance.FrameworkConfigFile) ){
				throw("Error finding settings.xml configuration file. The file #instance.FrameworkConfigFile# cannot be found.","","Framework.plugins.XMLParser.ColdBoxSettingsNotFoundException");
			}
			//Determine which CF version for XML Parsing method
			if (listfirst(server.coldfusion.productversion) lt 7){
				fwXML = xmlParse(getPlugin("fileutilities").readFile(instance.FrameworkConfigFile,false,"utf-8"));
			}
			else{
				//get XML for CFMX version 7 and above.
				fwXML = xmlParse(instance.FrameworkConfigFile);
			}
			//Get SettingNodes
			SettingNodes = XMLSearch(fwXML, instance.searchSettings);
			//Insert Settings to Config Struct
			for (i=1; i lte ArrayLen(SettingNodes); i=i+1)
				StructInsert( settingsStruct, SettingNodes[i].XMLAttributes["name"], trim(SettingNodes[i].XMLAttributes["value"]));
			//OS File Separator
			StructInsert(settingsStruct, "OSFileSeparator", instance.FileSeparator );
			//Get Config XML File Settings
			ConfigXMLFilePath = XMLSearch(fwXML, instance.searchConfigXML_Path);
			ConfigXMLFilePath = ExpandPath(replace(ConfigXMLFilePath[1].XMLText, "{sep}", instance.FileSeparator,"all"));
			StructInsert(settingsStruct, "ConfigFileLocation", ConfigXMLFilePath);
			//Schema Path
			StructInsert(settingsStruct, "ConfigFileSchemaLocation", instance.FrameworkConfigXSDFile);
			//Parent Application Path
			StructInsert(settingsStruct, "ApplicationPath", ExpandPath("."));
			//Load Framework Path too
			StructInsert(settingsStruct, "FrameworkPath", ExpandPath("/coldbox/system") & instance.FileSeparator );
			//Load Plugins Path
			StructInsert(settingsStruct, "FrameworkPluginsPath", settingsStruct.FrameworkPath & "plugins");
			//Set the complete modifylog path
			settingsStruct.ModifyLogLocation = "#settingsStruct.FrameworkPath#config#instance.FileSeparator#readme.txt";
			return settingsStruct;
		}//end of try
		catch( Any Exception ){
			throw("Error Loading Framework Configuration.","#Exception.Message# #Exception.Detail#","Framework.plugins.XMLParser.ColdboxSettingsParsingException");
		}
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="parseConfig" access="public" returntype="struct" output="false">
		<cfscript>
		//Create Config Structure
		var ConfigStruct = StructNew();
		var ConfigFileLocation = getController().getSetting("ConfigFileLocation", true);
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
		//Cache
		var CacheSettingNodes = "";
		//loopers
		var i = 0;
		var j = 0;
		//Appmapping Variables
		var webPath = "";
		var localPath = "";
		var PathLocation = "";
		//Testers
		var tester = "";
		try{
			//Validate File
			if ( not fileExists(ConfigFileLocation) ){
				throw("The Config File: #ConfigFileLocation# can't be found.","","Framework.plugins.XMLParser.ConfigXMLFileNotFoundException");
			}
			//Determine which CF version for XML Parsing method
			if (listfirst(server.coldfusion.productversion) lt 7){
				configXML = xmlParse(getPlugin("fileutilities").readFile(ConfigFileLocation,false,"utf-8"));
			}
			else{
				//Parse XML and validate with XSD
				configXML = xmlParse(ConfigFileLocation);
			}

			//validate
			if ( not structKeyExists(configXML, "config")  )
				throw("No Config element found in the configuration file","","Framework.plugins.XMLParser.ConfigXMLParsingException");

			//Application Path
			StructInsert(ConfigStruct, "ApplicationPath", ExpandPath("."));

			//Get SettingNodes
			SettingNodes = XMLSearch(configXML, instance.searchSettings);
			if ( ArrayLen(SettingNodes) eq 0 )
				throw("No Setting elements could be found in the configuration file.","","Framework.plugins.XMLParser.ConfigXMLParsingException");
			//Insert Settings to Config Struct
			for (i=1; i lte ArrayLen(SettingNodes); i=i+1)
				StructInsert( ConfigStruct, SettingNodes[i].XMLAttributes["name"], trim(SettingNodes[i].XMLAttributes["value"]));
			//Check for AppName or throw
			if ( not StructKeyExists(ConfigStruct, "AppName") )
				throw("There was no 'AppName' setting defined. This is required by the framework.","","Framework.plugins.XMLParser.ConfigXMLParsingException");

			//Calculate AppMapping if not set in the config, else auto-calculate
			if ( not structKeyExists(ConfigStruct, "AppMapping") ){
				webPath = replacenocase(cgi.script_name,getFIleFromPath(cgi.script_name),"");
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
			}

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

			//Check For Owner Email or Throw
			if ( not StructKeyExists(ConfigStruct, "OwnerEmail") )
				throw("There was no 'OwnerEmail' setting defined. This is required by the framework.","","Framework.plugins.XMLParser.ConfigXMLParsingException");
			//Check For EnableDumpvar or set to true
			if ( not StructKeyExists(ConfigStruct, "EnableDumpVar") or not isBoolean(ConfigStruct.EnableDumpVar))
				ConfigStruct["EnableDumpVar"] = "true";
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

			//Check for MyPluginsLocation if found
			if ( not structkeyExists(ConfigStruct, "MyPluginsLocation") )
				ConfigStruct["MyPluginsLocation"] = "";

			//Check for Handler Caching
			if ( not structKeyExists(ConfigStruct, "HandlerCaching") or not isBoolean(ConfigStruct.HandlerCaching) )
				ConfigStruct["HandlerCaching"] = true;

			//Check for IOC Framework
			if ( not structKeyExists(ConfigStruct, "IOCFramework") )
				ConfigStruct["IOCFramework"] = "";
			if ( not structKeyExists(ConfigStruct, "IOCDefinitionFile") )
				ConfigStruct["IOCDefinitionFile"] = "";
			if ( not structKeyExists(ConfigStruct, "IOCObjectCaching") )
				ConfigStruct["IOCObjectCaching"] = false;

			//Your Settings To Load
			YourSettingNodes = XMLSearch(configXML, instance.searchYourSettings);
			if ( ArrayLen(YourSettingNodes) gt 0 ){
				//Insert Your Settings to Config Struct
				for (i=1; i lte ArrayLen(YourSettingNodes); i=i+1){
					tester = trim(YourSettingNodes[i].XMLAttributes["value"]);
					//Test for Array
					if ( left(tester,1) eq "[" and right(tester,1) eq "]"){
						StructInsert(ConfigStruct, YourSettingNodes[i].XMLAttributes["name"], createArray(tester) );
					}
					else if ( left(tester,1) eq "{" and right(tester,1) eq "}"){
						StructInsert(ConfigStruct, YourSettingNodes[i].XMLAttributes["name"], createStruct(tester) );
					}
					else
						StructInsert( ConfigStruct, YourSettingNodes[i].XMLAttributes["name"], tester);
				}
			}

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

			//i18N Settings
			i18NSettingNodes = XMLSearch(configXML, instance.searchi18NSettings);
			//Check if empty
			if ( ArrayLen(i18NSettingNodes) gt 0 and ArrayLen(i18NSettingNodes[1].XMLChildren) gt 0){
				//Parse i18N Settings
				for (i=1; i lte ArrayLen(i18NSettingNodes[1].XMLChildren); i=i+1){

					//Set the Resource Bundle if Using it.
					if ( i18NSettingNodes[1].XMLChildren[i].XMLName eq "DefaultResourceBundle" and len(trim(i18NSettingNodes[1].XMLChildren[i].XMLText)) neq 0 ){
						i18NSettingNodes[1].XMLChildren[i].XMLText = expandPath(trim(i18NSettingNodes[1].XMLChildren[i].XMLText));
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
				//Check if resource bundle was used.
				if ( not structKeyExists(ConfigStruct, "DefaultResourceBundle") ){
					StructInsert(ConfigStruct,"DefaultResourceBundle","");
				}
			}
			else{
				StructInsert(ConfigStruct,"DefaultResourceBundle","");
				StructInsert(ConfigStruct,"DefaultLocale","");
				StructInsert(ConfigStruct,"LocaleStorage","");
				StructInsert(ConfigStruct,"using_i18N",false);
			}

			//Bug Tracer Reports
			BugEmailNodes = XMLSearch(configXML, instance.searchBugTracer);
			for (i=1; i lte ArrayLen(BugEmailNodes); i=i+1){
				BugEmails = BugEmails & trim(BugEmailNodes[i].XMLText);
				if ( i neq ArrayLen(BugEmailNodes) )
					BugEmails = BugEmails & ",";
			}
			//Insert Into Config
			StructInsert(ConfigStruct, "BugEmails", BugEmails);

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

			//Set the Handler Invocation & Physical Path for this Application
			if( ConfigStruct["AppMapping"] neq ""){
				//Parse out the first / to create handler invocation Path
				if ( left(ConfigStruct["AppMapping"],1) eq "/" ){
					ConfigStruct["AppMapping"] = removeChars(ConfigStruct["AppMapping"],1,1);
				}
				//Set the handler Invocation Path
				ConfigStruct["HandlersInvocationPath"] = replace(ConfigStruct["AppMapping"],"/",".","all") & ".handlers";

				//Set the Default Handler Path
				ConfigStruct["HandlersPath"] = ConfigStruct["AppMapping"];

				//Set the physical path according to system.
				//Test for CF 6.X
				if ( listfirst(server.coldfusion.productversion) lt 7 ){
					ConfigStruct["HandlersPath"] = replacenocase(cgi.SCRIPT_NAME, listlast(cgi.SCRIPT_NAME,"/"),"") & "handlers";
				}
				else{
					ConfigStruct["HandlersPath"] = "/" & ConfigStruct["HandlersPath"] & "/handlers";
				}
				//Set the Handlerspath expanded.
				ConfigStruct["HandlersPath"] = ExpandPath(ConfigStruct["HandlersPath"]);
			}
			else{
				ConfigStruct["HandlersInvocationPath"] = "handlers";
				ConfigStruct["HandlersPath"] = expandPath("handlers");
			}

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

			//Datasources Support
			DatasourcesNodes = XMLSearch(configXML, instance.searchDatasources);
			if ( ArrayLen(DatasourcesNodes) ){
				//Create Structures
				for(i=1;i lte ArrayLen(DatasourcesNodes); i=i+1){
					DSNStruct = structNew();

					//Required Entries
					if ( not structKeyExists(DatasourcesNodes[i].XMLAttributes, "Alias") or len(Trim(DatasourcesNodes[i].XMLAttributes["Alias"])) eq 0 )
						throw("This datasource entry's alias cannot be blank","","Framework.plugins.XMLParser.ConfigXMLParsingException");
					else
						StructInsert(DSNStruct,"Alias", Trim(DatasourcesNodes[i].XMLAttributes["Alias"]));
					if ( not structKeyExists(DatasourcesNodes[i].XMLAttributes, "Name") or len(Trim(DatasourcesNodes[i].XMLAttributes["Name"])) eq 0 )
						throw("This datasource entry's name cannot be blank","","Framework.plugins.XMLParser.ConfigXMLParsingException");
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
						throw("The datasource alias: #dsnStruct.Alias# has already been declared.","","Framework.plugins.XMLParser.ConfigXMLParsingException");
				}
			}
			StructInsert(ConfigStruct, "Datasources", DatasourcesStruct);

			//Layout into Config
			DefaultLayout = XMLSearch(configXML,instance.searchDefaultLayout);
			//validate Default Layout.
			if ( ArrayLen(DefaultLayout) eq 0 )
				throw("There was no default layout element found.","","Framework.plugins.XMLParser.ConfigXMLParsingException");
			if ( ArrayLen(DefaultLayout) gt 1 )
				throw("There were more than 1 DefaultLayout elements found. There can only be one.","","Framework.plugins.XMLParser.ConfigXMLParsingException");
			StructInsert(ConfigStruct,"DefaultLayout",Trim(DefaultLayout[1].XMLText));
			//Get View Layouts
			LayoutNodes = XMLSearch(configXML, instance.searchLayouts);
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
					throw("Invalid object timeout. Please see schema.","Value=#CacheSettingNodes[1].ObjectDefaultTimeout.xmlText#","Framework.plugins.XMLParser.InvalidCacheObjectDefaultTimeout");

				//Check ObjectDefaultLastAccessTimeout
				if ( structKeyExists(CacheSettingNodes[1], "ObjectDefaultLastAccessTimeout") and isNumeric(CacheSettingNodes[1].ObjectDefaultLastAccessTimeout.xmlText))
					StructInsert(ConfigStruct.CacheSettings, "ObjectDefaultLastAccessTimeout", trim(CacheSettingNodes[1].ObjectDefaultLastAccessTimeout.xmlText) );
				else
					throw("Invalid object last access timeout. Please see schema.","Value=#CacheSettingNodes[1].ObjectDefaultLastAccessTimeout.xmlText#","Framework.plugins.XMLParser.InvalidObjectDefaultLastAccessTimeout");

				//Check ReapFrequency
				if ( structKeyExists(CacheSettingNodes[1], "ReapFrequency") and isNumeric(CacheSettingNodes[1].ReapFrequency.xmlText))
					StructInsert(ConfigStruct.CacheSettings, "ReapFrequency", trim(CacheSettingNodes[1].ReapFrequency.xmlText) );
				else
					throw("Invalid reaping frequency. Please see schema.","Value=#CacheSettingNodes[1].ReapFrequency.xmlText#","Framework.plugins.XMLParser.InvalidReapFrequency");

				//Check MaxObjects
				if ( structKeyExists(CacheSettingNodes[1], "MaxObjects") and isNumeric(CacheSettingNodes[1].MaxObjects.xmlText)){
					StructInsert(ConfigStruct.CacheSettings, "MaxObjects", trim(CacheSettingNodes[1].MaxObjects.xmlText) );
				}
				else
					throw("Invalid Max Objects. Please see schema.","Value=#CacheSettingNodes[1].MaxObjects.xmlText#","Framework.plugins.XMLParser.InvalidMaxObjects");

				//Check FreeMemoryPercentageThreshold
				if ( structKeyExists(CacheSettingNodes[1], "FreeMemoryPercentageThreshold") and isNumeric(CacheSettingNodes[1].FreeMemoryPercentageThreshold.xmlText)){
					StructInsert(ConfigStruct.CacheSettings, "FreeMemoryPercentageThreshold", trim(CacheSettingNodes[1].FreeMemoryPercentageThreshold.xmlText) );
				}
				else
					throw("Invalid Free Memory Percentage Threshold. Please see schema.","Value=#CacheSettingNodes[1].FreeMemoryPercentageThreshold.xmlText#","Framework.plugins.XMLParser.InvalidFreeMemoryPercentageThreshold");


				//Set Override to true.
				ConfigStruct.CacheSettings.Override = true;
			}
			else{
				ConfigStruct.CacheSettings.Override = false;
			}


			//Determine which CF version for XML Parsing method
			if (listfirst(server.coldfusion.productversion) gte 7){
				//Finally Validate With XSD
				if ( not XMLValidate(configXML, getController().getSetting("ConfigFileSchemaLocation", true)).status )
					throw("<br>The config.xml file does not validate with the framework's schema.<br>You can find the config schema <a href='/coldbox/system/config/#GetFileFromPath(getController().getSetting("ConfigFileSchemaLocation", 1))#'>here</a>","","Framework.plugins.XMLParser.ConfigXMLParsingException");
			}
		}//end of try
		catch( Any Exception ){
			throw("#Exception.Message# & #Exception.Detail#","","Framework.plugins.XMLParser.ConfigXMLParsingException");
		}
		//finish
		return ConfigStruct;
		</cfscript>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->

	<cffunction name="createArray" access="private" returntype="array" hint="Create a setting Array">
		<cfargument name="setting" type="string" required="true" hint="The setting to create an array from">
		<!--- ************************************************************* --->
		<!--- Clean [] --->
		<cfset var cleanList = "">
		<cfset var i = 1>
		<cfset var cleanArray = ArrayNew(1)>
		<cfset cleanList = replace(replace(arguments.setting,"[","","all"),"]","","all")>
		<cfloop from="1" to="#listLen(cleanList)#" index="i">
			<cfset ArrayAppend(cleanArray,trim(listgetAt(cleanList,i)))>
		</cfloop>
		<!--- Create Array --->
		<cfreturn cleanArray>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="createStruct" access="private" returntype="struct" hint="Create a setting Structure">
		<cfargument name="setting" type="string" required="true" hint="The setting to create a struct from">
		<!--- ************************************************************* --->
		<!--- Clean {} --->
		<cfset var cleanList = "">
		<cfset var i = 1>
		<cfset var newStructure = structnew()>
		<cfset var structList = "">
		<cfset cleanList = replace(replace(arguments.setting,"{","","all"),"}","","all")>
		<!--- Loop Through list --->
		<cfloop from="1" to="#listlen(cleanList)#" index="i">
			<cfset structList = listgetAt(cleanList,i)>
			<cfset structInsert(newStructure, trim(getToken(structList,1,":")), trim(getToken(structList,2,":")) )>
		</cfloop>
		<!--- Create Array --->
		<cfreturn newStructure>
	</cffunction>


</cfcomponent>