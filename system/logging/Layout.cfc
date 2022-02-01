/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * This is a base layout object that will help you create custom layout's for messages in appenders
 **/
component accessors="true" {

	/**
	 * The LogBox appender this layotu is linked to.
	 */
	property name="appender";

	// The log levels enum as a public property
	this.logLevels = new coldbox.system.logging.LogLevels();
	// A line Sep Constant, man, wish we had final in CF.
	this.LINE_SEP  = chr( 13 ) & chr( 10 );

	/**
	 * Constructor
	 *
	 * @appender The appender this layout is linked to.
	 */
	function init( required appender ){
		variables.appender = arguments.appender;
		return this;
	}

	/**
	 * Format a logging event message into your own format
	 *
	 * @logEvent The LogBox logging event object
	 */
	function format( required logEvent ){
		throw(
			message = "You must implement this layout's format() method",
			type    = "FormatNotImplementedException"
		)
	}

}
