/**
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
* ---
* This service loads and configures a ColdBox application for operation
*/
component extends="coldbox.system.web.services.BaseService"{

	/**
	* Constructor
	*/
	function init( required controller ){
		variables.controller = arguments.controller;
		return this;
	}

	/**
	* Load a ColdBox application
	* @overrideConfigFile The configuration file to load the application with
	* @overrideAppMapping The direct location of the application in the web server
	*/
	LoaderService function loadApplication( overrideConfigFile="", overrideAppMapping="" ){
		var coldBoxSettings = controller.getColdBoxSettings();
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

		// Clear the Cache Dictionaries, just to make sure, we are in reload mode.
		controller.getHandlerService().clearDictionaries();
		// Configure interceptors for operation from the configuration file
		controller.getInterceptorService().configure();
		// Create CacheBox
		createCacheBox();
		// Create WireBox Container
		createWireBox();
		// Execute onConfigurationLoad for coldbox internal services()
		for( var key in services ){
			services[ key ].onConfigurationLoad();
		}
		// Flag the initiation, Framework is ready to serve requests. Praise be to GOD.
		controller.setColdboxInitiated( true );
		// Activate All Modules
		controller.getModuleService().activateAllModules();
		// Execute afterConfigurationLoad
		controller.getInterceptorService().processState( "afterConfigurationLoad" );
		// Rebuild flash here just in case modules or afterConfigurationLoad changes settings.
		controller.getRequestService().rebuildFlashScope();
		// Execute afterAspectsLoad: Deprecate at one point, no more aspects as all are modules now.
		controller.getInterceptorService().processState( "afterAspectsLoad" );
		// We are now done, rock and roll!!
		return this;
	}

	/**
	* Create the controller decorator
	*/
	LoaderService function createControllerDecorator(){
		// create decorator
		var decorator 	= createObject("component", controller.getSetting("ControllerDecorator") ).init( controller );
		var services  	= controller.getServices();

		// Call configuration on it
		decorator.configure();
		// Override in persistence scope
		application[ controller.getAppKey() ] = decorator;
		// Override locally now in all services
		for( var key in services ){
			services[ key ].setController( decorator );
		}
		return this;
	}

	/**
	* Create a running LogBox instance configured using ColdBox's default config
	* 
	* @return coldbox.system.logging.LogBox
	*/
	function createDefaultLogBox(){
		var logBoxConfig = "";

		logBoxConfig = new coldbox.system.logging.config.LogBoxConfig( CFCConfigPath="coldbox.system.web.config.LogBox" );

		return new coldbox.system.logging.LogBox( logBoxConfig, controller );
	}

	/**
	* Create WireBox DI Framework with configuration settings.
	*/
	LoaderService function createWireBox(){
		var wireboxData = controller.getSetting( "WireBox" );
		controller.getWireBox().init( wireboxData.binderPath, controller.getConfigSettings(), controller );

		// Map ColdBox Utility Objects
		var binder = controller.getWireBox().getBinder();

		// Map HTML Helper
		binder.map( "HTMLHelper@coldbox" )
			.to( "coldbox.system.core.dynamic.HTMLHelper" );
		// Map Renderer
		binder.map( "Renderer@coldbox" )
			.to( "coldbox.system.web.Renderer" );
		// Map Data Marshaller
		binder.map( "DataMarshaller@coldbox" )
			.to( "coldbox.system.core.conversion.DataMarshaller" );
		// Map XML Converter
		binder.map( "XMLConverter@coldbox" )
			.to( "coldbox.system.core.conversion.XMLConverter" );
		// Map Object Converter
		binder.map( "ObjectMarshaller@coldbox" )
			.to( "coldbox.system.core.conversion.ObjectMarshaller" );

		return this;
	}
	
	/**
	* Create the application's CacheBox instance
	*/
	LoaderService function createCacheBox(){
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
		return this;
	}
	
	/**
	* Process the shutdown of the application
	*/
	LoaderService function processShutdown(){
		var services = controller.getServices();
		var cacheBox = controller.getCacheBox();
		var wireBox  = controller.getWireBox();

		// Process services reinit
		for( var key in services ){
			services[ key ].onShutdown();
		}
		// Shutdown any services like cache engine, etc.
		cacheBox.shutdown();

		// Shutdown WireBox
		if( isObject( wireBox ) ){
			wireBox.shutdown();
		}
		return this;
	}
	
	/**************************************** PRIVATE ************************************************/

	/**
	* Creates the application loader
	* @overrideConfigFile Only used for unit testing or reparsing of a specific coldbox config file 
	*/
	function createAppLoader( overrideConfigFile="" ){
		var coldBoxSettings 	= controller.getColdBoxSettings();
		var appRootPath 		= controller.getAppRootPath();
		var configFileLocation 	= coldboxSettings.configConvention;

		// Overriding Marker defaults to false
		coldboxSettings[ "ConfigFileLocationOverride" ] = false;

		// verify coldbox.cfc exists in convention: /app/config/Coldbox.cfc
		if( fileExists( appRootPath & replace( configFileLocation, ".", "/", "all" ) & ".cfc" ) ){
			coldboxSettings[ "ConfigFileLocation" ] = configFileLocation;
		}

		// Overriding the config file location? Maybe unit testing?
		if( len( arguments.overrideConfigFile ) ){
			coldboxSettings[ "ConfigFileLocation" ] 			= arguments.overrideConfigFile;
			coldboxSettings[ "ConfigFileLocationOverride" ] 	= true;
		}

		// Create it and return it now that config file location is set in the location settings
		return new coldbox.system.web.config.ApplicationLoader( controller );
	}

}