<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
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
<cfcomponent hint="ENVIRONMENT settings interceptor when using the XML configuration file. This interceptor will be deprecated by 3.1"
			 extends="coldbox.system.Interceptor"
			 output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="Configure" access="public" returntype="void" hint="This is the configuration method for your interceptors" output="false" >
		<cfscript>
			var configFile = "";
			
			// App Loader
			instance.appLoader = controller.getLoaderService().getAppLoader();
			
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
			
			// Save Config File location
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
		<cfargument name="event" 		 required="true" hint="The event object.">
		<cfargument name="interceptData" required="true" hint="A structure containing intercepted information. NONE BY DEFAULT HERE">
		<!--- *********************************************************************** --->
		<cfscript>
			if( getProperty('interceptorCompleted') eq false){
				parseAndSet();	
				setProperty('interceptorCompleted',true);
			}
		</cfscript>
	</cffunction>
	
<!------------------------------------------- ACCESSOR/MUTATORS ------------------------------------------->	 

	<cffunction name="getConfigFile" access="public" returntype="any" output="false">
		<cfreturn instance.configFile>
	</cffunction>
	<cffunction name="setConfigFile" access="public" returntype="void" output="false">
		<cfargument name="configFile" type="string" required="true">
		<cfset instance.configFile = arguments.configFile>
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------->	 
	
	<cffunction name="parseAndSet" output="false" access="private" returntype="void" hint="ENVIRONMENT control the settings">
		<cfscript>
			var environmentsArray = ArrayNew(1);
			var settingsArray = ArrayNew(1);
			var environmentXML = "";
			var i = 1;
			var environment = "";
			var oXML = "";
			var configSettings = getController().getConfigSettings();
			var thisValue = "";
			var appLoader = instance.appLoader;
			var oUtilities = appLoader.getUtil();
			var oJSON = appLoader.getJSONUtil();
			var jsonRegex = appLoader.getJSONRegex();
			var cacheBoxHash	= "";
			var wireboxHash		= "";
			
			//Parse environment config file
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
			
			//Parse Custom Settings
			settingsArray = xmlSearch( oXML , "/environmentcontrol/environment[@name='#environment#']/Setting");
			//Insert Your Settings to Config Struct
			for (i=1; i lte ArrayLen(settingsArray); i=i+1){
				
				// Check if value attribute exists, else check text.
				if( structKeyExists(settingsArray[i].XMLAttributes,"value") ){
					thisValue = oUtilities.placeHolderReplacer(trim(settingsArray[i].XMLAttributes["value"]),configSettings);
				}
				// Check for the xml text
				if( len(settingsArray[i].XMLText) ){
					thisValue = oUtilities.placeHolderReplacer(trim(settingsArray[i].XMLText),configSettings);
				}
				
				//Test for JSON
				if( reFindNocase(jsonRegex,thisValue) ){
					thisValue = oJSON.decode(replace(thisValue,"'","""","all"));
				}
				// Check if overriding or new one?
				if( settingExists(trim(settingsArray[i].xmlAttributes.name)) ){
					setSetting( trim(settingsArray[i].xmlAttributes.name) , thisValue );
				}
				else{
					// Do a full set override
					"configSettings.#trim(settingsArray[i].xmlAttributes.name)#" = thisValue;
				}
			}
			
			// Parse Other Sections Available in the environment config.
			environmentXML = xmlSearch( oXML , "/environmentcontrol/environment[@name='#environment#']");
			//dump(environmentXML);$abort();
			if( arrayLen(environmentXML) ){
				environmentXML = xmlParse( toString(environmentXML[1]) );
				// Mail Settings
				appLoader.parseMailSettings(environmentXML,configSettings,true);
				// IOC
				appLoader.parseIOC(environmentXML,configSettings,true);		
				// Models
				appLoader.parseModels(environmentXML,configSettings,true);		
				// i18N
				appLoader.parseLocalization(environmentXML,configSettings,true);
				// Bug Tracers
				appLoader.parseBugTracers(environmentXML,configSettings,true);
				// Web Services
				appLoader.parseWebservices(environmentXML,configSettings,true);
				// Parse Datasources
				appLoader.parseDatasources(environmentXML,configSettings,true);
				// Parse Debugger Settings
				appLoader.parseDebuggerSettings(environmentXML,configSettings,true);
				// Reload Debugger Configuration
				controller.getDebuggerService().getDebuggerConfig().populate(configSettings.DebuggerSettings);
				// Parse Interceptors
				appLoader.parseInterceptors(environmentXML,configSettings,true);	
				
				//****** COMPAT MODE, REMOVE LATER ***********
				// Store CacheBox settings
				cacheBoxHash = hash(configSettings.cacheBox.toString());
				// Parse Cache Settings
				appLoader.parseCacheSettings(environmentXML,configSettings,true);
				// Reconfigure Cache Config Settings and Cache: TODO change with compat modes
				if( NOT isObject(controller.getCacheBox()) ){
					controller.getColdBoxOCM().getCacheConfig().populate(configSettings.cacheSettings);
					controller.getColdBoxOCM().configure(controller.getColdBoxOCM().getCacheConfig());
				}
				// Check if cacheBox changes where made, then reload it according to environment
				else if( cacheBoxHash NEQ hash(configSettings.cacheBox.toString()) ){
					controller.getLoaderService().createCacheContainer();
				}
				//****** COMPAT MODE, REMOVE LATER ***********
				
				// Parse LogBox
				appLoader.parseLogBox(environmentXML,configSettings,true);
				// Reconfigure LogBox if resset
				if( NOT structIsEmpty(configSettings["LogBoxConfig"]) ){
					controller.getLogBox().configure(controller.getLogBox().getConfig());
					controller.setLog(controller.getLogBox().getLogger(controller));
				}	
				// WireBox additions
				wireboxHash = hash( configSettings.wirebox.toString() );
				appLoader.parseWireBox(environmentXML,configSettings,true);
				if( wireboxHash NEQ hash(configSettings.wirebox.toString()) ){
					controller.getLoaderService().createWireBox();
				}
			}			
		</cfscript>
	</cffunction>
	
	<cffunction name="detectEnvironment" access="private" returntype="string" hint="Detect the running environment and return the name" output="false" >
		<cfargument name="environmentsArray" required="true" type="array" hint="The environment array">
		<cfscript>
			var i = 0;
			var j = 0;
			var XMLAttributes = '';
			var urls = '';
			var patterns = '';
			var environmentIndex = 0;
			var environment = '';
			
			for(i=1; i lte ArrayLen(arguments.environmentsArray); i=i+1){
			    XMLAttributes = arguments.environmentsArray[i].XMLAttributes;
			   
			    urls = '';
			    if(structKeyExists(XMLAttributes,'urls')){
			          urls = trim(XMLAttributes.urls);
			          if (len(urls) and listFindNoCase(urls,cgi.http_host)){
			                environmentIndex = i;
			                break;
			          }
			    }
			   
			    patterns = '';
			    if(structKeyExists(XMLAttributes,'patterns')){
			          patterns = trim(XMLAttributes.patterns);
			          if (len(patterns)){
			                for(j=1; j lte listLen(patterns); j=j+1){
			                      if (reFindNoCase(listGetAt(patterns,j),cgi.http_host)){
			                            environmentIndex = i;
			                            break;
			                      }
			                }
			          }
			    }
			}
			
			if (environmentIndex){
			    environment = trim(arguments.environmentsArray[environmentIndex].XMLAttributes.name);
			    setSetting("ENVIRONMENT",environment);
			}
			
			return environment;
		</cfscript>
	</cffunction>
	
</cfcomponent>