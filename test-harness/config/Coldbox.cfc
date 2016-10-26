component{

	// Configure ColdBox Application
	function configure(){

		// coldbox directives
		coldbox = {
			//Application Setup
			appName 				= "Test Harness",
			eventName 				= "event",

			//Development Settings
			reinitPassword			= "",
			handlersIndexAutoReload = true,

			//Implicit Events
			defaultEvent			= "",
			requestStartHandler		= "main.onRequestStart",
			requestEndHandler		= "main.onRequestEnd",
			applicationStartHandler = "main.onAppInit",
			applicationEndHandler	= "main.onAppStop",
			sessionStartHandler 	= "main.onSessionStart",
			sessionEndHandler		= "main.onSessionEnd",
			missingTemplateHandler	= "main.onMissingTemplate",

			//Extension Points
			applicationHelper 			= "includes/helpers/ApplicationHelper.cfm",
			viewsHelper					= "includes/helpers/ViewsHelper",
			modulesExternalLocation		= [ "/cbtestharness/external/testModules", "/cbtestharness/external/testModules2" ],
			viewsExternalLocation		= "/cbtestharness/external/testViews",
			layoutsExternalLocation 	= "/cbtestharness/external/testLayouts",
			handlersExternalLocation  	= "cbtestharness.external.testHandlers",
			requestContextDecorator 	= "cbtestharness.models.myRequestContextDecorator",
			controllerDecorator			= "cbtestharness.models.ControllerDecorator",

			//Error/Exception Handling
			invalidHTTPMethodHandler 	= "main.invalidHTTPMethod",
			exceptionHandler			= "main.onException",
			onInvalidEvent				= "main.onInvalidEvent",
			//customErrorTemplate		= "/coldbox/system/includes/BugReport.cfm",
			customErrorTemplate		= "views/_templates/generic_error.cfm",

			//Application Aspects
			handlerCaching 			= false,
			eventCaching			= true,
			proxyReturnCollection 	= false
		};

		// custom settings
		settings = {

		};

		// environment settings, create a detectEnvironment() method to detect it yourself.
		// create a function with the name of the environment so it can be executed if that environment is detected
		// the value of the environment is a list of regex patterns to match the cgi.http_host.
		environments = {
			development = "^cf.,^railo.,^localhost,jfetmac"
		};

		// Module Directives
		modules = {
			//Turn to false in production
			autoReload = false,
			// An array of modules names to load, empty means all of them
			include = [],
			// An array of modules names to NOT load, empty means none
			exclude = [ "excludedmod" ]
		};

		//LogBox DSL
		logBox = {
			// Define Appenders
			appenders = {
				myConsole     = { class="coldbox.system.logging.appenders.ConsoleAppender" },
				fileAppender  = { class="coldbox.system.logging.appenders.RollingFileAppender",
								  properties = {
								  	async = true,
								  	filePath="/cbTestHarness/logs", fileName=coldbox.appName, autoExpand=true, fileMaxSize="100"
								 }}
			},
			// Root Logger
			root = { levelmax="INFO", appenders="*" }
			//,debug = [ "coldbox.system" ]
		};

		//Layout Settings
		layoutSettings = {
			defaultLayout = "",
			defaultView   = ""
		};

		//Interceptor Settings
		interceptorSettings = {
			throwOnInvalidStates = false,
			customInterceptionPoints = ""
		};

		//Register interceptors as an array, we need order
		interceptors = [
			//SES
			{class="coldbox.system.interceptors.SES",
			 properties={}
			}
		];

		//Datasources
		datasources = {
			mysite   = {name="mySite", dbType="mysql", username="root", password="pass"},
			blog_dsn = {name="myBlog", dbType="oracle", username="root", password="pass"}
		};

		// flash scope configuration
		flash = {
			scope = "session",
			properties = {}, // constructor properties for the flash scope implementation
			inflateToRC = true, // automatically inflate flash data into the RC scope
			inflateToPRC = false, // automatically inflate flash data into the PRC scope
			autoPurge = true, // automatically purge flash data for you
			autoSave = true // automatically save flash scopes at end of a request and on relocations.
		};


	}

	function development(){
	}

}