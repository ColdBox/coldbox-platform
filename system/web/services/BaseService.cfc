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

	/**
	 * Service logger
	 */
	property name="log";

	/**
	 * Env Delegate
	 */
	property name="envDelegate";

	// ************************ INTERNAL EVENTS ************************//

	/**
	 * Once configuration file loads
	 */
	function onConfigurationLoad(){
	}

	/**
	 * Once aspects are loaded
	 */
	function afterAspectsLoad(){
	}

	/**
	 * On framework shutdown
	 */
	function onShutdown(){
	}

	/**
	 * Get the service logger
	 */
	function getLogger(){
		if ( !structKeyExists( variables, "log" ) || isNull( variables.log ) ) {
			variables.log = variables.controller.getLogBox().getLogger( this )
		}
		return variables.log
	}

	/**
	 * Get the Env delegate
	 */
	function getEnvDelegate(){
		if ( !structKeyExists( variables, "envDelegate" ) || isNull( variables.envDelegate ) ) {
			variables.envDelegate = variables.controller.getWireBox().getInstance( "Env@coreDelegates" )
		}
		return variables.envDelegate
	}

	/**
	 * Get the LogBox instance (lazy-cached)
	 */
	function getLogBox(){
		if ( !structKeyExists( variables, "logBox" ) || isNull( variables.logBox ) ) {
			variables.logBox = variables.controller.getLogBox()
		}
		return variables.logBox
	}

	/**
	 * Get the CacheBox instance (lazy-cached)
	 */
	function getCacheBox(){
		if ( !structKeyExists( variables, "cacheBox" ) || isNull( variables.cacheBox ) ) {
			variables.cacheBox = variables.controller.getCacheBox()
		}
		return variables.cacheBox
	}

}
