/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * A ColdFusion Appender
 * - logType 	: file or application
 * - fileName 	: The log file name to use, else uses the appender's name
**/
component accessors="true" extends="coldbox.system.logging.AbstractAppender"{

	/**
	 * Constructor
	 *
	 * @name The unique name for this appender.
	 * @properties A map of configuration properties for the appender"
	 * @layout The layout class to use in this appender for custom message rendering.
	 * @levelMin The default log level for this appender, by default it is 0. Optional. ex: LogBox.logLevels.WARN
	 * @levelMax The default log level for this appender, by default it is 5. Optional. ex: LogBox.logLevels.WARN
	 *
	 * @throws CFAppender.InvalidLogTypeException
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

		// Verify properties
		if( NOT propertyExists( 'logType' ) ){
			setProperty( "logType", "file" );
		} else {
			// Check types
			if( NOT reFindNoCase( "^(file|application)$", getProperty( "logType" ) ) ){
				throw(
					message = "Invalid logtype chosen #getProperty("logType")#",
					detail  = "Valid types are file or application",
					type    = "CFAppender.InvalidLogTypeException"
				);
			}
		}
		if( NOT propertyExists( "fileName" ) ){
			setProperty( "fileName", getName() );
		}

		return this;
    }

    /**
	 * Write an entry into the appender. You must implement this method yourself.
	 *
	 * @logEvent The logging event to log
	 */
	function logMessage( required coldbox.system.logging.LogEvent logEvent ){
		var entry = "";

		if( hasCustomLayout() ){
			entry = getCustomLayout().format( arguments.logEvent );
		} else {
			entry = "#arguments.logEvent.getCategory()# #arguments.logEvent.getMessage()# ExtraInfo: #arguments.logEvent.getextraInfoAsString()#";
		}

		if( getProperty( "logType" ) == "file" ){
			cflog(
				file = getProperty( "fileName" ),
				type = "#this.logLevels.lookupCF( arguments.logEvent.getSeverity() )#",
				text = entry
			);
		} else {
			cflog(
				file = "Application",
				type = "#this.logLevels.lookupCF( arguments.logEvent.getSeverity() )#",
				text = entry
			);
		}

		return this;
	}

}