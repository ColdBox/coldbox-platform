﻿/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * This service loads and configures a ColdBox application for operation
 */
component extends="coldbox.system.web.services.BaseService" accessors="true" {

	/**
	 * Constructor
	 *
	 * @controller The controller instance to bind the service with
	 */
	function init( required controller ){
		variables.controller = arguments.controller;
		variables.log        = "";
		return this;
	}

	/**
	 * Loads a ColdBox application with all of it's services
	 *
	 * @overrideConfigFile The configuration file to load the application with
	 * @overrideAppMapping The direct location of the application in the web server
	 * @overrideWebMapping The direct location of the application's web root in the server
	 *
	 * @return The LoaderService
	 */
	LoaderService function loadApplication(
		overrideConfigFile = "",
		overrideAppMapping = "",
		overrideWebMapping = ""
	){
		// Load application configuration file
		createAppLoader( arguments.overrideConfigFile ).loadConfiguration(
			arguments.overrideAppMapping,
			arguments.overrideWebMapping
		);
		// Prep services
		var coldBoxSettings = variables.controller.getColdBoxSettings();
		var services        = variables.controller.getServices();
		var configSettings  = variables.controller.getConfigSettings();

		// Do we need to create a controller decorator?
		if ( len( configSettings.controllerDecorator ) ) {
			createControllerDecorator();
		}

		// Check if application has loaded logbox settings so we can reconfigure, else using defaults.
		if ( NOT structIsEmpty( configSettings.logBoxConfig ) ) {
			// reconfigure LogBox with user configurations
			variables.controller.getLogBox().configure( variables.controller.getLogBox().getConfig() );
			// Reset the controller main logger
			variables.controller.setLog( variables.controller.getLogBox().getLogger( variables.controller ) );
		}

		// Seed a local logger
		variables.log = variables.controller.getLogBox().getLogger( this );
		// Clear the Cache Dictionaries, just to make sure, we are in reload mode.
		services.handlerService.clearDictionaries();
		// Configure interceptors for operation from the configuration file
		services.interceptorService.configure();

		// Create WireBox Container
		createWireBox();
		// Create CacheBox
		createCacheBox();

		// Execute onConfigurationLoad for coldbox internal services()
		for ( var thisService in services ) {
			services[ thisService ].onConfigurationLoad();
			variables.log.info( "+ #thisService# configured" );
		}

		// Auto Map Root Models
		if ( configSettings.autoMapModels && directoryExists( configSettings.modelsPath ) ) {
			variables.controller
				.getWireBox()
				.getBinder()
				.mapDirectory( configSettings.ModelsInvocationPath );
			variables.log.info( "+ Automatically mapped all root models" );
		}

		// Load up App Executors
		createAppExecutors();

		// Activate All Modules
		services.moduleService.activateAllModules();
		// Execute afterConfigurationLoad
		services.interceptorService.announce( "afterConfigurationLoad" );
		// Rescan interceptors in case modules had interception points to register
		services.interceptorService.rescanInterceptors();
		// Rebuild flash here just in case modules or afterConfigurationLoad changes settings.
		services.requestService.rebuildFlashScope();
		// Internal event for interceptors to load global UDF Helpers
		services.interceptorService.announce( "cbLoadInterceptorHelpers" );
		// Load up the global app scheduler, to guarantee all modules are loaded
		services.schedulerService.loadGlobalScheduler();
		// Startup the renderer for operation
		variables.controller.getRenderer().startup();
		// Execute afterAspectsLoad: all module interceptions are registered and flash rebuilt if needed
		services.interceptorService.announce( "afterAspectsLoad" );
		// Flag the initiation, Framework is ready to serve requests. Praise be to GOD.
		variables.controller.setColdboxInitiated( true );
		// Startup the schedulers now that the entire application has been loaded and runnning
		services.schedulerService.startupSchedulers();
		// Log it
		variables.log.info( "+++ ColdBox is ready to serve requests" );

		// We are now done, rock and roll!!
		return this;
	}

	/**
	 * Create and register the application's executors
	 */
	LoaderService function createAppExecutors(){
		variables.controller
			.getSetting( "executors" )
			.each( function( key, config ){
				arguments.config.name = arguments.key;
				variables.controller.getAsyncManager().newExecutor( argumentCollection = arguments.config );
				variables.log.info( "+ Registered App Executor: #arguments.key#" );
			} );
		return this;
	}

	/**
	 * Create the controller decorator
	 */
	LoaderService function createControllerDecorator(){
		// create decorator
		var decorator = createObject( "component", controller.getSetting( "ControllerDecorator" ) ).init(
			variables.controller
		);
		var services = variables.controller.getServices();

		// Call configuration on it
		decorator.configure();
		// Override in persistence scope
		application[ variables.controller.getAppKey() ] = decorator;

		// Override locally now in all services
		for ( var thisService in services ) {
			services[ thisService ].setController( decorator );
		}

		return this;
	}

	/**
	 * Create a new running LogBox instance configured using ColdBox's default config (coldbox.system.web.config.LogBox)
	 *
	 * @return coldbox.system.logging.LogBox
	 */
	function createDefaultLogBox(){
		return new coldbox.system.logging.LogBox(
			new coldbox.system.logging.config.LogBoxConfig( CFCConfigPath: "coldbox.system.web.config.LogBox" ),
			variables.controller
		);
	}

	/**
	 * Create the main ColdBox Injector instance and map all ColdBox Global Classes
	 */
	LoaderService function createWireBox(){
		var wireboxData = variables.controller.getSetting( "WireBox" );
		// Setup the WireBox instance
		variables.controller
			.getWireBox()
			.init(
				wireboxData.binderPath,
				variables.controller.getConfigSettings(),
				variables.controller
			);

		variables.log.info( "+ Application's WireBox configured" );

		var binder = controller.getWireBox().getBinder();

		// Map Renderer
		binder.map( "Renderer@coldbox" ).to( "coldbox.system.web.Renderer" );
		// Map Data Marshaller
		binder.map( "DataMarshaller@coldbox" ).to( "coldbox.system.core.conversion.DataMarshaller" );
		// Map XML Converter
		binder.map( "XMLConverter@coldbox" ).to( "coldbox.system.core.conversion.XMLConverter" );
		// Map Object Converter
		binder.map( "ObjectMarshaller@coldbox" ).to( "coldbox.system.core.conversion.ObjectMarshaller" );
		// Map Async Manager
		binder
			.map( "AsyncManager@coldbox" )
			.toProvider( function(){
				return variables.controller.getAsyncManager();
			} );
		// Map Delegates: core and ColdBox based delegates
		binder.mapDirectory( packagePath = "coldbox.system.core.delegates", namespace = "@coreDelegates" );
		binder.mapDirectory( packagePath = "coldbox.system.web.delegates", namespace = "@cbDelegates" );

		variables.log.info( "+ ColdBox Global Classes registered" );

		return this;
	}

	/**
	 * Create the application's CacheBox instance
	 */
	LoaderService function createCacheBox(){
		var config           = new coldbox.system.cache.config.CacheBoxConfig();
		var cacheBoxSettings = controller.getSetting( "cacheBox" );
		var cacheBox         = "";

		// Load by File
		if ( len( cacheBoxSettings.configFile ) ) {
			// load by config file type
			if ( listLast( cacheBoxSettings.configFile, "." ) eq "xml" ) {
				config.init( XMLConfig = cacheBoxSettings.configFile );
			} else {
				config.init( CFCConfigPath = cacheBoxSettings.configFile );
			}
		}
		// Load by DSL
		else if ( NOT structIsEmpty( cacheBoxSettings.dsl ) ) {
			config.loadDataDSL( cacheBoxSettings.dsl );
		}
		// Load by XML
		else {
			config.parseAndLoad( cacheBoxSettings.xml );
		}

		// Create CacheBox
		variables.controller.getCacheBox().init( config, variables.controller );

		variables.log.info( "+ Application's CacheBox configured" );

		return this;
	}

	/**
	 * Process the shutdown of the application
	 *
	 * @force If true, it forces all shutdowns this is usually true when doing reinits
	 */
	LoaderService function processShutdown( boolean force = false ){
		if ( !isSimpleValue( variables.log ) ) {
			variables.log.info( "† Shutting down ColdBox..." );
		}

		// Announce shutdown
		variables.controller.getInterceptorService().announce( "onColdBoxShutdown" );

		// Start shutting things down
		var wireBox = variables.controller.getWireBox();

		// Process services reinit
		structEach( variables.controller.getServices(), function( key, thisService ){
			if ( !isSimpleValue( variables.log ) ) {
				variables.log.info( "† Shutting down ColdBox #arguments.key# service..." );
			}
			thisService.onShutdown( force = force );
		} );

		// Shutdown any services like cache engine, etc.
		if ( !isSimpleValue( variables.log ) ) {
			variables.log.info( "† Shutting down CacheBox..." );
		}
		variables.controller.getCacheBox().shutdown();

		// Shutdown WireBox if it exists
		if ( isObject( wirebox ) ) {
			if ( !isSimpleValue( variables.log ) ) {
				variables.log.info( "† Shutting down WireBox..." );
			}
			wirebox.shutdown();
		}

		// Shutdown all ColdBox Scheduler Tasks, no need to delete them as WireBox will be nuked!
		if ( !isSimpleValue( variables.log ) ) {
			variables.log.info( "† Shutting down ColdBox Task Scheduler..." );
		}

		try {
			var asyncManager = wirebox.getInstance( "AsyncManager@coldbox" );
			asyncManager.shutdownAllExecutors( force = arguments.force );
		} catch ( any e ) {
			if ( !isSimpleValue( variables.log ) && variables.log.canError() ) {
				variables.log.error( "† Error getting the async manager to shutdown all executors...", e );
			}
		}

		// Shutdown LogBox LAST
		if ( !isSimpleValue( variables.log ) ) {
			variables.log.info( "† Shutting down LogBox..." );
		}
		variables.controller.getLogBox().shutdown();

		return this;
	}

	/**************************************** PRIVATE ************************************************/

	/**
	 * Creates the application loader
	 *
	 * @overrideConfigFile Only used for unit testing or reparsing of a specific coldbox config file
	 *
	 * @return coldbox.system.web.config.ApplicationLoader
	 */
	function createAppLoader( overrideConfigFile = "" ){
		var coldBoxSettings    = variables.controller.getColdBoxSettings();
		var appRootPath        = variables.controller.getAppRootPath();
		var configFileLocation = coldboxSettings.configConvention;

		// Overriding Marker defaults to false
		coldboxSettings[ "ConfigFileLocationOverride" ] = false;

		// verify coldbox.cfc exists in convention: /app/config/Coldbox.cfc
		if (
			fileExists( appRootPath & replace( configFileLocation, ".", "/", "all" ) & ".cfc" ) || fileExists(
				appRootPath & replace( configFileLocation, ".", "/", "all" ) & ".bx"
			)
		) {
			coldboxSettings[ "ConfigFileLocation" ] = configFileLocation;
		}

		// Overriding the config file location? Maybe unit testing?
		if ( len( arguments.overrideConfigFile ) ) {
			coldboxSettings[ "ConfigFileLocation" ]         = arguments.overrideConfigFile;
			coldboxSettings[ "ConfigFileLocationOverride" ] = true;
		}

		// Create it and return it now that config file location is set in the location settings
		return new coldbox.system.web.config.ApplicationLoader( variables.controller );
	}

}
