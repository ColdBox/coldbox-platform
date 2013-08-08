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
	function configure(binder){
		
		// The WireBox configuration structure DSL
		wireBox = {
			// LogBox Configuration file
			logBoxConfig 	= "coldbox.system.ioc.config.LogBox", 
			
			// CacheBox Integration
			cacheBox = {
				enabled = true 
				// configFile = "coldbox.system.ioc.config.CacheBox", An optional configuration file to use for loading CacheBox
				// cacheFactory = ""  A reference to an already instantiated CacheBox CacheFactory
				// classNamespace = "" A class path namespace to use to create CacheBox: Default=coldbox.system.cache or wirebox.system.cache
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
			
			// Stop recursions
			stopRecursions = [ "coldbox.system.Interceptor"	],
			
			// Parent Injector to assign to the configured injector, this must be an object reference
			parent = "",
			
			// Register all event listeners here, they are created in the specified order
			listeners = [
				{ class="coldbox.testing.cases.ioc.listeners.MyListener", name="MyListener", 
				  properties={
				  	name="CoolListener"
				  } }
			]	
		};
		
		// WireBox Mappings
		wirebox.mappings = {
			myBean = {alias="jose",path="my.path.Sample"},
			buffer = {path="java.lang.StringBuffer", type=binder.TYPES.JAVA,
					  DIConstructorArgs=[
					  	{name="buffer", value="16", javaCast="int"}
					  ]}
		};
	}	
</cfscript>
</cfcomponent>