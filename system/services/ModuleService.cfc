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

<!------------------------------------------- INTERNAL COLDBOX EVENTS ------------------------------------------->

	<!--- onConfigurationLoad --->
    <cffunction name="onConfigurationLoad" output="false" access="public" returntype="void" hint="Called by loader service when configuration file loads">
    	<cfscript>
			//Get Local Logger Now Configured
			instance.logger = controller.getLogBox().getLogger(this);

    		// Register The Modules
			registerAllModules();
    	</cfscript>
    </cffunction>

	<!--- onAspectsLoad --->
    <cffunction name="onAspectsLoad" output="false" access="public" returntype="void" hint="Called by loader service when all aspects have loaded">
    	<cfscript>
			// Now that we are up and running we will turn on all the modules.
			activateAllModules();
    	</cfscript>
    </cffunction>

	<!--- onShutdown --->
    <cffunction name="onShutdown" output="false" access="public" returntype="void" hint="Called when the application stops">
    	<cfscript>
    		// Unload all modules
			unloadAll();
    	</cfscript>
    </cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- registerAllModules --->
	<cffunction name="registerAllModules" output="false" access="public" returntype="void" hint="Register all located modules in the conventions or set location. Usually called by framework to load configuraiton data.">
		<cfscript>
			var foundModules   = "";
			var x 			   = 1;
			var includeModules = controller.getSetting("ModulesInclude");
			
			// Register the module configuration
			controller.setSetting("modules",structnew());

			//Get all modules found in the application
			foundModules = scanModulesDirectory(controller.getSetting("ModulesPath"));
			
			// Check if we have an inclusion list, if we do just iterate through it instead of the found modules
			if( listLen(includeModules) ){
				foundModules = listToArray(includeModules);
			}
			
			// Iterate through them.
			for(x=1; x lte arrayLen(foundModules); x++){
				// Verify the exception lists
				if( canLoad( foundModules[x] ) ){
					registerModule(foundModules[x]);
				}
			}
		</cfscript>
	</cffunction>

	<!--- registerModule --->
	<cffunction name="registerModule" output="false" access="public" returntype="boolean" hint="Register a module's configuration information and config object">
		<cfargument name="moduleName" type="string" required="true" hint="The name of the module to load. It must exist and be valid. Else we ignore it by logging a warning and returning false."/>
		<cfscript>
			var modulesLocation 		= controller.getSetting("ModulesLocation");
			var modulesPath 			= controller.getSetting("ModulesPath");
			var modulesInvocationPath 	= controller.getSetting("ModulesInvocationPath");
			// Module To Load
			var modName 				= arguments.moduleName;
			var modLocation 			= modulesPath & "/" & modName;
			var mConfig 				= "";
			var modulesConfiguration	= controller.getSetting("modules");
		</cfscript>

		<cflock name="module.registration.#arguments.modulename#" type="exclusive" throwontimeout="true" timeout="20">
			<cfscript>
			//Check if module config exists, else skip and exit and log
			if( NOT fileExists(modLocation & "/ModuleConfig.cfc") ){
				instance.logger.WARN("The module (#modName#) cannot be loaded as it does not have a ModuleConfig.cfc in its root. Path Checked: #modLocation#");
				return false;
			}
			
			// Config information for module
			mConfig = {
				// Module MetaData and Directives
				title				= "", 
				author				="", 
				webURL				="", 
				description			="", 
				version				="",
				viewParentLookup 	= "true", 
				layoutParentLookup 	= "true", 
				entryPoint 			= "",
				loadTime 			= now(), 
				activated 			= false,
				// Module Configurations
				path				 	= modLocation,
				invocationPath 			= modulesInvocationPath & "." & modName,
				mapping 				= modulesLocation & "/" & modName,
				handlerInvocationPath 	= modulesInvocationPath & "." & modName,
				handlerPhysicalPath     = modLocation,
				pluginInvocationPath  	= modulesInvocationPath & "." & modName,
				pluginsPhysicalPath		= modLocation,
				modelsInvocationPath     = modulesInvocationPath & "." & modName,
				modelsPhysicalPath		= modLocation,
				registeredHandlers 		= '',
				settings 				= {},
				interceptors 			= [],
				interceptorSettings     = { customInterceptionPoints = "" },
				routes 					= [],
				conventions = {
					handlersLocation 	= "handlers",
					layoutsLocation 	= "layouts",
					viewsLocation 		= "views",
					pluginsLocation     = "plugins",
					modelsLocation       = "model"
				}
			};
			
			// Load Module configuration from cfc and store it in module Config Cache
			instance.mConfigCache[modName] = loadModuleConfiguration(mConfig);
			
			// Update the paths according to conventions
			mConfig.handlerInvocationPath 	&= ".#replace(mConfig.conventions.handlersLocation,"/",".","all")#";
			mConfig.handlerPhysicalPath     &= "/#mConfig.conventions.handlersLocation#";
			mConfig.pluginInvocationPath  	&= ".#replace(mConfig.conventions.pluginsLocation,"/",".","all")#";
			mConfig.pluginsPhysicalPath		&= "/#mConfig.conventions.pluginsLocation#";
			mConfig.modelsInvocationPath    &= ".#replace(mConfig.conventions.modelsLocation,"/",".","all")#";
			mConfig.modelsPhysicalPath		&= "/#mConfig.conventions.modelsLocation#";
			
			// Store module configuration in main modules configuration
			modulesConfiguration[modName] = mConfig;

			// Log registration
			instance.logger.DEBUG("Module #arguments.moduleName# registered successfully.");
			</cfscript>
		</cflock>

		<cfreturn true>
	</cffunction>

	<!--- activateModules --->
	<cffunction name="activateAllModules" output="false" access="public" returntype="void" hint="Go over all the loaded module configurations and activate them for usage within the application">
		<cfscript>
			var modules 			= controller.getSetting("modules");
			var moduleName 			= "";

			// Iterate through module configuration and activate each module
			for(moduleName in modules){

				// Verify the exception and inclusion lists
				if( canLoad( moduleName ) ){
					activateModule(moduleName);
				}

			}
		</cfscript>
	</cffunction>

	<!--- activateModule --->
	<cffunction name="activateModule" output="false" access="public" returntype="boolean" hint="Activate a module">
		<cfargument name="moduleName" type="string" required="true" hint="The name of the module to load. It must exist and be valid. Else we ignore it by logging a warning and returning false."/>
		<cfscript>
			var modules 			= controller.getSetting("modules");
			var mConfig				= "";
			var iData       		= {};
			var y					= 1;
			var interceptorService  = controller.getInterceptorService();
			var beanFactory 		= controller.getPlugin("BeanFactory");
			var key					= "";

			// If module not registered, throw exception
			if(NOT structKeyExists(modules, arguments.moduleName) ){
				getUtil().throwit(message="Cannot activate module: #arguments.moduleName#",
								  detail="The module has not been registered, register the module first and then activate it.",
								  type="ModuleService.IllegalModuleState");
			}
		</cfscript>

		<cflock name="module.activation.#arguments.moduleName#" type="exclusive" timeout="20" throwontimeout="true">
		<cfscript>
			// Get module settings
			mConfig = modules[arguments.moduleName];

			// preModuleLoad interception
			iData = {moduleLocation=mConfig.path,moduleName=arguments.moduleName};
			interceptorService.processState("preModuleLoad",iData);

			// Register handlers
			mConfig.registeredHandlers = controller.getHandlerService().getHandlerListing( mconfig.handlerPhysicalPath );
			mConfig.registeredHandlers = arrayToList(mConfig.registeredHandlers);

			// Register Custom Interception Points
			interceptorService.appendInterceptionPoints(mConfig.interceptorSettings.customInterceptionPoints);

			// Register the Config as an observable also.
			interceptorService.registerInterceptor(interceptorObject=instance.mConfigCache[arguments.moduleName]);

			// Register Interceptors with Announcement service
			for(y=1; y lte arrayLen(mConfig.interceptors); y++){
				interceptorService.registerInterceptor(interceptorClass=mConfig.interceptors[y].class,
													   interceptorProperties=mConfig.interceptors[y].properties,
													   interceptorName=mConfig.interceptors[y].name);
			}

			// Register Model path if it exists.
			if( directoryExists( mconfig.modelsPhysicalPath ) ){
				beanFactory.appendExternalLocations( mConfig.modelsInvocationPath );
			}

			// Register Model Mappings Now
			for(key in mConfig.modelMappings){
				// Default alias check
				if( NOT structKeyExists(mConfig.modelMappings[key], "alias") ){
					mConfig.modelMappings[key].alias = "";
				}
				// Register mapping
				beanFactory.addModelMapping(alias = listAppend(key,mConfig.modelMappings[key].alias),
											path  = mConfig.modelMappings[key].path);
			}

			// Call on module configuration object onLoad() if found
			if( structKeyExists(instance.mConfigCache[arguments.moduleName],"onLoad") ){
				instance.mConfigCache[arguments.moduleName].onLoad();
			}

			// postModuleLoad interception
			iData = {moduleLocation=mConfig.path,moduleName=arguments.moduleName,moduleConfig=mConfig};
			interceptorService.processState("postModuleLoad",iData);

			// Log it
			instance.logger.DEBUG("Module #arguments.moduleName# activated sucessfully.");
		</cfscript>
		</cflock>

		<cfreturn true>
	</cffunction>

	<!--- reload --->
	<cffunction name="reload" output="false" access="public" returntype="void" hint="Reload a targeted module">
		<cfargument name="moduleName" type="string" required="true" hint="The module to reload"/>
		<cfscript>
			unload(arguments.moduleName);
			registerModule(arguments.moduleName);
			activateModule(arguments.moduleName);
		</cfscript>
	</cffunction>

	<!--- reloadAll --->
	<cffunction name="reloadAll" output="false" access="public" returntype="void" hint="Reload all modules">
		<cfscript>
			unloadAll();
			registerAllModules();
			activateAllModules();
		</cfscript>
	</cffunction>

	<!--- getLoadedModules --->
	<cffunction name="getLoadedModules" output="false" access="public" returntype="array" hint="Get a listing of all loaded modules">
		<cfscript>
			var modules = structKeyList(controller.getSetting("modules"));

			return listToArray(modules);
		</cfscript>
	</cffunction>

	<!--- unload --->
	<cffunction name="unload" output="false" access="public" returntype="boolean" hint="Unload a module if found from the configuration">
		<cfargument name="moduleName" type="string" required="true" hint="The module name to unload"/>
		<cfscript>
			// This method basically unregisters the module configuration
			var appConfig = controller.getConfigSettings();
			var iData = {moduleName=arguments.moduleName};
			var interceptorService = controller.getInterceptorService();
			var x = 1;

			// Check if module is loaded?
			if( NOT structKeyExists(appConfig.modules,arguments.moduleName) ){ return false; }

		</cfscript>

		<cflock name="module.unload.#arguments.moduleName#" type="exclusive" timeout="20" throwontimeout="true">
		<cfscript>
			// Check if module is loaded?
			if( NOT structKeyExists(appConfig.modules,arguments.moduleName) ){ return false; }

			// Before unloading a module interception
			interceptorService.processState("preModuleUnload",iData);

			// Call on module configuration object onLoad() if found
			if( structKeyExists(instance.mConfigCache[arguments.moduleName],"onUnload") ){
				instance.mConfigCache[arguments.moduleName].onUnload();
			}

			// Unregister all interceptors
			for(x=1; x lte arrayLen(appConfig.modules[arguments.moduleName].interceptors); x++){
				interceptorService.unregister(appConfig.modules[arguments.moduleName].interceptors[x].name);
			}

			//Remove Model Mapping Location
			controller.getPlugin("BeanFactory").removeExternalLocations(appConfig.modules[arguments.moduleName].invocationPath & "." & "model");

			// Remove configuration
			structDelete(appConfig.modules, arguments.moduleName);

			// Remove Configuration object from Cache
			structDelete(instance.mConfigCache,arguments.moduleName);

			//After unloading a module interception
			interceptorService.processState("postModuleUnload",iData);

			// Log it
			instance.logger.debug("Module #arguments.moduleName# unloaded successfully.");
		</cfscript>
		</cflock>

		<cfreturn true>
	</cffunction>

	<!--- unloadAll --->
	<cffunction name="unloadAll" output="false" access="public" returntype="void" hint="Unload all registered modules">
		<cfscript>
			// This method basically unregisters the module configuration
			var modules = controller.getSetting("modules");
			var key = "";

			// Unload all modules
			for(key in modules){
				unload(key);
			}
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
			oConfig.injectPropertyMixin("log",controller.getLogBox().getLogger(oConfig));

			//Configure the module
			oConfig.configure();

			//Get Public Module Properties
			mConfig.title 				= oConfig.title;
			mConfig.author 				= oConfig.author;
			mConfig.webURL				= oConfig.webURL;
			mConfig.description 		= oConfig.description;
			mConfig.version				= oConfig.version;

			// Optional Properties
			mConfig.viewParentLookup 	= true;
			if( structKeyExists(oConfig,"viewParentLookup") ){
				mConfig.viewParentLookup 	= oConfig.viewParentLookup;
			}
			mConfig.layoutParentLookup  = true;
			if( structKeyExists(oConfig,"layoutParentLookup") ){
				mConfig.layoutParentLookup 	= oConfig.layoutParentLookup;
			}
			mConfig.entryPoint  = "";
			if( structKeyExists(oConfig,"entryPoint") ){
				mConfig.entryPoint 	= oConfig.entryPoint;
			}

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
			mConfig.interceptorSettings = oConfig.getPropertyMixin("interceptorSettings","variables",structnew());
			if( NOT structKeyExists(mConfig.interceptorSettings,"customInterceptionPoints") ){
				mConfig.interceptorSettings.customInterceptionPoints = "";
			}
			
			//Get Routes
			mConfig.routes = oConfig.getPropertyMixin("routes","variables",arrayNew(1));

			//Get Model Mappings
			mConfig.modelMappings = oConfig.getPropertyMixin("modelMappings","variables",structnew());
			
			// Get and Append Module conventions
			structAppend(mConfig.conventions,oConfig.getPropertyMixin("conventions","variables",structnew()),true);
			
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

	<!--- canLoad --->
    <cffunction name="canLoad" output="false" access="private" returntype="boolean" hint="Checks if the module can be loaded or registered">
  		<cfargument name="moduleName" type="string" required="true" hint="The module name"/>
  		<cfscript>
    		var excludeModules = controller.getSetting("ModulesExclude");

			// If we have excludes and in the excludes
			if( len(excludeModules) and listFindNoCase(excludeModules,arguments.moduleName) ){
				return false;
			}

			return true;
    	</cfscript>
    </cffunction>


</cfcomponent>