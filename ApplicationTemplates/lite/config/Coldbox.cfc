component{

	// Configure ColdBox Application
	function configure(){
	
		// coldbox directives
		coldbox = {
			//Application Setup
			appName 				= "ColdBox LITE",
	
			//Development Settings
			reinitPassword			= "",
			handlersIndexAutoReload = true,
	
			//Implicit Events
			defaultEvent			= "",
			requestStartHandler		= "",
			requestEndHandler		= "",
			applicationStartHandler = "",
			applicationEndHandler	= "",
			sessionStartHandler 	= "",
			sessionEndHandler		= "",
			missingTemplateHandler	= "",
	
			//Error/Exception Handling
			exceptionHandler		= "",
			onInvalidEvent			= "",
			customErrorTemplate		= "includes/error.cfm",
	
			//Application Aspects
			handlerCaching 			= false
		};
		
		/**
		
		// custom settings
		settings = {

		};

		// environment settings, create a detectEnvironment() method to detect it yourself.
		// create a function with the name of the environment so it can be executed if that environment is detected
		// the value of the environment is a list of regex patterns to match the cgi.http_host.
		environments = {
			//development = "^cf8.,^railo."
		};
		
		// Layout Settings
		layoutSettings = {
			defaultLayout = ""
		};
		
		//Register Layouts
		layouts = [
			{ name = "login",
		 	  file = "Layout.tester.cfm",
			  views = "vwLogin,test",
			  folders = "tags,pdf/single"
			}
		];
		
		*/

	}
	
}