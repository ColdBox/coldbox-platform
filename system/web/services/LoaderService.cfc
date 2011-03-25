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
<cfcomponent name="LoaderService" output="false" hint="The application and framework loader service" extends="coldbox.system.web.services.BaseService">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" output="false" returntype="LoaderService" hint="Constructor">
		<cfargument name="controller" type="any" required="true">
		<cfscript>
			setController(arguments.controller);
			
			// service properties
			instance.log = "";
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
		<cfargument name="overrideConfigFile" required="false" default="" hint="The configuration file to load the application with">
		<cfargument name="overrideAppMapping" required="false" default="" hint="The direct location of the application in the web server."/>
		<!--- ************************************************************* --->
		<cfscript>
		var debuggerConfig = createObject("Component","coldbox.system.web.config.DebuggerConfig").init();
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
			controller.setLog(controller.getLogBox().getLogger(controller));
		}
		
		//Get Local Logger Now Configured
		instance.log = controller.getLogBox().getLogger(this);
		
		// Configure the application debugger.
		debuggerConfig.populate(controller.getSetting("DebuggerSettings"));
		controller.getDebuggerService().setDebuggerConfig(debuggerConfig);
		
		// Clear the Cache Dictionaries, just to make sure, we are in reload mode.
		controller.getPluginService().clearDictionary();
		controller.getHandlerService().clearDictionaries();
		
		// Create the Cache Container
		createCacheContainer();
		
		// Create WireBox Container
		createWireBox();
				
		// Execute onConfigurationLoad for coldbox internal services()
		for(key in services){
			services[key].onConfigurationLoad();
		}
		
		// Flag the initiation, Framework is ready to serve requests. Praise be to GOD.
		controller.setColdboxInitiated(true);
		
		// Activate Modules
		if( isObject(controller.getModuleService()) ){
			controller.getModuleService().activateAllModules();
		}
		
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
	
	<!--- createDefaultLogBox --->
    <cffunction name="createDefaultLogBox" output="false" access="public" returntype="coldbox.system.logging.LogBox" hint="Create a running LogBox instance configured using ColdBox's default config">
    	<cfscript>
   		var logBoxConfig = "";
		
		logBoxConfig = createObject("component","coldbox.system.logging.config.LogBoxConfig").init(CFCConfigPath="coldbox.system.web.config.LogBox");
		
		return createObject("component","coldbox.system.logging.LogBox").init(logBoxConfig,controller);
    	</cfscript>
    </cffunction>
	
	<!--- createWireBox --->
    <cffunction name="createWireBox" output="false" access="public" returntype="void" hint="Create WireBox DI Framework with config settings.">
    	<cfscript>
    		var wireboxData = controller.getSetting("WireBox");
			var oInjector	= "";
			
    		// If using cf8 and above then create it with our binder
			if( controller.getCFMLEngine().isMT() AND wireboxData.enabled ){
				oInjector = createObject("component","coldbox.system.ioc.Injector").init(wireboxData.binderPath,controller.getConfigSettings(), controller);
				controller.setWireBox( oInjector );
			}
    	</cfscript>
    </cffunction>
	
	<!--- createCacheBox --->
    <cffunction name="createCacheBox" output="false" access="public" returntype="coldbox.system.cache.CacheFactory" hint="Create the application's CacheBox instance">
    	<cfscript>
    		var config 				= createObject("Component","coldbox.system.cache.config.CacheBoxConfig").init();
			var cacheBoxSettings 	= controller.getSetting("cacheBox");
			
			// Load by File
			if( len(cacheBoxSettings.configFile) ){
				
				// load by config file type
				if( listLast(cacheBoxSettings.configFile,".") eq "xml"){
					config.init(XMLConfig=cacheBoxSettings.configFile);
				}
				else{
					config.init(CFCConfigPath=cacheBoxSettings.configFile);
				}
			}
			// Load by DSL
			else if ( NOT structIsEmpty(cacheBoxSettings.dsl) ){
				config.loadDataDSL( cacheBoxSettings.dsl );
			}
			// Load by XML
			else{
				config.parseAndLoad( cacheBoxSettings.xml );
			}
			
			// Create CacheBox
			return createObject("component","coldbox.system.cache.CacheFactory").init(config,controller);
		</cfscript>
    </cffunction>

	<!--- createCacheContainer --->
    <cffunction name="createCacheContainer" output="false" access="public" returntype="void" hint="Create the cache container">
    	<cfscript>
    		// Determine compat mode or new cachebox mode or pesky cf7 until 3.1
			if( controller.getCFMLEngine().isMT() AND NOT controller.getSetting("cacheSettings").compatMode ){
				// CacheBox creation
				controller.setCacheBox( createCacheBox() );
				return;
			}
			
			// else we are on compatmode
			controller.setColdboxOCM( createCacheManager() );
    	</cfscript>
    </cffunction>

	<!--- createCacheManager --->
    <cffunction name="createCacheManager" output="false" access="public" returntype="any" hint="Create the compatibility caching engine">
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
			var cacheBox = controller.getCacheBox();
			var wireBox = controller.getWireBox();
			
    		// Process services reinit
			for(key in services){
				services[key].onShutdown();
			}
			// Shutdown any services like cache engine, etc.
			if( isObject(cacheBox) ){
				cacheBox.shutdown();
			}
			// Shutdown WireBox
			if( isObject(wireBox) ){
				wireBox.shutdown();
			}
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
		
		// OVerriding Marker
		coldboxSettings["ConfigFileLocationOverride"] = false;
		
		// Loop over conventions and load found config file
		for(x=1; x lte listLen(configFileLocations); x=x+1){
			// Verify File Exists
			if( fileExists(appRootPath & listGetAt(configFileLocations,x) ) ){
				coldboxSettings["ConfigFileLocation"] = appRootPath & listGetAt(configFileLocations,x);				
			}			
		}
		
		// Overriding the config file location? Maybe unit testing?
		if( len(arguments.overrideConfigFile) ){
			coldboxSettings["ConfigFileLocation"] 			= getUtil().getAbsolutePath(arguments.overrideConfigFile);
			coldboxSettings["ConfigFileLocationOverride"] 	= true;
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