﻿/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * This is LogBox, an enterprise logging library. Please remember to persist this class once it has been created.
 * You can create as many instances of LogBox as you like. Just remember that you
 * need to register loggers in it.  It can be one or 1000, it all depends on you.
 *
 * By default, LogBox will log any warnings pertaining to itself in the CF logs
 * according to its name.
*/
component accessors="true"{


	/**
	* The LogBox unique ID
	*/
	property name="logBoxID";

	/**
	* The LogBox operating version
	*/
	property name="version";

	/**
	* The appender registration map
	*/
	property name="appenderRegistry" type="struct";

	/**
	* The Logger registration map
	*/
	property name="loggerRegistry" type="struct";

	/**
	* Category based appenders
	*/
	property name="categoryAppenders";

	/**
	* Configuration object
	*/
	property name="config";

	/**
	* ColdBox linkage class
	*/
	property name="coldbox";

	// The log levels enum as a public property
	this.logLevels = new coldbox.system.logging.LogLevels();

	/**
	 * Constructor
	 *
	 * @config The LogBoxConfig object to use to configure this instance of LogBox
	 * @coldbox A coldbox application that this instance of logbox can be linked to.
	 */
	function init( required coldbox.system.logging.config.LogBoxConfig config, coldbox="" ){
		// LogBox Unique ID
		variables.logboxID          = createObject( 'java', 'java.lang.System' ).identityHashCode( this );
		// Appenders
		variables.appenderRegistry  = structnew();
		// Loggers
		variables.loggerRegistry    = structnew();
		// Category Appenders
		variables.categoryAppenders = "";
		// Version
		variables.version           = "@build.version@+@build.number@";

		// Link incoming ColdBox argument
		variables.coldbox = arguments.coldbox;

		// Configure LogBox
		configure( arguments.config );

		return this;
	}

	/**
	 * Configure logbox for operation. You can also re-configure LogBox programmatically. Basically we register all appenders here and all categories
	 *
	 * @config The LogBoxConfig object to use to configure this instance of LogBox: coldbox.system.logging.config.LogBoxConfig
	 * @config.doc_generic coldbox.system.logging.config.LogBoxConfig
	 */
	function configure( required config ){
		lock name="#variables.logBoxID#.logbox.config" type="exclusive" timeout="30" throwOnTimeout=true{
			// Store config object with validation
			variables.config = arguments.config.validate();

			// Reset Registries
			variables.appenderRegistry 	= structnew();
			variables.loggerRegistry 	= structnew();

			//Get appender definitions
			var appenders = variables.config.getAllAppenders();

			// Register All Appenders configured
			for( var key in appenders ){
				registerAppender( argumentCollection=appenders[ key ] );
			}

			// Get Root def
			var rootConfig = variables.config.getRoot();
			// Create Root Logger
			var args = {
				category = "ROOT",
				levelMin = rootConfig.levelMin,
				levelMax = rootConfig.levelMax,
				appenders = getAppendersMap( rootConfig.appenders )
			};

			//Save in Registry
			variables.loggerRegistry = {
				"ROOT" = new coldbox.system.logging.Logger( argumentCollection=args )
			};
		}
	}

	/**
	 * Get the root logger object
	 *
	 * @return coldbox.system.logging.Logger
	 */
	function getRootLogger(){
		return variables.loggerRegistry[ "ROOT" ];
	}

	/**
	 * Get a logger object configured with a category name and appenders. If not configured, then it reverts to the root logger defined for this instance of LogBox
	 *
	 * @category The category name to use in this logger or pass in the target object will log from and we will inspect the object and use its metadata name
	 *
	 * @return coldbox.system.logging.Logger
	 */
	function getLogger( required category ){
		var root = getRootLogger();

		// is category object?
		if( isObject( arguments.category ) ){
			arguments.category = getMetadata( arguments.category ).name;
		}

		// trim cat, just in case
		arguments.category = trim( arguments.category );

		// Is logger by category name created already?
		if( structKeyExists( variables.loggerRegistry, arguments.category ) ){
			return variables.loggerRegistry[ arguments.category ];
		}

		// Do we have a category definition, so we can build it?
		var args = {};
		if( variables.config.categoryExists( arguments.category ) ){
			var categoryConfig = variables.config.getCategory( arguments.category );
			// Setup creation arguments
			args = {
				category 	= categoryConfig.name,
				levelMin 	= categoryConfig.levelMin,
				levelMax 	= categoryConfig.levelMax,
				appenders 	= getAppendersMap( categoryConfig.appenders )
			};
		} else {
			// Do Category Inheritance? or else just return the root logger.
			root = locateCategoryParentLogger( arguments.category );
			// Build it out as per Root logger
			args = {
				category = arguments.category,
				levelMin = root.getLevelMin(),
				levelMax = root.getLevelMax()
			};
		}

		// Create it
		lock name="#variables.logboxID#.logBox.logger.#arguments.category#" type="exclusive" throwontimeout="true" timeout="30"{
			if( NOT structKeyExists( variables.loggerRegistry, arguments.category ) ){
				// Create logger
				var oLogger = new coldbox.system.logging.Logger( argumentCollection=args );
				// Inject Root Logger
				oLogger.setRootLogger( root );
				// Store it
				variables.loggerRegistry[ arguments.category ] = oLogger;
			}
		}

		return variables.loggerRegistry[ arguments.category ];
	}

	/**
	 * Get the list of currently instantiated loggers.
	 */
	string function getCurrentLoggers(){
		return structKeyList( variables.loggerRegistry );
	}

	/**
	 * Get the list of currently instantiated appenders.
	 */
	string function getCurrentAppenders(){
		return structKeyList( variables.appenderRegistry );
	}

	/**
	 * Register a new appender object in the appender registry.
	 *
	 * @name A unique name for the appender to register. Only unique names can be registered per variables.
	 * @class The appender's class to register. We will create, init it and register it for you.
	 * @properties The structure of properties to configure this appender with.
	 * @layout The layout class to use in this appender for custom message rendering
	 * @levelMin The default log level for this appender, by default it is 0. Optional. ex: LogBox.logLevels.WARN
	 * @levelMax The default log level for this appender, by default it is 4. Optional. ex: LogBox.logLevels.WARN
	 */
	function registerAppender(
		required name,
		required class,
		struct properties={},
		layout="",
		numeric levelMin=0,
		numeric levelMax=4
	){

		if( !structKeyExists( variables.appenderRegistry, arguments.name ) ){

			lock name="#variables.logboxID#.registerappender.#name#" type="exclusive" timeout="15" throwOnTimeout="true"{

				if( !structKeyExists( variables.appenderRegistry, arguments.name ) ){

					// Create appender and linking
					var oAppender = new "#arguments.class#"( argumentCollection=arguments );
					oAppender.setColdBox( variables.coldbox );
					// run registration event
					oAppender.onRegistration();
					// set initialized
					oAppender.setInitialized( true );
					// Store it
					variables.appenderRegistry[ arguments.name ] = oAppender;

				}

			} // end lock

		}

	}

	/********************************************* PRIVATE *********************************************/

	/**
	 * Get a parent logger according to category convention inheritance.  If not found, it returns the root logger.
	 *
	 * @category The category name to investigate for parents
	 */
	private function locateCategoryParentLogger( required category ){
		// Get parent category name shortened by one.
		var parentCategory = "";

		// category len check
		if( len( arguments.category ) ){
			parentCategory = listDeleteAt( arguments.category, listLen( arguments.category, "." ), "." );
		}

		// Check if parent Category is empty
		if( len( parentCategory ) EQ 0 ){
			// Just return the root logger, nothing found.
			return getRootLogger();
		}
		// Does it exist already in the instantiated loggers?
		if( structKeyExists( variables.loggerRegistry, parentCategory ) ){
			return variables.loggerRegistry[ parentCategory ];
		}
		// Do we need to create it, lazy loading?
		if( variables.config.categoryExists( parentCategory ) ){
			return getLogger( parentCategory );
		}
		// Else, it was not located, recurse
		return locateCategoryParentLogger( parentCategory );
	}

	/**
	 * Get a map of appenders by list. Usually called to get a category of appenders
	 *
	 * @appenders The list of appenders to get
	 */
	struct function getAppendersMap( required appenders ){
		var results = arguments.appenders
			.listToArray()
			.reduce( function( result, item, index ){
				var target = {};
				if( !isNull( arguments.result ) ){
					target = result;
				}
				target[ item ] = variables.appenderRegistry[ item ];
				return target;
			} );

		return ( isNull( results ) ? structNew() : results );
	}

	/**
	 * Get Utility Object
	 */
	private function getUtil(){
		return new coldbox.system.core.util.Util();
	}

}