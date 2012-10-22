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
			defaultEvent			= "general.index",
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
			customErrorTemplate		= "",
	
			//Application Aspects
			handlerCaching 			= false
		};

	}
	
}