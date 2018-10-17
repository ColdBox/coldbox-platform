/**
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
* ---
* This component is used as a base for creating LogBox appenders
**/
component accessors="true"{

	/**
	 * Min logging level
	 */
	property name="levelMin" type="numeric";

	/**
	 * Max logging level
	 */
	property name="levelMax" type="numeric";

	/**
	 * Appender properties
	 */
	property name="properties" type="struct";

	/**
	 * Appender name
	 */
	property name="name" default="";

	/**
	 * Appender initialized flag
	 */
	property name="initialized" type="boolean" default="false";

	/**
	 * Appender customLayout for rendering messages
	 */
	property name="customLayout";

	/**
	 * ColdBox Controller Linkage, empty if in standalone mode.
	 */
	property name="coldbox";

	// The log levels enum as a public property
	this.logLevels = new coldbox.system.logging.LogLevels();

	/**
	 * Constructor
	 *
	 * @name The unique name for this appender.
	 * @properties A map of configuration properties for the appender"
	 * @layout The layout class to use in this appender for custom message rendering.
	 * @levelMin The default log level for this appender, by default it is 0. Optional. ex: LogBox.logLevels.WARN
	 * @levelMax The default log level for this appender, by default it is 5. Optional. ex: LogBox.logLevels.WARN
	 */
	function init(
		required name,
		struct properties={},
		layout="",
		levelMin=0,
		levelMax=4
	){
		// Appender Unique ID */
		variables._hash        = createObject( 'java', 'java.lang.System' ).identityHashCode( this );
		// Flag denoting if the appender is inited or not. This will be set by LogBox upon succesful creation and registration.
		variables.initialized  = false;

		// Appender's Name
		variables.name = REreplacenocase( arguments.name, "[^0-9a-z]", "", "ALL" );

		// Set internal properties
		variables.properties = arguments.properties;

		// Custom Renderer For Messages
		variables.customLayout = "";
		if( len( trim( arguments.layout ) ) ){
			variables.customLayout = createObject( "component", arguments.layout ).init( this );
		}

		// Levels
		variables.levelMin = arguments.levelMin;
		variables.levelMax = arguments.levelMax;

		return this;
	}

	/**
	 * Runs after the appender has been created and registered. Implemented by Concrete appender
	 */
	AbstractAppender function onRegistration(){
		return this;
	}

	/**
	 * Runs before the appender is unregistered from LogBox. Implemented by Concrete appender
	 */
	AbstractAppender function onUnRegistration(){
		return this;
	}

	/**
	 * Setter for level min
	 *
	 * @throws AbstractAppender.InvalidLogLevelException
	 */
	AbstractAppender function setLevelMin( required levelMin ){
		// Verify level
		if( this.logLevels.isLevelValid( arguments.levelMin ) AND arguments.levelMin lte getLevelMax() ){
			variables.levelMin = arguments.levelMin;
			return this;
		} else {
			throw(
				message = "Invalid Log Level",
				detail  = "The log level #arguments.levelMin# is invalid or greater than the levelMax (#getLevelMax()#). Valid log levels are from 0 to 5",
				type    = "AbstractAppender.InvalidLogLevelException"
			);
		}
	}

	/**
	 * Setter for level max
	 *
	 * @throws AbstractAppender.InvalidLogLevelException
	 */
	AbstractAppender function setLevelMax( required levelMax ){
		// Verify level
		if( this.logLevels.isLevelValid( arguments.levelMax ) AND arguments.levelMax gte getLevelMin() ){
			variables.levelMax = arguments.levelMax;
			return this;
		} else {
			throw(
				message = "Invalid Log Level",
				detail  = "The log level #arguments.levelMax# is invalid or less than the levelMin (#getLevelMin()#). Valid log levels are from 0 to 5",
				type    = "AbstractAppender.InvalidLogLevelException"
			);
		}
	}

	/**
	 * Verify if we have a custom layout object linked
	 */
	boolean function hasCustomLayout(){
		return isObject( variables.customLayout );
	}

	/**
	 * convert a severity to a string
	 *
	 * @severity The severity to convert to a string
	 */
	function severityToString( required numeric severity){
		return this.logLevels.lookup( arguments.severity );
	}

	/**
	 * Get internal hash id
	 */
	function getHash(){
		return variables._hash;
	}

	/**
	 * Is appender initialized
	 */
	boolean function isInitialized(){
		return variables.initialized;
	}

	/**
	 * Write an entry into the appender. You must implement this method yourself.
	 *
	 * @logEvent The logging event to log
	 */
	AbstractAppender function logMessage( required coldbox.system.logging.LogEvent logEvent ){
		return this;
	}

	/**
	 * Checks wether a log can be made on this appender using a passed in level
	 *
	 * @level The level to check
	 */
	boolean function canLog( required numeric level ){
		return ( arguments.level GTE getLevelMin() AND arguments.level LTE getLevelMax() );
	}

	/**
	 * Get a property from the `properties` struct
	 *
	 * @property The property key
	 * @defaultValue The default value to use if not found.
	 */
	function getProperty( required property, defaultValue ){
		if( variables.properties.keyExists( arguments.property ) ){
			return variables.properties[ arguments.property ];
		} else if( !isNull( arguments.defaultValue ) ){
			return arguments.defaultValue;
		}
	}

	/**
	 * Set a property from the `properties` struct
	 *
	 * @property The property key
	 * @value The value of the property
	 */
	AbstractAppender function setProperty( required property, required value ){
		variables.properties[ arguments.property ] = arguments.value;
		return this;
	}

	/**
	 * Validate a property from the `properties` struct
	 *
	 * @property The property key
	 */
	boolean function propertyExists( required property ){
		return structKeyExists( variables.properties, arguments.property );
	}

	/****************************************** PRIVATE *********************************************/

	/**
	 * Get the ColdBox Utility object
	 */
	private function getUtil(){
		if( structKeyExists( variables, "util" ) ){ return variables.util; }
		variables.util = new coldbox.system.core.util.Util();
		return variables.util;
	}

	/**
	 * Facade to internal ColdFusion logging facilities, just in case.
	 */
	private AbstractAppender function $log( required severity, required message ){
		cflog( type=arguments.severity, file="LogBox", text=arguments.message );
		return this;
	}

	/**
	 * Utiliy to send to output to console.
	 *
	 * @message Message to send
	 * @addNewLine Add a line break or not, default is yes
	 */
	private function out( required message, boolean addNewLine=true ){
		if( arguments.addNewLine ){
			arguments.message &= chr( 13 ) & chr( 10 );
		}
		createObject( "java", "java.lang.System" ).out.println( arguments.message );
	}

}