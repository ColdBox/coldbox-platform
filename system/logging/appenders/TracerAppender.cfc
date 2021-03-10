/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * A simple cftracer appender
**/
component accessors="true" extends="coldbox.system.logging.AbstractAppender" {

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
        // Init supertype
		super.init( argumentCollection=arguments );

		return this;
    }

    /**
	 * Write an entry into the appender. You must implement this method yourself.
	 *
	 * @logEvent The logging event to log
	 */
	function logMessage( required coldbox.system.logging.LogEvent logEvent ){
		var loge 	      = arguments.logEvent;
		var entry 	      = "";
		var traceSeverity = "information";

		if( hasCustomLayout() ){
			entry = getCustomLayout().format( loge );
		} else {
			entry = "#loge.getMessage()# ExtraInfo: #loge.getextraInfoAsString()#";
		}

		// Severity by cftrace
		switch( this.logLevels.lookupCF( loge.getSeverity() ) ){
			case "FATAL" : { traceSeverity = "fatal information"; break; }
			case "ERROR" : { traceSeverity = "error"; break; }
			case "WARN"  : { traceSeverity = "warning"; break; }
		}

		cftrace( category="#loge.getCategory()#", text="#entry#", type="#traceSeverity#" );

		return this;
	}

}