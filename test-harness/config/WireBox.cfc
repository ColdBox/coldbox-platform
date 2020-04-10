component extends = "coldbox.system.ioc.config.Binder"{
	/**
	 * Configure WireBox, that's it!
	 */
	function configure(){
		// The WireBox configuration structure DSL
		wireBox = {
			// Scope registration, automatically register a wirebox injector instance on any CF scope
			// By default it registeres itself on application scope
			scopeRegistration : {
				enabled : true,
				scope   : "application", // server, cluster, session, application
				key     : "wireBox"
			},
			// DSL Namespace registrations
			customDSL      : {},
			// Custom Storage Scopes
			customScopes   : {},
			// Package scan locations
			scanLocations  : [],
			// Stop Recursions
			stopRecursions : [],
			// Parent Injector to assign to the configured injector, this must be an object reference
			parentInjector : "",
			// Register all event listeners here, they are created in the specified order
			listeners      : [ { class : "coldbox.system.aop.Mixer" } ]
		};

		// Map Bindings below
		// Map some AOP aspects
		mapAspect( "MethodLogger" ).to( "coldbox.system.aop.aspects.MethodLogger" );

		map( "WireBoxURL" ).toValue( "http://www.coldbox.org" );
	}
}
