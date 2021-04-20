/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * This service manages all schedulers in ColdBox in an HMVC fashion
 */
component extends="coldbox.system.web.services.BaseService" accessors="true" {

	/**
	 * --------------------------------------------------------------------------
	 * Properties
	 * --------------------------------------------------------------------------
	 */

	/**
	 * A collection of schedulers this manager manages
	 */
	property name="schedulers" type="struct";

	/**
	 * Constructor
	 */
	function init( required controller ){
		variables.controller = arguments.controller;
		// Register a fresh collection of schedulers
		variables.schedulers = structNew( "ordered" );

		return this;
	}

	/**
	 * Once configuration loads prepare for operation
	 */
	function onConfigurationLoad(){
		// Prepare references for faster access
		variables.log                = variables.controller.getLogBox().getLogger( this );
		variables.interceptorService = variables.controller.getInterceptorService();
		variables.wirebox            = variables.controller.getWireBox();
		variables.appMapping         = variables.controller.getSetting( "AppMapping" );
		variables.appPath            = variables.controller.getSetting( "applicationPath" );
		variables.baseScheduler      = "coldbox.system.web.tasks.ColdBoxScheduler";
		// Load up the global app scheduler
		loadGlobalScheduler();
	}

	/**
	 * Process a ColdBox service shutdown
	 */
	function onShutdown(){
		variables.schedulers.each( function( name, thisScheduler ){
			variables.log.info( "† Shutting down Scheduler (#arguments.name#)..." );
			arguments.thisScheduler.shutdown();
		} );
	}

	/**
	 * Load the application's global scheduler
	 */
	function loadGlobalScheduler(){
		var appSchedulerConvention = "config.Scheduler";
		var schedulerName          = "appScheduler@coldbox";
		var schedulerPath          = variables.baseScheduler;

		// Check if base scheduler has been mapped?
		if ( NOT variables.wirebox.getBinder().mappingExists( variables.baseScheduler ) ) {
			// feed the base class
			variables.wirebox
				.registerNewInstance( name = variables.baseScheduler, instancePath = variables.baseScheduler )
				.addDIConstructorArgument( name = "name", value = "variables.baseScheduler" );
		}

		// Check if the convention exists, else just build out a simple scheduler
		if ( fileExists( variables.appPath & "config/Scheduler.cfc" ) ) {
			schedulerPath = (
				variables.appMapping.len() ? "#variables.appMapping#.#appSchedulerConvention#" : appSchedulerConvention
			);
		}

		// Load, create, register and activate
		loadScheduler( schedulerName, schedulerPath );
	}

	/**
	 * Load a scheduler cfc by path and name, usually this is called from module services or ways to register
	 * a-la-carte schedulers
	 *
	 * @name The name to register the scheduler with
	 * @path The path to instantiate the scheduler cfc
	 *
	 * @return The created, configured, registered, and activated scheduler
	 */
	function loadScheduler( required name, required path ){
		// Log it
		variables.log.info( "Loading ColdBox Task Scheduler (#arguments.name#) at => #arguments.path#..." );
		// Process as a Scheduler.cfc with virtual inheritance
		wirebox
			.registerNewInstance( name = arguments.name, instancePath = arguments.path )
			.setVirtualInheritance( variables.baseScheduler )
			.setThreadSafe( true )
			.setScope( variables.wirebox.getBinder().SCOPES.SINGLETON )
			.addDIConstructorArgument( name = "name", value = arguments.name );
		// Create, register, configure it and start it up baby!
		var oScheduler = registerScheduler( variables.wirebox.getInstance( arguments.name ) );
		// Register the Scheduler as an Interceptor as well.
		variables.controller.getInterceptorService().registerInterceptor( interceptorObject = oScheduler );
		// Configure it
		oScheduler.configure();
		// Start it up
		oScheduler.startup();
		// Return it
		return oScheduler;
	}

	/**
	 * Register a new scheduler in this manager using the scheduler name
	 *
	 * @scheduler The scheduler object to register in the service
	 *
	 * @return The registered scheduler Object: coldbox.system.web.tasks.ColdBoxScheduler
	 */
	function registerScheduler( required scheduler ){
		// Register it
		variables.schedulers[ arguments.scheduler.getName() ] = arguments.scheduler;
		// Return it
		return arguments.scheduler;
	}

	/**
	 * Verify if a scheduler has been registered
	 *
	 * @name The name of the scheduler
	 */
	boolean function hasScheduler( required name ){
		return variables.schedulers.keyExists( arguments.name );
	}

	/**
	 * Remove a scheduler from this manager
	 *
	 * @name The name of the scheduler
	 *
	 * @return True if removed, else if not found or not removed
	 */
	boolean function removeScheduler( required name ){
		if ( hasScheduler( arguments.name ) ) {
			variables.schedulers[ arguments.name ].shutdown();
			structDelete( variables.schedulers, arguments.name );
			return true;
		}
		return false;
	}

}
