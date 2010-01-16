<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date        :	January 12, 2010
Description :
I oversee and manage ColdBox modules

----------------------------------------------------------------------->
<cfcomponent output="false" hint="I oversee and manage ColdBox modules" extends="coldbox.system.services.BaseService">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" output="false" returntype="ModuleService" hint="Constructor">
		<cfargument name="controller" type="any" required="true">
		<cfscript>
			setController(arguments.controller);
			
			// service properties
			instance.logger = "";
			instance.mConfigCache = {};
			
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- onConfigurationLoad --->
    <cffunction name="onConfigurationLoad" output="false" access="public" returntype="void" hint="Called by loader service when configuration file loads">
    	<cfscript>
			//Get Local Logger Now Configured
			instance.logger = controller.getLogBox().getLogger(this);
		
    		// Register The Modules
			registerAllModules();
    	</cfscript>
    </cffunction>
	
	<!--- registerAllModules --->
	<cffunction name="registerAllModules" output="false" access="public" returntype="void" hint="Register all located modules">
		<cfscript>
			var foundModules = "";
			var x = 1;
			
			// Register the module configuration
			controller.setSetting("modules",structnew());
			
			//Get all modules in application
			foundModules = scanModulesDirectory(controller.getSetting("ModulesPath"));
			
			// Iterate through them.
			for(x=1; x lte arrayLen(foundModules); x++){
				registerModule(foundModules[x]);
			}
		</cfscript>
	</cffunction>
	
	<!--- registerModule --->
	<cffunction name="registerModule" output="false" access="public" returntype="boolean" hint="Register a module by name and location">
		<cfargument name="moduleName" type="string" required="true" hint="The module absolute location to load. Must be inside of the ModulesLocation path"/>
		<cfscript>
			var modulesLocation 		= controller.getSetting("ModulesLocation");
			var modulesPath 			= controller.getSetting("ModulesPath");
			var modulesInvocationPath 	= controller.getSetting("ModulesInvocationPath");
			// Module To Load
			var modName 				= arguments.moduleName;
			var modLocation 			= modulesPath & "/" & modName;
			var iData 					= {};
			var interceptorService 		= controller.getInterceptorService();
			var mConfig 				= "";
			var y						= 1;
			
			//Check if module config exists, else skip and exit and log
			if( NOT fileExists(modLocation & "/ModuleConfig.cfc") ){
				instance.logger.WARN("The module (#modName#) cannot be loaded as it does not have a ModuleConfig.cfc in its root. Path Checked: #modLocation#");
				return false;
			}
			
			// preModuleLoad interception
			iData = {moduleLocation=modLocation,moduleName=modName};
			interceptorService.processState("preModuleLoad",iData);
			
			// Config information for module
			mConfig = {
				title = "", author="", webURL="", description="", version="",
				path = modLocation,
				invocationPath = modulesInvocationPath & "." & modName,
				mapping = modulesLocation & "/" & modName,
				registeredHandlers = '',
				settings = {},
				interceptors = [],
				customInterceptionPoints = "",
				routes = []
			};
			
			// Load Module configuration from cfc and store it in module Config Cache.
			instance.mConfigCache[modName] = loadModuleConfiguration(mConfig);
			
			// Register handlers
			mConfig.registeredHandlers = controller.getHandlerService().getHandlerListing(mConfig.path & "/" & controller.getSetting("handlersConvention",true));
			mConfig.registeredHandlers = arrayToList(mConfig.registeredHandlers);
			
			// Register Custom Interception Points
			interceptorService.appendInterceptionPoints(mConfig.customInterceptionPoints);
			
			// Register Interceptors with Announcement service
			for(y=1; y lte arrayLen(mConfig.interceptors); y++){
				interceptorService.registerInterceptor(interceptorClass=mConfig.interceptors[y].class,
													   interceptorProperties=mConfig.interceptors[y].properties,
													   interceptorName=mConfig.interceptors[y].name);
			}
			
			// Register Model path if it exists according to parent convention.
			if( directoryExists(modLocation & "/" & controller.getSetting("modelsConvention",true)) ){
				controller.getPlugin("BeanFactory").appendExternalLocations(mConfig.invocationPath & "." & controller.getSetting("modelsConvention",true));
			}
			
			// Save module configuration
			controller.getConfigSettings().modules[modName] = mConfig;
			
			// Call on module configuration object onLoad() if found
			if( structKeyExists(instance.mConfigCache[modName],"onLoad") ){
				instance.mConfigCache[modName].onLoad();
			}
			
			// postModuleLoad interception
			iData = {moduleLocation=modLocation,moduleName=modName,moduleConfig=mConfig};
			interceptorService.processState("postModuleLoad",iData);
			
			return true;
		</cfscript>
	</cffunction>
	
	<!--- reload --->
	<cffunction name="reload" output="false" access="public" returntype="void" hint="Reload a targeted module">
		<cfargument name="moduleName" type="string" required="true" hint="The module to reload"/>
		<cfscript>
			unloadModule(arguments.moduleName);
			registerModule(arguments.moduleName);
		</cfscript>
	</cffunction>
	
	<!--- reloadAll --->
	<cffunction name="reloadAll" output="false" access="public" returntype="void" hint="Reload all modules">
		<cfscript>
			unloadAll();
			registerAllModules();
		</cfscript>
	</cffunction>
	
	<!--- getLoadedModules --->
	<cffunction name="getLoadedModules" output="false" access="public" returntype="array" hint="Get a listing of all loaded modules">
		<cfscript>
			var modules = structKeyList(controller.getSetting("modules"));
			
			return listToArray(modules);
		</cfscript>
	</cffunction>
	
	<!--- unloadModule --->
	<cffunction name="unloadModule" output="false" access="public" returntype="boolean" hint="Unload a module if found from the configuration">
		<cfargument name="moduleName" type="string" required="true" hint="The module name to unload"/>
		<cfscript>
			// This method basically unregisters the module configuration
			var appConfig = controller.getConfigSettings();
			var iData = {moduleName=arguments.moduleName};
			var interceptorService = controller.getInterceptorService();
			var x = 1;
			
			// Check if module is loaded?
			if( NOT structKeyExists(appConfig.modules,arguments.moduleName) ){ return false; }
			
			// Before unloading a module interception
			interceptorService.processState("preModuleUnload",iData);
			
			// Call on module configuration object onLoad() if found
			if( structKeyExists(mConfigCache[modName],"onUnload") ){
				instance.mConfigCache[modName].onUnload();
			}
			
			// Unregister all interceptors
			for(x=1; x lte arrayLen(appConfig.modules[arguments.moduleName].interceptors); x++){
				interceptorService.unregister(appConfig.modules[arguments.moduleName].interceptors[x].name);
			}
			
			//Remove Model Mapping Location
			controller.getPlugin("BeanFactory").removeExternalLocations(appConfig.modules[arguments.moduleName].invocationPath & "." & controller.getSetting("modelsConvention",true));
			
			// Remove configuration
			structDelete(appConfig.modules, arguments.moduleName);
			
			// Remove Configuration object from Cache
			structDelete(instance.mConfigCache,arguments.moduleName);
			
			//After unloading a module interception
			interceptorService.processState("postModuleUnload",iData);
			
			return true;
		</cfscript>
	</cffunction>
	
	<!--- unloadAll --->
	<cffunction name="unloadAll" output="false" access="public" returntype="void" hint="Unload all registered modules">
		<cfscript>
			// This method basically unregisters the module configuration
			var modules = controller.getSetting("modules");
			var key = "";
			
			// Unload all modules
			for(key in modules){
				unloadModule(key);
			}	
			
			controller.setSetting("modules",structnew());
			instance.mConfigCache = structnew();					
		</cfscript>
	</cffunction>
	
	<!--- loadModuleConfiguration --->
	<cffunction name="loadModuleConfiguration" output="false" access="public" returntype="any" hint="Load the module configuration object">
		<cfargument name="config" type="struct" required="true" hint="The module config structure"/>
		<cfscript>
			var mConfig = arguments.config;
			var oConfig = createObject("component", mConfig.invocationPath & ".ModuleConfig");
			var toLoad = "";
			// app settings pointer
			var appSettings = controller.getConfigSettings();
			var x=1;
			
			//Decorate It
			oConfig.injectPropertyMixin = getUtil().injectPropertyMixin;
			oConfig.getPropertyMixin 	= getUtil().getPropertyMixin;
			
			//MixIn Variables
			oConfig.injectPropertyMixin("controller",controller);
			oConfig.injectPropertyMixin("appMapping",controller.getSetting("appMapping"));
			oConfig.injectPropertyMixin("moduleMapping",mConfig.mapping);
			oConfig.injectPropertyMixin("modulePath",mConfig.path);
			
			//Get Public Module Properties
			mConfig.title 		= oConfig.title;
			mConfig.author 		= oConfig.author;
			mConfig.webURL		= oConfig.webURL;
			mConfig.description = oConfig.description;
			mConfig.version		= oConfig.version; 
			
			//Configure the module
			oConfig.configure();
			
			//Get the parent settings and append them
			toLoad = oConfig.getPropertyMixin("parentSettings","variables",structnew());
			structAppend(appSettings, toLoad , true);
			
			//Get the module settings
			mConfig.settings = oConfig.getPropertyMixin("settings","variables",structnew());
			
			//Get datasources
			toLoad = oConfig.getPropertyMixin("datasources","variables",structnew());
			structAppend(appSettings.datasources, toLoad, true);
			
			//Get webservices
			toLoad = oConfig.getPropertyMixin("webservices","variables",structnew());
			structAppend(appSettings.webservices, toLoad, true);
				
			//Get Interceptors
			mConfig.interceptors = oConfig.getPropertyMixin("interceptors","variables",arrayNew(1));
			for(x=1; x lte arrayLen(mConfig.interceptors); x=x+1){
				//Name check
				if( NOT structKeyExists(mConfig.interceptors[x],"name") ){
					mConfig.interceptors[x].name = listLast(mConfig.interceptors[x].class,".");
				}
				//Properties check
				if( NOT structKeyExists(mConfig.interceptors[x],"properties") ){
					mConfig.interceptors[x].properties = structnew();
				}
			}
			
			//Get custom interception points
			mConfig.customInterceptionPoints = oConfig.getPropertyMixin("customInterceptionPoints","variables","");
			
			
			//Get Routes
			mConfig.routes = oConfig.getPropertyMixin("routes","variables",arrayNew(1));	
			
			return oConfig;		
		</cfscript>
	</cffunction>
	
	
<!------------------------------------------- PRIVATE ------------------------------------------->
	
	<!--- scanModulesDirectory --->
	<cffunction name="scanModulesDirectory" output="false" access="private" returntype="array" hint="Get an array of modules found">
		<cfargument name="dirPath" type="string" required="true" hint="Path to scan"/>
		<cfset var q = "">
		<cfset var results = []>
		
		<cfdirectory action="list" directory="#arguments.dirpath#" name="q" type="dir" sort="asc">
		
		<cfloop query="q">
			<cfif NOT find(".", q.name)>
				<cfset arrayAppend(results,q.name)>
			</cfif>
		</cfloop>
		
		<cfreturn results>
	</cffunction>
	
	
</cfcomponent>