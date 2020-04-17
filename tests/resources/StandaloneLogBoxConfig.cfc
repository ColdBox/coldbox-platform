/**
 * Standalone LogBox Config
 */
component {

	/**
	 * Configure LogBox, that's it!
	 */
	function configure(){
		logBox = {};

		// Define Appenders
		logBox.appenders = { scope : { class : "coldbox.system.logging.appenders.ScopeAppender" } };

		// Root Logger
		logBox.root = {
			levelmax  : "DEBUG",
			levelMin  : "FATAL",
			appenders : "*"
		};
	}

}
