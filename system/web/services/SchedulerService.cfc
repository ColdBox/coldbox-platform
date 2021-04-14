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
		var appScheduler  = "config.Scheduler";
		var baseScheduler = "coldbox.system.web.tasks.ColdBoxScheduler";
		var schedulerName = "appScheduler@coldbox";

		// Check if base scheduler has been mapped?
		if ( NOT variables.wirebox.getBinder().mappingExists( baseScheduler ) ) {
			// feed the base class
			variables.wirebox
				.registerNewInstance( name = baseScheduler, instancePath = baseScheduler )
				.addDIConstructorArgument( name = "name", value = "baseScheduler" );
		}

		// Check if the convetion exists, else just build out a simple scheduler
		if ( fileExists( appPath & "config/Scheduler.cfc" ) ) {
			// Log it
			variables.log.info( "Loading App ColdBox Task Scheduler at => config/Scheduler.cfc" );
			var appSchedulerPath = (
				variables.appMapping.len() ? "#variables.appMapping#.#appScheduler#" : appScheduler
			);
			// Process as a Scheduler.cfc with virtual inheritance
			wirebox
				.registerNewInstance( name = schedulerName, instancePath = appSchedulerPath )
				.setVirtualInheritance( baseScheduler )
				.setThreadSafe( true )
				.setScope( variables.wirebox.getBinder().SCOPES.SINGLETON )
				.addDIConstructorArgument( name = "name", value = schedulerName );
		}
		// Load up a base scheduler
		else {
			// Log it
			variables.log.info( "Loading Base ColdBox Task Scheduler" );
			// Register scheduler with WireBox
			variables.wirebox
				.registerNewInstance( name = schedulerName, instancePath = baseScheduler )
				.setThreadSafe( true )
				.setScope( variables.wirebox.getBinder().SCOPES.SINGLETON )
				.addDIConstructorArgument( name = "name", value = schedulerName );
		}

		// Create, register, configure it and start it up baby!
		var appScheduler = registerScheduler( variables.wirebox.getInstance( schedulerName ) );
		// Register the Scheduler as an Interceptor as well.
		variables.controller.getInterceptorService().registerInterceptor( interceptorObject = appScheduler );
		// Configure it
		appScheduler.configure();
		// Start it up
		appScheduler.startup();
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
