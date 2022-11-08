/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * Provides rendering delegation capabilities.
 * Technically you can delegate to the Renderer, but this is a simplified interface
 */
component accessors="true" singleton {

	// DI
	property
		name    ="renderer"
		inject  ="Renderer@coldbox"
		delegate="view,layout,externalView";

}
