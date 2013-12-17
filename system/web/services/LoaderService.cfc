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
			setController( arguments.controller );

			// service properties
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
		var debuggerConfig 	= createObject("Component","coldbox.system.web.config.DebuggerConfig").init();
		var coldBoxSettings = controller.getColdBoxSettings();
		var key 			= "";
		var services 		= controller.getServices();

		// Load application configuration file
		createAppLoader( arguments.overrideConfigFile ).loadConfiguration( arguments.overrideAppMapping );
		
		// Do we need to create a controller decorator?
		if( len( controller.getSetting("ControllerDecorator") ) ){
			createControllerDecorator();
		}
		
		// Check if application has loaded logbox settings so we can reconfigure, else using defaults.
		if( NOT structIsEmpty( controller.getSetting("LogBoxConfig") ) ){
			// reconfigure LogBox with user configurations
			controller.getLogBox().configure( controller.getLogBox().getConfig() );
			// Reset the controller main logger
			controller.setLog( controller.getLogBox().getLogger( controller ) );
		}

		// Configure the application debugger with user settings
		debuggerConfig.populate( controller.getSetting("DebuggerSettings") );
		controller.getDebuggerService().setDebuggerConfig( debuggerConfig );
		// Clear the Cache Dictionaries, just to make sure, we are in reload mode.
		controller.getHandlerService().clearDictionaries();
		// Configure interceptors for operation from the configuration file
		controller.getInterceptorService().configure();
		// Create CacheBox
		createCacheBox();
		// Configure plugins for operation from the configuration file, we need caching enabled first
		controller.getPluginService().configure();
		// Create WireBox Container
		createWireBox();
		// Execute onConfigurationLoad for coldbox internal services()
		for(key in services){
			services[key].onConfigurationLoad();
		}
		// Flag the initiation, Framework is ready to serve requests. Praise be to GOD.
		controller.setColdboxInitiated(true);
		// Activate Modules
		controller.getModuleService().activateAllModules();
		// Execute afterConfigurationLoad
		controller.getInterceptorService().processState("afterConfigurationLoad");
		// Register Aspects
		registerAspects();
		// Execute afterAspectsLoad
		controller.getInterceptorService().processState("afterAspectsLoad");
		// We are now done, rock and roll!!
		</cfscript>
	</cffunction>
	
	<!--- createControllerDecorator --->
    <cffunction name="createControllerDecorator" output="false" access="public" returntype="void" hint="Create Controller Decorator">
    	<cfscript>
			// create decorator
    		var decorator 	= createObject("component", controller.getSetting("ControllerDecorator") ).init( controller );
    		var services  	= controller.getServices();
    		var key			= "";
    		
    		// Call configuration on it
    		decorator.configure();
    		// Override in persistence scope
    		application[ controller.getAppKey() ] = decorator;
    		// Override locally now in all services
    		for( key in services ){
    			services[ key ].setController( decorator );
    		}
    	</cfscript>
    </cffunction>

	<!--- Register the Aspects --->
	<cffunction name="registerAspects" access="public" returntype="void" hint="I Register the current Application's Aspects" output="false" >
		<cfscript>
		var javaLoader 			= "";
		var validationManager 	= "";
		var validationData 		= controller.getSetting("validation");

		// Activate Flash RAM
		controller.getRequestService().buildFlashScope();
	
		// if engine allows it, create validation engine
		if( controller.getCFMLEngine().isValidationSupported() ){
			// construct the validation manager specified in the config
			validationManager = controller.getWireBox().getInstance(name=validationData.manager);
			validationManager.setSharedConstraints( validationData.sharedConstraints );
			// store it as singleton manually in controller.
			controller.setValidationManager( validationManager );
			// map the manager into wirebox for retrievals
			controller.getWireBox().getBinder().map("WireBoxValidationManagerPath").toValue( validationData.manager );
			controller.getWireBox().getBinder().map("WireBoxValidationManager").toValue( validationManager );
		}

		// Init JavaLoader with paths if set as settings.
		if( controller.settingExists("javaloader_libpath") ){
			controller.getPlugin("JavaLoader");
		}

		// IoC Plugin Manager Configuration
		if ( len(controller.getSetting("IOCFramework")) ){
			//Create IoC Factory and configure it.
			controller.getPlugin("IOC").configure();
		}

		// Load i18N if application is using it.
		if ( controller.getSetting("using_i18N") ){
			//Create i18n Plugin and configure it.
			controller.getPlugin("i18n").init_i18N();
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
			controller.getWireBox().init(wireboxData.binderPath, controller.getConfigSettings(), controller);
    	</cfscript>
    </cffunction>

	<!--- createCacheBox --->
    <cffunction name="createCacheBox" output="false" access="public" returntype="void" hint="Create the application's CacheBox instance">
    	<cfscript>
    		var config 				= createObject("Component","coldbox.system.cache.config.CacheBoxConfig").init();
			var cacheBoxSettings 	= controller.getSetting("cacheBox");
			var cacheBox			= "";

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
			controller.getCacheBox().init(config,controller);
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
			cacheBox.shutdown();

			// Shutdown WireBox
			if( isObject(wireBox) ){
				wireBox.shutdown();
			}
		</cfscript>
    </cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->

	<!--- createAppLoader --->
	<cffunction name="createAppLoader" output="false" access="private" returntype="any" hint="Setups the variable for ColdBox loading" colddoc:generic="coldbox.system.web.loader.AbstractApplicationLoader">
		<cfargument name="overrideConfigFile" required="false" default="" hint="Only used for unit testing or reparsing of a specific coldbox config file.">
		<cfscript>
		var coldBoxSettings 	= controller.getColdBoxSettings();
		var appRootPath 		= controller.getAppRootPath();
		var configFileLocation 	= coldboxSettings.configConvention;

		// Overriding Marker defaults to false
		coldboxSettings["ConfigFileLocationOverride"] = false;

		// verify coldbox.cfc exists in convention: /app/config/Coldbox.cfc
		if( fileExists( appRootPath & replace(configFileLocation,".","/","all") & ".cfc" ) ){
			coldboxSettings["ConfigFileLocation"] = configFileLocation;
		}

		// Overriding the config file location? Maybe unit testing?
		if( len( arguments.overrideConfigFile ) ){
			coldboxSettings["ConfigFileLocation"] 			= arguments.overrideConfigFile;
			coldboxSettings["ConfigFileLocationOverride"] 	= true;
		}

		// If no config file location throw exception
		if( NOT len( coldboxSettings["ConfigFileLocation"] ) ){
			getUtil().throwit(message="Config file not located in conventions: #coldboxSettings.configConvention#",detail="",type="LoaderService.ConfigFileNotFound");
		}

		// Create it and return it now that config file location is set in the location settings
		instance.appLoader = createObject("component","coldbox.system.web.loader.CFCApplicationLoader").init( controller );

		return instance.appLoader;
		</cfscript>
	</cffunction>

</cfcomponent>