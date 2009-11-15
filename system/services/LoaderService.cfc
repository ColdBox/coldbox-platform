<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
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
		<cfargument name="overrideConfigFile" required="false" type="string" default="" hint="Only used for unit testing or reparsing of a specific coldbox config file.">
		<cfargument name="overrideAppMapping" required="false" type="string" default="" hint="Only used for unit testing or reparsing of a specific coldbox config file."/>
		<!--- ************************************************************* --->
		<cfscript>
		var debuggerConfig = createObject("Component","coldbox.system.beans.DebuggerConfig").init();
		var coldBoxSettings = controller.getColdBoxSettings();
		var key = "";
		var services = controller.getServices();
		
		// Overriding the config file location? Maybe unit testing?
		if( len(arguments.overrideConfigFile) ){
			coldboxSettings["ConfigFileLocation"] = getUtil().getAbsolutePath(arguments.overrideConfigFile);
		}
		
		// Load application configuration file
		createAppLoader().loadConfiguration(arguments.overrideAppMapping);
		
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
			javaLoader = controller.getPlugin("JavaLoader");
			javaLoader.setup( javaLoader.queryJars(controller.getSetting('javaloader_libpath')) );
		}
		
		// init Model Integration
		controller.getPlugin("BeanFactory");
		
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
		
		logBoxConfig = createObject("component","coldbox.system.logging.config.LogBoxConfig").init(expandPath("/coldbox/system/config/LogBox.xml"));
		
		return createObject("component","coldbox.system.logging.LogBox").init(logBoxConfig,controller);
    	</cfscript>
    </cffunction>
	
	<!--- createCacheManager --->
    <cffunction name="createCacheManager" output="false" access="public" returntype="coldbox.system.cache.CacheManager" hint="Create the cboxCache provider">
    	<cfscript>
		// Create cache Config
		var cacheConfig = createObject("Component","coldbox.system.cache.config.CacheConfig");
		var cache = "";
		
		// populate configuratio from loaded application
		cacheConfig.populate(controller.getSetting("cacheSettings"));
		
		// Create according cache manager
   		if ( controller.getCFMLEngine().isMT() ){
			cache = CreateObject("component","coldbox.system.cache.MTCacheManager").init(controller);
		}
		else{
			cache = CreateObject("component","coldbox.system.cache.CacheManager").init(controller);
		}
		
		// Configure the cache
		cache.configure(cacheConfig);		
		
		return cache;	
    	</cfscript>
    </cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------->
	
	<!--- createAppLoader --->
	<cffunction name="createAppLoader" output="false" access="private" returntype="coldbox.system.web.loader.AbstractApplicationLoader" hint="Detect the application loader to use and create it">
		<cfscript>
		// Load app loader determined by file extension, only XML or CFC allowed
		if( listLast(controller.getSetting("configFileLocation",true),".")  eq "cfc" ){
			instance.appLoader = createObject("component","coldbox.system.web.loader.CFCApplicationLoader").init(controller);
		}
		else{
			instance.appLoader = createObject("component","coldbox.system.web.loader.XMLApplicationLoader").init(controller);
		}
		
		return instance.appLoader;
		</cfscript>
	</cffunction>
	

</cfcomponent>