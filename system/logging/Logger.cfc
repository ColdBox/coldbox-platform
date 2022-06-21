/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * This is a logging object that allows for all kinds of logging to occur within its appender
 **/
component accessors="true" {

	/**
	 * Root Logger reference
	 */
	property name="rootLogger";

	/**
	 * Category for this logger
	 */
	property name="category";

	/**
	 * Appenders linked to this logger
	 */
	property name="appenders" type="struct";

	/**
	 * Level Min
	 */
	property name="levelMin";

	/**
	 * Level Max
	 */
	property name="levelMax";

	// The log levels enum as a public property
	this.logLevels = new coldbox.system.logging.LogLevels();

	/**
	 * Constructor
	 *
	 * @category  The category name to use this logger with
	 * @levelMin  The default log level for this appender, by default it is 0. Optional. ex: LogBox.logLevels.WARN
	 * @levelMax  The default log level for this appender, by default it is 0. Optional. ex: LogBox.logLevels.WARN
	 * @appenders A struct of already created appenders for this category, or blank to use the root logger.
	 */
	function init(
		required category,
		numeric levelMin = 0,
		numeric levelMax = 4,
		struct appenders = {}
	){
		// Save Properties
		variables.rootLogger = "";
		variables.category   = arguments.category;
		variables.appenders  = arguments.appenders;

		// Logger Logging Level defaults, which is wideeeee open!
		variables.levelMin = arguments.levelMin;
		variables.levelMax = arguments.levelMax;

		// Utilities
		variables._hash = createUUID();
		variables.util  = new coldbox.system.core.util.Util();


		// Local Locking
		variables.lockName    = variables._hash & "LoggerOperation";
		variables.lockTimeout = 20;

		return this;
	}

	/**
	 * Do we have any appenders
	 */
	function hasAppenders(){
		return !variables.appenders.isEmpty();
	}

	/**
	 * Stupid ACF10 not working on getters
	 */
	function getAppenders(){
		return variables.appenders;
	}

	/**
	 * Get an appender reference, if the appender does not exist it will throw an exception
	 *
	 * @name The appender's name
	 *
	 * @throws Logger.AppenderNotFound
	 */
	function getAppender( required name ){
		if ( structKeyExists( variables.appenders, arguments.name ) ) {
			return variables.appenders[ arguments.name ];
		}

		throw(
			message = "Appender #arguments.name# does not exist.",
			detail  = "The appenders registered are #structKeyList( variables.appenders )#",
			type    = "Logger.AppenderNotFound"
		);
	}

	/**
	 * Check if an appender exists
	 *
	 * @name The name of the appender
	 */
	boolean function appenderExists( required name ){
		return variables.appenders.keyExists( arguments.name );
	}

	/**
	 * Add a new appender to the list of appenders for this logger. If the appender already exists, then it will not be added.
	 *
	 * @newAppender An appender object reference
	 *
	 * @throws Logger.InvalidAppenderNameException
	 */
	Logger function addAppender( required newAppender ){
		// Verify Appender's name
		if ( NOT len( arguments.newAppender.getName() ) ) {
			throw(
				message = "Appender does not have a name, please instantiate the appender with a unique name.",
				type    = "Logger.InvalidAppenderNameException"
			);
		}

		// Get name
		var name = arguments.newAppender.getName();
		if ( !appenderExists( name ) ) {
			lock
				name          ="#variables._hash#.registerappender.#name#"
				type          ="exclusive"
				timeout       ="15"
				throwOnTimeout="true" {
				if ( !appenderExists( name ) ) {
					// run registration event if not Initialized
					if ( NOT arguments.newAppender.isInitialized() ) {
						arguments.newAppender.onRegistration();
						arguments.newAppender.setInitialized( true );
					}
					// Store Appender
					variables.appenders[ name ] = arguments.newAppender;
				}
			}
		}

		return this;
	}

	/**
	 * Unregister an appender from this Logger. True if successful or false otherwise.
	 */
	boolean function removeAppender( required name ){
		var isRemoved = false;

		if ( appenderExists( arguments.name ) ) {
			lock
				name          ="#variables._hash#.registerappender.#arguments.name#"
				type          ="exclusive"
				timeout       ="15"
				throwOnTimeout="true" {
				if ( appenderExists( name ) ) {
					// Get Appender
					var oAppender = variables.appenders[ arguments.name ];
					// Run un-registration event
					oAppender.onUnRegistration();
					// Now Delete it
					structDelete( variables.appenders, arguments.name );
					// flag deletion.
					isRemoved = true;
				}
			}
		}

		return isRemoved;
	}

	/**
	 * Remove all appenders registered
	 */
	Logger function removeAllAppenders(){
		var appenderKeys = structKeyArray( variables.appenders );

		appenderKeys.each( function( item ){
			removeAppender( item );
		} );

		return this;
	}

	/**
	 * Set the min level
	 *
	 * @levelMin the level to set
	 *
	 * @throws Logger.InvalidLogLevelException
	 */
	Logger function setLevelMin( required levelMin ){
		// convert to numeric, if passed in string like "INFO"
		if ( !isNumeric( arguments.levelMin ) ) {
			arguments.levelMin = this.logLevels.lookupAsInt( arguments.levelMin );
		}
		// Verify level
		if (
			this.logLevels.isLevelValid( arguments.levelMin ) AND
			arguments.levelMin lte getLevelMax()
		) {
			variables.levelMin = arguments.levelMin;
		} else {
			throw(
				message = "Invalid Log Level",
				detail  = "The log level #arguments.levelMin# is invalid or greater than the levelMax (#getLevelMax()#). Valid log levels are from 0 to 5",
				type    = "Logger.InvalidLogLevelException"
			);
		}

		return this;
	}

	/**
	 * Set the max level
	 *
	 * @levelMax the level to set
	 *
	 * @throws Logger.InvalidLogLevelException
	 */
	Logger function setLevelMax( required levelMax ){
		// convert to numeric, if passed in string like "INFO"
		if ( !isNumeric( arguments.levelMax ) ) {
			arguments.levelMax = this.logLevels.lookupAsInt( arguments.levelMax );
		}
		// Verify level
		if (
			this.logLevels.isLevelValid( arguments.levelMax ) AND
			arguments.levelMax gte getLevelMin()
		) {
			variables.levelMax = arguments.levelMax;
		} else {
			throw(
				message = "Invalid Log Level",
				detail  = "The log level #arguments.levelMax# is invalid or less than the levelMin (#getLevelMin()#). Valid log levels are from 0 to 5",
				type    = "Logger.InvalidLogLevelException"
			);
		}

		return this;
	}

	/**
	 * Log a debug message
	 *
	 * @message   The message to log
	 * @extraInfo Extra information to send to appenders
	 *
	 * @return Logger
	 */
	function debug( required message, extraInfo = "" ){
		arguments.severity = this.logLevels.DEBUG;
		return logMessage( argumentCollection = arguments );
	}

	/**
	 * Log a info message
	 *
	 * @message   The message to log
	 * @extraInfo Extra information to send to appenders
	 *
	 * @return Logger
	 */
	function info( required message, extraInfo = "" ){
		arguments.severity = this.logLevels.INFO;
		return logMessage( argumentCollection = arguments );
	}

	/**
	 * Log a warn message
	 *
	 * @message   The message to log
	 * @extraInfo Extra information to send to appenders
	 *
	 * @return Logger
	 */
	function warn( required message, extraInfo = "" ){
		arguments.severity = this.logLevels.WARN;
		return logMessage( argumentCollection = arguments );
	}

	/**
	 * Log an error message
	 *
	 * @message   The message to log
	 * @extraInfo Extra information to send to appenders
	 *
	 * @return Logger
	 */
	function error( required message, extraInfo = "" ){
		arguments.severity = this.logLevels.ERROR;
		return logMessage( argumentCollection = arguments );
	}

	/**
	 * Log a fatal message
	 *
	 * @message   The message to log
	 * @extraInfo Extra information to send to appenders
	 *
	 * @return Logger
	 */
	function fatal( required message, extraInfo = "" ){
		arguments.severity = this.logLevels.FATAL;
		return logMessage( argumentCollection = arguments );
	}

	/**
	 * Write an entry into the loggers registered with this LogBox variables
	 *
	 * @message   The message to log
	 * @severity  The severity level to log, if invalid, it will default to **Info**
	 * @extraInfo Extra information to send to appenders
	 */
	Logger function logMessage(
		required message,
		required severity,
		extraInfo = ""
	){
		var target = this;

		// Verify severity, if invalid, default to INFO
		if ( NOT this.logLevels.isLevelValid( arguments.severity ) ) {
			arguments.severity = this.logLevels.INFO;
		}

		// If message empty, just exit
		arguments.message = trim( arguments.message );
		if ( NOT len( arguments.message ) ) {
			return this;
		}

		// Is Logging Enabled?
		if ( getLevelMin() eq this.logLevels.OFF ) {
			return this;
		}

		// Can we log on target
		if ( canLog( arguments.severity ) ) {
			// Create Logging Event
			arguments.category = target.getCategory();

			// Do we have appenders locally? or go to root Logger
			if ( NOT hasAppenders() ) {
				target = getRootLogger();
			}


			// Process all appenders
			var targetAppenders = target
				.getAppenders()
				// Only go through appenders that can log
				.filter( function( key, thisAppender ){
					return thisAppender.canLog( severity );
				} );

			for ( var key in targetAppenders ) {
				var thisAppender = targetAppenders[ key ];
				// check to see if the async property was passed during definition and not in a thread already
				if (
					thisAppender.getProperty( "async", false ) &&
					!variables.util.inThread()
				) {
					// Thread this puppy
					thread
						action      ="run"
						name        ="logMessage_#replace( createUUID(), "-", "", "all" )#"
						appenderName="#key#"
						message     ="#arguments.message#"
						severity    ="#arguments.severity#"
						extraInfo   ="#arguments.extraInfo#"
						category    ="#arguments.category#" {
						var target  = this;
						if ( !hasAppenders() ) {
							target = getRootLogger();
						}
						var thisAppender = target.getAppender( attributes.appenderName );
						thread.logEvent  = new coldbox.system.logging.LogEvent(
							message   = attributes.message,
							severity  = attributes.severity,
							extraInfo = attributes.extraInfo,
							category  = attributes.category
						);
						thisAppender.logMessage( thread.logEvent );
					}
				} else {
					if ( isNull( local.logEvent ) ) {
						var logEvent = new coldbox.system.logging.LogEvent( argumentCollection = arguments );
					}
					thisAppender.logMessage( local.logEvent );
				}
			}
		}

		return this;
	}

	/**
	 * Checks wether a log can be made on this Logger using a passed in level
	 *
	 * @level The numeric or string level representation
	 */
	boolean function canLog( required level ){
		// If numeric, do a comparison immediately.
		if ( isNumeric( arguments.level ) ) {
			return ( arguments.level GTE getLevelMin() AND arguments.level LTE getLevelMax() );
		}
		// Else it is a string
		return ( canLog( this.LogLevels.lookupAsInt( arguments.level ) ) );
	}

	/**
	 * Can I log a fatal message
	 */
	boolean function canFatal(){
		return canLog( this.logLevels.FATAL );
	}

	/**
	 * Can I log a ERROR message
	 */
	boolean function canError(){
		return canLog( this.logLevels.ERROR );
	}

	/**
	 * Can I log a WARN message
	 */
	boolean function canWarn(){
		return canLog( this.logLevels.WARN );
	}

	/**
	 * Can I log a INFO message
	 */
	boolean function canInfo(){
		return canLog( this.logLevels.INFO );
	}

	/**
	 * Can I log a DEBUG message
	 */
	boolean function canDebug(){
		return canLog( this.logLevels.DEBUG );
	}

}
