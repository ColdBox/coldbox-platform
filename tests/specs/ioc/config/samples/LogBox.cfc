/**
 *********************************************************************************
 * Copyright Since 2005 ColdBox Platform by Ortus Solutions, Corp
 * www.coldbox.org | www.ortussolutions.com
 ********************************************************************************
 * LogBox Configuration
 */
component {

	function configure(){
		var system  = createObject( "java", "java.lang.System" );
		var homeDir = expandPath( "/tests" );

		logBox = {};

		// Define Appenders
		logBox.appenders = { consoleAppender : { class : "ConsoleAppender" } };

		// Root Logger
		logBox.root = {
			levelmax  : "INFO",
			levelMin  : "FATAL",
			appenders : "consoleAppender"
		};
	}

}
