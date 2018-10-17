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
		variables.out 	= createObject( "java", "java.lang.System" ).out;
		variables.error = createObject( "java", "java.lang.System" ).err;
    	return this;
	}

	/**
	* Write entry into the appender
	*
	* @logEvent The logging event.
	*/
	function logMessage( required any logEvent ) {
		var entry = "";
		if( hasCustomLayout() ){
			entry = getCustomLayout().format( logEvent );
		} else {
		  	entry = severityToString( logEvent.getseverity() ) & " " &
		  		logEvent.getCategory() & " " &
		  		logEvent.getmessage();
		  	
		  	// Add extra info if it exists
			var extraInfoAsString = logEvent.getextraInfoAsString();
		  	if( len( extraInfoAsString ) ) {
		  		entry &= " ExtraInfo: " &
		  		extraInfoAsString;	
		  	}
		}
		switch( logEvent.getSeverity() ){
			// Fatal + Error go to error stream
			case "0" : case "1" : {
				// log message
				variables.error.println( entry );
				break;
			}
			// Warning and above go to info stream
			default : {
				// log message
				variables.out.println( entry );
				break;
			}
		}


		return this;
	}

}