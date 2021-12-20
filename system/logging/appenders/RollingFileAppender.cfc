/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * A RollingFileAppender. This appenders rotates the log files according to the properties defined.
 *
 * Properties:
 *
 * - filepath : The location of where to store the log file.
 * - autoExpand : Whether to expand the file path or not. Defaults to true.
 * - filename : The name of the file, if not defined, then it will use the name of this appender. Do not append an extension to it. We will append a .log to it.
 * - fileEncoding : The file encoding to use, by default we use UTF-8;
 * - fileMaxSize : The max file size for log files. Defaults to 2000 (2 MB)
 * - fileMaxArchives : The max number of archives to keep. Defaults to 2.
 **/
component accessors="true" extends="coldbox.system.logging.appenders.FileAppender" {

	/**
	 * Constructor
	 *
	 * @name       The unique name for this appender.
	 * @properties A map of configuration properties for the appender"
	 * @layout     The layout class to use in this appender for custom message rendering.
	 * @levelMin   The default log level for this appender, by default it is 0. Optional. ex: LogBox.logLevels.WARN
	 * @levelMax   The default log level for this appender, by default it is 5. Optional. ex: LogBox.logLevels.WARN
	 */
	function init(
		required name,
		struct properties = {},
		layout            = "",
		levelMin          = 0,
		levelMax          = 4
	){
		super.init( argumentCollection = arguments );

		if ( NOT propertyExists( "fileMaxSize" ) OR NOT isNumeric( getProperty( "fileMaxSize" ) ) ) {
			setProperty( "fileMaxSize", "2000" );
		}
		if ( NOT propertyExists( "fileMaxArchives" ) OR NOT isNumeric( getProperty( "fileMaxArchives" ) ) ) {
			setProperty( "fileMaxArchives", "2" );
		}

		variables.fileRotator = new coldbox.system.logging.util.FileRotator();

		return this;
	}

	/**
	 * Called upon registration
	 */
	function onRegistration(){
		super.onRegistration();

		variables.logbox
			.getTaskScheduler()
			.newSchedule( this, "logRotation" )
			.delay( 1 ) // Don't start immediately, give it a breathing room
			.spacedDelay( 1 ) // Runs again, after this spaced delay once each reap finalizes
			.inMinutes()
			.start();

		return this;
	}

	function logRotation(){
		try {
			variables.fileRotator.checkRotation( this );
		} catch ( Any e ) {
			var errorMessage = "Error rotating #getName()# : #e.message# #e.detail# #e.stacktrace#";
			err( errorMessage );
			$log( "ERROR", errorMessage );
			rethrow;
		}
	}

}
