/**
********************************************************************************
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
* A ColdBox base internal service
*/
component accessors="true"{

	// controller reference
	property name="controller";

	function getUtil(){
		return controller.getUtil();
	}

	// ************************ INTERNAL EVENTS ************************//

	function onConfigurationLoad(){}
	function onShutdown(){}

}