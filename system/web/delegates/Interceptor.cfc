/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * Provides ability to listen, announce interception events
 */
component singleton {

	// DI
	property
		name    ="interceptorService"
		inject  ="coldbox:interceptorService"
		delegate="listen,announce";

}
