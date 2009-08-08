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
			
			// Local logger defined later
			instance.logger = "";
			
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Config Loader Method --->
	<cffunction name="configLoader" returntype="void" access="Public" hint="I Load the configurations only, init the framework variables and more." output="false">
		<!--- ************************************************************* --->
		<cfargument name="overrideConfigFile" required="false" type="string" default="" hint="Only used for unit testing or reparsing of a specific coldbox config file.">
		<cfargument name="overrideAppMapping" required="false" type="string" default="" hint="Only used for unit testing or reparsing of a specific coldbox config file."/>
		<!--- ************************************************************* --->
		<cfscript>
			var XMLParser = "";
			var CacheConfig = CreateObject("Component","coldbox.system.cache.config.CacheConfig");
			var DebuggerConfig = CreateObject("Component","coldbox.system.beans.DebuggerConfig");
			var FrameworkSettings = structNew();
			var ConfigSettings = structNew();
			var key = "";
			var services = controller.getServices();
			
			// Clear the Cache Dictionaries, just to make sure.
			controller.getPluginService().clearDictionary();
			controller.getHandlerService().clearDictionaries();
			
			// Create the Cache Container
			controller.setColdboxOCM(createCacheManager());
			
			// Get Parser Reference
			XMLParser = controller.getPlugin("XMLParser");
			
			// Load Global ColdBox Configuration Settings Structure
			FrameworkSettings = XMLParser.loadFramework(arguments.overrideConfigFile);
			controller.setColdboxSettings(FrameworkSettings);
			
			// Create the Cache Config Bean with data from the framework's settings.xml
			CacheConfig.populate(FrameworkSettings);
			controller.getColdboxOCM().configure(CacheConfig);
			
			// Load Application Config Settings Now that framework has been loaded.
			ConfigSettings = XMLParser.parseConfig(arguments.overrideAppMapping);
			controller.setConfigSettings(ConfigSettings);
			
			// Re-Configure LogBox if defined by application
			if( NOT structIsEmpty(configSettings["LogBoxConfig"]) ){
				controller.getLogBox().configure(controller.getLogBox().getConfig());
				controller.setLogger(controller.getLogBox().getLogger("coldbox.system.Controller"));
			}
			//Get Local Logger Now Configured
			instance.logger = controller.getLogBox().getLogger("coldbox.system.services.LoaderService");
			
			// Check for Cache OVerride Settings in Config
			if ( ConfigSettings.CacheSettings.OVERRIDE ){
				//Recreate the Config Bean
				CacheConfig = CacheConfig.init(ConfigSettings.CacheSettings.ObjectDefaultTimeout,
											   ConfigSettings.CacheSettings.ObjectDefaultLastAccessTimeout,
											   ConfigSettings.CacheSettings.ReapFrequency,
											   ConfigSettings.CacheSettings.MaxObjects,
											   ConfigSettings.CacheSettings.FreeMemoryPercentageThreshold,
											   ConfigSettings.CacheSettings.UseLastAccessTimeouts,
											   ConfigSettings.CacheSettings.EvictionPolicy);
				//Re-Configure the Object Cache.
				controller.getColdboxOCM().configure(CacheConfig);
			}
			
			// Configure the Debugger For Usage
			DebuggerConfig.populate(ConfigSettings.DebuggerSettings);
			controller.getDebuggerService().setDebuggerConfig(DebuggerConfig);
			
			// Execute onConfigurationLoad for services()
			for(key in services){
				services[key].onConfigurationLoad();
			}
			
			// Flag the initiation, Framework is ready to serve requests. Praise be to GOD.
			controller.setColdboxInitiated(true);
			
			// Execute afterConfigurationLoad
			controller.getInterceptorService().processState("afterConfigurationLoad");
			
			// Register Aspects
			registerAspects();
			
			// Execute onAspectsLoad on services
			for(key in services){
				services[key].onAspectsLoad();
			}
			
			// Execute afterAspectsLoad
			controller.getInterceptorService().processState("afterAspectsLoad");			
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
		
		// Init Model Integration
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
		
		// Flag the aspects inited.
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
    <cffunction name="createCacheManager" output="false" access="public" returntype="coldbox.system.cache.CacheManager" hint="Create the object cache manager">
    	<cfscript>
    		if ( controller.oCFMLENGINE.isMT() ){
				return CreateObject("component","coldbox.system.cache.MTCacheManager").init(controller);
			}
			else{
				return CreateObject("component","coldbox.system.cache.CacheManager").init(controller);
			}
    	</cfscript>
    </cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------->

	

</cfcomponent>