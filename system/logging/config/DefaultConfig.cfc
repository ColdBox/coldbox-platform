/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * The default logging configuration for a vanilla LogBox instance
 **/
component {

	/**
	 *  Configure logBox
	 */
	function configure(){
		logBox = {
			// Define Appenders
			appenders : { console : { class : "ConsoleAppender" } },
			// Root Logger
			root      : { levelmax : "INFO", appenders : "*" }
		};
	}

}
