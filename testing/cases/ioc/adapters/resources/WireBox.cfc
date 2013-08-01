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
			cacheBox = { enabled = false },			
			
			// Scope registration, automatically register a wirebox injector instance on any CF scope
			// By default it registeres itself on application scope
			scopeRegistration = { enabled = false }
		};
		
		// WireBox Mappings
		wirebox.mappings = {
			TestService = {path="coldbox.testing.testmodel.TestService"}
		};
	}	
</cfscript>
</cfcomponent>