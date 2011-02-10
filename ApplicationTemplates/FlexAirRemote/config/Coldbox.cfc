<cfcomponent output="false" hint="My App Configuration">
<cfscript>
/**
structures to create for configuration

- coldbox
- settings
- conventions
- environments
- ioc
- models (DEPRECATED use wirebox instead)
- wirebox
- debugger
- mailSettings
- i18n
- bugTracers
- webservices
- datasources
- layoutSettings
- layouts
- cacheEngine
- interceptorSettings
- interceptors
- modules

Available objects in variable scope
- controller
- logBoxConfig
- appMapping (auto calculated by ColdBox)

Required Methods
- configure() : The method ColdBox calls to configure the application.
Optional Methods
- detectEnvironment() : If declared the framework will call it and it must return the name of the environment you are on.
- {environment}() : The name of the environment found and called by the framework.

*/
	
// Configure ColdBox Application
function configure(){

	// coldbox directives
	coldbox = {
		//Application Setup
		appName 				= "Your App Name Here",
		//eventName 				= "event",
		
		//Development Settings
		debugMode				= true,
		debugPassword			= "",
		reinitPassword			= "",
		handlersIndexAutoReload = true,
		configAutoReload		= false,
		
		//Implicit Events
		defaultEvent			= "general.index",
		requestStartHandler		= "",
		requestEndHandler		= "",
		applicationStartHandler = "main.onAppInit",
		applicationEndHandler	= "",
		sessionStartHandler 	= "",
		sessionEndHandler		= "",
		missingTemplateHandler	= "",
		
		//Extension Points
		UDFLibraryFile 			= "",
		coldboxExtensionsLocation = "",
		modulesExternalLocation		= [],
		viewsExternalLocation	= "",
		layoutsExternalLocation = "",
		handlersExternalLocation  = "",
		requestContextDecorator = "",
		
		//Error/Exception Handling
		exceptionHandler		= "",
		onInvalidEvent			= "",
		customErrorTemplate		= "",
			
		//Application Aspects
		handlerCaching 			= false,
		eventCaching			= false,
		proxyReturnCollection 	= false,
		flashURLPersistScope	= "session"
	};
	
	// environment settings, create a detectEnvironment() method to detect it yourself.
	// create a function with the name of the environment so it can be executed if that environment is detected
	// the value of the environment is a list of regex patterns to match the cgi.http_host.
	environments = {
		//development = "^cf8.,^railo."
	};
	
	// custom settings
	settings = {
	
	};
	
	//WireBox Integration
	wireBox = { 
		enabled = true,
		//binder="config.WireBox", 
		singletonReload=true 
	};
	
	// Module Directives
	modules = {
		//Turn to false in production
		autoReload = true,
		// An array of modules names to load, empty means all of them
		include = [],
		// An array of modules names to NOT load, empty means none
		exclude = [] 
	};
	
	//Conventions
	conventions = {
		handlersLocation = "monitor/handlers",
		pluginsLocation = "monitor/plugins",
		viewsLocation 	 = "monitor/views",
		layoutsLocation  = "monitor/layouts",
		modulesLocation	 = "monitor/modules"
	};
	
	//LogBox DSL
	logBox = {
		// Define Appenders
		appenders = {
			coldboxTracer = { class="coldbox.system.logging.appenders.ColdboxTracerAppender" }
		},
		// Root Logger
		root = { levelmax="INFO", appenders="*" },
		// Implicit Level Categories
		info = [ "coldbox.system" ] 
	};
	
	//Layout Settings
	layoutSettings = {
		defaultLayout = "Layout.Main.cfm"
	};
	
	//Register interceptors as an array, we need order
	interceptors = [
		 //Autowire
		 {class="coldbox.system.interceptors.Autowire"}
	];
	
}
	
</cfscript>
</cfcomponent>