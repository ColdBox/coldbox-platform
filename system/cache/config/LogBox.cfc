/********************************************************************************
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
* *******************************************************************************
**/
component {

	/**
	 * Configure logBox
	 */
	function configure(){
		variables.logBox = {
			// Define Appenders
			appenders : { console : { class : "ConsoleAppender" } },
			// Root Logger
			root      : { levelmax : "INFO", appenders : "*" }
		};
	}

}
