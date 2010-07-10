<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date        :	January 18, 2007
Description :
	This cfc takes care of debugging settings.

Modification History:
01/18/2007 - Created
----------------------------------------------------------------------->
<cfcomponent name="LoaderService" output="false" hint="The application and framework loader service" extends="coldbox.system.services.BaseService">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" output="false" returntype="LoaderService" hint="Constructor">
		<cfargument name="controller" type="any" required="true">
		<cfscript>
			setController(arguments.controller);
			
			// service properties
			instance.logger = "";
			instance.appLoader = "";
			
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Get App Loader --->
	<cffunction name="getAppLoader" access="public" returntype="coldbox.system.web.loader.AbstractApplicationLoader" output="false" hint="Get the application configuration loader used">
		<cfreturn instance.appLoader>
	</cffunction>
	
	<!--- Config Loader Method --->
	<cffunction name="loadApplication" returntype="void" access="Public" hint="I load a coldbox application for operation." output="false">
		<!--- ************************************************************* --->
		<cfargument name="overrideConfigFile" required="false" type="string" default="" hint="The configuration file to load the application with">
		<cfargument name="overrideAppMapping" required="false" type="string" default="" hint="The direct location of the application in the web server."/>
		<!--- ************************************************************* --->
		<cfscript>
		var debuggerConfig = createObject("Component","coldbox.system.beans.DebuggerConfig").init();
		var coldBoxSettings = controller.getColdBoxSettings();
		var key = "";
		var services = controller.getServices();
		
		// Load application configuration file
		createAppLoader(arguments.overrideConfigFile).loadConfiguration(arguments.overrideAppMapping);
		
		// Check if application has loaded logbox settings so we can reconfigure, else using defaults.
		if( NOT structIsEmpty( controller.getSetting("LogBoxConfig") ) ){
			// reconfigure LogBox with user configurations
			controller.getLogBox().configure(controller.getLogBox().getConfig());
			// Reset the controller main logger
			controller.setLogger(controller.getLogBox().getLogger(controller));
		}
		
		//Get Local Logger Now Configured
		instance.logger = controller.getLogBox().getLogger(this);
		
		// Configure the application debugger.
		debuggerConfig.populate(controller.getSetting("DebuggerSettings"));
		controller.getDebuggerService().setDebuggerConfig(debuggerConfig);
		
		// Clear the Cache Dictionaries, just to make sure, we are in reload mode.
		controller.getPluginService().clearDictionary();
		controller.getHandlerService().clearDictionaries();
		
		// Create the Cache Container
		controller.setColdboxOCM(createCacheManager());
		
		// Execute onConfigurationLoad for coldbox internal services()
		for(key in services){
			services[key].onConfigurationLoad();
		}
		
		// Create WireBox
		controller.getPlugin("BeanFactory");
		
		// Flag the initiation, Framework is ready to serve requests. Praise be to GOD.
		controller.setColdboxInitiated(true);
		
		// Execute afterConfigurationLoad
		controller.getInterceptorService().processState("afterConfigurationLoad");
		
		// Register Aspects
		registerAspects();
		
		// Execute onAspectsLoad on coldbox internal services
		for(key in services){
			services[key].onAspectsLoad();
		}
		
		// Execute afterAspectsLoad
		controller.getInterceptorService().processState("afterAspectsLoad");
		
		// We are now done, rock and roll!!			
		</cfscript>
	</cffunction>

	<!--- Register the Aspects --->
	<cffunction name="registerAspects" access="public" returntype="void" hint="I Register the current Application's Aspects" output="false" >
		<cfscript>
		var javaLoader = "";
		
		// Init JavaLoader with paths if set as settings.
		if( controller.settingExists("javaloader_libpath") ){
			controller.getPlugin("JavaLoader");
		}
		
		// IoC Plugin Manager Configuration
		if ( len(controller.getSetting("IOCFramework")) ){
			//Create IoC Factory and configure it.
			controller.getPlugin("IOC");
		}

		// Load i18N if application is using it.
		if ( controller.getSetting("using_i18N") ){
			//Create i18n Plugin and configure it.
			controller.getPlugin("i18n").init_i18N(controller.getSetting("DefaultResourceBundle"),controller.getSetting("DefaultLocale"));
		}		
		
		// Set Debugging Mode according to configuration File
		controller.getDebuggerService().setDebugMode(controller.getSetting("DebugMode"));
		
		// Flag the aspects inited
		controller.setAspectsInitiated(true);
		</cfscript>
	</cffunction>
	
	<!--- createLogBox --->
    <cffunction name="createLogBox" output="false" access="public" returntype="coldbox.system.logging.LogBox" hint="Create a running LogBox instance configured using ColdBox's default config">
    	<cfscript>
   		var logBoxConfig = "";
		
		logBoxConfig = createObject("component","coldbox.system.logging.config.LogBoxConfig").init(CFCConfigPath="coldbox.system.config.LogBox");
		
		return createObject("component","coldbox.system.logging.LogBox").init(logBoxConfig,controller);
    	</cfscript>
    </cffunction>
	
	<!--- createCacheManager --->
    <cffunction name="createCacheManager" output="false" access="public" returntype="any" hint="Create the caching engine">
    	<cfscript>
		// Create cache Config
		var cacheConfig = createObject("Component","coldbox.system.cache.archive.config.CacheConfig");
		var cache = "";
		
		// populate configuratio from loaded application
		cacheConfig.populate(controller.getSetting("cacheSettings"));
		
		// Create according cache manager
   		if ( controller.getCFMLEngine().isMT() ){
			cache = CreateObject("component","coldbox.system.cache.archive.MTCacheManager").init(controller);
		}
		else{
			cache = CreateObject("component","coldbox.system.cache.archive.CacheManager").init(controller);
		}
		
		// Configure the cache
		cache.configure(cacheConfig);		
		
		return cache;	
    	</cfscript>
    </cffunction>
	
	<!--- processShutdown --->
    <cffunction name="processShutdown" output="false" access="public" returntype="void" hint="Process the shutdown of the application">
    	<cfscript>
    		var key 	 = "";
			var services = controller.getServices();
			
    		// Process services reinit
			for(key in services){
				services[key].onShutdown();
			}
			
			// Shutdown any services like cache engine, etc.
			// TODO
		</cfscript>
    </cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------->
	
	<!--- createAppLoader --->
	<cffunction name="createAppLoader" output="false" access="private" returntype="coldbox.system.web.loader.AbstractApplicationLoader" hint="Detect the application loader to use and create it">
		<cfargument name="overrideConfigFile" required="false" type="string" default="" hint="Only used for unit testing or reparsing of a specific coldbox config file.">
		<cfscript>
		var coldBoxSettings = controller.getColdBoxSettings();
		var appRootPath = controller.getAppRootPath();
		var configFileLocations = coldboxSettings.configConvention;
		var x = 1;
		
		// Loop over conventions and load found config file
		for(x=1; x lte listLen(configFileLocations); x=x+1){
			// Verify File Exists
			if( fileExists(appRootPath & listGetAt(configFileLocations,x) ) ){
				coldboxSettings["ConfigFileLocation"] = appRootPath & listGetAt(configFileLocations,x);				
			}			
		}
		
		// Overriding the config file location? Maybe unit testing?
		if( len(arguments.overrideConfigFile) ){
			coldboxSettings["ConfigFileLocation"] = getUtil().getAbsolutePath(arguments.overrideConfigFile);
		}
		
		// If no config file location throw exception
		if( not len(coldboxSettings["ConfigFileLocation"]) ){
			getUtil().throwit(message="Config file not located in conventions: #coldboxSettings.configConvention#",detail="",type="LoaderService.ConfigFileNotFound");
		}
		
		// If CFC loader, then create it and return it
		if( listLast(coldboxSettings["ConfigFileLocation"],".")  eq "cfc" ){
			instance.appLoader = createObject("component","coldbox.system.web.loader.CFCApplicationLoader").init(controller);
			return instance.appLoader;
		}
		
		// Return XML Loader
		instance.appLoader = createObject("component","coldbox.system.web.loader.XMLApplicationLoader").init(controller);
		return instance.appLoader;
		</cfscript>
	</cffunction>
	

</cfcomponent>