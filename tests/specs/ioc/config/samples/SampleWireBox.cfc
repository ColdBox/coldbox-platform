﻿component {

	/**
	 * Configure WireBox, that's it!
	 */
	function configure( binder ){
		// The WireBox configuration structure DSL
		wireBox = {
			// CacheBox Integration
			cacheBox : {
				enabled : true
				// configFile = "coldbox.system.ioc.config.CacheBox", An optional configuration file to use for loading CacheBox
				// cacheFactory = ""  A reference to an already instantiated CacheBox CacheFactory
				// classNamespace = "" A class path namespace to use to create CacheBox: Default=coldbox.system.cache or wirebox.system.cache
			},
			// Scope registration, automatically register a wirebox injector instance on any CF scope
			// By default it registers itself on application scope
			scopeRegistration : {
				enabled : true,
				scope   : "application", // server, session, application
				key     : "wireBox"
			},
			// DSL Namespace registrations
			customDSL      : {},
			// Custom Storage Scopes
			customScopes   : {},
			// Package scan locations
			scanLocations  : [],
			// Stop recursions
			stopRecursions : [ "coldbox.system.Interceptor" ],
			// Parent Injector to assign to the configured injector, this must be an object reference
			parent         : "",
			// Register all event listeners here, they are created in the specified order
			listeners      : [
				{
					class      : "coldbox.tests.specs.ioc.listeners.MyListener",
					name       : "MyListener",
					properties : { name : "CoolListener" }
				}
			]
		};

		// WireBox Mappings
		wirebox.mappings = {
			myBean : { alias : "jose", path : "my.path.Sample" },
			buffer : {
				path                   : "java.lang.StringBuilder",
				type                   : binder.TYPES.JAVA,
				DIConstructorArguments : [ { name : "buffer", value : "16", javaCast : "int" } ]
			}
		};
	}

}
