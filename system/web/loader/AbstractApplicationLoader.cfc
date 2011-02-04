<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	 		: Luis Majano
Date     		: September 23, 2005
Description		: 

Abstract application loader

----------------------------------------------------------------------->
<cfcomponent hint="Abstract coldbox application loader" output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------>
	
	<cfscript>
		instance = structnew();
	</cfscript>

	<!--- init --->
	<cffunction name="init" output="false" access="public" returntype="any" hint="constructor">
		<cfargument name="controller" type="any" required="true" hint="The coldbox application to load the settings into"/>
		<cfscript>
			// local controller
			instance.controller = arguments.controller;
			
			// Utility Object
			instance.util = createObject("component","coldbox.system.core.util.Util");
			
			// Coldbox Settings
			instance.coldboxSettings = arguments.controller.getColdBoxSettings();
			
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------>
	
	<!--- Parse the configuration --->
	<cffunction name="loadConfiguration" access="public" returntype="void" output="false" hint="Parse the application configuration file.">
		<cfargument name="overrideAppMapping" required="false" default="" hint="Only used for unit testing or reparsing of a specific coldbox config file."/>
	</cffunction>
	
	<!--- Get ColdBox Settings --->
	<cffunction name="getColdboxSettings" access="public" returntype="any" output="false" hint="Get the coldbox settings">
		<cfreturn instance.coldboxSettings>
	</cffunction>
	
	<!--- loadApplicationPaths --->
	<cffunction name="loadApplicationPaths" output="false" access="public" returntype="void" hint="Load application paths according to override">
		<cfargument name="configStruct" 		type="any"  required="true" hint="The configuration structure"/>
		<cfargument name="overrideAppMapping" 	type="any" 	required="false" default="" hint="Only used for unit testing or reparsing of a specific coldbox config file."/>
		<cfscript>
			// Setup Default Application Path from main controller
			arguments.configStruct.applicationPath = getController().getAppRootPath();
			
			// Check for Override of AppMapping
			if( len(trim(arguments.overrideAppMapping)) ){
				arguments.configStruct.applicationPath = expandPath(arguments.overrideAppMapping) & "/";
			}
		</cfscript>
	</cffunction>
	
	<!--- calculateAppMapping --->
    <cffunction name="calculateAppMapping" output="false" access="public" returntype="void" hint="Calculate the AppMapping">
    	<cfargument name="configStruct" 	type="any" required="true" hint="The config struct"/>
		<cfscript>
			// Get the web path from CGI.
			var	webPath = replacenocase(cgi.script_name,getFileFromPath(cgi.script_name),"");
			// Cleanup the template path
			var localPath = getDirectoryFromPath(replacenocase(getTemplatePath(),"\","/","all"));
			// Verify Path Location
			var pathLocation = findnocase(webPath, localPath);
			
			if ( pathLocation ){
				arguments.configStruct.appMapping = mid(localPath,pathLocation,len(webPath));
			}
			else{
				arguments.configStruct.appMapping = webPath;
			}

			//Clean last /
			if ( right(arguments.configStruct.AppMapping,1) eq "/" ){
				if ( len(arguments.configStruct.AppMapping) -1 gt 0)
					arguments.configStruct.AppMapping = left(arguments.configStruct.AppMapping,len(arguments.configStruct.AppMapping)-1);
				else
					arguments.configStruct.AppMapping = "";
			}
			
			//Clean j2ee context
			if( len(getContextRoot()) ){
				arguments.configStruct.AppMapping = replacenocase(arguments.configStruct.AppMapping,getContextRoot(),"");
			}
    	</cfscript>
    </cffunction>
	
	<!--- getAppMappingAsDots --->
    <cffunction name="getAppMappingAsDots" output="false" access="public" returntype="string" hint="Get the App Mapping as Dots">
    	<cfargument name="appMapping" type="any" required="true" />
		<cfscript>
			return reReplace(arguments.appMapping,"(/|\\)",".","all");
		</cfscript>
    </cffunction>

	<!--- Get ColdBox Util --->
	<cffunction name="getUtil" access="public" output="false" returntype="any" hint="Create and return a util object">
		<cfreturn instance.util/>
	</cffunction>
	
	<!--- loadLogBoxByConvention --->
    <cffunction name="loadLogBoxByConvention" output="false" access="public" returntype="void" hint="Load logBox by convention">
    	<cfargument name="logBoxConfig" type="any" required="true"/>
    	<cfargument name="config" 		type="any" required="true"/>
		<cfscript>
    		var appRootPath 	  = getController().getAppRootPath();
			var appMappingAsDots  = "";
			var configCreatePath  = "config.LogBox";
			
			// Reset Configuration we have declared a configuration DSL
			arguments.logBoxConfig.reset();
			//AppMappingInvocation Path
			appMappingAsDots = getAppMappingAsDots(arguments.config.appMapping);
			//Config Create Path
			if( len(appMappingAsDots) ){
				configCreatePath = appMappingAsDots & "." & configCreatePath;
			}
			arguments.logBoxConfig.init(CFCConfigPath=configCreatePath).validate();
			arguments.config["LogBoxConfig"] = arguments.logBoxConfig.getMemento();
		</cfscript>
    </cffunction>
	
	<!--- loadLogBoxByFile --->
    <cffunction name="loadLogBoxByFile" output="false" access="public" returntype="void" hint="Load logBox by file">
    	<cfargument name="logBoxConfig" type="any" 		required="true"/>
    	<cfargument name="filePath" 	type="any" 		required="true"/>
		<cfscript>
    		// Load according xml?
			if( listFindNoCase("cfm,xml", listLast(arguments.filePath,".")) ){
				arguments.logBoxConfig.init(XMLConfig=arguments.filePath).validate();
			}
			// Load according to CFC Path
			else{
				arguments.logBoxConfig.init(CFCConfigPath=arguments.filePath).validate();
			}
		</cfscript>
    </cffunction>
	
	<!--- loadCacheBoxByConvention --->
    <cffunction name="loadCacheBoxByConvention" output="false" access="public" returntype="any" hint="Basically get the right config file to load in place">
    	<cfargument name="config" type="any" required="true"/>
		<cfscript>
    		var appRootPath 	  = getController().getAppRootPath();
			var appMappingAsDots  = "";
			var configCreatePath  = "config.CacheBox";
			
			//AppMappingInvocation Path
			appMappingAsDots = getAppMappingAsDots(arguments.config.appMapping);
			
			//Config Create Path
			if( len(appMappingAsDots) ){
				configCreatePath = appMappingAsDots & "." & configCreatePath;
			}
			
			return configCreatePath;
		</cfscript>
    </cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------>

	<!--- Get Controller --->
	<cffunction name="getController" access="private" returntype="any" output="false" hint="Get the controller">
		<cfreturn instance.controller>
	</cffunction>
	
</cfcomponent>