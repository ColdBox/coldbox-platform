/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * This object is in charge of starting up virtual ColdBox applications used in integration testing.
 * The Virtual applications follow the convention of loading into the application scope.
 */
component accessors="true" {

	/**
	 * Constructor
	 *
	 * @appMapping The mapping that points to the ColdBox's application root. This will be expanded via <pre>expandPath()</pre>
	 * @configPath The CFC path to the ColdBox configuration object to load. The default is <pre>config.Coldbox</pre>
	 * @webMapping The direct location of the application's web root in the server, only used if using a modern non-webroot template
	 */
	function init(
		string appMapping = "/",
		string configPath = "",
		string webMapping = ""
	){
		variables.appMapping = arguments.appMapping;
		variables.configPath = arguments.configPath;
		variables.webMapping = arguments.webMapping;

		// Verify appMapping to be the webroot if passed as an empty string
		if ( !len( variables.appMapping ) ) {
			variables.appMapping = "/";
		}

		variables.appRootPath = expandPath( variables.appMapping );
		// Clean the path for nice root path.
		if ( NOT reFind( "(/|\\)$", variables.appRootPath ) ) {
			variables.appRootPath = variables.appRootPath & "/";
		}

		// If we didn't pass a configPath then discover it
		if ( !len( variables.configPath ) ) {
			// Default it
			variables.configPath = "config.Coldbox";
			if ( len( variables.appMapping ) && variables.appMapping neq "/" ) {
				variables.configPath = variables.appMapping & "." & variables.configPath;
			}
		}

		return this;
	}

	/**
	 * Startup a virtual ColdBox application for integration testing purposes.
	 *
	 * @force Force the startup of the application even if found. Default is false
	 *
	 * @return The loaded Application controller
	 */
	function startup( boolean force = false ){
		// Return back if it's already running and not forcing
		if ( isRunning() && !arguments.force ) {
			return application.cbController;
		}

		// Initialize mock Controller
		application.cbController = new coldbox.system.testing.mock.web.MockController(
			appRootPath = variables.appRootPath,
			appKey      = "cbController"
		);

		// Load application
		application.cbController
			.getLoaderService()
			.loadApplication(
				overrideConfigFile = variables.configPath,
				overrideAppMapping = variables.appMapping,
				overrideWebMapping = variables.webMapping
			);
		// Load Module CF Mappings so modules can work properly
		application.cbController.getModuleService().loadMappings();
		// back to the future!
		return application.cbController;
	}

	/**
	 * Restart the virtual app
	 */
	function restart(){
		shutdown();
		startup();
	}

	/**
	 * Verifies if the ColdBox application is in application scope and running
	 */
	boolean function isRunning(){
		return !isNull( application.cbController );
	}

	/**
	 * Get the running application controller. Null if not in scope!
	 *
	 */
	function getController(){
		return isRunning() ? application.cbController : javacast( "null", "" );
	}

	/**
	 * Shuts down a virtual ColdBox application.
	 * It expects the <pre>cbController</pre> to be the app by convention.
	 *
	 * @force If true, it forces all shutdowns this is usually true when doing reinits. Defaults to true for testing.
	 */
	function shutdown( boolean force = true ){
		if ( !isNull( application.cbController ) ) {
			application.cbController.getLoaderService().processShutdown( force = arguments.force );
		}
		structDelete( application, "cbController" );
		structDelete( application, "wirebox" );
		structDelete( application, "cachebox" );
	}

}
