﻿/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * This resembles a logging event within LogBox
 **/
component accessors="true" {

	/**
	 * The category to log messages under
	 */
	property name="category" default="";

	/**
	 * The timestamp of the log
	 */
	property name="timestamp";

	/**
	 * The message to log
	 */
	property name="message" default="";

	/**
	 * The severity to log with
	 */
	property name="severity" default="";

	/**
	 * Any extra info to log
	 */
	property name="extrainfo" default="";

	/**
	 * Constructor
	 *
	 * @message   The message to log.
	 * @severity  The severity level to log.
	 * @extraInfo Extra information to send to the loggers.
	 * @category  The category to log this message under.  By default it is blank.
	 */
	function init(
		required message,
		required severity,
		extraInfo = "",
		category  = ""
	){
		// Init event
		variables.timestamp = now();

		for ( var key in arguments ) {
			if ( isSimpleValue( arguments[ key ] ) ) {
				arguments[ key ] = trim( arguments[ key ] );
			}
			variables[ key ] = arguments[ key ];
		}
		return this;
	}

	function getXmlConverter(){
		if ( isNull( variables.xmlConverter ) ) {
			variables.xmlConverter = new coldbox.system.core.conversion.XMLConverter();
		}
		return variables.xmlConverter;
	}

	function getUtil(){
		if ( isNull( variables.util ) ) {
			variables.util = new coldbox.system.core.util.Util();
		}
		return variables.util;
	}

	/**
	 * Get the extra info as a string representation
	 */
	function getExtraInfoAsString(){
		// Simple value, just return it
		if ( isSimpleValue( variables.extraInfo ) ) {
			return variables.extraInfo;
		}

		// Convention translation: $toString();
		if ( isObject( variables.extraInfo ) AND structKeyExists( variables.extraInfo, "$toString" ) ) {
			return variables.extraInfo.$toString();
		}

		// Is this a raw CFML Exception?
		if (
			( isObject( variables.extraInfo ) || isStruct( variables.extraInfo ) )
			&&
			structKeyExists( variables.extraInfo, "stacktrace" ) &&
			structKeyExists( variables.extraInfo, "message" ) &&
			structKeyExists( variables.extraInfo, "detail" )
		) {
			var messageString = [
				"[Message] 		: #variables.extraInfo.message#",
				"[Detail] 		: #variables.extraInfo.detail#",
				"[Stacktrace] 	: #variables.extraInfo.stacktrace#"
			];
			return arrayToList( messageString, chr( 13 ) & chr( 10 ) );
		}

		// Component XML conversion
		if ( isObject( variables.extraInfo ) ) {
			return getXmlConverter().toXML( variables.extraInfo );
		}

		// Complex values, return serialized in json
		return getUtil().toJSON( variables.extraInfo );
	}

}
