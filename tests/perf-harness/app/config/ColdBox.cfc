/**
 * Shared ColdBox configuration for performance harness.
 * appName and appKey are overridden per-version in be-app/config and stable-app/config.
 */
component {

	function configure(){
		variables.coldbox = {
			appName                 : "ColdBoxPerfHarness",
			eventName               : "event",
			reinitPassword          : "",
			reinitKey               : "fwreinit",
			handlersIndexAutoReload : false,
			debugMode               : false,
			defaultEvent            : "Main.index",
			requestStartHandler     : "",
			requestEndHandler       : "",
			applicationStartHandler : "",
			applicationEndHandler   : "",
			sessionStartHandler     : "",
			sessionEndHandler       : "",
			missingTemplateHandler  : "",
			applicationHelper       : "",
			viewsHelper             : "",
			modulesExternalLocation : [],
			viewsExternalLocation   : "",
			layoutsExternalLocation : "",
			handlersExternalLocation: "",
			requestContextDecorator : "",
			exceptionHandler        : "",
			invalidEventHandler     : "",
			customErrorTemplate     : "",
			handlerCaching          : true,
			eventCaching            : false,
			proxyReturnCollection   : false
		};

		variables.layoutSettings = {
			defaultLayout : "Main.cfm",
			defaultView   : ""
		};

		variables.modules = {
			autoReload : false,
			include    : [ "perf-module" ],
			exclude    : []
		};

		variables.interceptors = [
			{ class : "#appMapping#.interceptors.PerfInterceptor" }
		];

		variables.logBox = {
			appenders : {
				console : { class : "ConsoleAppender" }
			},
			root : { levelmax : "WARN", appenders : "*" }
		};
	}

}
