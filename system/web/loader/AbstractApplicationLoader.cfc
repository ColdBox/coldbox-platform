<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
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
			
			// Regex for JSON
			instance.jsonRegex = "^(\{|\[)(.)*(\}|\])$";
			instance.jsonUtil = createObject("component","coldbox.system.core.util.conversion.JSON").init();
			
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------>
	
	<!--- Parse the configuration --->
	<cffunction name="loadConfiguration" access="public" returntype="void" output="false" hint="Parse the application configuration file.">
		<cfargument name="overrideAppMapping" 	type="string" 	required="false" default="" hint="Only used for unit testing or reparsing of a specific coldbox config file."/>
	</cffunction>
	
	<!--- Get ColdBox Settings --->
	<cffunction name="getColdboxSettings" access="public" returntype="struct" output="false" hint="Get the coldbox settings">
		<cfreturn instance.coldboxSettings>
	</cffunction>
	
	<!--- loadApplicationPaths --->
	<cffunction name="loadApplicationPaths" output="false" access="public" returntype="void" hint="Load application paths according to override">
		<cfargument name="configStruct" 		type="struct"   required="true" hint="The configuration structure"/>
		<cfargument name="overrideAppMapping" 	type="string" 	required="false" default="" hint="Only used for unit testing or reparsing of a specific coldbox config file."/>
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
    	<cfargument name="configStruct" 	type="struct" required="true" hint="The config struct"/>
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

	<!--- JSON REGEX --->
	<cffunction name="getJSONRegex" access="public" returntype="string" output="false" hint="Get the json regex string">
		<cfreturn instance.jsonRegex>
	</cffunction>
	
	<!--- getJSONUtil --->
	<cffunction name="getJSONUtil" access="public" output="false" returntype="coldbox.system.core.util.conversion.JSON" hint="Create and return a util object for JSON">
		<cfreturn instance.jsonUtil/>
	</cffunction>
	
	<!--- Get ColdBox Util --->
	<cffunction name="getUtil" access="public" output="false" returntype="coldbox.system.core.util.Util" hint="Create and return a util object">
		<cfreturn instance.util/>
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------>

	<!--- Get Controller --->
	<cffunction name="getController" access="private" returntype="any" output="false" hint="Get the controller">
		<cfreturn instance.controller>
	</cffunction>
	

</cfcomponent>