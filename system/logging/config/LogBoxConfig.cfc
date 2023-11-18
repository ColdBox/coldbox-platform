/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * This is a LogBox configuration object.  You can use it to configure a LogBox variables.
 **/
component accessors="true" {

	/**
	 * The ColdBox Utility object
	 */
	property name="utility";

	/**
	 * The appenders registered
	 */
	property name="appenders" type="struct";

	/**
	 * The categories registered
	 */
	property name="categories" type="struct";

	/**
	 * The root logger registered
	 */
	property name="rootLogger" type="struct";

	// The log levels enum as a public property
	this.logLevels = new coldbox.system.logging.LogLevels();
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
		if ( !isNull( arguments.CFCConfigPath ) ) {
			arguments.CFCConfig = createObject( "component", arguments.CFCConfigPath );
		}

		// Test and load via Data CFC
		if ( !isNull( arguments.CFCConfig ) and isObject( arguments.CFCConfig ) ) {
			// Decorate our data CFC
			arguments.CFCConfig.getPropertyMixin = getUtil().getMixerUtil().getPropertyMixin;
			// Execute the configuration
			arguments.CFCConfig.configure();
			// Load the DSL
			loadDataDSL( arguments.CFCConfig.getPropertyMixin( "logBox", "variables", structNew() ) );
		}

		// Just return, most likely programmatic config
		return this;
	}

	/**
	 * Get the ColdBox Utility object
	 */
	private function getUtil(){
		if ( isNull( variables.utility ) ) {
			variables.utility = new coldbox.system.core.util.Util();
		}
		return variables.utility;
	}

	/**
	 * Reset the configuration
	 */
	LogBoxConfig function reset(){
		// Register appenders
		variables.appenders  = structNew();
		// Register categories
		variables.categories = structNew();
		// Register root logger
		variables.rootLogger = structNew();
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
			DEBUG( argumentCollection = getUtil().arrayToStruct( logBoxDSL.debug ) );
		}
		if ( structKeyExists( logBoxDSL, "info" ) ) {
			INFO( argumentCollection = getUtil().arrayToStruct( logBoxDSL.info ) );
		}
		if ( structKeyExists( logBoxDSL, "warn" ) ) {
			WARN( argumentCollection = getUtil().arrayToStruct( logBoxDSL.warn ) );
		}
		if ( structKeyExists( logBoxDSL, "error" ) ) {
			ERROR( argumentCollection = getUtil().arrayToStruct( logBoxDSL.error ) );
		}
		if ( structKeyExists( logBoxDSL, "fatal" ) ) {
			FATAL( argumentCollection = getUtil().arrayToStruct( logBoxDSL.fatal ) );
		}
		if ( structKeyExists( logBoxDSL, "off" ) ) {
			OFF( argumentCollection = getUtil().arrayToStruct( logBoxDSL.off ) );
		}

		return this;
	}

	/**
	 * Reset appender configuration
	 */
	LogBoxConfig function resetAppenders(){
		variables.appenders = structNew();
		return this;
	}

	/**
	 * Reset categories configuration
	 */
	LogBoxConfig function resetCategories(){
		variables.categories = structNew();
		return this;
	}

	/**
	 * Reset root configuration
	 */
	LogBoxConfig function resetRoot(){
		variables.rootLogger = structNew();
		return this;
	}

	/**
	 * Get the config memento
	 */
	struct function getMemento(){
		return variables.filter( ( key, value ) => {
			return isCustomFunction( value ) || listFindNoCase( "this", key ) ? false : true;
		} );
	}

	/**
	 * Validates the configuration. If not valid, it will throw an appropriate exception.
	 *
	 * @throws AppenderNotFound - If an appender is not found in the configuration
	 */
	LogBoxConfig function validate(){
		// Check root logger definition
		if ( structIsEmpty( variables.rootLogger ) ) {
			// Auto register a root logger
			root( appenders = "*" );
		}

		// All root appenders?
		if ( variables.rootLogger.appenders eq "*" ) {
			variables.rootLogger.appenders = structKeyList( getAllAppenders() );
		}

		if ( len( variables.rootLogger.exclude ) ) {
			variables.rootLogger.appenders = excludeAppenders(
				variables.rootLogger.appenders,
				variables.rootLogger.exclude
			);
		}

		// Check root's appenders
		for ( var x = 1; x lte listLen( variables.rootLogger.appenders ); x++ ) {
			if ( NOT structKeyExists( variables.appenders, listGetAt( variables.rootLogger.appenders, x ) ) ) {
				throw(
					message = "Invalid appender in Root Logger",
					detail  = "The appender #listGetAt( variables.rootLogger.appenders, x )# has not been defined yet. Please define it first.",
					type    = "AppenderNotFound"
				);
			}
		}

		// Check all Category Appenders
		for ( var key in variables.categories ) {
			// Check * all appenders
			if ( variables.categories[ key ].appenders eq "*" ) {
				variables.categories[ key ].appenders = structKeyList( getAllAppenders() );
			}

			for ( var x = 1; x lte listLen( variables.categories[ key ].appenders ); x++ ) {
				if (
					NOT structKeyExists(
						variables.appenders,
						listGetAt( variables.categories[ key ].appenders, x )
					)
				) {
					throw(
						message = "Invalid appender in Category: #key#",
						detail  = "The appender #listGetAt( variables.categories[ key ].appenders, x )# has not been defined yet. Please define it first.",
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
		variables.appenders[ arguments.name ] = arguments;

		return this;
	}

	/**
	 * Add an appender configuration
	 *
	 * @appenders A list of appenders to configure the root logger with. Send a * to add all appenders
	 * @levelMin  The default log level for the root logger, by default it is 0 (FATAL). Optional. ex: config.logLevels.WARN
	 * @levelMax  The default log level for the root logger, by default it is 4 (DEBUG). Optional. ex: config.logLevels.WARN
	 * @exclude   a list of appenders to exclude from the root logger
	 *
	 * @throws InvalidAppenders
	 */
	LogBoxConfig function root(
		required appenders,
		levelMin = 0,
		levelMax = 4,
		exclude  = ""
	){
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
		variables.rootLogger = arguments;

		return this;
	}

	/**
	 * Get the root logger definition
	 */
	struct function getRoot(){
		return variables.rootLogger;
	}

	/**
	 * Add a new category configuration with appender(s).  Appenders MUST be defined first, else this method will throw an exception
	 *
	 * @name      A unique name for the appender to register. Only unique names can be registered per instance
	 * @levelMin  The default log level for the root logger, by default it is 0 (FATAL). Optional. ex: config.logLevels.WARN
	 * @levelMax  The default log level for the root logger, by default it is 4 (DEBUG). Optional. ex: config.logLevels.WARN
	 * @appenders A list of appender names to configure this category with. By default it uses all the registered appenders
	 * @exclude   A list of appender names to exclude from this category
	 */
	LogBoxConfig function category(
		required name,
		levelMin  = 0,
		levelMax  = 4,
		appenders = "*",
		exclude   = ""
	){
		// Convert Levels
		convertLevels( arguments );

		// Check levels
		levelChecks( arguments.levelMin, arguments.levelMax );

		// Check * all appenders
		if ( arguments.appenders eq "*" ) {
			arguments.appenders = structKeyList( getAllAppenders() );
		}

		// filter appenders based on exclusion list
		if ( len( arguments.exclude ) ) {
			arguments.appenders = excludeAppenders( arguments.appenders, arguments.exclude );
		}

		// Add category registration
		variables.categories[ arguments.name ] = arguments;

		return this;
	}

	/**
	 * Get a specified category definition
	 *
	 * @name The category name
	 */
	struct function getCategory( required name ){
		return variables.categories[ arguments.name ];
	}

	/**
	 * Check if a category definition exists
	 *
	 * @name The category name
	 */
	boolean function categoryExists( required name ){
		return structKeyExists( variables.categories, arguments.name );
	}

	/**
	 * Get the configured categories
	 */
	struct function getAllCategories(){
		return variables.categories;
	}

	/**
	 * Get all the configured appenders
	 */
	struct function getAllAppenders(){
		return variables.appenders;
	}

	/**
	 * Exclude appenders from a list of appenders
	 *
	 * @appenders A list of appenders to exclude from
	 * @exclude   A list of appenders to exclude
	 */
	string function excludeAppenders( required string appenders, required string exclude ){
		return listToArray( appenders ).filter( ( item ) => !listFindNoCase( exclude, item ) ).toList();
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
