/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * Base Helper class for all ColdBox services
 */
component accessors="true" {

	/**
	 * ColdBox Controller
	 */
	property name="controller";

	// ************************ INTERNAL EVENTS ************************//

	/**
	 * Once configuration file loads
	 */
	function onConfigurationLoad(){
	}

	/**
	 * On framework shutdown
	 */
	function onShutdown(){
	}

}
