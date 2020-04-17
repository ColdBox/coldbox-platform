/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * The default ColdBox LogBox configuration object for ColdBox Applications
 */
component {

	/**
	 * Configure LogBox, that's it!
	 */
	function configure(){
		logBox = {};

		// Define Appenders
		logBox.appenders = { console : { class : "ConsoleAppender" } };

		// Root Logger
		logBox.root = { levelmax : "INFO", appenders : "*" };
	}

}
