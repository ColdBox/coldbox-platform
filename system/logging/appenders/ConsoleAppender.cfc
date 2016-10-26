/**
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
* ---
* Console Appender
*/
component extends="coldbox.system.logging.AbstractAppender"{

	/**
	* Constructor
	*
	* @name        The unique name for this appender.
	* @properties  A map of configuration properties for the appender.
	* @layout      The layout class to use in this appender for custom message rendering.
	* @levelMin    The default log level for this appender, by default it is 0. Optional. ex: LogBox.logLevels.WARN
	* @levelMax    The default log level for this appender, by default it is 4. Optional. ex: LogBox.logLevels.WARN
	*/
	public ConsoleAppender function init(
	  	required string name,
		struct properties = {},
		string layout     = "",
		string levelMin   = 0,
		string levelMax   = 4 
	){
		super.init( argumentCollection=arguments );
		instance.out = createObject( "java", "java.lang.System" ).out;
    	return this;
	}

	/**
	* Write entry into the appender
	*
	* @logEvent The logging event.
	*/
	public void function logMessage( required any logEvent ) {
		if( hasCustomLayout() ){
		  var entry = getCustomLayout().format( logEvent );
		} else {
		  var entry = severityToString( logEvent.getseverity() ) & " " &
		  	logEvent.getCategory() & " " &
		  	logEvent.getmessage() & " ExtraInfo: " &
		  	logEvent.getextraInfoAsString();
		}
		
		// log message
		instance.out.println( entry );
		
		return;
	}

}