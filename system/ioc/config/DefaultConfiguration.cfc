<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Author 	 :	Luis Majano
Description :
	The default ColdBox WireBox Injector configuration object that is used when the
	WireBox injector is created
----------------------------------------------------------------------->
<cfcomponent output="false" hint="The default WireBox Injector configuration object">
<cfscript>
	
	/**
	* Configure WireBox, that's it!
	*/
	function configure(){
		
		// The WireBox configuration structure DSL
		wireBox = {
			// LogBox Configuration file
			logBoxConfig 	= "coldbox.system.ioc.config.LogBox", 
			
			// CacheBox Integration
			cacheBox = {
				enabled = false 
				// configFile = "coldbox.system.ioc.config.CacheBox", An optional configuration file to use for loading CacheBox
				// cacheFactory = ""  A reference to an already instantiated CacheBox CacheFactory
			},			
			
			// Scope registration, automatically register a wirebox injector instance on any CF scope
			// By default it registeres itself on application scope
			scopeRegistration = {
				enabled = true,
				scope   = "application", // server, cluster, session, application
				key		= "wireBox"
			},

			// DSL Namespace registrations
			customDSL = {
				//namespace = "class.path"
			},
			
			// Custom Storage Scopes
			customScopes = {
				// annotationName = "class.path"
			},
			
			// Package scan locations
			scanLocations = [
			],
			
			// Parent Injector to assign to the configured injector, this must be an object reference
			parent = "",
			
			// Register all event listeners here, they are created in the specified order
			listeners = [
				// { class="", name="", properties={} }
			]			
		};
	}	
</cfscript>
</cfcomponent>