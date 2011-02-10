<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	 		: Luis Majano
Date     		: September 23, 2005
Description		: 

Loads all the default ColdBox settings into an application controller

----------------------------------------------------------------------->
<cfcomponent hint="Loads all the default ColdBox settings into an application controller" output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------>
	
	<cfscript>
		instance = structnew();
	</cfscript>

	<!--- init --->
	<cffunction name="init" output="false" access="public" returntype="FrameworkLoader" hint="constructor">
		<cfscript>
			// File locations
			instance.FrameworkPath = expandPath("/coldbox/system") & "/";
			instance.FrameworkConfigFile = instance.FrameworkPath & "web/config/settings.xml";
			instance.FrameworkConfigXSDFile = instance.FrameworkPath & "web/config/config.xsd";
			
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------>
	
	<!--- loadSettings --->
	<cffunction name="loadSettings" output="false" access="public" returntype="void" hint="Get the coldbox default settings">
		<cfargument name="controller" type="any" required="true" hint="The coldbox controller to load"/>
		<cfscript>
			var settingsStruct = StructNew();
			var fwXML = "";
			var settingNodes = "";
			var conventions = "";
			var CFMLEngine = arguments.controller.getCFMLEngine().getEngine();
			var CFMLVersion = arguments.controller.getCFMLEngine().getVersion();
			var i = 1;
			var OSSeparator = createObject("java","java.lang.System").getProperty("file.separator");
			var appRootPath = arguments.controller.getAppRootPath();
				
			//Setup the ColdBox CFML Engine Info
			settingsStruct["CFMLEngine"] = CFMLEngine;
			settingsStruct["CFMLVersion"] = CFMLVersion;	
			settingsStruct["JDKVersion"] = arguments.controller.getCFMLEngine().JDK_VERSION;		
			
			// Schema Path
			settingsStruct["ConfigFileSchemaLocation"] = instance.FrameworkConfigXSDFile;
			
			//Fix Application Path to last / standard.
			if( NOT reFind("(/|\\)$",appRootPath) ){
				arguments.controller.setAppRootPath( appRootPath & OSSeparator );
			}
			
			// Setup metadata paths
			settingsStruct["ApplicationPath"] = appRootPath;
			settingsStruct["FrameworkPath"] = instance.FrameworkPath;
			settingsStruct["FrameworkPluginsPath"] = instance.FrameworkPath & "plugins";
			settingsStruct["modifyLogLocation"] = instance.FrameworkPath & "config/readme.txt";
			
			// Parse settings		
			fwXML = xmlParse(instance.FrameworkConfigFile);
			
			//Get SettingNodes From Config
			settingNodes = XMLSearch(fwXML,"//Settings/Setting");
			
			//Insert Settings to Config Struct
			for (i=1; i lte ArrayLen(settingNodes); i=i+1){
				settingsStruct[settingNodes[i].XMLAttributes["name"]] = settingNodes[i].XMLAttributes["value"];
			}
	
			//Conventions Parsing
			conventions = XMLSearch(fwXML,"//Conventions");
			settingsStruct["HandlersConvention"] = conventions[1].handlerLocation.xmltext;
			settingsStruct["pluginsConvention"] = conventions[1].pluginsLocation.xmltext;
			settingsStruct["LayoutsConvention"] = conventions[1].layoutsLocation.xmltext;
			settingsStruct["ViewsConvention"] = conventions[1].viewsLocation.xmltext;
			settingsStruct["EventAction"] = conventions[1].eventAction.xmltext;
			settingsStruct["ModelsConvention"] = conventions[1].modelsLocation.xmltext;
			settingsStruct["ConfigConvention"] = conventions[1].configLocation.xmltext;
			settingsStruct["ModulesConvention"] = conventions[1].modulesLocation.xmltext;
			
			settingsStruct["ConfigFileLocation"] = "";
			
			// Store loaded settings
			arguments.controller.setColdBoxSettings(settingsStruct);
		</cfscript>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------>
	
	<!--- Get ColdBox Util --->
	<cffunction name="getUtil" access="private" output="false" returntype="any" hint="Create and return a util object">
		<cfreturn createObject("component","coldbox.system.core.util.Util")/>
	</cffunction>

</cfcomponent>