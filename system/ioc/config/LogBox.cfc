/**
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
* ---
* The logging configuration object for WireBox Standalone version.
* You can make changes here to determine how WireBox logs information.  For more
* information about logBox visit: https://logbox.ortusbooks.com
**/
component{
	
	/**
	 *  Configure logBox
	 */
	function configure(){
		logBox = {
			// Define Appenders
			appenders = {
				console = { 
					class="coldbox.system.logging.appenders.ConsoleAppender"
				}
				/**,
				cflogs = {
					class="coldbox.system.logging.appenders.CFAppender",
					properties = { fileName="ColdBox-WireBox"}
				}
				**/
			},
			// Root Logger
			root = { levelmax="INFO", appenders="*" }
		};
	}

}