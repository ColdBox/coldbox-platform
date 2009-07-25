<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Author 	 :	Luis Majano & Rob Gonda
Date    	 :	November 8, 2007
License       : 	Licensed under the Apache 2 License
Description :
	This is an environment control interceptor for your usage. You must first create
	an environment control xml file and place it under your config folder, or wherever
	you want.  You must then set it as a property of the interceptor in your config
	file.  The path will be expanded, so please make sure it works.
	
	<interceptor class="environment">
		<property name='configFile'>config/environments.xml.cfm</property>
	</interceptor>
	
	That's it. Just make sure you write up correctly your environment xml file.


----------------------------------------------------------------------->
<cfcomponent name="EnvironmentControl"
			 hint="ENVIRONMENT settings interceptor"
			 extends="coldbox.system.Interceptor"
			 output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="Configure" access="public" returntype="void" hint="This is the configuration method for your interceptors" output="false" >
		<cfscript>
			var configFile = "";
			
			// Regex for JSON
			instance.jsonRegex = "^(\{|\[)(.)*(\}|\])$";
		
			// Verify that the configFile propety is set
			if( not propertyExists('configFile') ){
				$throw("Config File property does not exist. Please declare it.",'','interceptors.EnvironmentControl.configFilePropertyNotDefined');
			}
			// Try to locate the path
			configFile = locateFilePath(getProperty('configFile'));
			// Validate it
			if( len(configFile) eq 0 ){
				$throw('Config File could not be located: #getProperty('configFile')#. Please check again.','','interceptors.EnvironmentControl.configFileNotFound');
			}
			// Save Config File
			setConfigFile(configFile);			
			
			// Completed Flag
			setProperty('interceptorCompleted',false);
			
			//Verify the fireOnInit flag
			if( not propertyExists('fireOnInit') or not isBoolean(getProperty('fireOnInit')) ){
				setProperty('fireOnInit',true);
			}
			
			//Check if we need to fire the interception at configuration
			if( getProperty('fireOnInit') ){
				parseAndSet();
				setProperty('interceptorCompleted',true);
			}
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->	 

	<cffunction name="afterConfigurationLoad" output="false" access="public" returntype="void" hint="ENVIRONMENT control the settings">
		<!--- *********************************************************************** --->
		<cfargument name="event" 	required="true" type="coldbox.system.beans.RequestContext" hint="The event object.">
		<cfargument name="interceptData" required="true" type="struct" hint="A structure containing intercepted information. NONE BY DEFAULT HERE">
		<!--- *********************************************************************** --->
		<cfscript>
			if( getProperty('interceptorCompleted') eq false){
				parseAndSet();	
				setProperty('interceptorCompleted',true);
			}
		</cfscript>
	</cffunction>
	
<!------------------------------------------- ACCESSOR/MUTATORS ------------------------------------------->	 

	<cffunction name="getconfigFile" access="public" returntype="string" output="false">
		<cfreturn instance.configFile>
	</cffunction>
	<cffunction name="setconfigFile" access="public" returntype="void" output="false">
		<cfargument name="configFile" type="string" required="true">
		<cfset instance.configFile = arguments.configFile>
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------->	 
	
	<cffunction name="parseAndSet" output="false" access="private" returntype="void" hint="ENVIRONMENT control the settings">
		<cfscript>
			var environmentsArray = ArrayNew(1);
			var SettingsArray = ArrayNew(1);
			var environmentXML = "";
			var i = 1;
			var environment = "";
			var oXML = "";
			var configSettings = getController().getConfigSettings();
			var thisValue = "";
			var oUtilities = getPlugin("Utilities");
			var oJSON = getPlugin("JSON");
			var oXMLParser = getPlugin("XMLParser");
		
			//Parse it
			oXML = XMLParse(getConfigFile());
			
			//Search and test for environments
			environmentsArray = xmlSearch(oXML, '/environmentcontrol/environment');
			if( arrayLen(environmentsArray) eq 0){
				$throw("No environment elements found.","Please check your environment file again","interceptors.EnvironmentControl.elementException");
			}
			// Detect the environment
			environment = detectEnvironment(environmentsArray);
			// If no overrides found, then just exit out.
			if( len(trim(environment)) eq 0 ){ return; }
			
			//Parse Settings
			SettingsArray = xmlSearch( oXML , "/environmentcontrol/environment[@name='#environment#']/Setting");
			//Insert Your Settings to Config Struct
			for (i=1; i lte ArrayLen(SettingsArray); i=i+1){
				// Get Setting value with PlaceHolding replacements
				thisValue = oUtilities.placeHolderReplacer(trim(SettingsArray[i].XMLAttributes["value"]),configSettings);
				//Test for JSON
				if( reFindNocase(instance.jsonRegex,thisValue) ){
					thisValue = oJSON.decode(replace(thisValue,"'","""","all"));
				}
				// Check if overriding or new one?
				if( settingExists(trim(SettingsArray[i].xmlAttributes.name)) ){
					setSetting( trim(SettingsArray[i].xmlAttributes.name) , thisValue );
				}
				else{
					// Do a full set
					"configSettings.#trim(SettingsArray[i].xmlAttributes.name)#" = thisValue;
				}
			}
			
			// Parse Other Sections Available in the environment config.
			environmentXML = xmlSearch( oXML , "/environmentcontrol/environment[@name='#environment#']");
			// Mail Settings
			oXMLParser.parseMailSettings(environmentXML[1],configSettings,oUtilities,true);		
			// IOC
			oXMLParser.parseIOC(environmentXML[1],configSettings,oUtilities,true);		
			// Models
			oXMLParser.parseModels(environmentXML[1],configSettings,oUtilities,true);		
			// i18N
			oXMLParser.parseLocalization(environmentXML[1],configSettings,oUtilities,true);
			// Bug Tracers
			oXMLParser.parseBugTracers(environmentXML[1],configSettings,oUtilities,true);
			// Web Services
			oXMLParser.parseWebservices(environmentXML[1],configSettings,oUtilities,true);
			// Parse Datasources
			oXMLParser.parseDatasources(environmentXML[1],configSettings,oUtilities,true);
			// Parse Debugger Settings
			oXMLParser.parseDebuggerSettings(environmentXML[1],configSettings,oUtilities,true);
			// Reload Debugger Configuration
			controller.getDebuggerService().getDebuggerConfig().populate(configSettings.DebuggerSettings);
			// Parse Interceptors
			oXMLParser.parseInterceptors(environmentXML[1],configSettings,oUtilities,true);	
			// Parse LogBox
			oXMLParser.parseLogBox(environmentXML[1],configSettings,oUtilities,true);
			// Reconfigure LogBox
			if( NOT structIsEmpty(configSettings["LogBoxConfig"]) ){
				controller.getLogBox().configure(controller.getLogBox().getConfig());
				controller.setLogger(controller.getLogBox().getLogger("coldbox.system.Controller"));
			}				
		</cfscript>
	</cffunction>
	
	<cffunction name="detectEnvironment" access="private" returntype="string" hint="Detect the running environment and return the name" output="false" >
		<!--- *********************************************************************** --->
		<cfargument name="environmentsArray" required="true" type="array" hint="The environment array">
		<!--- *********************************************************************** --->
		<cfscript>
			for(i=1; i lte ArrayLen(arguments.environmentsArray); i=i+1){
				if ( listFindNoCase(trim(arguments.environmentsArray[i].XMLAttributes.urls),cgi.http_host) ){
					//Place the ENVIRONMENT on the settings structure.
					setSetting("ENVIRONMENT", trim(arguments.environmentsArray[i].XMLAttributes.name));
					return trim(arguments.environmentsArray[i].XMLAttributes.name);
					break;
				}
			}
			return "";
		</cfscript>
	</cffunction>
	
</cfcomponent>