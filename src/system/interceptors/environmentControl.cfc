<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
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
			
			//Verify that the configFile propety is set
			if( not propertyExists('configFile') ){
				throw("Config File property does not exist. Please declare it.",'','interceptors.environmentControl.configFilePropertyNotDefined');
			}
			//Test if the file exists
			if ( fileExists(getController().getAppRootPath() & getProperty('configFile')) ){
				configFile = getController().getAppRootPath() & getProperty('configFile');
			}
			if( fileExists(getController().getAppRootPath() & getSetting("OSFileSeparator",true) & getProperty('configFile'))  ){
				configFile = getController().getAppRootPath() & getSetting("OSFileSeparator",true) & getProperty('configFile');
			}
			else if( fileExists( ExpandPath(getProperty('configFile')) ) ){
				configFile = ExpandPath( getProperty('configFile') );
			}
			else{
				throw('Config File could not be located. Please check again.','','interceptors.environmentControl.configFileNotFound');
			}
			
			//Does it exist
			if ( not fileExists(configFile) ){
				throw("The config file does not exist at the following location: #configFile#.",'','interceptors.environmentControl.configFileNotFound');
			}
			//Verified, set it
			setConfigFile(configFile);			
			
			//Verify the fireOnInit flag
			if( not propertyExists('fireOnInit') ){
				setProperty('fireOnInit',false);
			}
			if( not isBoolean(getProperty('fireOnInit')) ){
				setProperty('fireOnInit',false);
			}
			//Check if we need to fire the interception at configuration
			if( getProperty('fireOnInit') ){
				parseAndSet();
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
			parseAndSet();	
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
		<!--- *********************************************************************** --->
		<cfscript>
			var environmentsArray = ArrayNew(1);
			var SettingsArray = ArrayNew(1);
			var settingsLength = 0;
			var i = 1;
			var ENVIRONMENT = "";
			var oXML = "";
		
			//Parse it
			oXML = XMLParse(getConfigFile());
			
			//Search and test for environments
			environmentsArray = xmlSearch(oXML, '/environmentcontrol/environment');
			
			if( arrayLen(environmentsArray) eq 0){
				throw("No environment elements found.","Please check your environment file again","interceptors.environmentControl.elementException");
			}
			/* Detect the environment */
			for(i=1; i lte ArrayLen(environmentsArray); i=i+1){
				if ( listFindNoCase(trim(environmentsArray[i].XMLAttributes.urls),cgi.http_host) ){
					//Place the ENVIRONMENT on the settings structure.
					setSetting("ENVIRONMENT", trim(environmentsArray[i].XMLAttributes.name));
					ENVIRONMENT = trim(environmentsArray[i].XMLAttributes.name);
					break;
				}
			}
			
			//Search for ENVIRONMENT settings.
			SettingsArray = xmlSearch( oXML , "/environmentcontrol/environment[@name='#ENVIRONMENT#']/Setting");
			settingsLength = ArrayLen(SettingsArray);
			//Check if settings for ENVIRONMENT found, else do nothing.
			if (settingsLength gt 0){
				//Loop And set
				for ( i=1; i lte settingsLength; i=i+1){
					setSetting( trim(SettingsArray[i].xmlAttributes.name) , trim(SettingsArray[i].xmlAttributes.value) );
				}
			}	
		</cfscript>
	</cffunction>
</cfcomponent>