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
<cfcomponent hint="ENVIRONMENT settings interceptor"
			 extends="coldbox.system.interceptor"
			 output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="Configure" access="public" returntype="void" hint="This is the configuration method for your interceptors" output="false" >
		<cfscript>
			var configFile = "";
			
			/* Verify that the configFile propety is set */
			if( not propertyExists('configFile') ){
				$throw("Config File property does not exist. Please declare it.",'','interceptors.environmentControl.configFilePropertyNotDefined');
			}
			/* Try to locate the path */
			configFile = locateFilePath(getProperty('configFile'));
			/* Validate it */
			if( len(configFile) eq 0 ){
				$throw('Config File could not be located: #getProperty('configFile')#. Please check again.','','interceptors.environmentControl.configFileNotFound');
			}
			
			/* execute check */
			setProperty('interceptorCompleted',false);
			
			//Verified, set it
			setConfigFile(configFile);			
			
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
		<cfargument name="event" 	required="true" type="coldbox.system.beans.requestContext" hint="The event object.">
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
			var settingsLength = 0;
			var i = 1;
			var ENVIRONMENT = "";
			var oXML = "";
			var configSettings = getController().getConfigSettings();
			var thisValue = "";
			var oUtilities = getPlugin("Utilities");
			var oJSON = getPlugin("json");
		
			//Parse it
			oXML = XMLParse(getConfigFile());
			
			//Search and test for environments
			environmentsArray = xmlSearch(oXML, '/environmentcontrol/environment');
			
			if( arrayLen(environmentsArray) eq 0){
				$throw("No environment elements found.","Please check your environment file again","interceptors.environmentControl.elementException");
			}
			/* Detect the environment */
			ENVIRONMENT = detectEnvironment(environmentsArray);
			
			//Search for ENVIRONMENT settings.
			SettingsArray = xmlSearch( oXML , "/environmentcontrol/environment[@name='#ENVIRONMENT#']/Setting");
			settingsLength = ArrayLen(SettingsArray);
			//Check if settings for ENVIRONMENT found, else do nothing.
			if (settingsLength gt 0){
				//Loop And set
				for ( i=1; i lte settingsLength; i=i+1){
					thisValue = trim(SettingsArray[i].xmlAttributes.value);
					/* Replace ${setting} */
					thisValue = oUtilities.placeHolderReplacer(trim(thisValue),configSettings);
					/* json decoding */
					if ( (left(thisValue,1) eq "[" AND right(thisValue,1) eq "]") OR
					     (left(thisValue,1) eq "{" AND right(thisValue,1) eq "}") ){
					     	thisValue = oJSON.decode(replace(thisValue,"'","""","all"));
					}
					
					/* Check if overriding a set setting */
					if( settingExists(trim(SettingsArray[i].xmlAttributes.name)) ){
						setSetting( trim(SettingsArray[i].xmlAttributes.name) , thisValue );
					}
					else{
						/* Do a full set */
						"configSettings.#trim(SettingsArray[i].xmlAttributes.name)#" = thisValue;
					}					
				}
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