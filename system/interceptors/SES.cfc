/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * @deprecated The routing service is now a first class citizen in ColdBox. This class will be removed in the future, please do not use it.
 *
 * This interceptor has now been deprecated, there is no need to define an SES interceptor. URL Routing is now done by the ColdBox
 * Routing Service. Also, please stop retrieving the SES interceptor using `getInterceptor( "SES" )`. You can retrieve the new Routing
 * service either through the ColdBox controller or the ColdBox Injection DSL
 *
 * <pre>
 * controller.getRoutingService()
 *
 * property name="routingService" inject="coldbox:routingService"
 * </pre>
 */
component extends="coldbox.system.Interceptor" accessors="true"{

	/**
	 * Constructor
	 */
	function configure(){
		variables.routingService = variables.controller.getRoutingService();
	}

	/**
	 * We need at least one interception point to listen to for compatibility mode.
	 */
	function afterConfigurationLoad(){
		// Nothing here
	}

	/**
	 * Passthrough for legacy support. This will be removed in the next version.
	 */
	function onMissingMethod( missingMethodName, missingMethodArguments={} ){
		return invoke(
			variables.routingService,
			arguments.missingMethodName,
			arguments.missingMethodArguments
		);
	}

}