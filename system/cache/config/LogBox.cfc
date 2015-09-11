/********************************************************************************
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
********************************************************************************
The logging configuration object for CacheBox Standalone version.
You can make changes here to determine how CacheBox logs information.  For more
information about logBox visit: http://wiki.coldbox.org/wiki/LogBox.cfm
**/
component{

	/**
	*  Configure logBox
	*/
	function configure(){
		variables.logBox = {
			// Define Appenders
			appenders = {
				console = {
					class="coldbox.system.logging.appenders.ConsoleAppender"
				}
			},
			// Root Logger
			root = { levelmax="INFO", appenders="*" }
		};
	}

}