/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * This is the default WireBox Module Binder each module get's assigned with.
 **/
component extends="coldbox.system.ioc.config.Binder" {

	/**
	 * Configure WireBox, that's it!
	 */
	function configure(){
		// The WireBox configuration structure DSL
		wireBox = {
			// Default LogBox Configuration file
			logBoxConfig : "coldbox.system.ioc.config.LogBox",
			// CacheBox Integration OFF by default
			cacheBox     : {
				enabled : false
				// configFile = "coldbox.system.ioc.config.CacheBox", An optional configuration file to use for loading CacheBox
				// cacheFactory = ""  A reference to an already instantiated CacheBox CacheFactory
				// classNamespace = "" A class path namespace to use to create CacheBox: Default=coldbox.system.cache or wirebox.system.cache
			},
			// Name of a CacheBox cache to store metadata in to speed up start time.
			// Since metadata is already stored in memory, this is only useful for a disk, etc cache that persists across restarts.
			metadataCache     : "",
			// Modules are scoped via it's parent, so it's disabled here
			scopeRegistration : { enabled : false },
			// DSL Namespace registrations
			customDSL         : {
				 // namespace = "mapping name"
			},
			// Custom Storage Scopes
			customScopes : {
				 // annotationName = "mapping name"
			},
			// Package scan locations
			scanLocations  : [],
			// Stop Recursions
			stopRecursions : [],
			// Parent Injector to assign to the configured injector, this must be an object reference
			parentInjector : "",
			// Register all event listeners here, they are created in the specified order
			listeners      : [
				 // { class="", name="", properties={} }
			]
		};
	}

}
