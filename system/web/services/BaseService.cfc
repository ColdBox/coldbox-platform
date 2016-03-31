/**
********************************************************************************
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
********************************************************************************
* A ColdBox base internal service
*/
component accessors="true" doc_abstract="true"{

	/**
	* ColdBox Controller
	*/
	property name="controller";

	// ************************ INTERNAL EVENTS ************************//

	/**
	* Once configuration file loads
	*/
	function onConfigurationLoad(){}

	/**
	* On framework shutdown
	*/
	function onShutdown(){}

}