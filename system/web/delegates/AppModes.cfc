/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * Provides the ability to know in which modes your application is via the delegated methods
 */
component singleton {

	// DI
	property
		name    ="controller"
		inject  ="coldbox"
		delegate="inDebugMode,isDevelopment,isProduction,isTesting";

}
