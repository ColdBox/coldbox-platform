/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * This is a LogBox configuration object.  You can use it to configure a LogBox instance.
 **/
component accessors="true" {

	// The log levels enum as a public property
	this.logLevels    = new coldbox.system.logging.LogLevels();
	// Internal Utility object
	variables.utility = new coldbox.system.core.util.Util();
	// Instance private scope
	instance          = structNew();
	// Startup the configuration
	reset();

	/**
	 * Constructor
	 *
	 * @CFCConfig     The logBox Data Configuration CFC
	 * @CFCConfigPath The logBox Data Configuration CFC path to use
	 */
	function init( any CFCConfig, string CFCConfigPath ){
		// Test and load via Data CFC Path
		if ( structKeyExists( arguments, "CFCConfigPath" ) ) {
			arguments.CFCConfig = createObject( "component", arguments.CFCConfigPath );
		}

		// Test and load via Data CFC
		if ( structKeyExists( arguments, "CFCConfig" ) and isObject( arguments.CFCConfig ) ) {
			// Decorate our data CFC
			arguments.CFCConfig.getPropertyMixin = variables.utility.getMixerUtil().getPropertyMixin;
			// Execute the configuration
			arguments.CFCConfig.configure();
			// Get Data
			var logBoxDSL = arguments.CFCConfig.getPropertyMixin( "logBox", "variables", structNew() );
			// Load the DSL
			loadDataDSL( logBoxDSL );
		}

		// Just return, most likely programmatic config
		return this;
	}

	/**
	 * Reset the configuration
	 */
	LogBoxConfig function reset(){
		// Register appenders
		instance.appenders  = structNew();
		// Register categories
		instance.categories = structNew();
		// Register root logger
		instance.rootLogger = structNew();
		return this;
	}

	/**
	 * Load a data configuration CFC data DSL
	 *
	 * @rawDSL The data configuration DSL structure
	 */
	LogBoxConfig function loadDataDSL( required struct rawDSL ){
		var logBoxDSL = arguments.rawDSL;

		// Register Appenders
		for ( var key in logBoxDSL.appenders ) {
			logBoxDSL.appenders[ key ].name = key;
			appender( argumentCollection = logBoxDSL.appenders[ key ] );
		}

		// Register Root Logger
		if ( NOT structKeyExists( logBoxDSL, "root" ) ) {
			logBoxDSL.root = { appenders : "*" };
		}
		root( argumentCollection = logBoxDSL.root );

		// Register Categories
		if ( structKeyExists( logBoxDSL, "categories" ) ) {
			for ( var key in logBoxDSL.categories ) {
				logBoxDSL.categories[ key ].name = key;
				category( argumentCollection = logBoxDSL.categories[ key ] );
			}
		}

		// Register Level Categories
		if ( structKeyExists( logBoxDSL, "debug" ) ) {
			DEBUG( argumentCollection = variables.utility.arrayToStruct( logBoxDSL.debug ) );
		}
		if ( structKeyExists( logBoxDSL, "info" ) ) {
			INFO( argumentCollection = variables.utility.arrayToStruct( logBoxDSL.info ) );
		}
		if ( structKeyExists( logBoxDSL, "warn" ) ) {
			WARN( argumentCollection = variables.utility.arrayToStruct( logBoxDSL.warn ) );
		}
		if ( structKeyExists( logBoxDSL, "error" ) ) {
			ERROR( argumentCollection = variables.utility.arrayToStruct( logBoxDSL.error ) );
		}
		if ( structKeyExists( logBoxDSL, "fatal" ) ) {
			FATAL( argumentCollection = variables.utility.arrayToStruct( logBoxDSL.fatal ) );
		}
		if ( structKeyExists( logBoxDSL, "off" ) ) {
			OFF( argumentCollection = variables.utility.arrayToStruct( logBoxDSL.off ) );
		}

		return this;
	}

	/**
	 * Reset appender configuration
	 */
	LogBoxConfig function resetAppenders(){
		instance.appenders = structNew();
		return this;
	}

	/**
	 * Reset categories configuration
	 */
	LogBoxConfig function resetCategories(){
		instance.categories = structNew();
		return this;
	}

	/**
	 * Reset root configuration
	 */
	LogBoxConfig function resetRoot(){
		instance.rootLogger = structNew();
		return this;
	}

	/**
	 * Get the instance memento
	 */
	struct function getMemento(){
		return instance;
	}

	/**
	 * Validates the configuration. If not valid, it will throw an appropriate exception.
	 *
	 * @throws AppenderNotFound
	 */
	LogBoxConfig function validate(){
		// Check root logger definition
		if ( structIsEmpty( instance.rootLogger ) ) {
			// Auto register a root logger
			root( appenders = "*" );
		}

		// All root appenders?
		if ( instance.rootLogger.appenders eq "*" ) {
			instance.rootLogger.appenders = structKeyList( getAllAppenders() );
		}

		// Check root's appenders
		for ( var x = 1; x lte listLen( instance.rootLogger.appenders ); x++ ) {
			if ( NOT structKeyExists( instance.appenders, listGetAt( instance.rootLogger.appenders, x ) ) ) {
				throw(
					message = "Invalid appender in Root Logger",
					detail  = "The appender #listGetAt( instance.rootLogger.appenders, x )# has not been defined yet. Please define it first.",
					type    = "AppenderNotFound"
				);
			}
		}

		// Check all Category Appenders
		for ( var key in instance.categories ) {
			// Check * all appenders
			if ( instance.categories[ key ].appenders eq "*" ) {
				instance.categories[ key ].appenders = structKeyList( getAllAppenders() );
			}

			for ( var x = 1; x lte listLen( instance.categories[ key ].appenders ); x++ ) {
				if ( NOT structKeyExists( instance.appenders, listGetAt( instance.categories[ key ].appenders, x ) ) ) {
					throw(
						message = "Invalid appender in Category: #key#",
						detail  = "The appender #listGetAt( instance.categories[ key ].appenders, x )# has not been defined yet. Please define it first.",
						type    = "AppenderNotFound"
					);
				}
			}
		}

		return this;
	}

	/**
	 * Add an appender configuration
	 *
	 * @name       A unique name for the appender to register. Only unique names can be registered per instance
	 * @class      The appender's class to register. We will create, init it and register it for you
	 * @properties The structure of properties to configure this appender with.
	 * @layout     The layout class path to use in this appender for custom message rendering.
	 * @levelMin   The default log level for the root logger, by default it is 0 (FATAL). Optional. ex: config.logLevels.WARN
	 * @levelMax   The default log level for the root logger, by default it is 4 (DEBUG). Optional. ex: config.logLevels.WARN
	 */
	LogBoxConfig function appender(
		required name,
		required class,
		struct properties = {},
		layout            = "",
		levelMin          = 0,
		levelMax          = 4
	){
		// Convert Levels
		convertLevels( arguments );

		// Check levels
		levelChecks( arguments.levelMin, arguments.levelMax );

		// Register appender
		instance.appenders[ arguments.name ] = arguments;

		return this;
	}

	/**
	 * Add an appender configuration
	 *
	 * @appenders A list of appenders to configure the root logger with. Send a * to add all appenders
	 * @levelMin  The default log level for the root logger, by default it is 0 (FATAL). Optional. ex: config.logLevels.WARN
	 * @levelMax  The default log level for the root logger, by default it is 4 (DEBUG). Optional. ex: config.logLevels.WARN
	 *
	 * @throws InvalidAppenders
	 */
	LogBoxConfig function root( required appenders, levelMin = 0, levelMax = 4 ){
		// Convert Levels
		convertLevels( arguments );

		// Check levels
		levelChecks( arguments.levelMin, arguments.levelMax );

		// Verify appender list
		if ( NOT listLen( arguments.appenders ) ) {
			throw(
				message = "Invalid Appenders",
				detail  = "Please send in at least one appender for the root logger",
				type    = "InvalidAppenders"
			);
		}

		// Add definition
		instance.rootLogger = arguments;

		return this;
	}

	/**
	 * Get the root logger definition
	 */
	struct function getRoot(){
		return instance.rootLogger;
	}

	/**
	 * Add a new category configuration with appender(s).  Appenders MUST be defined first, else this method will throw an exception
	 *
	 * @name      A unique name for the appender to register. Only unique names can be registered per instance
	 * @levelMin  The default log level for the root logger, by default it is 0 (FATAL). Optional. ex: config.logLevels.WARN
	 * @levelMax  The default log level for the root logger, by default it is 4 (DEBUG). Optional. ex: config.logLevels.WARN
	 * @appenders A list of appender names to configure this category with. By default it uses all the registered appenders
	 */
	LogBoxConfig function category(
		required name,
		levelMin  = 0,
		levelMax  = 4,
		appenders = "*"
	){
		// Convert Levels
		convertLevels( arguments );

		// Check levels
		levelChecks( arguments.levelMin, arguments.levelMax );

		// Check * all appenders
		if ( appenders eq "*" ) {
			appenders = structKeyList( getAllAppenders() );
		}

		// Add category registration
		instance.categories[ arguments.name ] = arguments;

		return this;
	}

	/**
	 * Get a specified category definition
	 *
	 * @name The category name
	 */
	struct function getCategory( required name ){
		return instance.categories[ arguments.name ];
	}

	/**
	 * Check if a category definition exists
	 *
	 * @name The category name
	 */
	boolean function categoryExists( required name ){
		return structKeyExists( instance.categories, arguments.name );
	}

	/**
	 * Get the configured categories
	 */
	struct function getAllCategories(){
		return instance.categories;
	}

	/**
	 * Get all the configured appenders
	 */
	struct function getAllAppenders(){
		return instance.appenders;
	}

	/**
	 * Add categories to the DEBUG level. Send each category as an argument.
	 */
	LogBoxConfig function debug(){
		for ( var key in arguments ) {
			category( name = arguments[ key ], levelMax = this.logLevels.DEBUG );
		}
		return this;
	}

	/**
	 * Add categories to the INFO level. Send each category as an argument.
	 */
	LogBoxConfig function info(){
		for ( var key in arguments ) {
			category( name = arguments[ key ], levelMax = this.logLevels.INFO );
		}
		return this;
	}

	/**
	 * Add categories to the WARN level. Send each category as an argument.
	 */
	LogBoxConfig function warn(){
		for ( var key in arguments ) {
			category( name = arguments[ key ], levelMax = this.logLevels.WARN );
		}
		return this;
	}

	/**
	 * Add categories to the ERROR level. Send each category as an argument.
	 */
	LogBoxConfig function error(){
		for ( var key in arguments ) {
			category( name = arguments[ key ], levelMax = this.logLevels.ERROR );
		}
		return this;
	}

	/**
	 * Add categories to the FATAL level. Send each category as an argument.
	 */
	LogBoxConfig function fatal(){
		for ( var key in arguments ) {
			category( name = arguments[ key ], levelMax = this.logLevels.FATAL );
		}
		return this;
	}

	/**
	 * Add categories to the OFF level. Send each category as an argument.
	 */
	LogBoxConfig function off(){
		for ( var key in arguments ) {
			category(
				name     = arguments[ key ],
				levelMin = this.logLevels.OFF,
				levelMax = this.logLevels.OFF
			);
		}
		return this;
	}

	/**
	 * Convert levels from an incoming structure of data
	 *
	 * @target The structure to look for elements: LevelMin and LevelMax
	 */
	private struct function convertLevels( required target ){
		// Check levelMin
		if ( structKeyExists( arguments.target, "levelMIN" ) and NOT isNumeric( arguments.target.levelMin ) ) {
			arguments.target.levelMin = this.logLevels.lookupAsInt( arguments.target.levelMin );
		}
		// Check levelMax
		if ( structKeyExists( arguments.target, "levelMax" ) and NOT isNumeric( arguments.target.levelMax ) ) {
			arguments.target.levelMax = this.logLevels.lookupAsInt( arguments.target.levelMax );
		}
		// For chaining
		return arguments.target;
	}

	/**
	 * Level checks on incoming levels
	 *
	 * @levelMin
	 * @levelMax
	 *
	 * @throws InvalidLevel
	 */
	private function levelChecks( required levelMin, required levelMax ){
		if ( !this.logLevels.isLevelValid( arguments.levelMin ) ) {
			throw( message = "LevelMin #arguments.levelMin# is not a valid level.", type = "InvalidLevel" );
		} else if ( !this.logLevels.isLevelValid( arguments.levelMax ) ) {
			throw( message = "LevelMin #arguments.levelMax# is not a valid level.", type = "InvalidLevel" );
		}
	}

}
