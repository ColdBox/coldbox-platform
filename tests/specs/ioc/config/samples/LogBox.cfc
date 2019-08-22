/**
 *********************************************************************************
 * Copyright Since 2005 ColdBox Platform by Ortus Solutions, Corp
 * www.coldbox.org | www.ortussolutions.com
 ********************************************************************************
 * LogBox Configuration
 */
component {

	function configure(){
		var system = createObject( "java", "java.lang.System" );
		var homeDir = expandPath( "/coldbox/tests" );

		logBox = {};


		// Define Appenders
		logBox.appenders = {
			fileAppender : {
				class : "coldbox.system.logging.appenders.RollingFileAppender",
				properties : {
					fileMaxArchives : 5,
					filename : "commandbox",
					filepath : homeDir & "/logs",
					async : true
				}
			}
		};

		// Root Logger
		logBox.root = { levelmax : "INFO", levelMin : "FATAL", appenders : "fileAppender" };
	}

}
